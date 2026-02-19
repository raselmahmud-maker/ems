# Employee Management System (EMS)

Full-stack, cloud-ready Employee Management System with JWT auth, role-based access, real-time updates, and PDF/Excel export.

## Tech Stack

- **Frontend:** React 18, Vite, React Router, Socket.IO client
- **Backend:** Node.js, Express, MongoDB (Mongoose), JWT, Socket.IO
- **Deploy:** Vercel (frontend), Render/Railway (backend), MongoDB Atlas

## Features

- **Auth:** Login with company email/password; admin approval for new users; Admin and User roles
- **Admin:** Add/Edit/Delete employees, search by Employee ID or Iqama, view full data, Iqama remaining days, PDF per employee, bulk export (CSV/Excel), bulk import (CSV/Excel), user approval/reject, system version
- **User:** Search by Employee ID or Iqama, view full employee data, download individual PDF (no edit/delete)
- **Real-time:** Socket.IO so when admin updates data, all clients see updates instantly

## Quick Start

### Prerequisites

- Node.js 18+
- MongoDB (local or MongoDB Atlas)

### 1. Install dependencies

```bash
cd ems
npm run install:all
```

### 2. Backend setup

```bash
cd server
cp .env.example .env
# Edit .env: set MONGODB_URI, JWT_SECRET (and optionally CLIENT_URL for CORS)
```

Create first admin user:

```bash
node src/scripts/seedAdmin.js
# Or set ADMIN_EMAIL and ADMIN_PASSWORD in .env
```

### 3. Run development

From project root `ems/`:

```bash
npm run dev
```

- Frontend: http://localhost:5173  
- Backend API: http://localhost:5000  

Login with the admin email/password you set in the seed.

## Project Structure

```
ems/
├── client/                 # React (Vite)
│   ├── src/
│   │   ├── components/      # Layout, SearchBar, EmployeeFormView, EmployeeModal
│   │   ├── context/        # AuthContext
│   │   ├── hooks/          # useSocket
│   │   ├── pages/          # Login, Register, Dashboard, Admin*, EmployeeView
│   │   ├── services/       # api (axios)
│   │   ├── utils/          # pdfDownload, exportDownload
│   │   └── constants/
│   └── vercel.json         # Vercel deployment
├── server/                 # Express API
│   ├── src/
│   │   ├── config/         # db
│   │   ├── controllers/    # auth, user, employee, pdf, exportImport, version
│   │   ├── middleware/    # auth, validate
│   │   ├── models/        # User, Employee, SystemVersion
│   │   ├── routes/
│   │   └── scripts/       # seedAdmin.js
│   ├── .env.example
│   └── render.yaml         # Render.com optional
└── README.md
```

## Deployment

### Frontend (Vercel)

1. Push client to Git; connect repo to Vercel.
2. Set **Build Command:** `npm run build`, **Output:** `dist`, **Root:** `client`.
3. Add env: `VITE_API_URL=https://your-backend-url.com/api` (no trailing slash).
4. Deploy.

### Backend (Render or Railway)

1. Create a new Web Service; connect the repo; root: `server`.
2. **Build:** `npm install`  
3. **Start:** `npm start`  
4. Environment variables:
   - `MONGODB_URI` — MongoDB Atlas connection string
   - `JWT_SECRET` — strong random secret
   - `CLIENT_URL` — frontend URL (e.g. https://your-app.vercel.app) for CORS and Socket.IO
   - `PORT` — set by Render/Railway

### Database (MongoDB Atlas)

1. Create a cluster; get connection string.
2. Use it as `MONGODB_URI` in the backend.
3. Run seed once (e.g. locally with `MONGODB_URI` pointing to Atlas) to create the first admin.

## API Overview

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | /api/auth/register | - | Register (pending approval) |
| POST | /api/auth/login | - | Login |
| GET | /api/auth/me | ✓ | Current user |
| GET | /api/employees | ✓ | List employees (paginated, optional search) |
| GET | /api/employees/search?q= | ✓ | Instant search by ID / Iqama |
| GET | /api/employees/:id | ✓ | Get one employee |
| GET | /api/employees/:id/pdf | ✓ | Download PDF |
| POST | /api/employees | Admin | Create employee |
| PUT | /api/employees/:id | Admin | Update employee |
| DELETE | /api/employees/:id | Admin | Delete employee |
| GET | /api/employees/export/all?format=xlsx\|csv | Admin | Bulk export |
| POST | /api/employees/import | Admin | Bulk import (file) |
| GET | /api/users | Admin | List users |
| PATCH | /api/users/:id/approve | Admin | Approve user |
| PATCH | /api/users/:id/reject | Admin | Reject/revoke user |
| GET | /api/version | - | Current version |
| PUT | /api/version | Admin | Update version |

## Security

- Passwords hashed with bcrypt; JWT in cookie + Authorization header.
- Role-based middleware; admin-only routes protected.
- Helmet and CORS configured; validate and sanitize inputs (express-validator).

## License

MIT.
