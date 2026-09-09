# Embercrown — a gamified exercise-logging web app

## Context

HiQ wants a mobile-first web app that turns exercise logging into a cooperative D&D campaign. Everyone
who joins creates a character; every logged workout feeds one of the six classic ability scores; the
party's combined strength is tested against a ladder of boss encounters and, at the campaign deadline,
against a dragon.

The folder already contains a previous HiQ challenge, `JourneyToHighcrown` — a collective step counter
skinned as a fantasy march to Highcrown Castle, with real lore (the Eternal Flame, the Fellowship of HiQ,
Riverwatch, Thunderfalls, Silverhold, the Bridge of Echoes). That app has no characters, stats, or combat.
This new app is its **sequel**: same world, same place names, but a real character-and-encounter system.

Sibling project `HiQ-Wellness` establishes the house tooling: Nuxt 4, npm, `@nuxt/fonts`, `@nuxt/icon`,
Pinia, the `app/` srcDir convention.

**Decisions confirmed with the user:** Supabase (hosted Postgres + Auth) for a genuinely shared party ·
hero name + PIN login · Tailwind v4 with a hand-built dark fantasy theme · new sibling folder ·
sequel to the Highcrown lore · cooperative party-total win condition requiring all six ability scores ·
12-week campaign, 5 minibosses + the dragon · Supabase setup steps included.

---

## Part 1 — The campaign

### Title

**Embercrown — The Waking of the Ashen Wyrm**

### The plot

> One year ago the Fellowship of HiQ carried thirty million steps to the cliffs of Highcrown and
> rekindled the Eternal Flame. The realm rejoiced. It should not have.
>
> The Flame burns on the strength of people moving together — and it burned so brightly that its light
> went down through the roots of the mountain, into a dark that had held still for an age. There it
> touched a sleeping eye.
>
> **Vharaxis the Ashen** was old when the Flame was young. The founders of Highcrown did not forge that
> fire; they *took* it, one ember, from a hoard beneath the world, and they never told the story that
> way. The wyrm has been dreaming of it ever since. Now she is awake, she has taken the sky above
> Highcrown, and she has set her lieutenants on every road the fellowship once walked.
>
> The Council of HiQ has sent out a second summons — and this one is not for marchers. Ash chokes the
> long roads; there is no walking to Highcrown now. What the realm needs is a company: a handful of
> heroes who will spend twelve weeks making themselves strong enough to climb the mountain and stand on
> the **Ember Throne**.
>
> You cannot out-fly a dragon. You cannot out-burn one. You can only arrive at the summit having become
> something she did not expect.

### The six virtues (why every stat matters)

Vharaxis is beaten by a *complete* company, and the story says so out loud: an ember of the Flame lives
in every hero, and the wyrm can only be met by a fire fed from all six sides. A party of nothing but
runners arrives at the Ember Throne with a fire that burns hot and thin, and she snuffs it.

### The act structure — 12 weeks, six encounters

Each act runs two weeks and ends in an encounter at a fixed date. A miniboss tests **two** abilities; the
dragon tests **all six**.

| Act | Week | Place | Encounter | Tests |
|---|---|---|---|---|
| I | 2 | The Rusted Gate, north of Riverwatch | **Grimjaw, the Hollow Knight** | STR · CON |
| II | 4 | The Hollow Wood and the fen beyond | **The Whisperer in the Fen** | INT · WIS |
| III | 6 | Thunderfalls Deep | **Kaerith, the Drowned Serpent** | CON · DEX |
| IV | 8 | The Undermarket of Silverhold | **Vex Coinshade, the Tallyman** | DEX · CHA |
| V | 10 | The Bridge of Echoes | **The Echo Warden** | CHA · WIS |
| Finale | 12 | The Ember Throne, above Highcrown | **Vharaxis the Ashen** | all six |

