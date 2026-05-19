vim.keymap.set("n","<C-a>", "<Nop>", { noremap = true, silent = true})
vim.keymap.set("v","<C-a>", "<Nop>", { noremap = true, silent = true})

vim.keymap.set("v", "//", function()
	local old_reg = vim.fn.getreg('"') --preserve reg

	-- yank visual selection into register "
	vim.cmd([[normal! y]])
	local text = vim.fn.getreg('"')

	vim.fn.setreg('"', old_reg)

	text = vim.fn.escape(text, [[/\]])

	vim.fn.setreg('/', text)
	vim.cmd("normal! /<CR>")
	end, { silent = true }
)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.colorcolumn = "80"
vim.g.have_nerd_font = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.textwidth = 72
vim.opt.formatoptions="cqt"

vim.opt.mouse = "a"


local function set_transparent()
	local groups = {
		"Normal",
		"NormalNC",
		"EndOfBuffer",
		"NormalFloat",
		"FloatBorder",
		"SignColumn",
		"StatusLine",
		"StatusLineNC",
		"TabLine",
		"TabLineFill",
		"TabLineSel",
		"ColorColumn",
	}

	for _, g in ipairs(groups) do
		vim.api.nvim_set_hl(0, g, {bg = "none"})
	end
	vim.api.nvim_set_hl(0, "TabLineFill", {bg = "none", fg = "#767676"})
end

vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

vim.opt.hlsearch = true -- highlight search matches
vim.opt.incsearch = true

vim.opt.swapfile = false
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

vim.opt.cursorline = true
vim.opt.linebreak = true
vim.opt.wrap = false
-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

vim.opt.tabstop = 8
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true

vim.opt.autoread = true
vim.opt.autowrite = false

-- [[ Basic Keymaps ]]
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("i", "jk", "<Esc>")


