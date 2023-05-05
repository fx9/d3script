function print(name, value)
  if value == nil then
    OutputLogMessage("%s\n", tostring(name))
  else
    OutputLogMessage("%s = %s\n", tostring(name), tostring(value))
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

function isOn(flag)
  return MODIFIER_CHECK_FUNCTIONS[flag]()
end

function isOff(flag)
  return not isOn(flag)
end

function release(key)
  if MOUSE_KEYS[key] ~= nil then
    ReleaseMouseButton(MOUSE_KEYS[key])
  elseif MOUSE_WHEELS[key] == nil then
    ReleaseKey(key)
  end
end

function press(key)
  if MOUSE_KEYS[key] ~= nil then
    PressMouseButton(MOUSE_KEYS[key])
  elseif MOUSE_WHEELS[key] ~= nil then
    MoveMouseWheel(MOUSE_WHEELS[key])
  else
    PressKey(key)
  end
end

function click(target)
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
  return self.program == nil or self:isOwnedBy(program) or self.program.priority < program.priority
end


Program = {
  priority = 0,

  Init = nil, -- :func() to initialize variables. Must be defined for each extension
  Resume = nil, -- :func() to resume coroutine. Must be defined for each extension
  Destroy = nil, -- :func() to cleanup status on script end. Must be defined for each extension
}

function Program:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
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

WhenModIsOn = Program:new{
  mod = "",
  program = nil,
  instance = nil,
}

function WhenModIsOn:Init()
  if MODIFIER_CHECK_FUNCTIONS[self.mod] == nil then
    print("WhenModIsOn: mod is not a modifier.")
    print("mod", self.mod)
    return nil
  end
  self.instance = nil
  return nil
end

function WhenModIsOn:Resume()
  local function createInstance()
    self.instance = self.program:new()
    self.instance:Init()
  end

  local function destroyInstance()
    self.instance:Destroy()
    self.instance = nil
  end

  edgeTrigger(self.instance ~= nil, isOn(self.mod), createInstance, destroyInstance)
  if self.instance ~= nil then
    self.instance:Resume()
  end
end

function WhenModIsOn:Destroy()
  if self.instance == nil then
    return
  end
  self.instance:Destroy()
  self.instance = nil
end

CdClick = Program:new{
  --priority = 0 inherited.
  key = "",
  resources = {},
  cycleTime = 0, -- total intended time of a cd-press-release cycle.
  holdTime = 0, -- hold key for this time, and then release. if set to -1, it will attempt to hold infinitely.

  pressFunc = press,
  releaseFunc = release,
  isEnabledFunc = nil,

  firstCycleOffset = 0, -- <=0: start first cycle immediately; >0: start first cycle X ms after init
  align = 0, -- alignment of every cycle. 0: unaligned; >0: align to the next point; <0: align to the previous point
  cycleStartsFromAcquire = false, -- if true, cycles start at when it first attempt to acquire resources (by default, cycles start from when the key is pressed).

  startTs = 0, -- timestamp when the current cycle starts
  pressTs = 0, -- timestamp when the key was recently pressed. Should remain -1 if the key is not being pressed
  clickDone = false, -- true if the press-release is done without interruption in the cycle.

  co = nil, -- coroutine to resume
}

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
  self.pressFunc(self.key)
  self.pressTs = RTime()
  if not self.cycleStartsFromAcquire then
    self.startTs = alignedTs(self.startTs, self.pressTs, self.align)
  end
end

function CdClick:pressed()
  return self.pressTs ~= -1
end

function CdClick:releaseKey()
  self.releaseFunc(self.key)
  self.pressTs = -1
end

function CdClick:releaseResources()
  if not self:haveAllResources() then
    for i, rsc in ipairs(self.resources) do
      if rsc:isOwnedBy(self) then
        rsc:removeOwner()
      end
    end
  end
end

function CdClick:Init()
  self:releaseKey()
  self.clickDone = true -- ready to start next cycle
  self.startTs = RTime() - self.cycleTime + self.firstCycleOffset
  self.co = coroutine.create(function()
    while true do
      self:operate()
      coroutine.yield()
    end
  end)
