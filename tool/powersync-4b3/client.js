const http = require('node:http');
const { createHmac } = require('node:crypto');

const secret = Buffer.from('phase-b-synthetic-test-secret-32-bytes');
const encode = value => Buffer.from(JSON.stringify(value)).toString('base64url');

function token(subject) {
  const now = Math.floor(Date.now() / 1000);
  const header = encode({ alg: 'HS256', typ: 'JWT', kid: 'phase-b-key' });
  const payload = encode({ sub: subject, aud: 'phase-b-test', iat: now, exp: now + 600 });
  const content = `${header}.${payload}`;
  return `${content}.${createHmac('sha256', secret).update(content).digest('base64url')}`;
}

function stream(endpoint, credential, buckets = []) {
  return new Promise((resolve, reject) => {
    let finished = false;
    const lines = [];
    const request = http.request(`${endpoint}/sync/stream`, {
      method: 'POST',
      headers: {
        ...(credential ? { authorization: `Bearer ${credential}` } : {}),
        'content-type': 'application/json',
        accept: 'application/x-ndjson'
      }
    }, response => {
      if (response.statusCode !== 200) {
        finished = true;
        response.resume();
        resolve({ status: response.statusCode, lines });
        return;
      }
      let pending = '';
      response.setEncoding('utf8');
      response.on('data', chunk => {
        pending += chunk;
        while (pending.includes('\n')) {
          const end = pending.indexOf('\n');
          const line = pending.slice(0, end);
          pending = pending.slice(end + 1);
          if (!line) continue;
          try {
            const parsed = JSON.parse(line);
            lines.push(parsed);
            if (parsed.checkpoint_complete) {
              finished = true;
              resolve({ status: response.statusCode, lines });
              request.destroy();
              return;
            }
          } catch (error) {
            finished = true;
            request.destroy();
            reject(error);
            return;
          }
        }
      });
      response.on('end', () => {
        if (!finished) reject(new Error('Stream ended before checkpoint_complete'));
      });
    });
    request.setTimeout(15000, () => request.destroy(new Error('Stream timeout')));
    request.on('error', error => { if (!finished) reject(error); });
    request.end(JSON.stringify({ buckets, streams: { include_defaults: true, subscriptions: [] } }));
  });
}

module.exports = { secret, token, stream };