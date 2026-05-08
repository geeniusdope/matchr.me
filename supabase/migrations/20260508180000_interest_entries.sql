-- Private interest list (R2.1–R2.5): emails of people the member is interested in (typically work emails).

create table public.interest_entries (
  id uuid primary key default gen_random_uuid (),
  user_id uuid not null references public.profiles (id) on delete cascade,
  interest_email text not null,
  subject_display_name text,
  created_at timestamptz not null default now (),
  updated_at timestamptz not null default now (),
  constraint interest_entries_email_nonempty_ck check (
    length(trim(interest_email)) > 0
  ),
  constraint interest_email_single_at_ck check (
    interest_email !~~ '%@%@%'
    and position('@' in interest_email) > 1
    and length(interest_email) - length(replace(interest_email, '@', '')) = 1
  )
);

comment on table public.interest_entries is
  'Member-owned rows: one person-of-interest per email on their private list (usually work email). Optional subject_display_name for UX (R2.1).';

comment on column public.interest_entries.interest_email is
  'Target address used for mutual-interest matching (normalized by app before insert/update).';

comment on column public.interest_entries.subject_display_name is
  'Optional label for the person associated with interest_email (R2.1).';

create unique index interest_entries_user_lower_email_uidx
  on public.interest_entries (user_id, lower(trim(interest_email)));

create index interest_entries_user_id_idx
  on public.interest_entries (user_id);

alter table public.interest_entries enable row level security;

create policy "interest_entries_select_own"
  on public.interest_entries
  for select
  to authenticated
  using (user_id = (select auth.uid ()));

create policy "interest_entries_insert_own"
  on public.interest_entries
  for insert
  to authenticated
  with check (user_id = (select auth.uid ()));

create policy "interest_entries_update_own"
  on public.interest_entries
  for update
  to authenticated
  using (user_id = (select auth.uid ()))
  with check (user_id = (select auth.uid ()));

create policy "interest_entries_delete_own"
  on public.interest_entries
  for delete
  to authenticated
  using (user_id = (select auth.uid ()));
