# Allows registration of repeating fixed-interval functions
# Authored by James Lawrence
# Copyright 2013 Sqrt4, All Rights Reserved

class window.Sqrt4.Scheduler
  @granularity: 1000 # Every second by default
  @tasks: {}

  @add: (task) =>
    @tasks[task.name] = task

  @remove: (task) =>
    delete @tasks[@task(task).name]

  @pause: (task, p = true) =>
    @task(task).pause(p)

  @task: (task) =>
    @tasks[if typeof task == 'string' then task else task.name]

  @execute: (task) =>
    task = @task(task)
    task.func()
    task.last_run = new Date().getTime()

  @process: =>
    for name, task of @tasks
      continue if task.paused or new Date().getTime() - task.last_run < task.interval
      @execute(task)
    setTimeout(@process, @granularity)

setTimeout(Sqrt4.Scheduler.process, 0)

class window.Sqrt4.ScheduledTask
  paused: false
  last_run: new Date().getTime()

  pause: (p = true) =>
    @paused = p

  constructor: (@name, @interval, @func) ->