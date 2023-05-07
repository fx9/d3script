function myprint(msg, name, value)
  if name == nil then
    OutputLogMessage("%s\n", tostring(msg))
    return
  end

  if value == nil then
    OutputLogMessage("%s: %s\n", tostring(msg), tostring(name))
    return
  end

  OutputLogMessage("%s: %s = %s\n", tostring(msg), tostring(name), tostring(value))
end
print = myprint

function func_selector()
  threads_dh_strafe2()
  mouse_move = false
end

DEBUG = false
LOOP_DELAY = 1
function log(msg, name, value)
  if not DEBUG then
    return
  end
  myprint(msg, name, value)
end

function logif(condition, msg, name, value)
  if condition then
    log(msg, name, value)
  end
end

RTime = GetRunningTime

--[[
Profiling result shows that the actions generally complete in <0.01 ms *Running time*
However, some actions may cause waiting time, which is not profilable with GetRunningTime.
Press/release of mouseleft may take up to 0.06 ms actual time.

--]]
--[[
function profile(func)
  myprint("start")
  local startTime = GetRunningTime()
  for i=1,100000 do
    func()
  end
  local endTime = GetRunningTime()
  myprint("100000 cycles average time", (endTime-startTime)/100000.0)
  myprint("startTime", startTime)
  myprint("endTime", endTime)
end

function profileGetRunningTime()
  profile(GetRunningTime)
end

function profileIsOn(mod)
  local function isModOn()
    return isOn(mod)
  end
  profile(isModOn)
end

function profilePress(key)
  local function pressKeyProfiling()
    return press(key)
  end
  profile(pressKeyProfiling)
  release(key)
end

function profileRelease(key)
  local function releaseKeyProfiling()
    return release(key)
  end
  profile(releaseKeyProfiling)
end

--]]

MODIFIER_CHECK_FUNCTIONS = {
  ["shift"] = function() return IsModifierPressed("shift") end,
  ["lshift"] = function() return IsModifierPressed("lshift") end,
  ["rshift"] = function() return IsModifierPressed("rshift") end,
  ["ctrl"] = function() return IsModifierPressed("ctrl") end,
  ["lctrl"] = function() return IsModifierPressed("lctrl") end,
  ["rctrl"] = function() return IsModifierPressed("rctrl") end,
  ["alt"] = function() return IsModifierPressed("alt") end,
  ["lalt"] = function() return IsModifierPressed("lalt") end,
  ["ralt"] = function() return IsModifierPressed("ralt") end,
  ["numlock"] = function() return IsKeyLockOn("numlock") end,
  ["capslock"] = function() return IsKeyLockOn("capslock") end,
  ["scrolllock"] = function() return IsKeyLockOn("scrolllock") end,
  ["mouseleft"] = function() return IsMouseButtonPressed(1) end,
  ["mousemid"] = function() return IsMouseButtonPressed(2) end,
  ["mouseright"] = function() return IsMouseButtonPressed(3) end,
  ["mouse4"] = function() return IsMouseButtonPressed(4) end,
  ["mouse5"] = function() return IsMouseButtonPressed(5) end,
}

MOUSE_KEYS = {
  ["mouseleft"] = 1,
  ["mousemid"] = 2,
  ["mouseright"] = 3,
  ["mouse4"] = 4,
  ["mouse5"] = 5,
}

MOUSE_WHEELS = {
  ["mousewheelup"] = 1,
  ["mousewheeldown"] = -1,
}

LOCK_KEYS = {
  ["scrolllock"] = 1,
  ["capslock"] = 1,
  ["numlock"] = 1,
}

MODIFIER_ON_CACHE = {}

function isOnCached(flag)
  if MODIFIER_ON_CACHE[flag] == nil then
    MODIFIER_ON_CACHE[flag] = isOn(flag)
  end
  return MODIFIER_ON_CACHE[flag]
end

function isOffCached(flag)
  return not isOnCached(flag)
end

function isOn(flag)
  return MODIFIER_CHECK_FUNCTIONS[flag]()