**Act I — The Rusted Gate.** An empty suit of siege-plate, packed with ash and standing in the north gate
of Riverwatch since the night the wyrm woke. It has no mind to reason with and no eyes to trick. Something
in there has to be shoved out of the way.

**Act II — The Hollow Wood.** The fen shows each hero their worst week on a loop — the missed sessions,
the excuses, the Tuesday they didn't get up. The path through it is perfectly clear to anyone who can
look at all that without flinching, and invisible to everyone else.

**Act III — Thunderfalls Deep.** Kaerith has coiled through the cataracts since before Thunderfalls had a
name, and she has never once had to hurry. There is no clever way to win this. Someone has to still be
moving when she stops.

**Act IV — The Undermarket of Silverhold.** Vex Coinshade does not fight. He meets each hero alone in a
side passage and makes them a fair, generous, entirely genuine offer to go home. Beating him takes quick
feet through the under-halls and a company that nobody can buy one piece at a time.

**Act V — The Bridge of Echoes.** The old trial, but the echoes have teeth now. The Warden crosses wearing
the party's own faces and speaking in their own voices. A hero alone on that bridge loses. The bridge only
holds under people who are still showing up for each other.

**Finale — The Ember Throne.** The summit above Highcrown, ash falling like grey snow. Vharaxis wants the
ember back out of every one of them. She is met by a company that is strong, quick, tireless, clear-headed,
steady and *together* — or she is not met at all.

### Failure has a story, not a dead end

If the party misses a miniboss's thresholds on its date, the boss is **not** simply beaten later — it
**escapes to the mountain** and its remaining strength is added to Vharaxis's thresholds at week 12. The
campaign always continues, the stakes are real, and there is a visible reason to catch up. If every
miniboss escapes, the dragon is very hard but never mathematically impossible.

### Small narrative touches worth building

- **The Kindling** — the first workout a hero logs lights their ember and unlocks the map. A one-screen
  tutorial with a line of prose, not a modal tour.
- **Deeds, not entries.** The shared feed renders logs in chronicle voice:
  *"Torvin Ashfoot ran eight kilometres along the Serpent Road. +48 Constitution."*
- **Boons** — small titles for milestones: *Emberlit* (first deed), *Unbroken* (7-day streak),
  *Sixfold* (contributed to all six abilities), *Standard-Bearer* (top contributor in an act).
- **The Council's dispatch** — each act opens with a short in-world briefing naming the two abilities it
  will test, so the party knows what to train.

---

## Part 2 — Game mechanics

### The six abilities and what feeds them

