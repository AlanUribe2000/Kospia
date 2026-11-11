const { execFileSync } = require('node:child_process');
const { randomBytes } = require('node:crypto');
const { readFileSync } = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const { secret, token, stream } = require('./client');

const docker = 'docker';
const tag = `kospia-phase-b-${randomBytes(8).toString('hex')}`;
const label = `org.kospia.phase-b=${tag}`;
const rules = path.resolve(__dirname, '../../api/backend/powersync/sync-config.yaml');
const containers = [];
let networkId;
let service;
const keepAlive = setInterval(() => {}, 1000);

function cli(args, options = {}) {
  return execFileSync(docker, args, { encoding: 'utf8', ...options }).trim();
}

function start(name, args) {
  const id = cli(['run', '-d', '--pull', 'never', '--name', `${tag}-${name}`, '--label', label, ...args]);
  containers.push(id);
  console.log(`Container ${tag}-${name}: ${id}`);
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

async function main() {
  networkId = cli(['network', 'create', '--label', label, tag]);
  console.log(`Network ${tag}: ${networkId}`);
  const postgres = alias => [
    '--network', networkId, '--network-alias', alias,
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
  service = start('powersync', [
    '--network', networkId, '--network-alias', 'powersync', '-p', '127.0.0.1::8080',
    '--mount', `type=bind,src=${path.join(__dirname, 'service.yaml')},dst=/config/service.yaml,readonly`,
    '--mount', `type=bind,src=${rules},dst=/config/sync-config.yaml,readonly`,
    '-e', 'POWERSYNC_CONFIG_PATH=/config/service.yaml', '-e', 'PS_ADMIN_API_TOKEN=phase-b-admin-only',
    '-e', 'PS_JWT_KID=phase-b-key', '-e', `PS_JWT_SECRET=${secret.toString('base64url')}`,
    '-e', 'PS_JWT_AUDIENCE=phase-b-test',
    '-e', 'PS_DATA_SOURCE_URI=postgresql://powersync_role:phase-b-replication-only@source:5432/phase_b',
    '-e', 'PS_STORAGE_SOURCE_URI=postgresql://postgres:phase-b-postgres-only@storage:5432/phase_b',
    'journeyapps/powersync-service:latest', 'start', '-r', 'unified'
  ]);
  const port = await retry('Published PowerSync port', () => cli(['port', service, '8080/tcp'], { stdio: 'pipe' }).split(':').pop());
  const endpoint = `http://127.0.0.1:${port}`;
  console.log(`PowerSync endpoint: ${endpoint}`);
  await retry('PowerSync liveness', async () => {
    const response = await fetch(`${endpoint}/probes/liveness`, { signal: AbortSignal.timeout(3000) });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
  });
  const sql = query => cli(['exec', source, 'psql', '-v', 'ON_ERROR_STOP=1', '-U', 'postgres', '-d', 'phase_b', '-c', query]);
  const operations = result => result.lines.flatMap(line => line.data?.data || []);
  const snapshot = subject => stream(endpoint, token(subject));
  const find = (result, table, id) => {
    const latest = operations(result).filter(op => op.object_type === table && op.object_id === id).at(-1);
    return latest?.op === 'PUT' ? latest : undefined;
  };
  const checkpoints = result => result.lines.filter(line => line.data).map(line => ({ name: line.data.bucket, after: line.data.next_after }));

  sql("INSERT INTO observations VALUES ('obs-a','alice','sp-1','descripcion inicial','2026-01-01'),('obs-b','bob','sp-1','descripcion privada bob','2026-01-01'); INSERT INTO observation_photos VALUES ('photo-a','obs-a','synthetic/a.jpg','leaf',-41.0,-72.0,'jpg','2026-01-01'),('photo-b','obs-b','synthetic/b.jpg','flower',-42.0,-73.0,'jpg','2026-01-01'); INSERT INTO notifications VALUES ('notice-a','alice','hola alice'),('notice-b','bob','hola bob'); INSERT INTO observaciones (id,descripcion) VALUES ('legacy-a','dato ficticio global'); INSERT INTO fotografias_observacion (id,observacion_id,tipo_foto) VALUES ('legacy-photo-a','legacy-a','hoja');");
  sql("INSERT INTO questions (id) VALUES ('question-synthetic'); INSERT INTO question_options (id, question_id, option_text, description, icon_attachment_id, icon_extension) VALUES ('option-synthetic','question-synthetic','Opcion ficticia','Descripcion inicial',NULL,NULL); INSERT INTO question_option_photos (id, option_id, order_index, file_extension, created_at) VALUES ('option-photo-synthetic','option-synthetic',2,'jpg','2026-01-03T12:00:00Z');");
  const alice = await retry('Initial replication', async () => {
    const result = await snapshot('alice');
    assert.equal(result.status, 200);
    assert.equal(find(result, 'observations', 'obs-a')?.data.notes, 'descripcion inicial');
    assert.equal(find(result, 'observation_photos', 'photo-a')?.data.plant_part, 'leaf');
    assert.equal(find(result, 'observation_photos', 'photo-a')?.data.file_extension, 'jpg');
    assert.equal(find(result, 'observation_photos', 'photo-a')?.data.latitude, -41);
    assert.ok(find(result, 'notifications', 'notice-a'));
    assert.deepEqual(find(result, 'question_options', 'option-synthetic')?.data, {
      id: 'option-synthetic', question_id: 'question-synthetic', option_text: 'Opcion ficticia', description: 'Descripcion inicial',
      icon_attachment_id: null, icon_extension: null
    });
    assert.deepEqual(find(result, 'question_option_photos', 'option-photo-synthetic')?.data, {
      id: 'option-photo-synthetic', option_id: 'option-synthetic', order_index: 2, file_extension: 'jpg', created_at: '2026-01-03T12:00:00Z'
    });
    return result;
  });
  const bob = await retry('Bob replication', async () => {
    const result = await snapshot('bob');
    assert.ok(find(result, 'observations', 'obs-b'));
    assert.ok(find(result, 'observation_photos', 'photo-b'));
    assert.ok(find(result, 'notifications', 'notice-b'));
    return result;
  });
  for (const [result, ids] of [[alice, ['obs-b', 'photo-b', 'notice-b']], [bob, ['obs-a', 'photo-a', 'notice-a']]]) {
    for (const id of ids) assert.ok(!operations(result).some(op => op.object_id === id), `unexpected cross-user item ${id}`);
  }
  for (const result of [alice, bob]) {
    assert.ok(find(result, 'observaciones', 'legacy-a'));
    assert.ok(find(result, 'fotografias_observacion', 'legacy-photo-a'));
    assert.equal(find(result, 'question_options', 'option-synthetic')?.data.description, 'Descripcion inicial');
    assert.equal(find(result, 'question_option_photos', 'option-photo-synthetic')?.data.option_id, 'option-synthetic');
  }
  console.log('PASS creation and metadata; current user_data isolated for Alice and Bob');
  console.log('FINDING legacy observaciones and fotografias_observacion are global and visible to both users');
  console.log('PASS option description and photo metadata inserted; global catalog visible to Alice and Bob');

  sql("UPDATE question_options SET description='Descripcion actualizada' WHERE id='option-synthetic';");
  const optionUpdated = await retry('Option description update replication', async () => {
    const delta = await stream(endpoint, token('alice'), checkpoints(alice));
    assert.equal(find(delta, 'question_options', 'option-synthetic')?.data.description, 'Descripcion actualizada');
    return await snapshot('alice');
  });
  console.log('PASS option description update PUT delta');

  sql("UPDATE question_options SET icon_attachment_id='icon-synthetic', icon_extension='png' WHERE id='option-synthetic';");
  const iconAssociated = await retry('Icon association replication', async () => {
    const delta = await stream(endpoint, token('alice'), checkpoints(optionUpdated));
    const option = find(delta, 'question_options', 'option-synthetic');
    assert.equal(option?.data.icon_attachment_id, 'icon-synthetic');
    assert.equal(option?.data.icon_extension, 'png');
    assert.equal(option?.data.description, 'Descripcion actualizada');
    return await snapshot('alice');
  });
  console.log('PASS icon association PUT delta');

  sql("UPDATE question_options SET icon_attachment_id=NULL, icon_extension=NULL WHERE id='option-synthetic';");
  const iconDissociated = await retry('Icon dissociation replication', async () => {
    const delta = await stream(endpoint, token('alice'), checkpoints(iconAssociated));
    const option = find(delta, 'question_options', 'option-synthetic');
    assert.ok(option);
    assert.equal(option.data.icon_attachment_id, null);
    assert.equal(option.data.icon_extension, null);
    assert.equal(option.data.description, 'Descripcion actualizada');
    return await snapshot('alice');
  });
  console.log('PASS icon dissociation PUT delta');

  sql("DELETE FROM question_option_photos WHERE id='option-photo-synthetic';");
  await retry('Option photo removal replication', async () => {
    const delta = await stream(endpoint, token('alice'), checkpoints(iconDissociated));
    assert.ok(operations(delta).some(op => op.op === 'REMOVE' && op.object_type === 'question_option_photos' && op.object_id === 'option-photo-synthetic'));
    const result = await snapshot('alice');
    assert.ok(!find(result, 'question_option_photos', 'option-photo-synthetic'));
    assert.equal(find(result, 'question_options', 'option-synthetic')?.data.description, 'Descripcion actualizada');
  });
  console.log('PASS option photo DELETE produces REMOVE delta; option retained');

  sql("UPDATE observations SET notes='descripcion actualizada', updated_at='2026-01-02' WHERE id='obs-a'; UPDATE observation_photos SET plant_part='stem', file_extension='png', latitude=-40.5 WHERE id='photo-a';");
  const updated = await retry('Update replication', async () => {
    const result = await snapshot('alice');
    assert.equal(find(result, 'observations', 'obs-a')?.data.notes, 'descripcion actualizada');
    assert.equal(find(result, 'observation_photos', 'photo-a')?.data.plant_part, 'stem');
    assert.equal(find(result, 'observation_photos', 'photo-a')?.data.file_extension, 'png');
    assert.equal(find(result, 'observation_photos', 'photo-a')?.data.latitude, -40.5);
    return result;
  });
  console.log('PASS observation notes and photo metadata updates');

  sql("DELETE FROM observation_photos WHERE id='photo-a';");
  await retry('Photo removal replication', async () => {
    const delta = await stream(endpoint, token('alice'), checkpoints(updated));
    assert.ok(operations(delta).some(op => op.op === 'REMOVE' && op.object_type === 'observation_photos' && op.object_id === 'photo-a'));
    const result = await snapshot('alice');
    assert.ok(!find(result, 'observation_photos', 'photo-a'));
    assert.ok(find(result, 'observations', 'obs-a'));
  });
  assert.ok(find(await snapshot('bob'), 'observation_photos', 'photo-b'));
  console.log('PASS photo REMOVE delta; observation and Bob photo retained');
  const unauthenticated = await stream(endpoint, null);
  assert.ok([401, 403].includes(unauthenticated.status));
  console.log(`PASS missing JWT rejected (HTTP ${unauthenticated.status})`);
}

main().catch(error => {
  console.error(error);
  if (service) {
    try { execFileSync(docker, ['logs', '--tail', '80', service], { stdio: 'inherit' }); } catch (_) {}
  }
  process.exitCode = 1;
}).finally(() => {
  clearInterval(keepAlive);
  for (const id of containers.reverse()) {
    try { cli(['stop', '-t', '3', id]); console.log(`Stopped own container ${id}`); }
    catch (error) { console.error(`Could not stop own container ${id}: ${error.message}`); process.exitCode = 1; }
  }
  if (networkId) console.log(`Retained own network ${tag}: ${networkId}`);
});