end

function isOff(flag)
  return not isOn(flag)
end

function release(key)
  log("release", key, RTime())
  if MOUSE_KEYS[key] ~= nil then
    ReleaseMouseButton(MOUSE_KEYS[key])
  elseif MOUSE_WHEELS[key] == nil then
    ReleaseKey(key)
  end
end

function press(key)
  log("press", key, RTime())
  if MOUSE_KEYS[key] ~= nil then
    PressMouseButton(MOUSE_KEYS[key])
  elseif MOUSE_WHEELS[key] ~= nil then
    MoveMouseWheel(MOUSE_WHEELS[key])
  else
    PressKey(key)
  end
end

function click(target)
  log("click", target, RTime())
  if type(target) == "string" then
    -- key
    local key = target
    if MOUSE_KEYS[key] ~= nil then
      PressAndReleaseMouseButton(MOUSE_KEYS[key])
    elseif MOUSE_WHEELS[key] ~= nil then
      MoveMouseWheel(MOUSE_WHEELS[key])
    elseif key == "" then
      -- do nothing
    else
      PressAndReleaseKey(key)
    end
  else
    -- function
    target()
  end
end

function setOn(key)
  if LOCK_KEYS[key] ~= nil then
    if isOff(key) then
      click(key)
    end
  else
    release(key)
    press(key)
  end
end

function setOff(key)
  if LOCK_KEYS[key] ~= nil then
    if isOn(key) then
      click(key)
    end
  else
    release(key)
  end
end

Resource = {
  program = nil,
  onRelease = nil, -- func() to call on resource release.
}

function Resource:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Resource:removeOwner()
  if self.onRelease ~= nil then
    self.onRelease()
  end
  self.onRelease = nil
  self.program = nil
end

function Resource:isOwnedBy(program)
  return self.program == program
end

function Resource:isFree()
  return self.program == nil
end

function Resource:acquire(program, onRelease)
  if self:canAcquire(program) then
    if self.program ~= program then
      self:removeOwner()
    end
    self.program = program
    self.onRelease = onRelease
    return true
  end
  return false
end

function Resource:canAcquire(program)
  return self:isFree() or self:isOwnedBy(program) or self.program.priority < program.priority
end

function doNothing(...)
end

CdClick = {
  name = "",
  priority = 0,
  key = "",
  resources = {},
  cycleTime = 0, -- total intended time of a cd-press-release cycle. if set to -1, the click will execute only once.
  holdTime = 0, -- hold key for this time, and then release. if set to -1, it will attempt to hold infinitely.

  pressFunc = press, -- func(key) to press
  releaseFunc = release, -- func(key) to release. will be called on destroy/disable

  isEnabledFunc = nil, -- func() returns bool to determine whether it's enabled. nil to skip the whole isEnabled handling
  isEnabled = true,
  onEnabledFunc = doNothing, -- func(self) to execute when enabled.
  onDisabledFunc = doNothing, -- func(self) to execute when disabled.

  firstCycleOffset = 0, -- <=0: start first cycle immediately; >0: start first cycle X ms after init
  align = 0, -- alignment of every cycle. 0: unaligned; >0: align to the next point; <0: align to the previous point
  cycleStartsFromAcquire = false, -- if true, cycles start at when it first attempt to acquire resources (by default, cycles start from when the key is pressed).

  startTs = 0, -- timestamp when the current cycle starts
  pressTs = 0, -- timestamp when the key was recently pressed. Should remain -1 if the key is not being pressed
  clickDone = false, -- true if the press-release is done without interruption in the cycle.

  onEnabledClosure = nil, -- func() to execute when enabled - this will include onEnabledFunc
  onDisabledClosure = nil, -- func() to execute when disabled - this will include onDisabledFunc
  co = nil, -- coroutine to resume
}

function alwaysTrue()
  return true
end

function edgeTrigger(oldVal, newVal, upFunc, downFunc)
  if oldVal ~= newVal then
    if newVal then
      upFunc()
    else
      downFunc()
    end
  end
  return newVal