end


function CdClick:enabled()
  if self.isEnabledFunc ~= nil then
    return self.isEnabledFunc()
  end
  return true
end


function CdClick:operate()
  if not self:enabled() then
    self:releaseKey()
    self:releaseResources()
    return
  end

  if not self:pressed() then
    -- not pressed, either before or after click
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
  if self:holdIsDone() then
    self.clickDone = true
    self:releaseKey()
    self:releaseResources()
  end
end

function CdClick:Resume()
  coroutine.resume(self.co) 
end

function CdClick:Destroy()
  self:releaseKey()
  for i, rsc in ipairs(self.resources) do
    rsc:removeOwner()
  end
  self.co = nil
end



function runPrograms(programs)
  for i, p in ipairs(programs) do
    p:Init()
  end
  while true do
    Sleep(1)
    for i, p in ipairs(programs) do
      p:Resume()
    end
    if isOff("scrolllock") then
      break
    end
  end

  for i, p in ipairs(programs) do
    p:Destroy()
  end
end

function test2()
  action = Resource:new()
  h = CdClick:new{holdTime = -1, key = "1", priority = 0, resources = {action}}
  print(h.resources)
  h2 = h:new{key = "2", priority = 1}
  print(h2.resources)
  m = WhenModIsOn:new{mod = "mouseleft", program = h2}
  c = CdClick:new{
    priority = 10,
    key = "3",
    resources = {action},
    cycleTime = 1000,
    holdTime = 100,
  }

  runPrograms({h,m,c})
  Sleep(5000)
    ReleaseKey("1")
    ReleaseKey("2")
    --ReleaseKey("3")
end

function OnEvent(event, arg)
  --OutputLogMessage("event = %s, arg = %s\n", event, arg);
-- [[
    if (event == "MOUSE_BUTTON_PRESSED") and arg == 9 then
      test2()
    end
--]]
end


Account = {balance = 0}
    
function Account:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Account:deposit (v)
  self.balance = self.balance + v
end

function Account:withdraw (v)
  if v > self.balance then print("insufficient funds") end
  self.balance = self.balance - v
end

function example()
  a = Account:new()
  a:deposit(100)
  a:withdraw(200)
  print("a", a.balance)
  b = Account:new()
  b:deposit(300)
  b:withdraw(200)
  print("b",b.balance)
  print("a",a.balance)
end


function func_selector()
  --mouse_move = is_on("capslock")
--switch_d4()
--switch_temp()
--switch_cru_condemn()
--switch_cru_bombardment()
--switch_cru_bombardment_tp()
--switch_cru_foth()
--switch_cru_foth2()
--switch_monk_tempest()
--switch_monk_water()
--switch_monk_fire()
--switch_monk_tempest_fire()
--switch_wiz_blast()
--switch_wiz_ice_orb()
--switch_wiz_meteor()
--switch_dh_knife2()
--switch_dh_knife_season27()
--switch_dh_knife_season27_2()
switch_dh_strafe2_s28()
--switch_dh_strafe2()
--switch_dh_strafe_entangle()
--switch_dh_strafe_support()
--switch_dh_multishoot()
--switch_nec_bloodnova()
  mouse_move = false
end


function d4_left_pressed()
  release("1")
  
end

function d4_right_released()
  press("1")
end

function switch_d4()
  switch_operations4({
    ["1"] = -1,
    ["2"] = 1600,
    ["3"] = 1000,
    ["4"] = 1000,
    --["q"] = 500,
  },
  {nil, {"2"}, d4_left_pressed, d4_right_released},
  {nil, {}}
  )
end


function switch_temp()
  --cd_click("2", 120000)
  --cd_click("3", 120000)
  --cd_click("4", 120000)
  switch_operations4({
    ["1"] = -1,
    ["2"] = {5000, -500},
    ["3"] = 500,
    ["4"] = 500,
    ["q"] = 500,
    ["mouseright"] = 1450,
  },
  {"backslash", {"1","3","mouseright"}},
  {nil, {}}
  )
