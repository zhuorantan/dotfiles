local hs = hs

local M = {}

M.Device = {
  mini = "Zhuoran’s Mac mini",
  mbp = "Zhuoran’s MacBook Pro",
  work = "Zhuoran’s Virtual Machine",
}

M.current = hs.network.configuration.open():computerName()

return M
