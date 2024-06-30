OLM = OutputLogMessage
function myprintT(msg, logTable)
  OLM("%s: {", tostring(msg))
  for k, v in pairs(logTable) do OLM("%s = %s, ", tostring(k), tostring(v)) end
  OLM("}\n")
end
function myprint(msg, arg1, arg2)
  if type(arg1) == "table" then return myprintT(msg, arg1) end
  if arg2 ~= nil then return OLM("%s: %s = %s\n", tostring(msg), tostring(arg1), tostring(arg2)) end
  if arg1 ~= nil then return OLM("%s: %s\n", tostring(msg), tostring(arg1)) end
  OLM("%s\n", tostring(msg))
end
IN_PROD = (PlayMacro ~= nil)
print = myprint

DEBUG = false
LOOP_DELAY = 1
function log(msg, name, value) return DEBUG and myprint(msg, name, value) end
function logif(condition, msg, name, value) return condition and log(msg, name, value) end

KEY_D3_FORCE_MOVE = "backslash"
KEY_D4_FORCE_MOVE = "k"
D4_POTION_INTERVAL = 5000

function func_selector()
  threads_barb_ww_dust_devil()
  --threads_barb_dust_devil_3weapon()
  --threads_barb_dust_devil_2weapon()
  --threads_barb()
  --threads_d4_barb_jump()
  --threads_d4_temp()
  --threads_d4_rogue_heartseeker()
  --threads_d4_nec()
  --threads_sor_chain_lightning()
  --threads_druid_claw_shred()
  --threads_druid_EB2()
  --threads_boulder()
  --threads_d4_rogue_flurry()
  --threads_d4_rogue_flurry_RF()
  --threads_d4_rogue_rapid_fire()
  --threads_d4_rogue_imbue()
  --testSubAction()
end

function threads_d4_temp()
  local runner = ProgramRunner:new()
  runner.actionResource:unblock()
  local subActions = SubActionsMaker:new()
  local buffActionResource = Resource:new()

  blockedActions = {}

  local press1 = runner:AddHoldKey { priority = 1, key = "1", }
  press1.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, press1)

  --local click1 = runner:AddClick { key = "1", cycleTime = 500, }
-- [[
  local click2 = runner:AddClick { key = "2", cycleTime = 200, }
  --click2.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, click2)

  local click3 = runner:AddClick { key = "3", cycleTime = 500, }
  --click3.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, click3)

  local click4 = runner:AddClick { key = "4", cycleTime = 500, }
  --click4.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, click4)

  local clickF = runner:AddClick { key = "F", cycleTime = 500, }
  table.insert(blockedActions, clickF)
--]]
  --local clickMR = runner:AddClick { key = "mouseright", cycleTime = 250, }
  --table.insert(blockedActions, clickMR)

  if D4_POTION_INTERVAL > 0 then
    local clickQ = runner:AddClick { key = "Q", cycleTime = D4_POTION_INTERVAL, }
  end
  local clickG = runner:AddClick { key = "G", cycleTime = 100, }
  local replaceML = runner:AddReplaceMouseLeft("F", blockedActions)

  runner:run()
end


function threads_d4_sor()
  local runner = ProgramRunner:new()
  runner.actionResource:unblock()
  local subActions = SubActionsMaker:new()
  local buffActionResource = Resource:new()

  blockedActions = {}

  local press1 = runner:AddHoldKey { priority = 1, key = "1", }
  press1.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, press1)

  --local click1 = runner:AddClick { key = "1", cycleTime = 500, }
  local click2 = runner:AddClick { key = "2", cycleTime = 200, }
  --click2.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, click2)

  local click3 = runner:AddClick { key = "3", cycleTime = 500, }
  --click3.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, click3)

  local click4 = runner:AddClick { key = "4", cycleTime = 500, }
  --click4.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, click4)

--[[
  local clickF = runner:AddClick { key = "F", cycleTime = 500, }
  table.insert(blockedActions, clickF)
--]]
  --local clickMR = runner:AddClick { key = "mouseright", cycleTime = 250, }
  --table.insert(blockedActions, clickMR)

  if D4_POTION_INTERVAL > 0 then
    local clickQ = runner:AddClick { key = "Q", cycleTime = D4_POTION_INTERVAL, }
  end
  local clickG = runner:AddClick { key = "G", cycleTime = 100, }
  local replaceML = runner:AddReplaceMouseLeft("F", blockedActions)

  runner:run()
end

function threads_d4_nec()
  local runner = ProgramRunner:new()
  runner.actionResource:unblock()
  local subActions = SubActionsMaker:new()
  local buffActionResource = Resource:new()

  blockedActions = {}

  --local press1 = runner:AddHoldKey { priority = 1, key = "1", }
  --press1.isEnabledFunc = ModIsOff("mouseright")
  --table.insert(blockedActions, press1)

  --local click1 = runner:AddClick { key = "1", cycleTime = 1500, }
  --table.insert(blockedActions, click1)

  --local click2 = runner:AddClick { key = "2", cycleTime = 200, }
  --click2.isEnabledFunc = ModIsOff("mouseright")
  --table.insert(blockedActions, click2)

  --local click3 = runner:AddClick { key = "3", cycleTime = 500, }
  --click3.isEnabledFunc = ModIsOff("mouseright")
  --table.insert(blockedActions, click3)

  local click4 = runner:AddClick { key = "4", cycleTime = 500, }
  --click4.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, click4)

  --local clickF = runner:AddClick { key = "F", cycleTime = 500, }
  --table.insert(blockedActions, clickF)

  --local clickMR = runner:AddClick { key = "mouseright", cycleTime = 250, }
  --table.insert(blockedActions, clickMR)

  if D4_POTION_INTERVAL > 0 then
    local clickQ = runner:AddClick { key = "Q", cycleTime = D4_POTION_INTERVAL, }
  end
  --local clickG = runner:AddClick { key = "G", cycleTime = 100, }
  local replaceML = runner:AddReplaceMouseLeft("G", blockedActions)

  runner:run()
end






function threads_d4_rogue_heartseeker()
  local runner = ProgramRunner:new()
  runner.actionResource:unblock()
  local subActions = SubActionsMaker:new()
  local buffActionResource = Resource:new()
  local cursorLocator = CursorLocator:new{
    closeRatio = 0.53, -- move instead of shooting out of this range
    staticRatio = 0.01, -- 0.01 = 1/200 screen width
    pixelOvalRatioY = 480/560, -- Y-axis pixels / X-axis pixels of the "close" oval
  }
  local cursorLocatorUpdater = runner:AddClick { key = "", cycleTime = 100, pressFunc = cursorLocator:GetPositionFunc() }

  blockedActions = {}

  local farFunc, notFarFunc = cursorLocator:isFarFunc(1)
  local mrOffFunc = ModIsOff("mouseright")
  local mrOffAndNotFarFunc = function() return mrOffFunc() and notFarFunc() end

  local press1 = runner:AddHoldKey { priority = 1, key = "1", }
  press1.isEnabledFunc = notFarFunc
  table.insert(blockedActions, press1)


  local clickF = runner:AddClick { key = "F", cycleTime = 200 }
  clickF.isEnabledFunc = mrOffAndNotFarFunc
  table.insert(blockedActions, clickF)


--[[
  local click2 = runner:AddClick { key = "2", cycleTime = 200 }
  click2:AddResource(buffActionResource)
  click2.isEnabledFunc = mrOffAndNotFarFunc
  table.insert(blockedActions, click2)
  local click4 = runner:AddClick { key = "4", cycleTime = 200, }
  --click4.isEnabledFunc = mrOffFunc
  --table.insert(blockedActions, click4)
  local click3 = runner:AddClick { key = "3", cycleTime = 4600, holdTime = 100  }
  click3:AddResource(buffActionResource)
  click3.isEnabledFunc = mrOffAndNotFarFunc
  table.insert(blockedActions, click3)
--]]
  local clickFAndMove = runner:Add(
          subActions
                  :Hold("f", 100)
                  :Hold(KEY_D4_FORCE_MOVE, 600)
                  :Make()
  )
  clickFAndMove.isEnabledFunc = farFunc
  table.insert(blockedActions, clickFAndMove)

  if D4_POTION_INTERVAL > 0 then
    local clickQ = runner:AddClick { key = "Q", cycleTime = D4_POTION_INTERVAL, }
  end
  local clickG = runner:AddClick { key = "G", cycleTime = 100, }
  local replaceML = runner:AddReplaceMouseLeft("", blockedActions)


  runner:run()
