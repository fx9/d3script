function print(name, value)
    OutputLogMessage("%s = %s\n", tostring(name), tostring(value))
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
    function callback()
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
    function callback()
        set_on_list(arg)
    end
    return callback
end

function callback_set_on_map(key_cd_map)
    function callback()
        set_on_map(key_cd_map)
    end
    return callback
end

function callback_set_off(...)
    function callback()
        set_off_list(arg)
    end
    return callback
end

function callback_set_off_map(key_cd_map)
    function callback()
        set_off_map(key_cd_map)
    end
    return callback
end

---- cooldown click functions ----

key_times={}

function last_key_time(key_code)
    last_key=key_times[key_code]
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
    curr_time = GetRunningTime()
    if curr_time - last_key_time(key_code) >= cd then
        click(key_code)
        key_times[key_code] = GetRunningTime()
        return true
    else
        return false
    end
end

MIN_MOUSEWHEEL_INTERVAL=100
function cd_click_mouse_wheel(key_code, cd)
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
    curr_time = GetRunningTime()
    if curr_time - last_key_time(key_code) >= cd then
        return true
    else
        return false
    end
end

---- D3 specific functions ----

function click_key_cd_map(key_cd_map, avoid_map)
    for key, cd in pairs(key_cd_map) do
        -- only click when avoid_map[key] is nil or false
        if cd ~= -1 and (avoid_map == nil or not avoid_map[key])then
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

function switch_operations(key_cd_map, replace_key)
    set_off("capslock")
    set_on_map(key_cd_map)
    running = true
    do_replace = false
    enable_replace = replace_key ~= nil and key_cd_map["mouseleft"] ~= -1
    while true do
        avoid_map = {
            ["mouseleft"] = do_replace,
        }
        click_key_cd_map(key_cd_map, avoid_map)
        Sleep(50)
        if is_off("scrolllock", callback_set_off_map(key_cd_map)) then
            break
        end
        running = edge_trigger(
            running,
            not (is_on("ctrl") or is_on("alt") or is_on("capslock")),
            callback_set_on_map(key_cd_map),
            callback_set_off_map(key_cd_map)
        )
        if enable_replace then
            do_replace = edge_trigger(
                do_replace,
                running and is_on("mouseleft"),
                callback_set_on(replace_key),
                callback_set_off(replace_key)
            )
        end
    end
    if enable_replace then
        set_off(replace_key)
    end
    set_off("capslock")
end

-- �˴���scrolllock���ƵĽű�
-- ��--�ص�����Ҫ�İ���
-- �������� = �ź�����ֱ�ʾ��������ĺ�������500 �� 0.5 ��
-- �� -1 ��ʾ�˼�һֱ��ס
-- mouseleft��ʾ������
-- mouseright��ʾ����Ҽ�
-- ����ű���ʾ һֱ��ס1��ÿ0.5�밴һ��34
function example()
    switch_operations({
        ["1"] = -1,
        -- ["2"] = 500,
        ["3"] = 500,
        ["4"] = 500,
        -- ["mouseleft"] = -1,
        -- ["mouseright"] = 500,
    
    -- �˴�spacebar��ʾ���ո���ǿ���ƶ���
    }, "spacebar")
end

-- ��������������ͬ�İ��������������ͬ����������ͬ�Ľű�����
function example2()
    switch_operations({
        -- ���������45�ż��Լ������ֵ�֧�֣�ע������޷���ס
        ["mouse4"] = -1,
        ["mouse5"] = 500,
        ["mousewheeldown"] = 500,
        ["mousewheelup"] = 500,
    }, "spacebar")
end

function example3()
    switch_operations({
        ["1"] = -1, 
        ["2"] = 4500,
        ["3"] = 60000,
        ["4"] = 70000,
    -- �������ѵڶ�������ȥ�����Խ���ǿ���ƶ�
    })
end

last_release_switch=-1

function OnEvent(event, arg)
    OutputLogMessage("event = %s, arg = %s\n", event, arg)

    -- �˴� arg == 8 �� 8 �滻Ϊ��ղŷ����� scrolllock ���İ������
    if (arg == 8) then
        if (event == "MOUSE_BUTTON_PRESSED") then
            if GetRunningTime()-last_release_switch <= 5 then
                return
            end
            example()
        end
        if (event == "MOUSE_BUTTON_RELEASED") then
            last_release_switch=GetRunningTime()
        end 
    end 
    
    -- �˴� arg == -1 �� -1 �滻Ϊ��һ�������� scrolllock ���İ������
	-- Ĭ�ϵ� -1 ���ᱻ�κΰ�������
    if (arg == -1) then
        if (event == "MOUSE_BUTTON_PRESSED") then
            if GetRunningTime()-last_release_switch <= 5 then
                return
            end
            -- �˴������㶨�����������
            example2()
        end
        if (event == "MOUSE_BUTTON_RELEASED") then
            last_release_switch=GetRunningTime()
        end 
    end 
	
    if (event == "MOUSE_BUTTON_PRESSED" and arg == 10) then
        simple_major_attack()
    end 

end