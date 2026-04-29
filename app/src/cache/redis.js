const { createClient } = require("redis");
const env = require("../config/env");

const redisClient = createClient({
  url: `redis://${env.redis.host}:${env.redis.port}`
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

function isRedisConnected() {
  return redisConnected;
}

module.exports = {
  redisClient,
  connectRedis,
  isRedisConnected
};
