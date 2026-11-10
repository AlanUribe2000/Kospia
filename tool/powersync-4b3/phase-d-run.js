const { execFileSync } = require('node:child_process');
const { randomBytes, createHmac } = require('node:crypto');
const { readFileSync, openSync, writeSync, closeSync } = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const { format } = require('node:util');
const { secret, token, stream } = require('./client');

const evidenceName = process.argv[2] || 'phase-d-evidence.txt';
if (!/^phase-d-evidence(?:-\d+)?\.txt$/.test(evidenceName)) throw new Error('Invalid evidence filename');
const evidence = openSync(path.join(__dirname, evidenceName), 'wx');
for (const level of ['log', 'error']) {
  const original = console[level].bind(console);
  console[level] = (...args) => {
    writeSync(evidence, `${format(...args)}\n`);
    original(...args);
  };
}

const docker = 'C:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe';
const tag = `kospia-phase-d-${randomBytes(8).toString('hex')}`;
const label = `org.kospia.phase-d=${tag}`;
const containers = [];
const networks = [];
const keepAlive = setInterval(() => console.log('WAIT phase-d fixture running'), 5000);
let service;

function cli(args, options = {}) {
  return execFileSync(docker, args, { encoding: 'utf8', ...options }).trim();
}

function network(name, internal) {
  const id = cli(['network', 'create', '--label', label, ...(internal ? ['--internal'] : []), `${tag}-${name}`]);
  networks.push(id);
  console.log(`NETWORK ${name} ${id} internal=${internal}`);
  return id;
}

function start(name, args) {
  const id = cli(['run', '-d', '--pull', 'never', '--name', `${tag}-${name}`, '--label', label, ...args]);
  containers.push(id);
  console.log(`CONTAINER ${name} ${id}`);
  return id;
}

async function retry(description, action, timeout = 120000) {
  const deadline = Date.now() + timeout;
  let lastError;
  while (Date.now() < deadline) {
    try { return await action(); }
    catch (error) { lastError = error; await new Promise(resolve => setTimeout(resolve, 1000)); }
  }
  throw new Error(`${description}: ${lastError}`);
}

function expiredToken(subject) {
  const encode = value => Buffer.from(JSON.stringify(value)).toString('base64url');
  const content = `${encode({ alg: 'HS256', typ: 'JWT', kid: 'phase-b-key' })}.${encode({ sub: subject, aud: 'phase-b-test', exp: 1 })}`;
  return `${content}.${createHmac('sha256', secret).update(content).digest('base64url')}`;
}

