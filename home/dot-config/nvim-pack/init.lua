-- # Core vim

vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.o.autowrite = true
vim.o.breakindent = true
vim.o.confirm = true
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.ignorecase = true
vim.o.inccommand = "split"
vim.o.incsearch = true
vim.o.laststatus = 3
vim.o.list = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 10
vim.o.shiftwidth = 2
vim.o.showmode = false
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.tabstop = 2
vim.o.undofile = true
vim.o.undolevels = 10000
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.filetype.add({
  pattern = { [".*/ghostty/config"] = "conf" },
  filename = {
    ["Brewfile"] = "ruby",
    ["dot-gitconfig"] = "gitconfig",
    ["dot-zshrc"] = "zsh",
  },
})

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y')
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p')
vim.keymap.set({ "n", "v" }, "<leader>P", '"+P')

vim.pack.add({
  "https://github.com/akinsho/bufferline.nvim",
  "https://github.com/b0o/SchemaStore.nvim",
  "https://github.com/brenoprata10/nvim-highlight-colors",
  "https://github.com/coder/claudecode.nvim",
  "https://github.com/dmtrKovalenko/fff.nvim",
  "https://github.com/EdenEast/nightfox.nvim",
  "https://github.com/esmuellert/codediff.nvim",
  "https://github.com/femiagbabiaka/fff-snacks.nvim",
  "https://github.com/f-person/auto-dark-mode.nvim",
  "https://github.com/folke/lazydev.nvim",
  "https://github.com/folke/noice.nvim",
  "https://github.com/folke/sidekick.nvim",
  "https://github.com/folke/snacks.nvim",
  "https://github.com/folke/tokyonight.nvim",
  "https://github.com/folke/which-key.nvim",
  "https://github.com/gbprod/yanky.nvim",
  "https://github.com/kylechui/nvim-surround",
  "https://github.com/ldelossa/gh.nvim",
  "https://github.com/ldelossa/litee.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/MagicDuck/grug-far.nvim",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  "https://github.com/mrjones2014/smart-splits.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/NeogitOrg/neogit",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-mini/mini.files",
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/nvim-neotest/neotest",
  "https://github.com/nvim-neotest/neotest-jest",
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/pwntester/octo.nvim",
  "https://github.com/rafamadriz/friendly-snippets",
  {
    src = "https://github.com/saghen/blink.cmp",
    version = vim.version.range("1"),
  },
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/stevearc/overseer.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  "https://github.com/windwp/nvim-autopairs",
})

-- Shared, config-agnostic local modules (see ~/.config/nvim-shared).
vim.opt.runtimepath:append(vim.fn.expand("~/.config/nvim-shared"))

-- # LSP & diagnostics

vim.diagnostic.config({
  virtual_text = { prefix = "●" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
  },
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({
        bufnr = bufnr,
        scope = "cursor",
        focus = false,
      })
    end,
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  once = true,
  callback = function()
    require("lazydev").setup({
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    })
  end,
})

vim.lsp.config("lua_ls", {
  ---@module 'lspconfig'
  ---@type lspconfig.settings.lua_ls
  settings = {
    Lua = {
      semantic = { enable = false },
      diagnostics = { libraryFiles = "Disable" },
      format = { enable = false },
    },
  },
})

vim.lsp.config("jsonls", {
  before_init = function(_, new_config)
    new_config.settings.json.schemas = new_config.settings.json.schemas or {}
    vim.list_extend(
      new_config.settings.json.schemas,
      require("schemastore").json.schemas()
    )
  end,
  settings = {
    json = { format = { enable = true }, validate = { enable = true } },
  },
})

vim.lsp.config("denols", {
  workspace_required = true,
  root_markers = { "deno.json", "deno.jsonc" },
})

vim.lsp.config("vtsls", {
  on_attach = function(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
  settings = { vtsls = { autoUseWorkspaceTsdk = true } },
})

vim.lsp.config("cssmodules_ls", {
  settings = { capabilities = { definitionProvider = false } },
})

local oxlint_base_on_attach = vim.lsp.config.oxlint.on_attach
vim.lsp.config("oxlint", {
  on_attach = function(client, bufnr)
    if not oxlint_base_on_attach then
      return
    end

    oxlint_base_on_attach(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "LspOxlintFixAll",
    })
  end,
})