end

---- click utilities ----

function set_on_map(key_cd_map)
  for key, cd in pairs(key_cd_map) do
    if cd == -1 then
      set_on(key)
    end
  end
end

function set_off_map(key_cd_map)
  for key, cd in pairs(key_cd_map) do
    if cd == -1 then
      set_off(key)
    end
  end
end

---- cooldown click functions ----

key_times={}

function last_key_time(key_code)
  local last_key
  last_key = key_times[key_code]
  if (last_key == nil) then
    -- return a large negative number to prevent cooldown
    return -10000000
  end
  return last_key
end

function cd_click(key_code, cd)
  -- align:
  -- 0, nil: unaligned
  -- >0: align to the next point
  -- <0: align to the previous point
  if MOUSE_WHEELS[key_code] ~= nil then
    return cd_click_mouse_wheel(key_code, cd)
  end
  
  local align
  if type(cd) == "table" then
    align = cd[2]
    cd = cd[1]
  else
    align = 0
  end
  
  local curr_time
  local prev_time
  local time_diff
  local click_time
  curr_time = GetRunningTime()
  prev_time = last_key_time(key_code)
  if prev_time < 0 then
    prev_time = curr_time - cd
  end
  time_diff = curr_time - last_key_time(key_code)
  if time_diff >= cd then
    click(key_code)
    if align == 0 or align == nil then
      click_time = curr_time
    elseif align > 0 then
      click_time = curr_time - time_diff % align
      if click_time < curr_time then
        click_time = click_time + align
      end
    else
      click_time = curr_time - time_diff % (-align)
    end
    if key_code == "mouseright" then
     print(time_diff)
    end
    key_times[key_code] = click_time
    return true
  else
    return false
  end
end

function cd_macro(macro, cd)
  local curr_time
  curr_time = GetRunningTime()
  if curr_time - last_key_time(macro) >= cd then
    PlayMacro(macro)
    key_times[macro] = GetRunningTime()
    return true
  else
    return false
  end
end

function cd_func(name, func, cd)
  local curr_time
  curr_time = GetRunningTime()
  if curr_time - last_key_time(name) >= cd then
    func()
    key_times[name] = GetRunningTime()
    return true
  else
    return false
  end
end

MIN_MOUSEWHEEL_INTERVAL=100
function cd_click_mouse_wheel(key_code, cd)
  local curr_time
  curr_time = GetRunningTime()
  if curr_time - last_key_time(key_code) >= cd then
    for mouse_wheel_code, value in pairs(MOUSE_WHEELS) do
      if curr_time - last_key_time(mouse_wheel_code) < MIN_MOUSEWHEEL_INTERVAL then
        return false
      end
    end
    click(key_code)
    key_times[key_code] = GetRunningTime()
    return true
  else
    return false
  end
end

function check_cooldown(key_code, cd)
  local curr_time
  curr_time = GetRunningTime()
  if curr_time - last_key_time(key_code) >= cd then
    return true
  else
    return false
  end
end

---- event engine ----
EXECUTING_EVENTS=false
SCHEDULED_EVENTS={}
NEW_SCHEDULED_EVENTS={}
-- event={name, func_wrap, scheduled_time}
function exec_events()
  EXECUTING_EVENTS=true
  NEW_SCHEDULED_EVENTS={}
  local curr_time
  curr_time = GetRunningTime()
  local func_wrap
  local scheduled_time
  for i, event in ipairs(SCHEDULED_EVENTS) do
    name, func_wrap, scheduled_time = unpack(event)
    if curr_time >= scheduled_time then
      func_wrap()
    else
      table.insert(NEW_SCHEDULED_EVENTS, event)
    end
  end
  SCHEDULED_EVENTS=NEW_SCHEDULED_EVENTS
  NEW_SCHEDULED_EVENTS={}
  EXECUTING_EVENTS=false
end

