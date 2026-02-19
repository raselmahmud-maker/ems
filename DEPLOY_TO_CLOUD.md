# Deploy EMS to the Cloud (Use Anytime, Any Device)

Follow these steps in order. After deployment, you’ll open one URL in your browser—no need to run the backend or frontend on your PC.

---

## Step 1: MongoDB Atlas (Database)

1. Go to **https://www.mongodb.com/cloud/atlas** and sign up / log in.
2. Click **Build a Database** → choose **M0 FREE** → pick a region near you → Create.
3. Create a database user:
   - **Database Access** → Add New Database User
   - Username and password (e.g. `emsuser` / `YourSecurePassword123`) → Add User
4. Allow access:
   - **Network Access** → Add IP Address → **Allow Access from Anywhere** (0.0.0.0/0) → Confirm
5. Get the connection string:
   - **Database** → **Connect** → **Connect your application**
   - Copy the URI. It looks like:
     `mongodb+srv://emsuser:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority`
   - Replace `<password>` with your database user password.
   - Add a database name before the `?`: use `ems` so the URI ends with `/ems?retryWrites=...`
   - **Save this URI**; you’ll use it as `MONGODB_URI` in Step 2.

---

## Step 2: Backend on Render

1. Go to **https://render.com** and sign up / log in.
2. **New +** → **Web Service**.
3. Connect your repository:
   - If your code is on **GitHub**: connect GitHub, select the repo that contains the **ems** project, then set **Root Directory** to **`server`** (so Render uses the backend folder).
   - If you don’t use Git: see “Deploy without Git” below.
4. Configure the service:
   - **Name:** `ems-api` (or any name).
   - **Region:** choose one close to you.
   - **Runtime:** Node.
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
   - **Instance Type:** Free.
5. **Environment** (Environment Variables):
   - `NODE_ENV` = `production`
   - `MONGODB_URI` = your full Atlas URI from Step 1 (e.g. `mongodb+srv://emsuser:YourPassword@cluster0.xxxxx.mongodb.net/ems?retryWrites=true&w=majority`)
   - `JWT_SECRET` = a long random string (e.g. generate one at https://randomkeygen.com/)
   - `CLIENT_URL` = leave empty for now; you’ll set it in Step 5 after Vercel gives you the frontend URL.
6. Click **Create Web Service**. Wait until the deploy succeeds.
7. Copy your backend URL, e.g. **`https://ems-api.onrender.com`** (yours will be different). You’ll use this for the frontend and for `CLIENT_URL`.

---

## Step 3: Create Admin User (rasel@maam.sa)

Your database is in the cloud, so create the user once using the Atlas connection string:

1. On your PC, open **server\.env** (create it from **server\.env.example** if needed).
2. Set only:
   ```env
   MONGODB_URI=your_atlas_connection_string_from_step_1
   ```
3. In Command Prompt:
   ```bat
   cd C:\Users\farha\ems\server
   node src\scripts\createUser.js
   ```
4. You should see: **User created: rasel@maam.sa**. You can then use **rasel@maam.sa** / **Farhan784** to log in after the frontend is deployed.

---

## Step 4: Frontend on Vercel

1. Go to **https://vercel.com** and sign up / log in.
2. **Add New** → **Project**.
3. Import your repository (the one that contains the **ems** project).
4. Configure the project:
   - **Root Directory:** click **Edit** and set to **`client`**.
   - **Framework Preset:** Vite (should be auto-detected).
   - **Build Command:** `npm run build`
   - **Output Directory:** `dist`
5. **Environment Variables:**
   - **Name:** `VITE_API_URL`  
   - **Value:** your backend URL from Step 2 **including `/api`**, e.g. `https://ems-api.onrender.com/api`  
   (No trailing slash.)
6. Click **Deploy**. Wait until the build finishes.
7. Copy your frontend URL, e.g. **`https://ems-client.vercel.app`**.

---

## Step 5: Link Frontend to Backend (CORS)

1. Go back to **Render** → your **ems-api** service → **Environment**.
2. Add or update:
   - `CLIENT_URL` = your Vercel frontend URL from Step 4, e.g. `https://ems-client.vercel.app`  
   (No trailing slash.)
3. Save. Render will redeploy once; wait for it to finish.

---

## Step 6: Use the App Anytime

- Open in your browser: **your Vercel URL** (e.g. `https://ems-client.vercel.app`).
- Log in with: **rasel@maam.sa** / **Farhan784**.

You can use this URL on any device (PC, phone, tablet) without opening or running the backend on your computer.

---

## Deploy Without Git (Render + Vercel)

If your code is only on your PC:

1. **Backend (Render):**
   - Create a **new GitHub repo**, push only the **server** folder (or the whole **ems** repo with root dir `server`).
   - Connect that repo to Render as in Step 2.
2. **Frontend (Vercel):**
   - Push the **client** folder to the same or another repo (or push the whole **ems** and set root to `client`).
   - Connect that repo to Vercel as in Step 4.

---

## Quick Reference

| What        | Where                          |
|------------|---------------------------------|
| Database   | MongoDB Atlas (Step 1)          |
| Backend    | Render – root directory: `server` |
| Frontend   | Vercel – root directory: `client` |
| Login      | rasel@maam.sa / Farhan784      |

---

## Troubleshooting

- **Login fails / “Cannot reach server”:**  
  Check that `VITE_API_URL` on Vercel is exactly your Render URL + `/api` (e.g. `https://ems-api.onrender.com/api`).

- **CORS or “blocked” errors:**  
  Ensure `CLIENT_URL` on Render is exactly your Vercel URL (e.g. `https://ems-client.vercel.app`), no trailing slash.

- **Render free tier sleeps:**  
  The first request after idle can take 30–60 seconds. After that it’s fast until it sleeps again.
