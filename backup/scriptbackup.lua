
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
    click("1")
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

