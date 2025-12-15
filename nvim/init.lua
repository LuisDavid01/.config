vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.cursorcolumn = false
vim.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.incsearch = true
vim.opt.ignorecase = true
vim.opt.wrap = true
vim.opt.tabstop = 4
vim.o.shiftwidth = 4
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.swapfile = false
vim.o.signcolumn = "yes"
vim.o.winborder = "rounded"
vim.g.mapleader = " "

vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	float = {
		source = "if_many", border = "rounded",
	},
})

vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')
vim.keymap.set('n', '<leader>pv', ":Oil<CR>")
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]])
-- greatest remap ever imo
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.pack.add({
	{ src = "https://github.com/vague2k/vague.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/chomosuke/typst-preview.nvim" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/L3MON4D3/LuaSnip" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter",        version = "main" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim",          version = "0.1.8" },
	{ src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
	{ src = "https://github.com/aznhe21/actions-preview.nvim" },
	{ src = "https://github.com/supermaven-inc/supermaven-nvim" },
	{ src = "https://github.com/tpope/vim-fugitive" },
	{ src = "https://github.com/ThePrimeagen/harpoon",                   version = "harpoon2" }
})


--treesitter
require 'nvim-treesitter.config'.setup({
	install_dir = vim.fn.stdpath('data') .. '/site',
	ensure_installed = { "rust", "typescript", "javascript", "go", "c",
		"astro", "markdown", "python", "prisma" },
	highlight = { enable = true },
})

vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'rust', 'javascript', 'zig', 'lua', 'elixir', 'markdown', 'docker', 'makefile',
		'typescript', 'json', 'yaml', 'html', 'css', 'tsx', 'go', 'c', 'r', 'python', 'prisma' },
	callback = function()
		vim.treesitter.start()
	end,
})

--snips
require("luasnip").setup({ enable_autosnippets = true })
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })
local ls = require('luasnip')
local map = vim.keymap.set

map({ "i" }, "<C-h>", function() ls.expand() end, { silent = true })
map({ "i", "s" }, "<C-j>", function() ls.jump(1) end, { silent = true })
map({ "i", "s" }, "<C-k>", function() ls.jump(-1) end, { silent = true })
require "mason".setup()
require "oil".setup({
	view_options = {
		show_icons = true,
		show_hidden = true,
	},
})

-- telescope
local telescope = require("telescope")
telescope.setup({
	defaults = {
		preview = { treesitter = false },
		sorting_strategy = "ascending",
		borderchars = {
			"─", -- top
			"│", -- right
			"─", -- bottom
			"│", -- left
			"┌", -- top-left
			"┐", -- top-right
			"┘", -- bottom-right
			"└", -- bottom-left
		},
		path_displays = { "smart" },
		layout_config = {
			height = 100,
			width = 400,
			prompt_position = "top",
			preview_cutoff = 40,
		}
	}
})
telescope.load_extension("ui-select")

-- telescope para archivos
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })



vim.lsp.enable({
	"lua_ls", "gopls", "tinymist",
	"rust_analyzer", "clangd", "astro", "ts_ls", "emmet_ls",
	"pyright", "prismals"
})

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('my.lsp', {}),
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		if client:supports_method('textDocument/completion') then
			-- Optional: trigger autocompletion on EVERY keypress. May be slow!
			local opts = { buffer = args.buf, silent = true }
			-- Keymaps para buffers con LSP
			vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, opts)
			vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
			vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
			vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
			vim.keymap.set('n', '<leader>f', function()
				vim.lsp.buf.format { async = true }
			end, opts)
			vim.keymap.set('n', '<leader>gr', require('telescope.builtin').lsp_references, opts)
			local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
			client.server_capabilities.completionProvider.triggerCharacters = chars
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		end
	end,
})


-- git
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

--supermaven
require('supermaven-nvim').setup({})

vim.cmd [[set completeopt+=menuone,noselect,popup]]
require "vague".setup({ transparent = true })
vim.cmd("colorscheme vague")


vim.cmd(":hi statusline guibg=NONE")
