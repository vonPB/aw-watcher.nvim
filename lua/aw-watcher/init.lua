local utils = require("aw-watcher.utils")
local uv = vim.loop

Connected = false
ErrorMSGLast = 0
HeartbeatLast = utils.get_time()
File = ''
Language = ''
Project = ''

-- Server
Hostname = utils.get_username()
Ip = '127.0.0.1'
Port = 5600
PulseTime = 30
BaseUrl = "http://" .. Ip .. ":" .. Port .. "/api/0"
Bucketname = "aw-watcher-neovim_" .. Hostname
BucketUrl = BaseUrl .. "/buckets/" .. Bucketname
HeartbeatUrl = BucketUrl .. "/heartbeat?pulsetime=" .. PulseTime

local function HTTPPost(url, data)
  if type(url) ~= "string" or type(data) ~= "table" then
    return
  end

  local payload = vim.fn.json_encode(data)

  local args = {
    '--location',
    '--request',
    'POST',
    url,
    '--header',
    'Content-Type:application/json',
    '--data-raw',
    payload
  }

  Handle = uv.spawn('curl', { args = args, verbatim = false, },
    function(code)
      if not Connected and code == 0 then
        Connected = true
      elseif code ~= 0 then
        Connected = false
      end

      if Handle and not Handle:is_closing() then Handle:close() end
    end)
end

local function CreateBucket()
  local body = {
    name = Bucketname,
    hostname = Hostname,
    client = 'neovim-watcher',
    type = 'app.editor.activity',
  }
  HTTPPost(BucketUrl, body)
end

local function heartbeat()
  local now = utils.get_time()

  if not Connected then
    if now - ErrorMSGLast > 60 then
      utils.notify("Not connected. Use :AWStart to try again.", vim.log.levels.WARN)
      ErrorMSGLast = now
    end
    return
  end

  if not now or not HeartbeatLast or now - HeartbeatLast < 5 then
    return
  end

  local f = utils.get_filename()
  local l = utils.get_filetype()

  if f == File and l == Language and now - HeartbeatLast < 15 then -- abort on no changes but coninue if last heartbeat is older than 15 seconds
    return
  end
  File = f
  Language = l
  HeartbeatLast = now

  local body = {
    timestamp = utils.get_timestamp(),
    duration = 0,
    data = {
      file = File,
      project = vim.b.project_name,
      branch = vim.b.branch_name,
      language = Language,
    }
  }
  HTTPPost(HeartbeatUrl, body)
end

local function AWStart()
  CreateBucket()
end

local function AWStatus()
  utils.notify(Connected and 'Connected' or 'Disconnected', vim.log.levels.INFO)
end

local function create_commands()
  vim.api.nvim_create_user_command('Heartbeat', function() heartbeat() end, { bang = true, desc = 'send a heartbeat' })
  vim.api.nvim_create_user_command('AWStart', function() AWStart() end, { bang = true, desc = 'start activity watcher' })
  vim.api.nvim_create_user_command('AWStatus', function() AWStatus() end,
    { bang = true, desc = 'currently connected status' })
end

local function create_autocommands()
  local augroup = vim.api.nvim_create_augroup('AcitivityWatch', { clear = true })

  -- Heartbeat
  vim.defer_fn(function()
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'BufEnter', 'CursorMovedI', 'CmdlineEnter', 'CmdlineChanged' }, {
      group = augroup,
      callback = heartbeat
    })
  end, 100) -- delay first heartbeat

  -- Start
  vim.api.nvim_create_autocmd('VimEnter', {
    group = augroup,
    callback = AWStart
  })

  -- Git
  vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "FocusGained" }, {
    group = augroup,
    callback = function()
      utils.set_branch_name()
      utils.set_project_name()
    end
  })

end

local function setup()
  create_autocommands()
  create_commands()
end

return {
  setup = setup,
}
