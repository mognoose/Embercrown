import type { Ability, AbilityCode } from '~/types/domain'
import { ABILITY_CODES } from '~/types/domain'

/**
 * Presentation metadata for the six abilities. The *game* data (which activity
 * feeds which ability, and at what rate) lives in the database; only the way an
 * ability looks and reads lives here.
 */
export const ABILITIES: Record<AbilityCode, Ability> = {
  str: {
    code: 'str',
    name: 'Strength',
    short: 'STR',
    flavour: 'For shoving what will not be reasoned with out of the way.',
    icon: 'game-icons:biceps',
    colorVar: '--color-str',
  },
  dex: {
    code: 'dex',
    name: 'Dexterity',
    short: 'DEX',
    flavour: 'For footwork in the under-halls, and for landing on your feet.',
    icon: 'game-icons:acrobatic',
    colorVar: '--color-dex',
  },
  con: {
    code: 'con',
    name: 'Constitution',
    short: 'CON',
    flavour: 'For still moving when the serpent has stopped.',
    icon: 'game-icons:heart-beats',
    colorVar: '--color-con',
  },
  int: {
    code: 'int',
    name: 'Intelligence',
    short: 'INT',
    flavour: 'For seeing the path through a fen that is lying to you.',
    icon: 'game-icons:brain',
    colorVar: '--color-int',
  },
  wis: {
    code: 'wis',
    name: 'Wisdom',
    short: 'WIS',
    flavour: 'For knowing that rest is not the opposite of strength.',
    icon: 'game-icons:owl',
    colorVar: '--color-wis',
  },
  cha: {
    code: 'cha',
    name: 'Charisma',
    short: 'CHA',
    flavour: 'For a company that nobody can buy one piece at a time.',
    icon: 'game-icons:public-speaker',
    colorVar: '--color-cha',
  },
}

export const ABILITY_LIST: Ability[] = ABILITY_CODES.map(code => ABILITIES[code])

/** Icons for the six classes, keyed by class id. */
export const CLASS_ICONS: Record<string, string> = {
  fighter: 'game-icons:sword-brandish',
  ranger: 'game-icons:bowman',
  barbarian: 'game-icons:axe-in-stump',
  wizard: 'game-icons:wizard-staff',
  druid: 'game-icons:oak-leaf',
  bard: 'game-icons:lyre',
}

export const ANCESTRIES = [
  'Human',
  'Elf',
  'Dwarf',
  'Halfling',
  'Half-Orc',
  'Tiefling',
  'Dragonborn',
  'Gnome',
] as const

export type Ancestry = (typeof ANCESTRIES)[number]
