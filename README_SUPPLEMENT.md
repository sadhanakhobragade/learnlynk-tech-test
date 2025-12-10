# README_SUPPLEMENT.md  
This document provides implementation notes, run instructions, assumptions, and reviewer guidance for the LearnLynk technical test submission.

---

## 1. Overview
This submission implements a minimal CRM-style backend and frontend as described in the technical assignment. The goals were:

- Clean, readable schema and policies  
- Simple and secure task creation API (Edge Function)  
- Clear filtering of tasks due today  
- Demonstration of understanding RLS, Supabase, and multi-tenant patterns  

---

## 2. Backend Overview (Supabase Postgres)

### Implemented Tables
- `leads`: basic lead info + tenant & ownership  
- `applications`: linked to lead  
- `tasks`: linked to application  

All tables include:
- `uuid` primary keys  
- `created_at`, `updated_at`  
- FKs with cascading  
- Performance indexes  

See `backend/schema.sql`.

---

## 3. Row Level Security (RLS)

RLS enabled on `leads`. Policies allow:
- Admins → all tenant data  
- Counselors → only owned records  
- Team members → based on `user_teams` table  

See `backend/rls_policies.sql`.

---

## 4. Edge Function: create-task

- Validates payload  
- Creates task using service role key  
- Returns created task details  

See `backend/edge-functions/create-task/index.ts`.

---

## 5. Frontend (Next.js)

The page `/dashboard/today`:

- Fetches tasks due today  
- Sorts by due time  
- Allows “Mark Complete”  
- Uses Supabase anon key + RLS  

---

## 6. How to Run Locally

### Setup frontend
cd frontend
npm install
npm run dev

pgsql
Copy code

Create `frontend/.env.local`:

NEXT_PUBLIC_SUPABASE_URL=https://<project>.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=sb_publishable_xxxxx

yaml
Copy code

### Apply schema
Paste contents of `backend/schema.sql` & `backend/rls_policies.sql` into Supabase SQL Editor → Run.

---

## 7. Testing

### Insert sample data
See `scripts/sample-data.sql`.

### Test edge function
See `scripts/sample-curl.sh`.

---

## 8. Stripe Integration Summary

Stripe is integrated by:
1. Client requests PaymentIntent from Edge Function  
2. Edge Function creates PaymentIntent with secret key  
3. Edge returns `client_secret`  
4. Frontend completes payment using Stripe.js  
5. Backend webhook verifies payment and updates application  

This keeps secret keys secure and off the client.

---

## 9. Assumptions

- JWT contains `role` and `user_id`.  
- Multi-tenant access is simplified for MVP.  
- Only authenticated users create tasks or leads.

---

## 10. Reviewer Notes

- Submission respects original folder structure.  
- Code is minimal, readable, and production-aligned.  
- RLS demonstrates real access control understanding.  
- Dashboard + mark-complete flow fully working.
