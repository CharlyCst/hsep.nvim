local api = vim.api
local buf, win, line, filetype

-- —————————————————————————————— Configuration ————————————————————————————— --

-- the dimension of our window
local win_width = 30
local win_height = 1

-- used to select the appropriate comment symbols when :filetype is on
local comments = {
    sh     = '#',
    python = '#',
    vim    = '"',
    lua    = '--',
    swift  = '//',
    rust   = '//',
    scala  = '//',
    go     = '//',
    java   = '//',
    cpp    = '//',
}

-- ——————————————————————————————— Separators ——————————————————————————————— --

local function build_separator(text, comment)
    local total_width = 80
    local separator = ''
    if string.len(text) == 0 then
        separator = comment .. ' ' .. string.rep('—', total_width - 2 - 2 * string.len(comment)) .. ' ' .. comment
    else
        local separator_width = total_width - string.len(text) - 2 * string.len(comment) - 4
        local left_separator = string.rep('—', math.floor(separator_width/2))
        local right_separator = string.rep('—', math.ceil(separator_width/2))
        separator = comment .. ' ' .. left_separator .. ' ' .. text .. ' ' .. right_separator .. ' ' .. comment
    end
    return separator
end

local function insert_separator()
    local text = api.nvim_buf_get_lines(buf, 0, 1, false)[1]
    local comment = comments[filetype]
    if not comment then
        comment = '//'
    end
    local separator = build_separator(text, comment)
    require'hsep'._close_window()
    api.nvim_buf_set_lines(0, line, line, false, {separator})
end

-- ——————————————————————————— Windows & Buffers ———————————————————————————— --

local function set_mappings(buf)
    local mappings = {
        ['<Cr>'] = '_insert_separator()',
        ['<Esc>'] = '_close_window()',
    }

    for k, v in pairs(mappings) do
        api.nvim_buf_set_keymap(buf, 'i', k, '<Esc>:lua require"hsep".' .. v .. '<Cr>', {
            nowait = true, noremap = true, silent = true
        })
    end
end

local function open_window()
    -- create the buffer
    buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    set_mappings(buf)

    -- get dimensions
    local width = api.nvim_get_option("columns")
    local height = api.nvim_get_option("lines")

    -- compute starting position
    local row = math.ceil((height - win_height) / 2 - 1)
    local col = math.ceil((width - win_width) / 2)

    -- set some options
    local opts = {
        style = "minimal",
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col,
    }

    -- borders
    local border_buf = api.nvim_create_buf(false, true)

    local border_lines = {'╔═ Separator ' .. string.rep('═', win_width - 12) .. "╗"}
    local middle_line = '║' .. string.rep(' ', win_width) .. '║'
    for i=1, win_height do
      table.insert(border_lines, middle_line)
    end
    table.insert(border_lines, '╚' .. string.rep('═', win_width) .. '╝')
    api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

    local border_opts = {
        style = "minimal",
        relative = "editor",
        width = win_width + 2,
        height = win_height + 2,
        row = row - 1,
        col = col - 1,
    }

    -- open windows
    local border_win = api.nvim_open_win(border_buf, true, border_opts)
    win = api.nvim_open_win(buf, true, opts)
    -- small trick to close both windows together
    api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "'..border_buf)
    -- enter insert mode and exit on enter
    api.nvim_command('startinsert')
    -- todo: how to close windows on focus loss?

end

local function close_window()
    api.nvim_win_close(win, true)
    buf = nil
end

-- —————————————————————————————————— Main —————————————————————————————————— --

-- The main HSep function
local function hsep()
    local position = api.nvim_win_get_cursor(0)
    line = position[1]
    filetype = api.nvim_buf_get_option(0, 'filetype')
    open_window()
end

return {
    hsep = hsep,
    _close_window = close_window,
    _insert_separator = insert_separator
}

