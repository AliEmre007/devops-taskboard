const { Pool } = require("pg");
const env = require("../config/env");

const pool = new Pool({
  host: env.postgres.host,
  port: env.postgres.port,
  database: env.postgres.database,
  user: env.postgres.user,
  password: env.postgres.password
});

module.exports = {
  pool
};
