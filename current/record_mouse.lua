
function addMouseStats(stats, dx, dy)
  if dx > 0 then
    stats["x+"] = stats["x+"] + dx
  else
    stats["x-"] = stats["x-"] - dx
  end

  if dy > 0 then
    stats["y+"] = stats["y+"] + dy
  else
    stats["y-"] = stats["y-"] - dy
  end
end

function mergeStats(stats, temp_stats)
  stats["x+"] = stats["x+"] + temp_stats["x+"]
  stats["x-"] = stats["x-"] + temp_stats["x-"]
  stats["y+"] = stats["y+"] + temp_stats["y+"]
  stats["y-"] = stats["y-"] + temp_stats["y-"]
  temp_stats["x+"] = 0
  temp_stats["x-"] = 0
  temp_stats["y+"] = 0
  temp_stats["y-"] = 0
end

record_one_click = true
function recordMouse()
  warning = false
  s=RTime()
  while isOff("capslock") do
    Sleep(1)
    if RTime()-s > 5000 then
      return
    end
  end
  stats = {
    ["x+"] = 0,
    ["x-"] = 0,
    ["y+"] = 0,
    ["y-"] = 0,
  }
  temp_stats = {
    ["x+"] = 0,
    ["x-"] = 0,
    ["y+"] = 0,
    ["y-"] = 0,
  }
  x, y = GetMousePosition()
  t0 = 0
  tx = 0
  clicks = 0
  s=RTime()
  while isOff("mouseleft") do
    Sleep(1)
    if RTime()-s > 5000 then
      return
    end
  end
  t0 = RTime()
  click_started = false
  while isOn("capslock") do
    Sleep(1)
    -- get pos diff
    xx, yy = GetMousePosition()
    if xx == 0 or xx == 65535 or yy == 0 or yy == 65535 then
       warning = true
    end
    dx=xx-x
    dy=yy-y
    x=xx
    y=yy

    -- print diff
    if dx ~= 0 or dy ~= 0 then
      --myprint("d_stats",{["dx"] = dx, ["dy"] = dy})
    end

    addMouseStats(temp_stats, dx, dy)
    in_click = isOn("mouseleft")

    if record_one_click then
      if in_click and not click_started then
        click_started = true
        t0 = RTime()
        clicks = clicks + 1
        mergeStats(temp_stats,temp_stats)
      end
      if click_started and not in_click then
        click_started = false
        tx = RTime()
        mergeStats(stats,temp_stats)
        break
      end
    else
      if in_click and not click_started then
        click_started = true
        tx = RTime()
        clicks = clicks + 1
        --myprint("one click - temp_stats", temp_stats)
        --myprint("time",tx-t0)
        mergeStats(stats,temp_stats)
      end
      if click_started and not in_click then
        click_started = false
      end
    end
  end
  if warning then
    myprint("warning: mouse hit boarder")
    return
  end
  myprint("mouse movement",stats)
  myprint("time",tx-t0)
  myprint("clicks",clicks)
end
