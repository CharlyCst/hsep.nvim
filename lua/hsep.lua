local api = vim.api

-- —————————————————————————————— Configuration ————————————————————————————— --

-- Used to select the appropriate comment symbols when :filetype is on
local comments = {
    sh     = '#',
    make   = '#',
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
local function get_comment_string(filetype)
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
local function get_separator_width(filetype)
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
local function build_separator(text, filetype)
    local comment = get_comment_string(filetype)
    local total_width = get_separator_width(filetype)
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

-- ———————————————————————— Interact with Separators ———————————————————————— --

local function search_separators()
    local comment = get_comment_string()
    vim.cmd('silent! /' .. comment .. '\\s*' .. string.rep(sep, 5) .. '.*' .. string.rep(sep, 5) .. '\\s*' .. comment)
end

-- —————————————————————————————————— Main —————————————————————————————————— --

-- The main HSep function
local function hsep(args)

    -- Handle search
    if args == 'search' then
        search_separators()
        do return end
    end

    -- Default: insert separator
    vim.ui.input({ prompt = 'Separator' }, function(input)

        -- Check for input
        if input == nil then
            return
        end

        -- Insert the separator
        local line = api.nvim_win_get_cursor(0)[1]
        local filetype = api.nvim_buf_get_option(0, 'filetype')

        local separator = build_separator(input, filetype)
        api.nvim_buf_set_lines(0, line, line, false, {separator})
     end)
end

return {
    hsep = hsep,
}

