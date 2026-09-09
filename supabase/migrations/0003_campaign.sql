-- Embercrown — the campaign: thirteen weeks, five lieutenants and a wyrm.
-- 14 September to 15 December 2026.
--
-- A sequel to the March to Highcrown. Change the dates here to re-run it; the
-- rest of the app derives everything from these two tables.
--
-- The shape of the season:
--   Act I runs 21 days rather than 14. The campaign opens five days after it was
--   announced, so the whole of the first act is people still making characters
--   and working out what counts — no one who joins in week two has already
--   missed a fight. Acts II-V are clean fortnights, every one closing on a
--   Sunday. After the Echo Warden falls on 29 November there is no lieutenant
--   left, only 16 days of climbing, scored on the whole campaign.
--
-- Balance, so the numbers are arguable rather than magic:
--   required_per_hero is points per *active* hero, where an active hero is one
--   who logged at least one deed inside that boss's window. So the real
--   question a threshold asks is not "how hard must someone train" but "what
--   share of the company has to be doing this at all".
--   At 250 in all six, the dragon needs roughly a third of the party active in
--   each category — e.g. two 20-minute meditations a week for the season is
--   about 830 Intelligence, so one hero in three covers everyone else's share.
--   That is enough to make the company notice and coordinate, and not enough to
--   become a chore. Constitution clears itself; Wisdom and Charisma are the
--   ones that need somebody to actually organise something.
--   The minibosses are deliberately steeper inside their own fortnight — Act II
--   wants something like 60% of the party sitting quietly — because each act is
--   there to make everyone try the thing it is about. The Council's dispatch
--   names the two abilities in advance, so nobody is ambushed.

insert into campaign (id, title, subtitle, starts_on, ends_on) values (
  true,
  'Embercrown',
  'The Waking of the Ashen Wyrm',
  date '2026-09-14',
  date '2026-12-15'
);

insert into bosses (
  id, act, name, title, place,
  window_starts_on, encounter_on,
  tested_abilities, required_per_hero, is_final, icon,
  intro, approach_text, victory_text, defeat_text
) values

-- ── Act I ──────────────────────────────────────────────────────────────────
(
  'grimjaw', 1, 'Grimjaw', 'the Hollow Knight', 'The Rusted Gate, north of Riverwatch',
  date '2026-09-14', date '2026-10-04',
  array['str', 'con'], '{"str": 95, "con": 95}'::jsonb, false,
  'game-icons:visored-helm',

  'The north gate of Riverwatch has not opened since the night the wyrm woke. '
  'Something is standing in it: a suit of siege-plate eight feet tall, filled to '
  'the gorget with cold ash, with nothing inside the helm but a slow grey light. '
  'The ferrymen call it Grimjaw, for the sound the visor makes when the wind '
  'gets under it. It has not moved in eleven days. It does not need to.',

  'There is no riddle here and no mercy in it. Grimjaw has no mind to argue with '
  'and no eyes to deceive. It is a great deal of weight standing where the road '
  'ought to be, and the only answer to that is to be heavier, or to still be '
  'pushing when it stops. Train your backs and your lungs, and come at the gate '
  'together.',

  'The company hits the gate as one and keeps hitting it. For a long moment '
  'nothing gives — and then the ash inside the armour shifts, and the whole grey '
  'weight of it goes over backwards into the mud with a sound like a bell being '
  'dropped down a well. The visor comes off. There was never anything in it. '
  'Behind the gate, the north road runs on, and the light on it is ordinary '
  'daylight, and after eleven days that is worth more than treasure. '
  'The road to the Hollow Wood is open.',

  'The company throws itself at the gate until the light goes, and Grimjaw does '
  'not so much win as fail to notice. In the morning the armour is gone, and so '
  'is the ash it was standing in — a long grey smear up the north road, toward '
  'the mountain. It has gone to her. Whatever weight it was carrying, she is '
  'carrying now, and the party will meet it again at the summit with the wyrm '
  'behind it.'
),

-- ── Act II ─────────────────────────────────────────────────────────────────
(
  'whisperer', 2, 'The Whisperer', 'in the Fen', 'The Hollow Wood',
  date '2026-10-05', date '2026-10-18',
  array['int', 'wis'], '{"int": 80, "wis": 80}'::jsonb, false,
  'game-icons:goblin-head',

  'The Hollow Wood was only ever a wood. Now there is a fen in the middle of it '
  'that no map admits to, and a voice in the fen that knows things it should not. '
  'It speaks to each traveller alone, in their own voice, and what it says is '
  'always true — the session they skipped, the Tuesday they did not get up, the '
  'excuse they made and half believed. It does not lie. It simply will not stop, '
  'and it will not let you past until you can hear all of it without flinching.',

  'The path across the fen is perfectly clear. It has been clear the whole time. '
  'It is only invisible to anyone still arguing with the voice. Sit with the '
  'quiet, breathe, and stretch out what the argument has knotted up — and the '
  'water goes down to ankle depth and the stones show through.',

  'One at a time, the company stops answering. The voice runs on for a while '
  'longer out of habit, reciting failures to people who have simply agreed with '
  'it, and then, having nothing left to hold, it thins out into the reeds and is '
  'only frogs. The fen is four inches deep. It always was. On the far bank '
  'someone laughs, and it carries a long way in the new quiet. '
  'The road to Thunderfalls is open.',

  'The company argues with the fen for two weeks and the fen never tires, '
  'because it is not the one doing the talking. On the fifteenth morning the '
  'water is gone and so is the voice, north, toward the mountain — carrying '
  'every true thing it learned about every one of them. She will know exactly '
  'what to say at the summit.'
),

