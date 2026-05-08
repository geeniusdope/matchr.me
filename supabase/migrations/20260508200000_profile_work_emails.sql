-- Matchable emails linked to a member account (R1.5, R2.4): one row per address.
-- A user may record one or more rows; only verified rows participate in match resolution.

create table public.profile_work_emails (
  id uuid primary key default gen_random_uuid (),
  user_id uuid not null references public.profiles (id) on delete cascade,
  email text not null,
  verified boolean not null default false,
  verified_at timestamptz,
  created_at timestamptz not null default now (),
  updated_at timestamptz not null default now (),
  constraint profile_work_emails_email_nonempty_ck check (length(trim(email)) > 0),
  constraint profile_work_emails_single_at_ck check (
    email !~~ '%@%@%'
    and position('@' in email) > 1
    and length(email) - length(replace(email, '@', '')) = 1
  ),
  constraint profile_work_emails_verified_consistency_ck check (
    (verified = false and verified_at is null)
    or (verified = true and verified_at is not null)
  )
);

comment on table public.profile_work_emails is
  'Member matchable email addresses (usually work): one row each; multiple rows per user allowed (R1.5). Verified rows resolve mutual interest (R2.4).';

comment on column public.profile_work_emails.email is
  'Matchable address for this profile; normalize (trim/lower) in app before write. Others may list this email as interest; resolves only when verified.';

comment on column public.profile_work_emails.verified is
  'True after successful work-email verification (R1.5, §4.1.1). Matching uses only verified rows.';

comment on column public.profile_work_emails.verified_at is
  'Timestamp when verification succeeded (R1.2 audit trail). Null when verified is false.';

create unique index profile_work_emails_user_lower_email_uidx
  on public.profile_work_emails (user_id, lower(trim(email)));

-- No two accounts may hold the same verified work email (impersonation / cross-account abuse).
create unique index profile_work_emails_verified_global_email_uidx
  on public.profile_work_emails (lower(trim(email)))
  where verified = true;

create index profile_work_emails_user_id_idx
  on public.profile_work_emails (user_id);

create index profile_work_emails_lookup_lower_email_idx
  on public.profile_work_emails (lower(trim(email)))
  where verified = true;

alter table public.profile_work_emails enable row level security;

create policy "profile_work_emails_select_own"
  on public.profile_work_emails
  for select
  to authenticated
  using (user_id = (select auth.uid ()));

create policy "profile_work_emails_insert_own"
  on public.profile_work_emails
  for insert
  to authenticated
  with check (user_id = (select auth.uid ()));

create policy "profile_work_emails_update_own"
  on public.profile_work_emails
  for update
  to authenticated
  using (user_id = (select auth.uid ()))
  with check (user_id = (select auth.uid ()));

create policy "profile_work_emails_delete_own"
  on public.profile_work_emails
  for delete
  to authenticated
  using (user_id = (select auth.uid ()));
