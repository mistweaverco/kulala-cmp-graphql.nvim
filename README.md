<div align="center">

![Kulala Logo](logo.svg)

# kulala-cmp-graphql.nvim

![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/mistweaverco/kulala-cmp-graphql.nvim?style=for-the-badge)](https://github.com/mistweaverco/kulala-cmp-graphql.nvim/releases/latest)
[![Discord](https://img.shields.io/badge/discord-join-7289da?style=for-the-badge&logo=discord)](https://discord.gg/QyVQmfY4Rt)

[Install](#install) • [Configuration](#configuration) • [Usage](#usage)

<p></p>

A minimal completion source for GraphQL in `.http`/`.rest` files in Neovim using [nvim-cmp][nvim-cmp].

It accompanies both [kulala.nvim][kulala] and [rest.nvim][restnvim].

Kulala is a minimalistic plugin for API development in Neovim,
whereas rest.nvim is a full fledged REST client for Neovim.

Kulala is swahili for "rest" or "relax".

<p></p>

![demo](https://github.com/user-attachments/assets/3d3d3a3a-0272-4405-a7e0-7e9b8f03ea88)

<p></p>

</div>

## Install

> [!WARNING]
> Requirements:
> - Neovim 0.10.0+
> - Treesitter
> - nvim-cmp

Via [lazy.nvim](https://github.com/folke/lazy.nvim):


```lua
require('lazy').setup({
  -- GraphQL completion
  {
    'mistweaverco/kulala-cmp-graphql.nvim',
    opts = {},
  },
})
```

### Configuration

Add the following to your `cmp.setup`:

```lua
cmp.setup.filetype("http", {
  sources = cmp.config.sources({
    { name = "kulala-cmp-graphql" },
  }, {
    { name = "buffer" },
  }),
})
```

### Full Configuration

A full configuration example using lazy.nvim:

```lua
-- Bootstrapping lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Install Plugins
require("lazy").setup({
  {
    "nvim-treesitter/nvim-treesitter",
    build = function()
      pcall(require("nvim-treesitter.install").update { with_sync = true })
    end,
    config = function()
      require('nvim-treesitter.configs').setup({
        -- Add languages to be installed here that you want installed for treesitter
        ensure_installed = {
          'http',
          'json',
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
  {
    "mistweaverco/kulala.nvim",
    opts= {},
  },
  {
    "hrsh7th/nvim-cmp", -- Autocompletion plugin
    config = function()
      -- Set up nvim-cmp.
      local cmp = require("cmp")
      local lspkind = require("lspkind")

      cmp.setup({
        formatting = {
          format = lspkind.cmp_format({
            preset = "default", -- can be either 'default' (requires nerd-fonts font) or 'codicons' for codicon preset (requires vscode-codicons font)
            mode = "symbol_text", -- show only symbol annotations
            -- maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            -- can also be a function to dynamically calculate max width such as
            -- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
            ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
            show_labelDetails = true, -- show labelDetails in menu. Disabled by default
          }),
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
        }, {
          { name = "buffer" },
        }),
      })
      cmp.setup.filetype("http", {
        sources = cmp.config.sources({
          { name = "kulala-cmp-graphql" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "onsails/lspkind.nvim", -- Add vscode-like pictograms to completion items
      {
        "mistweaverco/kulala-cmp-graphql.nvim", -- GraphQL source for nvim-cmp in http files
        opts = {},
        ft = "http",
      },
    },
  },
})
```

## Usage

This plugin provides completions for GraphQL queries in `.http`/`.rest` files.

It depends on a GraphQL schema file in your project which should reside next to your `.http`/`.rest` files.

The schema file should be named `[http-file-name-without-extension].graphql-schema.json` or `graphql-schema.json`.

You can download the schema file using [kulala.nvim][kulala] via the
[`:lua require("kulala").download_graphql_schema()`][kulala-dl-gql-schema]

[kulala]: https://github.com/mistweaverco/kulala.nvim
[restnvim]: https://github.com/rest-nvim/rest.nvim
[kulala-dl-gql-schema]: https://kulala.mwco.app/docs/usage/public-methods#download_graphql_schema
[nvim-cmp]: https://github.com/hrsh7th/nvim-cmp