end


function threads_druid_claw_shred()
  local runner = ProgramRunner:new()
  runner.actionResource:unblock()
  local subActions = SubActionsMaker:new()
  local buffActionResource = Resource:new()
  local cursorLocator = CursorLocator:new{
    closeRatio = 0.35, -- range of claw=390/1280, but this can be different
    staticRatio = 0.01, -- 0.01 = 1/200 screen width
    pixelOvalRatioY = 480/560, -- Y-axis pixels / X-axis pixels of the "close" oval
  }
  local cursorLocatorUpdater = runner:AddClick { key = "", cycleTime = 100, pressFunc = cursorLocator:GetPositionFunc() }

  blockedActions = {}

  local farFunc, notFarFunc = cursorLocator:isFarFunc(1)
  local mrOffFunc = ModIsOff("mouseright")
  local mrOffAndNotFarFunc = function() return mrOffFunc() and notFarFunc() end

  local press1 = runner:AddHoldKey { priority = 1, key = "1", }
  press1.isEnabledFunc = notFarFunc
  table.insert(blockedActions, press1)
  local click2 = runner:AddClick { key = "2", cycleTime = 200 }
  click2:AddResource(buffActionResource)
  click2.isEnabledFunc = mrOffAndNotFarFunc
  table.insert(blockedActions, click2)

  local click4 = runner:AddClick { key = "4", cycleTime = 200, }
  --click4.isEnabledFunc = mrOffFunc
  --table.insert(blockedActions, click4)

  local clickF = runner:AddClick { key = "F", cycleTime = 500, }
  clickF.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, clickF)
--[[
  local click3 = runner:AddClick { key = "3", cycleTime = 4600, holdTime = 100  }
  click3:AddResource(buffActionResource)
  click3.isEnabledFunc = mrOffAndNotFarFunc
  table.insert(blockedActions, click3)
--]]
--[[
  local pressDot = runner:AddHoldKey { priority = 1, key = "period", }
  pressDot.isEnabledFunc = farFunc
  local forceMove = runner:AddHoldKey { priority = 2, cycleTime = 200, holdTime = 100, key = KEY_D4_FORCE_MOVE, }
  forceMove.isEnabledFunc = farFunc
  table.insert(blockedActions, forceMove)
--]]
  local clickDotAndMove = runner:Add(
          subActions
                  :Hold("period", 100)
                  :Hold(KEY_D4_FORCE_MOVE, 600)
                  :Make()
  )
  clickDotAndMove.isEnabledFunc = farFunc
  table.insert(blockedActions, clickDotAndMove)

  if D4_POTION_INTERVAL > 0 then
    local clickQ = runner:AddClick { key = "Q", cycleTime = D4_POTION_INTERVAL, }
  end
  local clickG = runner:AddClick { key = "G", cycleTime = 100, }
  local replaceML = runner:AddReplaceMouseLeft("", blockedActions)


  runner:run()
end


function threads_druid_EB2()
  local runner = ProgramRunner:new()
  runner.actionResource:unblock()
  local subActions = SubActionsMaker:new()
  local buffActionResource = Resource:new()

  blockedActions = {}

  local press1 = runner:AddHoldKey { priority = 1, key = "1", }
  press1.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, press1)
-- [[
  local click2 = runner:AddClick { key = "2", cycleTime = 3000, holdTime = 100  }
  click2:AddResource(buffActionResource)
  click2.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, click2)

  local click3 = runner:AddClick { key = "3", cycleTime = 4600, holdTime = 100  }
  click3:AddResource(buffActionResource)
  click3.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, click3)
--]]
  local click4 = runner:AddClick { key = "4", cycleTime = 200, }
  click4.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, click4)

  --local clickF = runner:AddClick { key = "F", cycleTime = 500, }
  --clickF.isEnabledFunc = ModIsOff("mouseright")
  --table.insert(blockedActions, clickF)

  local clickDot = runner:AddClick { key = "period", cycleTime = 800, }
  --clickDot.isEnabledFunc = ModIsOn("mouseleft")
  --table.insert(blockedActions, clickDot)

  local replaceML = runner:AddReplaceMouseLeft("", blockedActions)


  runner:run()
end

function threads_d4_barb_jump()
  local runner = ProgramRunner:new()
  runner.actionResource:unblock()
  local subActions = SubActionsMaker:new()
  local buffActionResource = Resource:new()

  local cursorLocator = CursorLocator:new{
    closeRatio = 0.25, -- range of earthquake
    staticRatio = 0.01, -- 0.01 = 1/200 screen width
    pixelOvalRatioY = 480/560, -- Y-axis pixels / X-axis pixels of the "close" oval
  }
  local cursorLocatorUpdater = runner:AddClick { key = "", cycleTime = 100, pressFunc = cursorLocator:GetPositionFunc() }

  local cursorLocator2 = CursorLocator:new{
    closeRatio = 0.35, -- range of lunging strike is ~0.5
    staticRatio = 0.01, -- 0.01 = 1/200 screen width
    pixelOvalRatioY = 480/560, -- Y-axis pixels / X-axis pixels of the "close" oval
  }
  local cursorLocatorUpdater2 = runner:AddClick { key = "", cycleTime = 100, pressFunc = cursorLocator2:GetPositionFunc() }

  blockedActions = {}

  local farFunc, notFarFunc = cursorLocator:isFarFunc(1)
  local farFuncLS, notFarFuncLS = cursorLocator2:isFarFunc(1)
  --local mrOffFunc = ModIsOff("mouseright")
  --local staticFunc = cursorLocator:isStaticFunc(2)
  --local mrOffAndNotFarFunc = function() return mrOffFunc() and notFarFunc() end
  --local staticAndNotFarFunc = function() return staticFunc() and notFarFunc() end

  local press1 = runner:AddHoldKey { priority = 1, key = "1", }
  --press1.isEnabledFunc = notFarFunc
  table.insert(blockedActions, press1)
-- [[
  local click2 = runner:AddHoldKey { priority = 3, key = "2", cycleTime = 2500, holdTime = 100  }
  click2:AddResource(buffActionResource)
  click2.isEnabledFunc = notFarFunc
  table.insert(blockedActions, click2)

  local click3 = runner:AddClick { key = "3", cycleTime = 200 }
  --click3:AddResource(buffActionResource)
  --table.insert(blockedActions, click3)
--]]
  local click4 = runner:AddHoldKey { priority = 3, key = "4", cycleTime = 3000, holdTime = 100 }
  click4.isEnabledFunc = notFarFunc
  table.insert(blockedActions, click4)

  local clickF = runner:AddHoldKey { priority = 2, key = "F", cycleTime = 600, holdTime = 100 }
  clickF.isEnabledFunc = farFuncLS
  table.insert(blockedActions, clickF)


--[[
  local pressDot = runner:AddHoldKey { priority = 1, key = "period", }
  pressDot.isEnabledFunc = farFunc
  local forceMove = runner:AddHoldKey { priority = 2, cycleTime = 200, holdTime = 100, key = KEY_D4_FORCE_MOVE, }
  forceMove.isEnabledFunc = farFunc
  table.insert(blockedActions, forceMove)
  local clickDotAndMove = runner:Add(
          subActions
                  :Hold("period", 100)
                  :Hold(KEY_D4_FORCE_MOVE, 600)
                  :Make()
  )
  clickDotAndMove.isEnabledFunc = farFunc
  table.insert(blockedActions, clickDotAndMove)
--]]

  if D4_POTION_INTERVAL > 0 then
    local clickQ = runner:AddClick { key = "Q", cycleTime = D4_POTION_INTERVAL, }
  end
  local clickG = runner:AddClick { key = "G", cycleTime = 100, }
  local replaceML = runner:AddReplaceMouseLeft("", blockedActions)

  runner:run()
end


function threads_d4_barb_jump()
  local runner = ProgramRunner:new()
  runner.actionResource:unblock()
  local subActions = SubActionsMaker:new()
  local buffActionResource = Resource:new()

  local cursorLocator = CursorLocator:new{
    closeRatio = 0.32, -- close range
    staticRatio = 0.01, -- 0.01 = 1/200 screen width
    pixelOvalRatioY = 480/560, -- Y-axis pixels / X-axis pixels of the "close" oval
  }
  local cursorLocatorUpdater = runner:AddClick { key = "", cycleTime = 100, pressFunc = cursorLocator:GetPositionFunc() }

  local farFunc, notFarFunc = cursorLocator:isFarFunc(1)

  blockedActions = {}

  local press1 = runner:AddHoldKey { priority = 1, key = "1", }
  --press1.isEnabledFunc = notFarFunc
  table.insert(blockedActions, press1)
