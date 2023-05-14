
dofile("current\\test_util.lua")
dofile("backup\\script_backup_20230505.lua5.4.lua")
TEST_OUTPUT = true
mockRuntime:Setup({
  testUtil.click("scrolllock",0),
  testUtil.press("mouseleft",1000),
  testUtil.click("scrolllock",2000),
  testUtil.release("mouseleft",1000),
})
print(switch_wiz_meteor)
switch_wiz_meteor()
mockRuntime:validate()

mockRuntime:Setup({})
switch_wiz_meteor()
mockRuntime:validate()

print("This is the end of test.")