OLM = OutputLogMessage
RTime = GetRunningTime
local unpack = table.unpack or unpack
function myprintT(msg, logTable)
  OLM("%s: {", tostring(msg))

  -- 1. Extract keys into a temporary array
  local keys = {}
  for k in pairs(logTable) do
    table.insert(keys, k)
  end

  -- 2. Sort the keys alphabetically
  -- We use tostring() inside the sort to prevent errors if you have mixed types
  table.sort(keys, function(a, b)
    return tostring(a) < tostring(b)
  end)

  -- 3. Iterate through the sorted keys to print values
  for _, k in ipairs(keys) do
    local v = logTable[k]
    OLM("%s = %s, ", tostring(k), tostring(v))
  end

  OLM("}\n")
end


function myprint(msg, arg1, arg2)
  if type(arg1) == "table" then return myprintT(msg, arg1) end
  if arg2 ~= nil then return OLM("%s: %s = %s\n", tostring(msg), tostring(arg1), tostring(arg2)) end
  if arg1 ~= nil then return OLM("%s: %s\n", tostring(msg), tostring(arg1)) end
  OLM("%s\n", tostring(msg))
end

DEBUG = false
LOOP_DELAY = 1
function log(msg, name, value) return DEBUG and myprint(msg, name, value) end
function logif(condition, msg, name, value) return condition and log(msg, name, value) end

MOUSE_PRESS_TIME = { -1, -1, -1, -1, -1 }
MOUSE_RELEASE_TIME = { -1, -1, -1, -1, -1 }

function isMouseOn(mb)
  if MOUSE_PRESS_TIME[mb] == RTime() then
    return true
  end

  if MOUSE_RELEASE_TIME[mb] == RTime() then
    return false
  end

  return IsMouseButtonPressed(mb)
end

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
  ["mouseleft"] = function() return isMouseOn(1) end,
  ["mousemid"] = function() return isMouseOn(2) end,
  ["mouseright"] = function() return isMouseOn(3) end,
  ["mouse4"] = function() return isMouseOn(4) end,
  ["mouse5"] = function() return isMouseOn(5) end,
}

