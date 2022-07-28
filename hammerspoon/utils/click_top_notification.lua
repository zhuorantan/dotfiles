local hs = hs

-- Click top notification
local function clickTopNotification()
  local element = hs.axuielement.applicationElement(hs.appfinder.appFromName("Notification Center"))
  local stackSearchFunc = hs.axuielement.searchCriteriaFunction({ attribute = "AXSubrole", value = "AXNotificationCenterAlertStack" })
  local alertSearchFunc = hs.axuielement.searchCriteriaFunction({ attribute = "AXSubrole", value = { "AXNotificationCenterAlert", "AXNotificationCenterBanner" } })

  element:elementSearch(function(_, elementSearchObject, count)
    if count > 0 then
      elementSearchObject[1]:performAction("AXPress")
      return
    end

    -- Try to find an alert stack
    element:elementSearch(function(_, elementSearchObject, count)
      if count == 0 then
        hs.alert.show("No notifications")
        return
      end

      elementSearchObject[1]:performAction("AXPress")

      element:elementSearch(function(_, elementSearchObject, count)
        if count == 0 then
          hs.alert.show("Notification not found in stack")
          return
        end

        elementSearchObject[1]:performAction("AXPress")
      end, alertSearchFunc)
    end, stackSearchFunc)
  end, alertSearchFunc)
end

return clickTopNotification
