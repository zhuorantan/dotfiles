local vim = vim

local b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' -- You will need this for encoding/decoding
local function b64_encode(data)
  return ((data:gsub('.', function(x)
    local r,b='',x:byte()
    for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
    return r;
  end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
    if (#x < 6) then return '' end
    local c=0
    for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
    return b64:sub(c+1,c+1)
  end)..({ '', '==', '=' })[#data%3+1])
end

local function osc52_yank(text)
  local osc52 = '\x1b]52;c;' .. b64_encode(text) .. '\x07'
  vim.api.nvim_chan_send(vim.v.stderr, osc52)

  local success = false
  if vim.fn.filewritable('/dev/fd/2') == 1 then
    success = vim.fn.writefile({ osc52 }, '/dev/fd/2', 'b') == 0
  else
    success = vim.fn.chansend(vim.v.stderr, osc52) > 0
  end

  if success then
    vim.notify('[osc52] Yanked to clipboard')
  else
    vim.notify('[osc52] Failed to yank to clipboard', 'error')
  end
end

return osc52_yank
