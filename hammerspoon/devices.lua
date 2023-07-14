local hs = hs

local M = {}

M.Device = {
  studio = "Zhuoran’s Mac Studio",
  mini = "Zhuoran’s Mac mini",
  mbp = "Zhuoran’s MacBook Pro",
  work = "Zhuoran’s Virtual Machine",
}

M.current = hs.host.localizedName()

return M