| Ability | In-world | Activities |
|---|---|---|
| **STR** Strength | shoving Grimjaw aside | weight training, calisthenics, climbing, carrying, heavy garden/manual work |
| **DEX** Dexterity | footwork in the Undermarket | ball & racket sports, martial arts, dance, skating, skiing, agility work |
| **CON** Constitution | outlasting Kaerith | running, walking, cycling, swimming, rowing, hiking, cross-country skiing |
| **INT** Intelligence | seeing through the fen | mindfulness, meditation, breathwork *(per the user's spec)* |
| **WIS** Wisdom | keeping your feet on the bridge | stretching, mobility, yoga, sauna, deliberate rest & sleep discipline |
| **CHA** Charisma | a company nobody can buy | group classes, team sport, training with a colleague, coaching someone |

WIS and CHA are deliberate: they reward recovery and bringing people along, which is what a workplace
wellness challenge should reward and what a pure "log your gym time" app never does.

### Classes

Six classes, each with a primary ability, `+25%` gain on it. A mixed party clears the dragon far more
easily than six of the same class — the mechanics push the same message the story does.

| Class | Primary | Blurb |
|---|---|---|
| Fighter | STR | *Trained, disciplined, and first through the gate.* |
| Ranger | DEX | *Reads a road the way others read a page.* |
| Barbarian | CON | *Stops when the mountain stops.* |
| Wizard | INT | *The only one who noticed the fen was lying.* |
| Druid | WIS | *Knows that rest is not the opposite of strength.* |
| Bard | CHA | *Nobody walks off alone while the bard is talking.* |

Ancestry (Human, Elf, Dwarf, Halfling, Half-Orc, Tiefling, Dragonborn, Gnome) is **pure flavour, no
mechanics** — it colours the portrait and the chronicle text. Portraits are generated from an iconify
glyph + a palette seeded off the hero name; no illustration work needed to ship.

### Scoring

```
deed_points = duration_minutes × activity.points_per_minute × intensity × class_bonus
  intensity: light 0.75 · moderate 1.0 · hard 1.3
  class_bonus: 1.25 on the class's primary ability, else 1.0
```

Points accumulate per hero per ability, uncapped. The D&D-looking score is a **display** derived from them:

```
ability_score = 8 + floor( sqrt( points / 10 ) )        modifier = floor( (score - 10) / 2 )
```

so 250 pts → 13, 1000 pts → 18, 2500 pts → 23. Diminishing returns per person, which keeps one obsessive
athlete from trivialising the party score, but never a hard cap.

`hero_level = 1 + floor( sqrt( total_points_all_abilities / 100 ) )`.

### Boss thresholds scale with the party

Headcount is unknown until people sign up, so a boss stores a **per-hero requirement**, not an absolute:

```
required(ability) = boss.required_per_hero[ability] × active_hero_count
active_hero_count = heroes with ≥1 deed in the current act
```

An encounter is won when the party's total points meet the requirement in **every ability the boss tests**.
This auto-balances a party of 8 and a party of 40, and — importantly — a hero who signs up and never logs
doesn't drag the party down.

### Suggested starting calibration

Assume a moderately active participant logs ~150 minutes/week. Over a two-week act at moderate intensity
that is ~300 points spread across abilities. Miniboss `required_per_hero` of **90–120 per tested ability**
per act is a genuine but fair stretch; the dragon asks **~150 per ability across all six**, which forces
real breadth. These are seed values in the database and explicitly meant to be retuned after week 1 —
the plan includes an admin-visible "projected outcome" readout so you can see a fight is unwinnable before
the party does.

---

## Part 3 — Technical plan

### Location and stack

New sibling folder **`/Users/szilagyicsaba/Projects/HiQ/Embercrown`**, its own git repo, scaffolded with
`npx nuxi@latest init Embercrown` (npm, TypeScript, git) — this is the "empty Nuxt starter" step, and it
gives the same minimal starter `HiQ-Wellness` was built from.

Verified current versions: `nuxt` 4.5.2 · `@nuxtjs/supabase` 2.0.10 (ships `@supabase/ssr` 0.12) ·
`@supabase/supabase-js` 2.116 · `tailwindcss` / `@tailwindcss/vite` 4.3.3 · `@nuxt/icon` 2.5.1 ·
`@nuxt/fonts` 0.14.0 · `zod` 4.5.4.

Modules: `@nuxtjs/supabase`, `@nuxt/fonts`, `@nuxt/icon` (+ `@iconify-json/game-icons` — a large free
fantasy glyph set, perfect for classes, abilities and bosses). **Tailwind v4 is installed as a Vite
plugin, not via `@nuxtjs/tailwindcss`** (that module is still v3-era):

```ts
// nuxt.config.ts
import tailwindcss from '@tailwindcss/vite'
export default defineNuxtConfig({
  modules: ['@nuxtjs/supabase', '@nuxt/fonts', '@nuxt/icon'],
  css: ['~/assets/css/main.css'],
  vite: { plugins: [tailwindcss()] },
  supabase: {
    redirect: true,
    redirectOptions: { login: '/enter', callback: '/', exclude: ['/', '/tale', '/create'] },
  },
  compatibilityDate: '2025-07-15',
})
```

`app/assets/css/main.css` starts with `@import "tailwindcss";` then an `@theme` block defining the
fantasy palette (ink/parchment/ember/ash tokens, `--font-display` for a blackletter-ish display face
pulled by `@nuxt/fonts`, `--color-str/dex/con/int/wis/cha` so each ability has one canonical colour used
by bars, charts and icons alike). Dark by default; mobile-first, with a bottom tab bar under `md:`.

**No Pinia.** Supabase + `useAsyncData`/`useSupabaseClient` covers all state; the only shared client
state is the current hero, which is one `useState`-backed composable.

### Auth: hero name + PIN

**Recommended: Supabase Auth with a synthetic email shim.** At character creation the app slugifies the
hero name and calls `signUp({ email: `${slug}@heroes.embercrown.invalid`, password: pin })`; login is the
same slug plus PIN. This keeps `auth.uid()` real, so **RLS does all the authorization** and the app can
run entirely on the anon key with no service-role secret anywhere in the bundle. The `@nuxtjs/supabase`
module handles the SSR cookie session, `useSupabaseUser()`, and route protection.

The alternative — Nitro routes holding `service_role` and a bcrypt PIN table — means hand-rolling
sessions and losing RLS as a safety net, for no gain at this scale. Not worth it.

Practical constraints this imposes:
- Supabase enforces a **6-character minimum password**, so it is a **6-digit PIN**, not 4. Say so in the
  UI copy ("choose a six-digit sigil").
- In the Supabase dashboard: disable email confirmations (the domain is unroutable by design — `.invalid`
  is reserved by RFC 2606 so nothing ever leaks), and turn off "allow new users to sign up" once the
  party is assembled if you want a closed roster.
- **Rate limiting**: 6 digits is a million combinations; Supabase Auth already rate-limits sign-in per IP,
  and this is an internal challenge where the worst case is a colleague logging someone else's push-ups.
  Note the tradeoff in the README rather than over-engineering it. Add a `heroes.failed_attempts` counter
  and a 30-second client-side lockout after 5 misses as cheap defence in depth.
- **PIN reset** has no email channel, so it is deliberately manual: a documented SQL snippet in the README
  for you to run as admin. Small party, rare event.

### Database schema

One migration folder, `supabase/migrations/`, applied either through the SQL editor or the Supabase CLI.

**Tables**

- `heroes` — `id uuid pk references auth.users(id) on delete cascade`, `name`, `slug unique`,
  `class_id`, `ancestry`, `portrait_seed`, `joined_at`. One row per player, created by a trigger or by
  the client immediately after sign-up.
- `classes` — seed data: `id`, `name`, `primary_ability`, `bonus numeric default 1.25`, `icon`, `blurb`.
- `abilities` — seed data: the six, with `code`, `name`, `colour`, `icon`, `flavour`.
- `activity_types` — seed data: `id`, `name`, `ability_code`, `points_per_minute`, `icon`,
  `daily_minute_cap`. ~30 rows covering the table in Part 2.
- `deeds` — the log. `id`, `hero_id`, `activity_type_id`, `performed_on date`, `duration_minutes int`,
  `intensity text check in ('light','moderate','hard')`, `note text`, `created_at`.
- `campaign` — a single-row config table: `title`, `starts_on`, `ends_on`, `lore` jsonb.
- `bosses` — `id`, `act int`, `slug`, `name`, `title`, `place`, `encounter_on date`,
  `tested_abilities text[]`, `required_per_hero jsonb` (`{"str":110,"con":110}`), `is_final bool`,
  `intro`, `victory_text`, `defeat_text`, `icon`.
- `encounters` — the **materialised** result, one row per boss once resolved: `boss_id`, `resolved_at`,
  `outcome`, `active_hero_count`, `party_totals jsonb`, `required jsonb`. Results are frozen so the
  history can't silently rewrite itself as people keep logging.

**Derived scoring, in the database**

```sql
-- points for a single deed, with class bonus applied
create view deed_points as
select d.*, a.ability_code,
       d.duration_minutes * t.points_per_minute
         * case d.intensity when 'light' then 0.75 when 'hard' then 1.3 else 1.0 end
         * case when c.primary_ability = t.ability_code then c.bonus else 1.0 end as points
from deeds d
join activity_types t on t.id = d.activity_type_id
join heroes h on h.id = d.hero_id
join classes c on c.id = h.class_id
join abilities a on a.code = t.ability_code;

create view hero_abilities as        -- hero_id, ability_code, points, score, modifier
create view party_abilities as       -- ability_code, total_points, contributing_heroes
create view hero_summary as          -- hero_id, name, class, level, total_points, deed_count, streak
```

`score = 8 + floor(sqrt(points/10))` lives in one `ability_score(numeric)` SQL function so the client
never re-implements it. A `resolve_encounter(boss_slug)` **RPC** (SECURITY DEFINER) does the comparison
and writes the `encounters` row; a companion `project_encounter(boss_slug)` returns the same comparison
live and unrecorded, which powers the "how are we doing?" bar on the map and lets you see a fight is
unwinnable before the party does.

**RLS** — enabled on every table:
- `heroes`, `hero_summary`, `party_abilities`, `bosses`, `encounters`, all seed tables: `select` for
  `authenticated` (the party is meant to see each other).
- `deeds`: `select` for `authenticated`; `insert`/`update`/`delete` only `where hero_id = auth.uid()`,
  and `update`/`delete` additionally only within 24 hours of `created_at` (fix a typo, don't rewrite
  history).
- `encounters`: no client writes at all — only the RPC.

**Integrity constraints** (cheap, DB-level, no trust in the client):
- `check (duration_minutes between 1 and 300)`
- `check (performed_on <= current_date and performed_on >= (select starts_on from campaign))`
- a `before insert` trigger enforcing `activity_types.daily_minute_cap` per hero per day
- `unique (hero_id, activity_type_id, performed_on, duration_minutes)` to swallow double-submits

**Indexes**: `deeds(hero_id, performed_on desc)`, `deeds(performed_on)`, `heroes(slug)`.

### App structure

```
app/
  app.vue                         NuxtLayout + NuxtPage
  assets/css/main.css             @import tailwindcss + @theme fantasy tokens
  layouts/
    default.vue                   parchment/ash chrome, bottom tab bar (mobile), header (desktop)
    scroll.vue                    narrow prose layout for lore & encounter pages
  middleware/
    hero.global.ts                logged in but no hero row → /create
  pages/
    index.vue                     the Hearth: party banner, next encounter countdown, log CTA, deed feed
    enter.vue                     hero name + 6-digit PIN, sign-in / sign-up toggle
    create.vue                    character creation: name, class, ancestry, portrait
    log.vue                       log a deed — the single most important screen, must be ~3 taps
    hero/[slug].vue               character sheet: portrait, six ability bars, level, boons, deed history
    party.vue                     roster + per-ability contribution leaderboard
    map.vue                       the campaign map: six acts, progress rings, locked/won/lost states
    encounter/[slug].vue          boss page — intro, live projection or frozen result, narrative outcome
    tale.vue                      the full lore (public, no auth)
  components/
    hero/                         portrait.vue, abilityBar.vue, sheet.vue, classPicker.vue
    deed/                         form.vue, feedItem.vue, quickPick.vue
    campaign/                     mapNode.vue, countdown.vue, bossCard.vue, thresholdBar.vue
    ui/                           panel.vue, button.vue, statPill.vue, ornament.vue
  composables/
    useHero.ts                    current hero row + refresh, useState-backed
    useCampaign.ts                campaign config, current act, next encounter
    useAbilities.ts               ability metadata + score/modifier formatting helpers
    useDeeds.ts                   log, edit, delete, recent feed
    useChronicle.ts               renders a deed as in-world prose
  types/                          database.types.ts (generated), domain.ts
  utils/                          slug.ts, score.ts (mirrors the SQL formula for optimistic UI)
supabase/
  migrations/0001_schema.sql      tables, views, functions, RLS
  migrations/0002_seed.sql        abilities, classes, activity types
  migrations/0003_campaign.sql    the Embercrown campaign: dates, six bosses, all narrative text
server/                           none needed
```

`database.types.ts` comes from `npx supabase gen types typescript` so every query is typed end to end.

### Boss resolution — how it actually fires

No cron, no scheduled function. `project_encounter()` is called live on the map and boss pages; when the
encounter date has passed and no `encounters` row exists, the next page load calls `resolve_encounter()`,
which freezes the result and returns it. Idempotent (one row per boss, enforced by a unique constraint),
zero infrastructure. Add a `pg_cron` job later only if you want the result to land at midnight sharp
whether or not anyone is looking.

### Deployment

**Vercel** with the Nuxt preset (zero-config SSR), or Netlify — either is fine. Env vars:
`SUPABASE_URL` and `SUPABASE_KEY` (the anon key; that is the only key the app ever needs, which is the
whole point of the RLS-first design). `.env` is gitignored; `.env.example` is committed.

*Note for the README: the sibling `JourneyToHighcrown` accidentally committed its real `.env` because its
gitignore only excluded `*.local`. The Nuxt starter's gitignore already handles this correctly — don't
weaken it.*

---

## Part 4 — Build order

Each phase ends with something you can open on a phone and show someone.

1. **Scaffold** — `nuxi init`, Tailwind v4 + `@theme` tokens, fonts, icons, layouts, the dark fantasy
   shell with placeholder screens. Demoable: the app looks like the game before it does anything.
2. **Supabase + auth** — project setup, `0001`/`0002` migrations, `@nuxtjs/supabase` wiring, `/enter`,
   `/create`, the `hero.global` middleware. Demoable: two people can make characters and see each other.
3. **Logging and the character sheet** — `/log`, the `deeds` table with its caps and constraints, the
   scoring views, `/hero/[slug]` with six ability bars, `/party` leaderboard. **This is the core loop**;
   everything before it is setup and everything after is theatre. Demoable: a real, working tracker.
4. **The campaign** — `0003` migration with the full Embercrown text, `/map`, `/encounter/[slug]`,
   `project_encounter`, countdowns, the Hearth page. Demoable: the game.
5. **Resolution and consequence** — `resolve_encounter`, victory/defeat narrative pages, escaped
   minibosses feeding the dragon's thresholds, the finale screen.
6. **Polish** — the chronicle feed voice, boons/titles, streaks, PWA manifest so it installs to the home
   screen, empty states, and a `/tale` page for the lore.

Phases 1–4 are the deliverable; 5–6 can follow once people are actually logging.

---

## Verification

- `npm run dev` and drive the whole loop on a phone-sized viewport: create two characters of different
  classes, log deeds against all six abilities, confirm the class bonus shows up in the numbers and that
  the party totals on `/party` equal the sum of both sheets.
- **Prove RLS works**: signed in as hero A, attempt `supabase.from('deeds').delete().eq('hero_id', B)`
  from the browser console — it must affect zero rows. Same for inserting a deed with someone else's
  `hero_id`. This is the one security check that matters, since the anon key is public by design.
- **Prove the constraints work**: try a 500-minute deed, a deed dated tomorrow, and the same deed twice —
  all three must be rejected by Postgres, not just by the form.
- **Test the boss maths without waiting twelve weeks**: temporarily set a boss's `encounter_on` to
  yesterday and its `required_per_hero` low, load the map, confirm an `encounters` row is written exactly
  once and the victory text renders; then reset the date, delete the row, raise the thresholds, and
  confirm the defeat path and the "escaped to the mountain" effect on the dragon's requirements.
- Confirm `project_encounter` matches a hand-calculated expectation for a two-hero party.
- `npm run build && npm run preview` before the first deploy.
