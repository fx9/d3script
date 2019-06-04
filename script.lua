function print(name, value)
  OutputLogMessage("%s = %s\n", tostring(name), tostring(value))
end

function func_selector()
--switch_temp()
--switch_cru_condemn()
--switch_cru_hammer()
switch_dh_knife2()
--switch_dh_multishoot2()
--switch_dh_rapidshot()
--switch_nec_bloodnova()
--switch_znec()
end

function switch_temp()
  switch_operations4({
    --["lshift"] = -1,
    ["1"] = -1,
    ["2"] = 500,
    ["3"] = 500,
    ["4"] = 500,
  },
  {"backslash", {"2","3","4"}}
  )
end

---- click utilities ----

modifier_check_table={
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

mouse_map={
  ["mouseleft"] = 1,
  ["mousemid"] = 2,
  ["mouseright"] = 3,
  ["mouse4"] = 4,
  ["mouse5"] = 5,
}

mouse_wheels={
  ["mousewheelup"] = 1,
  ["mousewheeldown"] = -1,
}

lock_keys={
  ["scrolllock"] = 1,
  ["capslock"] = 1,
  ["numlock"] = 1,
}

function is_on(flag, true_callback, false_callback)
  if modifier_check_table[flag]() then
    if true_callback ~= nil then
      true_callback()
    end
    return true
  else
    if false_callback ~= nil then
      false_callback()
    end
    return false
  end
end

function is_off(flag, true_callback, false_callback)
  return not is_on(flag, false_callback, true_callback)
end

function release_list(keys)
  for i, key in ipairs(keys) do
    if mouse_map[key] ~= nil then
      ReleaseMouseButton(mouse_map[key])
    elseif mouse_wheels[key] == nil then
      ReleaseKey(key)
    end
  end
end

function release(...)
  release_list(arg)
end

function callback_release(...)
  local function callback()
    release_list(arg)
  end
  return callback
end

function press(...)
  for i, key in ipairs(arg) do
    if mouse_map[key] ~= nil then
      PressMouseButton(mouse_map[key])
    elseif mouse_wheels[key] ~= nil then
      MoveMouseWheel(mouse_wheels[key])
    else
      PressKey(key)
    end
  end
end

function click(...)
  for i, key in ipairs(arg) do
    if mouse_map[key] ~= nil then
      PressAndReleaseMouseButton(mouse_map[key])
    elseif mouse_wheels[key] ~= nil then
      MoveMouseWheel(mouse_wheels[key])
    else
      PressAndReleaseKey(key)
    end
  end
end

function set_on_list(keys)
  for i, key in ipairs(keys) do
    if lock_keys[key] ~= nil then
      if is_off(key) then
        click(key)
      end
    else
      release(key)
      press(key)
    end
  end
end

function set_on(...)
  set_on_list(arg)
end

function set_off_list(keys)
  for i, key in ipairs(keys) do
    if lock_keys[key] ~= nil then
      if is_on(key) then
        click(key)
      end
    else
      release(key)
    end
  end
end

function set_off(...)
  set_off_list(arg)
end

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

function callback_set_on(...)
  local function callback()
    set_on_list(arg)
  end
  return callback
end

function callback_set_on_delay(key, delay)
  local function callback()
    Sleep(delay)
    set_on(key)
  end
  return callback
end

function callback_set_on_map(key_cd_map)
  local function callback()
    set_on_map(key_cd_map)
  end
  return callback
end

function callback_set_off(...)
  local function callback()
    set_off_list(arg)
  end
  return callback
end

function callback_set_off_map(key_cd_map)
  local function callback()
    set_off_map(key_cd_map)
  end
  return callback
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
  if mouse_wheels[key_code] ~= nil then
    return cd_click_mouse_wheel(key_code, cd)
  end
  local curr_time
  curr_time = GetRunningTime()
  if curr_time - last_key_time(key_code) >= cd then
    click(key_code)
    key_times[key_code] = GetRunningTime()
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
    for mouse_wheel_code, value in pairs(mouse_wheels) do
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
GLOBAL_AVOID_MAP={}

function globally_avoid(...)
  for i, key_or_func in ipairs(arg) do
    if GLOBAL_AVOID_MAP[key_or_func] == nil then
      GLOBAL_AVOID_MAP[key_or_func] = 0
    end
    GLOBAL_AVOID_MAP[key_or_func] = GLOBAL_AVOID_MAP[key_or_func] + 1
  end
end

function globally_unavoid(...)
  for i, key_or_func in ipairs(arg) do
    if GLOBAL_AVOID_MAP[key_or_func] ~= nil then
      GLOBAL_AVOID_MAP[key_or_func] = GLOBAL_AVOID_MAP[key_or_func] - 1
      if GLOBAL_AVOID_MAP[key_or_func] == 0 then
        GLOBAL_AVOID_MAP[key_or_func] = nil
      end
    end
  end
end

function click_avoid(key_or_func)
  if GLOBAL_AVOID_MAP[key_or_func] then
    return false
  end
  if type(key_or_func) == "string" then
    click(key_or_func)
  else
    key_or_func()
  end
  return true
end

function click_key_cd_map(key_cd_map, avoid_map)
  if avoid_map == nil then
    avoid_map = GLOBAL_AVOID_MAP
  end
  for key, cd in pairs(key_cd_map) do
    -- only click when avoid_map[key] is nil or false
    if cd ~= -1 and not avoid_map[key] then
      cd_click(key, cd)
    end
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
  
  if avoid_keys == nil then
    avoid_keys = {}
  end
  table.insert(avoid_keys, triggering_key)
  
  local function press_func()
    globally_avoid(unpack(avoid_keys))
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
    globally_unavoid(unpack(avoid_keys))
  end
  
  return press_func, release_func
end


function switch_operations4(key_cd_map, left_trigger, right_trigger)
  local mouseleft_autoclick_interval = 200
  set_on_map(key_cd_map)
  
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
  
  local function release_then_press_mouseleft()
    local lshift_on=false
    if is_on("lshift") then
      lshift_on=true
      release("lshift")
    end
    release(left_replace)
    release("mouseleft")
    press(left_replace)
    if lshift_on then
      press("lshift")
    end
    press("mouseleft")
  end
    
  while true do
    click_key_cd_map(key_cd_map)
    exec_events()
    Sleep(50)
    if is_off("scrolllock", callback_set_off_map(key_cd_map)) then
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
    ["4"] = 500,
  },
  {"backslash", {}},
  {nil, {}, knife_mouseright_pressed, knife_mouseright_released}
  )
