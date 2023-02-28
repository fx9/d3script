function print(name, value)
  OutputLogMessage("%s = %s\n", tostring(name), tostring(value))
end

function func_selector()
  --mouse_move = is_on("capslock")
--switch_temp()
--switch_cru_condemn()
--switch_cru_bombardment()
--switch_cru_bombardment_tp()
--switch_cru_foth()
--switch_cru_foth2()
--switch_wiz_blast()
--switch_monk_tempest()
--switch_monk_water()
--switch_monk_fire()
--switch_monk_tempest_fire()
--switch_dh_knife2()
--switch_dh_knife_season27()
--switch_dh_knife_season27_2()
--switch_dh_strafe3()
switch_dh_strafe2()
--switch_dh_strafe_entangle()
--switch_dh_strafe_support()
--switch_dh_multishoot()
--switch_nec_bloodnova()
  mouse_move = false
end


function switch_temp()
  switch_operations4({
    ["1"] = -1,
    ["2"] = {5000, -500},
    ["3"] = 3000,
    ["4"] = 500,
  },
  {"backslash", {"1"}},
  {nil, {}}
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
  for i, key_or_func in ipairs(arg) do
    if type(key_or_func) == "string" then
      key = key_or_func
      if mouse_map[key] ~= nil then
        PressAndReleaseMouseButton(mouse_map[key])
      elseif mouse_wheels[key] ~= nil then
        MoveMouseWheel(mouse_wheels[key])
      elseif key == "" then
        -- do nothing
      else
        PressAndReleaseKey(key)
      end
    else
      key_or_func()
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
  -- align:
  -- 0, nil: unaligned
  -- >0: align to the next point
  -- <0: align to the previous point
  if mouse_wheels[key_code] ~= nil then
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
  click(key_or_func)
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

mouse_move=false
function switch_operations4(key_cd_map, left_trigger, right_trigger)
  local mouseleft_autoclick_interval = 200
  local mouseright_autoclick_interval = 200
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
  key_times["release_then_press_mouseleft"] = GetRunningTime()
  
  local right_replace
  local mouseright_autoclick_enabled
  
  if right_trigger == nil then
    right_trigger={}
  end
  right_replace = right_trigger[1]
  mouseright_autoclick_enabled = right_replace ~= nil
  
  local function release_then_press_mouseright()
    local lshift_on=false
    if is_on("lshift") then
      lshift_on=true
      release("lshift")
    end
    release(right_replace)
    release("mouseright")
    press(right_replace)
    if lshift_on then
      press("lshift")
    end
    press("mouseright")
  end
  key_times["release_then_press_mouseright"] = GetRunningTime()

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


click_keys_in_order_i=0
function click_keys_in_order(keys)
  click_keys_in_order_i = click_keys_in_order_i + 1
  click_avoid(keys[click_keys_in_order_i])
  click_keys_in_order_i = click_keys_in_order_i % table.getn(keys)
end

 --[[
 // this doesn't work because one cycle is not exact 50ms
 
function flatten_keys_with_delay(keys_with_delay, interval)
  local result = {}
  local delay = 0
  for i, key_delay in ipairs(keys_with_delay) do
    table.insert(result, key_delay[1])
	delay = key_delay[2] - interval
    while(delay > 0)
    do
      table.insert(result, "")
	  delay = delay - interval
    end
  end
  return result
end

function click_keys_sequence_func(keys_with_delay)
  click_keys_in_order_i=0
  return closure(click_keys_in_order, flatten_keys_with_delay(keys_with_delay, 50))
end

--]]



click_by_offset_start_time=-999999
click_by_offset_i=0
function click_by_offset(key_offset_list, total_time)
  local curr_time = GetRunningTime()
  local curr_offset = curr_time - click_by_offset_start_time
  if click_by_offset_i == 0 then
	if curr_offset >= total_time then
	  click_by_offset_start_time = curr_time
	else
	  return
	end
  end
  local i = click_by_offset_i + 1
  local key = key_offset_list[i][1]
  local offset = key_offset_list[i][2]
  if curr_offset >= offset then
    click_avoid(key)
	if offset == 0 then
	  click_by_offset_start_time = GetRunningTime()
	end
    click_by_offset_i = i % table.getn(key_offset_list)
  end
end

function click_by_offset_func(key_offset_list, total_time)
  click_by_offset_start_time=-999999
  click_by_offset_i=0
  return closure(click_by_offset, key_offset_list, total_time)
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

function switch_dh_knife_season27()
  cd_click("2", 60000)
  click("mouseright")
  Sleep(200)
  switch_operations4({
    ["1"] = -1,
    ["3"] = {500, -500},
    ["4"] = {500, -500},
  },
  {"backslash", {}}
  )
end

function knife_season27_2_use_knife()
  press("lshift")
  Sleep(200)
  click("mouseleft")
  Sleep(300)
  release("lshift")
end
function switch_dh_knife_season27_2()
--[[
  click_keys_in_order_i = 0
  local local_func=closure(click_keys_in_order, {
    "3","mouseright","mouseright","mouseright","mouseright",
    "mouseright","mouseright","mouseright","mouseright","mouseright",
    "mouseright","mouseright","mouseright","mouseright","mouseright",
    "mouseright","mouseright","mouseright","mouseright","mouseright",
  })
--]]
  local local_func=closure(click_keys_in_order, {"","","","0","mouseright"})
  cd_click("2", 60000)
  cd_func("knife_season27_2_use_knife", knife_season27_2_use_knife, 0)
  --click("3")
  --Sleep(200)
  click("mouseright")
  Sleep(200)
  switch_operations4({
    --["t"] = 150,
    --[local_func] = 150,
    ["1"] = -1,
    ["3"] = {500, -500},
    ["4"] = {500, -500},
    --["mouseright"] = 3500,
    [local_func] = 800,
  },
  {"backslash", {"mouseright"}}
  )
end

      
function switch_dh_strafe3()
  switch_operations4({
    ["1"] = -1,
    ["2"] = 4500,
    ["3"] = 1000,
    ["4"] = {500, -500},
    ["mouseright"] = 500,
  },
  {"backslash", {"3"}}
  )
end

function switch_dh_strafe()
  switch_operations4({
    ["1"] = -1,
    ["2"] = 4500,
    ["3"] = 1000,
    ["4"] = {500, -500},
    ["mouseright"] = 500,
  },
  {"backslash", {"3"}}
  )
end

dh_strafe_start_time=0
dh_strafe_curr_time=0
dh_strafe_pressed=""
dh_strafe_1_time=340
dh_strafe_1_extended_time=2300
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
  release("1")
  release("3")
  dh_strafe_pressed=""
end

function dh_strafe2_mouseleft_released()
end

function switch_dh_strafe2()
  switch_operations4({
    [dh_strafe2_next_op] = 1,
    ["2"] = 4500,
    ["4"] = {500, -500},
    ["mouseright"] = 500,
  },
  {"backslash", {dh_strafe2_next_op}, dh_strafe2_reset, dh_strafe2_mouseleft_released}
  )
  dh_strafe2_reset()
end

function switch_dh_strafe_support()
  switch_operations4({
    ["1"] = -1,
    ["2"] = 500,
    ["3"] = 1000,
    ["4"] = {500, -500},
    ["mouseright"] = 3000,
  },
  {"backslash", {"3"}}
  )
end

function switch_dh_strafe_entangle()
  local local_func=closure(click_keys_in_order, {"2","","3","",""})
  switch_operations4({
    ["1"] = -1,
    --["2"] = 500,
    [local_func] = 500,
    ["4"] = {500, -500},
    ["mouseright"] = 500,
  },
  {"backslash", {local_func}}
  )
end


function switch_dh_multishoot()
  switch_operations4({
    ["1"] = -1,
    ["3"] = 3200,
    ["4"] = {500, -500},
  },
  {"backslash", {"3", "4"}},
  {nil, {"3"}}
  )
end


function switch_cru_foth2()
  switch_operations4({
    ["1"] = 250,
    ["2"] = 250,
    ["3"] = 250,
    ["4"] = 250,
    ["t"] = 100,
  },
  {"backslash", {}}
  )
end

function switch_cru_foth()
  local local_func=click_by_offset_func({
    {"4",0},
    {"1",4700},
    {"2",4700},
    {"3",4700},
  }, 5050)
  switch_operations4({
    ["mouseleft"] = -1,
    --["t"] = 100,
    [local_func] = 1,
  },
  {"backslash", {}}
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
    ["2"] = 1000,
    ["3"] = 500,
    ["4"] = {500, -500},
    ["mouseright"] = -1,
  },
  --{"backslash", {"mouseright"}}
  {"backslash", {"mouseright", "1"}, cru_condemn_mouseleft_pressed, cru_condemn_mouseleft_released}
 
 )
