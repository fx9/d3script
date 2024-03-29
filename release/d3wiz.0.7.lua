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
}

mouse_map={
    ["mouseleft"] = 1,
    ["mousemid"] = 2,
    ["mouseright"] = 3,
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
        if mouse_map[key] == nil then
            ReleaseKey(key)
        else
            ReleaseMouseButton(mouse_map[key])
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
        if mouse_map[key] == nil then
            PressKey(key)
        else
            PressMouseButton(mouse_map[key])
        end
    end
end

function click(...)
    for i, key in ipairs(arg) do
        if mouse_map[key] == nil then
            PressAndReleaseKey(key)
        else
            PressAndReleaseMouseButton(mouse_map[key])
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

function callback_set_on(...)
    function callback()
        set_on_list(arg)
    end
    return callback
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

function callback_set_off(...)
    function callback()
        set_off_list(arg)
    end
    return callback
end

function callback_set_off_map(key_cd_map)
    function callback()
        for key, cd in pairs(key_cd_map) do
            if cd == -1 then
                set_off(key)
            end
        end
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
    curr_time = GetRunningTime()
    if curr_time - last_key_time(key_code) >= cd then
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

function loop_operations(key_cd_map)
    for key, cd in pairs(key_cd_map) do
        if cd == -1 then
            set_on(key)
        end
    end
    while true do
        for key, cd in pairs(key_cd_map) do
            if cd ~= -1 then
                cd_click(key, cd)
            end
        end
        Sleep(50)
        if is_off("shift", callback_set_off_map(key_cd_map)) then
            return
        end
    end
end

function switch_operations(key_cd_map, mouseleft_alternate)
    for key, cd in pairs(key_cd_map) do
        if cd == -1 then
            set_on(key)
        end
    end
    set_on("capslock")
    running = true
    alter_mouseleft = false
    new_alter_mouseleft = false
    while true do
        for key, cd in pairs(key_cd_map) do
            if cd ~= -1 and not (key == "mouseleft" and alter_mouseleft) then
                cd_click(key, cd)
            end
        end
        Sleep(100)
        if is_off("scrolllock", callback_set_off_map(key_cd_map)) then
            break
        end
        caps_on = is_on("capslock")
        if caps_on ~= running then
            running = caps_on
            if running then
                for key, cd in pairs(key_cd_map) do
                    if cd == -1 then
                        set_on(key)
                    end
                end
            else
                for key, cd in pairs(key_cd_map) do
                    if cd == -1 then
                        set_off(key)
                    end
                end
            end
        end
        new_alter_mouseleft = (mouseleft_alternate ~= nil and running and is_on("mouseleft"))
        if alter_mouseleft ~= new_alter_mouseleft then
            alter_mouseleft = new_alter_mouseleft
            if alter_mouseleft then
                set_on(mouseleft_alternate)
            else
                set_off(mouseleft_alternate)
            end
        end
    end
    set_off("capslock")
    if mouseleft_alternate ~= nil then
        set_off(mouseleft_alternate)
    end
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

last_release_switch=-1

function OnEvent(event, arg)
    OutputLogMessage("event = %s, arg = %s\n", event, arg)

	-- 此处 arg == 8 将 8 替换为你刚才分配了 scrolllock 键的按键编号
    if (event == "MOUSE_BUTTON_PRESSED" and arg == 8) then
        if GetRunningTime()-last_release_switch <= 5 then
            return
        end
        switch_wiz_archon()
    end 

	-- 此处和上面一并修改， arg == 8 将 8 替换为你刚才分配了 scrolllock 键的按键编号
    if (event == "MOUSE_BUTTON_RELEASED" and arg == 8) then
        last_release_switch=GetRunningTime()
    end 

end