G602 = {
  mouseleft = 1,
  mouseright = 2, -- different from MOUSE_KEYS
  mousemid = 3,
  down_front = 4,
  down_mid = 5,
  down_back = 6,
  up_front = 7,
  up_mid = 8,
  up_back = 9,
  top_front = 10,
  top_back = 11,
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

function isModifier(flag)
  return MODIFIER_CHECK_FUNCTIONS[flag] ~= nil
end

--- click functions ---

PRESS_SAFEGUARD = {}
function exitReleaseAll()
  for k, v in pairs(PRESS_SAFEGUARD) do
    if v then
      release(k)
    end
  end
end

function release(key)
  log("release", key, RTime())
  PRESS_SAFEGUARD[key] = nil
  local mouseButton = MOUSE_KEYS[key]
  if mouseButton ~= nil then
    ReleaseMouseButton(mouseButton)
    MOUSE_RELEASE_TIME[mouseButton] = RTime()
    MOUSE_PRESS_TIME[mouseButton] = -1
  elseif MOUSE_WHEELS[key] == nil then
    ReleaseKey(key)
  end
end

function press(key)
  log("press", key, RTime())
  PRESS_SAFEGUARD[key] = 1
  local mouseButton = MOUSE_KEYS[key]
  if mouseButton ~= nil then
    PressMouseButton(mouseButton)
    MOUSE_PRESS_TIME[mouseButton] = RTime()
    MOUSE_RELEASE_TIME[mouseButton] = -1
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
    local mouseButton = MOUSE_KEYS[key]
    if mouseButton ~= nil then
      PressAndReleaseMouseButton(mouseButton)
      MOUSE_RELEASE_TIME[mouseButton] = RTime()
      MOUSE_PRESS_TIME[mouseButton] = -1
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

--- closure functions ---

function fnAll(f, ...)
    local args = {...}
    local n = select('#', ...)
    return function()
        return f(unpack(args, 1, n))
    end
end

function fnEach(func, ...)
  local keys = {...}
  local count = select("#", ...)
  return function()
    for i = 1, count do
      func(keys[i])
    end
  end
end

--- click detector functions ---

function doNothing()
end

ClickDetector = {
  gkey = 0,
  modifier = "mouse5",
  modifierWarmUpTime = 0, -- if not 0, sleep this time (ms) before first checking modifier
  longClickTime = 210, -- if modifier is pressed and hold for more than this time (ms), it's considered a long click. Otherwise a short click.
  doubleClickTime = 200, -- if modifier is pressed within this time (ms) of its last press, it's considered a double click. Otherwise a single click.

  -- Note: Extra arguments provided to a function are silently dropped. Missing arguments are default to nil.
  -- Phase 1: called as f()
  onPress = doNothing, -- triggered FIRST on any press of modifier

  -- Phase 2: called as f()
  onSingleClickPress = doNothing, -- triggered on press of a single click
  onDoubleClickPress = doNothing, -- triggered on press of a double click

  -- Phase 3: called as f(isSingleClick)
  onLongClick = doNothing, -- triggered once modifier has been pressed for longPressTime
  onLongClickRelease = doNothing, -- triggered on release if onLongClick is triggered
  onShortClickRelease = doNothing, -- triggered on release if onLongClick is not triggered
  onRelease = doNothing, -- triggered LAST on any release of modifier

  -- private params
  lastPressTime = -9999,
  lastReleaseTime = -9999,
}
ClickDetector.__index = ClickDetector

function ClickDetector:new(o)
  o = o or {}
  setmetatable(o, self)
  --self.__index = self
  return o
end

function ClickDetector:isSingleClick(pressTime)
  return pressTime > self.lastPressTime + self.doubleClickTime
end

function ClickDetector:isLongClick(pressTime)
  return RTime() > pressTime + self.longClickTime
end

function ClickDetector:makeFunc()
  return function()
    local pressTime = RTime()
    local isSingleClick = self:isSingleClick(pressTime)
    self.onPress()
    if isSingleClick then
      self.onSingleClickPress()
    else
      self.onDoubleClickPress()
    end
    if isModifier(self.modifier) then
      local longClickTriggered = false
      if self.modifierWarmUpTime > 0 then
        Sleep(self.modifierWarmUpTime)
      end
      while isOn(self.modifier) do
        Sleep(1)
        if not longClickTriggered and self:isLongClick(pressTime) then
          self.onLongClick(isSingleClick)
          longClickTriggered = true
        end
      end
      if longClickTriggered then
        self.onLongClickRelease(isSingleClick)
      else
        self.onShortClickRelease(isSingleClick)
      end
    end
    self.onRelease(isSingleClick)
    self.lastPressTime = pressTime
    self.lastReleaseTime = RTime()
  end
end

FuncTableHandler = {
  funcTable = {}
}
FuncTableHandler.__index = FuncTableHandler

function FuncTableHandler:new(o)
  o = o or {}
  o.funcTable = o.funcTable or {}
  setmetatable(o, self)
  --self.__index = self
  return o
end

function FuncTableHandler:AddClickDetectorFunc(p)
  p = ClickDetector:new(p)
  if p.gkey == nil or p.gkey <= 0 then
    return
  end
  self.funcTable[p.gkey] = p:makeFunc()
end

--- advanced action functions ---

AdvancedAction = {
  name = "",
  enabled = false,
  delay = 0,
  upFunc = doNothing,
  downFunc = doNothing,
  -- private
  triggered = false
}
AdvancedAction.__index = AdvancedAction

function AdvancedAction:new(o)
  o = o or {}
  setmetatable(o, self)
  --self.__index = self
  return o
end

function AdvancedAction:up(holdTime)
  if not self.enabled then
    return
  end
  if not self.triggered and holdTime > self.delay then
    self.upFunc()
    self.triggered = true
  end
end

function AdvancedAction:down()
  if self.triggered then
    self.downFunc()
    self.triggered = false
  end
end

AdvancedActionsHandler = {
  actions = {},
  startCondition = function() return true end,
  -- private
  startTime = 0,
  started = false,
}
AdvancedActionsHandler.__index = AdvancedActionsHandler

function AdvancedActionsHandler:new(o)
  o = o or {}
  o.actions = o.actions or {}
  setmetatable(o, self)
  --self.__index = self
  return o
end

function AdvancedActionsHandler:Add(p)
  p = AdvancedAction:new(p)
  table.insert(self.actions,p)
end

function AdvancedActionsHandler:Start()
  if self.started then
    return
  end
  if not self.startCondition() then
    return
  end
  self.startTime = RTime()
  self.started = true
end

function AdvancedActionsHandler:Up()
  if not self.started then
    return
  end
  local holdTime = RTime() - self.startTime
  for _, action in ipairs(self.actions) do
    action:up(holdTime)
  end
end

function AdvancedActionsHandler:ShouldStop()
  return self.started and not self.startCondition()
end

function AdvancedActionsHandler:Down()
  if not self.started then
    return
  end
  for _, action in ipairs(self.actions) do
    action:down()
  end
  self.started = false
end


--- feature functions ---

function movemouseright50()
  MoveMouseRelative(50,0)
end

function movemouseright500()
    MoveMouseRelative(50,0)
    Sleep(100)
    MoveMouseRelative(50,0)
    Sleep(100)
    MoveMouseRelative(50,0)
    Sleep(100)
    MoveMouseRelative(50,0)
    Sleep(100)
    MoveMouseRelative(50,0)
    Sleep(100)
    MoveMouseRelative(50,0)
    Sleep(100)
    MoveMouseRelative(50,0)
    Sleep(100)
    MoveMouseRelative(50,0)
    Sleep(100)
    MoveMouseRelative(50,0)
    Sleep(100)
    MoveMouseRelative(50,0)
end

function autoDown()
  while isOn("mouseright") do
    if isOn("mouseleft") then
      MoveMouseRelative(0,3)
    end
    while isOn("mouseleft") do
      Sleep(1)
    end
    Sleep(1)
  end
end

aaHandler = AdvancedActionsHandler:new{
  startCondition = function() return isOn("mouseleft") end,
}
aaHandler:Add{
  name = "autoScope",
  enabled = true,
  delay = 700,
  upFunc = fnEach(click, "j"),
  downFunc = fnEach(click, "j"),
}

aaHandler:Add{
  name = "autoCrouch",
  enabled = false,
  delay = 300,
  upFunc = fnEach(click, "c"),
  downFunc = fnEach(click, "c"),
}

function autoPeek4()
  if isOff("capslock") then
    return
  end
  if isOff("mouseright") then
    return
  end
  local advancedActions = isOn("numlock")
  local peekLeft = isOn("scrolllock")
  local key = "e"
  if peekLeft then
    key = "q"
  end
  press(key)
  if peekLeft then
    click("v")
  end
  -- Sleep(50)
  while isOn("mouseright") do
    if advancedActions then
      aaHandler:Start()
      aaHandler:Up()
      if aaHandler:ShouldStop() then
        aaHandler:Down()
      end
    end
    Sleep(1)
  end
  if peekLeft then
    click("v")
  end
  if advancedActions then
    aaHandler:Down()
  end
  release(key)
end

function switchPeek()
  if isOff("capslock") then
    setOn("capslock")
    setOff("scrolllock")
    return
  end
  click("scrolllock")
end

function autoHoldBreath()
  if isOff("capslock") then
    return
  end
  click("ralt")
end

funcs = {
  [G602.down_front] = switchPeek,
  --[9] = movemouseright50,
  [G602.mouseright] = autoPeek4,
}

handler = FuncTableHandler:new{funcTable = funcs}
handler:AddClickDetectorFunc{
  gkey = G602.top_front,
  onLongClick = fnEach(click,"h"),
  onShortClickRelease = fnEach(click,"f8"),
}

handler:AddClickDetectorFunc{
  gkey = G602.down_mid,
  modifier = "lalt",
  modifierWarmUpTime = 50,
  onShortClickRelease = fnEach(setOff,"capslock","scrolllock","numlock"),
}

handler:AddClickDetectorFunc{
  gkey = G602.up_mid,
  modifier = "",
  onDoubleClickPress = fnEach(click, "numlock"),
}

handler:AddClickDetectorFunc{
  gkey = G602.down_back,
  onLongClick = fnEach(click,"n"),
  onShortClickRelease = fnEach(click,"9"),
}

release_funcs = {
  [G602.mouseright] = autoHoldBreath,
}

function OnEvent(event, arg)
  --OutputLogMessage("event = %s, arg = %s\n", event, arg)
  --if arg == 10 then
    --return markAndSecondInteract(event, arg)
  --end

  if (funcs[arg] ~= nil) then
    if (event == "MOUSE_BUTTON_PRESSED") then
      funcs[arg]()
    end
  end

  if (release_funcs[arg] ~= nil) then
    if (event == "MOUSE_BUTTON_RELEASED") then
      release_funcs[arg]()
    end
  end
end