-- [[
  local click2 = runner:AddHoldKey { priority = 3, key = "2", cycleTime = 2500, holdTime = 100  }
  click2:AddResource(buffActionResource)
  click2.isEnabledFunc = notFarFunc
  table.insert(blockedActions, click2)

  local click3 = runner:AddClick { key = "3", cycleTime = 200 }
  --click3:AddResource(buffActionResource)
  --table.insert(blockedActions, click3)
--]]
  local click4 = runner:AddHoldKey { key = "4", cycleTime = 200  }
  --click4.isEnabledFunc = notFarFunc
  table.insert(blockedActions, click4)

  --local clickF = runner:AddHoldKey { priority = 2, key = "F", cycleTime = 600, holdTime = 100 }
  --clickF.isEnabledFunc = farFuncLS
  --table.insert(blockedActions, clickF)


  if D4_POTION_INTERVAL > 0 then
    local clickQ = runner:AddClick { key = "Q", cycleTime = D4_POTION_INTERVAL, }
  end
  local clickG = runner:AddClick { key = "G", cycleTime = 100, }
  local replaceML = runner:AddReplaceMouseLeft("", blockedActions)

  runner:run()
end

function threads_barb()
  local runner = ProgramRunner:new()
  runner.actionResource:unblock()
  local subActions = SubActionsMaker:new()
  local buffActionResource = Resource:new()

  local cursorLocator = CursorLocator:new{
    closeRatio = 0.35, -- close?
    staticRatio = 0.05, -- 0.01 = 1/200 screen width
    pixelOvalRatioY = 480/560, -- Y-axis pixels / X-axis pixels of the "close" oval
  }
  local cursorLocatorUpdater = runner:AddClick { key = "", cycleTime = 100, pressFunc = cursorLocator:GetPositionFunc() }

  local closeFunc, notCloseFunc = cursorLocator:isCloseFunc(1)
  local staticFunc = cursorLocator:isStaticFunc(2)
  local staticAndCloseFunc = function() return staticFunc() and closeFunc() end

  blockedActions = {}

  local pressShift = runner:Add { key = "lshift", holdTime = -1}
  pressShift.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, pressShift)

  local loop3skills = runner:Add(
          subActions
                  :Hold("F", 100)
                  :Hold("1", 2000)
                  --:Hold("mouseright", 150)
                  :Make()
  )
  loop3skills.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, loop3skills)


  local loopBuff = runner:Add(
          subActions
                  :Hold("2", 200)
                  :After(500)
                  :Hold("3", 200)
                  :After(500)
                  :Make()
  )
  table.insert(blockedActions, loopBuff)

  --local click2 = runner:AddClick { key = "2", cycleTime = 4000, }
  --click2:AddResource(buffActionResource)
  --table.insert(blockedActions, click2)

  --local click3 = runner:AddClick { key = "3", cycleTime = 3500, }
  --click3:AddResource(buffActionResource)
  --table.insert(blockedActions, click3)

  local click4 = runner:AddClick { key = "4", cycleTime = 200, }
  table.insert(blockedActions, click4)

  --local clickMR = runner:AddClick { key = "mouseright", cycleTime = 5000, }
  --local clickMR = runner:AddClick { priority = 3, cycleTime = 300, key = "mouseright", holdTime = 100, }
  --table.insert(blockedActions, clickMR)

--[[
  local press1 = runner:AddHoldKey { priority = 1, key = "1", }
  table.insert(blockedActions, press1)
  --local click1 = runner:AddClick { key = "1", cycleTime = 500, }

  --local clickF = runner:AddClick { key = "F", cycleTime = 500, }
  local clickF = runner:AddHoldKey { priority = 2, cycleTime = 300, key = "F", holdTime = 100,}
  --clickF:AddResource(buffActionResource)
  table.insert(blockedActions, clickF)


--]]

  if D4_POTION_INTERVAL > 0 then
    local clickQ = runner:AddClick { key = "Q", cycleTime = D4_POTION_INTERVAL, }
  end
  local clickG = runner:AddClick { key = "G", cycleTime = 100, }
  local replaceML = runner:AddReplaceMouseLeft("", blockedActions)

  runner:run()
end

function threads_barb_ww_dust_devil()
  local runner = ProgramRunner:new()
  runner.actionResource:unblock()
  local subActions = SubActionsMaker:new()
  local buffActionResource = Resource:new()


  local cursorLocator = CursorLocator:new{
    closeRatio = 0.35, -- close?
    staticRatio = 0.05, -- 0.01 = 1/200 screen width
    pixelOvalRatioY = 480/560, -- Y-axis pixels / X-axis pixels of the "close" oval
  }
  local cursorLocatorUpdater = runner:AddClick { key = "", cycleTime = 100, pressFunc = cursorLocator:GetPositionFunc() }

  local closeFunc, notCloseFunc = cursorLocator:isCloseFunc(1)

  blockedActions = {}

  local startTime = RTime()
  local totalPhaseTime = 4000
  local phase1Time = 1300
  --local isPhase1 = function () return closeFunc() or (RTime()-startTime)%totalPhaseTime <= phase1Time end
  --local isPhase2 = function () return not isPhase1() end
--[[
  local loop2skills = runner:Add(
          subActions
                  :Hold("F", 100)
                  --:Hold("period", 120)
                 -- :Hold("4", 100)
                  :Make()
  )
  loop2skills.isEnabledFunc = isPhase1
  table.insert(blockedActions, loop2skills)
--]]
  local press1 = runner:AddHoldKey { priority = 1, key = "1", }
  press1.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, press1)

  local click2 = runner:AddClick { key = "2", cycleTime = 200, }
  click2:AddResource(buffActionResource)
  table.insert(blockedActions, click2)

  local click3 = runner:AddClick { key = "3", cycleTime = 200, }
  click3:AddResource(buffActionResource)
  table.insert(blockedActions, click3)

  local click4 = runner:AddClick { key = "4", cycleTime = 200, }
  click4:AddResource(buffActionResource)
  table.insert(blockedActions, click4)

  local clickForceMove = runner:AddClick { key = "k", cycleTime = 200, }
  clickForceMove.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, clickForceMove)

  local clickF = runner:AddHoldKey { priority = 2, key = "f", cycleTime = 200, holdTime = 100}
  clickF.isEnabledFunc = ModIsOn("mouseright")
  --clickF:AddResource(buffActionResource)
  table.insert(blockedActions, clickF)

  local clickDot = runner:AddClick { key = "period", cycleTime = 200, }
  clickDot.isEnabledFunc = ModIsOn("mouseright")
  --clickF:AddResource(buffActionResource)
  table.insert(blockedActions, clickDot)


  if D4_POTION_INTERVAL > 0 then
    local clickQ = runner:AddClick { key = "Q", cycleTime = D4_POTION_INTERVAL, }
  end
  local clickG = runner:AddClick { key = "G", cycleTime = 100, }
  local replaceML = runner:AddReplaceMouseLeft("", blockedActions)

  runner:run()
end


function threads_barb_dust_devil_2weapon()
  local runner = ProgramRunner:new()
  runner.actionResource:unblock()
  local subActions = SubActionsMaker:new()
  local buffActionResource = Resource:new()

  local cursorLocator = CursorLocator:new{
    closeRatio = 0.75, -- close?
    staticRatio = 0.05, -- 0.01 = 1/200 screen width
    pixelOvalRatioY = 480/560, -- Y-axis pixels / X-axis pixels of the "close" oval
  }
  local cursorLocatorUpdater = runner:AddClick { key = "", cycleTime = 100, pressFunc = cursorLocator:GetPositionFunc() }
  local closeFunc, notCloseFunc = cursorLocator:isCloseFunc(1)

  blockedActions = {}

  local loop2skills = runner:Add(
          subActions
                  :Hold("1", 100)
                  :Hold("F", 120)
                 -- :Hold("4", 100)
                  :Make()
  )
  --loop2skills.isEnabledFunc = closeFunc
  table.insert(blockedActions, loop2skills)

  --local clickForceMove = runner:AddClick { key = KEY_D4_FORCE_MOVE, cycleTime = 100, }
  --clickForceMove.isEnabledFunc = notCloseFunc
  --table.insert(blockedActions, clickForceMove)

