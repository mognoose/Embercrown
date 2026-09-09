# Embercrown

*The Waking of the Ashen Wyrm* — a gamified exercise log for a HiQ team
challenge, running **1 October to New Year's Eve**, and a sequel to the March to
Highcrown.

Everyone who joins makes a D&D-style character. Every workout you log feeds one
of the six ability scores. Five lieutenants stand between the company and the
mountain, each weighed at the end of its own act, and at midnight on 31 December
the whole party is measured against a dragon who tests **all six** — so a
company of nothing but runners does not get up there.

Nuxt 4 · Tailwind 4 · Supabase.

---

## Getting it running

### 1. Install

```bash
npm install
```

### 2. Make a Supabase project

1. Create a project at [supabase.com](https://supabase.com).
2. **Authentication → Sign In / Providers → Email**: turn **Confirm email**
   *off*. Heroes sign in with a name and a six-digit sigil, which is shimmed
   onto an address at `heroes.embercrown.invalid` — a domain reserved by RFC
   2606 that provably cannot receive mail, so there is no confirmation link to
   click and nothing ever leaves the building.
3. Once everybody has signed up, you can close the roster under
   **Authentication → Sign Ups** if you want to.

### 3. Run the migrations

Paste each file into the SQL editor in order, or use the CLI:

```bash
npx supabase link --project-ref <your-ref>
npx supabase db push
```

| File | What it does |
| --- | --- |
| `supabase/migrations/0001_schema.sql` | Tables, scoring views, encounter RPCs, row level security |
| `supabase/migrations/0002_seed.sql` | The six abilities, six classes, ~33 activity types |
| `supabase/migrations/0003_campaign.sql` | The Embercrown campaign: dates, six bosses, all the prose |

### 4. Point the app at it

```bash
cp .env.example .env
```

Fill in `SUPABASE_URL` and `SUPABASE_KEY` from **Project settings → API**. The
anon key is the only key the app ever needs — see *Security* below.

```bash
npm run dev
```

### Or run the whole thing locally

`supabase/config.toml` is committed, so you can bring up a throwaway Postgres +
Auth + Studio stack on your own machine (needs Docker running):

```bash
npx supabase start          # prints a local URL and anon key
npx supabase db reset       # applies all three migrations from scratch
```

Point `.env` at the printed `API_URL` and `ANON_KEY` and `npm run dev`. This is
the right place to try schedule changes and difficulty tuning before touching
the hosted project. `npx supabase stop` when you're done.

---

## Running your own campaign

The shipped campaign runs **Thursday 1 October 2026 → Thursday 31 December
2026** — 92 days. Every miniboss falls on a Sunday, so an act closes as the week
closes; the wyrm falls on New Year's Eve.

| Act | Encounter | Window | Days | Tests |
| --- | --- | --- | --- | --- |
| I · Grimjaw | **Sun 18 Oct** | 1 Oct → 18 Oct | 18 | STR · CON |
| II · The Whisperer | **Sun 1 Nov** | 19 Oct → 1 Nov | 14 | INT · WIS |
| III · Kaerith | **Sun 15 Nov** | 2 Nov → 15 Nov | 14 | CON · DEX |
| IV · Vex Coinshade | **Sun 29 Nov** | 16 Nov → 29 Nov | 14 | DEX · CHA |
| V · The Echo Warden | **Sun 13 Dec** | 30 Nov → 13 Dec | 14 | CHA · WIS |
| Finale · Vharaxis | **Thu 31 Dec** | 1 Oct → 31 Dec | 92 | all six |

Two irregularities, both deliberate. **Act I is 18 days** because the campaign
opens on a Thursday and the first act is the one where people are still making
characters and working out what counts. **The 18 days after Act V are the
climb** — no lieutenant left, only the mountain, over the holidays, scored on
the whole campaign, which is the right shape when half the company is
travelling.

Deeds dated before the start date are rejected by the database, so set these to
your own dates before inviting anyone.

Everything the players see comes out of two tables, so you can retune the game
without touching the app:

- **Dates** — `campaign.starts_on` / `ends_on`, and each boss's
  `window_starts_on` / `encounter_on`. Minibosses are scored on the deeds inside
  their own window; the dragon's window is the whole campaign.
- **Difficulty** — `bosses.required_per_hero`, e.g. `{"str": 85, "con": 85}`.
  These are points required *per active hero*, where an active hero is one who
  logged at least one deed inside that boss's window. Thresholds therefore scale
  with turnout: a party of eight and a party of forty get the same fight, and
  somebody who signs up and never logs is not a drag on everyone else.
- **The story** — `bosses.intro`, `approach_text`, `victory_text`,
  `defeat_text`. Paragraph breaks are real newlines; the encounter page splits
  on blank lines.
- **Activities and rates** — `activity_types.points_per_minute` and
  `daily_minute_cap`.

### The balance, in one paragraph

Because thresholds scale per active hero, the question a number really asks is
not "how hard must someone train" but **"what share of the company has to be
doing this at all"**. At the dragon's 250 in all six, that share is about a
third: two twenty-minute meditations a week for the season comes to roughly 830
Intelligence, so one hero in three covers everyone else. Constitution clears
itself; Wisdom and Charisma are the ones that need somebody to actually organise
something, which is the point of them. The minibosses are steeper *inside their
own fortnight* on purpose — Act II wants something like 60% of the party sitting
quietly — because each act exists to make everyone try the thing it is about,
and the Council's dispatch names the two abilities in advance.

**Watch the projection in week one.** Every boss page shows a live "how it
stands" readout, so you can see a fight is unwinnable long before the party
does, and adjust `required_per_hero` while it still looks like game design
rather than a rescue.

### When a boss wins

Nothing dead-ends. A miniboss the company fails to stop **escapes to the
mountain**, and a quarter of what it asked for is added to the dragon's demand —
on exactly the abilities the company was weak in. The campaign always runs to
New Year's Eve, and there is always a visible reason to catch up.

---

## How the numbers work

```
deed points = minutes × activity rate × intensity × class bonus
              intensity: light 0.75 · moderate 1.0 · hard 1.3
              class bonus: 1.25 on your class's primary ability
```

Points accumulate uncapped. The D&D-looking score is derived from them:

```
ability score = 8 + floor(sqrt(points / 10))      → 250 pts = 13, 1000 = 18, 2500 = 23
hero level    = 1 + floor(sqrt(total points / 100))
```

Diminishing returns per person, so one very keen athlete can't trivialise the
party total, but no hard ceiling either.

All of this is computed **in the database** (`deed_points`, `hero_abilities`,
`party_abilities`, `hero_summary` in `0001_schema.sql`), so every screen agrees
by construction. `app/utils/score.ts` mirrors the same formulas purely so the
log form can show you what a deed is worth before you submit it — if you change
one, change both.

---

## Encounter resolution

There is no cron job. `project_encounter(boss_id)` returns a live projection;
once the encounter date has passed, the next page load calls
`resolve_encounter(boss_id)`, which freezes the outcome into the `encounters`
table. It is idempotent — the primary key means the first caller wins and
everyone else reads the same row — and once written, the result never changes,
whatever anybody logs afterwards.

To test the whole arc without waiting three months, move a boss's
`encounter_on` to yesterday, load `/map`, and check that exactly one
`encounters` row appears with the right outcome. Delete the row and reset the
date to try the other branch.

---

## Security

The browser only ever holds the **anon key**, so the row level security policies
in `0001_schema.sql` are the entire authorization model:

- Reference data and lore: readable by anyone.
- Heroes and deeds: readable by any signed-in member of the company — the shared
  chronicle is the point.
- A hero may insert only their own deeds (`hero_id = auth.uid()`), and may amend
  or retract one only within 24 hours of writing it.
- `encounters` takes no client writes at all; only the RPC writes results.

The database also enforces the rules the form suggests: 1–300 minutes, no future
dates, nothing outside the campaign window, a per-activity daily minute cap, and
a uniqueness constraint that swallows double-submits.

**On the sigil.** Six digits is a million combinations, and Supabase rate-limits
sign-ins per IP; the sign-in form adds a 30-second lockout after five misses.
This is right-sized for an internal team challenge where the worst realistic
outcome is a colleague logging someone else's push-ups. It is not a bank vault,
and the sign-in page says so. Tell people not to reuse a PIN they care about.

**Resetting a sigil.** There is no email channel, so it's a manual admin job.
In the Supabase dashboard, **Authentication → Users**, find
`<hero-slug>@heroes.embercrown.invalid` and use *Reset password* → *Send magic
link* is not available; instead use the SQL editor:

```sql
-- Replace both values. Requires the service role (the SQL editor has it).
update auth.users
set encrypted_password = crypt('123456', gen_salt('bf'))
where email = 'torvin-ashfoot@heroes.embercrown.invalid';
```

Then tell them their new six digits, and tell them to change nothing else.

---

## Deploying

Vercel or Netlify, both zero-config for Nuxt SSR. Set `SUPABASE_URL` and
`SUPABASE_KEY` as environment variables. Do not add the service role key —
nothing in this app wants it.

---

## Project layout

```
app/
  assets/css/main.css       Tailwind 4 + the @theme fantasy palette
  components/               campaign/ · deed/ · hero/ · ui/
  composables/              campaign, hero, party, deeds, encounter, sigil, today
  layouts/                  default (app chrome) · scroll (prose)
  middleware/               hero.global — signed in but no character → /create
  pages/                    index · enter · create · log · map · party
                            hero/[slug] · encounter/[slug] · tale
  types/domain.ts           the shared shapes
  utils/                    abilities (display metadata) · score · chronicle
supabase/migrations/        the three SQL files above
```