function add_event(event)
  if EXECUTING_EVENTS then
    table.insert(NEW_SCHEDULED_EVENTS, event)
  else
    table.insert(SCHEDULED_EVENTS, event)
  end
end

function clear_all_events()
  SCHEDULED_EVENTS={}
  NEW_SCHEDULED_EVENTS={}
end

function clear_events(clear_name)
  local temp_events
  temp_events = {}
  for i, event in ipairs(SCHEDULED_EVENTS) do
    name, func_wrap, scheduled_time = unpack(event)
    if name ~= clear_name then
      table.insert(temp_events, event)
    end
  end
  SCHEDULED_EVENTS = temp_events
  
  temp_events = {}
  for i, event in ipairs(NEW_SCHEDULED_EVENTS) do
    name, func_wrap, scheduled_time = unpack(event)
    if name ~= clear_name then
      table.insert(temp_events, event)
    end
  end
  NEW_SCHEDULED_EVENTS = temp_events
end

function closure(func, ...)
  return function()
    func(unpack(arg))
  end
end

function settimeout(name, func_wrap, cd)
  local curr_time
  curr_time = GetRunningTime()
  add_event({name, func_wrap, curr_time + cd})
end

function schedule_loop_func(name, func, cd, ...)
  local func_args=arg
  local function loop_func()
    local ret_val
    local my_cd
    ret_val = func(unpack(func_args))
    if ret_val == false then -- ret_val == nil is OK
      my_cd = 0
    else
      my_cd = cd
    end
    settimeout(name, loop_func, my_cd)
  end
  settimeout(name, loop_func, 0)
end


---- D3 specific functions ----
function click_key_cd_map(key_cd_map)
  for key, cd in pairs(key_cd_map) do
    cd_click(key, cd)
  end
end

function edge_trigger(old_val, new_val, up_func, down_func)
  if old_val ~= new_val then
    if new_val then
      up_func()
    else
      down_func()
    end
  end
  return new_val
end


function trigger_functions_from_args(trigger_args, triggering_key)
  local key_replace
  local avoid_keys
  local internal_press_func
  local internal_release_func
  
  if trigger_args == nil then
    trigger_args={nil,{}}
  end
  
  key_replace, avoid_keys, internal_press_func, internal_release_func = unpack(trigger_args)

  table.insert(avoid_keys, triggering_key)
  
  local function press_func()
    if key_replace ~= nil then
      set_on(key_replace)
    end
    if internal_press_func ~= nil then
      internal_press_func()
    end
  end
  
  local function release_func()
    if internal_release_func ~= nil then
      internal_release_func()
    end
    if key_replace ~= nil then
      set_off(key_replace)
    end
  end
  
  return press_func, release_func
end


mouse_move=false
function run_processes(process_list, left_process, right_process)
  local mouseleft_autoclick_interval = 200
  local mouseright_autoclick_interval = 200
  
  local enable_left_trigger
  local left_press_func
  local left_release_func
  local left_triggering
  
  enable_left_trigger = left_trigger ~= nil
  left_press_func, left_release_func = trigger_functions_from_args(left_trigger, "mouseleft")
  left_triggering = false
  
  local enable_right_trigger
  local right_press_func
  local right_release_func
  local right_triggering
  
  enable_right_trigger = right_trigger ~= nil and key_cd_map["mouseright"] ~= -1
  right_press_func, right_release_func = trigger_functions_from_args(right_trigger, "mouseright")
  right_triggering = false
  
  
  local left_replace
  local mouseleft_autoclick_enabled
  
  if left_trigger == nil then
    left_trigger={}
  end
  left_replace = left_trigger[1]
  mouseleft_autoclick_enabled = left_replace ~= nil
  
  while true do
    click_key_cd_map(key_cd_map)
    exec_events()
    Sleep(1)
    if mouse_move then
      x, y = GetMousePosition()
      xx = x - 32768
      yy = y - 30000
      d = math.sqrt(xx*xx + yy*yy)
      if d > 4096 then
         x = 32768 + xx*4096/d
         y = 30000 + yy*4096/d
         MoveMouseToVirtual(x, y)
      end
    end

    if is_off("scrolllock") then
      set_off_map(key_cd_map)
      break
    end
    if enable_left_trigger then
      left_triggering = edge_trigger(
        left_triggering,
        is_on("mouseleft"),
        left_press_func,
        left_release_func
      )
    end
    if left_triggering and mouseleft_autoclick_enabled then
      cd_func("release_then_press_mouseleft", release_then_press_mouseleft, mouseleft_autoclick_interval)
    end
    if enable_right_trigger then
      right_triggering = edge_trigger(
        right_triggering,
        is_on("mouseright"),
        right_press_func,
        right_release_func
      )
    end
    if right_triggering and mouseright_autoclick_enabled then
      cd_func("release_then_press_mouseright", release_then_press_mouseright, mouseright_autoclick_interval)
    end
  end
  if enable_left_trigger then
    left_release_func()
  end
  if enable_right_trigger then
    right_release_func()
  end
  clear_all_events()
  set_off_map(key_cd_map)