--[[

  local pressShift = runner:Add { key = "lshift", holdTime = -1}
  pressShift.isEnabledFunc = staticAndCloseFunc
  table.insert(blockedActions, pressShift)
--]]

  local click2 = runner:AddClick { key = "2", cycleTime = 200, }
  --click2:AddResource(buffActionResource)
  table.insert(blockedActions, click2)

  local click3 = runner:AddClick { key = "3", cycleTime = 100, }
  --click3:AddResource(buffActionResource)
  --table.insert(blockedActions, click3)

  local click4 = runner:AddClick { key = "4", cycleTime = 1000, }
  table.insert(blockedActions, click4)

  --local clickDot = runner:AddClick { key = "period", cycleTime = 100, }
  --clickDot.isEnabledFunc = ModIsOn("mouseright")
  --table.insert(blockedActions, clickDot)

  if D4_POTION_INTERVAL > 0 then
    local clickQ = runner:AddClick { key = "Q", cycleTime = 1000, }
  end
  local clickG = runner:AddClick { key = "G", cycleTime = 100, }
  local replaceML = runner:AddReplaceMouseLeft("", blockedActions)

  runner:run()
end

function threads_boulder()
  local runner = ProgramRunner:new()
  runner.actionResource:unblock()
  local subActions = SubActionsMaker:new()
  local buffActionResource = Resource:new()

  blockedActions = {}

  local press1 = runner:AddHoldKey { priority = 1, key = "1", }
  press1.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, press1)
--[[
  local click2 = runner:AddClick { key = "2", cycleTime = 3000, holdTime = 100  }
  click2:AddResource(buffActionResource)
  click2.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, click2)
--]]

  local click3 = runner:AddClick { key = "3", cycleTime = 3000, holdTime = 100  }
  click3:AddResource(buffActionResource)
  click3.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, click3)

  local click4 = runner:AddClick { key = "4", cycleTime = 200, }
  click4.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, click4)

  local clickF = runner:AddHoldKey { priority = 2, cycleTime = 800, key = "F", holdTime = 100,}
  clickF.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, clickF)

  local clickQ = runner:AddClick { key = "Q", cycleTime = 5000, }

  local replaceML = runner:AddReplaceMouseLeft("", blockedActions)

  runner:run()
end

function threads_barb_dust_devil_3weapon()
  local runner = ProgramRunner:new()
  runner.actionResource:unblock()
  local subActions = SubActionsMaker:new()
  local buffActionResource = Resource:new()

  local cursorLocator = CursorLocator:new{
    closeRatio = 0.35, -- close?
    staticRatio = 0.05, -- 0.01 = 1/200 screen width
    pixelOvalRatioY = 480/560, -- Y-axis pixels / X-axis pixels of the "close" oval
  }
  local cursorLocatorUpdater = runner:AddClick { key = "", cycleTime = 100, pressFunc = cursorLocator:GetPositionFunc() }

  local closeFunc, notCloseFunc = cursorLocator:isCloseFunc(1)
  local staticFunc = cursorLocator:isStaticFunc(2)
  local staticAndCloseFunc = function() return staticFunc() and closeFunc() end

  blockedActions = {}


  local loop3skills = runner:Add(
          subActions
                  :Hold("1", 100)
                  :Hold("F", 100)
                  :Hold("mouseright", 100)
                  :Hold("1", 100)
                  :Hold("mouseright", 100)
                  :Hold("F", 100)
                  :Make()
  )
  table.insert(blockedActions, loop3skills)

--[[
  local pressShift = runner:Add { key = "lshift", holdTime = -1}
  pressShift.isEnabledFunc = staticAndCloseFunc
  table.insert(blockedActions, pressShift)
  local loop2skills = runner:Add(
          subActions
                  :Hold("1", 100)
                  :Hold("F", 100)
                  :Hold("1", 100)
                  :Hold("F", 100)
                  :Make()
  )
  table.insert(blockedActions, loop2skills)

--]]

  --local click2 = runner:AddClick { key = "2", cycleTime = 200, }
  --click2:AddResource(buffActionResource)
  --table.insert(blockedActions, click2)

  local click3 = runner:AddClick { key = "3", cycleTime = 200, }
  --click3:AddResource(buffActionResource)
  table.insert(blockedActions, click3)

  local click4 = runner:AddClick { key = "4", cycleTime = 200, }
  table.insert(blockedActions, click4)

  --local clickMR = runner:AddClick { key = "mouseright", cycleTime = 500, }
  --table.insert(blockedActions, clickMR)

  if D4_POTION_INTERVAL > 0 then
    local clickQ = runner:AddClick { key = "Q", cycleTime = D4_POTION_INTERVAL, }
  end
  local clickG = runner:AddClick { key = "G", cycleTime = 100, }
  local replaceML = runner:AddReplaceMouseLeft("", blockedActions)

  runner:run()
end

function threads_boulder()
  local runner = ProgramRunner:new()
  runner.actionResource:unblock()
  local subActions = SubActionsMaker:new()
  local buffActionResource = Resource:new()

  blockedActions = {}

  local press1 = runner:AddHoldKey { priority = 1, key = "1", }
  press1.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, press1)
--[[
  local click2 = runner:AddClick { key = "2", cycleTime = 3000, holdTime = 100  }
  click2:AddResource(buffActionResource)
  click2.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, click2)
--]]

  local click3 = runner:AddClick { key = "3", cycleTime = 3000, holdTime = 100  }
  click3:AddResource(buffActionResource)
  click3.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, click3)

  local click4 = runner:AddClick { key = "4", cycleTime = 200, }
  click4.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, click4)

  local clickF = runner:AddHoldKey { priority = 2, cycleTime = 800, key = "F", holdTime = 100,}
  clickF.isEnabledFunc = ModIsOff("mouseright")
  table.insert(blockedActions, clickF)

  local clickQ = runner:AddClick { key = "Q", cycleTime = 5000, }

  local replaceML = runner:AddReplaceMouseLeft("", blockedActions)

  runner:run()
end

function threads_sor_chain_lightning()
  local runner = ProgramRunner:new()
  runner.actionResource:unblock()
  local subActions = SubActionsMaker:new()
  local buffActionResource = Resource:new()

  local press1 = runner:AddHoldKey { priority = 1, key = "1", }
  --local click1 = runner:AddClick { key = "1", cycleTime = 500, }
  local click2 = runner:AddClick { key = "2", cycleTime = 3500, holdTime = 100 }
  --click2:AddResource(buffActionResource)
-- [[
  local click3 = runner:AddClick { key = "3", cycleTime = 500, }
  --click3:AddResource(buffActionResource)
  local click4 = runner:AddClick { key = "4", cycleTime = 500, }
  local clickF = runner:AddClick { key = "F", cycleTime = 500, }
  --clickF:AddResource(buffActionResource)
  --local clickMR = runner:AddClick { key = "mouseright", cycleTime = 500, }
--]]

  local replaceML = runner:AddReplaceMouseLeft("", {press1,click2,click4,clickF})

  runner:run()
end

function threads_d4_trampslide()
  local runner = ProgramRunner:new()
  runner.actionResource:unblock()
  local subActions = SubActionsMaker:new()

  local press1 = runner:AddHoldKey {    priority = 1,    key = "1",  }
  --local click1 = runner:AddClick { key = "1", cycleTime = 500, }
  local click2 = runner:AddClick { key = "2", cycleTime = 500, }
  local click3 = runner:AddClick { key = "3", cycleTime = 500, }
  local click4 = runner:AddClick { key = "4", cycleTime = 500, }
  --local clickF = runner:AddClick { key = "F", cycleTime = 500, }
  local clickMR = runner:AddClick { key = "mouseright", cycleTime = 500, }
  local replaceML = runner:AddReplaceMouseLeft("", {press1,click2,click4,clickMR})

  runner:run()
end

