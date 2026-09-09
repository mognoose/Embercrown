-- Reschedule: the campaign now runs 14 September to 15 December 2026.
--
-- 0003 has been corrected for a fresh install; this brings an already-installed
-- database in line. Safe to run on either — every statement is an UPDATE to a
-- known row, so running it twice changes nothing the second time.
--
-- What moved:
--   * The season is 93 days instead of 92, and starts three weeks earlier.
--   * Act I runs 21 days rather than 18, because the campaign now opens five
--     days after it was announced and the whole of the first act is people
--     still signing up. Its threshold rises with its length, 85 -> 95, which is
--     still the gentlest act per day of anything in the ladder.
--   * The finale is no longer New Year's Eve, so Vharaxis's prose no longer
--     turns on midnight and the year changing. She is met before the longest
--     night instead.
--
-- Nothing else changes: Acts II-V keep their thresholds, and the dragon keeps
-- 250 in all six, because 93 days is the same season length as 92.

update campaign set
  starts_on = date '2026-09-14',
  ends_on   = date '2026-12-15';

update bosses set
  window_starts_on  = date '2026-09-14',
  encounter_on      = date '2026-10-04',
  required_per_hero = '{"str": 95, "con": 95}'::jsonb
where id = 'grimjaw';

update bosses set
  window_starts_on = date '2026-10-05',
  encounter_on     = date '2026-10-18'
where id = 'whisperer';

update bosses set
  window_starts_on = date '2026-10-19',
  encounter_on     = date '2026-11-01'
where id = 'kaerith';

update bosses set
  window_starts_on = date '2026-11-02',
  encounter_on     = date '2026-11-15'
where id = 'coinshade';

update bosses set
  window_starts_on = date '2026-11-16',
  encounter_on     = date '2026-11-29'
where id = 'echo-warden';

update bosses set
  window_starts_on = date '2026-09-14',
  encounter_on     = date '2026-12-15'
where id = 'vharaxis';

-- The wyrm's account of herself, rewritten off New Year's Eve.
update bosses set
  intro =
    'The summit above Highcrown, and ash coming down like grey snow. She is not '
    'sitting on the Ember Throne. She is the reason it is called that. Vharaxis '
    'was old when the Flame was young, and she remembers a thing the founders left '
    'out of the story: they did not forge that fire. They took it. One ember, out '
    'of a hoard beneath the world, while she slept — and every year since, every '
    'step anybody walked toward Highcrown, has been fed to a light that was hers. '
    'She has come for the interest.' || E'\n\n' ||
    'She has also named the day, because a wyrm that old thinks in seasons and '
    'likes a clean ledger. She will be met on the fifteenth of December, before '
    'the longest night — or she carries the ember down into the dark with her, '
    'and the Flame does not come out the other side.',

  approach_text =
    'You cannot out-fly a wyrm and you cannot out-burn one. She has already beaten '
    'stronger companies than this, and quicker ones, and she has centuries of '
    'practice at finding the one thing a party never trained. The only way onto '
    'that summit is to arrive complete — strong, quick, tireless, clear-headed, '
    'steady, and together — and be, in all six, something she did not expect.' || E'\n\n' ||
    'When the Echo Warden goes off the bridge on the twenty-ninth of November '
    'there is nothing left between the company and the mountain: no lieutenant, '
    'no trial, only sixteen days of climbing into the shortening afternoons, with '
    'the roads bad and the light gone by four. Everything logged since the '
    'fourteenth of September is on the sledge behind you. Nothing else is.',

  victory_text =
    'She takes the company apart looking for the seam. She is very good at it, and '
    'she has all the time in the world, and there is no seam. Strength where she '
    'expected exhaustion. Nerve where she expected the fear. Six of them where she '
    'expected, in the end, one.' || E'\n\n' ||
    'When she finally stops, it is not because she is beaten — a thing like '
    'Vharaxis is never quite beaten — but because she has understood something, '
    'and it has cost her the argument. The ember was never in the hoard. It was '
    'never in the Flame either. It has been in the people walking toward it the '
    'entire time, which is why it kept burning while she slept, and why there was '
    'always more of it than she remembered leaving.' || E'\n\n' ||
    'She goes up. The ash stops. The sun comes over the shoulder of the mountain '
    'with nothing standing in front of it for the first time in a year, and it is '
    'a thin, low, fifteenth-of-December sun, and it is enough.' || E'\n\n' ||
    'In the Great Hall the Eternal Flame stands up straight. The longest night is '
    'still ahead of the realm — but it will be got through now, the way it always '
    'was: by people going out into the cold and coming back.' || E'\n\n' ||
    'The Council will want to give the company something. The company, on the '
    'whole, would like to sit down.' || E'\n\n' ||
    'The Embercrown is held.',

  defeat_text =
    'They reach the summit. That, in the end, is the part that was in doubt, and '
    'they do it.' || E'\n\n' ||
    'But she has been watching the road all season, and she knows exactly which of '
    'the six they never trained, and she opens the argument there. The company '
    'holds the Ember Throne for a long time — longer than she expected, long '
    'enough that she has to work — and then the gap tells, the way a gap always '
    'tells, and Vharaxis takes the ember back out of the mountain and goes north '
    'with it, into the shortest days of the year.' || E'\n\n' ||
    'The Flame at Highcrown does not go out. It gutters, and holds, and burns low '
    'all through midwinter — because a fire like that runs on people moving '
    'together, and this year the realm moved. Not enough. But it moved, and the '
    'nights start getting shorter again on their own.' || E'\n\n' ||
    'The Council is already drafting next year''s summons. The road north is still '
    'there, and so is the company, and everyone now knows exactly which of the six '
    'she went for.' || E'\n\n' ||
    'The Embercrown is lost — for now.'
where id = 'vharaxis';
