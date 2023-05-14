OLM = OutputLogMessage
function myprintT(msg, logTable)
  OLM("%s: {", tostring(msg))
  for k, v in pairs(logTable) do OLM("%s = %s, ", tostring(k), tostring(v)) end
  OLM("}\n")
end
function myprint(msg, arg1, arg2)
  if type(arg1) == "table" then return myprintT(msg, arg1) end
  if arg2 ~= nil then return OLM("%s: %s = %s\n", tostring(msg), tostring(arg1), tostring(arg2)) end
  if arg1 ~= nil then return OLM("%s: %s\n", tostring(msg), tostring(arg1)) end
  OLM("%s\n", tostring(msg))
end
IN_PROD = (PlayMacro ~= nil)
print = myprint

DEBUG = false
LOOP_DELAY = 1
function log(msg, name, value) return DEBUG and myprint(msg, name, value) end
function logif(condition, msg, name, value) return condition and log(msg, name, value) end

function func_selector()
  --threads_dh_strafe2()
  --threads_test()
  --testSubAction()
  threads_wiz_meteor()
  mouse_move = false
end

function threads_test()
end

function sleepExact(ms)
  local s = GetRunningTime()
  if ms > 200 then
    Sleep(ms / 2)
    sleepExact(ms - (GetRunningTime() - s))
    return
  end
  local t = 0
  while true do
    t = GetRunningTime()
    if ms - (t - s) < 15 then
      while ms - (t - s) > 0 do
        t = GetRunningTime()
      end
      return
    end
    Sleep(1)
  end
end

RTime = GetRunningTime
GETTIME_PER_MS = 2010
MS_PER_SLEEP = 15.3
function timeProfiling()
  local t = RTime()
  local i = 0
  while t == RTime() do i = i + 1 end
  -- now it's beginning of a millisecond
  t = RTime()
  i = 0
  local loops = 1
  while t + loops > RTime() do i = i + 1 end
  GETTIME_PER_MS = i / loops
  myprint("GETTIME_PER_MS", GETTIME_PER_MS)

  local sleeps = 10
  local start = RTime()
  for _ = 1, sleeps do
    Sleep(1)
  end
  MS_PER_SLEEP = (RTime() - start) / sleeps
  myprint("MS_PER_SLEEP", MS_PER_SLEEP)
end

