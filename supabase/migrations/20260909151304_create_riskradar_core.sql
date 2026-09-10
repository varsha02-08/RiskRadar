/*
# Create RiskRadar community reporting core

1. New Tables
- `riskradar_reports`: community observations with condition, severity, location, description, verification status, and ownership.
2. Security
- Row-level security enabled.
- Authenticated users can create and read their own reports.
- Authorities can later be granted verified-review access through a dedicated server-side role policy.
3. Notes
- Hazard and relocation demonstration data remains source-labelled in the client until authorized GIS feeds are connected.
*/

CREATE TABLE IF NOT EXISTS public.riskradar_reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
  report_code text NOT NULL UNIQUE,
  condition text NOT NULL,
  severity text NOT NULL,
  description text NOT NULL,
  latitude double precision,
  longitude double precision,
  road_access text NOT NULL DEFAULT 'unknown',
  people_affected text NOT NULL DEFAULT 'unknown',
  immediate_assistance text NOT NULL DEFAULT 'unknown',
  verification_status text NOT NULL DEFAULT 'pending',
  created_at timestamptz NOT NULL DEFAULT now(),
  verified_at timestamptz
);

ALTER TABLE public.riskradar_reports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users_read_own_riskradar_reports" ON public.riskradar_reports;
CREATE POLICY "users_read_own_riskradar_reports" ON public.riskradar_reports FOR SELECT TO authenticated USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "users_insert_own_riskradar_reports" ON public.riskradar_reports;
CREATE POLICY "users_insert_own_riskradar_reports" ON public.riskradar_reports FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "users_update_own_riskradar_reports" ON public.riskradar_reports;
CREATE POLICY "users_update_own_riskradar_reports" ON public.riskradar_reports FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "users_delete_own_riskradar_reports" ON public.riskradar_reports;
CREATE POLICY "users_delete_own_riskradar_reports" ON public.riskradar_reports FOR DELETE TO authenticated USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS riskradar_reports_user_id_idx ON public.riskradar_reports(user_id);
CREATE INDEX IF NOT EXISTS riskradar_reports_status_idx ON public.riskradar_reports(verification_status);