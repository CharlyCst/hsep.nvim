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

Simply use `:HSep`, type your text and press Enter.

Or better add a binding for it:

```vim
nmap <Leader>- :HSep<CR>
```

### Install

HSep require Neovim 0.4.4 or later.

**With Plug**:

```vim
call plug#begin('~/.config/nvim/plugged')
" Add this ↴
Plug 'CharlyCst/hsep.nvim'
call plug#end()
```