-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`
-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--  To check the current status of your plugins, run
--    :Lazy
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require("lazy").setup({
	"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
	-- "gc" to comment visual regions/lines
	{ "numToStr/Comment.nvim", opts = {} },
	{"vimwiki/vimwiki",
		init = function()
		vim.g.vimwiki_list = {
		{
		path = '~/wiki',
		syntax = 'markdown',
		ext = '.md',
		diary_frequency = 'monthly',
		},
        }
		end,
	},
	{"cappyzawa/trim.nvim",opts = {}},
	{
		"jpalardy/vim-slime",
		init = function()
			vim.g.slime_target = "tmux"
			vim.g.slime_bracketed_paste = 0
			vim.g.slime_default_config = {
				socket_name = vim.fn.split(vim.env.TMUX or "", ",")[1] or "default",
				target_pane = ":.1",
			}
			vim.g.slime_dont_ask_default = 1
		end,
	},
	{
		"lervag/vimtex",
		lazy=false,
		init = function()
			-- Use init for configuration, don't use the more common "config".
		end
	},
	{
	  'Julian/lean.nvim',
	  event = { 'BufReadPre *.lean', 'BufNewFile *.lean' },

	  dependencies = {
	    'nvim-telescope/telescope.nvim', -- for Lean-specific pickers
	    -- 'andymass/vim-matchup',          -- for enhanced % motion behavior
	    -- 'andrewradev/switch.vim',        -- for switch support
	    -- 'tomtom/tcomment_vim',           -- for commenting
	  },

	  ---@type lean.Config
	  opts = { -- see the manual for full configuration options
	    mappings = true,
	  }
	},
	{
	    "iamcco/markdown-preview.nvim",
	    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	    ft = { "markdown" },
	    build = function() vim.fn["mkdp#util#install"]() end,
	},
	{ -- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},
	{
		"ThePrimeagen/harpoon",
		dependencies = {
			"nvim-lua/plenary.nvim",
		}
	},
	{
	  "ibhagwan/fzf-lua",
	  -- optional for icon support
	  dependencies = { "nvim-tree/nvim-web-devicons" },
	  -- or if using mini.icons/mini.nvim
	  -- dependencies = { "nvim-mini/mini.icons" },
	  opts = {},
		config = function()
			defaults = {
				file_icons = false,
				git_icons = false,
				color_icons = false,
			}
		end
	},
	{ -- Autocompletion
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			{
				"L3MON4D3/LuaSnip",
				build = (function()
					-- Build Step is needed for regex support in snippets.
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {
					-- `friendly-snippets` contains a variety of premade snippets.
					--    See the README about individual language/framework/plugin snippets:
					--    https://github.com/rafamadriz/friendly-snippets
					 {
					   'rafamadriz/friendly-snippets',
					   config = function()
						 --require("luasnip.loaders.from_vscode").load({ paths = { "~/.config/nvim/LuaSnip" } })
					     require('luasnip.loaders.from_vscode').lazy_load()
					   end,
					},
				},
			},
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			luasnip.config.setup({})

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,noinsert" },

				-- For an understanding of why these mappings were
				-- chosen, you will need to read `:help ins-completion`
				--
				-- No, but seriously. Please read `:help ins-completion`, it is really good!
				mapping = cmp.mapping.preset.insert({
					-- Select the [n]ext item
					["<C-n>"] = cmp.mapping.select_next_item(),
					-- Select the [p]revious item
					["<C-p>"] = cmp.mapping.select_prev_item(),

					-- Scroll the documentation window [b]ack / [f]orward
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),

					-- Accept ([y]es) the completion.
					--  This will auto-import if your LSP supports it.
					--  This will expand snippets if the LSP sent a snippet.
					["<C-c>"] = cmp.mapping.confirm({ select = true }),

					-- Manually trigger a completion from nvim-cmp.
					--  Generally you don't need this, because nvim-cmp will display
					--  completions whenever it has completion options available.
					["<C-Space>"] = cmp.mapping.complete({}),

					-- Think of <c-l> as moving to the right of your snippet expansion.
					--  So if you have a snippet that's like:
					--  function $name($args)
					--    $body
					--  end
					--
					-- <c-l> will move you to the right of each of the expansion locations.
					-- <c-h> is similar, except moving you backwards.
					["<C-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),
					["<C-h>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),

					-- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
					--    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				},
			})
		end,
	},
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = function()
			require("gruvbox").setup({ transparent_mode = true })
			vim.cmd.colorscheme("gruvbox")
			set_transparent()
		end,
	},
	{ "neovim/nvim-lspconfig" },
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		build = ":TSUpdate",
		opts = {
			ensure_installed = { "bash", "julia","c", "html", "lua", "luadoc", "markdown", "vim", "vimdoc" },
			-- Autoinstall languages that are not installed
			auto_install = true,
			highlight = {
				enable = true,
				-- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
				--  If you are experiencing weird indenting issues, add the language to
				--  the list of additional_vim_regex_highlighting and disabled languages for indent.
				additional_vim_regex_highlighting = { "ruby" },
			},
			indent = { enable = true, disable = { "ruby" } },
		},
		config = function(_, opts)
			-- [[ Configure Treesitter ]] See `:help nvim-treesitter`

			---@diagnostic disable-next-line: missing-fields
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
})

local mark = require("harpoon.mark")
local ui = require("harpoon.ui")
local term = require("harpoon.term")



local lspconfig = require("lspconfig")

lspconfig.julials.setup({
  cmd = { "julia",
    "--project=@/home/masonmccallum/.julia/environments/nvim-lspconfig",
    "--startup-file=no", "--history-file=no", "-e",
    [[
    using LanguageServer, SymbolServer;
    server = LanguageServer.LanguageServerInstance(stdin, stdout);
    run(server);
    ]]
  }
})
lspconfig.lua_ls.setup({})
lspconfig.pyright.setup({})


-- [[ harpoon ]]
vim.keymap.set("n", "<leader>a", mark.add_file, { desc = 'Add current file to harpoon list' })
vim.keymap.set("n", "<leader>th", ui.toggle_quick_menu, { desc = 'Toggle harpoon list' })

-- vim.keymap.set("n", "<C-h>", function() ui.nav_file(1) end, { desc = 'jump to first file in harpoon list' })
vim.keymap.set("n", "<C-j>", function() ui.nav_file(2) end, { desc = 'jump to second file in harpoon list' })
vim.keymap.set("n", "<C-k>", function() ui.nav_file(3) end, { desc = 'jump to third file in harpoon list' })
vim.keymap.set("n", "<C-l>", function() ui.nav_file(4) end, { desc = 'jump to fourth file in harpoon list' })

-- [[ vimwiki ]]
vim.g.vimwiki_auto_header = 1
-- Lua initialization file

-- [[ MarkdownPreview ]]
vim.api.nvim_command([[let g:mkdp_auto_start = 0]])
vim.api.nvim_command([[let g:mkdp_auto_stop = 1]])
-- [[ vimtex ]]
vim.g.vimtex_view_method = 'skim'
vim.g.vimtex_view_skim_exe = '/opt/homebrew/bin/skim'
-- [[ vim-slime keymaps ]]
vim.cmd[[xmap <leader>s <Plug>SlimeRegionSend]]
vim.cmd[[nmap <leader>s <Plug>SlimeMotionSend]]
vim.cmd[[nmap <leader>ss <Plug>SlimeLineSend]]

-- Make sure fzf-lua is required
local fzf = require("fzf-lua")

-- Examples with <leader> as the prefix
vim.keymap.set("n", "<leader>f", fzf.files, { desc = "Find files" })
vim.keymap.set("n", "<leader>g", fzf.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>b", fzf.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>r", fzf.resume, { desc = "Resume last search" })

vim.keymap.set("n", "<leader>cf", function()
  fzf.files({ cwd = "~/Documents/research/code" })
end, { desc = "find in code dir" })

vim.keymap.set("n", "<leader>cg", function()
  fzf.live_grep({ cwd = "~/Documents/research/code" })
end, { desc = "Live grep in code dir" })