-- ── Act III ────────────────────────────────────────────────────────────────
(
  'kaerith', 3, 'Kaerith', 'the Drowned Serpent', 'Thunderfalls Deep',
  date '2026-10-19', date '2026-11-01',
  array['con', 'dex'], '{"con": 90, "dex": 85}'::jsonb, false,
  'game-icons:sea-serpent',

  'Kaerith has coiled through the cataracts of Thunderfalls since before '
  'Thunderfalls had a name, and in all that time she has never once had to '
  'hurry. She is not the wyrm''s creature; she does not need to be. The stair '
  'behind the falls is the only way north, the stair goes through her, and she '
  'has all the time there has ever been.',

  'There is no clever way to do this. The stair is wet, the footing is bad, and '
  'the fight lasts exactly as long as the slowest lung in the company. Build the '
  'engine and learn where your feet are, because somebody has to still be moving '
  'when she stops.',

  'Hour eleven. The company is past speech, working in shifts on the wet stone, '
  'and Kaerith — who has never hurried, and therefore has never learned to — '
  'makes the first mistake of her very long life and puts a coil where a coil '
  'should not go. It is not a killing blow. It does not need to be. She unwinds '
  'from the stair with something that is almost respect and goes down into the '
  'deep water, and the way north stands open and roaring. '
  'The road to Silverhold is open.',

  'The company is still on the stair when the light fails on the last day, and '
  'Kaerith is exactly where she was at the start, because she has done this '
  'before and they have not. In the night she leaves the falls for the first '
  'time in an age and goes upriver, toward the mountain, curious now. Something '
  'in the company interested her. She would like to see how it ends.'
),

-- ── Act IV ─────────────────────────────────────────────────────────────────
(
  'coinshade', 4, 'Vex Coinshade', 'the Tallyman', 'The Undermarket of Silverhold',
  date '2026-11-02', date '2026-11-15',
  array['dex', 'cha'], '{"dex": 95, "cha": 90}'::jsonb, false,
  'game-icons:hooded-figure',

  'Silverhold''s gates are shut, as they always are, so the road goes under it — '
  'through the Undermarket, where the dwarves sell what the dwarves will not '
  'discuss upstairs. Vex Coinshade keeps the tally there. He is unfailingly '
  'polite, he has never broken an agreement in his life, and he has already '
  'bought four companies this season. None of them noticed being sold.',

  'Coinshade does not fight. He meets each hero alone in a side passage and '
  'makes them a fair, generous, entirely genuine offer to go home — and the '
  'terrible thing is that it is a good offer. He wins by arithmetic: a company '
  'is only ever bought one person at a time. Move fast through the under-halls, '
  'and do not let anybody walk one alone.',

  'He gets three of them into side passages and makes three excellent offers, '
  'and all three come back and say so out loud, at the table, in front of '
  'everyone. That is not how it is supposed to go. Coinshade recalculates, finds '
  'no remaining angle, and — because he is a professional — closes his ledger, '
  'stands, and tells them how to get up through the cellars to the north stair. '
  'He even tells them the truth. '
  'The road to the Bridge of Echoes is open.',

  'Nobody betrays anybody. It is quieter than that. People simply start taking '
  'the corridors on their own, and stop mentioning what they were offered, and '
  'by the last day the company is a set of individuals who happen to be walking '
  'in the same direction. Coinshade closes the ledger with a small satisfied '
  'note and sends his tally up the mountain, because the wyrm pays better than '
  'anyone and she likes to know where the seams are.'
),

-- ── Act V ──────────────────────────────────────────────────────────────────
(
  'echo-warden', 5, 'The Echo Warden', 'Doubt, Wearing Your Face',
  'The Bridge of Echoes',
  date '2026-11-16', date '2026-11-29',
  array['cha', 'wis'], '{"cha": 100, "wis": 95}'::jsonb, false,
  'game-icons:mirror-mirror',

  'A narrow span of stone over a dark with no bottom to it. Every traveller who '
  'crosses hears the ones who crossed before — their doubts, their triumphs, '
  'their fear. The fellowship walked it a year ago and heard only voices. The '
  'echoes have teeth now. Something crosses with the company in the middle '
  'distance, wearing their faces and speaking in their voices, and it is very '
  'good at both.',

  'The Warden is only ever as strong as the company is scattered. It cannot copy '
  'two people at once who are actually looking at each other. Cross together, '
  'out loud, in company — and keep enough left in the tank to hold your nerve, '
  'because the last hundred yards are the ones it has been saving for.',

  'Halfway out, the Warden wears the face of the one person nobody would '
  'question, and says the reasonable thing, and for a heartbeat the bridge is '
  'very quiet. Then somebody says a name — the real one, out loud — and somebody '
  'else answers, and the whole company goes down the span calling to each other '
  'like idiots, and the thing walking with them runs out of faces to wear. It '
  'goes over the rail without a sound. The bridge holds. '
  'The road to the Ember Throne is open.',

  'They cross. Everyone crosses. But they cross strung out over half a mile, '
  'each of them alone with something wearing a face they trust, and every one of '
  'them reaches the far side having privately agreed to something. The Warden '
  'does not follow. It does not need to — it goes ahead, up the mountain, to '
  'wait with the others, and it has learned the company''s names now, and how '
  'each of them likes to be spoken to.'
),

