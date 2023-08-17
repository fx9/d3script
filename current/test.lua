
dofile("current\\test_util.lua")
dofile("current\\script4.lua")
TEST_OUTPUT = true
mockRuntime:Setup({
  testUtil.click("scrolllock",0),
  testUtil.press("mouseleft",1000),
  testUtil.click("scrolllock",2000),
  testUtil.release("mouseleft",1000),
})
OnEvent("MOUSE_BUTTON_PRESSED",8)
mockRuntime:validate()

mockRuntime:Setup({})
threads_d4_rogue_imbue()
mockRuntime:validate()

print("This is the end of test.")