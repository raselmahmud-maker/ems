# Access the app from a different network (different Wi‑Fi, mobile data, etc.)

When you're **not on the same Wi‑Fi** as your PC, the app’s local address (e.g. `http://192.168.1.100:5173`) won’t work. You need the app to be reachable from the **internet**.

You have two main options:

---

## Option 1: Deploy to a cloud server (recommended)

Put the **API server + database** (and optionally the frontend) on a **host that has a public URL**. Then you (and others) can use that URL from **any device, any network** (different Wi‑Fi, mobile data, another city, etc.).

### What you need

- A **MongoDB** database (e.g. [MongoDB Atlas](https://www.mongodb.com/cloud/atlas) – free tier is enough).
- A **host for the Node server** (e.g. [Railway](https://railway.app), [Render](https://render.com), [Fly.io](https://fly.io), or a VPS).
- Optionally, host the **frontend** on the same service or on [Vercel](https://vercel.com) / [Netlify](https://netlify.com).

### Steps (high level)

1. **MongoDB Atlas**
   - Create a free cluster.
   - Get the connection string (e.g. `mongodb+srv://user:pass@cluster.mongodb.net/ems`).
   - Use this as `MONGODB_URI` for your server.

2. **Deploy the backend**
   - Push your code to GitHub (or use the host’s CLI).
   - Create a new “Web Service” / “App” and point it to your **server** folder (Node.js).
   - Set environment variables:
     - `MONGODB_URI` = your Atlas connection string  
     - `JWT_SECRET` = a long random string  
     - `CLIENT_URL` = the URL where the frontend will run (e.g. `https://your-app.vercel.app` or the same host URL).

3. **Deploy the frontend**
   - Build: `cd client && npm run build`.
   - Either:
     - Deploy the `client/dist` folder to Vercel/Netlify, or
     - Serve it from the same Node server (add static hosting of `dist` in Express).
   - Set **one** env variable for the build: `VITE_API_URL` = your API base URL (e.g. `https://your-api.railway.app/api`). Rebuild after changing this.

4. **Use the app**
   - Open the **frontend URL** (e.g. `https://your-app.vercel.app`) on **any device, any network** and log in.

**→ Full step-by-step:** see **[DEPLOY-TO-CLOUD.md](DEPLOY-TO-CLOUD.md)** (MongoDB Atlas + Railway or Render + Vercel + first admin).

---

## Option 2: Temporary tunnel from your PC (no deployment)

Use a **tunnel** so your **local** app is temporarily reachable from the internet. Good for testing or short‑term use; your PC must stay on and running the app.

### Using ngrok (example)

1. Install [ngrok](https://ngrok.com/download) and create a free account.
2. On your PC, start the app as usual (server on 5000, client on 5173).
3. In a **new terminal** run:
   ```bash
   ngrok http 5173
   ```
4. ngrok will show a public URL, e.g. `https://abc123.ngrok.io`.
5. **Problem:** The frontend (Vite) will try to call `/api` on that URL, but your API is on port 5000. So you either:
   - Expose **both** (e.g. run a second ngrok for 5000 and set `VITE_API_URL` to that), or  
   - Serve the **built** frontend from the **same** Node server and expose only port 5000 with ngrok (so one URL for both API and app).

**Simpler approach with one URL:**

- Build the frontend with `VITE_API_URL` set to your **ngrok API URL** (e.g. `https://xyz.ngrok.io/api` if you tunnel port 5000).
- Serve the built files from Express (static from `client/dist`).
- Run only the server (port 5000) and tunnel **that** with ngrok. Then open the ngrok URL in the browser on any device.

Free ngrok URLs change each time you restart; paid plans give a fixed domain.

**→ Full step-by-step:** see **[TUNNEL-FROM-PC.md](TUNNEL-FROM-PC.md)** (ngrok + single URL with server serving the built client).

---

## Summary

| Situation | What to do |
|-----------|------------|
| Same Wi‑Fi only | Use **CONNECT-FROM-ANOTHER-DEVICE.md** (PC IP + firewall). |
| Different Wi‑Fi / mobile data / anywhere | **Deploy** (Option 1) so the app has a public URL, or use a **tunnel** (Option 2) from your PC. |
| Long‑term or for a team | Deploy to a cloud server (Option 1). |

If you say which you prefer (e.g. “deploy on Railway” or “tunnel with ngrok”), the next step can be a concrete, copy‑paste checklist for that.