-- ── Finale ─────────────────────────────────────────────────────────────────
(
  'vharaxis', 6, 'Vharaxis', 'the Ashen', 'The Ember Throne, above Highcrown',
  date '2026-09-14', date '2026-12-15',
  array['str', 'dex', 'con', 'int', 'wis', 'cha'],
  '{"str": 250, "dex": 250, "con": 250, "int": 250, "wis": 250, "cha": 250}'::jsonb,
  true, 'game-icons:dragon-head',

  'The summit above Highcrown, and ash coming down like grey snow. She is not '
  'sitting on the Ember Throne. She is the reason it is called that. Vharaxis '
  'was old when the Flame was young, and she remembers a thing the founders left '
  'out of the story: they did not forge that fire. They took it. One ember, out '
  'of a hoard beneath the world, while she slept — and every year since, every '
  'step anybody walked toward Highcrown, has been fed to a light that was hers. '
  'She has come for the interest.' || E'\n\n' || ''
  'She has also named the day, because a wyrm that old thinks in seasons and '
  'likes a clean ledger. She will be met on the fifteenth of December, before '
  'the longest night — or she carries the ember down into the dark with her, '
  'and the Flame does not come out the other side.',

  'You cannot out-fly a wyrm and you cannot out-burn one. She has already beaten '
  'stronger companies than this, and quicker ones, and she has centuries of '
  'practice at finding the one thing a party never trained. The only way onto '
  'that summit is to arrive complete — strong, quick, tireless, clear-headed, '
  'steady, and together — and be, in all six, something she did not expect.' || E'\n\n' || ''
  'When the Echo Warden goes off the bridge on the twenty-ninth of November '
  'there is nothing left between the company and the mountain: no lieutenant, '
  'no trial, only sixteen days of climbing into the shortening afternoons, with '
  'the roads bad and the light gone by four. Everything logged since the '
  'fourteenth of September is on the sledge behind you. Nothing else is.',

  'She takes the company apart looking for the seam. She is very good at it, and '
  'she has all the time in the world, and there is no seam. Strength where she '
  'expected exhaustion. Nerve where she expected the fear. Six of them where she '
  'expected, in the end, one. ' || E'\n\n' || ''
  'When she finally stops, it is not because she is beaten — a thing like '
  'Vharaxis is never quite beaten — but because she has understood something, '
  'and it has cost her the argument. The ember was never in the hoard. It was '
  'never in the Flame either. It has been in the people walking toward it the '
  'entire time, which is why it kept burning while she slept, and why there was '
  'always more of it than she remembered leaving.' || E'\n\n' || ''
  'She goes up. The ash stops. The sun comes over the shoulder of the mountain '
  'with nothing standing in front of it for the first time in a year, and it is '
  'a thin, low, fifteenth-of-December sun, and it is enough.' || E'\n\n' || ''
  'In the Great Hall the Eternal Flame stands up straight. The longest night is '
  'still ahead of the realm — but it will be got through now, the way it always '
  'was: by people going out into the cold and coming back.' || E'\n\n' || ''
  'The Council will want to give the company something. The company, on the '
  'whole, would like to sit down.' || E'\n\n' || ''
  'The Embercrown is held.',

  'They reach the summit. That, in the end, is the part that was in doubt, and '
  'they do it.' || E'\n\n' || ''
  'But she has been watching the road all season, and she knows exactly which of '
  'the six they never trained, and she opens the argument there. The company '
  'holds the Ember Throne for a long time — longer than she expected, long '
  'enough that she has to work — and then the gap tells, the way a gap always '
  'tells, and Vharaxis takes the ember back out of the mountain and goes north '
  'with it, into the shortest days of the year.' || E'\n\n' || ''
  'The Flame at Highcrown does not go out. It gutters, and holds, and burns low '
  'all through midwinter — because a fire like that runs on people moving '
  'together, and this year the realm moved. Not enough. But it moved, and the '
  'nights start getting shorter again on their own.' || E'\n\n' || ''
  'The Council is already drafting next year''s summons. The road north is still '
  'there, and so is the company, and everyone now knows exactly which of the six '
  'she went for.' || E'\n\n' || ''
  'The Embercrown is lost — for now.'
);
