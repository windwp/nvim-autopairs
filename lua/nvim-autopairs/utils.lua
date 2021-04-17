local M={}
local api = vim.api
local log = require('nvim-autopairs._log')


M.is_attached = function(bufnr)
    local _, check = pcall(api.nvim_buf_get_var, bufnr, "nvim-autopairs")
    return check == 1
end

M.is_in_table = function(tbl, val)
    if tbl == nil then return false end
    for _, value in pairs(tbl) do
        if val== value then return true end
    end
    return false
end

M.check_filetype = function(tbl, filetype)
    if tbl == nil then return true end
    return M.is_in_table(tbl, filetype)
end

M.check_disable_ft = function(tbl, filetype)
    if tbl == nil then return true end
    return not M.is_in_table(tbl, filetype)
end

M.is_in_range = function(row, col, range)
    local start_row, start_col, end_row, end_col  = unpack(range)

    return (row > start_row or (start_row == row and col >= start_col))
        and (row < end_row or (row == end_row and col <= end_col))
end

M.get_cursor = function(bufnr)
    local row, col = unpack(api.nvim_win_get_cursor(0))
    return row - 1, col
end
M.text_get_line = function(bufnr, lnum)
    return api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1]
end
M.text_get_current_line = function(bufnr)
    local row = unpack(api.nvim_win_get_cursor(0))
    return M.text_get_line(bufnr, row -1)
end

M.text_sub_char = function(line, start, num)
    if num > 0 then num = num - 1
    elseif num < 0 then num = num + 1 end
    log.debug(vim.inspect(num))
    return string.sub(line,
        math.min(start, start + num),
        math.max(start, start + num)
    )
end

M.insert_char = function(text)
		api.nvim_put({text}, "c", false, true)
end

M.feed = function(text)
    api.nvim_feedkeys (api.nvim_replace_termcodes(
				text, true, false, true),
		"n", true)
end

M.esc = function(cmd)
    return vim.api.nvim_replace_termcodes(cmd, true, false, true)
end

return M
