require("dotenv").config();

const express = require("express");
const { Pool } = require("pg");
const { createClient } = require("redis");

const app = express();

app.use(express.json());

const PORT = Number(process.env.APP_PORT || 3000);

const pool = new Pool({
  host: process.env.POSTGRES_HOST || "localhost",
  port: Number(process.env.POSTGRES_PORT || 5432),
  database: process.env.POSTGRES_DB || "taskboard",
  user: process.env.POSTGRES_USER || "taskboard_user",
  password: process.env.POSTGRES_PASSWORD || "taskboard_pass"
});

const redisClient = createClient({
  url: `redis://${process.env.REDIS_HOST || "localhost"}:${process.env.REDIS_PORT || 6379}`
});

let redisConnected = false;

redisClient.on("error", (error) => {
  redisConnected = false;
  console.error("Redis error:", error.message);
});

async function connectRedis() {
  try {
    if (!redisClient.isOpen) {
      await redisClient.connect();
    }

    redisConnected = true;
    console.log("Connected to Redis");
  } catch (error) {
    redisConnected = false;
    console.error("Redis connection failed:", error.message);
  }
}

async function initDb() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS tasks (
      id SERIAL PRIMARY KEY,
      title TEXT NOT NULL,
      completed BOOLEAN NOT NULL DEFAULT FALSE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  `);

  console.log("Database initialized");
}

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

    if (!redisConnected) {
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

app.get("/tasks", async (req, res, next) => {
  try {
    if (redisConnected) {
      const cachedTasks = await redisClient.get("tasks");

      if (cachedTasks) {
        return res.json({
          source: "redis-cache",
          data: JSON.parse(cachedTasks)
        });
      }
    }

    const result = await pool.query(
      "SELECT id, title, completed, created_at FROM tasks ORDER BY id DESC"
    );

    if (redisConnected) {
      await redisClient.setEx("tasks", 15, JSON.stringify(result.rows));
    }

    return res.json({
      source: "postgres",
      data: result.rows
    });
  } catch (error) {
    return next(error);
  }
});

app.post("/tasks", async (req, res, next) => {
  try {
    const { title } = req.body;

    if (!title || typeof title !== "string" || title.trim().length === 0) {
      return res.status(400).json({
        error: "Task title is required"
      });
    }

    const result = await pool.query(
      "INSERT INTO tasks (title) VALUES ($1) RETURNING id, title, completed, created_at",
      [title.trim()]
    );

    if (redisConnected) {
      await redisClient.del("tasks");
    }

    return res.status(201).json(result.rows[0]);
  } catch (error) {
    return next(error);
  }
});

app.use((err, req, res, next) => {
  console.error(err);

  return res.status(500).json({
    error: "Internal server error"
  });
});

async function start() {
  await initDb();
  await connectRedis();

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`DevOps TaskBoard API running on port ${PORT}`);
  });
}

if (require.main === module) {
  start().catch((error) => {
    console.error("Application failed to start:", error);
    process.exit(1);
  });
}

module.exports = {
  app,
  pool,
  redisClient
};
