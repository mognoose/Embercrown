import type { DeedPoint, Intensity } from '~/types/domain'

/**
 * Deeds, not log entries. The feed reads like a campaign journal, which is most
 * of what makes a spreadsheet feel like a game.
 */

const VERBS: Record<string, string> = {
  running: 'ran the long road',
  intervals: 'ran the beacon-line, hard and back again',
  walking: 'walked',
  cycling: 'rode out',
  swimming: 'swam the cold water',
  rowing: 'took an oar',
  hiking: 'went up into the hills',
  'xc-skiing': 'crossed the snow',
  weights: 'went to the iron',
  calisthenics: 'drilled with nothing but their own weight',
  climbing: 'went up something that did not want to be gone up',
  rucking: 'carried a load a long way',
  'manual-work': 'put their back into honest work',
  'ball-sports': 'played',
  'racket-sports': 'played',
  'martial-arts': 'trained at arms',
  dance: 'danced',
  skating: 'took the ice',
  agility: 'drilled footwork',
  meditation: 'sat with the quiet',
  mindfulness: 'kept watch on their own mind',
  breathwork: 'practised the breath',
  yoga: 'moved through the forms',
  mobility: 'worked the stiffness out',
  stretching: 'stretched out the long muscles',
  sauna: 'took the heat',
  'deliberate-rest': 'rested, deliberately',
  'restorative-walk': 'walked slowly, and thought about nothing',
  'group-class': 'trained in company',
  'team-sport': 'played alongside others',
  'buddy-training': 'dragged a colleague out with them',
  coaching: 'led others through the work',
  club: 'answered the club whistle',
}

const INTENSITY_TAIL: Record<Intensity, string> = {
  light: ' — gently',
  moderate: '',
  hard: ' — and left nothing on the field',
}

export function chronicleLine(deed: DeedPoint): string {
  const verb = VERBS[deed.activity_type_id] ?? `trained at ${deed.activity_name.toLowerCase()}`
  return `${deed.hero_name} ${verb} for ${deed.duration_minutes} minutes${INTENSITY_TAIL[deed.intensity]}.`
}

/** "+48 Constitution" */
export function chronicleGain(deed: DeedPoint): string {
  return `+${Math.round(Number(deed.points))} ${ABILITIES[deed.ability_code].name}`
}

/**
 * Every narrative field on a boss separates paragraphs with a blank line.
 * Splitting here keeps the four of them rendering the same way.
 */
export function paragraphs(text: string | null | undefined): string[] {
  if (!text) return []
  return text.split(/\n\s*\n/).map(p => p.trim()).filter(Boolean)
}
