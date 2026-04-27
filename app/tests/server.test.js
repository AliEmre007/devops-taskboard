const request = require("supertest");
const app = require("../src/server");

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

  test("GET /ready should return ready", async () => {
    const response = await request(app).get("/ready");

    expect(response.statusCode).toBe(200);
    expect(response.body.status).toBe("ready");
  });
});

