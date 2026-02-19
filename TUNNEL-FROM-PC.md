# Option 2: Use a tunnel so the app is reachable from any network

Use a **tunnel** (e.g. ngrok) so your **local** app gets a public URL. You can open it from another Wi‑Fi or mobile data. Your PC must stay on and the app must keep running.

---

## What you need

- [ngrok](https://ngrok.com/download) (free account)
- MongoDB running locally (or a `MONGODB_URI` in `server/.env`)
- Node.js to run the server and build the client

---

## Step 1: Install ngrok

1. Download from [ngrok.com/download](https://ngrok.com/download) and install.
2. Sign up at [ngrok.com](https://ngrok.com) and copy your auth token.
3. Run once: `ngrok config add-authtoken YOUR_TOKEN`.

---

## Step 2: Build the frontend (relative API)

The app and API will be on the **same URL**, so the frontend should call `/api` on the same origin. Do **not** set `VITE_API_URL` when building.

From the project root (e.g. `ems`):

```bash
cd client
npm run build
cd ..
```

If you already have `VITE_API_URL` in `client/.env`, remove it or leave it empty for this tunnel setup.

---

## Step 3: Start the tunnel first (to get your public URL)

In a terminal:

```bash
ngrok http 5000
```

Leave this running. You’ll see something like:

```text
Forwarding   https://abc123.ngrok-free.app -> http://localhost:5000
```

Copy the **HTTPS URL** (e.g. `https://abc123.ngrok-free.app`). This is your **public URL** for the app.

---

## Step 4: Allow that URL in the server (CORS)

In `server/.env` set:

- **CLIENT_URL** = your ngrok URL from Step 3 (no trailing slash), e.g. `https://abc123.ngrok-free.app`

So the server allows that origin for CORS and cookies.

---

## Step 5: Start the server (serving the built client)

From the project root:

```bash
cd server
set SERVE_CLIENT=true
npm start
```

On macOS/Linux use `export SERVE_CLIENT=true` instead of `set`.

The server will:

- Listen on port 5000
- Serve the API under `/api`
- Serve the built frontend (login, dashboard, etc.) for all other paths

Keep this terminal open.

---

## Step 6: Open the app from any device

On your phone or another PC (any network), open in the browser:

**https://YOUR_NGROK_URL**  
(e.g. `https://abc123.ngrok-free.app`)

Log in and use the app as usual.

---

## Summary

| Step | What to do |
|------|------------|
| 1 | Install ngrok and add your auth token |
| 2 | `cd client` → `npm run build` (no `VITE_API_URL`) |
| 3 | Run `ngrok http 5000`, copy the HTTPS URL |
| 4 | In `server/.env` set `CLIENT_URL` = that ngrok URL |
| 5 | `cd server` → `SERVE_CLIENT=true` and `npm start` |
| 6 | Open the ngrok URL on any device |

---

## Notes

- **Free ngrok URLs change** each time you restart ngrok. After a new URL, update `CLIENT_URL` in `server/.env` and restart the server (Step 4 and 5).
- Your **PC must stay on** and both **ngrok** and the **server** must keep running.
- For a **fixed URL** or no “Visit Site” interstitial, use a paid ngrok plan or see **DEPLOY-TO-CLOUD.md** for a permanent deployment.
