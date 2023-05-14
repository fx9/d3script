
dofile("test_util.lua")
dofile("script4.lua")
TEST_OUTPUT = false
mockRuntime:Setup({
  testUtil.click("scrolllock",0),
  testUtil.press("mouseleft",1000),
  testUtil.click("scrolllock",2000),
  testUtil.release("mouseleft",1000),
})
threads_wiz_meteor()
mockRuntime:validate()

mockRuntime:Setup({})
threads_wiz_meteor()
mockRuntime:validate()