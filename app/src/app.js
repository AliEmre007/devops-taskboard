const express = require("express");
const { pool } = require("./db/pool");
const { redisClient, isRedisConnected } = require("./cache/redis");
const tasksRoutes = require("./routes/tasks.routes");
const errorHandler = require("./middleware/error-handler");
const { metricsMiddleware, metricsHandler } = require("./metrics/prometheus");
const app = express();

app.use(express.json());
app.use(metricsMiddleware);

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

app.get("/ready", async (req, res) => {
  try {
    await pool.query("SELECT 1");

    if (!isRedisConnected()) {
      return res.status(503).json({
        status: "not_ready",
        database: "ok",
        redis: "not_connected"
      });
    }

    await redisClient.ping();

    return res.json({
      status: "ready",
      database: "ok",
      redis: "ok"
    });
  } catch (error) {
    return res.status(503).json({
      status: "not_ready",
      error: error.message
    });
  }
});

app.use("/tasks", tasksRoutes);
app.get("/metrics", metricsHandler);
app.use(errorHandler);

module.exports = app;
