/**
 * Reads SUPABASE_DB_PASSWORD from repo-root .env and runs the Supabase CLI
 * with an explicit -p flag. Some CLI versions still try password-less
 * "cli_login_postgres" unless --password is passed.
 *
 * Usage (from repo root):
 *   node scripts/run-supabase-with-env-password.mjs db push
 *   node scripts/run-supabase-with-env-password.mjs link --project-ref <ref>
 */
import { spawnSync } from 'node:child_process';
import { existsSync, readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, '..');

function loadEnv(filePath) {
  const out = {};
  let raw;
  try {
    raw = readFileSync(filePath, 'utf8');
    if (raw.charCodeAt(0) === 0xfeff) raw = raw.slice(1);
  } catch {
    console.error('Missing .env at repo root.');
    process.exit(1);
  }
  for (const line of raw.split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const eq = trimmed.indexOf('=');
    if (eq <= 0) continue;
    const key = trimmed.slice(0, eq).trim();
    let val = trimmed.slice(eq + 1).trim();
    if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
      val = val.slice(1, -1);
    }
    out[key] = val;
  }
  return out;
}

const argv = process.argv.slice(2);
if (argv.length === 0) {
  console.error('Usage: node scripts/run-supabase-with-env-password.mjs <supabase-args…>');
  process.exit(1);
}

const parsed = loadEnv(join(root, '.env'));
const pwd = parsed.SUPABASE_DB_PASSWORD;
if (!pwd) {
  console.error(
    'Set SUPABASE_DB_PASSWORD in .env (Dashboard → Settings → Database, postgres user).'
  );
  process.exit(1);
}

if (argv.some((a, i) => a === '-p' || a === '--password' || argv[i - 1] === '-p')) {
  console.error('Do not pass -p/--password on the command line; use .env only.');
  process.exit(1);
}

const withPassword = [...argv, '-p', pwd];

/** Prefer real CLI binary; `pnpm`/`.cmd` is unreliable under spawnSync on Windows. */
function resolveSupabaseBin(repoRoot) {
  const binDir = join(repoRoot, 'node_modules', 'supabase', 'bin');
  const win = join(binDir, 'supabase.exe');
  const unix = join(binDir, 'supabase');
  const exe = process.platform === 'win32' ? win : unix;
  if (!existsSync(exe)) {
    console.error('Supabase CLI binary not found at', exe, '— run pnpm install at repo root.');
    process.exit(1);
  }
  return exe;
}

const binPath = resolveSupabaseBin(root);
const result = spawnSync(binPath, withPassword, {
  cwd: root,
  stdio: 'inherit',
  shell: false,
  env: process.env,
});

if (result.error) {
  console.error(result.error.message);
  process.exit(1);
}

process.exit(result.status === null ? 1 : result.status);
