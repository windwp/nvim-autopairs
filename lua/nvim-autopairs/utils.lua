local M = {}
local api = vim.api
local log = require('nvim-autopairs._log')

M.key = {
    del = "<del>",
    bs = "<bs>",
    c_h = "<C-h>",
    left = "<left>",
    right = "<right>",
    join_left = "<c-g>U<left>",
    join_right = "<c-g>U<right>",
    undo_sequence = "<c-g>u",
    noundo_sequence = "<c-g>U",
    abbr = "<c-]>"
}

M.set_vchar = function(text)
    text = text:gsub('"', '\\"')
    vim.v.char = text
end


M.is_quote = function(char)
    return char == "'" or char == '"' or char == '`'
end

M.is_bracket = function(char)
    return char == "(" or char == '[' or char == '{' or char == '<'
end


M.is_close_bracket = function(char)
    return char == ")" or char == ']' or char == '}' or char == '>'
end

M.compare = function(value, text, is_regex)
    if is_regex and string.match(text, value) then
        return true
    elseif text == value then
        return true
    end
    return false
end

---check cursor is inside a quote
---@param line string
---@param pos number position in line
---@param quote_type nil|string specify a quote
---@return boolean
M.is_in_quotes = function(line, pos, quote_type)
    local cIndex = 0
    local result = false
    local last_char = quote_type or ''

    while cIndex < string.len(line) and cIndex < pos do
        cIndex = cIndex + 1
        local char = line:sub(cIndex, cIndex)
        local prev_char = line:sub(cIndex - 1, cIndex - 1)
        if
            result == true
            and char == last_char
            and prev_char ~= "\\"
        then
            result = false
            last_char = quote_type or ''
        elseif
            result == false
            and M.is_quote(char)
            and (not quote_type or char == quote_type)
            --a single quote with a word before is not count unless it is a
            -- prefixed string in python (e.g. f'string {with_brackets}')
            and not (
                char == "'"
                and prev_char:match('%w')
                and (vim.bo.filetype ~= 'python' or prev_char:match('[^frbuFRBU]'))
            )
        then
            last_char = quote_type or char
            result = true
        end
    end
    return result
end

M.is_attached = function(bufnr)
    local _, check = pcall(api.nvim_buf_get_var, bufnr or 0, "nvim-autopairs")
    return check == 1
end


M.set_attach = function(bufnr, value)
    api.nvim_buf_set_var(bufnr or 0, "nvim-autopairs", value)
end

M.is_in_table = function(tbl, val)
    if tbl == nil then return false end
    for _, value in pairs(tbl) do
        if val == value then return true end
    end
    return false
end

M.check_filetype = function(tbl, filetype)
    if tbl == nil then return true end
    return M.is_in_table(tbl, filetype)
end

M.check_not_filetype = function(tbl, filetype)
    if tbl == nil then return true end
    return not M.is_in_table(tbl, filetype)
end

M.is_in_range = function(row, col, range)
    local start_row, start_col, end_row, end_col = unpack(range)

    return (row > start_row or (start_row == row and col >= start_col))
        and (row < end_row or (row == end_row and col <= end_col))
end

M.get_cursor = function(bufnr)
    local row, col = unpack(api.nvim_win_get_cursor(bufnr or 0))
    return row - 1, col
end
M.text_get_line = function(bufnr, lnum)
    return api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1] or ''
end

M.text_get_current_line = function(bufnr)
    local row = unpack(api.nvim_win_get_cursor(0)) or 1
    return M.text_get_line(bufnr, row - 1)
end

M.repeat_key = function(key, num)
    local text = ''
    for _ = 1, num, 1 do
        text = text .. key
    end
    return text
end
--- cut text from position with number character
---@param line string  text
---@param col number  position of text
---@param prev_count number  number char previous
---@param next_count number number char next
---@param is_regex boolean if it is regex then will cut all
M.text_cusor_line = function(line, col, prev_count, next_count, is_regex)
    if is_regex then
        prev_count = col
        next_count = #line - col
    end
    local prev = M.text_sub_char(line, col, -prev_count)
    local next = M.text_sub_char(line, col + 1, next_count)
    return prev, next
end

M.text_sub_char = function(line, start, num)
    local finish = start
    if num < 0 then
        start = start + num + 1
    else
        finish = start + num - 1
    end
    return string.sub(line, start, finish)
end

-- P(M.text_sub_char("aa'' aaa", 3, -1))
M.insert_char = function(text)
    api.nvim_put({ text }, "c", false, true)
end

M.feed = function(text, num)
    num = num or 1
    if num < 1 then num = 1 end
    local result = ''
    for _ = 1, num, 1 do
        result = result .. text
    end
    log.debug("result" .. result)
    api.nvim_feedkeys(api.nvim_replace_termcodes(
            result, true, false, true),
        "n", true)
end

M.esc = function(cmd)
    return vim.api.nvim_replace_termcodes(cmd, true, false, true)
end

M.is_block_wise_mode = function()
    return vim.fn.visualmode() == ''
end

--- get prev_char with out key_map
M.get_prev_char = function(opt)
    return opt.line:sub(opt.col - 1, opt.col + #opt.rule.start_pair - 2)
end

return M
