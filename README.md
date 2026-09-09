# Embercrown

*The Waking of the Ashen Wyrm* — a twelve-week gamified exercise log for a HiQ
team challenge, and a sequel to the March to Highcrown.

Everyone who joins makes a D&D-style character. Every workout you log feeds one
of the six ability scores. Five lieutenants stand between the company and the
mountain, each weighed at the end of its own two weeks, and at week twelve the
whole party is measured against a dragon who tests **all six** — so a company of
nothing but runners does not get up there.

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

---

## Running your own campaign

Everything the players see comes out of two tables, so you can retune the game
without touching the app:

- **Dates** — `campaign.starts_on` / `ends_on`, and each boss's
  `window_starts_on` / `encounter_on`. Minibosses are scored on the deeds inside
  their own two-week window; the dragon's window is the whole campaign.
- **Difficulty** — `bosses.required_per_hero`, e.g. `{"str": 75, "con": 75}`.
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

A moderately active participant logs roughly 150 minutes a week, which is
150–200 points spread across abilities. Over a two-week act that's 300–400
points per hero to distribute, so a miniboss asking 75–100 in each of two
abilities wants about half the party's effort pointed at it. The dragon asks 220
in all six across the whole twelve weeks, which nobody reaches by accident on
Intelligence, Wisdom or Charisma. That is deliberately the hard part.

**Watch the projection in week one.** Every boss page shows a live "how it
stands" readout, so you can see a fight is unwinnable long before the party
does, and adjust `required_per_hero` while it still looks like game design
rather than a rescue.

### When a boss wins

Nothing dead-ends. A miniboss the company fails to stop **escapes to the
mountain**, and a quarter of what it asked for is added to the dragon's demand —
on exactly the abilities the company was weak in. The campaign always runs to
week twelve, and there is always a visible reason to catch up.

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

To test the whole arc without waiting twelve weeks, move a boss's
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
