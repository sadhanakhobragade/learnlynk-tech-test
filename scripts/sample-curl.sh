curl -X POST "https://.functions.supabase.co/create-task"
-H "Content-Type: application/json"
-d '{ "application_id":"2e3da04c-903a-4f4e-9723-4a072fcac4ae", "task_type":"call", "due_at":"2025-12-10T10:00:00.000Z", "title":"Follow up (via edge function)", "owner_id":"" }'