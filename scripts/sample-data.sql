-- Create demo tenant INSERT INTO public.tenants (id, name) VALUES ('4643f105-92ca-413a-bd6e-c371e088375d', 'demo-tenant') ON CONFLICT DO NOTHING;

-- Create lead INSERT INTO public.leads (tenant_id, owner_id, email, phone, full_name, stage, created_at, updated_at) VALUES ('4643f105-92ca-413a-bd6e-c371e088375d', gen_random_uuid(), 'testlead@example.com', '9876543210', 'Test Lead', 'new', now(), now()) RETURNING id;

-- Example application (replace lead_id) INSERT INTO public.applications (tenant_id, lead_id, application_number, stage, status) VALUES ('4643f105-92ca-413a-bd6e-c371e088375d', '382869f2-386f-4793-a127-7657e46f22d6', 'APP-1001', 'inquiry', 'open') RETURNING id;

-- Create a task due today INSERT INTO public.tasks (tenant_id, application_id, title, type, status, due_at) VALUES ('4643f105-92ca-413a-bd6e-c371e088375d', '2e3da04c-903a-4f4e-9723-4a072fcac4ae', 'Manual test - due today', 'call', 'open', now() + interval '2 hour') RETURNING id;