end

function cru_bombardment_click_3()
  if is_on("capslock") then
    click("3")
  end
end
function switch_cru_bombardment()
  switch_operations4({
    ["1"] = {3000, -500},
    ["2"] = {2000, -500},
    [cru_bombardment_click_3] = 500,
    ["4"] = {5000, -500},
    --["mouseright"] = 500,
  },
  {"backslash", {"1","2","4"}}
  )
end
function switch_cru_bombardment_tp()
  switch_operations4({
    ["mouseleft"] = -1,
    ["1"] = {3000, -500},
    ["2"] = {2000, -500},
    [cru_bombardment_click_3] = 500,
    ["4"] = {5000, -500},
    ["t"] = 200,
    --["mouseright"] = 500,
  },
  {"backslash", {}},
  {nil, {"1","2","4"}}
  )
end

function switch_nec_bloodnova()
  switch_operations4({
    ["1"] = -1,
    --["2"] = 500,
    ["3"] = 5000,
    ["4"] = 500,
  },
  {"backslash", {"3", "4"}}
  )
end


function switch_wiz_blast()
  cd_click("3", 90000)
  cd_click("4", 90000)
  switch_operations4({
    ["1"] = -1,
    ["2"] = 200,
  },
  {"backslash", {}}
  )
end

function monk_tempest_mouseright_pressed()
  
