/**
 * Today's date as YYYY-MM-DD, decided once on the server and carried to the
 * client in the payload. Every act boundary, countdown and "is this boss over
 * yet" check reads from here, so the two renders can never disagree about what
 * day it is.
 */
export function useToday() {
  return useState<string>('today', () => new Date().toISOString().slice(0, 10))
}

export function daysBetween(from: string, to: string): number {
  const a = Date.parse(`${from}T00:00:00Z`)
  const b = Date.parse(`${to}T00:00:00Z`)
  return Math.round((b - a) / 86_400_000)
}

const LONG_DATE = new Intl.DateTimeFormat('en-GB', {
  day: 'numeric',
  month: 'long',
})

export function formatDate(iso: string): string {
  return LONG_DATE.format(new Date(`${iso}T00:00:00Z`))
}

/** "in 9 days", "today", "4 days ago" — for countdowns that don't need to tick. */
export function describeGap(days: number): string {
  if (days === 0) return 'today'
  if (days === 1) return 'tomorrow'
  if (days === -1) return 'yesterday'
  if (days > 0) return `in ${days} days`
  return `${-days} days ago`
}