end

function alignedTs(oldTs, newTs, align)
  local timeDiff = newTs - oldTs
  if align == 0 or align == nil then
    return newTs
  elseif align > 0 then
    local lignedTs = newTs - timeDiff % align
    if alignedTs < newTs then
      alignedTs = alignedTs + align
    end
    return alignedTs
  else
    return newTs - timeDiff % (-align)
  end
end

function CdClick:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function CdClick:AddResource(r)
  table.insert(self.resources, r)
  return self
end

function CdClick:Set(name, value)
  self[name] = value
  return self
end

function CdClick:cdIsDone()
  return self.cycleTime ~= -1 and RTime() - self.startTs >= self.cycleTime
end

function CdClick:holdIsDone()
  if self.holdTime == -1 then
    return false
  end

  if RTime() - self.pressTs < self.holdTime then
    return false
  end

  return true
end

function CdClick:haveAllResources()
  for i, rsc in ipairs(self.resources) do
    if not rsc:isOwnedBy(self) then
      return false
    end
  end
  return true
end

function CdClick:acquireAllResources()
  --log("acquireAllResources", self.key)
  for i, rsc in ipairs(self.resources) do
    if not rsc:canAcquire(self) then
      return false
    end
  end

  local function onResourceRelease()
    if self:pressed() then
      if self:holdIsDone() then
        self.clickDone = true
      end
      self:releaseKey()
    end
  end

  for i, rsc in ipairs(self.resources) do
    rsc:acquire(self, onResourceRelease)
  end
  return true
end

function CdClick:pressKey()
  -- log("pressKey", "key", self.key)
  self.pressFunc(self.key)
  self.pressTs = RTime()
  -- log("pressKey", "pressTs", self.pressTs)
  --logif(self.key == "4", "pressTs", self.pressTs)
  if not self.cycleStartsFromAcquire then
    self.startTs = alignedTs(self.startTs, self.pressTs, self.align)
  end
end

function CdClick:pressed()
  return self.pressTs ~= -1
end

function CdClick:releaseKey()
  -- log("releaseKey", "key", self.key)
  self.releaseFunc(self.key)
  self.pressTs = -1
end

function CdClick:releaseResources()
  --log("releaseResources", self.key)
  for i, rsc in ipairs(self.resources) do
    if rsc:isOwnedBy(self) then
      rsc:removeOwner()
    end
  end
end

function CdClick:Reset()
  self.pressTs = -1
  self.clickDone = true -- ready to start next cycle
  self.startTs = RTime() - self.cycleTime + self.firstCycleOffset
  -- self.co = coroutine.create(function()
  --   while true do
  --     self:operate()
  --     coroutine.yield()
  --   end
  -- end)
end

function CdClick:Init()
  self:Reset()
  self.onEnabledClosure = function()
    -- logif(self.key=="backslash","enabled","time",RTime())
    self:Reset()
    self:onEnabledFunc()
  end
  self.onDisabledClosure = function()
    -- logif(self.key=="backslash","disabled","time",RTime())
    self:onDisabledFunc()
    self:Cleanup()
  end
end

function CdClick:operate()
  if self.isEnabledFunc ~= nil then
    self.isEnabled = edgeTrigger(self.isEnabled, self.isEnabledFunc(), self.onEnabledClosure, self.onDisabledClosure)
    if not self.isEnabled then
      return
    end
  end

  --log(self.key, self.pressTs)
  if not self:pressed() then
    -- not pressed, either before or after click
    --log("clickDone", self.clickDone)
    if self.clickDone then
      -- after click
      if not self:cdIsDone() then
        -- should not start next cycle, nothing to do
        return
      end
      -- start next cycle
      self.clickDone = false
      if self.cycleStartsFromAcquire then
        self.startTs = alignedTs(self.startTs, RTime(), self.align)
      end
      -- now it's before click, keep going
    end

    --log("before click")
    -- before click
    if self:acquireAllResources() then
      -- got all resources, press key
      self:pressKey()
    else
      -- else no resources acquired, nothing to do
      return
    end
  end
  -- key pressed
  --log("holdTime", self.holdTime)
  --log("pressTs", self.pressTs)
  if self:holdIsDone() then
    self.clickDone = true
    self:releaseKey()
    self:releaseResources()
  end
