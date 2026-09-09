/**
 * Mirrors the SQL functions of the same names in 0001_schema.sql.
 *
 * The database is the authority — these exist so the UI can show a number
 * optimistically the instant a deed is logged, without a round trip. If you
 * change one, change both.
 */

export function abilityScore(points: number): number {
  return 8 + Math.floor(Math.sqrt(Math.max(points, 0) / 10))
}

export function abilityModifier(score: number): number {
  return Math.floor((score - 10) / 2)
}

export function heroLevel(totalPoints: number): number {
  return 1 + Math.floor(Math.sqrt(Math.max(totalPoints, 0) / 100))
}

export function formatModifier(modifier: number): string {
  return modifier >= 0 ? `+${modifier}` : `${modifier}`
}

/** Points still needed to reach the next ability score. */
export function pointsToNextScore(points: number): number {
  const next = abilityScore(points) - 8 + 1
  return Math.ceil(next * next * 10 - points)
}

/** Progress through the current ability score, 0..1 — for the sliver on a bar. */
export function scoreProgress(points: number): number {
  const step = abilityScore(points) - 8
  const floor = step * step * 10
  const ceil = (step + 1) * (step + 1) * 10
  return ceil === floor ? 0 : (points - floor) / (ceil - floor)
}

export function slugify(name: string): string {
  return name
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 40)
}

/** Deterministic small integer from a string, for portrait generation. */
export function seedFrom(text: string): number {
  let hash = 2166136261
  for (let i = 0; i < text.length; i++) {
    hash ^= text.charCodeAt(i)
    hash = Math.imul(hash, 16777619)
  }
  return Math.abs(hash) % 100000
}