end
function release_and_press_1()
  release("1")
  press("1")
end
function monk_tempest_mouseright_released()
  settimeout("", release_and_press_1, 50)
end
function switch_monk_tempest()
  cd_click("3", 30000)
  switch_operations4({
    ["1"] = -1,
    ["4"] = 5000,
  },
  {"backslash", {}},
  {nil, {}, monk_tempest_mouseright_pressed, monk_tempest_mouseright_released}
  )
end

function monk_water_mouseright_pressed()
  release("1")
end
function monk_water_mouseright_released()
  settimeout("", monk_water_click_4, 50)
end
function monk_water_click_4()
  click("4")
  key_times["4"] = GetRunningTime()
  press("1")
end
function switch_monk_water()
  switch_operations4({
    ["1"] = -1,
    ["2"] = 250,
    ["3"] = 250,
    ["4"] = 3000,
    --["mouseright"] = 3000,
  },
  {"backslash", {"4"}},
  {nil, {},monk_water_mouseright_pressed,monk_water_mouseright_released}
  )
end

monk_fire_click_3_delay=500
monk_fire_click_4_delay=1000
function monk_fire_mouseright_pressed()
  release("1")
  key_times[monk_fire_click_34] = GetRunningTime()+3000-monk_fire_click_34_delay
end
function monk_fire_mouseright_released()
  --settimeout("", monk_fire_after_mouseright, 50)
  key_times[monk_fire_click_34] = GetRunningTime()+300-monk_fire_click_34_delay
  key_times["4"] = 0
end
function monk_fire_click_34()
  click("3")
  cd_click("4",monk_fire_click_4_delay)
end
function monk_fire_after_mouseright()
  click("4")
  press("1")
end
function switch_monk_fire()
  switch_operations4({
    ["1"] = -1,
    ["2"] = 250,
    [monk_fire_click_34] = monk_fire_click_3_delay,
    --["mouseright"] = 3000,
  },
  {"backslash", {monk_fire_click_34}},
  {nil, {monk_fire_click_34},monk_water_mouseright_pressed,monk_water_mouseright_released}
  )
end

function switch_monk_tempest_fire()
  switch_operations4({
    ["1"] = -1,
    --["2"] = 250,
    ["3"] = 250,
    ["4"] = 250,
    ["mouseright"] = 3000,
  },
  {"backslash", {"mouseright"}}
  )
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