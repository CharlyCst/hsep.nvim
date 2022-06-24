local api = vim.api
local popup_buf, win, line, filetype

-- —————————————————————————————— Configuration ————————————————————————————— --

-- the dimension of our window
local win_width = 30
local win_height = 1

-- used to select the appropriate comment symbols when :filetype is on
local comments = {
    sh     = '#',
    python = '#',
    vim    = '"',
    tex    = '%',
    lua    = '--',
    swift  = '//',
    rust   = '//',
    scala  = '//',
    go     = '//',
    java   = '//',
    cpp    = '//',
}

-- The separator
local sep = '—'

-- ————————————————————————————————— Utils —————————————————————————————————— --

-- Get comment from filetype, or user provided table.
local function get_comment_string()
    local comment = comments[filetype]
    if not comment then
        comment = '//'
    end

    local override_comments = vim.g.hsep_language_comments
    if type(override_comments) == 'table' then
        if type(override_comments[filetype]) == 'string' then
            comment = override_comments[filetype]
        end
    end

    return comment
end

-- Get the separator width.
local function get_separator_width()
    local width = 80

    -- check g:hsep_width
    local override_width = vim.g.hsep_width
    if type(override_width) == 'number' then
        width = override_width
    end

    -- check g:hsep_language_width
    local language_specific_width = vim.g.hsep_language_width
    if type(language_specific_width) == 'table' then
        if type(language_specific_width[filetype]) == 'number' then
            width = language_specific_width[filetype]
        end
    end

    return width
end

-- ——————————————————————————————— Separators ——————————————————————————————— --

-- Return the separator for a given text.
local function build_separator(text)
    local comment = get_comment_string()
    local total_width = get_separator_width()
    local separator = ''

    if string.len(text) == 0 then
        separator = comment .. ' ' .. string.rep(sep, total_width - 2 - 2 * string.len(comment)) .. ' ' .. comment
    else
        local separator_width = total_width - string.len(text) - 2 * string.len(comment) - 4
        local left_separator = string.rep(sep, math.floor(separator_width/2))
        local right_separator = string.rep(sep, math.ceil(separator_width/2))
        separator = comment .. ' ' .. left_separator .. ' ' .. text .. ' ' .. right_separator .. ' ' .. comment
    end
    return separator
end

-- Insert a separator with the popup's text under the cursor location.
local function insert_separator()
    local text = api.nvim_buf_get_lines(popup_buf, 0, 1, false)[1]

    local separator = build_separator(text)
    require'hsep'._close_window()
    api.nvim_buf_set_lines(0, line, line, false, {separator})
end

-- ——————————————————————————— Windows & Buffers ———————————————————————————— --

-- Set the Hsep mappings inside the given buffer (e.g. the popup window)
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
    local buf = api.nvim_create_buf(false, true)
    popup_buf = buf
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
    popup_buf = nil
end

-- ———————————————————————— Interact with Separators ———————————————————————— --

local function search_separators()
    local comment = get_comment_string()
    vim.cmd('silent! /' .. comment .. '\\s*' .. string.rep(sep, 5) .. '.*' .. string.rep(sep, 5) .. '\\s*' .. comment)
end

-- —————————————————————————————————— Main —————————————————————————————————— --

-- The main HSep function
local function hsep(args)
    -- Update global variables
    line = api.nvim_win_get_cursor(0)[1]
    filetype = api.nvim_buf_get_option(0, 'filetype')

    if args == 'search' then
        search_separators()
    else
        -- Default to inserting a separator
        open_window()
    end
end

return {
    hsep = hsep,
    _close_window = close_window,
    _insert_separator = insert_separator
}

