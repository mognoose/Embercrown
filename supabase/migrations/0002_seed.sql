-- Embercrown — reference data: the six abilities, the six classes, and the
-- activities that feed them.
--
-- points_per_minute is the tuning dial. Activities that are hard to sustain for
-- long (intervals, meditation) earn more per minute and cap out sooner;
-- activities you can do for hours (walking, hiking) earn less and cap later, so
-- that an hour of real effort and three hours of ambling land in the same range.

insert into abilities (code, name, sort_order) values
  ('str', 'Strength',     1),
  ('dex', 'Dexterity',    2),
  ('con', 'Constitution', 3),
  ('int', 'Intelligence', 4),
  ('wis', 'Wisdom',       5),
  ('cha', 'Charisma',     6);

insert into classes (id, name, primary_ability, bonus, blurb, sort_order) values
  ('fighter',   'Fighter',   'str', 1.25,
   'Trained, disciplined, and first through the gate.', 1),
  ('ranger',    'Ranger',    'dex', 1.25,
   'Reads a road the way other people read a page.', 2),
  ('barbarian', 'Barbarian', 'con', 1.25,
   'Stops when the mountain stops.', 3),
  ('wizard',    'Wizard',    'int', 1.25,
   'The only one who noticed the fen was lying.', 4),
  ('druid',     'Druid',     'wis', 1.25,
   'Knows that rest is not the opposite of strength.', 5),
  ('bard',      'Bard',      'cha', 1.25,
   'Nobody walks off alone while the bard is still talking.', 6);

insert into activity_types (id, name, ability_code, points_per_minute, daily_minute_cap, sort_order) values
  -- Strength
  ('weights',        'Weight training',            'str', 1.20, 120, 10),
  ('calisthenics',   'Bodyweight training',        'str', 1.10, 120, 20),
  ('climbing',       'Climbing',                   'str', 1.00, 180, 30),
  ('rucking',        'Rucking or carrying',        'str', 0.80, 120, 40),
  ('manual-work',    'Heavy manual work',          'str', 0.60, 180, 50),

  -- Dexterity
  ('ball-sports',    'Ball sports',                'dex', 1.00, 180, 10),
  ('racket-sports',  'Racket sports',              'dex', 1.10, 180, 20),
  ('martial-arts',   'Martial arts',               'dex', 1.20, 120, 30),
  ('dance',          'Dance',                      'dex', 0.90, 180, 40),
  ('skating',        'Skating or downhill skiing', 'dex', 0.90, 240, 50),
  ('agility',        'Agility and balance work',   'dex', 1.30,  60, 60),

  -- Constitution
  ('running',        'Running',                    'con', 1.20, 180, 10),
  ('intervals',      'Intervals or circuits',      'con', 1.60,  60, 20),
  ('cycling',        'Cycling',                    'con', 0.80, 240, 30),
  ('swimming',       'Swimming',                   'con', 1.20, 120, 40),
  ('rowing',         'Rowing or paddling',         'con', 1.10, 120, 50),
  ('hiking',         'Hiking',                     'con', 0.70, 300, 60),
  ('xc-skiing',      'Cross-country skiing',       'con', 1.00, 240, 70),
  ('walking',        'Walking',                    'con', 0.45, 240, 80),

  -- Intelligence
  ('meditation',     'Meditation',                 'int', 1.60,  60, 10),
  ('mindfulness',    'Mindfulness practice',       'int', 1.60,  60, 20),
  ('breathwork',     'Breathwork',                 'int', 1.80,  45, 30),

  -- Wisdom
  ('yoga',           'Yoga',                       'wis', 1.10, 120, 10),
  ('mobility',       'Mobility work',              'wis', 1.30,  60, 20),
  ('stretching',     'Stretching',                 'wis', 1.20,  60, 30),
  ('sauna',          'Sauna',                      'wis', 0.80,  60, 40),
  ('deliberate-rest','Deliberate rest',            'wis', 1.00,  60, 50),
  ('restorative-walk','Restorative walk',          'wis', 0.60,  90, 60),

  -- Charisma
  ('group-class',    'Group class',                'cha', 1.20, 120, 10),
  ('team-sport',     'Team sport',                 'cha', 1.10, 180, 20),
  ('buddy-training', 'Training with a colleague',  'cha', 1.30, 120, 30),
  ('coaching',       'Coaching or leading a session', 'cha', 1.50, 120, 40),
  ('club',           'Club or league session',     'cha', 1.00, 180, 50);
