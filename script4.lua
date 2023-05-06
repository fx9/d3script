function print(msg, name, value)
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

function func_selector()
  threads_dh_strafe2()
  mouse_move = false
end


DEBUG = false
LOOP_DELAY=1
function log(msg, name, value)
  if not DEBUG then
    return
  end
  print(msg, name, value)
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
  print("start")
  local startTime = GetRunningTime()
  for i=1,100000 do
    func()
  end
  local endTime = GetRunningTime()
  print("100000 cycles average time", (endTime-startTime)/100000.0)
  print("startTime", startTime)
  print("endTime", endTime)
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

MODIFIER_CHECK_FUNCTIONS={
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

MOUSE_KEYS={
  ["mouseleft"] = 1,
  ["mousemid"] = 2,
  ["mouseright"] = 3,
  ["mouse4"] = 4,
  ["mouse5"] = 5,
}

MOUSE_WHEELS={
  ["mousewheelup"] = 1,
  ["mousewheeldown"] = -1,
}

LOCK_KEYS={
  ["scrolllock"] = 1,
  ["capslock"] = 1,
  ["numlock"] = 1,
}

MODIFIER_ON_CACHE={}

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
  if type(target) == "string" then -- key
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
  else -- function
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
  return  self.program == nil
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
  priority = 0,
  key = "",
  resources = {},
  cycleTime = 0, -- total intended time of a cd-press-release cycle.
  holdTime = 0, -- hold key for this time, and then release. if set to -1, it will attempt to hold infinitely.

  pressFunc = press,  -- func(key) to press
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

function CdClick:cdIsDone()
  return RTime() - self.startTs >= self.cycleTime
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


function CdClick:internalInit()
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
  self:internalInit()
  self.onEnabledClosure = function ()
    -- logif(self.key=="backslash","enabled","time",RTime())
    self:internalInit()
    self:onEnabledFunc()
  end
  self.onDisabledClosure = function ()
    -- logif(self.key=="backslash","disabled","time",RTime())
    self:onDisabledFunc()
    self:Destroy()
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
    if self.clickDone then -- after click
      if not self:cdIsDone() then -- should not start next cycle, nothing to do
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

function CdClick:Destroy()
  self:releaseKey()
  self:releaseResources()
  -- self.co = nil
end

function updateModCache()
  for mod, value in pairs(MODIFIER_ON_CACHE) do
    MODIFIER_ON_CACHE[mod] = isOn(mod)
  end
end

function runPrograms(actions, noActions, actionResource)
  cachedMods = cachedMods or {}

  for i, p in ipairs(actions) do
    p:Init()
  end
  for i, p in ipairs(noActions) do
    p:Init()
  end

  local noActionExecuted = false
  while true do
    Sleep(LOOP_DELAY)
    updateModCache()

    for i, action in ipairs(actions) do
      if not noActionExecuted and actionResource:isFree() then
        for j, noAction in ipairs(noActions) do
          noAction:Resume()
        end
      end
      action:Resume()
    end

    if not noActionExecuted then
      for j, noAction in ipairs(noActions) do
        noAction:Resume()
      end
    end

    if isOff("scrolllock") then
      break
    end
  end

  for i, p in ipairs(actions) do
    p:Destroy()
  end
  for i, p in ipairs(noActions) do
    p:Destroy()
  end

end

function holdKey(priority, key, resources)
  return CdClick:new{holdTime = -1, key = key, priority = priority, resources = resources}
end

function noActionClick(priority, key, cd, resources)
  return CdClick:new{
    priority = priority,
    key = key,
    resources = resources,
    cycleTime = cd,
    holdTime = 0,

    pressFunc = click, 
    releaseFunc = doNothing,
  }
end

function actionClick(priority, key, cd, holdTime, resources)
  return CdClick:new{
    priority = priority,
    key = key,
    resources = resources,
    cycleTime = cd,
    holdTime = holdTime,
  }
end

function modEdgeTrigger(mod, upFunc, downFunc)
  return CdClick:new{
    holdTime = -1,

    pressFunc = doNothing,
    releaseFunc = doNothing,

    isEnabledFunc = ModIsOn(mod),
    isEnabled = isOff(mod), -- use flip value to ensure upFunc/downFunc called immediately
    onEnabledFunc = upFunc,
    onDisabledFunc = downFunc,
  }
end

function modEdgeTriggerCached(mod, upFunc, downFunc)
  return CdClick:new{
    holdTime = -1,

    pressFunc = doNothing,
    releaseFunc = doNothing,

    isEnabledFunc = ModIsOnCached(mod),
    isEnabled = isOffCached(mod), -- use flip value to ensure upFunc/downFunc called immediately
    onEnabledFunc = upFunc,
    onDisabledFunc = downFunc,
  }
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

function release_and_press_mouseleft(replace_key)
  local lshift_on=false
  if isOn("lshift") then
    lshift_on=true
    release("lshift")
  end
  release(replace_key)
  release("mouseleft")
  press(replace_key)
  if lshift_on then
    press("lshift")
  end
  press("mouseleft")
  Sleep(1)
end

function test2()
  action = Resource:new()
  h = holdKey(0,"1",{action})
  h2 = holdKey(1,"2",{action})
  h2.isEnabledFunc = ModIsOn("mouseleft")
  h.isEnabledFunc = ModIsOff("mouseleft")
  c = noActionClick(10,"3",1000,{action})

  runPrograms({h,h2,c})
  Sleep(5000)
    ReleaseKey("1")
    ReleaseKey("2")
    ReleaseKey("3")
end

function threads_dh_strafe2()
  local action = Resource:new()

  local low = 0
  local high = 10
  local interrupt = 100

  local enabled = true
  function disabledWhenMoving()
    return enabled
  end

  click2 = noActionClick(low,"2",4200,{action})
  click4 = noActionClick(low,"4",500,{action})
  click4.align = -500
  clickMR = noActionClick(low,"mouseright",500,{action})
  clickQ = noActionClick(low,"q",500,{action})
  -- clickML = noActionClick(low,"mouseleft",5000,{action})
  -- clickML.align = -500
  -- clickML.isEnabledFunc = disabledWhenMoving

  replaceML = noActionClick(interrupt,"backslash",200,{action})
  replaceML.pressFunc = release_and_press_mouseleft
  replaceML.isEnabledFunc = ModIsOn("mouseleft")
  replaceML.onEnabledFunc = function(self) enabled = false end
  replaceML.onDisabledFunc = function(self) enabled = true end


  press1_time=340
  press1_extended_time=2300
  press3_time=200

  press1 = actionClick(1,"1",2500,2300,{action})
  press1.firstCycleOffset = 100
  press1.isEnabledFunc = disabledWhenMoving
  press3 = actionClick(high,"3",2500,200,{action})
  press3.pressFunc = function(key)
    press("3")
    press("lshift")
  end
  press3.releaseFunc = function(key)
    release("3")
    click("mouseleft")
    release("lshift")
  end
  press3.isEnabledFunc = disabledWhenMoving
  -- pressLShift = holdKey(1,"lshift",{})

  local function press1_more()
    press1.holdTime = press1_extended_time
    press3.cycleTime = press3_time + press1_extended_time
    press1.cycleTime = press3_time + press1_extended_time
    press1:Init()
    press3:Init()
  end

  local function press1_less()
    press1.holdTime = press1_time
    press3.cycleTime = press3_time + press1_time
    press1.cycleTime = press3_time + press1_time
  end

  speedControl = modEdgeTrigger("capslock", press1_less, press1_more)

  runPrograms(
    {press1,press3},
    {replaceML,speedControl,click2,click4,clickMR,clickQ},
    action
  )
end

-- function OnEvent(event, arg)
--   --OutputLogMessage("event = %s, arg = %s\n", event, arg);
-- -- [[
--     if (event == "MOUSE_BUTTON_PRESSED") and arg == 9 then
--       threads_dh_strafe2()
--     end
-- --]]
-- end

last_release_switch=-1
function OnEvent(event, arg)
  OutputLogMessage("event = %s, arg = %s\n", event, arg)
  --OutputLogMessage("time = %s event = %s, arg = %s\n", GetRunningTime(), event, arg)
  MODIFIER_ON_CACHE={}

  local funcs={
    [8] = func_selector,
    [6] = func_selector,
  }
  if (funcs[arg] ~= nil) then
    if (event == "MOUSE_BUTTON_PRESSED") then
      if GetRunningTime()-last_release_switch <= 5 then
        return
      end
      funcs[arg]()
    end
    if (event == "MOUSE_BUTTON_RELEASED") then
      last_release_switch=GetRunningTime()
    end 
  end 

end