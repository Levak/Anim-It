-----------------------------
-- Levak ©2014 --------------
-- http://levak.free.fr/ ----
-- levak92@gmail.com --------
-----------------------------

---------- AnimIt : Animable Object class

Object = class()
----- Simply give a table that indicates
----- the animatedvariables and their initial values
function Object:init(animable)
   self.tasks = {{}}
   self.visible = true

   for k, v in pairs(animable) do
      self[k] = v or 0
   end
end

-- Paint method to override if needed
function Object:paint(gc) end

-- Stop all tasks from queue queueID (if given, else all queues)
-- without calling callbacks. Current animations are stranded.
function Object:Stop(queueID)
   self:__Stop(queueID)
   return self
end

-- Demand the scheduler to finishes all tasks from queue
-- queueID (if given, else all queues). This method ensure
-- calling task callbacks.
function Object:Complete(queueID)
   self:__Stop(queueID, true)
   return self
end

-- Animate an object property in ms milliseconds on queue
-- queueID (if given). When the animation terminates,
-- call callback if given.
function Object:Animate(t, ms, callback, queueID)
   self:__PushTask(self.__Animate, t, ms, callback, queueID)
   return self
end

-- Wait on an object ms milliseconds on queue queueID (if given).
-- When the animation terminates, call callback if given.
function Object:Delay(ms, callback, queueID)
   self:__PushTask(self.__Delay, false, ms, callback, queueID)
   return self
end

-- Set the object visible or not on queue queueID (if given).
function Object:setVisible(t, queueID)
   self:__PushTask(self.__setVisible, t, 1, false, queueID)
   return self
end

---------------------
----- Internals -----
---------------------

function Object:__PushTask(task, t, ms, callback, queueID)
   queueID = queueID or 1
   timer.start(0.01)
   if not self.tasks[queueID] then self.tasks[queueID] = {} end
   table.insert(self.tasks[queueID], {task, t, ms, callback, queueID})
   if #self.tasks[queueID] == 1 then
      local ok = task(self, t, ms, callback, queueID)
      if not ok then table.remove(self.tasks[queueID], 1) end
   end
end

function Object:__PopTask(queueID)
   queueID = queueID or 1
   table.remove(self.tasks[queueID], 1)
   if #self.tasks[queueID] > 0 then
      local task, t, ms, callback, queueID = unpack(self.tasks[queueID][1])
      local ok = task(self, t, ms, callback, queueID)
      if not ok then self:__PopTask(queueID) end
   end
end

function Object:__Stop(queueID, complete)
   timer.purgeTasks(self, queueID, complete)

   if queueID then
      for j=1, #self.tasks[queueID] do
         self.tasks[queueID][j] = nil
      end
      self.tasks[queueID] = {}
   else
      for i=1, #self.tasks do
         for j=1, #self.tasks[i] do
            self.tasks[i][j] = nil
         end
         self.tasks[i] = nil
      end
      self.tasks = {{}}
   end

--   collectgarbage()
   return self
end

function Object:__initVar(t, k, ms)
   if not t[k] then t[k] = self[k] end
   local inc = (t[k] - self[k]) / ms
   local side = inc >= 0 and 1 or -1
   t[k] = { target=t[k], inc=inc, side=side, done=false }
end

function Object:__Animate(t, ms, callback, queueID)
   if not ms then ms = 50 end
   if ms < 0 then print("Error: Invalid time divisor (must be >= 0)") return end
   ms = ms / timer.multiplier
   if ms == 0 then ms = 1 end
   if not t or type(t) ~= "table" then print("Error: Target position is "..type(t)) return end
   for k, _ in pairs(t) do
      self:__initVar(t, k, ms)
   end
   timer.addTask(self, queueID, function(complete)
                    local b = true
                    if complete then
                       for k, v in pairs(t) do
                          self[k] = v.target
                          v.done = true
                       end
                    else
                       for k, v in pairs(t) do
                          local s = self[k]
                          if not v.done then
                             local final = s + v.inc
                             if final * v.side < v.target * v.side then
                                self[k] = final
                                b = false
                             else
                                self[k] = v.target
                                v.done = true
                             end
                          end
                       end
                    end
                    if b then
                       self:__PopTask(queueID)
                       if callback then callback(self) end
                       return true
                    end
                    return false
   end)
   return true
end

function Object:__Delay(_, ms, callback, queueID)
   if not ms then ms = 50 end
   if ms < 0 then print("Error: Invalid time divisor (must be >= 0)") return end
   ms = ms / timer.multiplier
   if ms == 0 then ms = 1 end
   local t = 0
   timer.addTask(self, queueID, function(complete)
                    if not complete and t < ms then
                       t = t + 1
                       return false
                    else
                       self:__PopTask(queueID)
                       if callback then callback(self) end
                       return true
                    end
   end)
   return true
end

function Object:__setVisible(t, _, _, queueID)
   timer.addTask(self, queueID, function(complete)
                    self.visible = t
                    self:__PopTask(queueID)
                    return true
   end)
   return true
end
