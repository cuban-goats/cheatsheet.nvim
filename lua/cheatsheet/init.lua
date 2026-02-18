-- make a cheatsheet for typst
-- specify a cheatsheet dir in opts
-- specify a filename for a new or existing cheatsheet
-- create a new window that opens the file
-- opt to open with typst preview
-- make own preview of the cheatsheet folder

local M = {
  buf = nil,
  win = nil,
}

local api = vim.api
local keymap = vim.keymap
local fn = vim.fn

local on_attach = function(bufnr)
  keymap.set("n", "q", "<cmd>close<CR>", { buffer = bufnr })
end

function M.setup(opts)
  opts = opts or {}

  keymap.set("n", "<Leader>h", function()
    if M.win and api.nvim_win_is_valid(M.win) then
      api.nvim_set_current_win(M.win)
      return
    end
    if opts.cheatDir then
    else
      print("No cheatsheet directory specified in opts")
    end
    createWindow()
    openNeoTree(opts)
    showMenu(opts)

    local fileList = createFilelist(opts)
    createShortcutList(opts, fileList)
    reopenMenu(opts, fileList)
    openDefaultFile()

    if M.buf and api.nvim_buf_is_valid(M.buf) then
      on_attach(M.buf)
      return
    end
  end, { buffer = M.buf })
end

function createWindow()
  M.buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(M.buf, 'bufhidden', 'wipe')

  local width = 60
  local height = 30
  local row = math.floor((api.nvim_get_option('lines') - height) / 2)
  local col = math.floor((api.nvim_get_option('columns') - width) / 2)
  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    anchor = 'NW',
  }
  M.win = api.nvim_open_win(M.buf, true, opts)
end

function menuBar(opts)
  api.nvim_buf_set_lines(M.buf, 0, -1, false, { "Directory: " .. opts.cheatDir })
  api.nvim_buf_set_lines(M.buf, -1, -1, false, { "------- Menu --------------------------" })
  api.nvim_buf_set_lines(M.buf, -1, -1, false, { "h: Keymaps" })
  api.nvim_buf_set_lines(M.buf, -1, -1, false, { "---------------------------------------" })
  keymapMenu()
end

function showMenu(configOpts, fileShortCuts)
  menuBar(configOpts)
end

function reopenMenu(configOpts, dirList)
  keymap.set("n", "b", function()
    menuBar(configOpts)
    for i = 1, #dirList do
      api.nvim_buf_set_lines(M.buf, -1, -1, false, { i .. ": " .. dirList[i] })
    end
  end, { buffer = M.buf })
end

function keymapMenu()
  keymap.set("n", "h", function()
    api.nvim_buf_set_lines(M.buf, 0, -1, false, { "------- Keymap List: ------------------" })
    api.nvim_buf_set_lines(M.buf, -1, -1, false, { "<leader>hs: Open default" })
    api.nvim_buf_set_lines(M.buf, -1, -1, false, { "b: navigate back to menu" })
    api.nvim_buf_set_lines(M.buf, -1, -1, false, { "<leader>ch: open cheatDir to edit cheatsheets" })
    api.nvim_buf_set_lines(M.buf, -1, -1, false, { "---------------------------------------" })
  end, { buffer = M.buf })
end

function createFilelist(opts)
  local fileList = {}
  for files, value in vim.fs.dir(opts.cheatDir, {}) do
    table.insert(fileList, files)
  end
  return fileList
end

function createShortcutList(opts, fileList)
  shortCutList = {}
  for i = 1, #fileList do
    api.nvim_buf_set_lines(M.buf, -1, -1, false, { i .. ": " .. fileList[i] })
    table.insert(shortCutList, "<leader>" .. i)
    keymap.set("n", shortCutList[i], function()
      print(i)
    end, { buffer = M.buf })
  end
  openFile(opts, fileList, shortCutList)
end

-- deprecated
function openDefaultFile()
  keymap.set("n", "<leader>hs", function()
    closeWindow()
    vim.cmd("split ~/Desktop/theorie/cheatsheets/cheatsheet.typ")
  end, { buffer = M.buf })
end

--

function openFile(opts, fileList, shortCutList)
  local fileOpenCommands = {}
  for i = 1, #fileList do
    fileOpenCommands[i] = "split " .. opts.cheatDir .. "/" .. fileList[i];
    -- print(fileOpenCommands[i])
    keymap.set("n", shortCutList[i], function()
      closeWindow()
      vim.cmd(fileOpenCommands[i])
    end, { buffer = M.buf })
  end
end

function closeWindow()
  if M.win and api.nvim_win_is_valid(M.win) then
    api.nvim_win_close(M.win, true)
    return
  end
  if M.buf and api.nvim_buf_is_valid(M.buf) then
    api.nvim_buf_delete(M.buf, { force = true })
    return
  end
end

function openNeoTree(opts)
  keymap.set("n", "<leader>ch", function()
    closeWindow()
    vim.cmd("Neotree dir=" .. fn.expand(opts.cheatDir))
  end, { buffer = M.buf })
end

-- planned:
-- function openTypstPreview()
-- end

return M
