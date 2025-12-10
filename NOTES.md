Project: LearnLynk Tech Test — Submission Notes
Summary

This repository contains a minimal multi-tenant CRM prototype implementing the LearnLynk technical test. Implementations included:

Database schema (tenants, leads, applications, tasks) with indexes, constraints, and triggers.

Row-Level Security policies for leads and supporting user_teams table.

Edge Function (server-side) to create tasks (backend/edge-functions/create-task/index.ts).

Frontend Next.js page /dashboard/today showing tasks due today and allowing marking tasks complete.

Assumptions

JWT contains a role claim accessible as auth.jwt() ->> 'role' with values like admin or counselor.

owner_id is set to the authenticated user's auth.uid() when creating leads/tasks from authenticated clients (or set server-side by edge functions using service_role key).

This submission uses Supabase (Postgres) and Supabase Edge Functions (Deno). The service role key is required for server-side operations that bypass RLS.

How to run (Local Frontend)

Ensure Node.js (>=16) and npm are installed.

Copy the repo and open terminal in the frontend folder.

Create .env.local inside frontend with the following values (do not commit):

NEXT_PUBLIC_SUPABASE_URL=https://<your-project-ref>.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=sb_publishable_XXXXXXXXXXXXX

Install and run:

cd frontend
npm install
npm run dev

Open http://localhost:3000/dashboard/today

How to apply the database schema (Supabase)

Open your Supabase project → SQL Editor → New Query.

Open backend/schema.sql in your local copy, copy all SQL and paste into Supabase SQL Editor, then Run.

Confirm tables tenants, leads, applications, tasks exist via Database → Tables.

How to apply RLS policies

Open Supabase SQL Editor → New Query.

Copy backend/rls_policies.sql content and Run. This will enable RLS on leads and create SELECT/INSERT/UPDATE/DELETE policies.

Deploy Edge Function (create-task)

Locally, install the Supabase CLI (see supabase.com docs) or use the Supabase dashboard.

If using CLI, from repo root run:

# login if needed
supabase login
# deploy function (path relative to repo)
supabase functions deploy create-task --project-ref <project-ref> --env .env.functions

Alternatively, in Supabase Console → Edge Functions → New Function → paste backend/edge-functions/create-task/index.ts and deploy.

In Supabase Console for that function, set environment variables:

SUPABASE_URL = https://<project-ref>.supabase.co

SUPABASE_SERVICE_ROLE_KEY = (service_role key from Settings → API Keys)

Test with cURL or Postman (see scripts for example cURL). The function returns the created task_id on success.

How to test Mark Complete (frontend)

Open /dashboard/today and click Mark Complete on a task.

In Supabase SQL Editor, run:

SELECT id, title, status, due_at FROM public.tasks ORDER BY created_at DESC LIMIT 5;

Confirm the task's status changed to completed.

Security notes

Edge function uses the service_role key to bypass RLS for server-side inserts. Store the key securely and do not commit it.

RLS policies check auth.jwt() ->> 'role' = 'admin' and owner_id = auth.uid(); adjust to your auth scheme if different.

Stripe integration (8–12 lines - required by assignment)

To accept payments for application fees we would integrate Stripe Payments using server-side endpoints to create PaymentIntents. The frontend would request a PaymentIntent from an Edge Function which uses the Stripe secret key (stored as an environment variable). The function creates a PaymentIntent with amount and currency, returns the client_secret to the frontend, and the frontend completes the payment using Stripe.js. After successful payment, the Edge Function verifies the payment (webhook recommended) and updates the application payment_status in the database. This avoids exposing secret keys to the browser and keeps payment verification server-side.

Sample cURL (Edge Function)

See scripts/sample-curl.sh in repository for an example request to the deployed Edge Function.