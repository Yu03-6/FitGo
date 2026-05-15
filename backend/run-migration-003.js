const pool = require("./config/database");
const fs = require("fs");
const path = require("path");

async function runMigration() {
  const conn = await pool.getConnection();
  try {
    console.log("Running migration 003: Add username to users table...");

    const migrationSQL = fs.readFileSync(
      path.join(__dirname, "migrations", "003_add_username.sql"),
      "utf8",
    );

    // Split by semicolons and execute each statement
    const statements = migrationSQL
      .split(";")
      .map((s) => s.trim())
      .filter((s) => s.length > 0 && !s.startsWith("--"));

    for (const statement of statements) {
      console.log("Executing:", statement.substring(0, 50) + "...");
      await conn.query(statement);
    }

    console.log("✓ Migration 003 completed successfully");
  } catch (error) {
    console.error("Migration failed:", error);
    throw error;
  } finally {
    conn.release();
    await pool.end();
  }
}

runMigration().catch((err) => {
  console.error("Fatal error:", err);
  process.exit(1);
});
