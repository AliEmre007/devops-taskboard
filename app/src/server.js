const app = require("./app");
const env = require("./config/env");
const { initDb } = require("./db/pool");
const { connectRedis } = require("./cache/redis");

async function start() {
  await initDb();
  await connectRedis();

  app.listen(env.app.port, "0.0.0.0", () => {
    console.log(`DevOps TaskBoard API running on port ${env.app.port}`);
  });
}

if (require.main === module) {
  start().catch((error) => {
    console.error("Application failed to start:", error);
    process.exit(1);
  });
}

module.exports = {
  start
};
