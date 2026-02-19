# Deploying EMS to a Server

This guide covers moving your Employee Management System from local development to a server (VPS, cloud VM, or PaaS).

**Quick option (free):** To deploy with one click using **Render**, see **[docs/DEPLOY_TO_RENDER.md](docs/DEPLOY_TO_RENDER.md)**. Push to GitHub, connect the repo to Render, set env vars, and get a public URL.

---

## Prerequisites

- **Node.js** 18+ on the server
- **MongoDB**: either
  - **MongoDB Atlas** (cloud, recommended): create a free cluster at [mongodb.com/atlas](https://www.mongodb.com/atlas) and get a connection string, or
  - **MongoDB** installed on the same server or another machine
- **Git** (optional, to clone the repo on the server)

---

## Option A: Single server (recommended)

One machine serves both the API and the React app. Users open one URL (e.g. `https://ems.yourcompany.com`).

### 1. Build the app on your PC (or on the server)

From the project root (`ems/`):

```bash
npm run build
```

This creates `client/dist/` with the production frontend.

### 2. Copy the project to the server

- **Option 2a:** Upload the whole folder (e.g. with SCP, SFTP, or Git clone on the server).
- **Option 2b:** From your PC:
  ```bash
  scp -r ems user@your-server-ip:/var/www/
  ```
  (Replace `user`, `your-server-ip`, and path as needed.)

Ensure the server has the **built** `client/dist` folder. If you clone with Git on the server, run `npm run build` from the repo root on the server after `npm run install:all`.

### 3. Install dependencies on the server

On the server:

```bash
cd /var/www/ems   # or your path
npm run install:all
```

(This runs `npm install` in root, `server`, and `client`.)

### 4. Configure environment

Create or edit `server/.env` on the server:

```env
# Production
NODE_ENV=production
PORT=5000
HOST=0.0.0.0

# Serve React app from this server (single URL for users)
SERVE_CLIENT=true

# MongoDB: use your Atlas connection string or server MongoDB
MONGODB_URI=mongodb+srv://user:password@cluster.xxxxx.mongodb.net/ems?retryWrites=true&w=majority

# JWT: use a long random secret (never use the default in production)
JWT_SECRET=your-very-long-random-secret-at-least-32-chars
JWT_EXPIRES=7d

# Public URL where users open the app (for CORS and cookies)
CLIENT_URL=https://ems.yourcompany.com
```

Important:

- **MONGODB_URI**: Your real MongoDB connection string (Atlas or `mongodb://localhost:27017/ems` if MongoDB is on the same server).
- **JWT_SECRET**: Generate a strong secret, e.g. `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"`.
- **CLIENT_URL**: The exact URL users use (e.g. `https://ems.yourcompany.com`). No trailing slash.

### 5. Run the server

**One-off (for testing):**

```bash
npm start
```

**Keep it running (production):** use a process manager like **PM2**:

```bash
npm install -g pm2
cd server
pm2 start src/index.js --name ems
```

Then:

```bash
pm2 save
pm2 startup   # follow the command it prints so EMS starts on reboot
```

The app will be available at `http://YOUR_SERVER_IP:5000`. For HTTPS and a domain, put a reverse proxy (e.g. Nginx) in front (see below).

---

## Option B: Frontend and backend on different hosts

Example: frontend on **Vercel/Netlify**, backend on **Render/Railway/VPS**.

### 1. Backend server

- Deploy the **server** folder (or whole repo and run from `server/`).
- Do **not** set `SERVE_CLIENT=true`.
- Set env:
  - `MONGODB_URI`, `JWT_SECRET`, `NODE_ENV=production`
  - `CLIENT_URL=https://your-frontend-domain.com` (exact frontend URL for CORS)

### 2. Frontend build

Build the client with the **backend API URL**:

```bash
cd client
VITE_API_URL=https://your-api-domain.com/api npm run build
```

(Replace `https://your-api-domain.com/api` with your real API base URL.)

### 3. Deploy frontend

- Upload `client/dist/` to your frontend host (Vercel, Netlify, or any static host).
- Ensure the host serves `index.html` for client-side routes (e.g. SPA fallback).

---

## Reverse proxy and HTTPS (single server)

To use a domain and HTTPS (e.g. `https://ems.yourcompany.com`), put **Nginx** (or Caddy) in front of Node.

### Example Nginx config

```nginx
server {
    listen 80;
    server_name ems.yourcompany.com;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

- Install Nginx, enable this site, reload Nginx.
- Get a certificate (e.g. **Let’s Encrypt** with Certbot): `certbot --nginx -d ems.yourcompany.com`.

In `server/.env`, keep:

```env
CLIENT_URL=https://ems.yourcompany.com
```

---

## Checklist before go-live

| Item | Action |
|------|--------|
| **MONGODB_URI** | Set to real MongoDB (Atlas or server). |
| **JWT_SECRET** | Long random value; never use default in production. |
| **CLIENT_URL** | Exact public URL (https if you use SSL). |
| **SERVE_CLIENT** | `true` if same server serves API + React. |
| **Build** | Run `npm run build` so `client/dist` exists. |
| **Admin user** | Run `node server/src/scripts/seedAdmin.js` once (with server `.env` loaded) if you need a first admin. |

---

## Seed first admin on the server

From project root, with `server/.env` in place:

```bash
cd server
node src/scripts/seedAdmin.js
```

Set `ADMIN_EMAIL` and `ADMIN_PASSWORD` in `server/.env` or env when running this script. If an admin with that email already exists, the script does nothing.

---

## File uploads (documents, photos)

Uploaded files are stored on the **server’s disk** (see `server` code for paths). For a single-server deployment they live next to the app. If you later move to multiple backend instances, you’ll need a shared store (e.g. S3) and code changes; for one server, the default behavior is fine.

---

## Quick reference: env variables

| Variable | Required | Description |
|----------|----------|-------------|
| **MONGODB_URI** | Yes | MongoDB connection string. |
| **JWT_SECRET** | Yes (prod) | Secret for signing JWTs. |
| **NODE_ENV** | Recommended | `production` on server. |
| **PORT** | No | Default 5000. |
| **HOST** | No | Default `0.0.0.0`. |
| **CLIENT_URL** | Yes (prod) | Public app URL (for CORS/cookies). |
| **SERVE_CLIENT** | For Option A | `true` to serve React from Express. |
| **JWT_EXPIRES** | No | Default `7d`. |

You can copy `server/.env.example` to `server/.env` and fill in the values for your server.
