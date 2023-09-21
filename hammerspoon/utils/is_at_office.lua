local hs = hs

local function is_at_office()
  -- Desktop cannot be at office
  if hs.battery.batteryType() == nil then
    return false
  end

  -- If not connected to power, then not at office
  if hs.battery.powerSource() ~= "AC Power" then
    return false
  end

  -- If number of external screens is less than 2, then not at office
  local externalScreens = 0
  for _, screen in pairs(hs.screen.allScreens()) do
    if screen:name() == "Built-in Retina Display" then
      return false
    end
    externalScreens = externalScreens + 1
  end
  if externalScreens < 2 then
    return false
  end

  return true
end

return is_at_office
