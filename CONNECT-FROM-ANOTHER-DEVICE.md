# Connect from another device (same Wi‑Fi)

Follow these steps so your phone/laptop can open the app using your PC’s IP.

---

## Step 1: Get your PC’s IP address

On your **PC**, open **PowerShell** or **Command Prompt** and run:

```powershell
ipconfig | findstr /i "IPv4"
```

Note the **IPv4 Address** (e.g. `192.168.1.100`). Use this wherever you see `YOUR_PC_IP` below.

---

## Step 2: Allow ports in Windows Firewall

Windows often blocks incoming connections. Allow the app and API:

1. Press **Win + R**, type **wf.msc**, press Enter (opens Windows Defender Firewall).
2. Click **“Inbound Rules”** in the left panel.
3. Click **“New Rule…”** on the right.
4. Choose **“Port”** → Next.
5. Choose **TCP**, under “Specific local ports” enter: **5000, 5173** → Next.
6. Choose **“Allow the connection”** → Next.
7. Leave all profiles (Domain, Private, Public) checked → Next.
8. Name: **EMS App** → Finish.

Or run this in **PowerShell as Administrator** (one line):

```powershell
New-NetFirewallRule -DisplayName "EMS App" -Direction Inbound -Protocol TCP -LocalPort 5000,5173 -Action Allow
```

---

## Step 3: Configure the server

Edit **server/.env** (create from `server/.env.example` if needed).

Set **CLIENT_URL** so the API accepts requests from your other device. You can allow both localhost and your PC IP:

```env
CLIENT_URL=http://localhost:5173,http://YOUR_PC_IP:5173
```

Example (if your IP is 192.168.1.100):

```env
CLIENT_URL=http://localhost:5173,http://192.168.1.100:5173
```

Save the file and **restart the server** (stop and run `npm run dev` again in the `server` folder).

---

## Step 4: Start the app on your PC

1. **Terminal 1 – API server**
   ```bash
   cd server
   npm run dev
   ```
   Wait until you see: `Server running on http://0.0.0.0:5000`

2. **Terminal 2 – Frontend**
   ```bash
   cd client
   npm run dev
   ```
   You should see something like: `Local: http://localhost:5173/` and **Network: http://192.168.x.x:5173/**

---

## Step 5: Open the app on the other device

- Connect the other device to the **same Wi‑Fi** as the PC.
- In the browser, go to: **http://YOUR_PC_IP:5173**  
  Example: **http://192.168.1.100:5173**
- You should see the login page. Log in with your email and password.

---

## If it still doesn’t connect

| Check | What to do |
|-------|------------|
| Same Wi‑Fi? | Phone/other device must be on the same network as the PC. |
| Correct IP? | Run `ipconfig` again; IP can change after reconnecting. |
| Firewall | Ensure the rule for ports **5000** and **5173** is enabled (Step 2). |
| Server .env | `CLIENT_URL` must include `http://YOUR_PC_IP:5173` and server restarted. |
| Both running? | On the PC, both `server` (port 5000) and `client` (port 5173) must be running. |
| Try API from phone | On the other device’s browser open: `http://YOUR_PC_IP:5000/api/health` — you should see `{"status":"ok",...}`. If not, the server or firewall is still blocking. |

---

## Quick test from the other device

Open in the browser:

- **App:** `http://YOUR_PC_IP:5173`
- **API health:** `http://YOUR_PC_IP:5000/api/health`

If the health URL works but the app doesn’t load, the frontend (Vite) isn’t reachable — check firewall for 5173 and that you started the client with `npm run dev`. If the health URL doesn’t work, the server or firewall (port 5000) is the issue.
