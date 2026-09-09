/**
 * Whether the signed-in account has finished character creation.
 *
 * Filled once by the `hero.global` middleware and carried to the client in the
 * payload, so the guard costs one query per session rather than one per
 * navigation. `null` means "not yet asked".
 */
export function useHasHero() {
  return useState<boolean | null>('has-hero', () => null)
}
