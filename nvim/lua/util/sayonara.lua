local function create_scratch_buffer()
  vim.cmd("enew!")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.buflisted = false
  vim.bo.swapfile = false
  return vim.fn.bufnr("%")
end

local function is_buffer_shown_in_another_window(target_buffer)
  local current_tab = vim.fn.tabpagenr()
  local other_tabs = {}
  for i = 1, vim.fn.tabpagenr("$") do
    if i ~= current_tab then
      table.insert(other_tabs, i)
    end
  end

  local current_tab_buffers = vim.fn.tabpagebuflist(current_tab)
  local count = 0
  for _, buf in ipairs(current_tab_buffers) do
    if buf == target_buffer then
      count = count + 1
    end
  end
  if count > 1 then
    return true
  end

  for _, tab in ipairs(other_tabs) do
    local tab_buffers = vim.fn.tabpagebuflist(tab)
    for _, buf in ipairs(tab_buffers) do
      if buf == target_buffer then
        return true
      end
    end
  end

  return false
end

local function preserve_window(target_buffer)
  local altbufnr = vim.fn.bufnr("#")
  local valid_buffers = {}

  for i = 1, vim.fn.bufnr("$") do
    if vim.fn.buflisted(i) == 1 and i ~= target_buffer then
      table.insert(valid_buffers, i)
    end
  end

  if #valid_buffers == 0 then
    return create_scratch_buffer()
  end

  local alt_is_valid = false
  for _, buf in ipairs(valid_buffers) do
    if buf == altbufnr then
      alt_is_valid = true
      break
    end
  end

  if not alt_is_valid then
    local bufs = {}
    for _, buf in ipairs(valid_buffers) do
      if buf < target_buffer then
        table.insert(bufs, 1, buf)
      else
        table.insert(bufs, buf)
      end
    end
    vim.cmd("buffer! " .. bufs[1])
  else
    vim.cmd("buffer! #")
  end
end

local function handle_window(target_buffer, do_preserve)
  if vim.bo.buftype == "quickfix" or (vim.bo.buftype == "nofile" and vim.bo.filetype == "vim") then
    local ok, err = pcall(vim.cmd, "close")
    if ok then
      return
    elseif err:match("E444") then
      -- cannot close last window, continue
    end
  end

  local ok, err = pcall(vim.cmd, "lclose")
  if not ok then
    if err:match("E11") then
      vim.cmd("close")
      return
    end
  end

  local do_delete = not is_buffer_shown_in_another_window(target_buffer)

  if do_preserve then
    local scratch_buffer = preserve_window(target_buffer)
    if do_delete then
      if vim.fn.bufloaded(target_buffer) == 1 and scratch_buffer ~= target_buffer then
        vim.cmd("silent bdelete! " .. target_buffer)
      end
    end
    return
  end

  local valid_buffers = 0
  for i = 1, vim.fn.bufnr("$") do
    if vim.fn.buflisted(i) == 1 and i ~= target_buffer then
      valid_buffers = valid_buffers + 1
    end
  end

  if vim.fn.tabpagenr("$") == 1 and vim.fn.winnr("$") == 1 and valid_buffers >= 1 then
    vim.cmd("silent bdelete! " .. target_buffer)
    return
  end

  pcall(vim.cmd, "close!")

  if do_delete then
    if vim.fn.bufloaded(target_buffer) == 1 then
      vim.cmd("silent bdelete! " .. target_buffer)
    end
  end
end

local function sayonara(do_preserve)
  local hidden = vim.o.hidden
  vim.o.hidden = true

  local target_buffer = vim.fn.bufnr("%")

  local ok, err = pcall(function()
    handle_window(target_buffer, do_preserve)
  end)

  vim.o.hidden = hidden

  if not ok then
    error(err)
  end
end

return sayonara
