local hs = hs

local M = {}

local function getXcodeAppName()
  local xcodeHandle = io.popen("xcode-select -print-path")
  local xcodeAppName = string.match(xcodeHandle:read("*a"), "/Applications/(.*).app/Contents/Developer")
  xcodeHandle:close()

  return xcodeAppName
end

M.browserAppName = hs.application.nameForBundleID(hs.application.defaultAppForUTI("public.html"))
M.xcodeAppName = getXcodeAppName()

return M
