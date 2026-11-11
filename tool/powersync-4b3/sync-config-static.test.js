const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const root = path.resolve(__dirname, '../..');
const read = file => readFileSync(path.join(root, file), 'utf8').replace(/\r\n/g, '\n');
const config = read('api/backend/powersync/sync-config.yaml');
const candidate = read('tool/powersync-4b3/phase-d-candidate.yaml');

const expected = `# yaml-language-server: $schema=https://unpkg.com/@powersync/service-sync-rules@latest/schema/sync_rules.json

config:
  edition: 3

streams:
  global:
    auto_subscribe: true
    queries:
      - |
        SELECT
          id,
          title,
          completed
        FROM tasks

      - |
        SELECT
          id,
          codigo_origen,
          nombre_comun,
          nombre_cientifico,
          color_flor,
          tamano_flor,
          cantidad_petalos,
          tipo_planta,
          espinas,
          fruto_visible,
          color_fruto,
          forma_hoja,
          borde_hoja,
          altura_aproximada,
          habitat,
          descripcion,
          aroma,
          color_centro,
          agrupacion_flor,
          hojas_perennes,
          habitat_humedo,
          flor_colgante,
          flores_por_tallo,
          espinas_visibles,
          epoca_floracion,
          zona_patagonia,
          created_at,
          updated_at
        FROM flores
      - |
        SELECT * FROM species
      - |
        SELECT * FROM questions
      - |
        SELECT * FROM question_options
      - |
        SELECT * FROM question_option_photos
      - |
        SELECT * FROM species_traits

  user_data:
    auto_subscribe: true
    queries:
      - |
        SELECT *
        FROM observations
        WHERE user_id = auth.user_id()
      - |
        SELECT *
        FROM observation_photos
        WHERE observation_id IN (
          SELECT id
          FROM observations
          WHERE user_id = auth.user_id()
        )
      - |
        SELECT *
        FROM notifications
        WHERE CAST(user_id AS TEXT) = auth.user_id()
`;

test('preserves every other query and stream configuration literally', () => {
  assert.equal(config, expected.slice(0, -1));
});

test('does not reference the excluded legacy tables', () => {
  assert.doesNotMatch(config, /\b(?:observaciones|fotografias_observacion)\b/i);
});

test('retains the candidate owner filters and global catalog', () => {
  const normalize = value => value.replace(/\s+/g, ' ').trim();
  const configSql = normalize(config.replace(/- \|/g, ''));
  for (const sql of [
    'SELECT * FROM species',
    'SELECT * FROM questions',
    'SELECT * FROM question_options',
    'SELECT * FROM question_option_photos',
    'SELECT * FROM species_traits',
    'SELECT * FROM observations WHERE user_id = auth.user_id()',
    'SELECT * FROM observation_photos WHERE observation_id IN ( SELECT id FROM observations WHERE user_id = auth.user_id() )',
    'SELECT * FROM notifications WHERE CAST(user_id AS TEXT) = auth.user_id()',
  ]) {
    assert.ok(configSql.includes(sql), `missing in config: ${sql}`);
    assert.ok(normalize(candidate.replace(/- \|/g, '')).includes(sql), `missing in candidate: ${sql}`);
  }
});