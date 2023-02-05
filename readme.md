```rs

// ————————————————————————— Horizontal Separators —————————————————————————— //

```

A simple Neovim plugin to insert vertical separators with centered text in your code.

### Features

- Easy to use
- Center text
- Detect file type to adapt comment characters
- Minimal (a single small & self contained lua file)
- Customizable

### Usage

- To insert a new separator use `:HSep`, type your text and press Enter.
- To search separators use `:Hsep search`.

Here are a few optionnal mappings to make things easier

```vim
nmap <Leader>-- :HSep<CR>
nmap <Leader>-s :HSep search<CR>
```

### Install

HSep requires Neovim 0.6.0 or later.

**With Plug**:

```vim
call plug#begin('~/.config/nvim/plugged')
" Add this ↴
Plug 'CharlyCst/hsep.nvim'
call plug#end()
```

### Customize

HSep can be customized through global variables, the following examples are
given in lua:

```lua
-- Per-language comment configuration
vim.g.hsep_language_comments = {
    lua = "---",
}

-- Default separator width
vim.g.hsep_width = 60

-- Per language separator width
vim.g.hsep_language_width = {
    lua = 70,
}
```

In case you find the need to add more languages, feel free to open a PR or an
issue.
Tip: you can find the current file type wirth `:echo &filetype`.

