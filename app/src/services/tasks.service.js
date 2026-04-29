const tasksRepository = require("../repositories/tasks.repository");
const { redisClient, isRedisConnected } = require("../cache/redis");

const TASKS_CACHE_KEY = "tasks";

async function getTasks() {
  if (isRedisConnected()) {
    const cachedTasks = await redisClient.get(TASKS_CACHE_KEY);

    if (cachedTasks) {
      return {
        source: "redis-cache",
        data: JSON.parse(cachedTasks)
      };
    }
  }

  const tasks = await tasksRepository.findAllTasks();

  if (isRedisConnected()) {
    await redisClient.setEx(TASKS_CACHE_KEY, 15, JSON.stringify(tasks));
  }

  return {
    source: "postgres",
    data: tasks
  };
}

async function addTask(title) {
  const task = await tasksRepository.createTask(title);

  if (isRedisConnected()) {
    await redisClient.del(TASKS_CACHE_KEY);
  }

  return task;
}

module.exports = {
  getTasks,
  addTask
};
