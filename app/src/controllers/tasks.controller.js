const tasksService = require("../services/tasks.service");

async function listTasks(req, res, next) {
  try {
    const result = await tasksService.getTasks();

    return res.json(result);
  } catch (error) {
    return next(error);
  }
}

async function createTask(req, res, next) {
  try {
    const { title } = req.body;

    if (!title || typeof title !== "string" || title.trim().length === 0) {
      return res.status(400).json({
        error: "Task title is required"
      });
    }

    const task = await tasksService.addTask(title.trim());

    return res.status(201).json(task);
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  listTasks,
  createTask
};

