const fs = require("fs");
const path = require("path");
const pool = require("./config/database");

async function runMigrations() {
  const migrationFile = path.join(
    __dirname,
    "migrations/001_add_verification_fields.sql",
  );

  try {
    // Read the migration file
    const sql = fs.readFileSync(migrationFile, "utf-8");

    // Get a connection
    const conn = await pool.getConnection();

    try {
      // Split SQL statements and execute them
      const statements = sql
        .split(";")
        .map((stmt) => stmt.trim())
        .filter((stmt) => stmt.length > 0 && !stmt.startsWith("--"));

      for (const statement of statements) {
        console.log(`Executing: ${statement.substring(0, 50)}...`);
        try {
          await conn.query(statement);
          console.log("Executed successfully");
        } catch (err) {
          // Ignore column already exists errors
          if (
            err.message.includes("Duplicate column") ||
            err.code === "ER_DUP_FIELDNAME"
          ) {
            console.log("Column already exists, skipping");
          } else {
            throw err;
          }
        }
      }

      console.log("Database migration successful!");
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Migration failed:", error.message);
    console.error("Details:", error);
    process.exit(1);
  }
}

runMigrations();