end


---- Functions for D3 Builds ----

knife_press_1_delay=360
function knife_press_1()
  press("1")
  settimeout("mouseright", knife_release_1, knife_press_1_delay)
end
function knife_release_1()
  release("1")
  settimeout("mouseright", knife_press_1, 1950 - knife_press_1_delay)
end
function knife_mouseright_pressed()
  settimeout("mouseright", knife_press_1, 1950)
  release("1")
end

function knife_mouseright_released()
  clear_events("mouseright")
  press("1")
end

function switch_dh_knife2()
  cd_click("2", 60000)
  switch_operations4({
    ["1"] = -1,
    ["3"] = 500,
    ["4"] = {500, -500},
  },
  {"backslash", {}},
  {nil, {}, knife_mouseright_pressed, knife_mouseright_released}
  )
end

dh_strafe_start_time=0
dh_strafe_curr_time=0
dh_strafe_pressed=""
dh_strafe_1_time=340
dh_strafe_1_extended_time=2000
dh_strafe_3_time=200
function dh_strafe2_press3()
  release("1")
  dh_strafe_pressed = "3"
  dh_strafe_start_time = GetRunningTime()
  press("3")
end
function dh_strafe2_press1()
  release("3")
  dh_strafe_pressed = "1"
  dh_strafe_start_time = GetRunningTime()
  press("1")
end

function dh_strafe2_next_op()
  if dh_strafe_pressed == "1" then
    dh_strafe_curr_time = GetRunningTime()
    if is_on("capslock") then
      time_diff = dh_strafe_1_extended_time
    else
      time_diff = dh_strafe_1_time
    end
    if dh_strafe_curr_time - dh_strafe_start_time >= time_diff then
      dh_strafe2_press3()
    end
  elseif dh_strafe_pressed == "3" then
    dh_strafe_curr_time = GetRunningTime()
    if dh_strafe_curr_time - dh_strafe_start_time >= dh_strafe_3_time then
      dh_strafe2_press1()
    end
  else
    dh_strafe2_press3()
  end
end

function dh_strafe2_reset()
  dh_strafe_start_time=0
  shift_mouseleft_start_time=0
  release("1")
  release("3")
  release("lshift")
  dh_strafe_pressed=""
  shift_mouseleft_pressed=""
end

function dh_strafe2_mouseleft_released()
end

function switch_dh_strafe2()
  switch_operations4({
    [dh_strafe2_next_op] = 1,
    ["2"] = 4500,
    ["4"] = {500, -500},
    ["q"] = 500,
    ["mouseright"] = 500,
  },
  {"backslash", {dh_strafe2_next_op}, dh_strafe2_reset, dh_strafe2_mouseleft_released}
  )
  dh_strafe2_reset()
end


last_release_switch=-1
function OnEvent(event, arg)
  OutputLogMessage("event = %s, arg = %s\n", event, arg)
  --OutputLogMessage("time = %s event = %s, arg = %s\n", GetRunningTime(), event, arg)

  SCHEDULED_EVENTS={}
  
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