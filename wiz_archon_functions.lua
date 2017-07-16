
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

function cast_wiz_archon(circle_time)
    release("lshift")
    press("lshift")
    click("mouseleft")
    release("lshift")
    Sleep(100)
    curr_time = GetRunningTime()
    end_time = curr_time + 20000
    next_time = curr_time + circle_time - 100
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
    while cast_wiz_archon(32000) do
        OutputLogMessage("time = %d\n", GetRunningTime())
    end
    set_off("scrolllock")
    set_off("capslock")
end
