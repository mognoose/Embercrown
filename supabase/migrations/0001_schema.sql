-- Embercrown — schema, scoring, encounter resolution and row level security.
--
-- Scoring is derived in the database so that every surface (character sheet,
-- party roster, boss projection) agrees by construction. The client never
-- recomputes a total it can ask for.

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------------
-- Reference data
-- ---------------------------------------------------------------------------

create table abilities (
  code       text primary key check (code in ('str', 'dex', 'con', 'int', 'wis', 'cha')),
  name       text not null,
  sort_order int  not null
);

create table classes (
  id              text primary key,
  name            text not null,
  primary_ability text not null references abilities (code),
  -- Gain multiplier applied to deeds that feed the class's primary ability.
  bonus           numeric(3, 2) not null default 1.25 check (bonus between 1 and 2),
  blurb           text not null,
  sort_order      int  not null
);

create table activity_types (
  id                text primary key,
  name              text not null,
  ability_code      text not null references abilities (code),
  points_per_minute numeric(4, 2) not null check (points_per_minute > 0),
  -- Ceiling on minutes of this activity one hero may log on one day.
  daily_minute_cap  int  not null check (daily_minute_cap between 1 and 600),
  sort_order        int  not null default 100
);

create index activity_types_ability_idx on activity_types (ability_code, sort_order);

-- Single-row campaign configuration.
create table campaign (
  id        boolean primary key default true check (id),
  title     text not null,
  subtitle  text not null,
  starts_on date not null,
  ends_on   date not null,
  check (ends_on > starts_on)
);

-- ---------------------------------------------------------------------------
-- Heroes and deeds
-- ---------------------------------------------------------------------------

create table heroes (
  id            uuid primary key references auth.users (id) on delete cascade,
  name          text not null check (char_length(trim(name)) between 2 and 30),
  slug          text not null unique,
  class_id      text not null references classes (id),
  ancestry      text not null,
  portrait_seed int  not null,
  joined_at     timestamptz not null default now()
);

create table deeds (
  id               uuid primary key default gen_random_uuid(),
  hero_id          uuid not null references heroes (id) on delete cascade,
  activity_type_id text not null references activity_types (id),
  performed_on     date not null,
  duration_minutes int  not null check (duration_minutes between 1 and 300),
  intensity        text not null default 'moderate'
                     check (intensity in ('light', 'moderate', 'hard')),
  note             text check (char_length(note) <= 200),
  created_at       timestamptz not null default now(),
  -- Swallows the double-tap on a slow connection.
  unique (hero_id, activity_type_id, performed_on, duration_minutes)
);

create index deeds_hero_idx on deeds (hero_id, performed_on desc);
create index deeds_date_idx on deeds (performed_on);

-- performed_on must fall inside the campaign and may not be in the future.
-- A CHECK constraint cannot hold a subquery, so this is a trigger.
create function deeds_enforce_window() returns trigger
language plpgsql as $$
declare
  c campaign%rowtype;
begin
  select * into c from campaign where id;

  if new.performed_on > current_date then
    raise exception 'A deed cannot be logged for a day that has not happened yet.';
  end if;

  if c.starts_on is not null and new.performed_on < c.starts_on then
    raise exception 'The campaign begins on %; nothing before it counts.', c.starts_on;
  end if;

  if c.ends_on is not null and new.performed_on > c.ends_on then
    raise exception 'The campaign ended on %.', c.ends_on;
  end if;

  return new;
end $$;

create trigger deeds_window
  before insert or update on deeds
  for each row execute function deeds_enforce_window();

-- Per-activity daily minute cap, so one heroic Sunday cannot carry an act.
create function deeds_enforce_daily_cap() returns trigger
language plpgsql as $$
declare
  v_cap   int;
  v_total int;
  v_name  text;
begin
  select daily_minute_cap, name into v_cap, v_name
  from activity_types where id = new.activity_type_id;

  select coalesce(sum(duration_minutes), 0) into v_total
  from deeds
  where hero_id = new.hero_id
    and activity_type_id = new.activity_type_id
    and performed_on = new.performed_on
    and id is distinct from new.id;

  if v_total + new.duration_minutes > v_cap then
    raise exception '% is capped at % minutes a day; % already logged.',
      v_name, v_cap, v_total;
  end if;

  return new;
