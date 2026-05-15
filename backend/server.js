process.stdout.write("Starting backend...\n");

const app = require("./app");
process.stdout.write("App module loaded successfully\n");

require("dotenv").config();
process.stdout.write(".env file loaded successfully\n");

const PORT = process.env.PORT || 3000;
process.stdout.write(`Port configured: ${PORT}\n`);

try {
  const server = app.listen(PORT,"0.0.0.0");

  server.on("listening", () => {
    process.stdout.write(`FitGo Backend running on port ${PORT}\n`);
    process.stdout.write(`Environment: ${process.env.NODE_ENV}\n`);
    process.stdout.write("Server is ready, accepting connections\n\n");
    process.stdout.write(`Server listening on port ${PORT}\n`);
  });

  // Handle server errors
  server.on("error", (err) => {
    process.stderr.write(`Server error: ${err.message}\n`);
    if (err.code === "EADDRINUSE") {
      process.stderr.write(`Port ${PORT} is already in use\n`);
    } else if (err.code === "EACCES") {
      process.stderr.write(`Permission denied to access port ${PORT}\n`);
    }
    process.exit(1);
  });

  // Catch unhandled errors
  process.on("uncaughtException", (err) => {
    process.stderr.write(`Unhandled exception: ${err.message}\n`);
    process.exit(1);
  });

  process.on("unhandledRejection", (reason) => {
    process.stderr.write(`Unhandled rejection: ${reason}\n`);
    process.exit(1);
  });
} catch (err) {
  process.stderr.write(`Startup failed: ${err.message}\n`);
  process.exit(1);
}
