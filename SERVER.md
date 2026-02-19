# EMS Server – How to Run

The API server is in the `server` folder. Choose one of the following ways to run it.

---

## 1. Local (development)

**Requirements:** Node.js 18+, MongoDB running locally or a MongoDB Atlas URI.

```bash
cd server
cp .env.example .env
# Edit .env: set MONGODB_URI, JWT_SECRET, CLIENT_URL if needed
npm install
npm run dev
```

- Server: **http://localhost:5000**
- With `HOST=0.0.0.0` in `.env`, other devices on your network can use **http://YOUR_PC_IP:5000**

---

## 2. Production with PM2

Keeps the server running in the background and restarts it if it crashes.

```bash
cd server
npm install
cp .env.example .env
# Edit .env for production (MONGODB_URI, JWT_SECRET, CLIENT_URL)

npx pm2 start ecosystem.config.cjs --env production
pm2 save
pm2 startup   # optional: start on system boot
```

Useful commands:

- `pm2 status`        – list processes  
- `pm2 logs ems-server` – view logs  
- `pm2 restart ems-server` – restart  

---

## 3. Docker (server + MongoDB)

Runs the API and MongoDB in containers. No need to install MongoDB on the host.

**From the project root (where `docker-compose.yml` is):**

```bash
# Create server/.env with at least JWT_SECRET and optional CLIENT_URL
cd server && cp .env.example .env && cd ..

docker-compose up -d
```

- API: **http://localhost:5000**  
- MongoDB: **localhost:27017** (internal to Docker)

To use from another device on your network, set in `server/.env` or in `docker-compose.yml`:

- `CLIENT_URL=http://YOUR_PC_IP:5173`

Then open **http://YOUR_PC_IP:5173** on the other device (with the client built and served, or via Vite dev server bound to `0.0.0.0`).

---

## Environment variables

| Variable       | Description |
|----------------|-------------|
| `PORT`         | Port (default: 5000) |
| `HOST`         | Bind address (default: 0.0.0.0 for all interfaces) |
| `MONGODB_URI`  | MongoDB connection string |
| `JWT_SECRET`   | Secret for JWT (use a strong value in production) |
| `JWT_EXPIRES`  | Token expiry (e.g. 7d) |
| `CLIENT_URL`   | Frontend origin for CORS and Socket.IO (e.g. http://localhost:5173 or http://YOUR_IP:5173) |

---

## Health check

- **GET** `/api/health` → `{ "status": "ok", "timestamp": "..." }`
