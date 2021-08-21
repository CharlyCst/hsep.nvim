```rs

// ————————————————————————— Horizontal Separators —————————————————————————— //

```

A simple Neovim plugin to insert vertical separators with centered text in your code.

### Features

- Easy to use
- Center text
- Detect file type to adapt comment characters
- Minimal (a single small & self contained lua file)
- ~~Customizable~~ (soon?)

### Usage

- To insert a new separator use `:HSep`, type your text and press Enter.
- To search separators use `:Hsep search`.

Here are a few optionnal mappings to make things easier

```vim
nmap <Leader>-- :HSep<CR>
nmap <Leader>-s :HSep search<CR>
```

### Install

HSep require Neovim 0.5.0 or later.

**With Plug**:

```vim
call plug#begin('~/.config/nvim/plugged')
" Add this ↴
Plug 'CharlyCst/hsep.nvim'
call plug#end()
```

