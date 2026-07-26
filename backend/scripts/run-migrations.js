/**
 * Applies every SQL file in supabase/migrations (in filename order) against
 * the database at DATABASE_URL, tracking what's already been applied in a
 * schema_migrations table so re-running this script is a no-op for files
 * it has already run. Seed files under supabase/seed are applied only when
 * --seed is passed, since they shouldn't run against a database that
 * already has real data.
 */
const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

const MIGRATIONS_DIR = path.join(__dirname, '..', '..', 'supabase', 'migrations');
const SEED_DIR = path.join(__dirname, '..', '..', 'supabase', 'seed');

async function run() {
  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) {
    console.error('DATABASE_URL is required, e.g.:');
    console.error('  postgresql://postgres:<password>@db.<project-ref>.supabase.co:5432/postgres');
    process.exit(1);
  }

  const client = new Client({ connectionString, ssl: { rejectUnauthorized: false } });
  await client.connect();

  try {
    await client.query(`
      create table if not exists schema_migrations (
        filename text primary key,
        applied_at timestamptz not null default now()
      );
    `);

    const { rows: appliedRows } = await client.query('select filename from schema_migrations');
    const applied = new Set(appliedRows.map((r) => r.filename));

    const migrationFiles = fs.readdirSync(MIGRATIONS_DIR).filter((f) => f.endsWith('.sql')).sort();

    for (const file of migrationFiles) {
      if (applied.has(file)) {
        console.log(`skip  ${file} (already applied)`);
        continue;
      }
      const sql = fs.readFileSync(path.join(MIGRATIONS_DIR, file), 'utf8');
      console.log(`apply ${file}`);
      await client.query('begin');
      try {
        await client.query(sql);
        await client.query('insert into schema_migrations (filename) values ($1)', [file]);
        await client.query('commit');
      } catch (err) {
        await client.query('rollback');
        throw new Error(`Migration ${file} failed: ${err.message}`);
      }
    }

    if (process.argv.includes('--seed')) {
      const seedFiles = fs.readdirSync(SEED_DIR).filter((f) => f.endsWith('.sql')).sort();
      for (const file of seedFiles) {
        const sql = fs.readFileSync(path.join(SEED_DIR, file), 'utf8');
        console.log(`seed  ${file}`);
        await client.query(sql);
      }
    }

    console.log('Done.');
  } finally {
    await client.end();
  }
}

run().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
