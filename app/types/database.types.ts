/**
 * Shape of the Supabase schema, matching supabase/migrations/0001..0003.
 *
 * Hand-written so the project typechecks before anyone has a Supabase project
 * to point at. Once yours exists you can replace this file wholesale with
 *
 *   npx supabase gen types typescript --project-id <ref> > app/types/database.types.ts
 *
 * and everything downstream keeps working — @nuxtjs/supabase picks this path up
 * automatically.
 */

type Json = string | number | boolean | null | { [key: string]: Json } | Json[]

export interface Database {
  public: {
    Tables: {
      abilities: {
        Row: { code: string; name: string; sort_order: number }
        Insert: { code: string; name: string; sort_order: number }
        Update: Partial<{ code: string; name: string; sort_order: number }>
        Relationships: []
      }
      classes: {
        Row: {
          id: string
          name: string
          primary_ability: string
          bonus: number
          blurb: string
          sort_order: number
        }
        Insert: {
          id: string
          name: string
          primary_ability: string
          bonus?: number
          blurb: string
          sort_order: number
        }
        Update: Partial<Database['public']['Tables']['classes']['Insert']>
        Relationships: []
      }
      activity_types: {
        Row: {
          id: string
          name: string
          ability_code: string
          points_per_minute: number
          daily_minute_cap: number
          sort_order: number
        }
        Insert: {
          id: string
          name: string
          ability_code: string
          points_per_minute: number
          daily_minute_cap: number
          sort_order?: number
        }
        Update: Partial<Database['public']['Tables']['activity_types']['Insert']>
        Relationships: []
      }
      campaign: {
        Row: {
          id: boolean
          title: string
          subtitle: string
          starts_on: string
          ends_on: string
        }
        Insert: {
          id?: boolean
          title: string
          subtitle: string
          starts_on: string
          ends_on: string
        }
        Update: Partial<Database['public']['Tables']['campaign']['Insert']>
        Relationships: []
      }
      heroes: {
        Row: {
          id: string
          name: string
          slug: string
          class_id: string
          ancestry: string
          portrait_seed: number
          joined_at: string
        }
        Insert: {
          id: string
          name: string
          slug: string
          class_id: string
          ancestry: string
          portrait_seed: number
          joined_at?: string
        }
        Update: Partial<Database['public']['Tables']['heroes']['Insert']>
        Relationships: []
      }
      deeds: {
        Row: {
          id: string
          hero_id: string
          activity_type_id: string
          performed_on: string
          duration_minutes: number
          intensity: string
          note: string | null
          created_at: string
        }
        Insert: {
          id?: string
          hero_id: string
          activity_type_id: string
          performed_on: string
          duration_minutes: number
          intensity?: string
          note?: string | null
          created_at?: string
        }
        Update: Partial<Database['public']['Tables']['deeds']['Insert']>
        Relationships: []
      }
      bosses: {
        Row: {
          id: string
          act: number
          name: string
          title: string
          place: string
          window_starts_on: string
          encounter_on: string
          tested_abilities: string[]
          required_per_hero: Json
          is_final: boolean
          intro: string
          approach_text: string
          victory_text: string
          defeat_text: string
          icon: string
        }
        Insert: Database['public']['Tables']['bosses']['Row']
        Update: Partial<Database['public']['Tables']['bosses']['Row']>
        Relationships: []
      }
      encounters: {
        Row: {
          boss_id: string
          resolved_at: string
          outcome: string
          active_hero_count: number
          party_totals: Json
          required: Json
        }
        Insert: {
          boss_id: string
          resolved_at?: string
          outcome: string
          active_hero_count: number
          party_totals: Json
          required: Json
        }
        Update: Partial<Database['public']['Tables']['encounters']['Insert']>
        Relationships: []
      }
    }
    Views: {
      deed_points: {
        Row: {
          id: string
          hero_id: string
          hero_name: string
          hero_slug: string
          activity_type_id: string
          activity_name: string
          ability_code: string
          performed_on: string
          duration_minutes: number
          intensity: string
          note: string | null
          created_at: string
          points: number
        }
        Relationships: []
      }
      hero_abilities: {
        Row: {
          hero_id: string
          ability_code: string
          points: number
          score: number
        }
        Relationships: []
      }
      party_abilities: {
        Row: {
          ability_code: string
          points: number
          contributing_heroes: number
        }
        Relationships: []
      }
      hero_summary: {
        Row: {
          id: string
          name: string
          slug: string
          ancestry: string
          portrait_seed: number
          joined_at: string
          class_id: string
          class_name: string
          primary_ability: string
          total_points: number
          level: number
          deed_count: number
          last_deed_on: string | null
        }
        Relationships: []
      }
    }
    Functions: {
      ability_score: { Args: { points: number }; Returns: number }
      ability_modifier: { Args: { score: number }; Returns: number }
      hero_level: { Args: { points: number }; Returns: number }
      hero_streak: { Args: { p_hero: string }; Returns: number }
      escaped_burden: { Args: Record<string, never>; Returns: Json }
      project_encounter: { Args: { p_boss_id: string }; Returns: Json }
      resolve_encounter: { Args: { p_boss_id: string }; Returns: Json }
    }
    Enums: Record<string, never>
    CompositeTypes: Record<string, never>
  }
}