function threads_d4_rogue_flurry_RF()
  local runner = ProgramRunner:new()
  runner.actionResource:unblock()
  local subActions = SubActionsMaker:new()

  local closeRangeEnabled = false
  local closeRangeEnabledFunc = function() return isOn("capslock") or closeRangeEnabled end
  local closeRangeDisabledFunc = function() return not closeRangeEnabledFunc() end

  local holdFlurry = runner:AddHoldKey {
    priority = 1,
    key = "1",
  }
  local holdRapidFire = runner:AddHoldKey {
    priority = 2,
    key = "2",
    isEnabledFunc = closeRangeEnabledFunc
  }
  local pressFlurryAndTrap = runner:Add(
          subActions
                  :After(200)
                  :Hold("3", 200)
                  :After(500)
                  :Press("lshift")
                  :WithResource(runner.actionResource, 3)
                  :Hold("1", 200)
                  :WithResource(nil)
                  :Release("lshift")
                  :After(900)
                  :Make()
  )
  pressFlurryAndTrap.isEnabledFunc = closeRangeEnabledFunc
  runner.actionResource:unblock()

  local clickTrap = runner:AddClick { key = "3", cycleTime = 500, isEnabledFunc = closeRangeDisabledFunc }
  local click4 = runner:AddClick { key = "4", cycleTime = 500, }
  local closeTicks = 0
  local closeRatio = 0.18
  local closeRange = 32768 * closeRatio
  local capslockAdjuster = runner:AddClick { key = "", cycleTime = 100, pressFunc = function()
    x, y = GetMousePosition()
    xx = x - 32768
    yy = y - 31468
    yy = yy*9/16
    d = math.sqrt(xx*xx + yy*yy)
    if d > closeRange then
      closeTicks = 0
      closeRangeEnabled = false
    else
      closeTicks = closeTicks + 1
      if closeTicks >= 2 then
        closeRangeEnabled = true
      end
    end
  end }

  local replaceML = runner:AddReplaceMouseLeft("F", {holdFlurry, holdRapidFire, pressFlurryAndTrap, clickTrap, click4 })

  runner:run()
end

function threads_d4_rogue_rapid_fire()
  local runner = ProgramRunner:new()
  runner.actionResource:unblock()
  local subActions = SubActionsMaker:new()

  local press1 = runner:AddHoldKey {
    priority = 1,
    key = "1",
  }
  local click2 = runner:AddClick { key = "2", cycleTime = 500, }
  local click3 = runner:AddClick { key = "3", cycleTime = 500, }
  local click4 = runner:AddClick { key = "4", cycleTime = 500, }

  local replaceML = runner:AddReplaceMouseLeft("F", {press1, click2, click3, click4 })

  runner:run()
end

function threads_d4_rogue_flurry()
  local runner = ProgramRunner:new()
  runner.actionResource:unblock()
  local subActions = SubActionsMaker:new()

  local press1 = runner:AddHoldKey {
    priority = 1,
    key = "1",
  }
  local click3 = runner:AddClick { key = "3", cycleTime = 500, }
  local click4 = runner:AddClick { key = "4", cycleTime = 500, }

  local replaceML = runner:AddReplaceMouseLeft("F", {press1, click3, click4 })

  runner:run()
end

function sleepExact(ms)
  local s = GetRunningTime()
  if ms > 200 then
    Sleep(ms / 2)
    sleepExact(ms - (GetRunningTime() - s))
    return
  end
  local t = 0
  while true do
    t = GetRunningTime()
    if ms - (t - s) < 15 then
      while ms - (t - s) > 0 do
        t = GetRunningTime()
      end
      return
    end
    Sleep(1)
  end
end

RTime = GetRunningTime
GETTIME_PER_MS = 2010
MS_PER_SLEEP = 15.3
function timeProfiling()
  local t = RTime()
  local i = 0
  while t == RTime() do i = i + 1 end
  -- now it's beginning of a millisecond
  t = RTime()
  i = 0
  local loops = 1
  while t + loops > RTime() do i = i + 1 end
  GETTIME_PER_MS = i / loops
  myprint("GETTIME_PER_MS", GETTIME_PER_MS)

  local sleeps = 10
  local start = RTime()
  for _ = 1, sleeps do
    Sleep(1)
  end
  MS_PER_SLEEP = (RTime() - start) / sleeps
  myprint("MS_PER_SLEEP", MS_PER_SLEEP)
end

--[[
Profiling result shows that the actions generally complete in <0.01 ms *Running time*
However, some actions may cause waiting time, which is not profile-able with GetRunningTime.
Press/release of mouseleft may take up to 0.06 ms actual time.
--]]


MOUSE_PRESS_TIME = {-1,-1,-1,-1,-1}
MOUSE_RELEASE_TIME = {-1,-1,-1,-1,-1}

function isMouseOn(mb)
  if MOUSE_PRESS_TIME[mb] == RTime() then
    return true
  end

  if MOUSE_RELEASE_TIME[mb] == RTime() then
    return false
  end

  return IsMouseButtonPressed(mb)
end


MODIFIER_CHECK_FUNCTIONS = {
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
  ["mouseleft"] = function() return isMouseOn(1) end,
  ["mousemid"] = function() return isMouseOn(2) end,
  ["mouseright"] = function() return isMouseOn(3) end,
  ["mouse4"] = function() return isMouseOn(4) end,
  ["mouse5"] = function() return isMouseOn(5) end,
}

MOUSE_KEYS = {
  ["mouseleft"] = 1,
  ["mousemid"] = 2,
  ["mouseright"] = 3,
  ["mouse4"] = 4,
  ["mouse5"] = 5,
}

MOUSE_WHEELS = {
  ["mousewheelup"] = 1,
  ["mousewheeldown"] = -1,
}

LOCK_KEYS = {
  ["scrolllock"] = 1,
  ["capslock"] = 1,
  ["numlock"] = 1,
}

MODIFIER_ON_CACHE = {}

---- cooldown click functions ----

keyTimes = {}
function lastKeyTime(key)
  local lastTs = keyTimes[key]
  if (lastTs == nil) then
    -- return a large negative number to prevent cooldown
    return -10000000
  end
  return lastTs
end

function cdClick(key, cd, align, clickFunc)
  -- align: 0, nil: unaligned; >0: align to the next point; <0: align to the previous point

  clickFunc = clickFunc or click

  -- prioritize align in cd = {cd, align}
  if type(cd) == "table" then
    align = cd[2]
    cd = cd[1]
  elseif align == nil then
    align = 0
  end

  local prevTs = lastKeyTime(key)
  local currTs = RTime()
  -- adjust prevTs so it works with align correctly
  if prevTs < 0 then
    prevTs = currTs - cd
  end

  if currTs - prevTs >= cd then
    if not clickFunc(key) then
      return false
    end
    currTs = alignedTs(prevTs, currTs, align)
    keyTimes[key] = currTs
    return true
  else
    return false
  end
end

function checkCd(key, cd)
  return RTime() - last_key_time(key) >= cd
end

---- isOn functions ----

function isOnCached(flag)
  if MODIFIER_ON_CACHE[flag] == nil then
    MODIFIER_ON_CACHE[flag] = isOn(flag)
  end
  return MODIFIER_ON_CACHE[flag]
end

function isOffCached(flag)
  return not isOnCached(flag)
end

function isOn(flag)
  return MODIFIER_CHECK_FUNCTIONS[flag]()
end

function isOff(flag)
  return not isOn(flag)
end

--- click functions ---

PRESS_SAFEGUARD={}
function exitReleaseAll()
  for k, v in pairs(PRESS_SAFEGUARD) do
    if v then
      release(k)
    end
  end
end

function release(key)
  log("release", key, RTime())
  PRESS_SAFEGUARD[key] = nil
  local mouseButton = MOUSE_KEYS[key]
  if mouseButton ~= nil then
    ReleaseMouseButton(mouseButton)
    MOUSE_RELEASE_TIME[mouseButton] = RTime()
    MOUSE_PRESS_TIME[mouseButton] = -1
  elseif MOUSE_WHEELS[key] == nil then
    ReleaseKey(key)
  end
end

function press(key)
  log("press", key, RTime())
  PRESS_SAFEGUARD[key] = 1
  local mouseButton = MOUSE_KEYS[key]
  if mouseButton ~= nil then
    PressMouseButton(mouseButton)
    MOUSE_PRESS_TIME[mouseButton] = RTime()
    MOUSE_RELEASE_TIME[mouseButton] = -1
  elseif MOUSE_WHEELS[key] ~= nil then
    clickMW(key)
  else
    PressKey(key)
  end
end

function click(target)
  log("click", target, RTime())
  if type(target) == "string" then
    -- key
    local key = target
    local mouseButton = MOUSE_KEYS[key]
    if mouseButton ~= nil then
      PressAndReleaseMouseButton(mouseButton)
      MOUSE_RELEASE_TIME[mouseButton] = RTime()
      MOUSE_PRESS_TIME[mouseButton] = -1
    elseif MOUSE_WHEELS[key] ~= nil then
      return clickMW(key)
    elseif key == "" then
      -- do nothing
    else
      PressAndReleaseKey(key)
    end
  else
    -- function
    target()
  end
  return true
