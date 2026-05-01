-- Given and family name; required on every profile row (table empty at migration time).

alter table public.profiles
  add column firstname text not null,
  add column surname text not null;

comment on column public.profiles.firstname is 'Given / first name.';
comment on column public.profiles.surname is 'Family / surname.';