end

function multishoot_mouseright_pressed()
  release("2")
  press("1")
  Sleep(400)
  release("1")
  settimeout("mouseright", knife_press_1, 1950)
end

function multishoot_mouseright_released()
  clear_events("mouseright")
  release("1")
  press("2")
end

function switch_dh_multishoot2()
  switch_operations4({
    ["2"] = -1,
    ["3"] = 4000,
    ["4"] = 500,
  },
  {"backslash", {"3"}},
  {nil, {}, multishoot_mouseright_pressed, multishoot_mouseright_released}
  )
end

function switch_dh_rapidshot()
  switch_operations4({
    ["1"] = -1,
    ["2"] = 500,
    ["3"] = 500,
    ["4"] = 500,
  },
  {"backslash", {"3"}}
  )
end

function cru_condemn_mouseleft_pressed()
  schedule_loop_func("mouseleft", click, 900, "1")
end

function cru_condemn_mouseleft_released()
  clear_events("mouseleft")
end

function switch_cru_condemn()
  switch_operations4({
    ["1"] = 600,
    ["2"] = 2000,
    ["3"] = 500,
    ["4"] = 500,
    ["mouseright"] = 500,
  },
  {"backslash", {"mouseright", "1"}, cru_condemn_mouseleft_pressed, cru_condemn_mouseleft_released}
  )
end

function switch_cru_hammer()
  switch_operations4({
    ["1"] = -1,
    ["2"] = 500,
    ["3"] = 500,
    ["4"] = 500,
  },
  {"backslash", {"2", "3"}}
  )
end

function switch_nec_bloodnova()
  switch_operations4({
    ["1"] = -1,
    ["2"] = 500,
    ["3"] = 5000,
    ["4"] = 500,
  },
  {"backslash", {"3", "4"}}
  )
end

function switch_znec()
  switch_operations4({
    --["lshift"] = -1,
    ["1"] = -1,
    ["2"] = 500,
    --["3"] = 250,
    ["4"] = 200,
  },
  {"backslash", {"4"}}
  )
end
last_release_switch=-1

function OnEvent(event, arg)
  OutputLogMessage("event = %s, arg = %s\n", event, arg)

  SCHEDULED_EVENTS={}

  local funcs={
    [8] = func_selector,
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