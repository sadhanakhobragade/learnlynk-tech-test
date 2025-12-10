-- LearnLynk Tech Test - Task 1: Completed Schema
-- Creates tenants + leads + applications + tasks with constraints, indexes, and triggers.

-- enable pgcrypto for gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- tenants table (for tenant_id references)
CREATE TABLE IF NOT EXISTS public.tenants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Leads table
CREATE TABLE IF NOT EXISTS public.leads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  owner_id uuid NOT NULL,
  email text,
  phone text,
  full_name text,
  stage text NOT NULL DEFAULT 'new',
  source text,
  data jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Indexes for leads
CREATE INDEX IF NOT EXISTS idx_leads_tenant_owner_stage_created ON public.leads (tenant_id, owner_id, stage, created_at);
CREATE INDEX IF NOT EXISTS idx_leads_owner ON public.leads (owner_id);

-- Applications table
CREATE TABLE IF NOT EXISTS public.applications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  lead_id uuid NOT NULL REFERENCES public.leads(id) ON DELETE CASCADE,
  program_id uuid,
  intake_id uuid,
  application_number text,
  stage text NOT NULL DEFAULT 'inquiry',
  status text NOT NULL DEFAULT 'open',
  payment_request jsonb DEFAULT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Indexes for applications
CREATE INDEX IF NOT EXISTS idx_applications_tenant_lead_stage ON public.applications (tenant_id, lead_id, stage);
CREATE INDEX IF NOT EXISTS idx_applications_lead ON public.applications (lead_id);

-- Tasks table
CREATE TABLE IF NOT EXISTS public.tasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  application_id uuid NOT NULL REFERENCES public.applications(id) ON DELETE CASCADE,
  title text,
  type text NOT NULL,
  status text NOT NULL DEFAULT 'open',
  due_at timestamptz NOT NULL,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT tasks_type_check CHECK (type IN ('call','email','review')),
  CONSTRAINT tasks_due_after_created CHECK (due_at >= created_at)
);

-- Indexes for tasks (common queries: by tenant, due date, status)
CREATE INDEX IF NOT EXISTS idx_tasks_tenant_due_status ON public.tasks (tenant_id, due_at, status);
CREATE INDEX IF NOT EXISTS idx_tasks_due_at ON public.tasks (due_at);

-- Trigger function to auto-update updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_leads_updated_at BEFORE UPDATE ON public.leads FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_applications_updated_at BEFORE UPDATE ON public.applications FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_tasks_updated_at BEFORE UPDATE ON public.tasks FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


