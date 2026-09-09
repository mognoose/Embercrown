export const ABILITY_CODES = ['str', 'dex', 'con', 'int', 'wis', 'cha'] as const
export type AbilityCode = (typeof ABILITY_CODES)[number]

export const INTENSITIES = ['light', 'moderate', 'hard'] as const
export type Intensity = (typeof INTENSITIES)[number]

/** Must match the CASE expression in the `deed_points` view. */
export const INTENSITY_MULTIPLIER: Record<Intensity, number> = {
  light: 0.75,
  moderate: 1.0,
  hard: 1.3,
}

export interface Ability {
  code: AbilityCode
  name: string
  short: string
  /** What this ability does in the story. */
  flavour: string
  icon: string
  /** CSS custom property holding this ability's one canonical colour. */
  colorVar: `--color-${AbilityCode}`
}

export interface HeroClass {
  id: string
  name: string
  primary_ability: AbilityCode
  bonus: number
  blurb: string
  icon: string
}

export interface ActivityType {
  id: string
  name: string
  ability_code: AbilityCode
  points_per_minute: number
  daily_minute_cap: number
  sort_order: number
}

export interface Hero {
  id: string
  name: string
  slug: string
  class_id: string
  ancestry: string
  portrait_seed: number
  joined_at: string
}

export interface HeroSummary extends Hero {
  class_name: string
  primary_ability: AbilityCode
  total_points: number
  level: number
  deed_count: number
  last_deed_on: string | null
}

export interface HeroAbility {
  hero_id: string
  ability_code: AbilityCode
  points: number
  score: number
}

export interface Deed {
  id: string
  hero_id: string
  activity_type_id: string
  performed_on: string
  duration_minutes: number
  intensity: Intensity
  note: string | null
  created_at: string
}

export interface DeedPoint extends Deed {
  activity_name: string
  ability_code: AbilityCode
  points: number
  hero_name: string
  hero_slug: string
}

export interface Campaign {
  title: string
  subtitle: string
  starts_on: string
  ends_on: string
}

export interface Boss {
  id: string
  act: number
  name: string
  title: string
  place: string
  window_starts_on: string
  encounter_on: string
  tested_abilities: AbilityCode[]
  required_per_hero: Partial<Record<AbilityCode, number>>
  is_final: boolean
  intro: string
  /** The Council's dispatch: what to train before this encounter. */
  approach_text: string
  victory_text: string
  defeat_text: string
  icon: string
}

export interface AbilityStanding {
  code: AbilityCode
  points: number
  required: number
  met: boolean
  ratio: number
}

/** Shape returned by the `project_encounter` and `resolve_encounter` RPCs. */
export interface EncounterProjection {
  boss_id: string
  active_heroes: number
  /** True once the result has been frozen into the `encounters` table. */
  resolved: boolean
  resolved_at: string | null
  outcome: 'victory' | 'defeat' | null
  /** How the party stands right now (or stood, if resolved). */
  abilities: AbilityStanding[]
  /** Whether the party would win if the encounter happened at this moment. */
  would_win: boolean
  /** Extra requirement the dragon has gained from minibosses that escaped. */
  escaped_burden: Partial<Record<AbilityCode, number>>
}
