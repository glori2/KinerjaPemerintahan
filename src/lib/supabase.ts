import { createClient } from '@supabase/supabase-js';

// Build-safe: during Next.js static generation on Vercel, env vars may not
// be present. Fallback to empty strings so the module loads without crashing.
// At browser runtime the real values are injected by Next.js automatically.
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL ?? '';
const supabasePublishableKey =
  process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY ||
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ||
  '';

export const supabase = createClient(supabaseUrl, supabasePublishableKey);
