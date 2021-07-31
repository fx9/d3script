---- Functions for D3 Builds ----
function multishoot_mouseright_pressed()
  release("2")
  press("1")
  Sleep(400)
  release("1")
  settimeout("mouseright", knife_press_1, 1950)
end

function multishoot_mouseright_released()
  clear_events("mouseright")
  release("1")
  press("2")
end

function switch_dh_multishoot2()
  switch_operations4({
    ["2"] = -1,
    ["3"] = 4000,
    ["4"] = 500,
  },
  {"backslash", {"3"}},
  {nil, {}, multishoot_mouseright_pressed, multishoot_mouseright_released}
  )
end

function switch_dh_rapidshot()
  switch_operations4({
    ["1"] = -1,
    ["2"] = 500,
    ["3"] = 500,
    ["4"] = {500, -500},
  },
  {"backslash", {"3"}}
  )
end

function switch_cru_condemn_lag()
  switch_operations4({
    ["1"] = 200,
    ["2"] = 1000,
    ["3"] = 500,
    ["4"] = {500, -500},
    ["mouseright"] = -1,
  },
  --{"backslash", {"mouseright"}}
  {"backslash", {"mouseright", "1"}, cru_condemn_mouseleft_pressed, cru_condemn_mouseleft_released}
 
 )
end

function switch_cru_thorn()
  switch_operations4({
    ["1"] = -1,
    ["2"] = 1000,
    ["3"] = 500,
    ["4"] = {500, -500},
  },
  {"backslash", {"1", "2", "3"}, }
  --{nil, {"1", "2", "3"}, }
  )
end

function switch_cru_hf()
  switch_operations4({
    --["lshift"] = -1,
    ["1"] = -1,
    ["2"] = 500,
    ["3"] = 5000,
    ["4"] = {500, -500},
    ["mouseright"] = 1800,
  },
  {"backslash", {"1","2","3"}}
  )
end

function switch_cru_hammer()
  switch_operations4({
    ["1"] = -1,
    ["2"] = 500,
    ["3"] = 500,
    ["4"] = {500, -500},
  },
  {"backslash", {"2", "3", "4"}}
  )
end

function switch_znec()
  switch_operations4({
    --["lshift"] = -1,
    ["1"] = -1,
    ["2"] = 500,
    --["3"] = 250,
    ["4"] = 200,
  },
  {"backslash", {"4"}}
  )
end


function wiz_hydra_mouseright_pressed()
  release("1")
end
function wiz_hydra_mouseright_released()
  press("1")
  settimeout("", closure(click, "2"), 50)
  settimeout("", closure(click, "2"), 850)
end
function switch_wiz_hydra()
  cd_click("3", 120000)
  cd_click("4", 120000)
  switch_operations4({
    ["1"] = -1
  },
  {"backslash", {}},
  {"backslash", {}, wiz_hydra_mouseright_pressed, wiz_hydra_mouseright_released}
  )
end

function switch_wiz_blast()
  cd_click("3", 90000)
  cd_click("4", 90000)
  switch_operations4({
    ["1"] = -1,
    ["2"] = 200,
  },
  {"backslash", {}}
  )
end

function switch_wiz_frozen_orb()
  cd_click("3", 90000)
  cd_click("4", 90000)
  switch_operations4({
    ["1"] = -1,
    ["2"] = 1000, -- frozen orb
  },
  {"backslash", {"2"}}
  )
end