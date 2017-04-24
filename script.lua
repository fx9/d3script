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

function loop_operations(key_cd_map)
    set_on_map(key_cd_map)
    while true do
        click_key_cd_map(key_cd_map)
        Sleep(50)
        if is_off("shift", callback_set_off_map(key_cd_map)) then
            return
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

function simple_major_attack()
    loop_operations({
        ["mouseleft"] = -1,
    })
end

function click_mapping(modifier_to_check, key_to_click)
    if is_on(modifier_to_check) then
        click(key_to_click)
        set_off(modifier_to_check)
        return true
    end
    return false
end

function negative_click_mapping(modifier_to_check, key_to_click)
    if is_off(modifier_to_check) then
        click(key_to_click)
        set_on(modifier_to_check)
        return true
    end
    return false
end

-- 此处是scrolllock控制的脚本
-- 用--关掉不需要的按键
-- 其他按键 = 号后的数字表示按键间隔的毫秒数，500 即 0.5 秒
-- 用 -1 表示此键一直按住
-- mouseleft表示鼠标左键
-- mouseright表示鼠标右键
-- 这个脚本表示 一直按住1，每0.5秒按一次34
function example()
    switch_operations({
        ["1"] = -1,
        -- ["2"] = 500,
        ["3"] = 500,
        ["4"] = 500,
        -- ["mouseleft"] = -1,
        -- ["mouseright"] = 500,
    
    -- 此处spacebar表示将空格当作强制移动键
    }, "spacebar")
end

-- 用两个函数给不同的按键触发，可以令不同按键启动不同的脚本配置
function example2()
    switch_operations({
        -- 增加了鼠标45号键以及鼠标滚轮的支持，注意滚轮无法按住
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
    -- 像这样把第二个参数去掉可以禁用强制移动
    })
end

function cast_wiz_archon()
    release("lshift")
    press("lshift")
    click("mouseleft")
    release("lshift")
    Sleep(100)
    curr_time = GetRunningTime()
    end_time = curr_time + 20000
    next_time = curr_time + 31900
    click("1")
    Sleep(100)
    press("mouseright")
    init_time = curr_time + 500
    init_done = false
    warn_time = end_time - 1500
    warned = false
    while curr_time < end_time do
        if not warned and curr_time >= warn_time then
            click("0")
            warned = true
        end
        if not init_done and curr_time >= init_time then
            click("2")
            init_done = true
        end
        Sleep(50)
        if is_off("capslock", callback_set_off("mouseright")) then
            return false
        end
        if is_off("scrolllock") then
            break
        end
        negative_click_mapping("mouseright", "3")
        curr_time = GetRunningTime()
    end
    set_off("mouseright")
    set_off("scrolllock")
    return wait_wiz_archon(next_time)
end
   

function wait_wiz_archon(end_time)
    alter_mouseleft = false
    new_alter_mouseleft = false
    mouseleft_alternate = "spacebar"
    set_on("2")
    while GetRunningTime() < end_time or is_on("ctrl") do
        Sleep(50)
        if is_off("capslock", callback_set_off("2", mouseleft_alternate)) then
            return false
        end
        if is_on("scrolllock", callback_set_off("2", mouseleft_alternate)) then
            return true
        end
        new_alter_mouseleft = (mouseleft_alternate ~= nil and running and is_on("mouseleft") and is_off("ctrl"))
        if alter_mouseleft ~= new_alter_mouseleft then
            alter_mouseleft = new_alter_mouseleft
            if alter_mouseleft then
                set_on(mouseleft_alternate)
            else
                set_off(mouseleft_alternate)
            end
        end
    end
    set_off("2")
    set_on("scrolllock")
    return true
end
    
   
function switch_wiz_archon()
    click("3", "4")
    set_on("capslock")
    Sleep(200)
    set_off("scrolllock")
    Sleep(200)
    curr_time = GetRunningTime()
    if not wait_wiz_archon(curr_time+100000) then
        return
    end
    while cast_wiz_archon() do
        OutputLogMessage("time = %d\n", GetRunningTime())
    end
    set_off("scrolllock")
    set_off("capslock")
end

function switch_cru_hammer()
    switch_operations({
        ["1"] = -1,
        ["3"] = 500,
        ["4"] = 500,
    }, "spacebar")
end

function loop_monk()
    loop_operations({
        ["mouseleft"] = -1,
        ["2"] = 500,
        ["3"] = 500,
        ["4"] = 500,
        ["mouseright"] = 500,
    })
end

function switch_dh_multishoot()
    switch_operations({
        ["1"] = -1,
        ["3"] = 3000,
        ["4"] = 500,
    }, "spacebar")
end

function switch_dh_cluster()
    switch_operations({
        ["1"] = -1,
        ["2"] = 8000,
        ["3"] = 500,
        ["4"] = 500,
        ["mouseleft"] = 3000,
    }, "spacebar")
end

function switch_dh_grenade()
    switch_operations({
        ["1"] = -1,
        ["3"] = 500,
        ["4"] = 500,
    }, "spacebar")
end

function switch_dh_knife()
    cd_click("2", 60000)
    switch_operations({
        ["1"] = -1,
        ["3"] = 500,
        ["4"] = 500,
    }, "spacebar")
end

function switch_wiz()
    PlayMacro("shift-click")
    switch_operations({
        ["1"] = -1,
        ["2"] = 4500,
        ["3"] = 60000,
        ["4"] = 70000,
    }, "spacebar")
end

function switch_temp()
    switch_operations({
        ["1"] = -1,
        ["2"] = 500,
        ["3"] = 500,
        --["4"] = 70000,
    }, "spacebar")
end


function switch_cru_hammer2()
    switch_operations({
        ["1"] = -1,
        ["2"] = 500,
        ["3"] = 500,
        ["4"] = 500,
    }, "spacebar")
end

last_release_switch=-1

function OnEvent(event, arg)
    OutputLogMessage("event = %s, arg = %s\n", event, arg)

    -- 此处 arg == 8 将 8 替换为你刚才分配了 scrolllock 键的按键编号
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
    
    -- 此处 arg == 9 将 9 替换为另一个分配了 scrolllock 键的按键编号
    if (arg == 9) then
        if (event == "MOUSE_BUTTON_PRESSED") then
            if GetRunningTime()-last_release_switch <= 5 then
                return
            end
            -- 此处调用你定义的其他函数
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