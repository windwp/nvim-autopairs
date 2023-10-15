local utils = require('nvim-autopairs.utils')
local log = require('nvim-autopairs._log')
local npairs = require('nvim-autopairs')
local M = {}

local default_config = {
    map = '<M-e>',
    chars = { '{', '[', '(', '"', "'" },
    pattern = [=[[%'%"%>%]%)%}%,%`]]=],
    end_key = '$',
    before_key = 'h',
    after_key = 'l',
    cursor_pos_before = true,
    keys = 'qwertyuiopzxcvbnmasdfghjkl',
    highlight = 'Search',
    highlight_grey = 'Comment',
    manual_position = true,
    use_virt_lines = true
}

M.ns_fast_wrap = vim.api.nvim_create_namespace('autopairs_fastwrap')

local config = {}

M.setup = function(cfg)
    if config.chars == nil then
        config = vim.tbl_extend('force', default_config, cfg or {}) or {}
        npairs.config.fast_wrap = config
    end
end

function M.getchar_handler()
    local ok, key = pcall(vim.fn.getchar)
    if not ok then
        return nil
    end
    if key ~= 27 and type(key) == 'number' then
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
        local offset = -1
        for i = col + 2, #line, 1 do
            local char = line:sub(i, i)
            local char2 = line:sub(i - 1, i)
            if string.match(char, config.pattern)
                or (char == ' ' and string.match(char2, '%w'))
            then
                local key = config.keys:sub(index, index)
                index = index + 1
                if not config.manual_position and (
                        utils.is_quote(char)
                        or (
                            utils.is_close_bracket(char)
                            and utils.is_in_quotes(line, col, prev_char)
                        )
                    )
                then
                    offset = 0
                end

                if config.manual_position and i == str_length then
                    key = config.end_key
                end

                table.insert(
                    list_pos,
                    { col = i + offset, key = key, char = char, pos = i }
                )
            end
        end

        local end_col, end_pos
        if config.manual_position then
            end_col = str_length + offset
            end_pos = str_length
        else
            end_col = str_length + 1
            end_pos = str_length + 1
        end
        -- add end_key to list extmark
        if #list_pos == 0 or list_pos[#list_pos].key ~= config.end_key then
            table.insert(
                list_pos,
                { col = end_col, key = config.end_key, pos = end_pos, char = config.end_key }
            )
        end

        M.highlight_wrap(list_pos, row, col, #line)
        vim.defer_fn(function()
            -- get the first char
            local char = #list_pos == 1 and config.end_key or M.getchar_handler()
            vim.api.nvim_buf_clear_namespace(0, M.ns_fast_wrap, row, row + 1)
            for _, pos in pairs(list_pos) do
                local hl_mark = {
                    { pos = pos.pos - 1, key = config.before_key },
                    { pos = pos.pos + 1, key = config.after_key },
                }
                if config.manual_position and (char == pos.key or char == string.upper(pos.key)) then
                    M.highlight_wrap(hl_mark, row, col, #line)
                    M.choose_pos(row, line, pos, end_pair)
                    break
                end
                if char == pos.key then
                    M.move_bracket(line, pos.col, end_pair, false)
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

M.choose_pos = function(row, line, pos, end_pair)
    vim.defer_fn(function()
        -- select a second key
        local char =
            pos.char == nil and config.before_key
            or pos.char == config.end_key and config.after_key
            or M.getchar_handler()
        vim.api.nvim_buf_clear_namespace(0, M.ns_fast_wrap, row, row + 1)
        if not char then return end
        local change_pos = false
        local col = pos.col
        if char == string.upper(config.before_key) or char == string.upper(config.after_key) then
            change_pos = true
        end
        if char == config.after_key or char == string.upper(config.after_key) then
            col = pos.col + 1
        end
        M.move_bracket(line, col, end_pair, change_pos)
        vim.cmd('startinsert')
    end, 10)
end

M.move_bracket = function(line, target_pos, end_pair, change_pos)
    log.debug(target_pos)
    line = line or utils.text_get_current_line(0)
    local row, col = utils.get_cursor()
    local _, next_char = utils.text_cusor_line(line, col, 1, 1, false)
    -- remove an autopairs if that exist
    if next_char == end_pair then
        line = line:sub(1, col) .. line:sub(col + 2, #line)
        target_pos = target_pos - 1
    end

    line = line:sub(1, target_pos) .. end_pair .. line:sub(target_pos + 1, #line)
    vim.api.nvim_set_current_line(line)
    if change_pos then
        vim.api.nvim_win_set_cursor(0, { row + 1, target_pos + (config.cursor_pos_before and 0 or 1) })
    end
end

M.highlight_wrap = function(tbl_pos, row, col, end_col)
    local bufnr = vim.api.nvim_win_get_buf(0)
    if config.use_virt_lines then
        local virt_lines = {}
        local start = 0
        for _, pos in ipairs(tbl_pos) do
            virt_lines[#virt_lines + 1] = { string.rep(' ', pos.pos - start - 1), 'Normal' }
            virt_lines[#virt_lines + 1] = { pos.key, config.highlight }
            start = pos.pos
        end
        vim.api.nvim_buf_set_extmark(bufnr, M.ns_fast_wrap, row, 0, {
            virt_lines = { virt_lines },
            hl_mode = 'blend',
        })
    else
        if config.highlight_grey then
            vim.highlight.range(
                bufnr,
                M.ns_fast_wrap,
                config.highlight_grey,
                { row, col },
                { row, end_col },
                {}
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
end

return M