end

MIN_MOUSEWHEEL_INTERVAL = 100
lastMW = -MIN_MOUSEWHEEL_INTERVAL
function clickMW(key)
  local code = MOUSE_WHEELS[key]
  local t = RTime()
  if t - lastMW < MIN_MOUSEWHEEL_INTERVAL then
    return false
  end
  MoveMouseWheel(code)
  lastMW = t
  return true
end

function setOn(key)
  if LOCK_KEYS[key] ~= nil then
    if isOff(key) then
      click(key)
    end
  else
    release(key)
    press(key)
  end
end

function setOff(key)
  if LOCK_KEYS[key] ~= nil then
    if isOn(key) then
      click(key)
    end
  else
    release(key)
  end
end

-- avoid functions
GLOBAL_AVOID_MAP = {}

function globallyAvoid(key_or_func)
  if GLOBAL_AVOID_MAP[key_or_func] == nil then
    GLOBAL_AVOID_MAP[key_or_func] = 0
  end
  GLOBAL_AVOID_MAP[key_or_func] = GLOBAL_AVOID_MAP[key_or_func] + 1
end

function globallyUnavoid(key_or_func)
  if GLOBAL_AVOID_MAP[key_or_func] ~= nil then
    GLOBAL_AVOID_MAP[key_or_func] = GLOBAL_AVOID_MAP[key_or_func] - 1
    if GLOBAL_AVOID_MAP[key_or_func] == 0 then
      GLOBAL_AVOID_MAP[key_or_func] = nil
    end
  end
end

function clickAvoid(key_or_func)
  if GLOBAL_AVOID_MAP[key_or_func] then
    return false
  end
  return click(key_or_func)
end

-- classes

CursorLocator = {
  closeRatio = 0.18, -- 0.01 = 1/200 screen width
  staticRatio = 0.01, -- 0.01 = 1/200 screen width
  centerX = 32768,
  centerY = 31468,
  unitLengthRatioY = 9/16, -- width/length ratio of screen
  pixelOvalRatioY = 480/560, -- Y-axis pixels / X-axis pixels of the "close" oval
  historyLength = 5,

  x = 0,
  y = 0,
  xx = 0, -- x relative to center
  yy = 0, -- y relative to center and unified to the scale of x
  xxHistory = {},
  yyHistory = {},
}

function CursorLocator:new(o)
  o = o or {}
  o.xxHistory = o.xxHistory or {}
  o.yyHistory = o.yyHistory or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function CursorLocator:dCenter(i) -- distance to center
  local xx = self.xxHistory[i]
  local yy = self.yyHistory[i]
  return math.sqrt(xx * xx + yy * yy)
end

function CursorLocator:dRelative(i, j) -- distance i to j
  local dx = self.xxHistory[i] - self.xxHistory[j]
  local dy = self.yyHistory[i] - self.yyHistory[j]
  return math.sqrt(dx * dx + dy * dy)
end

function CursorLocator:GetPosition()
  local x, y = GetMousePosition()
  self.x = x
  self.y = y
  self.xx = x - self.centerX
  self.yy = (y - self.centerY) * self.unitLengthRatioY / self.pixelOvalRatioY
  table.insert(self.xxHistory,1,self.xx)
  table.insert(self.yyHistory,1,self.yy)
  if #self.xxHistory > self.historyLength then
    table.remove(self.xxHistory)
    table.remove(self.yyHistory)
  end
end

function CursorLocator:GetPositionFunc()
  local function func()
    self:GetPosition()
  end
  return func
end

function CursorLocator:isCloseI(i)
  i = i or 1
  local d = self:dCenter(i)
  local closeRange = self.closeRatio * 32768
  if d > closeRange then
    return false
  else
    return true
  end
end

function CursorLocator:isStaticI(i)
  i = i or 1
  local d = self:dRelative(i, i+1)
  local staticRange = self.staticRatio * 32768
  if d > staticRange then
    return false
  else
    return true
  end
end

function CursorLocator:isClose(count, reverse)
  reverse = reverse or false
  local i = 1
  count = count or 1
  local j = i + count
  if j > #self.xxHistory + 1 then
    j = #self.xxHistory + 1
  end
  while i < j do
    if reverse == self:isCloseI(i) then
      return false
    end
    i = i + 1
  end
  return true
end

function CursorLocator:isStatic(count)
  local i = 1
  count = count or 1
  local j = i + count
  if j > #self.xxHistory then
    j = #self.xxHistory
  end
  while i < j do
    if not self:isStaticI(i) then
      return false
    end
    i = i + 1
  end
  return true
end

function CursorLocator:isCloseFunc(count)
  local function func()
    return self:isClose(count, false)
  end
  local function notFunc()
    return not self:isClose(count, false)
  end
  return func, notFunc
end

function CursorLocator:isFarFunc(count)
  local function func()
    return self:isClose(count, true)
  end
  local function notFunc()
    return not self:isClose(count, true)
  end
  return func, notFunc
end

function CursorLocator:isStaticFunc(count)
  local function func()
    return self:isStatic(count)
  end
  local function notFunc()
    return not self:isStatic(count)
  end
  return func, notFunc
end


Resource = {
  name = "",
  blocked = false,
  program = nil,
  onRelease = nil, -- func() to call on resource release.
}

function Resource:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Resource:block()
  if self.blocked then return end
  self:removeOwner()
  self.blocked = true
end

function Resource:unblock()
  self.blocked = false
end

function Resource:removeOwner()
  if self.onRelease ~= nil then
    self.onRelease()
  end
  self.onRelease = nil
  self.program = nil
end

function Resource:isOwnedBy(program)
  return self.program == program
end

function Resource:acquire(program, onRelease)
  if self:canAcquire(program) then
    if self.program ~= program then
      self:removeOwner()
    end
    self.program = program
    self.onRelease = onRelease
    return true
  end
  return false
end

function Resource:canAcquire(program)
  return (not self.blocked) and (self.program == nil or self:isOwnedBy(program) or self.program.priority < program.priority)
end

function doNothing(...)
end

CdAction = {
  name = "",
  priority = 0,
  key = "",
  resources = {},
  cycleTime = 0, -- total intended time of a cd-press-release cycle.
  holdTime = 0, -- hold key for this time, and then release. if set to -1, it will attempt to hold infinitely.
  onlyOnce = false, -- if true, only execute the action once.
  subActions = {}, -- subActions is a list of CdAction following special rules.
  -- subActions start in sequence after pressFunc is executed.
  -- A subAction must not acquire the resource of its parent action, or it will cause a deadlock.
  -- A subAction doesn't need to ensure its releaseFunc properly cleaning up its status.
  -- When using subActions,
  --   releaseFunc will not be called when holdTime is reached, until all remaining subActions are executed.
  --   releaseFunc must ensure cleaning up status caused by subActions.
  currentSubActionIndex = 0, -- index is 1-based; 0 means the first subAction needs initialization.

  pressFunc = press, -- func(key) to press
  releaseFunc = release, -- func(key) to release. will be called on destroy/disable

  isEnabledFunc = nil, -- func() returns bool to determine whether it's enabled. nil to skip the whole isEnabled handling
  isEnabled = true,
  onEnabledFunc = doNothing, -- func(self) to execute when enabled.
  onDisabledFunc = doNothing, -- func(self) to execute when disabled.

  firstCycleOffset = 0, -- <=0: start first cycle immediately; >0: start first cycle X ms after init
  align = 0, -- alignment of every cycle. 0: unaligned; >0: align to the next point; <0: align to the previous point
  cycleStartsFromAcquire = false, -- if true, cycles start at when it first attempt to acquire resources (by default, cycles start from when the key is pressed).

  startTs = 0, -- timestamp when the current cycle starts
  pressTs = 0, -- timestamp when the key was recently pressed. Should remain -1 if the key is not being pressed
  clickDone = false, -- true if the press-release is done without interruption in the cycle.
  started = false, -- whether the program has started

  onEnabledClosure = nil, -- func() to execute when enabled - this will include onEnabledFunc
  onDisabledClosure = nil, -- func() to execute when disabled - this will include onDisabledFunc
}

function alwaysTrue()
  return true
end

function edgeTrigger(oldVal, newVal, upFunc, downFunc)
  if oldVal ~= newVal then
    if newVal then
      upFunc()
    else
      downFunc()
    end
  end
  return newVal
