-- Align remote schema when 20260506120000 ran before seen_at / update policy / trigger were added.

alter table public.match_history_entries
  add column if not exists seen_at timestamptz;

comment on table public.match_history_entries is
  'Abstracted match timeline per member: counterparty snapshot, notification delivery time, read/seen state. Match time: join matches.created_at.';

comment on column public.match_history_entries.seen_at is
  'First time this member opened/acknowledged the match in-app; NULL = unseen. Use with notified_at for “new match” badges (e.g. notified_at IS NOT NULL AND seen_at IS NULL).';

create index if not exists match_history_entries_user_new_match_idx
  on public.match_history_entries (user_id)
  where notified_at is not null and seen_at is null;

drop policy if exists "match_history_entries_update_own"
  on public.match_history_entries;

create policy "match_history_entries_update_own"
  on public.match_history_entries
  for update
  to authenticated
  using (user_id = (select auth.uid ()))
  with check (user_id = (select auth.uid ()));

create or replace function public.match_history_entries_member_update_guard ()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
  if (select auth.uid ()) is not null and (select auth.uid ()) = old.user_id then
    if new.match_id is distinct from old.match_id
       or new.user_id is distinct from old.user_id
       or new.counterpart_display_name is distinct from old.counterpart_display_name
       or new.counterpart_email is distinct from old.counterpart_email
       or new.notified_at is distinct from old.notified_at then
      raise exception 'Members may only update seen_at on match_history_entries';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists match_history_entries_member_update_guard_trg
  on public.match_history_entries;

create trigger match_history_entries_member_update_guard_trg
  before update on public.match_history_entries
  for each row
  execute function public.match_history_entries_member_update_guard ();