end

function CdClick:Resume()
  self:operate()
  -- coroutine.resume(self.co)
end

function CdClick:Cleanup()
  self:releaseKey()
  self:releaseResources()
  -- self.co = nil
end

function updateModCache()
  for mod, value in pairs(MODIFIER_ON_CACHE) do
    MODIFIER_ON_CACHE[mod] = isOn(mod)
  end
end

function runPrograms(actions)
  cachedMods = cachedMods or {}

  for i, p in ipairs(actions) do
    p:Init()
  end

  while true do
    Sleep(LOOP_DELAY)
    updateModCache()

    for i, action in ipairs(actions) do
      action:Resume()
    end

    if isOff("scrolllock") then
      break
    end
  end

  for i, p in ipairs(actions) do
    p:Cleanup()
  end
end

function runWithInsertedNoActions(actions, noActions, actionResource)
  cachedMods = cachedMods or {}

  for i, p in ipairs(actions) do
    p:Init()
  end
  for i, p in ipairs(noActions) do
    p:Init()
  end

  local noActionsExecuted = false
  while true do
    Sleep(LOOP_DELAY)
    updateModCache()

    noActionsExecuted = false
    for i, action in ipairs(actions) do
      if not noActionsExecuted and actionResource:isFree() then
        for j, noAction in ipairs(noActions) do
          noAction:Resume()
        end
        noActionsExecuted = true
      end
      action:Resume()
    end

    if not noActionsExecuted then
      for j, noAction in ipairs(noActions) do
        noAction:Resume()
      end
    end

    if isOff("scrolllock") then
      break
    end
  end

  for i, p in ipairs(actions) do
    p:Cleanup()
  end
  for i, p in ipairs(noActions) do
    p:Cleanup()
  end
end

ProgramRunner = {
  commonResources = {},
  programs = {},
}

function ProgramRunner:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function ProgramRunner:AddCommonResource(r)
  r = r or Resource:new()
  table.insert(self.commonResources, r)
  return r
end

-- function ProgramRunner:HasResource(r)
--   for i, rsc in ipairs(self.commonResources) do
--     if rsc == r then
--       return true
--     end
--   end
--   return false
-- end

function ProgramRunner:Add(p)
  p = p or {}
  local resources = p.resources
  p = CdClick:new(p)
  table.insert(self.programs, p)
  if resources == nil then
    for i, rsc in ipairs(self.commonResources) do
      p:AddResource(rsc)
    end
  end
  return p
end

function ProgramRunner:AddHoldKey(p)
  p = self:Add(p)
  p.holdTime = -1
  return p
end

function ProgramRunner:AddNoAction(p)
  p = self:Add(p)
  p.holdTime = 0
  p.pressFunc = click
  p.releaseFunc = doNothing
  return p
end

function ProgramRunner:AddEdgeTrigger(isEnabledFunc, upFunc, downFunc)
  local p = self:Add()
  p.holdTime = -1

  p.pressFunc = doNothing
  p.releaseFunc = doNothing

  p.isEnabledFunc = isEnabledFunc
  p.isEnabled = not isEnabledFunc() -- use flipped isEnabled to ensure upFunc/downFunc called immediately
  p.onEnabledFunc = upFunc
  p.onDisabledFunc = downFunc
  return p
end

function ProgramRunner:AddModEdgeTrigger(mod, upFunc, downFunc)
  local p = self:AddEdgeTrigger(ModIsOn(mod), upFunc, downFunc)
  return p
end

function ProgramRunner:AddModEdgeTriggerChached(mod, upFunc, downFunc)
  local p = self:AddEdgeTrigger(ModIsOnCached(mod), upFunc, downFunc)
  return p
end

function ProgramRunner:run()
  runPrograms(self.programs)