end $$;

create trigger deeds_daily_cap
  before insert or update on deeds
  for each row execute function deeds_enforce_daily_cap();

-- ---------------------------------------------------------------------------
-- The campaign ladder
-- ---------------------------------------------------------------------------

create table bosses (
  id                text primary key,
  act               int  not null unique,
  name              text not null,
  title             text not null,
  place             text not null,
  -- Minibosses are judged on the deeds of their own two-week act; the dragon is
  -- judged on the whole campaign. window_starts_on says which.
  window_starts_on  date not null,
  encounter_on      date not null,
  tested_abilities  text[] not null check (array_length(tested_abilities, 1) between 1 and 6),
  -- { "str": 85, "con": 85 } — points required *per active hero*.
  required_per_hero jsonb not null,
  is_final          boolean not null default false,
  intro             text not null,
  approach_text     text not null,
  victory_text      text not null,
  defeat_text       text not null,
  icon              text not null,
  check (encounter_on > window_starts_on)
);

-- One row per boss, written once, never revised. Frozen so the chronicle cannot
-- quietly rewrite itself as the party keeps training.
create table encounters (
  boss_id           text primary key references bosses (id) on delete cascade,
  resolved_at       timestamptz not null default now(),
  outcome           text not null check (outcome in ('victory', 'defeat')),
  active_hero_count int  not null,
  party_totals      jsonb not null,
  required          jsonb not null
);

-- ---------------------------------------------------------------------------
-- Scoring
-- ---------------------------------------------------------------------------

create function ability_score(points numeric) returns int
language sql immutable as $$
  select 8 + floor(sqrt(greatest(points, 0) / 10.0))::int;
$$;

create function ability_modifier(score int) returns int
language sql immutable as $$
  select floor((score - 10) / 2.0)::int;
$$;

create function hero_level(points numeric) returns int
language sql immutable as $$
  select 1 + floor(sqrt(greatest(points, 0) / 100.0))::int;
$$;

-- Every deed with its point value: duration × rate × intensity × class bonus.
create view deed_points with (security_invoker = true) as
select
  d.id,
  d.hero_id,
  h.name  as hero_name,
  h.slug  as hero_slug,
  d.activity_type_id,
  t.name  as activity_name,
  t.ability_code,
  d.performed_on,
  d.duration_minutes,
  d.intensity,
  d.note,
  d.created_at,
  round(
    d.duration_minutes
      * t.points_per_minute
      * case d.intensity when 'light' then 0.75 when 'hard' then 1.3 else 1.0 end
      * case when c.primary_ability = t.ability_code then c.bonus else 1.0 end
  , 1) as points
from deeds d
join activity_types t on t.id = d.activity_type_id
join heroes h         on h.id = d.hero_id
join classes c        on c.id = h.class_id;

-- Six rows per hero, always — an untrained ability reports zero rather than
-- going missing, which keeps the character sheet honest.
create view hero_abilities with (security_invoker = true) as
select
  h.id     as hero_id,
  a.code   as ability_code,
  coalesce(sum(dp.points), 0) as points,
  ability_score(coalesce(sum(dp.points), 0)) as score
from heroes h
cross join abilities a
left join deed_points dp on dp.hero_id = h.id and dp.ability_code = a.code
group by h.id, a.code;

create view party_abilities with (security_invoker = true) as
select
  a.code as ability_code,
  coalesce(sum(dp.points), 0)   as points,
  count(distinct dp.hero_id)::int as contributing_heroes
from abilities a
left join deed_points dp on dp.ability_code = a.code
group by a.code;

create view hero_summary with (security_invoker = true) as
select
  h.id,
  h.name,
  h.slug,
  h.ancestry,
  h.portrait_seed,
  h.joined_at,
  h.class_id,
  c.name            as class_name,
  c.primary_ability,
  coalesce(sum(dp.points), 0)              as total_points,
  hero_level(coalesce(sum(dp.points), 0))  as level,
  count(dp.id)::int                        as deed_count,
  max(dp.performed_on)                     as last_deed_on
