
dofile("current\\test_util.lua")
dofile("current\\script4.lua")
TEST_OUTPUT = false

function test_threads_func_safe_exit(func)
  print("test1: ScrollLock clicked with mouseleft holding")
  mockRuntime:Setup({
    testUtil.click("scrolllock",0),
    testUtil.press("mouseleft",1000),
    testUtil.click("scrolllock",2000),
  })
  func()
  mockRuntime:release("mouseleft")
  mockRuntime:validate()
  
  print("test2: ScrollLock normally clicked")
  mockRuntime:Setup({
    testUtil.click("scrolllock",0),
    testUtil.press("mouseleft",3000),
    testUtil.release("mouseleft",3000),
    testUtil.click("scrolllock",5000),
  })
  func()
  mockRuntime:validate()

  print("test3: ScrollLock not clicked")
  mockRuntime:Setup({})
  func()
  mockRuntime:validate()
end

for k, v in pairs(_G) do
  if string.sub(k, 1, #"threads_") == "threads_" then
    print("test: "..k)
    test_threads_func_safe_exit(v)
  end
end

print("This is the end of test.")