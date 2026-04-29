require("dotenv").config();

const env = {
  app: {
    port: Number(process.env.APP_PORT || 3000),
    nodeEnv: process.env.NODE_ENV || "development"
  },
  postgres: {
    host: process.env.POSTGRES_HOST || "localhost",
    port: Number(process.env.POSTGRES_PORT || 5432),
    database: process.env.POSTGRES_DB || "taskboard",
    user: process.env.POSTGRES_USER || "taskboard_user",
    password: process.env.POSTGRES_PASSWORD || "taskboard_pass"
  },
  redis: {
    host: process.env.REDIS_HOST || "localhost",
    port: Number(process.env.REDIS_PORT || 6379)
  }
};

module.exports = env;