from heroes h
join classes c on c.id = h.class_id
left join deed_points dp on dp.hero_id = h.id
group by h.id, c.name, c.primary_ability;

-- Consecutive days ending today (or yesterday, so a streak survives until the
-- day is actually over).
create function hero_streak(p_hero uuid) returns int
language plpgsql stable as $$
declare
  d date := current_date;
  n int := 0;
begin
  if not exists (select 1 from deeds where hero_id = p_hero and performed_on = d) then
    d := current_date - 1;
  end if;

  while exists (select 1 from deeds where hero_id = p_hero and performed_on = d) loop
    n := n + 1;
    d := d - 1;
  end loop;

  return n;
end $$;

-- ---------------------------------------------------------------------------
-- Encounters
-- ---------------------------------------------------------------------------

-- A miniboss the party failed to stop escapes to the mountain, and a quarter of
-- what it asked for is added to the dragon's demand — on exactly the abilities
-- the party was weak in.
create function escaped_burden() returns jsonb
language sql stable as $$
  select coalesce(
    jsonb_object_agg(k, v),
    '{}'::jsonb
  )
  from (
    select req.key as k, round(sum((req.value)::numeric) * 0.25, 1) as v
    from encounters e
    join bosses b on b.id = e.boss_id
    cross join lateral jsonb_each(b.required_per_hero) as req(key, value)
    where e.outcome = 'defeat' and not b.is_final
    group by req.key
  ) s;
$$;

-- The heart of the game: how the party stands against one boss.
-- Returns the same shape whether the fight is still ahead (live projection) or
-- already resolved (the frozen record).
create function project_encounter(p_boss_id text) returns jsonb
language plpgsql stable as $$
declare
  b            bosses%rowtype;
  rec          encounters%rowtype;
  v_active     int;
  v_burden     jsonb := '{}'::jsonb;
  v_abilities  jsonb := '[]'::jsonb;
  v_win        boolean := true;
  v_code       text;
  v_points     numeric;
  v_required   numeric;
begin
  select * into b from bosses where id = p_boss_id;
  if not found then
    raise exception 'No such encounter: %', p_boss_id;
  end if;

  select * into rec from encounters where boss_id = p_boss_id;

  if found then
    -- Frozen record: replay exactly what was recorded on the day.
    foreach v_code in array b.tested_abilities loop
      v_points   := coalesce((rec.party_totals ->> v_code)::numeric, 0);
      v_required := coalesce((rec.required ->> v_code)::numeric, 0);
      v_abilities := v_abilities || jsonb_build_object(
        'code', v_code,
        'points', v_points,
        'required', v_required,
        'met', v_points >= v_required,
        'ratio', case when v_required > 0
                      then round(least(v_points / v_required, 1), 4) else 1 end
      );
    end loop;

    return jsonb_build_object(
      'boss_id', b.id,
      'active_heroes', rec.active_hero_count,
      'resolved', true,
      'resolved_at', rec.resolved_at,
      'outcome', rec.outcome,
      'abilities', v_abilities,
      'would_win', rec.outcome = 'victory',
      'escaped_burden', '{}'::jsonb
    );
  end if;

  -- Live projection.
  if b.is_final then
    v_burden := escaped_burden();
  end if;

  select count(distinct hero_id)::int into v_active
  from deeds
  where performed_on between b.window_starts_on and b.encounter_on;

  foreach v_code in array b.tested_abilities loop
    select coalesce(sum(points), 0) into v_points
    from deed_points
    where ability_code = v_code
      and performed_on between b.window_starts_on and b.encounter_on;

    v_required := (
      coalesce((b.required_per_hero ->> v_code)::numeric, 0)
      + coalesce((v_burden ->> v_code)::numeric, 0)
    ) * greatest(v_active, 1);

    if v_points < v_required then
      v_win := false;
    end if;

    v_abilities := v_abilities || jsonb_build_object(
      'code', v_code,
      'points', v_points,
      'required', v_required,
      'met', v_points >= v_required,
      'ratio', case when v_required > 0
                    then round(least(v_points / v_required, 1), 4) else 1 end
    );
  end loop;

  return jsonb_build_object(
    'boss_id', b.id,
    'active_heroes', v_active,
    'resolved', false,
    'resolved_at', null,
    'outcome', null,
    'abilities', v_abilities,
    'would_win', v_win and v_active > 0,
    'escaped_burden', v_burden
  );
