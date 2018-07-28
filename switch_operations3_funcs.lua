
function switch_operations3(key_cd_map, macro_cd_map, left_trigger, right_trigger, key_cd_map_when_paused, mouseleft_autoclick_interval)
    set_off("capslock")
    set_on_map(key_cd_map)
    running = true
    enable_left_trigger = left_trigger ~= nil
    if left_trigger == nil then
        left_trigger={nil,{}}
    end
    left_triggering = false
    left_replace = left_trigger[1]
    left_avoid_keys = left_trigger[2]
    left_press_func = left_trigger[3]
    if left_press_func == nil then
        left_press_func = callback_set_on(left_replace)
    end
    left_release_func = left_trigger[4]
    if left_release_func == nil then
        left_release_func = callback_set_off(left_replace)
    end
	
	mouseleft_autoclick_enabled = left_replace ~= nil
	if mouseleft_autoclick_enabled and mouseleft_autoclick_interval == nil then
		mouseleft_autoclick_interval = 200
	end
	
	function release_then_press_mouseleft()
         lshift_on=false
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

	function cd_release_then_press_mouseleft()
		cd_func("release_then_press_mouseleft", release_then_press_mouseleft, mouseleft_autoclick_interval)
	end
	
    enable_right_trigger = right_trigger ~= nil and key_cd_map["mouseright"] ~= -1
    if right_trigger == nil then
        right_trigger={nil,{}}
    end
    right_triggering = false
    right_replace = right_trigger[1]
    right_avoid_keys = right_trigger[2]
    right_press_func = right_trigger[3]
    if right_press_func == nil then
        right_press_func = callback_set_on(right_replace)
    end
    right_release_func = right_trigger[4]
    if right_release_func == nil then
        right_release_func = callback_set_off(right_replace)
    end
    
    avoid_map = {}
    extra_avoid_map = {}
    for i, extra_avoid_key in pairs(left_avoid_keys) do
        extra_avoid_map[extra_avoid_key] = false
    end
    for i, extra_avoid_key in pairs(right_avoid_keys) do
        extra_avoid_map[extra_avoid_key] = false
    end
    
        
    while true do
        avoid_map["mouseleft"]=left_triggering
        avoid_map["mouseright"]=right_triggering
        for extra_avoid_key, v in pairs(extra_avoid_map) do
            avoid_map[extra_avoid_key] = false
        end
        for i, extra_avoid_key in pairs(left_avoid_keys) do
            avoid_map[extra_avoid_key] = avoid_map[extra_avoid_key] or avoid_map["mouseleft"]
        end
        for i, extra_avoid_key in pairs(right_avoid_keys) do
            avoid_map[extra_avoid_key] = avoid_map[extra_avoid_key] or avoid_map["mouseright"]
        end
        click_key_cd_map(key_cd_map, avoid_map)
        if macro_cd_map ~= nil then
            for macro, cd in pairs(macro_cd_map) do
                cd_macro(macro, cd)
            end
        end
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
        if not running and key_cd_map_when_paused ~= nil then
            click_key_cd_map(key_cd_map_when_paused)
        end
        if enable_left_trigger then
            left_triggering = edge_trigger(
                left_triggering,
                running and is_on("mouseleft"),
                left_press_func,
                left_release_func
            )
        end
        if running and left_triggering and mouseleft_autoclick_enabled then
            cd_release_then_press_mouseleft()
        end
        if enable_right_trigger then
            right_triggering = edge_trigger(
                right_triggering,
                running and is_on("mouseright"),
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
    set_off_map(key_cd_map)
    set_off("capslock")
end

function multishoot_mouseright_pressed()
    Sleep(100)
    release("1")
    PlayMacro("macro4sleep2500")
end

function multishoot_mouseright_released()
    AbortMacro()
    press("1")
end

function switch_dh_multishoot()
    switch_operations3({
        ["1"] = -1,
        ["2"] = 500,
        ["3"] = 4000,
    },
    nil,
    {"backslash", {"3"}},
    {nil, {"3"}, multishoot_mouseright_pressed, multishoot_mouseright_released},
    {["mouseleft"] = 250}
    )
end

function knife_mouseright_pressed()
    release("1")
    PlayMacro("macro1sleep2000")
end

function knife_mouseright_released()
    AbortMacro()
    press("1")
end

function switch_dh_knife2()
    cd_click("2", 60000)
    switch_operations3({
        ["1"] = -1,
        ["3"] = 500,
        ["4"] = 500,
    },nil,
    {"backslash", {}},
    {nil, {}, knife_mouseright_pressed, knife_mouseright_released},
    {["mouseleft"] = 250}
    )
end

function switch_dh_knife()
    cd_click("2", 60000)
    switch_operations3({
        ["1"] = -1,
        ["3"] = 500,
        ["4"] = 500,
    },nil,
    {"backslash", {}},
    nil,
    {["mouseleft"] = 250}
    )
end


function switch_cru_hammer()
    switch_operations({
        ["1"] = -1,
        ["2"] = 500,
        ["3"] = 500,
        ["4"] = 500,
    }, "backslash")
end

function switch_cru_spike()
    switch_operations3({
        ["lshift"] = -1,
        ["mouseleft"] = -1,
        ["mouseright"] = 1300,
        ["q"] = 8000,
        ["1"] = 16000,
        ["2"] = 16000,
        ["3"] = 16000,
        ["4"] = 16000,
    },
    nil,
    {"backslash", {}},
    nil,
    {["mouseleft"] = 250}
    )
end


function switch_monk()
    switch_operations3({
        ["4"] = -1,
        ["3"] = 300,
    },{
        ["shift-click"] = 5000,
    },
    {"backslash", {"1"}},
    nil,
    {["mouseleft"] = 250}
    )
end

function switch_wiz()
    PlayMacro("shift-click")
    switch_operations3({
        ["1"] = -1,
        ["2"] = 4500,
        ["3"] = 60000,
        ["4"] = 70000,
    },nil,
    {"backslash", {"1"}},
    nil,
    {["mouseleft"] = 250}
    )
end

function switch_nec()
    switch_operations3({
        --["mouseleft"] = 250,
        --["1"] = -1,
        --["2"] = 500,
        ["3"] = 1000,
        ["4"] = 1000,
    },nil,
    {"backslash", {"1","3","4"}},
    nil,
    {["mouseleft"] = 250}
    )
end

function switch_nec2()
    switch_operations3({
        ["mouseleft"] = 250,
        --["1"] = 2000,
        --["2"] = 500,
        --["3"] = 500,
        ["4"] = 500,
    },nil,
    {"backslash", {"4"}},
    nil,
    {["mouseleft"] = 250}
    )
end

function switch_nec3()
    switch_operations3({
        ["mouseleft"] = 250,
        --["1"] = 500,
        ["2"] = 2000,
        ["3"] = 500,
        ["4"] = 500,
    },nil,
    {"backslash", {"4"}},
    nil,
    {["mouseleft"] = 250}
    )
end


function cru_new_mouseleft_pressed()
    press("backslash")
    PlayMacro("macro1sleep900")
end

function cru_new2_mouseleft_pressed()
    press("backslash")
    PlayMacro("macro1sleep1200")
end

function cru_new_mouseleft_released()
    AbortMacro()
    release("backslash")
end

function cru_new_mouseright_pressed()
    AbortMacro()
end

function switch_cru_new()
    switch_operations3({
        ["1"] = 600,
        ["2"] = 2000,
        ["3"] = 500,
        ["4"] = 500,
        ["mouseright"] = 500,
    },nil,
    {"backslash", {"mouseright", "1"}, cru_new_mouseleft_pressed, cru_new_mouseleft_released},
    nil,
    {["mouseleft"] = 250}
    )
end


function switch_cru_new2()
    switch_operations3({
        ["1"] = 600,
        ["2"] = 5000,
        ["3"] = 500,
        ["4"] = 500,
    },nil,
    {"backslash", {"1", "2", "3"}, cru_new2_mouseleft_pressed, cru_new_mouseleft_released},
    {nil, {}, cru_new_mouseright_pressed, nil},
    {["mouseleft"] = 250}
    )
end


function switch_temp()
    switch_operations3({
        ["1"] = -1,
        ["3"] = 500,
        ["4"] = 500,
    },nil,
    {"backslash", {"1"}},
    nil,
    {["mouseleft"] = 250}
    )
end

last_release_switch=-1

function OnEvent(event, arg)
    OutputLogMessage("event = %s, arg = %s\n", event, arg)

    switch_funcs={
        --[8] = switch_temp,
        --[8] = switch_cru_hammer,
        --[8] = switch_cru_spike,
        --[8] = switch_monk,
        --[8] = switch_wiz,
        --[8] = switch_nec2,
        [8] = switch_dh_knife2,
        --[8] = switch_dh_multishoot,
        [9] = switch_dh_knife2,
    }

    if (switch_funcs[arg] ~= nil) then
        if (event == "MOUSE_BUTTON_PRESSED") then
            if GetRunningTime()-last_release_switch <= 5 then
                return
            end
            switch_funcs[arg]()
        end
        if (event == "MOUSE_BUTTON_RELEASED") then
            last_release_switch=GetRunningTime()
        end 
    end 

end