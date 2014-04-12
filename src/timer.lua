-----------------------------
-- Levak ©2014 --------------
-- http://levak.free.fr/ ----
-- levak92@gmail.com --------
-----------------------------

---------- AnimIt : Timer extension

-- Bootstrap of timer.start
local _tstart = timer.start
function timer.start(ms)
   if not timer.isRunning then
      _tstart(ms)
   end
   timer.isRunning = true
end

-- Bootstrap of timer.stop
local _tstop = timer.stop
function timer.stop()
   timer.isRunning = false
   _tstop()
end

-- Function to call in on.timer
function timer.update(no_stop)
   local j = 1
   while j <= #timer.tasks do -- for each task
      if timer.tasks[j][2]() then -- delete it if has ended
         table.remove(timer.tasks, j)
      else
         j = j + 1
      end
   end

   if not no_stop and #timer.tasks <= 0 then
      timer.stop()
   end
end

---------------------
----- Internals -----
---------------------

timer.tasks = {}
function timer.addTask(object, queueID, task)
   table.insert(timer.tasks, {object, task, queueID})
end

function timer.purgeTasks(object, queueID, complete)
   local j = 1
   while j <= #timer.tasks do
      if timer.tasks[j][1] == object
      and (not queueID or timer.tasks[j][3] == queueID) then
         timer.tasks[j][2](complete)
         table.remove(timer.tasks, j)
      else
         j = j + 1
      end
   end
end