end $$;

-- Freezes the result of an encounter whose date has passed. Idempotent: the
-- primary key on encounters.boss_id means the first caller wins and everyone
-- else reads the same row back.
create function resolve_encounter(p_boss_id text) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  b        bosses%rowtype;
  proj     jsonb;
  v_totals jsonb := '{}'::jsonb;
  v_req    jsonb := '{}'::jsonb;
  item     jsonb;
begin
  select * into b from bosses where id = p_boss_id;
  if not found then
    raise exception 'No such encounter: %', p_boss_id;
  end if;

  if b.encounter_on >= current_date then
    -- Not yet fought. Hand back the live projection unchanged.
    return project_encounter(p_boss_id);
  end if;

  if exists (select 1 from encounters where boss_id = p_boss_id) then
    return project_encounter(p_boss_id);
  end if;

  proj := project_encounter(p_boss_id);

  for item in select * from jsonb_array_elements(proj -> 'abilities') loop
    v_totals := v_totals || jsonb_build_object(item ->> 'code', item -> 'points');
    v_req    := v_req    || jsonb_build_object(item ->> 'code', item -> 'required');
  end loop;

  insert into encounters (boss_id, outcome, active_hero_count, party_totals, required)
  values (
    b.id,
    case when (proj ->> 'would_win')::boolean then 'victory' else 'defeat' end,
    (proj ->> 'active_heroes')::int,
    v_totals,
    v_req
  )
  on conflict (boss_id) do nothing;

  return project_encounter(p_boss_id);
end $$;

-- ---------------------------------------------------------------------------
-- Row level security
--
-- The app ships only the anon key, so these policies are the whole of the
-- authorization model. The party may read everything about each other; a hero
-- may write only their own deeds, and only for a day.
-- ---------------------------------------------------------------------------

alter table abilities      enable row level security;
alter table classes        enable row level security;
alter table activity_types enable row level security;
alter table campaign       enable row level security;
alter table heroes         enable row level security;
alter table deeds          enable row level security;
alter table bosses         enable row level security;
alter table encounters     enable row level security;

-- Reference data and lore are readable by anyone, signed in or not, so the
-- opening page and /tale can render before a hero exists.
create policy read_abilities  on abilities      for select using (true);
create policy read_classes    on classes        for select using (true);
create policy read_activities on activity_types for select using (true);
create policy read_campaign   on campaign       for select using (true);
create policy read_bosses     on bosses         for select using (true);

-- The party.
create policy read_heroes on heroes for select
  to authenticated using (true);

create policy create_own_hero on heroes for insert
  to authenticated with check (id = (select auth.uid()));

create policy update_own_hero on heroes for update
  to authenticated using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- Deeds are public to the party — the shared feed is the point — but writable
-- only by their owner.
create policy read_deeds on deeds for select
  to authenticated using (true);

create policy insert_own_deed on deeds for insert
  to authenticated with check (hero_id = (select auth.uid()));

-- A day's grace to fix a typo, then the record stands.
create policy amend_own_deed on deeds for update
  to authenticated
  using (hero_id = (select auth.uid()) and created_at > now() - interval '24 hours')
  with check (hero_id = (select auth.uid()));

create policy retract_own_deed on deeds for delete
  to authenticated
  using (hero_id = (select auth.uid()) and created_at > now() - interval '24 hours');

-- Results are written by resolve_encounter() alone.
create policy read_encounters on encounters for select using (true);

grant execute on function project_encounter(text) to anon, authenticated;
grant execute on function resolve_encounter(text) to authenticated;
grant execute on function hero_streak(uuid)       to authenticated;