async function main() {
  console.log(`RUN ${tag}`);
  const internal = network('internal', true);
  const ingress = network('ingress', false);
  const postgres = alias => [
    '--network', internal, '--network-alias', alias,
    '--tmpfs', '/var/lib/postgresql/data:rw',
    '-e', 'POSTGRES_PASSWORD=phase-b-postgres-only', '-e', 'POSTGRES_DB=phase_b',
    'postgres:16', 'postgres', '-c', 'wal_level=logical'
  ];
  const source = start('source', postgres('source'));
  const storage = start('storage', postgres('storage'));
  for (const id of [source, storage]) {
    await retry('PostgreSQL readiness', () => cli(['exec', id, 'pg_isready', '-U', 'postgres', '-d', 'phase_b'], { stdio: 'pipe' }));
  }
  cli(['exec', '-i', source, 'psql', '-v', 'ON_ERROR_STOP=1', '-U', 'postgres', '-d', 'phase_b'], {
    input: readFileSync(path.join(__dirname, 'schema.sql'), 'utf8')
  });
  service = cli(['create', '--pull', 'never', '--name', `${tag}-powersync`, '--label', label,
    '--network', ingress, '-p', '127.0.0.1::8080',
    '--mount', `type=bind,src=${path.join(__dirname, 'service.yaml')},dst=/config/service.yaml,readonly`,
    '--mount', `type=bind,src=${path.join(__dirname, 'phase-d-candidate.yaml')},dst=/config/sync-config.yaml,readonly`,
    '-e', 'POWERSYNC_CONFIG_PATH=/config/service.yaml', '-e', 'PS_ADMIN_API_TOKEN=phase-b-admin-only',
    '-e', 'PS_JWT_KID=phase-b-key', '-e', `PS_JWT_SECRET=${secret.toString('base64url')}`,
    '-e', 'PS_JWT_AUDIENCE=phase-b-test',
    '-e', 'PS_DATA_SOURCE_URI=postgresql://powersync_role:phase-b-replication-only@source:5432/phase_b',
    '-e', 'PS_STORAGE_SOURCE_URI=postgresql://postgres:phase-b-postgres-only@storage:5432/phase_b',
    'journeyapps/powersync-service:latest', 'start', '-r', 'unified'
  ]);
  containers.push(service);
  console.log(`CONTAINER powersync ${service}`);
  cli(['network', 'connect', '--alias', 'powersync', internal, service]);
  cli(['start', service]);
  console.log('INFO PostgreSQL internal-only; PowerSync also on own non-internal ingress network');
  const publishedPort = () => {
    const value = cli(['port', service, '8080/tcp'], { stdio: 'pipe' });
    assert.match(value, /^127\.0\.0\.1:\d+$/);
    return value.split(':').pop();
  };
  const endpoint = `http://127.0.0.1:${await retry('Published port', publishedPort, 15000)}`;
  const alive = async () => {
    const response = await fetch(`${endpoint}/probes/liveness`, { signal: AbortSignal.timeout(2000) });
    assert.equal(response.status, 200);
  };
  await retry('PowerSync liveness', alive, 120000);
  console.log(`ENDPOINT ${endpoint}`);
  const sql = query => cli(['exec', source, 'psql', '-v', 'ON_ERROR_STOP=1', '-U', 'postgres', '-d', 'phase_b', '-c', query]);
  const operations = result => result.lines.flatMap(line => line.data?.data || []);
  const find = (result, table, id) => {
    const latest = operations(result).filter(op => op.object_type === table && op.object_id === id).at(-1);
    return latest?.op === 'PUT' ? latest : undefined;
  };
  const checkpoints = result => result.lines.filter(line => line.data).map(line => ({ name: line.data.bucket, after: line.data.next_after }));
  const snapshot = subject => stream(endpoint, token(subject));

  for (const [description, credential] of [['missing', null], ['malformed', 'not-a-jwt'], ['bad-signature', `${token('alice').slice(0, -8)}invalidX`], ['expired', expiredToken('alice')]]) {
    const result = await stream(endpoint, credential);
    assert.ok([401, 403].includes(result.status), `${description}: HTTP ${result.status}`);
    console.log(`PASS ${description} JWT rejected HTTP ${result.status}`);
  }

  sql("INSERT INTO observations VALUES ('obs-a','alice','sp-1','private-a','2026-01-01'),('obs-b','bob','sp-1','private-b','2026-01-01'),('obs-pro','professional','sp-1','private-pro','2026-01-01'),('obs-admin','admin','sp-1','private-admin','2026-01-01'); INSERT INTO observation_photos VALUES ('photo-a','obs-a','a.jpg','leaf',-41,-72,'jpg','2026-01-01'),('photo-b','obs-b','b.jpg','leaf',-42,-73,'jpg','2026-01-01'),('photo-pro','obs-pro','pro.jpg','leaf',NULL,NULL,'jpg','2026-01-01'),('photo-admin','obs-admin','admin.jpg','leaf',NULL,NULL,'jpg','2026-01-01'); INSERT INTO notifications VALUES ('notice-a','alice','private-a'),('notice-b','bob','private-b'),('notice-pro','professional','private-pro'),('notice-admin','admin','private-admin'); INSERT INTO observaciones (id,descripcion) VALUES ('legacy-a','private-legacy'); INSERT INTO fotografias_observacion (id,observacion_id,tipo_foto) VALUES ('legacy-photo-a','legacy-a','leaf'); INSERT INTO species VALUES ('sp-1','synthetic'); INSERT INTO questions VALUES ('q-1'); INSERT INTO question_options (id,question_id,option_text,description) VALUES ('opt-1','q-1','synthetic','initial'); INSERT INTO question_option_photos (id,option_id,order_index) VALUES ('opt-photo-1','opt-1',1); INSERT INTO species_traits VALUES ('trait-1');");
  const subjects = [['alice', 'a'], ['bob', 'b'], ['professional', 'pro'], ['admin', 'admin']];
  const privateTables = ['observations', 'observation_photos', 'notifications'];
  const catalog = [['species', 'sp-1'], ['questions', 'q-1'], ['question_options', 'opt-1'], ['question_option_photos', 'opt-photo-1'], ['species_traits', 'trait-1']];
  const results = new Map();
  for (const [subject, suffix] of subjects) {
    const result = await retry(`Replication ${subject}`, async () => {
      const current = await snapshot(subject);
      assert.equal(current.status, 200);
      for (const [table, id] of [...catalog, ['observations', `obs-${suffix}`], ['observation_photos', `photo-${suffix}`], ['notifications', `notice-${suffix}`]]) {
        assert.ok(find(current, table, id), `missing ${table}/${id} for ${subject}`);
      }
      return current;
    });
    for (const [, other] of subjects.filter(([name]) => name !== subject)) {
      for (const id of [`obs-${other}`, `photo-${other}`, `notice-${other}`]) {
        assert.ok(!operations(result).some(op => op.object_id === id), `${subject} saw ${id}`);
      }
    }
    assert.ok(!operations(result).some(op => ['observaciones', 'fotografias_observacion'].includes(op.object_type)), `${subject} saw legacy data`);
    for (const line of result.lines.filter(item => item.data && /global/i.test(item.data.bucket))) {
      assert.ok(!line.data.data.some(op => privateTables.includes(op.object_type)), `private row in global bucket ${line.data.bucket}`);
    }
    assert.ok(result.lines.some(item => item.data && /global/i.test(item.data.bucket)), 'global bucket not observed');
    results.set(subject, result);
    console.log(`PASS ${subject}: own private rows, five global tables, no other users or legacy`);
  }
  console.log('PASS professional/admin are subjects with no role claim and receive no extra privileges; no cross-user role policy asserted');

  sql("UPDATE observations SET notes='updated' WHERE id='obs-a'; UPDATE observation_photos SET plant_part='stem' WHERE id='photo-a'; UPDATE notifications SET body='updated' WHERE id='notice-a'; UPDATE question_options SET description='updated' WHERE id='opt-1';");
  const updated = await retry('Update deltas', async () => {
    const delta = await stream(endpoint, token('alice'), checkpoints(results.get('alice')));
    for (const [table, id, field] of [['observations','obs-a','notes'], ['observation_photos','photo-a','plant_part'], ['notifications','notice-a','body'], ['question_options','opt-1','description']]) {
      assert.equal(find(delta, table, id)?.data[field], table === 'observation_photos' ? 'stem' : 'updated');
    }
    return await snapshot('alice');
  });
  console.log('PASS private and catalog update PUT deltas');
  sql("DELETE FROM observation_photos WHERE id='photo-a'; DELETE FROM question_option_photos WHERE id='opt-photo-1';");
  const afterPhotos = await retry('Photo removal deltas', async () => {
    const delta = await stream(endpoint, token('alice'), checkpoints(updated));
    for (const [table, id] of [['observation_photos','photo-a'], ['question_option_photos','opt-photo-1']]) {
      assert.ok(operations(delta).some(op => op.op === 'REMOVE' && op.object_type === table && op.object_id === id), `missing REMOVE ${table}/${id}`);
    }
    return await snapshot('alice');
  });
  sql("DELETE FROM notifications WHERE id='notice-a'; DELETE FROM observations WHERE id='obs-a';");
  await retry('Observation removal deltas', async () => {
    const delta = await stream(endpoint, token('alice'), checkpoints(afterPhotos));
    for (const [table, id] of [['observations','obs-a'], ['notifications','notice-a']]) {
      assert.ok(operations(delta).some(op => op.op === 'REMOVE' && op.object_type === table && op.object_id === id), `missing REMOVE ${table}/${id}`);
    }
  });
  const bob = await snapshot('bob');
  for (const [table, id] of [['observations','obs-b'], ['observation_photos','photo-b'], ['notifications','notice-b']]) assert.ok(find(bob, table, id));
  console.log('PASS private and catalog REMOVE deltas; Bob private rows retained');
}

main().catch(error => {
  console.error('FAIL', error);
  if (service) {
    try { console.error(cli(['logs', '--tail', '80', service], { stdio: 'pipe' })); } catch (_) {}
  }
  process.exitCode = 1;
}).finally(() => {
  clearInterval(keepAlive);
  for (const id of containers.reverse()) {
    try { cli(['rm', '-f', id]); console.log(`REMOVED own container ${id}`); }
    catch (error) { console.error(`CLEANUP ERROR container ${id}: ${error.message}`); process.exitCode = 1; }
  }
  for (const id of networks.reverse()) {
    try { cli(['network', 'rm', id]); console.log(`REMOVED own network ${id}`); }
    catch (error) { console.error(`CLEANUP ERROR network ${id}: ${error.message}`); process.exitCode = 1; }
  }
  console.log(`EXIT ${process.exitCode || 0}`);
  closeSync(evidence);
});