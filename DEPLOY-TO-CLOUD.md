# Deploy EMS to the cloud (use from any Wi‑Fi or mobile data)

Follow these steps to get a public URL so you can open the app from **any device, any network**.

---

## What you’ll get

- **Backend (API):** e.g. `https://ems-api.railway.app` or `https://your-app.onrender.com`
- **Frontend (app):** e.g. `https://ems-yourname.vercel.app`
- **Database:** MongoDB Atlas (free tier)

You’ll use the **frontend URL** to log in from anywhere.

---

## Part 1: MongoDB Atlas (database)

1. Go to [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas) and create a free account.
2. **Create a cluster:** Choose the free tier (M0), pick a region near you, create.
3. **Database access:**
   - Left menu → **Database Access** → **Add New Database User**
   - Username and password (save the password).
   - Permissions: **Atlas admin** or **Read and write to any database**.
4. **Network access:**
   - Left menu → **Network Access** → **Add IP Address**
   - Click **Allow Access from Anywhere** (0.0.0.0/0) for simplicity, then confirm.
5. **Get connection string:**
   - Left menu → **Database** → **Connect** on your cluster.
   - Choose **Connect your application**.
   - Copy the URI. It looks like:
     ```text
     mongodb+srv://USERNAME:PASSWORD@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
     ```
   - Replace `<password>` with your real database user password (no angle brackets).
   - Add a database name before the `?`: e.g. `ems` → `...mongodb.net/ems?retryWrites=...`
   - Save this as your **MONGODB_URI** (you’ll use it in Part 2).

---

## Part 2: Deploy the backend (Railway or Render)

### Option A: Railway

1. Go to [railway.app](https://railway.app), sign in with GitHub.
2. **New Project** → **Deploy from GitHub repo**. Connect the repo that contains your EMS code (or upload the `server` folder).
3. If the repo is the full project (client + server):
   - After the first deploy, open the service → **Settings** → **Root Directory** set to **server**.
   - **Build Command:** leave empty or `npm install`.
   - **Start Command:** `npm start` or `node src/index.js`.
4. If you only pushed the `server` folder, Root Directory can stay empty; **Start Command:** `npm start`.
5. **Variables** (Settings → Variables). Add:

   | Name          | Value |
   |---------------|--------|
   | `NODE_ENV`    | `production` |
   | `PORT`        | `5000` (Railway often sets this automatically; you can leave it) |
   | `MONGODB_URI` | Your Atlas URI from Part 1 |
   | `JWT_SECRET`  | A long random string (e.g. 32+ characters) |
   | `JWT_EXPIRES` | `7d` |
   | `CLIENT_URL`  | Your frontend URL from Part 3, e.g. `https://ems-xxx.vercel.app` (no trailing slash) |

6. **Deploy.** When it’s running, open **Settings** → **Networking** → **Generate Domain**. Copy the URL (e.g. `https://ems-api-production-xxxx.up.railway.app`). This is your **API URL**. You’ll need it for the frontend.

### Option B: Render

1. Go to [render.com](https://render.com), sign in with GitHub.
2. **New** → **Web Service** → connect the repo.
3. **Root Directory:** `server`.
4. **Environment:** Node.
5. **Build Command:** `npm install`.
6. **Start Command:** `npm start`.
7. **Environment Variables:** Add the same as in the table above. For `CLIENT_URL` use your Vercel URL from Part 3 (you can add it after the first deploy and redeploy).
8. Create the service. Render will give a URL like `https://ems-server-xxxx.onrender.com`. This is your **API URL**.

---

## Part 3: Deploy the frontend (Vercel)

1. Go to [vercel.com](https://vercel.com), sign in with GitHub.
2. **Add New** → **Project** → import the same repo.
3. **Root Directory:** set to **client** (or leave empty if the repo root is the app and you’ll set build settings to use `client`).
4. **Build settings:**
   - **Framework Preset:** Vite.
   - **Build Command:** `npm run build` (or `cd client && npm run build` if root is repo root).
   - **Output Directory:** `dist` (or `client/dist` if building from repo root).
   - **Install Command:** `npm install` (or `cd client && npm install` if root is repo root).
5. **Environment variables** (before first deploy):

   | Name            | Value |
   |-----------------|--------|
   | `VITE_API_URL` | Your **API URL** from Part 2 + `/api`, e.g. `https://ems-api-production-xxxx.up.railway.app/api` or `https://ems-server-xxxx.onrender.com/api` |

   No trailing slash: `.../api` not `.../api/`.

6. Deploy. Vercel will give a URL like `https://ems-xxx.vercel.app`. This is your **frontend URL**.

---

## Part 4: Connect backend and frontend

1. **Backend:** In Railway (or Render), set **CLIENT_URL** to your **frontend URL** (e.g. `https://ems-xxx.vercel.app`). Redeploy the backend so CORS allows that origin.
2. **Frontend:** You already set `VITE_API_URL` to the API URL; if you change the API URL later, update this and redeploy the frontend.

---

## Part 5: First admin user

The app needs at least one **approved admin** to log in. You can do either:

**A) Seed script (if you have one)**  
Run it once against your **production** MongoDB (e.g. locally with `MONGODB_URI` set to your Atlas URI), or add a one-off script that creates an admin user and run it in the same way.

**B) Register + approve**  
1. Open your **frontend URL** (e.g. `https://ems-xxx.vercel.app`).
2. Click **Register** and create an account with the email you want as admin.
3. In MongoDB Atlas: **Database** → **Browse Collections** → select your `ems` db → **users** collection. Find your user document and set `role: "admin"` and `approved: true`. Save.
4. Log in on the frontend with that email and password.

After that, you can use **My Account** → **User management** (as admin) to add more users or approve others.

---

## Summary

| Step | Where | What |
|------|--------|------|
| 1 | MongoDB Atlas | Create cluster, user, allow 0.0.0.0/0, get `MONGODB_URI` |
| 2 | Railway or Render | Deploy `server`, set `MONGODB_URI`, `JWT_SECRET`, `CLIENT_URL` → get **API URL** |
| 3 | Vercel | Deploy `client` with `VITE_API_URL` = API URL + `/api` → get **frontend URL** |
| 4 | Backend | Set `CLIENT_URL` = frontend URL, redeploy |
| 5 | Atlas or app | Create first admin (seed or register + edit in Atlas) |

Use the **frontend URL** on any device, any Wi‑Fi or mobile data, to open and use the app.
