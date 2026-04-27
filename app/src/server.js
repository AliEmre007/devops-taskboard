require("dotenv").config();

const express = require("express");

const app = express();

app.use(express.json());

const PORT = process.env.APP_PORT || 3000;

app.get("/", (req, res) => {
  res.json({
    service: "DevOps TaskBoard API",
    status: "running",
    message: "Welcome to the DevOps TaskBoard project"
  });
});

app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    service: "devops-taskboard-api"
  });
});

app.get("/ready", (req, res) => {
  res.json({
    status: "ready",
    dependencies: {
      database: "not_configured_yet",
      redis: "not_configured_yet"
    }
  });
});

if (require.main === module) {
  app.listen(PORT, "0.0.0.0", () => {
    console.log(`DevOps TaskBoard API running on port ${PORT}`);
  });
}

module.exports = app;
