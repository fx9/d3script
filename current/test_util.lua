originalPrint = print
OutputLogMessage = function(...) originalPrint(string.format(...)) end

testUtil = {
  press = function(key, time)
    return {key = key, time = time, op = "press"}
  end,
  release = function(key, time)
    return {key = key, time = time, op = "release"}
  end,
  click = function(key, time)
    return {key = key, time = time, op = "click"}
  end,
}

mockRuntime = {
  time = 0,
  pressedKeys = {},
  keyLocksOn = {
    ["numlock"] = false,
    ["capslock"] = false,
    ["scrolllock"] = false,
  },
  script = {},
  scriptIndex = 1,

  MODIFIERS = { ["shift"] = 1, ["ctrl"] = 1, ["alt"] = 1 },
  MODIFIER_KEYS = { ["lshift"] = 1, ["rshift"] = 1, ["lctrl"] = 1, ["rctrl"] = 1, ["lalt"] = 1, ["ralt"] = 1 },
  MOUSE_BUTTONS = { [1] = "mouseleft", [2] = "mousemid", [3] = "mouseright", [4] = "mouse4", [5] = "mouse5" },
  MOUSE_WHEELS = { [1] = "mousewheelup", [-1] = "mousewheeldown" },
  KEYS = { ["escape"] = 2, ["f1"] = 2, ["f2"] = 2, ["f3"] = 2, ["f4"] = 2, ["f5"] = 2, ["f6"] = 2, ["f7"] = 2, ["f8"] = 2, ["f9"] = 2, ["f10"] = 2, ["f11"] = 2, ["f12"] = 2, ["f13"] = 2, ["f14"] = 2, ["f15"] = 2, ["f16"] = 2, ["f17"] = 2, ["f18"] = 2, ["f19"] = 2, ["f20"] = 2, ["f21"] = 2, ["f22"] = 2, ["f23"] = 2, ["f24"] = 2, ["printscreen"] = 2, ["scrolllock"] = 2, ["pause"] = 2, ["tilde"] = 2, ["1"] = 2, ["2"] = 2, ["3"] = 2, ["4"] = 2, ["5"] = 2, ["6"] = 2, ["7"] = 2, ["8"] = 2, ["9"] = 2, ["0"] = 2, ["minus"] = 2, ["equal"] = 2, ["backspace"] = 2, ["tab"] = 2, ["q"] = 2, ["w"] = 2, ["e"] = 2, ["r"] = 2, ["t"] = 2, ["y"] = 2, ["u"] = 2, ["I"] = 2, ["o"] = 2, ["p"] = 2, ["lbracket"] = 2, ["rbracket"] = 2, ["backslash"] = 2, ["capslock"] = 2, ["a"] = 2, ["s"] = 2, ["d"] = 2, ["f"] = 2, ["g"] = 2, ["h"] = 2, ["j"] = 2, ["k"] = 2, ["l"] = 2, ["semicolon"] = 2, ["quote"] = 2, ["enter"] = 2, ["lshift"] = 2, ["non_us_slash"] = 2, ["z"] = 2, ["x"] = 2, ["c"] = 2, ["v"] = 2, ["b"] = 2, ["n"] = 2, ["m"] = 2, ["comma"] = 2, ["period"] = 2, ["slash"] = 2, ["rshift"] = 2, ["lctrl"] = 2, ["lgui"] = 2, ["lalt"] = 2, ["spacebar"] = 2, ["ralt"] = 2, ["rgui"] = 2, ["appkey"] = 2, ["rctrl"] = 2, ["insert"] = 2, ["home"] = 2, ["pageup"] = 2, ["delete"] = 2, ["end"] = 2, ["pagedown"] = 2, ["up"] = 2, ["left"] = 2, ["down"] = 2, ["right"] = 2, ["numlock"] = 2, ["numslash"] = 2, ["numminus"] = 2, ["num7"] = 2, ["num8"] = 2, ["num9"] = 2, ["numplus"] = 2, ["num4"] = 2, ["num5"] = 2, ["num6"] = 2, ["num1"] = 2, ["num2"] = 2, ["num3"] = 2, ["numenter"] = 2, ["num0"] = 2, ["numperiod"] = 2 },

  SLEEP_CYCLE_TIME = 15.3,
  sleepCycle = function(self)
    local intMs = math.floor(self.SLEEP_CYCLE_TIME)
    local remainder = self.SLEEP_CYCLE_TIME - intMs
    if math.random() < remainder then
      intMs = intMs + 1
    end
    self.time = self.time + intMs
    self:executeScript()
    return intMs
  end,

  Setup = function(self, script)
    local lastItem = script[#script]
    --[[
    if lastItem == nil then
      table.insert(script, testUtil.click("scrolllock", 1000))
    elseif lastItem.key ~= "scrolllock" then
      table.insert(script, testUtil.click("scrolllock", lastItem.time + 1000))
    end
    --]]
    self.script = script
    self.scriptIndex = 1
    
    self.time = 0
    self.pressedKeys = {}
    self.keyLocksOn = {
      ["numlock"] = false,
      ["capslock"] = false,
      ["scrolllock"] = false,
    }
    self:executeScript()
  end,

  executeScript = function(self)
    local scriptItem = self.script[self.scriptIndex]
    if not scriptItem then
      return
    end
    if scriptItem.time > self.time then
      return
    end
    if scriptItem.op == "press" then
      self:press(scriptItem.key)
    elseif scriptItem.op == "release" then
      self:release(scriptItem.key)
    elseif scriptItem.op == "click" then
      self:press(scriptItem.key)
      self:release(scriptItem.key)
    end
    self.scriptIndex = self.scriptIndex + 1
    self:executeScript() -- execute until nothing to do
  end,

  error = function()
    originalPrint("Error in API calls: "..debug.traceback())
  end,

  press = function(self,key)
    self.pressedKeys[key] = 1
    if self.keyLocksOn[key] ~= nil then
      self.keyLocksOn[key] = not self.keyLocksOn[key]
    end
  end,

  release = function(self,key)
    self.pressedKeys[key] = nil
  end,
  
  validate = function(self)
    for k, v in pairs(self.pressedKeys) do 
      if v ~= nil then
        originalPrint("Not released: "..k.."\n")
      end
    end
    for k, v in pairs(self.keyLocksOn) do 
      if v then
        originalPrint("Lock left on: "..k.."\n")
      end
    end
  end,
}

math.randomseed(1)
TEST_OUTPUT = true
function TestLog(funcName,msg)
  if TEST_OUTPUT then
    originalPrint(tostring(mockRuntime.time).." "..funcName..": "..msg)
  end
end


function GetRunningTime()
  return mockRuntime.time
end

function Sleep(ms)
  if ms <= 0 then
    return
  end
  local endTime = mockRuntime.time + ms
  for i = 1, 1000 do
    mockRuntime:sleepCycle()
    if mockRuntime.time >= endTime then
      return
    end
  end
  originalPrint("sleep too long: "..ms.." ms")
end

function IsModifierPressed(mod)
  if mockRuntime.MODIFIERS[mod] ~= nil then
    return IsModifierPressed("l"..mod) or IsModifierPressed("r"..mod)
  end
  if mockRuntime.MODIFIER_KEYS[mod] ~= nil then
    return mockRuntime.pressedKeys[mod] ~= nil
  end
  mockRuntime.error()
  return false
end

function IsKeyLockOn(key)
  if mockRuntime.keyLocksOn[key] ~= nil then
    return mockRuntime.keyLocksOn[key]
  end
  mockRuntime.error()
  return false
end

function IsMouseButtonPressed(mb)
  if mockRuntime.MOUSE_BUTTONS[mb] ~= nil then
    return mockRuntime.pressedKeys[mockRuntime.MOUSE_BUTTONS[mb]] ~= nil
  end
  mockRuntime.error()
  return false
end

function PressMouseButton(mb)
  TestLog("PressMouseButton", mb)
  if mockRuntime.MOUSE_BUTTONS[mb] ~= nil then
    mockRuntime:press(mockRuntime.MOUSE_BUTTONS[mb])
    return
  end
  mockRuntime.error()
end

function ReleaseMouseButton(mb)
  TestLog("ReleaseMouseButton", mb)
  if mockRuntime.MOUSE_BUTTONS[mb] ~= nil then
    mockRuntime:release(mockRuntime.MOUSE_BUTTONS[mb])
    return
  end
  mockRuntime.error()
end

function PressAndReleaseMouseButton(mb)
  TestLog("PressAndReleaseMouseButton", mb)
  if mockRuntime.MOUSE_BUTTONS[mb] ~= nil then
    mockRuntime:press(mockRuntime.MOUSE_BUTTONS[mb])
    mockRuntime:release(mockRuntime.MOUSE_BUTTONS[mb])
    return
  end
  mockRuntime.error()
end

function PressKey(key)
  TestLog("PressKey", key)
  if mockRuntime.KEYS[key] ~= nil then
    mockRuntime:press(key)
    return
  end
  mockRuntime.error()
end

function ReleaseKey(key)
  TestLog("ReleaseKey", key)
  if mockRuntime.KEYS[key] ~= nil then
    mockRuntime:release(key)
    return
  end
  mockRuntime.error()
end

function PressAndReleaseKey(key)
  TestLog("PressAndReleaseKey", key)
  if mockRuntime.KEYS[key] ~= nil then
    mockRuntime:press(key)
    mockRuntime:release(key)
    return
  end
  mockRuntime.error()
end

function MoveMouseWheel(mw)
  if mockRuntime.MOUSE_WHEELS[mw] == nil then
    mockRuntime.error()
  end
end