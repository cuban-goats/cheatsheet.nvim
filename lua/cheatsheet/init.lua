local M = {
	buf = nil,
	win = nil,
	width = nil,
}

local api = vim.api
local keymap = vim.keymap
local fn = vim.fn

local on_attach = function(bufnr)
	keymap.set("n", "q", "<cmd>close<CR>", { buffer = bufnr })
end

local function createWindow(opts)
	M.buf = api.nvim_create_buf(false, true)
	api.nvim_set_option_value("bufhidden", "wipe", { buf = M.buf })

	local width = opts.width or math.floor(vim.o.columns * 0.8)
	local height = opts.height or math.floor(vim.o.lines * 0.8)
	M.width = width - 2
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		anchor = "NW",
		border = "rounded",
	}
	M.win = api.nvim_open_win(M.buf, true, opts)
end

local function separator()
	return string.rep("-", M.width)
end

local function keymapMenu()
	keymap.set("n", "h", function()
		api.nvim_buf_set_lines(M.buf, 0, -1, false, {
			separator(),
			"<leader>hs: Open default",
			"b: navigate back to menu",
			"<leader>ch: open cheatDir to edit cheatsheets",
			"<leader>X: open cheatFile (instead of X type the number according to the file)",
			separator(),
		})
	end, { buffer = M.buf })
end

local function menuBar(opts)
	api.nvim_buf_set_lines(M.buf, 0, -1, false, {
		"Directory: " .. opts.cheatDir,
		separator(),
		"h: Keymaps",
		separator(),
	})
	keymapMenu()
end

local function showMenu(configOpts, fileShortCuts)
	menuBar(configOpts)
end

local function reopenMenu(configOpts, dirList)
	keymap.set("n", "b", function()
		menuBar(configOpts)
		for i = 1, #dirList do
			api.nvim_buf_set_lines(M.buf, -1, -1, false, { i .. ": " .. dirList[i] })
		end
	end, { buffer = M.buf })
end

local function createFilelist(opts)
	local fileList = {}
	for name, type in vim.fs.dir(opts.cheatDir, {}) do
		if type ~= "directory" then
			table.insert(fileList, name)
		end
	end
	return fileList
end

local function closeWindow()
	if M.win and api.nvim_win_is_valid(M.win) then
		api.nvim_win_close(M.win, true)
	end
end

local function openFile(opts, fileList, shortCutList)
	local fileOpenCommands = {}
	for i = 1, #fileList do
		fileOpenCommands[i] = "split " .. opts.cheatDir .. "/" .. fileList[i]
		-- print(fileOpenCommands[i])
		keymap.set("n", shortCutList[i], function()
			closeWindow()
			vim.cmd(fileOpenCommands[i])
		end, { buffer = M.buf })
	end
end

local function createShortcutList(opts, fileList)
	local shortCutList = {}
	for i = 1, #fileList do
		api.nvim_buf_set_lines(M.buf, -1, -1, false, { i .. ": " .. fileList[i] })
		table.insert(shortCutList, "<leader>" .. i)
	end
	openFile(opts, fileList, shortCutList)
end

local function openDefaultFile(opts)
	keymap.set("n", "<leader>hs", function()
		closeWindow()
		local defaultCmd = "split " .. opts.cheatDir .. "/" .. opts.default
		print(defaultCmd)
		vim.cmd(defaultCmd)
	end, { buffer = M.buf })
end

local function openNeoTree(opts)
	if not pcall(require, "neo-tree") then
		print("cheatsheet.nvim: neo-tree is not installed")
		return
	end
	keymap.set("n", "<leader>ch", function()
		closeWindow()
		vim.cmd("Neotree dir=" .. fn.expand(opts.cheatDir))
	end, { buffer = M.buf })
end

-- planned:
-- function openTypstPreview()
-- end

local setupDone = false

function M.setup(opts)
	if setupDone then
		return
	end
	setupDone = true
	opts = opts or {}

	keymap.set("n", "<Leader>h", function()
		if M.win and api.nvim_win_is_valid(M.win) then
			api.nvim_set_current_win(M.win)
			return
		end
		if not opts.cheatDir then
			print("No cheatsheet directory specified in opts")
			return
		end
		createWindow(opts)
		openNeoTree(opts)
		showMenu(opts)

		local fileList = createFilelist(opts)
		createShortcutList(opts, fileList)
		reopenMenu(opts, fileList)
		openDefaultFile(opts)

		if M.buf and api.nvim_buf_is_valid(M.buf) then
			on_attach(M.buf)
			return
		end
	end)
end

return M
