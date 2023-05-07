
function switch_dh_multishoot()
    switch_operations4({
        ["1"] = -1,
        ["3"] = 4000,
        ["4"] = 500,
    },
    {"backslash", {"3"}}
    )
end


dh_53_status=0
function dh_53_mouseleft_pressed()
    release("1")
    release("3")
end

function dh_53_mouseleft_released()
    press("1")
end

function dh_53_click_by_status()
    if dh_53_status == 2 then
        click_avoid("3")
    else
        click_avoid("1")
    end
end

function dh_53_next_status()
    dh_53_status = (dh_53_status + 1) % 3
end

function switch_dh_53()
    dh_53_status=0
    schedule_loop_func(dh_53_next_status, 1500)
    schedule_loop_func(dh_53_click_by_status, 200)
    switch_operations4({
        --["1"] = -1,
        ["2"] = 16000,
        --["3"] = 500,
        ["4"] = 500,
    },
    {"backslash", {"1", "3"}}--,dh_53_mouseleft_pressed,dh_53_mouseleft_released}
    )
    release("1")
    release("3")
end


cru_new2_delay=1200
function cru_new2_mouseleft_pressed()
    schedule_loop_func(click, cru_new2_delay, "1")
end

function cru_new2_mouseleft_released()
    clear_events()
end

function cru_new2_mouseright_pressed()
    clear_events()
    settimeout(cru_new2_mouseleft_pressed, 3000)
end


function switch_cru_new2()
    cru_new2_delay=1200
    switch_operations4({
        ["1"] = 600,
        ["2"] = 5000,
        ["3"] = 500,
        ["4"] = 500,
    },
    {"backslash", {"1", "2", "3"}, cru_new2_mouseleft_pressed, cru_new2_mouseleft_released},
    {nil, {}, cru_new2_mouseright_pressed, nil}
    )
end

function switch_cru_new2_1()
    cru_new2_delay=900
    switch_operations4({
        ["1"] = 600,
        ["2"] = 5000,
        ["3"] = 500,
        ["4"] = 500,
    },
    {"backslash", {"1", "2", "3"}, cru_new2_mouseleft_pressed, cru_new2_mouseleft_released},
    {nil, {}, cru_new2_mouseright_pressed, nil}
    )
end

function cru_new3_mouseright_pressed()
    globally_avoid("1", "2", "3")
    settimeout(closure(globally_unavoid, "1", "2", "3"), 3000)
end

function cru_new3_alt_to_lift_mouseleft()
    if is_on("lalt") then
        release("mouseleft")
    else
        press("mouseleft")
    end
end

function switch_cru_new3()
    press("mouseleft")
    schedule_loop_func(cru_new3_alt_to_lift_mouseleft, 0)
    switch_operations4({
        ["1"] = 800,
        ["2"] = 5000,
        ["3"] = 500,
        ["4"] = 500,
    },
    {"backslash", {},},
    {nil, {}, cru_new3_mouseright_pressed, nil}
    )
    clear_events()
    release("mouseleft")
end

function cru_sweep_mouseleft_pressed()
    --release("lshift")
    release("1")
end

function cru_sweep_mouseleft_released()
    --press("lshift")
    press("1")
end

function switch_cru_sweep()
    switch_operations4({
        --["lshift"] = -1,
        ["1"] = -1,
        ["2"] = 500,
        ["3"] = 500,
        ["4"] = 500,
    },
    {"backslash", {"1", "2", "3"}, cru_sweep_mouseleft_pressed, cru_sweep_mouseleft_released}
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

function switch_cru_shield()
    switch_operations4({
        ["1"] = -1,
        ["2"] = 2000,
        ["3"] = 500,
        ["4"] = 500,
    },
    {"backslash", {"2", "3"}}
    )
end

function switch_wd_pet()
    click("4")
    press("lshift")
    Sleep(500)
    click("mouseleft")
    release("lshift")
    switch_operations4({
        ["1"] = 500,
        ["3"] = 10000,
    },
    {"backslash", {}}
    )
end
