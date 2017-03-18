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
    end
    set_off("capslock")
end



-- �˴���shift���ƵĽű�
-- ��--�ص�����Ҫ�İ���
-- �������� = �ź�����ֱ�ʾ��������ĺ�������500 �� 0.5 ��
-- �� -1 ��ʾ�˼�һֱ��ס
-- mouseleft��ʾ������
-- mouseright��ʾ����Ҽ�
-- ����ű���ʾ һֱ��ס1��ÿ2.5�밴һ��2��3.5�밴һ��3��1�밴һ��4��0.5�밴һ���������������Ҽ�
function shift_example()
    loop_operations({
        ["1"] = -1,
        ["2"] = 2500,
        ["3"] = 3500,
        ["4"] = 1000,
        ["mouseleft"] = 500,
        -- ["mouseright"] = 500,
    })
end


-- �˴���scrolllock���ƵĽű�
-- ��--�ص�����Ҫ�İ���
-- �������� = �ź�����ֱ�ʾ��������ĺ�������500 �� 0.5 ��
-- �� -1 ��ʾ�˼�һֱ��ס
-- mouseleft��ʾ������
-- mouseright��ʾ����Ҽ�
-- ����ű���ʾ һֱ��ס1��ÿ0.5�밴һ��234
function scrolllock_example()
    switch_operations({
        ["1"] = -1,
        ["2"] = 500,
        ["3"] = 500,
        ["4"] = 500,
        -- ["mouseleft"] = -1,
        -- ["mouseright"] = 500,
    })
end


function OnEvent(event, arg)
    OutputLogMessage("event = %s, arg = %s\n", event, arg)


	-- �˴� arg == 8 �� 8 �滻Ϊ��ղŷ����� scrolllock ���İ������
    if (event == "MOUSE_BUTTON_PRESSED" and arg == 8) then
        scrolllock_example()
    end 

	-- �˴� arg == 3 �� 3 �滻Ϊ��ղŷ����� shift ���İ������
    if (event == "MOUSE_BUTTON_PRESSED" and arg == 3) then
        shift_example()
    end
end