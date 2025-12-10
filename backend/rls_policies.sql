-- backend/rls_policies.sql
-- Row Level Security policies for public.leads (final)

-- team_id exists
ALTER TABLE public.leads
  ADD COLUMN IF NOT EXISTS team_id uuid;

-- enable row level security
ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;

-- drop existing policies if present
DROP POLICY IF EXISTS leads_select_policy ON public.leads;
DROP POLICY IF EXISTS leads_insert_policy ON public.leads;
DROP POLICY IF EXISTS leads_update_policy ON public.leads;
DROP POLICY IF EXISTS leads_delete_policy ON public.leads;

-- SELECT policy: admins OR owner OR members of owner's team
CREATE POLICY leads_select_policy
  ON public.leads
  FOR SELECT
  USING (
    (
      (auth.jwt() ->> 'role') = 'admin'
    )
    OR ( owner_id IS NOT NULL AND owner_id = auth.uid() )
    OR EXISTS (
      SELECT 1
      FROM public.user_teams ut
      WHERE ut.user_id = auth.uid()
        AND ut.team_id = public.leads.team_id
    )
  );

-- INSERT policy: admins or any authenticated user can insert (tenant check can be added later)
CREATE POLICY leads_insert_policy
  ON public.leads
  FOR INSERT
  WITH CHECK (
    (
      (auth.jwt() ->> 'role') = 'admin'
    )
    OR ( auth.uid() IS NOT NULL )
  );

-- UPDATE policy: admins or owner can update their leads
CREATE POLICY leads_update_policy
  ON public.leads
  FOR UPDATE
  USING (
    (auth.jwt() ->> 'role') = 'admin'
    OR owner_id = auth.uid()
  )
  WITH CHECK (
    (auth.jwt() ->> 'role') = 'admin'
    OR owner_id = auth.uid()
  );

-- DELETE policy: only admins can delete
CREATE POLICY leads_delete_policy
  ON public.leads
  FOR DELETE
  USING (
    (auth.jwt() ->> 'role') = 'admin'
  );
