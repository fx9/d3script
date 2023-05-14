
dofile("test_util.lua")
dofile("script4.lua")
TEST_OUTPUT = false

function test_threads_func_safe_exit(func)
  mockRuntime:Setup({
    testUtil.click("scrolllock",0),
    testUtil.press("mouseleft",1000),
    testUtil.click("scrolllock",2000),
  })
  threads_wiz_meteor()
  mockRuntime:release("mouseleft")
  mockRuntime:validate()
  
  mockRuntime:Setup({
    testUtil.click("scrolllock",0),
    testUtil.press("mouseleft",3000),
    testUtil.release("mouseleft",3000),
    testUtil.click("scrolllock",5000),
  })
  threads_wiz_meteor()
  mockRuntime:validate()

  mockRuntime:Setup({})
  threads_wiz_meteor()
  mockRuntime:validate()
end

for k, v in pairs(_G) do
  if string.sub(k, 1, #"threads_") == "threads_" then
    print("test: "..k)
    test_threads_func_safe_exit(v)
  end
end

print("This is the end of test.")