-- profiles.matching_paused: current state only (no timestamp on profiles).
-- matching_pause_events: append-only pause/resume history (abstracted).
-- matches + match_history_entries: mutual matches and per-member history (abstracted).

-- ---------------------------------------------------------------------------
-- profiles.current pause flag
-- ---------------------------------------------------------------------------

alter table public.profiles
  add column matching_paused boolean not null default false;

comment on column public.profiles.matching_paused is
  'When true, new match notifications for this member are deferred per product rules; interest list unchanged. Pause/resume history lives in matching_pause_events.';

-- ---------------------------------------------------------------------------
-- Pause / resume history (no matching_paused_changed_at on profiles)
-- ---------------------------------------------------------------------------

create table public.matching_pause_events (
  id uuid primary key default gen_random_uuid (),
  profile_id uuid not null references public.profiles (id) on delete cascade,
  paused boolean not null,
  created_at timestamptz not null default now ()
);

comment on table public.matching_pause_events is
  'Append-only history when a member pauses or resumes matching (paused=true pause, paused=false resume).';

create index matching_pause_events_profile_id_created_at_idx
  on public.matching_pause_events (profile_id, created_at desc);

alter table public.matching_pause_events enable row level security;

create policy "matching_pause_events_select_own"
  on public.matching_pause_events
  for select
  to authenticated
  using (profile_id = (select auth.uid ()));

-- Rows are written by trigger only (see below), not by clients directly.

-- ---------------------------------------------------------------------------
-- Canonical mutual match (pair identity + when mutual interest was recorded)
-- ---------------------------------------------------------------------------

create table public.matches (
  id uuid primary key default gen_random_uuid (),
  user_a_id uuid not null references public.profiles (id) on delete cascade,
  user_b_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now (),
  constraint matches_ordered_pair_ck check (user_a_id < user_b_id),
  constraint matches_distinct_users_ck check (user_a_id <> user_b_id)
);

comment on table public.matches is
  'One row per mutual match (canonical ordered pair). Timestamps reflect when the match was recorded.';

create unique index matches_user_pair_uidx
  on public.matches (user_a_id, user_b_id);

create index matches_created_at_idx
  on public.matches (created_at desc);

alter table public.matches enable row level security;

create policy "matches_select_participant"
  on public.matches
  for select
  to authenticated
  using (
    user_a_id = (select auth.uid ())
    or user_b_id = (select auth.uid ())
  );

-- Inserts/updates: application / Edge Functions with service role (no authenticated insert policy).

-- ---------------------------------------------------------------------------
-- Per-member match history (counterparty snapshot + optional notified_at)
-- ---------------------------------------------------------------------------

create table public.match_history_entries (
  id uuid primary key default gen_random_uuid (),
  match_id uuid not null references public.matches (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  counterpart_display_name text not null,
  counterpart_email text not null,
  notified_at timestamptz,
  constraint match_history_entries_one_row_per_user_per_match unique (match_id, user_id)
);

comment on table public.match_history_entries is
  'Abstracted match timeline per member: who they matched with (snapshot), optional deferred-notification time. Match occurrence time: join matches.created_at or duplicate if denormalization needed later.';

create index match_history_entries_user_id_created_via_match_idx
  on public.match_history_entries (user_id);

alter table public.match_history_entries enable row level security;

create policy "match_history_entries_select_own"
  on public.match_history_entries
  for select
  to authenticated
  using (user_id = (select auth.uid ()));

-- ---------------------------------------------------------------------------
-- Keep pause history in sync when profiles.matching_paused changes
-- ---------------------------------------------------------------------------

create or replace function public.record_matching_pause_event ()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'UPDATE'
     and (old.matching_paused is distinct from new.matching_paused) then
    insert into public.matching_pause_events (profile_id, paused)
    values (new.id, new.matching_paused);
  end if;
  return new;
end;
$$;

comment on function public.record_matching_pause_event () is
  'Appends matching_pause_events when profiles.matching_paused toggles (DEFINER so RLS does not block the insert).';

create trigger profiles_matching_pause_events_trg
  after update of matching_paused on public.profiles
  for each row
  execute function public.record_matching_pause_event ();
