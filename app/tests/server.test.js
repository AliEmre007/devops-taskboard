const request = require("supertest");
const app = require("../src/app");
const { pool } = require("../src/db/pool");
const { redisClient } = require("../src/cache/redis");

describe("DevOps TaskBoard API", () => {
  test("GET / should return service information", async () => {
    const response = await request(app).get("/");

    expect(response.statusCode).toBe(200);
    expect(response.body.service).toBe("DevOps TaskBoard API");
    expect(response.body.status).toBe("running");
  });

  test("GET /health should return ok", async () => {
    const response = await request(app).get("/health");

    expect(response.statusCode).toBe(200);
    expect(response.body.status).toBe("ok");
  });

  test("POST /tasks without title should return 400", async () => {
    const response = await request(app).post("/tasks").send({});

    expect(response.statusCode).toBe(400);
    expect(response.body.error).toBe("Task title is required");
  });
});

afterAll(async () => {
  await pool.end();

  if (redisClient.isOpen) {
    await redisClient.quit();
  }
});