end

function ModIsOn(mod)
  local function func()
    return isOn(mod)
  end
  return func
end

function ModIsOff(mod)
  local function func()
    return isOff(mod)
  end
  return func
end

function ModIsOnCached(mod)
  local function func()
    return isOnCached(mod)
  end
  return func
end

function ModIsOffCached(mod)
  local function func()
    return isOffCached(mod)
  end
  return func
end

function ModOnCacheMatchesMap(modOnMap)
  local function func()
    for mod, on in pairs(modOnMap) do
      if isOnCached(mod) ~= on then
        return false
      end
    end
    return true
  end
  return func
end

function releaseAndPressML(replaceKey)
  local lshiftOn = false
  if isOn("lshift") then
    lshiftOn = true
    release("lshift")
  end
  release(replaceKey)
  release("mouseleft")
  press(replaceKey)
  if lshiftOn then
    press("lshift")
  end
  press("mouseleft")
  Sleep(1)
end

function threads_dh_strafe2()
  local runner = ProgramRunner:new()
  local action = runner:AddCommonResource()

  local low = 0
  local high = 10
  local interrupt = 100

  local enabled = true
  local function disabledWhenMoving()
    return enabled
  end

  local click2 = runner:AddNoAction { key = "2", cycleTime = 4200, }
  local click4 = runner:AddNoAction { key = "4", cycleTime = 500, align = -500, }
  local clickMR = runner:AddNoAction { key = "mouseright", cycleTime = 500, }
  local clickQ = runner:AddNoAction { key = "q", cycleTime = 500, }

  local replaceML = runner:AddNoAction {
    key = "q",
    cycleTime = 500,

    pressFunc = releaseAndPressML,

    isEnabledFunc = ModIsOn("mouseleft"),
    onEnabledFunc = function(self)
      log("replaceML enabled")
      enabled = false
    end,

    onDisabledFunc = function(self)
      log("replaceML disabled")
      release(self.key)
      enabled = true
    end,
  }

  local press1Time = 340
  local press1MoreTime = 2300
  local press3Time = 200
  local total13Time = press1MoreTime + press3Time

  local press1 = runner:Add {
    priority = 1,
    key = "1",
    cycleTime = total13Time,
    holdTime = press1MoreTime,

    firstCycleOffset = 100,
    isEnabledFunc = disabledWhenMoving,
  }

  local press3 = runner:Add {
    priority = high,
    key = "3",
    cycleTime = total13Time,
    holdTime = press3Time,

    firstCycleOffset = 100,
    isEnabledFunc = disabledWhenMoving,
    pressFunc = function(key)
      press("3")
      press("lshift")
    end,
    releaseFunc = function(key)
      release("3")
      if enabled then
        click("mouseleft")
      end
      release("lshift")
    end,
  }

  local function press1More()
    press1.holdTime = press1MoreTime
    press1.cycleTime = press3Time + press1MoreTime
    press3.cycleTime = press3Time + press1MoreTime
    press1:Init()
    press3:Init()
  end

  local function press1Less()
    press1.holdTime = press1Time
    press1.cycleTime = press3Time + press1Time
    press3.cycleTime = press3Time + press1Time
  end

  local speedControl = runner:AddModEdgeTriggerChached("capslock", press1Less, press1More)

  runner:run()
end

last_release_switch = -1
function OnEvent(event, arg)
  OutputLogMessage("event = %s, arg = %s\n", event, arg)
  --OutputLogMessage("time = %s event = %s, arg = %s\n", GetRunningTime(), event, arg)
  MODIFIER_ON_CACHE = {}

  local funcs = {
    [8] = func_selector,
    [6] = func_selector,
  }
  if (funcs[arg] ~= nil) then
    if (event == "MOUSE_BUTTON_PRESSED") then
      if GetRunningTime() - last_release_switch <= 5 then
        return
      end
      funcs[arg]()
    end
    if (event == "MOUSE_BUTTON_RELEASED") then
      last_release_switch = GetRunningTime()
    end
  end
end