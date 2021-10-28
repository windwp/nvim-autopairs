local utils = require('nvim-autopairs.utils')
local log = require('nvim-autopairs._log')
local npairs = require('nvim-autopairs')
local M = {}

local default_config = {
    map = '<M-e>',
    chars = { '{', '[', '(', '"', "'" },
    pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], '%s+', ''),
    offset = -1, -- Offset from pattern match
    end_key = '$',
    keys = 'qwertyuiopzxcvbnmasdfghjkl',
    highlight = 'Search',
    highlight_grey = 'Comment',
}

M.ns_fast_wrap = vim.api.nvim_create_namespace('autopairs_fastwrap')

local config = {}

M.setup = function(cfg)
    if config.chars == nil then
        config = vim.tbl_extend('force', default_config, cfg or {})
        npairs.config.fast_wrap = config
    end
end

function M.getchar_handler()
    local ok, key = pcall(vim.fn.getchar)
    if not ok then
        return nil
    end
    if type(key) == 'number' then
        local key_str = vim.fn.nr2char(key)
        return key_str
    end
    return nil
end

M.show = function(line)
    line = line or utils.text_get_current_line(0)
    log.debug(line)
    local row, col = utils.get_cursor()
    local prev_char = utils.text_cusor_line(line, col, 1, 1, false)
    local end_pair = ''
    if utils.is_in_table(config.chars, prev_char) then
        local rules = npairs.get_buf_rules()
        for _, rule in pairs(rules) do
            if rule.start_pair == prev_char then
                end_pair = rule.end_pair
            end
        end
        if end_pair == '' then
            return
        end
        local list_pos = {}
        local index = 1
        local str_length = #line
        local offset = config.offset
        for i = col + 2, #line, 1 do
            local char = line:sub(i, i)
            if string.match(char, config.pattern) then
                local key = config.keys:sub(index, index)
                index = index + 1
                if utils.is_quote(char) then
                    offset = 0
                end
                table.insert(
                    list_pos,
                    { col = i + offset, key = key, char = char, pos = i }
                )
            end
        end

        table.insert(
            list_pos,
            { col = str_length + 1, key = config.end_key, pos = str_length + 1}
        )

        M.highlight_wrap(list_pos, row, col, #line)
        vim.defer_fn(function()
            local char = #list_pos == 1 and config.end_key or M.getchar_handler()
            vim.api.nvim_buf_clear_namespace(0, M.ns_fast_wrap, row, row + 1)
            for _, pos in pairs(list_pos) do
                if char == pos.key then
                    M.move_bracket(line, pos.col, end_pair,false)
                    break
                end
                if char == string.upper(pos.key) then
                    M.move_bracket(line, pos.col, end_pair, true)
                    break
                end
            end
            vim.cmd('startinsert')
        end, 10)
        return
    end
    vim.cmd('startinsert')
end

M.move_bracket = function(line, target_pos, end_pair, change_pos)
    line = line or utils.text_get_current_line(0)
    local row, col = utils.get_cursor()
    local _, next_char = utils.text_cusor_line(line, col, 1, 1, false)
    -- remove an autopairs if that exist
    -- ((fsadfsa)) dsafdsa
    if next_char == end_pair then
        line = line:sub(1, col) .. line:sub(col + 2, #line)
        target_pos = target_pos - 1
    end

    line = line:sub(1, target_pos) .. end_pair .. line:sub(target_pos + 1, #line)
    vim.api.nvim_set_current_line(line)
    if  change_pos then
        vim.api.nvim_win_set_cursor(0,{row + 1, target_pos})
    end
end

M.highlight_wrap = function(tbl_pos, row, col, end_col)
    local bufnr = vim.api.nvim_win_get_buf(0)
    if config.highlight_grey then
        vim.highlight.range(
            bufnr,
            M.ns_fast_wrap,
            config.highlight_grey,
            { row, col },
            { row, end_col }
        )
    end
    for _, pos in ipairs(tbl_pos) do
        vim.api.nvim_buf_set_extmark(bufnr, M.ns_fast_wrap, row, pos.pos - 1, {
            virt_text = { { pos.key, config.highlight } },
            virt_text_pos = 'overlay',
            hl_mode = 'blend',
        })
    end
end

return M
