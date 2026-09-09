/**
 * Hero name + six-digit sigil, shimmed onto Supabase Auth.
 *
 * Supabase wants an email and a password; the party wants neither. So the hero
 * name is slugified into an address on a domain that provably cannot receive
 * mail (`.invalid` is reserved by RFC 2606), and the sigil is the password.
 * The point of the shim is that `auth.uid()` stays real — which is what lets
 * row level security be the entire authorization model, with no service key
 * anywhere near the browser.
 *
 * Supabase enforces a six-character minimum on passwords, so the sigil is six
 * digits, not four. The UI says so.
 */

const HERO_DOMAIN = 'heroes.embercrown.invalid'

export const SIGIL_LENGTH = 6

export function heroAddress(name: string): string {
  return `${slugify(name)}@${HERO_DOMAIN}`
}

export function useSigil() {
  const supabase = useSupabaseClient()

  async function enter(name: string, sigil: string) {
    const { error } = await supabase.auth.signInWithPassword({
      email: heroAddress(name),
      password: sigil,
    })
    if (error) throw new Error(readSigilError(error.message))
  }

  async function summon(name: string, sigil: string) {
    const { data, error } = await supabase.auth.signUp({
      email: heroAddress(name),
      password: sigil,
    })
    if (error) throw new Error(readSigilError(error.message))
    if (!data.user) throw new Error('The summons failed. Try again.')
    return data.user
  }

  async function depart() {
    await supabase.auth.signOut()
  }

  return { enter, summon, depart }
}

function readSigilError(message: string): string {
  const m = message.toLowerCase()
  if (m.includes('invalid login credentials')) {
    return 'No hero by that name answers to that sigil.'
  }
  if (m.includes('already registered') || m.includes('already been registered')) {
    return 'A hero already carries that name. Choose another, or enter with your sigil.'
  }
  if (m.includes('password should be at least')) {
    return `A sigil is exactly ${SIGIL_LENGTH} digits.`
  }
  if (m.includes('rate limit') || m.includes('too many')) {
    return 'Too many attempts. Wait a moment before trying again.'
  }
  if (m.includes('signups not allowed') || m.includes('signup is disabled')) {
    return 'The roster is closed. Ask the Council to let you in.'
  }
  return message
}
