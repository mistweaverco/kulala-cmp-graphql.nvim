<div align="center">

![Kulala Logo](logo.svg)

# kulala-cmp-graphql.nvim

![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/mistweaverco/kulala-cmp-graphql.nvim?style=for-the-badge)](https://github.com/mistweaverco/kulala-cmp-graphql.nvim/releases/latest)
[![Discord](https://img.shields.io/badge/discord-join-7289da?style=for-the-badge&logo=discord)](https://discord.gg/QyVQmfY4Rt)

[Install](#install) • [Configuration](#configuration) • [Usage](#usage)

<p></p>

A minimal completion source for GraphQL in `.http`/`.rest` files in Neovim using [nvim-cmp][nvim-cmp].

It accompanies [kulala.nvim][kulala], a minimalistic plugin for API development in Neovim.

Kulala is swahili for "rest" or "relax".

<p></p>

![demo](https://github.com/user-attachments/assets/3d3d3a3a-0272-4405-a7e0-7e9b8f03ea88)

<p></p>

</div>

## Install

> [!WARNING]
> Requires Neovim 0.10.0+

Via [lazy.nvim](https://github.com/folke/lazy.nvim):


```lua
require('lazy').setup({
  -- GraphQL completion
  {
    'mistweaverco/kulala-cmp-graphql.nvim',
    config = function()
      require('kulala-cmp-graphql').setup()
    end
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

## Usage

This plugin provides completions for GraphQL queries in `.http`/`.rest` files.

It depends on a GraphQL schema file in your project which should reside next to your `.http`/`.rest` files.

The schema file should be named `[http-file-name-without-extension].graphql-schema.json` or `graphql-schema.json`.

You can download the schema file using [kulala.nvim][kulala] via the
[`:lua require("kulala").download_graphql_schema()`][kulala-dl-gql-schema]

[kulala]: https://github.com/mistweaverco/kulala.nvim
[kulala-dl-gql-schema]: https://kulala.mwco.app/docs/usage/public-methods#download_graphql_schema
[nvim-cmp]: https://github.com/hrsh7th/nvim-cmp


