const { pool } = require("../db/pool");

async function findAllTasks() {
  const result = await pool.query(
    "SELECT id, title, completed, created_at FROM tasks ORDER BY id DESC"
  );

  return result.rows;
}

async function createTask(title) {
  const result = await pool.query(
    "INSERT INTO tasks (title) VALUES ($1) RETURNING id, title, completed, created_at",
    [title]
  );

  return result.rows[0];
}

module.exports = {
  findAllTasks,
  createTask
};