end

function alignedTs(oldTs, newTs, align)
  local timeDiff = newTs - oldTs
  if align == 0 or align == nil then
    return newTs
  elseif align > 0 then
    local overTime = timeDiff % align
    if overTime == 0 then
      return newTs
    end
    return newTs - overTime + align
  else
    return newTs - timeDiff % (-align)
  end
end

function CdAction:new(o)
  o = o or {}
  o.resources = o.resources or {}
  o.subActions = o.subActions or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function CdAction:AddResource(r)
  for i, rsc in ipairs(self.resources) do
    if rsc == r then
      return self
    end
  end
  table.insert(self.resources, r)
  return self
end

function CdAction:cdIsDone()
  return RTime() - self.startTs >= self.cycleTime
end

function CdAction:holdIsDone()
  return self.holdTime ~= -1 and self:subActionsAreDone() and RTime() - self.pressTs >= self.holdTime
end

function CdAction:isDone()
  return self:cdIsDone() and self:holdIsDone()
end

-- subAction methods --

function CdAction:subActionsAreDone()
  -- index is 1-based
  return self.currentSubActionIndex > #self.subActions
end

function CdAction:currentSubAction()
  -- index is 1-based
  return self.subActions[self.currentSubActionIndex]
end

function CdAction:nextSubAction()
  self.currentSubActionIndex = self.currentSubActionIndex + 1
  if not self:subActionsAreDone() then
    self:currentSubAction():Init()
  end
end

function CdAction:startSubActions()
  self.currentSubActionIndex = 0
  self:nextSubAction()
end

function CdAction:operateSubActions()
  if not self:subActionsAreDone() then
    local s = self:currentSubAction()
    -- Reset() already ensured that the first subAction is initialized, if it exists
    s:Resume()
    if s:isDone() then
      s:Cleanup()
      self:nextSubAction()
    end
  end
end

function CdAction:completeSubActions()
  if self.currentSubActionIndex == 0 then
    return
  end
  while not self:subActionsAreDone() do
    self:currentSubAction():Cleanup()
    self:nextSubAction()
  end
end

function CdAction:haveAllResources()
  for i, rsc in ipairs(self.resources) do
    if not rsc:isOwnedBy(self) then
      return false
    end
  end
  return true
end

function CdAction:acquireAllResources()
  --log("acquireAllResources", self.key)
  for i, rsc in ipairs(self.resources) do
    --logif(self.key == "a", "resource", rsc.name)
    if not rsc:canAcquire(self) then
      return false
    end
  end

  local function onResourceRelease()
    self:releaseKey()
  end

  for i, rsc in ipairs(self.resources) do
    rsc:acquire(self, onResourceRelease)
  end
  return true
end

function CdAction:pressKey()
  -- log("pressKey", "key", self.key)
  self.pressFunc(self.key)
  self.pressTs = RTime()
  -- log("pressKey", "pressTs", self.pressTs)
  --logif(self.key == "4", "pressTs", self.pressTs)
  if not self.cycleStartsFromAcquire then
    self.startTs = alignedTs(self.startTs, self.pressTs, self.align)
  end
  self:startSubActions()
end

function CdAction:pressed()
  return self.pressTs ~= -1
end

function CdAction:releaseKey()
  -- log("releaseKey", "key", self.key)
  if self:pressed() or self.pressFunc == doNothing then
    self.releaseFunc(self.key)
    self.pressTs = -1
  end
  self:completeSubActions()
  if self:holdIsDone() then
    self.clickDone = true
  end
end

function CdAction:releaseResources()
  --log("releaseResources", self.key)
  for i, rsc in ipairs(self.resources) do
    if rsc:isOwnedBy(self) then
      rsc:removeOwner()
    end
  end
end

function CdAction:Reset()
  self.pressTs = -1
  self.clickDone = true -- ready to start next cycle
  self.startTs = RTime() - self.cycleTime + self.firstCycleOffset
  self.started = false
end

function CdAction:Init()
  self:Reset()
  self.onEnabledClosure = function()
    -- logif(self.key==KEY_D3_FORCE_MOVE,"enabled","time",RTime())
    self:Reset()
    self:onEnabledFunc()
  end
  self.onDisabledClosure = function()
    -- logif(self.key==KEY_D3_FORCE_MOVE,"disabled","time",RTime())
    self:onDisabledFunc()
    self:Cleanup()
  end
end

function CdAction:Resume()
  if self.isEnabledFunc ~= nil then
    self.isEnabled = edgeTrigger(self.isEnabled, self.isEnabledFunc(), self.onEnabledClosure, self.onDisabledClosure)
    if not self.isEnabled then
      return
    end
  end

  --log(self.key, self.pressTs)
  if not self:pressed() then
    -- not pressed, either before or after click
    --log("clickDone", self.clickDone)
    if self.clickDone then
      -- after click
      if (self.onlyOnce and self.started) or not self:cdIsDone() then
        -- should not start next cycle, nothing to do
        return
      end
      -- start next cycle
      self.started = true
      self.clickDone = false
      if self.cycleStartsFromAcquire then
        self.startTs = alignedTs(self.startTs, RTime(), self.align)
      end
      -- now it's before click, keep going
    end

    --log("before click")
    -- before click
    if self:acquireAllResources() then
      -- got all resources, press key
      self:pressKey()
    else
      -- else no resources acquired, nothing to do
      return
    end
  end
  -- key pressed
  --log("holdTime", self.holdTime)
  --log("pressTs", self.pressTs)

  -- handle subActions
  self:operateSubActions()

  if self:holdIsDone() then
    self.clickDone = true
    self:releaseKey()
    self:releaseResources()
  end
end

function CdAction:Cleanup()
  self:releaseKey()
  self:releaseResources()
end

function updateModCache()
  for mod, value in pairs(MODIFIER_ON_CACHE) do
    MODIFIER_ON_CACHE[mod] = isOn(mod)
  end
end

function runPrograms(actions)
  for i, p in ipairs(actions) do p:Init() end
  while true do
    Sleep(LOOP_DELAY)
    updateModCache()
    for i, action in ipairs(actions) do action:Resume() end
    if isOff("scrolllock") then break end
  end
  for i, p in ipairs(actions) do p:Cleanup() end
end

ProgramRunner = {
  actionResource = Resource:new { name = "action" },
  programs = {},
}

function ProgramRunner:new(o)
  o = o or {}
  o.programs = o.programs or {}
  setmetatable(o, self)
  self.__index = self
  self.actionResource:unblock()
  return o
end

function ProgramRunner:Add(p)
  p = CdAction:new(p)
  table.insert(self.programs, p)
  return p
end

function ProgramRunner:AddAction(p)
  p = self:Add(p)
  p:AddResource(self.actionResource)
  return p
end

function ProgramRunner:AddHoldKey(p)
  p = p or {}
  p.holdTime = p.holdTime or -1
  p = self:AddAction(p)
  return p
end

function ProgramRunner:AddClick(p)
  p = p or {}
  p.holdTime = p.holdTime or 0
  p.pressFunc = p.pressFunc or click
  p.releaseFunc = p.releaseFunc or doNothing
  p = self:Add(p)
  return p
end

function ProgramRunner:AddReplaceMouseLeft(replaceKey, blockedActions, blockActionResource)
  p = self:Add {
    blockedActions = blockedActions or {},
    enableBlockedActions = true,
    key = replaceKey,
    cycleTime = 150,
    pressFunc = releaseAndPressML,
    releaseFunc = doNothing,
    isEnabledFunc = ModIsOn("mouseleft"),
    isEnabled = false,
    onEnabledFunc = function(self2)
      log("replaceML enabled")
      self2.enableBlockedActions = false
      for i, p in ipairs(self2.blockedActions) do p:Cleanup() end
      if blockActionResource then
        self.actionResource:block()
      end
    end,
    onDisabledFunc = function(self2)
      log("replaceML disabled")
      if self2.key ~= "" then
        release(self2.key)
      end
      self2.enableBlockedActions = true
      if blockActionResource then
        self.actionResource:unblock()
      end
    end,
    Cleanup = function(self2)
      if self2.key ~= "" then
        release(self2.key)
      end
      self2:releaseKey()
      self2:releaseResources()
    end,
  }
  p.blockedActionsIsEnabledFunc = function() return p.enableBlockedActions end

  for i, action in ipairs(p.blockedActions) do
    if action.isEnabledFunc == nil then
      action.isEnabledFunc = p.blockedActionsIsEnabledFunc
    else
      local existing = action.isEnabledFunc
      action.isEnabledFunc = function()
        return existing() and p.enableBlockedActions
      end
    end
  end

  return p
