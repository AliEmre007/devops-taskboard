const express = require("express");
const tasksController = require("../controllers/tasks.controller");

const router = express.Router();

router.get("/", tasksController.listTasks);
router.post("/", tasksController.createTask);

module.exports = router;
