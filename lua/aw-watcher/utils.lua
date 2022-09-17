local has_notify, notify = pcall(require, "notify")
local M = {}

function M.get_username()
  return os.getenv("USERNAME"):upper() -- other aw watchers capitalize this too...
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

function M.get_filetype()
  return vim.bo.filetype or 'Unknown' -- language
end

local function search_git_root()
  local root_dir
  for dir in vim.fs.parents(vim.api.nvim_buf_get_name(0)) do
    if vim.fn.isdirectory(dir .. "/.git") == 1 then
      root_dir = dir
      break
    end
  end
  if root_dir then
    return root_dir
  end
  return nil
end

function M.set_project_name()
  local project = search_git_root() or vim.fn.getcwd()
  project = vim.fs.normalize(project):gsub(".*/", "")
  vim.b.project_name = project
end

function M.set_branch_name()
  local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD")
  if branch ~= "" then
    vim.b.branch_name = branch
    return branch
  else
    vim.b.branch_name = 'Unknown'
  end
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