end

function ProgramRunner:AddEdgeTrigger(isEnabledFunc, upFunc, downFunc)
  local p = self:Add {
    holdTime = -1,
    pressFunc = doNothing,
    releaseFunc = doNothing,
    isEnabledFunc = isEnabledFunc,
    isEnabled = false,
    onEnabledFunc = upFunc,
    onDisabledFunc = downFunc,
  }
  return p
end

function ProgramRunner:AddModEdgeTrigger(mod, upFunc, downFunc)
  return self:AddEdgeTrigger(ModIsOn(mod), upFunc, downFunc)
end

function ProgramRunner:AddModEdgeTriggerCached(mod, upFunc, downFunc)
  return self:AddEdgeTrigger(ModIsOnCached(mod), upFunc, downFunc)
end

function ProgramRunner:run()
  runPrograms(self.programs)
end

SubActionsMaker = {
  resource = nil,
  priority = 0,
  afterMs = 0,
  subActions = {},
}

function SubActionsMaker:new(o)
  o = o or {}
  o.subActions = o.subActions or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function SubActionsMaker:Add(p)
  p = CdAction:new(p)
  table.insert(self.subActions, p)
  p.onlyOnce = true
  p.firstCycleOffset = self.afterMs
  if self.resource ~= nil then
    p:AddResource(self.resource)
    p.priority = self.priority
  end
  self.afterMs = 0
  return p
end

function SubActionsMaker:WithResource(r, priority)
  self.priority = priority or 0
  self.resource = r
  return self
end

function SubActionsMaker:After(ms)
  self.afterMs = self.afterMs + ms
  return self
end

function SubActionsMaker:Press(key)
  self:Add { key = key, releaseFunc = doNothing, }
  return self
end

function SubActionsMaker:Release(key)
  self:Add { key = key, pressFunc = doNothing, }
  return self
end

function SubActionsMaker:Click(key)
  self:Add { key = key, pressFunc = click, releaseFunc = doNothing, }
  return self
end

function SubActionsMaker:Function(func, key)
  self:Add {key = key, pressFunc = func, releaseFunc = doNothing, }
  return self
end

function SubActionsMaker:Hold(key, holdTime)
  self:Add { key = key, holdTime = holdTime, }
  return self
end

function SubActionsMaker:Block(resource)
  self:Add { key = resource, pressFunc = function(r) r:block() end, releaseFunc = doNothing, }
  return self
end

function SubActionsMaker:Unblock(resource)
  self:Add { key = resource, pressFunc = doNothing, releaseFunc = function(r) r:unblock() end, }
  return self
end

function SubActionsMaker:DoNothing()
  self:Add { pressFunc = doNothing, releaseFunc = doNothing, }
  return self
end

function SubActionsMaker:Make(p)
  self:WithResource(nil)
  if self.afterMs > 0 then
    self:DoNothing()
  end
  p = p or {}
  p.pressFunc = p.pressFunc or doNothing
  p.releaseFunc = p.releaseFunc or doNothing
  p.subActions = self.subActions
  self.subActions = {}
  return p
end

function ModIsOn(mod)
  local function func()
    return isOn(mod)
  end
  return func
end

function ModIsOff(mod)
  local function func()
    return isOff(mod)
  end
  return func
end

function ModIsOnCached(mod)
  local function func()
    return isOnCached(mod)
  end
  return func
end

function ModIsOffCached(mod)
  local function func()
    return isOffCached(mod)
  end
  return func
end

--[[
function ModOnCacheMatchesMap(modOnMap)
  local function func()
    for mod, on in pairs(modOnMap) do
      if isOnCached(mod) ~= on then
        return false
      end
    end
    return true
  end
  return func
end
--]]

function releaseAndPressMLRepressShift(replaceKey)
  local lshiftOn = false
  if isOn("lshift") then
    lshiftOn = true
    release("lshift")
  end
  release(replaceKey)
  release("mouseleft")
  press(replaceKey)
  if lshiftOn then
    press("lshift")
  end
  press("mouseleft")
  --Sleep(1)
end

function releaseAndPressML(replaceKey)
  if isOn("lshift") then
    release("lshift")
  end
  if replaceKey ~= "" then
    release(replaceKey)
  end
  release("mouseleft")
  if replaceKey ~= "" then
    press(replaceKey)
  end
  press("mouseleft")
  -- sleep 1 to make sure mouse left is recognized to be released
  -- can be removed if it works
  Sleep(1)
end

function threads_d4_rogue_imbue()
  local runner = ProgramRunner:new()
  local subActions = SubActionsMaker:new()

  local attack1Time= 490
  local press1Time = 220
  local press2Time = 100
  local press2Delay = 100


  local imbueCd=9860
  local imbueKeys = {"3","3","","4","4"}
  local currImbue = 1
  local cycleStartTime = -999999
  local useImbue = function(key)
    local currTime = RTime()
    if currTime - cycleStartTime >= imbueCd then
      currImbue = 1
      cycleStartTime = currTime
    end
    if currImbue <= #imbueKeys and imbueKeys[currImbue] ~= "" then
      click(imbueKeys[currImbue])
    end
    currImbue = currImbue + 1
  end

  local press12 = runner:Add(
          subActions
                  :WithResource(runner.actionResource)
                  :Hold("1", press1Time)
                  :After(attack1Time -press1Time)
                  :Hold("1", press1Time)
                  :After(attack1Time -press1Time)
                  :Hold("1", press1Time)
                  :After(press2Delay)
                  :Function(useImbue,"")
                  :Hold("2", press2Time)
                  :After(attack1Time - press2Time)
                  :Make()
  )
  runner.actionResource:unblock()

  --local click3 = runner:AddClick { key = "3", cycleTime = 500, }
  --local click4 = runner:AddClick { firstCycleOffset=6500, key = "4", cycleTime = 500, }
  local clickF = runner:AddClick { key = "f", cycleTime = 500, }

  local replaceML = runner:AddReplaceMouseLeft("", { }, true)
  --local imbueCounter = runner:AddModEdgeTriggerCached("mouseright", costImbue, doNothing)
  --local clickMR = runner:AddClick { key = "mouseright", cycleTime = 500, }
  --local clickQ = runner:AddClick { key = "q", cycleTime = 500, }

  runner:run()
end

function resetDungenon()
  x, y = GetMousePosition()
  if x > 65335 and y < 200 then
    click("j")
    Sleep(100)
    MoveMouseToVirtual(56674, 53330)
    Sleep(100)
    click("mouseleft")
    Sleep(100)
    MoveMouseToVirtual(30322, 39667)
    Sleep(100)
    click("mouseleft")
    Sleep(100)
    click("m")
    MoveMouseToVirtual(x, y)
  end
end

function logMousePosition()
  x, y = GetMousePosition()
  myprint("get mouse position",{x=x,y=y})
end

function testMousePosition(x, y)
  myprint("move mouse position",{x=x,y=y})
  MoveMouseToVirtual(x, y)
  click("mouseleft")
end


function pressALot()
  x = 50
   -- sleepExact(1)
    press("2")
-- [[
  for _ = 1, 1 do
    Sleep(300)
    press("k")
    --sleepExact(1)
    release("k")
    click("1")
    --sleepExact(16)
  end
--]]
  --  sleepExact(1)
    release("2")
end


last_release_switch = -9999
function OnEvent(event, arg)
  OutputLogMessage("event = %s, arg = %s\n", event, arg)
  --OutputLogMessage("time = %s event = %s, arg = %s\n", GetRunningTime(), event, arg)
  MODIFIER_ON_CACHE = {}
  GLOBAL_AVOID_MAP = {}

  local funcs = {
    [8] = func_selector,
    --[9] = logMousePosition,
    --[9] = function() testMousePosition(32768,31500) end,
    [9] = resetDungenon,
    --[9] = pressALot,
  }
  if (funcs[arg] ~= nil) then
    if (event == "MOUSE_BUTTON_PRESSED") then
      if GetRunningTime() - last_release_switch <= 5 then
        return
      end
      funcs[arg]()
      exitReleaseAll()
    end
    if (event == "MOUSE_BUTTON_RELEASED") then
      last_release_switch = GetRunningTime()
    end
  end
end