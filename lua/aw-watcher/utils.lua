local has_notify, notify = pcall(require, "notify")
local M = {}

function M.get_username()
  return os.getenv("USERNAME")
end

function M.get_timestamp()
  return string.format("%s.%03dZ", os.date("!%Y-%m-%dT%H:%M:%S"), 123)
end

function M.get_filename()
  local value = vim.fn.expand("%p") -- file
  if not value then
    return ''
  end
  return value
end

function M.get_time()
  return tonumber(vim.api.nvim_exec("echo localtime()", true)) -- time
end

function M.get_project()
  return vim.fs.dirname(File) or 'Unknown' -- project
end

function M.get_filetype()
  return vim.bo.filetype or 'Unknown' -- language
end

function M.notify(msg, level)
  vim.schedule(function()
    if has_notify then
      notify(msg, level, { title = "Activity Watcher" })
    else
      vim.notify("[Activity Watcher] " .. msg, level)
    end
  end)
end

return M
