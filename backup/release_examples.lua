
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