# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Neovim configuration based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim). The config is written in Lua and managed with the `lazy.nvim` plugin manager.

## Formatting

All Lua files must be formatted with **StyLua** before committing. The project config is in `.stylua.toml`:

- Column width: 160
- Indent: 2 spaces
- Quote style: AutoPreferSingle
- Parentheses on calls: omitted when unambiguous (`call_parentheses = "None"`)
- Simple statements are collapsed onto one line

Run the formatter:
```sh
stylua .
```

Check without modifying (as CI does):
```sh
stylua --check .
```

CI (`.github/workflows/stylua.yml`) runs `stylua --check .` on PRs.

## Architecture

### Entry point: `init.lua`

All configuration lives in a single `init.lua`. It is structured in this order:

1. **Leader key** — `<Space>` for both `mapleader` and `maplocalleader`
2. **Editor options** — vanilla `vim.o` / `vim.opt` settings (tabs=4 spaces, `undofile`, `clipboard=unnamedplus`, etc.)
3. **Keymaps** — window navigation (`<C-hjkl>`), buffer cycling (`<C-Tab>`/`<C-S-Tab>`), diagnostic list (`<leader>q`)
4. **Autocommands** — yank highlight, diagnostic float on `CursorHold`
5. **`lazy.nvim` bootstrap + plugin specs** — all plugins are declared inline or imported from `lua/plugins/`
6. **`nvim-cmp` setup** — configured after lazy for Rust/LSP completion (separate from blink.cmp; both coexist)

### Plugin split

Plugins that need substantial configuration live in `lua/plugins/` as separate files, each returning a lazy spec table:

| File | Plugin(s) |
|---|---|
| `autopairs.lua` | windwp/nvim-autopairs |
| `debug.lua` | nvim-dap + nvim-dap-ui + mason-nvim-dap + nvim-dap-go |
| `gitsigns.lua` | lewis6991/gitsigns (keymaps for hunks, blame, diff) |
| `indent_line.lua` | lukas-reineke/indent-blankline.nvim |
| `lint.lua` | mfussenegger/nvim-lint (markdownlint for `.md`) |
| `neo-tree.lua` | nvim-neo-tree/neo-tree.nvim (`\` to toggle) |

Additional configuration lives in `lua/`:

- `clangd_config.lua` — returned directly as the clangd server spec (root markers, flags, capabilities)
- `health.lua` — custom `:checkhealth` module

### LSP setup

LSPs are configured via the new `vim.lsp.config` / `vim.lsp.enable` API (not the older `lspconfig.setup` per-server pattern). Mason auto-installs servers listed in `ensure_installed`. Currently active servers:

- **clangd** — C/C++, configured from `lua/clangd_config.lua`. Format-on-save is disabled for `c`/`cpp` filetypes.
- **lua_ls** — Lua, configured inline with Neovim runtime awareness.
- **rustaceanvim** — Rust (handles rust-analyzer itself; no explicit server entry needed).

### Completion

**blink.cmp** is the sole completion engine. It provides LSP capabilities to servers, uses LuaSnip for snippets, and has signature help enabled. Sources: `lsp`, `path`, `snippets`.

### Colorscheme

`bluz71/vim-nightfly-colors` (`nightfly`), loaded eagerly at priority 1000.

### File navigation

- **Telescope** — fuzzy finder; `<leader>s*` bindings. Also overrides LSP go-to keymaps (`grr`, `gri`, `grd`, etc.) on `LspAttach`.
- **yazi.nvim** — terminal file manager; `<leader>-` (current file), `<leader>cw` (cwd), `<C-Up>` (resume).
- **neo-tree** — sidebar tree; `\` to open/close.

### Formatting

`stevearc/conform.nvim` handles format-on-save. Currently configured formatters:

- Lua → `stylua`
- C/C++ → format-on-save disabled (manual `<leader>f`)

Manual format: `<leader>f`
