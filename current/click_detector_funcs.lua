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
function closure(f, ...)
    local args = {...}
    local n = select('#', ...)
    return function()
        return f(unpack(args, 1, n))
    end
end

--- long/short/double click functions ---

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
  setmetatable(o, self)
  --self.__index = self
  return o
end

function FuncTableHandler:AddClickDetectorFunc(p)
  p = ClickDetector:new(p)
  if p.gkey <= 0 then
    return
  end
  self.funcTable[p.gkey] = p:makeFunc()
end

--- feature functions ---

function addMouseStats(stats, dx, dy)
  if dx > 0 then
    stats["x+"] = stats["x+"] + dx
  else
    stats["x-"] = stats["x-"] - dx
  end

  if dy > 0 then
    stats["y+"] = stats["y+"] + dy
  else
    stats["y-"] = stats["y-"] - dy
  end
end

function mergeStats(stats, temp_stats)
  stats["x+"] = stats["x+"] + temp_stats["x+"]
  stats["x-"] = stats["x-"] + temp_stats["x-"]
  stats["y+"] = stats["y+"] + temp_stats["y+"]
  stats["y-"] = stats["y-"] + temp_stats["y-"]
  temp_stats["x+"] = 0
  temp_stats["x-"] = 0
  temp_stats["y+"] = 0
  temp_stats["y-"] = 0
end

record_one_click = true
function recordMouse()
  warning = false
  s=RTime()
  while isOff("capslock") do
    Sleep(1)
    if RTime()-s > 5000 then
      return
    end
  end
  stats = {
    ["x+"] = 0,
    ["x-"] = 0,
    ["y+"] = 0,
    ["y-"] = 0,
  }
  temp_stats = {
    ["x+"] = 0,
    ["x-"] = 0,
    ["y+"] = 0,
    ["y-"] = 0,
  }
  x, y = GetMousePosition()
  t0 = 0
  tx = 0
  clicks = 0
  s=RTime()
  while isOff("mouseleft") do
    Sleep(1)
    if RTime()-s > 5000 then
      return
    end
  end
  t0 = RTime()
  click_started = false
  while isOn("capslock") do
    Sleep(1)
    -- get pos diff
    xx, yy = GetMousePosition()
    if xx == 0 or xx == 65535 or yy == 0 or yy == 65535 then
       warning = true
    end
    dx=xx-x
    dy=yy-y
    x=xx
    y=yy

    -- print diff
    if dx ~= 0 or dy ~= 0 then
      --myprint("d_stats",{["dx"] = dx, ["dy"] = dy})
    end

    addMouseStats(temp_stats, dx, dy)
    in_click = isOn("mouseleft")

    if record_one_click then
      if in_click and not click_started then
        click_started = true
        t0 = RTime()
        clicks = clicks + 1
        mergeStats(temp_stats,temp_stats)
      end
      if click_started and not in_click then
        click_started = false
        tx = RTime()
        mergeStats(stats,temp_stats)
        break
      end
    else
      if in_click and not click_started then
        click_started = true
        tx = RTime()
        clicks = clicks + 1
        --myprint("one click - temp_stats", temp_stats)
        --myprint("time",tx-t0)
        mergeStats(stats,temp_stats)
      end
      if click_started and not in_click then
        click_started = false
      end
    end
  end
  if warning then
    myprint("warning: mouse hit boarder")
    return
  end
  myprint("mouse movement",stats)
  myprint("time",tx-t0)
  myprint("clicks",clicks)
end

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

function onLongShortPress(modifier, onLongPressFunc, onShortPressFunc)
  return function()
    local pressTime = RTime()
    while isOn(modifier) do
      Sleep(1)
      holdTime = RTime() - pressTime
      if holdTime > 210 then
        onLongPressFunc()
        return
      end
    end
    onShortPressFunc()
  end
end


function autoPeek4()
  if isOff("capslock") then
    return
  end
  if isOff("mouseright") then
    return
  end
  local autoC = isOn("numlock")
  local peekLeft = isOn("scrolllock")
  local key = "e"
  if peekLeft then
    key = "q"
  end
  press(key)
  if peekLeft then
    click("v")
  end
  if autoC then
    click("c")
  end
  Sleep(50)
  while isOn("mouseright") do
    Sleep(50)
  end
  if peekLeft then
    click("v")
  end
  if autoC then
    click("c")
  end
  release(key)
end

function isPeekLeft()
  if isOff("capslock") then
    return false
  end
  if isOn("scrolllock") then
    return true
  end
  if isOn("numlock") then
    return false
  end
  x0, y0 = GetMousePosition()
  while true do
    Sleep(25)
    x1, y1 = GetMousePosition()
    if x1 ~= x0 or y1 ~= y0 then
      break
    end
  end
  Sleep(50)
  x2, y2 = GetMousePosition()
  pl = x0 > x1 and x1 > x2
  return pl
end


function switchPeek()
  if isOff("capslock") then
    setOn("capslock")
    setOff("scrolllock")
    return
  end
  click("scrolllock")
end

--[[
function onDblClick(func)
  local func_last_press = -9999
  local function funcOnDblClick()
    --myprint("func_last_press",func_last_press)
    if GetRunningTime() - func_last_press <= 200 then
      func()
    end
    func_last_press=GetRunningTime()
  end
  return funcOnDblClick
end

G_LAST_PRESS=-9999
function numLockOnDblClick()
  if GetRunningTime() - G_LAST_PRESS <= 200 then
    click("numlock")
  end
  G_LAST_PRESS=GetRunningTime()
end
--]]
function clickNumLock()
  click("numlock")
end

function resetLocks()
  setOff("capslock")
  setOff("scrolllock")
  setOff("numlock")
end

function autoHoldBreath()
  if isOff("capslock") then
    return
  end
  click("ralt")
end

funcs = {
  --[10] = markAndSecondInteract3,
  [4] = switchPeek,
  --[5] = resetLocksOnDblClick,
  --[8] = numLockOnDblClick,
  --[9] = movemouseright50,
  --[6] = bandageAndMapZoom,
  [2] = autoPeek4,
}

handler = FuncTableHandler:new{funcTable = funcs}
handler:AddClickDetectorFunc{
  gkey = 10,
  onLongClick = closure(click,"h"),
  onShortClickRelease = closure(click,"g"),
}

handler:AddClickDetectorFunc{
  gkey = 5,
  modifier = "lalt",
  modifierWarmUpTime = 50,
  onShortClickRelease = resetLocks,
}

handler:AddClickDetectorFunc{
  gkey = 8,
  modifier = "",
  onDoubleClickPress = clickNumLock,
}

handler:AddClickDetectorFunc{
  gkey = 6,
  onLongClick = closure(click,"n"),
  onShortClickRelease = closure(click,"9"),
}

release_funcs = {
  [2] = autoHoldBreath,
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