local stylelint_base_on_attach = vim.lsp.config.stylelint_lsp.on_attach
vim.lsp.config("stylelint_lsp", {
  on_attach = function(client, bufnr)
    if not stylelint_base_on_attach then
      return
    end

    stylelint_base_on_attach(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "LspStylelintFixAll",
    })
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    local bufmap = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
    end

    if
      client
      and client:supports_method(
        vim.lsp.protocol.Methods.textDocument_definition,
        event.buf
      )
    then
      bufmap("gd", vim.lsp.buf.definition, "Go to definition")
    end

    ---@param jump_opts vim.diagnostic.JumpOpts
    local function jump(jump_opts)
      vim.diagnostic.jump(vim.tbl_extend("force", { float = true }, jump_opts))
    end

    bufmap("]d", function()
      jump({ count = 1 })
    end, "Next diagnostic")
    bufmap("[d", function()
      jump({ count = -1 })
    end, "Previous diagnostic")
    bufmap("]D", function()
      jump({ count = -1, pos = { 0, 0 } })
    end, "Last diagnostic")
    bufmap("[D", function()
      jump({ count = 1, pos = { 0, 0 } })
    end, "First diagnostic")

    local sev = vim.diagnostic.severity
    bufmap("]e", function()
      jump({ count = 1, severity = sev.ERROR })
    end, "Next error")
    bufmap("[e", function()
      jump({ count = -1, severity = sev.ERROR })
    end, "Previous error")
    bufmap("]E", function()
      jump({ count = -1, pos = { 0, 0 }, severity = sev.ERROR })
    end, "Last error")
    bufmap("[E", function()
      jump({ count = 1, pos = { 0, 0 }, severity = sev.ERROR })
    end, "First error")
    bufmap("]w", function()
      jump({ count = 1, severity = sev.WARN })
    end, "Next warning")
    bufmap("[w", function()
      jump({ count = -1, severity = sev.WARN })
    end, "Previous warning")
    bufmap("]W", function()
      jump({ count = -1, pos = { 0, 0 }, severity = sev.WARN })
    end, "Last warning")
    bufmap("[W", function()
      jump({ count = 1, pos = { 0, 0 }, severity = sev.WARN })
    end, "First warning")
  end,
})

-- # Plugin setups

-- ## Mason + LSP/tool installation

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "bashls",
    "copilot",
    "cssls",
    "cssmodules_ls",
    "denols",
    "eslint",
    "graphql",
    "html",
    "jsonls",
    "lua_ls",
    "marksman",
    "oxfmt",
    "oxlint",
    "stylelint_lsp",
    "stylua",
    "taplo",
    "vtsls",
  },
})
require("mason-tool-installer").setup({
  ensure_installed = { "prettier", "shfmt", "shellcheck" },
})

-- ## Conform formatting

require("conform").setup({
  default_format_opts = { lsp_format = "fallback" },
  format_on_save = { timeout_ms = 500 },
  formatters_by_ft = {
    markdown = { "prettier" },
    sh = { "shfmt", "shellcheck" },
    html = { "prettier" },
  },
})
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

-- ## Icons (must run before any plugin that requires nvim-web-devicons)

require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons()

-- ## Colors

require("nightfox").setup({
  options = {
    modules = {
      neogit = false,
    },
    styles = {
      comments = "italic",
    },
  },
  palettes = {
    dawnfox = {
      -- The default dawnfox yellow does not have enough contrast for my eyes.
      -- These values are the colors from the theme, shaded down by 0.25.
      yellow = {
        base = "#b07627",
        bright = "#b37e35",
        dim = "#a66c1b",
      },
    },
  },
  groups = {
    all = {
      -- Nightfox themes set `NormalFloat` to have a darker background color to
      -- contrast it to the standard background color, but float border and
      -- title have the normal background. This results in a weird two-tone
      -- theme for floating windows. I prefer to have NormalFloat, FloatBorder,
      -- and FloatTitle to all have matching styles.
      FloatBorder = {
        link = "NormalFloat",
      },
      FloatTitle = {
        link = "NormalFloat",
      },
    },
  },
})

---@diagnostic disable-next-line: missing-fields
require("tokyonight").setup({ style = "moon" })
require("auto-dark-mode").setup({
  update_interval = 1000,
  set_dark_mode = function()
    vim.cmd.colorscheme("tokyonight")
  end,
  set_light_mode = function()
    vim.cmd.colorscheme("tokyonight")
  end,
})
vim.cmd.colorscheme("tokyonight")

-- ## Core UI

require("which-key").setup()

