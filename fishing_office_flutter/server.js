import http from 'node:http';
import { createReadStream, existsSync } from 'node:fs';
import { extname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = fileURLToPath(new URL('.', import.meta.url));
const staticDir = join(__dirname, 'build', 'web');
const port = Number(process.env.PORT || 3000);

const mime = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.png': 'image/png',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.json': 'application/json; charset=utf-8',
  '.wasm': 'application/wasm'
};

function serveFile(res, filePath) {
  const type = mime[extname(filePath)] || 'application/octet-stream';
  res.writeHead(200, { 'content-type': type });
  createReadStream(filePath).pipe(res);
}

http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);
  const path = url.pathname === '/' ? '/index.html' : url.pathname;
  const filePath = join(staticDir, path);

  if (existsSync(filePath) && filePath.startsWith(staticDir)) {
    return serveFile(res, filePath);
  }

  const indexPath = join(staticDir, 'index.html');
  if (existsSync(indexPath)) {
    return serveFile(res, indexPath);
  }

  res.writeHead(404);
  res.end('Not found');
}).listen(port, () => {
  console.log(`fishing-office-mvp listening on ${port}`);
});
