event_times={}
DOUBLE_CLICK_TIME_MS=300

function last_event_time(event, arg)
    if (event_times[event] == nil) then
        return 0
    end
    last_event=event_times[event][arg]
    if (last_event == nil) then
        return 0
    end
    return last_event
end

function record_event_time(event, arg)
    if (event_times[event] == nil) then
        event_times[event] = {}
    end
    curr_event = GetRunningTime()
    OutputLogMessage("curr_event = %s\n", curr_event)
    event_times[event][arg] = curr_event
    return curr_event
end

function record_and_get_event_time_diff(event, arg)
    last_event=last_event_time(event, arg)
    curr_event=record_event_time(event, arg)
    return curr_event - last_event
end

function record_and_check_double_click(event, arg, double_click_time)
    double_click_time = double_click_time or DOUBLE_CLICK_TIME_MS
    return record_and_get_event_time_diff(event, arg) < double_click_time
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

function simple_major_attack()
    press("mouseleft")
    while true do
        Sleep(50)
        if is_off("shift", callback_release("mouseleft")) then
            return
        end
    end
end



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
        Sleep(100)
        if is_off("shift", callback_set_off_map(key_cd_map)) then
            return
        end
    end
end


function loop_operation_cru2()
    press("1")
    while true do
        cd_click("2", 2500)
        cd_click("3", 3500)
        cd_click("4", 1000)
        cd_click("mouseleft", 500)
        Sleep(100)
        if is_off("shift", callback_release("1")) then
            return
        end
    end
end

function loop_operation_cru()
    press("1")
    while true do
        click("2", "3")
        for i = 0, 3 do
            click("4", "mouseleft")
            for j = 0, 10 do
                Sleep(100)
                if is_off("shift", callback_release("1")) then
                    return
                end
            end
        end
    end
end

function loop_operation_dh_1_L34()
    press("1")
    while true do
        click("mouseleft")
        for i = 0, 6 do
            click("3", "4")
            for j = 0, 5 do
                Sleep(100)
                if is_off("shift", callback_release("1")) then
                    return
                end
            end
        end
    end
end

function loop_operation_dh_1_234()
    press("1")
    while true do
        click("2", "3", "4")
        for j = 0, 5 do
            Sleep(100)
            if is_off("shift", callback_release("1")) then
                return
            end
        end
    end
end

function loop_operation_monk()
    press("mouseleft")
    while true do
        click("2", "3", "4", "mouseright")
        for j = 0, 5 do
            Sleep(100)
            if is_off("shift", callback_release("mouseleft")) then
                return
            end
        end
    end
end

function switch_operation_wiz()
    click("2")
    Sleep(200)
    click("3")
    Sleep(300)
    click("4")
    Sleep(100)
    click("2")
    press("mouseright")
    check_interval = 50
    total_time = 20000
    warn_time = 18000
    loops = total_time / check_interval
    warn_loop = warn_time / check_interval
    for i = 0, loops do
        if i == warn_loop then
            click("0")
        end
        Sleep(check_interval)
        if is_off("scrolllock", callback_release("mouseright")) then
            return
        end
        if is_off("mouseright") then
            click("3")
            -- must release before press or it will be ignored
            release("mouseright")
            press("mouseright")
        end
    end
    release("mouseright")
    click("scrolllock")
end


function exit_callback_dh()
    release("1")
    set_off("capslock")
end

function switch_operation_dh()
    press("1")
    if not IsKeyLockOn("capslock") then
        PressAndReleaseKey("capslock")
    end
    running = true
    while true do
        click("2", "3", "4")
        for j = 0, 5 do
            Sleep(100)
            if is_off("scrolllock", exit_callback_dh) then
                return
            end
            caps_on = is_on("capslock")
            if caps_on ~= running then
                running = caps_on
                release("1")
                if running then
                    press("1")
                end
            end
        end
    end
end

function switch_operation_dh2()
    press("1")
    set_on("capslock")
    running = true
    while true do
        cd_click("2", 500)
        cd_click("3", 500)
        cd_click("4", 500)
        Sleep(100)
        if is_off("scrolllock", exit_callback_dh) then
            return
        end
        caps_on = is_on("capslock")
        if caps_on ~= running then
            running = caps_on
            release("1")
            if running then
                press("1")
            end
        end
    end
end


function switch_operation_dh3()
    switch_operations({
        ["1"] = -1,
        ["2"] = 500,
        ["3"] = 500,
        ["4"] = 500,
    })
end

function switch_operations(key_cd_map)
    for key, cd in pairs(key_cd_map) do
        if cd == -1 then
            set_on(key)
        end
    end
    set_on("capslock")
    while true do
        for key, cd in pairs(key_cd_map) do
            if cd ~= -1 then
                cd_click(key, cd)
            end
        end
        Sleep(100)
        if is_off("scrolllock", callback_set_off_map(key_cd_map)) then
            return
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
    end
end



function OnEvent(event, arg)
    OutputLogMessage("event = %s, arg = %s\n", event, arg)

    if (event == "MOUSE_BUTTON_PRESSED" and arg == 8) then
        switch_operation_dh3()
    end 

    if (event == "MOUSE_BUTTON_PRESSED" and arg == 3) then
        loop_operation_dh_1_L34()
    end 

    if (event == "MOUSE_BUTTON_PRESSED" and arg == 11) then
        simple_major_attack()
    end 
end