require("snacks").setup({
  dashboard = {
    preset = {
      header = table.concat({
        [[                               __                ]],
        [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
        [[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
        [[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
        [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
        [[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
      }, "\n"),
      keys = {
        {
          desc = "Find files",
          icon = " ",
          label = "SPC SPC",
          action = "<leader><leader>",
        },
        {
          desc = "Search and replace",
          icon = " ",
          label = "SPC s",
          action = "<leader>s",
        },
        { desc = "Git", icon = " ", label = "SPC gg", action = "<leader>gg" },
        {
          desc = "Projects",
          icon = " ",
          label = "SPC p",
          action = "<leader>p",
        },
      },
    },
    -- Default sections include a `startup` section that requires lazy.nvim's
    -- lazy.stats module. We're on vim.pack, so omit it.
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
    },
  },
  indent = { enabled = true },
  notifier = { enabled = true },
  picker = {
    enabled = true,
    sources = { files = { hidden = true } },
  },
  statuscolumn = { enabled = true },
})

require("lualine").setup({
  options = {
    globalstatus = true,
    disabled_filetypes = { statusline = { "snacks_dashboard" } },
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
  },
  sections = {
    lualine_b = { { "branch", icon = "" } },
    lualine_c = { "filename", "diagnostics" },
    lualine_x = {
      {
        function()
          return require("pr_reviews").statusline()
        end,
      },
      "diff",
      "filetype",
    },
  },
})

require("bufferline").setup({
  options = {
    always_show_bufferline = false,
    diagnostics = "nvim_lsp",
    close_command = function(n)
      Snacks.bufdelete(n)
    end,
    groups = {
      items = {
        require("bufferline.groups").builtin.pinned:with({ icon = "󰐃 " }),
      },
    },
  },
})

require("noice").setup({
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
    },
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
    inc_rename = false,
    lsp_doc_border = true,
  },
})

-- ## Windows

require("smart-splits").setup({ default_amount = 2 })

-- ## Editing

require("nvim-autopairs").setup({
  disable_filetype = { "snacks_picker_input", "grug-far" },
})
require("nvim-surround").setup({})
require("yanky").setup({})
require("nvim-highlight-colors").setup({})

-- ## Completion

require("blink.cmp").setup({
  completion = { documentation = { auto_show = true } },
  fuzzy = { implementation = "prefer_rust" },
  cmdline = { enabled = false },
  sources = {
    default = { "lazydev", "lsp", "path", "snippets", "buffer" },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
      },
    },
  },
})

-- ## Treesitter

require("nvim-treesitter").install({
  "bash",
  "css",
  "git_config",
  "gitattributes",
  "gitcommit",
  "git_rebase",
  "gitignore",
  "graphql",
  "html",
  "javascript",
  "jsdoc",
  "json5",
  "lua",
  "luap",
  "markdown",
  "markdown_inline",
  "regex",
  "tsx",
  "typescript",
  "vim",
  "yaml",
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    if pcall(vim.treesitter.start, args.buf) then
      vim.bo[args.buf].indentexpr =
        "v:lua.require('nvim-treesitter').indentexpr()"
    end
  end,
})

-- ## Files / search

require("mini.files").setup({
  mappings = { synchronize = "<cr>" },
})

require("grug-far").setup({ transient = true })

require("fff").setup({ prompt = " " })
require("fff-snacks").setup()

-- ## Git

require("gitsigns").setup({
  on_attach = function(bufnr)
    local gs = require("gitsigns")
    local function map(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
    end

    map("n", "]c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gs.nav_hunk("next")
      end
    end, "Next Git Hunk")
    map("n", "[c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gs.nav_hunk("prev")
      end
    end, "Previous Git Hunk")
    map("n", "]C", function()
      gs.nav_hunk("last")
    end, "Last Git Hunk")
    map("n", "[C", function()
      gs.nav_hunk("first")
    end, "First Git Hunk")

    map("n", "<leader>gb", gs.blame, "Blame")
    map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
    map("v", "<leader>gs", function()
      gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, "Stage hunk")
    map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
    map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
    map("v", "<leader>gr", function()
      gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, "Reset hunk")
    map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")

    map({ "o", "x" }, "ih", gs.select_hunk)
  end,
})

require("neogit").setup({
  signs = {
    hunk = { "", "" },
    item = { "", "" },
    section = { "", "" },
  },
  integrations = { codediff = true },
})

require("octo").setup({ picker = "snacks", enable_builtin = true })

require("litee.lib").setup()
require("litee.gh").setup({})

require("pr_reviews").setup({})

-- ## Test / tasks

---@diagnostic disable-next-line: missing-fields
require("neotest").setup({
  adapters = { require("neotest-jest")({}) },
  consumers = {
    overseer = function()
      return require("neotest.consumers.overseer")
    end,
  },
})

require("overseer").setup({})

-- ## AI

-- sidekick provides Copilot next-edit-suggestions (the <tab> keymap below).
require("sidekick").setup({})

-- claudecode connects Neovim to the Claude Code CLI over its MCP websocket.
require("claudecode").setup({})

-- ## Misc

require("render-markdown").setup({ code = { border = "thin" } })

-- # Build hooks

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(args)
    if args.data.kind == "delete" then
      return
    end
    local name = args.data.spec.name
    if name == "fff.nvim" then
      require("fff.download").download_or_build_binary()
    elseif name == "nvim-treesitter" then
      vim.cmd("TSUpdate")
    end
  end,
})

-- # Keymaps

-- ## Yanky put / cycle
vim.keymap.set({ "n", "x" }, "y", "<Plug>(YankyYank)", { desc = "Yank" })
vim.keymap.set(
  { "n", "x" },
  "p",
  "<Plug>(YankyPutAfter)",
  { desc = "Put after" }
)
vim.keymap.set(
  { "n", "x" },
  "P",
  "<Plug>(YankyPutBefore)",
  { desc = "Put before" }
)
vim.keymap.set(
  { "n", "x" },
  "gp",
  "<Plug>(YankyGPutAfter)",
  { desc = "Put after selection" }
)
vim.keymap.set(
  { "n", "x" },
  "gP",
  "<Plug>(YankyGPutBefore)",
  { desc = "Put before selection" }
)
vim.keymap.set(
  "n",
  "<c-p>",
  "<Plug>(YankyPreviousEntry)",
  { desc = "Previous yank entry" }
)
vim.keymap.set(
  "n",
  "<c-n>",
  "<Plug>(YankyNextEntry)",
  { desc = "Next yank entry" }
)
vim.keymap.set("n", "]p", "<Plug>(YankyPutIndentAfterLinewise)")
vim.keymap.set("n", "[p", "<Plug>(YankyPutIndentBeforeLinewise)")
vim.keymap.set("n", "]P", "<Plug>(YankyPutIndentAfterLinewise)")
vim.keymap.set("n", "[P", "<Plug>(YankyPutIndentBeforeLinewise)")
vim.keymap.set("n", ">p", "<Plug>(YankyPutIndentAfterShiftRight)")
vim.keymap.set("n", "<p", "<Plug>(YankyPutIndentAfterShiftLeft)")
vim.keymap.set("n", ">P", "<Plug>(YankyPutIndentBeforeShiftRight)")
vim.keymap.set("n", "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)")
vim.keymap.set("n", "=p", "<Plug>(YankyPutAfterFilter)")
vim.keymap.set("n", "=P", "<Plug>(YankyPutBeforeFilter)")

-- ## Window navigation and resize
vim.keymap.set({ "n", "t" }, "<C-h>", require("smart-splits").move_cursor_left)
vim.keymap.set({ "n", "t" }, "<C-j>", require("smart-splits").move_cursor_down)
vim.keymap.set({ "n", "t" }, "<C-k>", require("smart-splits").move_cursor_up)
vim.keymap.set({ "n", "t" }, "<C-l>", require("smart-splits").move_cursor_right)

vim.keymap.set({ "n", "t" }, "<A-h>", require("smart-splits").resize_left)
vim.keymap.set({ "n", "t" }, "<A-j>", require("smart-splits").resize_down)
vim.keymap.set({ "n", "t" }, "<A-k>", require("smart-splits").resize_up)
vim.keymap.set({ "n", "t" }, "<A-l>", require("smart-splits").resize_right)

-- ## Terminal
local function toggle_terminal()
  Snacks.terminal.toggle(nil, { win = { position = "right" } })
end
vim.keymap.set(
  { "n", "t" },
  "<c-/>",
  toggle_terminal,
  { desc = "Toggle terminal" }
)
vim.keymap.set(
  { "n", "t" },
  "<c-_>",
  toggle_terminal,
  { desc = "Toggle terminal" }
)

-- ## Sidekick (next edit suggestions)
vim.keymap.set("n", "<tab>", function()
  if not require("sidekick").nes_jump_or_apply() then
    return "<Tab>"
  end
end, { expr = true, desc = "Apply next edit suggestion" })

-- ## Claude Code
vim.keymap.set(
  { "n", "t", "i", "x" },
  "<c-.>",
  "<cmd>ClaudeCodeFocus<cr>",
  { desc = "Focus Claude" }
)

-- ## Which-key leader bindings

local function run_latest_task(action)
  local overseer = require("overseer")
  local tasks = overseer.list_tasks({ recent_first = true })
  if vim.tbl_isempty(tasks) then
    vim.notify("No tasks found", vim.log.levels.WARN)
  else
    overseer.run_action(tasks[1], action)
  end
end

require("which-key").add({
  {
    "<leader><leader>",
    "<cmd>FFFSnacks<cr>",
    desc = "Find files",
  },
  {
    "<leader>/",
    function()
      Snacks.picker.grep()
    end,
    desc = "Grep",
  },
  {
    "<leader>e",
    function()
      local mf = require("mini.files")
      if not mf.close() then
        mf.open(vim.api.nvim_buf_get_name(0), false)
      end
    end,
    desc = "Toggle file explorer",
  },
  {
    "<leader>p",
    function()
      Snacks.picker.projects()
    end,
    desc = "Projects",
  },
  {
    "<leader>s",
    function()
      local opts = { visualSelectionUsage = "operate-within-range" }
      if vim.bo.filetype == "snacks_dashboard" then
        opts.windowCreationCommand = ""
      end
      require("grug-far").open(opts)
    end,
    mode = { "n", "v" },
    desc = "Search and Replace",
  },

  { "<leader>a", group = "ai" },
  { "<leader>aa", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
  { "<leader>af", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add file" },
  {
    "<leader>as",
    "<cmd>ClaudeCodeSend<cr>",
    mode = { "x" },
    desc = "Send selection",
  },
  { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume session" },
  {
    "<leader>aC",
    "<cmd>ClaudeCode --continue<cr>",
    desc = "Continue session",
  },
  { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select model" },
  { "<leader>ay", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
  { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  { "<leader>b", group = "buffer" },
  {
    "<leader>bd",
    function()
      Snacks.bufdelete()
    end,
    desc = "Delete buffer",
  },
  {
    "<leader>be",
    function()
      Snacks.picker.buffers()
    end,
    desc = "Buffer explorer",
  },
  { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close others" },
  { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Pin buffer" },
  {
    "<leader>bu",
    "<cmd>BufferLineGroupClose ungrouped<cr>",
    desc = "Close unpinned",
  },
  { "<leader>c", group = "config" },
  {
    "<leader>cc",
    "<cmd>edit $MYVIMRC<cr>",
    desc = "Edit config",
  },
  {
    "<leader>cp",
    function()
      vim.pack.update()
    end,
    desc = "Plugin status",
  },
  { "<leader>f", group = "find" },
  {
    "<leader>fc",
    function()
      Snacks.picker.colorschemes({
        -- Drop Neovim's built-in colorschemes, which live under $VIMRUNTIME.
        transform = function(item)
          if item.file and item.file:find(vim.env.VIMRUNTIME, 1, true) then
            return false
          end
          return item
        end,
      })
    end,
    desc = "Colorschemes",
  },
  {
    "<leader>fi",
    function()
      Snacks.picker.icons()
    end,
    desc = "Find icon",
  },
  {
    "<leader>fy",
    "<cmd>YankyRingHistory<cr>",
    mode = { "n", "x" },
    desc = "Yank history",
  },
  { "<leader>g", group = "git" },
  { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
  { "<leader>gd", "<cmd>CodeDiff<cr>", desc = "Diff view" },
  {
    "<leader>go",
    function()
      Snacks.gitbrowse()
    end,
    mode = { "n", "x" },
    desc = "Browse (open)",
  },
  {
    "<leader>gy",
    function()
      Snacks.gitbrowse({
        open = function(url)
          vim.fn.setreg("+", url)
        end,
        notify = false,
        what = "permalink",
      })
    end,
    mode = { "n", "x" },
    desc = "Browse (copy permalink)",
  },
  { "<leader>gh", group = "github" },
  { "<leader>ghc", group = "commits" },
  { "<leader>ghcc", "<cmd>GHCloseCommit<cr>", desc = "Close" },
  { "<leader>ghce", "<cmd>GHExpandCommit<cr>", desc = "Expand" },
  { "<leader>ghco", "<cmd>GHOpenToCommit<cr>", desc = "Open To" },
  { "<leader>ghcp", "<cmd>GHPopOutCommit<cr>", desc = "Pop Out" },
  { "<leader>ghcz", "<cmd>GHCollapseCommit<cr>", desc = "Collapse" },
  { "<leader>ghi", group = "issues" },
  { "<leader>ghip", "<cmd>GHPreviewIssue<cr>", desc = "Preview" },
  { "<leader>ghio", "<cmd>GHOpenIssue<cr>", desc = "Open" },
  { "<leader>ghl", group = "litee" },
  { "<leader>ghlt", "<cmd>LTPanel<cr>", desc = "Toggle panel" },
  { "<leader>ghp", group = "pull request" },
  { "<leader>ghpc", "<cmd>GHClosePR<cr>", desc = "Close" },
  { "<leader>ghpd", "<cmd>GHPRDetails<cr>", desc = "Details" },
  { "<leader>ghpe", "<cmd>GHExpandPR<cr>", desc = "Expand" },
  { "<leader>ghpo", "<cmd>GHOpenPR<cr>", desc = "Open" },
  { "<leader>ghpp", "<cmd>GHPopOutPR<cr>", desc = "Pop out" },
  { "<leader>ghpr", "<cmd>GHRefreshPR<cr>", desc = "Refresh" },
  { "<leader>ghpt", "<cmd>GHOpenToPR<cr>", desc = "Open to" },
  { "<leader>ghpz", "<cmd>GHCollapsePR<cr>", desc = "Collapse" },
  { "<leader>ghr", group = "review" },
  { "<leader>ghrb", "<cmd>GHStartReview<cr>", desc = "Begin" },
  { "<leader>ghrc", "<cmd>GHCloseReview<cr>", desc = "Close" },
  { "<leader>ghrd", "<cmd>GHDeleteReview<cr>", desc = "Delete" },
  { "<leader>ghre", "<cmd>GHExpandReview<cr>", desc = "Expand" },
  { "<leader>ghrs", "<cmd>GHSubmitReview<cr>", desc = "Submit" },
  { "<leader>ghrz", "<cmd>GHCollapseReview<cr>", desc = "Collapse" },
  { "<leader>ght", group = "threads" },
  { "<leader>ghtc", "<cmd>GHCreateThread<cr>", desc = "Create" },
  { "<leader>ghtn", "<cmd>GHNextThread<cr>", desc = "Next" },
  { "<leader>ghtt", "<cmd>GHToggleThread<cr>", desc = "Toggle" },
  { "<leader>o", group = "octo" },
  { "<leader>oi", "<cmd>Octo issue list<cr>", desc = "Issues" },
  { "<leader>op", "<cmd>Octo pr list<cr>", desc = "PRs" },
  { "<leader>od", "<cmd>Octo discussion list<cr>", desc = "Discussions" },
  { "<leader>on", "<cmd>Octo notification list<cr>", desc = "Notifications" },
  {
    "<leader>os",
    function()
      require("octo.utils").create_base_search_command({
        include_current_repo = true,
      })
    end,
    desc = "Search GitHub",
  },
  {
    "<leader>or",
    function()
      require("pr_reviews").pick()
    end,
    desc = "Review requests",
  },
  { "<leader>r", group = "run" },
  { "<leader>rr", "<cmd>OverseerRun<cr>", desc = "Run task" },
  {
    "<leader>re",
    function()
      run_latest_task("restart")
    end,
    desc = "Re-run latest",
  },
  { "<leader>rt", "<cmd>OverseerToggle left<cr>", desc = "Task list" },
  {
    "<leader>ro",
    function()
      run_latest_task("open float")
    end,
    desc = "Output of latest",
  },
  { "<leader>t", group = "test" },
  {
    "<leader>tt",
    function()
      require("neotest").run.run(vim.fn.expand("%"))
    end,
    desc = "Current file",
  },
  {
    "<leader>ta",
    function()
      require("neotest").run.run(vim.uv.cwd())
    end,
    desc = "All",
  },
  {
    "<leader>tn",
    function()
      require("neotest").run.run()
    end,
    desc = "Nearest",
  },
  {
    "<leader>ts",
    function()
      require("neotest").summary.toggle()
    end,
    desc = "Summary",
  },
  {
    "<leader>to",
    function()
      require("neotest").output.open({ enter = true, auto_close = true })
    end,
    desc = "Output",
  },
  {
    "<leader>tS",
    function()
      require("neotest").run.stop()
    end,
    desc = "Stop",
  },
})

-- # Per-machine overrides
-- Sourced last so it can override anything above. Not tracked in dotfiles.
local local_init = vim.fs.joinpath(vim.fn.stdpath("config"), "local.lua")
if vim.uv.fs_stat(local_init) then
  dofile(local_init)
end
