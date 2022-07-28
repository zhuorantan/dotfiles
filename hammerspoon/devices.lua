local hs = hs

local M = {}

M.Device = {
  mini = "Zhuoran’s Mac mini",
  mbp = "Zhuoran’s MacBook Pro",
  work = "Zhuoran’s MacBook Pro for Work",
}

M.current = hs.network.configuration.open():computerName()

return M
