
function loop_monk()
    loop_operations({
        ["mouseleft"] = -1,
        ["2"] = 500,
        ["3"] = 500,
        ["4"] = 500,
        ["mouseright"] = 500,
    })
end

function switch_dh_cluster()
    switch_operations({
        ["1"] = -1,
        ["2"] = 8000,
        ["3"] = 500,
        ["4"] = 500,
        ["mouseleft"] = 3000,
    }, "backslash")
end

function switch_dh_grenade()
    switch_operations({
        ["1"] = -1,
        ["3"] = 500,
        ["4"] = 500,
    }, "backslash")
end

function switch_monk()
    switch_operations({
        ["4"] = -1,
        ["3"] = 300,
    }, "backslash",{
        ["shift-click"] = 5000,
    })
end

function switch_monk2()
    switch_operations({
        ["2"] = 10000,
        ["3"] = 300,
        ["4"] = 7500,
    }, "backslash",{
        ["shift-click"] = 5000,
    })
end

function switch_wiz()
    PlayMacro("shift-click")
    switch_operations({
        ["1"] = -1,
        ["2"] = 4500,
        ["3"] = 60000,
        ["4"] = 70000,
    }, "backslash")
end

function simple_major_attack()
    loop_operations({
        ["mouseleft"] = -1,
    })
end
