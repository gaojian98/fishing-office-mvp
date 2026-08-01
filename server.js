import http from 'node:http';
import { createReadStream, existsSync } from 'node:fs';
import { readFile, stat } from 'node:fs/promises';
import { extname, join, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = fileURLToPath(new URL('.', import.meta.url));
const webDir = join(__dirname, 'fishing_office_flutter', 'build', 'web');
const port = Number(process.env.PORT || 3100);

const mimeTypes = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.mjs': 'application/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.wasm': 'application/wasm',
  '.map': 'application/json; charset=utf-8',
  '.txt': 'text/plain; charset=utf-8',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
};

function contentType(filePath) {
  return mimeTypes[extname(filePath).toLowerCase()] || 'application/octet-stream';
}

async function sendFile(res, filePath) {
  const type = contentType(filePath);
  res.writeHead(200, { 'content-type': type });
  createReadStream(filePath).pipe(res);
}

async function sendIndex(res) {
  const indexPath = join(webDir, 'index.html');
  if (!existsSync(indexPath)) {
    res.writeHead(500, { 'content-type': 'text/plain; charset=utf-8' });
    res.end('Flutter build/web not found. Run flutter build web --release first.');
    return;
  }
  const html = await readFile(indexPath, 'utf8');
  res.writeHead(200, { 'content-type': 'text/html; charset=utf-8' });
  res.end(html);
}

function resolvePath(urlPath) {
  const cleanPath = normalize(urlPath).replace(/^([/\\])+/, '');
  const filePath = join(webDir, cleanPath);
  return filePath.startsWith(webDir) ? filePath : null;
}

const server = http.createServer(async (req, res) => {
  try {
    const requestUrl = new URL(req.url || '/', 'http://fishing-office.invalid');
    const pathname = requestUrl.pathname;
    const filePath = resolvePath(pathname);

    if (filePath && existsSync(filePath)) {
      const fileStat = await stat(filePath);
      if (fileStat.isFile()) {
        await sendFile(res, filePath);
        return;
      }
    }

    if (pathname === '/' || pathname === '/home' || pathname === '/index.html' || pathname.startsWith('/#/')) {
      await sendIndex(res);
      return;
    }

    if (pathname === '/office-fishing/' || pathname === '/office-fishing.html') {
      await sendIndex(res);
      return;
    }

    const fallback = join(webDir, 'index.html');
    if (existsSync(fallback)) {
      await sendIndex(res);
      return;
    }

    res.writeHead(404, { 'content-type': 'text/plain; charset=utf-8' });
    res.end('Not found');
  } catch (error) {
    res.writeHead(500, { 'content-type': 'text/plain; charset=utf-8' });
    res.end(String(error));
  }
});

server.listen(port, () => {
  console.log(`Fishing Office MVP listening on ${port}`);
});