--[[
Profiling result shows that the actions generally complete in <0.01 ms *Running time*
However, some actions may cause waiting time, which is not profile-able with GetRunningTime.
Press/release of mouseleft may take up to 0.06 ms actual time.
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

---- cooldown click functions ----

keyTimes = {}
function lastKeyTime(key)
  local lastTs = keyTimes[key]
  if (lastTs == nil) then
    -- return a large negative number to prevent cooldown
    return -10000000
  end
  return lastTs
end

function cdClick(key, cd, align, clickFunc)
  -- align: 0, nil: unaligned; >0: align to the next point; <0: align to the previous point

  clickFunc = clickFunc or click

  -- prioritize align in cd = {cd, align}
  if type(cd) == "table" then
    align = cd[2]
    cd = cd[1]
  elseif align == nil then
    align = 0
  end

  local prevTs = lastKeyTime(key)
  local currTs = RTime()
  -- adjust prevTs so it works with align correctly
  if prevTs < 0 then
    prevTs = currTs - cd
  end

  if currTs - prevTs >= cd then
    if not clickFunc(key) then
      return false
    end
    currTs = alignedTs(prevTs, currTs, align)
    keyTimes[key] = currTs
    return true
  else
    return false
  end
end

function checkCd(key, cd)
  return RTime() - last_key_time(key) >= cd
end

---- isOn functions ----

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

--- click functions ---

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
    clickMW(key)
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
      return clickMW(key)
    elseif key == "" then
      -- do nothing
    else
      PressAndReleaseKey(key)
    end
  else
    -- function
    target()
  end
  return true
end

MIN_MOUSEWHEEL_INTERVAL = 100
lastMW = -MIN_MOUSEWHEEL_INTERVAL
function clickMW(key)
  local code = MOUSE_WHEELS[key]
  local t = RTime()
  if t - lastMW < MIN_MOUSEWHEEL_INTERVAL then
    return false
  end
  MoveMouseWheel(code)
  lastMW = t
  return true
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

-- avoid functions
GLOBAL_AVOID_MAP = {}

function globallyAvoid(key_or_func)
  if GLOBAL_AVOID_MAP[key_or_func] == nil then
    GLOBAL_AVOID_MAP[key_or_func] = 0
  end
  GLOBAL_AVOID_MAP[key_or_func] = GLOBAL_AVOID_MAP[key_or_func] + 1
end

function globallyUnavoid(key_or_func)
  if GLOBAL_AVOID_MAP[key_or_func] ~= nil then
    GLOBAL_AVOID_MAP[key_or_func] = GLOBAL_AVOID_MAP[key_or_func] - 1
    if GLOBAL_AVOID_MAP[key_or_func] == 0 then
      GLOBAL_AVOID_MAP[key_or_func] = nil
    end
  end
end

function clickAvoid(key_or_func)
  if GLOBAL_AVOID_MAP[key_or_func] then
    return false
  end
  return click(key_or_func)
end

-- classes

Resource = {
  name = "",
  blocked = false,
  program = nil,
  onRelease = nil, -- func() to call on resource release.
}

function Resource:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Resource:block()
  if self.blocked then return end
  self:removeOwner()
  self.blocked = true
end

function Resource:unblock()
  self.blocked = false
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
  return (not self.blocked) and (self.program == nil or self:isOwnedBy(program) or self.program.priority < program.priority)
end

function doNothing(...)
end

CdAction = {
  name = "",
  priority = 0,
  key = "",
  resources = {},
  cycleTime = 0, -- total intended time of a cd-press-release cycle.
  holdTime = 0, -- hold key for this time, and then release. if set to -1, it will attempt to hold infinitely.
  onlyOnce = false, -- if true, only execute the action once.
  subActions = {}, -- subActions is a list of CdAction following special rules.
  -- subActions start in sequence after pressFunc is executed.
  -- A subAction must not acquire the resource of its parent action, or it will cause a deadlock.
  -- A subAction doesn't need to ensure its releaseFunc properly cleaning up its status.
  -- When using subActions,
  --   releaseFunc will not be called when holdTime is reached, until all remaining subActions are executed.
  --   releaseFunc must ensure cleaning up status caused by subActions.
  currentSubActionIndex = 0, -- index is 1-based; 0 means the first subAction needs initialization.

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
  started = false, -- whether the program has started

  onEnabledClosure = nil, -- func() to execute when enabled - this will include onEnabledFunc
  onDisabledClosure = nil, -- func() to execute when disabled - this will include onDisabledFunc
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
    local overTime = timeDiff % align
    if overTime == 0 then
      return newTs
    end
    return newTs - overTime + align
  else
    return newTs - timeDiff % (-align)
  end
end

function CdAction:new(o)
  o = o or {}
  o.resources = o.resources or {}
  o.subActions = o.subActions or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function CdAction:AddResource(r)
  for i, rsc in ipairs(self.resources) do
    if rsc == r then
      return self
    end
  end
  table.insert(self.resources, r)
  return self
end

function CdAction:cdIsDone()
  return RTime() - self.startTs >= self.cycleTime
end

function CdAction:holdIsDone()
  return self.holdTime ~= -1 and self:subActionsAreDone() and RTime() - self.pressTs >= self.holdTime
end

function CdAction:isDone()
  return self:cdIsDone() and self:holdIsDone()
end

-- subAction methods --

function CdAction:subActionsAreDone()
  -- index is 1-based
  return self.currentSubActionIndex > table.getn(self.subActions)
end

function CdAction:currentSubAction()
  -- index is 1-based
  return self.subActions[self.currentSubActionIndex]
end

function CdAction:nextSubAction()
  self.currentSubActionIndex = self.currentSubActionIndex + 1
  if not self:subActionsAreDone() then
    self:currentSubAction():Init()
  end
end

function CdAction:startSubActions()
  self.currentSubActionIndex = 0
  self:nextSubAction()
end

function CdAction:operateSubActions()
  if not self:subActionsAreDone() then
    local s = self:currentSubAction()
    -- Reset() already ensured that the first subAction is initialized, if it exists
    s:Resume()
    if s:isDone() then
      s:Cleanup()
      self:nextSubAction()
    end
  end
end

function CdAction:completeSubActions()
  if self.currentSubActionIndex == 0 then
    return
  end
  while not self:subActionsAreDone() do
    self:currentSubAction():Cleanup()
    self:nextSubAction()
  end
end

function CdAction:haveAllResources()
  for i, rsc in ipairs(self.resources) do
    if not rsc:isOwnedBy(self) then
      return false
    end
  end
  return true
end

function CdAction:acquireAllResources()
  --log("acquireAllResources", self.key)
  for i, rsc in ipairs(self.resources) do
    --logif(self.key == "a", "resource", rsc.name)
    if not rsc:canAcquire(self) then
      return false
    end
  end

  local function onResourceRelease()
    self:releaseKey()
  end

  for i, rsc in ipairs(self.resources) do
    rsc:acquire(self, onResourceRelease)
  end
  return true
end

function CdAction:pressKey()
  -- log("pressKey", "key", self.key)
  self.pressFunc(self.key)
  self.pressTs = RTime()
  -- log("pressKey", "pressTs", self.pressTs)
  --logif(self.key == "4", "pressTs", self.pressTs)
  if not self.cycleStartsFromAcquire then
    self.startTs = alignedTs(self.startTs, self.pressTs, self.align)
  end
  self:startSubActions()
end

function CdAction:pressed()
  return self.pressTs ~= -1
end

function CdAction:releaseKey()
  -- log("releaseKey", "key", self.key)
  if not self:pressed() then
    return
  end
  if self:holdIsDone() then
    self.clickDone = true
  end
  self:completeSubActions()
  self.releaseFunc(self.key)
  self.pressTs = -1
end

function CdAction:releaseResources()
  --log("releaseResources", self.key)
  for i, rsc in ipairs(self.resources) do
    if rsc:isOwnedBy(self) then
      rsc:removeOwner()
    end
  end
end

function CdAction:Reset()
  self.pressTs = -1
  self.clickDone = true -- ready to start next cycle
  self.startTs = RTime() - self.cycleTime + self.firstCycleOffset
  self.started = false
end

function CdAction:Init()
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

function CdAction:Resume()
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
      if (self.onlyOnce and self.started) or not self:cdIsDone() then
        -- should not start next cycle, nothing to do
        return
      end
      -- start next cycle
      self.started = true
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

  -- handle subActions
  self:operateSubActions()

  if self:holdIsDone() then
    self.clickDone = true
    self:releaseKey()
    self:releaseResources()
  end
end

function CdAction:Cleanup()
  self:releaseKey()
  self:releaseResources()
end

function updateModCache()
  for mod, value in pairs(MODIFIER_ON_CACHE) do
    MODIFIER_ON_CACHE[mod] = isOn(mod)
  end
end

function runPrograms(actions)
  for i, p in ipairs(actions) do p:Init() end
  while true do
    Sleep(LOOP_DELAY)
    updateModCache()
    for i, action in ipairs(actions) do action:Resume() end
    if isOff("scrolllock") then break end
  end
  for i, p in ipairs(actions) do p:Cleanup() end
end

ProgramRunner = {
  actionResource = Resource:new { name = "action" },
  programs = {},
}

function ProgramRunner:new(o)
  o = o or {}
  o.programs = o.programs or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function ProgramRunner:Add(p)
  p = CdAction:new(p)
  table.insert(self.programs, p)
  return p
end

function ProgramRunner:AddAction(p)
  p = self:Add(p)
  p:AddResource(self.actionResource)
  return p
end

function ProgramRunner:AddHoldKey(p)
  p = p or {}
  p.holdTime = p.holdTime or -1
  p = self:AddAction(p)
  return p
end

function ProgramRunner:AddClick(p)
  p = p or {}
  p.holdTime = p.holdTime or 0
  p.pressFunc = p.pressFunc or click
  p.releaseFunc = p.releaseFunc or doNothing
  p = self:Add(p)
  return p
end

function ProgramRunner:AddReplaceMouseLeft(replaceKey, blockedActions)
  p = self:Add {
    blockedActions = blockedActions or {},
    enableBlockedActions = true,
    key = replaceKey,
    cycleTime = 200,
    pressFunc = releaseAndPressML,
    releaseFunc = doNothing,
    isEnabledFunc = ModIsOn("mouseleft"),
    isEnabled = false,
    onEnabledFunc = function(self2)
      log("replaceML enabled")
      self2.enableBlockedActions = false
      for i, p in ipairs(self2.blockedActions) do p:Cleanup() end
    end,
    onDisabledFunc = function(self2)
      log("replaceML disabled")
      release(self2.key)
      self2.enableBlockedActions = true
    end,
    Cleanup = function(self2)
      release(self2.key)
      self2:releaseKey()
      self2:releaseResources()
    end,
  }
  p.blockedActionsIsEnabledFunc = function() return p.enableBlockedActions end

  for i, action in ipairs(p.blockedActions) do
    if action.isEnabledFunc == nil then
      action.isEnabledFunc = p.blockedActionsIsEnabledFunc
    else
      local existing = action.isEnabledFunc
      action.isEnabledFunc = function()
        return existing() and p.enableBlockedActions
      end
    end
  end

  return p
end

function ProgramRunner:AddEdgeTrigger(isEnabledFunc, upFunc, downFunc)
  local p = self:Add {
    holdTime = -1,
    pressFunc = doNothing,
    releaseFunc = doNothing,
    isEnabledFunc = isEnabledFunc,
    isEnabled = false,
    onEnabledFunc = upFunc,
    onDisabledFunc = downFunc,
  }
  return p
end

function ProgramRunner:AddModEdgeTrigger(mod, upFunc, downFunc)
  return self:AddEdgeTrigger(ModIsOn(mod), upFunc, downFunc)
end

function ProgramRunner:AddModEdgeTriggerCached(mod, upFunc, downFunc)
  return self:AddEdgeTrigger(ModIsOnCached(mod), upFunc, downFunc)
end

function ProgramRunner:run()
  runPrograms(self.programs)
end

SubActionsMaker = {
  afterMs = 0,
  subActions = {},
}

function SubActionsMaker:new(o)
  o = o or {}
  o.subActions = o.subActions or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function SubActionsMaker:Add(p)
  p = CdAction:new(p)
  table.insert(self.subActions, p)
  p.onlyOnce = true
  p.firstCycleOffset = self.afterMs
  self.afterMs = 0
  return p
end

function SubActionsMaker:After(ms)
  self.afterMs = self.afterMs + ms
  return self
end

function SubActionsMaker:Press(key)
  self:Add { key = key, releaseFunc = doNothing, }
  return self
end

function SubActionsMaker:Release(key)
  self:Add { key = key, pressFunc = doNothing, }
  return self
end

function SubActionsMaker:Click(key)
  self:Add { key = key, pressFunc = click, releaseFunc = doNothing, }
  return self
end

function SubActionsMaker:Hold(key, holdTime)
  self:Add { key = key, holdTime = holdTime, }
  return self
end

function SubActionsMaker:Block(resource)
  self:Add { key = resource, pressFunc = function(r) r:block() end, releaseFunc = doNothing, }
  return self
end

function SubActionsMaker:Unblock(resource)
  self:Add { key = resource, pressFunc = doNothing, releaseFunc = function(r) r:unblock() end, }
  return self
end

function SubActionsMaker:Make(p)
  p = p or {}
  p.pressFunc = p.pressFunc or doNothing
  p.releaseFunc = p.releaseFunc or doNothing
  p.subActions = self.subActions
  self.subActions = {}
  return p
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

--[[
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
--]]

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
  --Sleep(1)
end

function threads_dh_strafe2()
  local runner = ProgramRunner:new()
  local subActions = SubActionsMaker:new()

  local press1Time = 340
  local press1MoreTime = 1800
  local press3Time = 200
  local total13Time = press1MoreTime + press3Time

  local press31 = runner:AddAction(
          subActions:Press("lshift"):Hold("3", press3Time):Click("mouseleft"):Release("lshift"):Hold("1", press1MoreTime):Make()
  )

  local function press1More()
    press31.subActions[#press31.subActions].holdTime = press1MoreTime
  end

  local function press1Less()
    press31.subActions[#press31.subActions].holdTime = press1Time
  end

  local replaceML = runner:AddReplaceMouseLeft("backslash", { press31 })
  local click2 = runner:AddClick { key = "2", cycleTime = 4200, }
  local click4 = runner:AddClick { key = "4", cycleTime = 500, }
  local clickMR = runner:AddClick { key = "mouseright", cycleTime = 500, }
  local clickQ = runner:AddClick { key = "q", cycleTime = 500, }

  local speedControl = runner:AddModEdgeTriggerCached("capslock", press1Less, press1More)

  runner:run()
  release("backslash")
  release("lshift")
end

function testSubAction()
  local runner = ProgramRunner:new()
  local subActions = SubActionsMaker:new {}

  runner:AddAction(subActions:Hold("a", 700):After(500):Press("lshift"):Hold("b", 1000):Release("lshift"):Hold("c", 1000):Make {
    priority = 1,
    cycleTime = 5000,
    firstCycleOffset = 500,
  })
  local clickQ = runner:AddClick { key = "q", cycleTime = 100, }

  runner:run()
end

function threads_wiz_meteor()
  cdClick("2", 120000)
  cdClick("3", 120000)
  cdClick("4", 120000)
  local runner = ProgramRunner:new()

  local enabled = true
  local function disabledWhenMoving()
    return enabled
  end

  local subActions = SubActionsMaker:new {}
  local clickML = subActions:Press("lshift"):After(50):Click("mouseleft"):After(25):Release("lshift"):Make {
    priority = 2,
    cycleTime = 5000,
  }
  clickML = runner:AddAction(clickML)

  local press1 = runner:AddHoldKey {
    priority = 1,
    key = "1",
  }

  local replaceML = runner:AddReplaceMouseLeft("backslash", {press1, clickML})
  local clickQ = runner:AddClick { key = "q", cycleTime = 500, }

  runner:run()
end

last_release_switch = -1
function OnEvent(event, arg)
  OutputLogMessage("event = %s, arg = %s\n", event, arg)
  --OutputLogMessage("time = %s event = %s, arg = %s\n", GetRunningTime(), event, arg)
  MODIFIER_ON_CACHE = {}
  GLOBAL_AVOID_MAP = {}

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