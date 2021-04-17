local M={}
local api = vim.api
local log = require('nvim-autopairs._log')

M.key = {
    left = "<left>",
    del = "<del>",
    bs = "<bs>",
    right = "<right>"
}



M.is_quote = function (char)
    return char == "'" or char == '"' or char == '`'
end

M.is_in_quote = function(line, pos, quote)
  local cIndex = 0
  local result = false

  while cIndex < string.len(line) and cIndex < pos  do
    cIndex = cIndex + 1
    local char = line:sub(cIndex, cIndex)
    if
      result == true and
      char == quote and
      line:sub(cIndex -1, cIndex -1) ~= "\\"
    then
       result = false
    elseif result == false and char == quote then
        result = true
    end
  end
  return result
end

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


-- function M.text_prev_next(line, col, prev_count, next_char)
--   prev_count = prev_count or 1
--   next_char = next_char or prev_count

--   if line then
--     local prev = string.sub(line, math.max(col - prev_count + 1, 0), col)
--     local next = string.sub(line, col + 1, math.min(col + next_char, #line + 1))
--         return prev, next
--   end
-- end

M.text_sub_char = function(line, start, num)
    local finish = start
    if num < 0 then
        start = start + num + 1
    else
        finish = start + num -1
    end
    return string.sub(line, start, finish)
end

-- P(M.text_sub_char("aa'' aaa", 3, -1))
M.insert_char = function(text)
		api.nvim_put({text}, "c", false, true)
end

M.feed = function(text, num)
    -- num = num or 1
    -- local result = ''
    -- for _ = 1, num, 1 do
    --     result = result .. text
    -- end
    -- log.debug("result" .. result)
    -- api.nvim_feedkeys (api.nvim_replace_termcodes(
    --     result, true, false, true),
		-- "n", true)

    for i = 1, num, 1 do
        api.nvim_feedkeys (api.nvim_replace_termcodes(
            text, true, false, true),
        "n", true)
    end
end

M.esc = function(cmd)
    return vim.api.nvim_replace_termcodes(cmd, true, false, true)
end

return M
