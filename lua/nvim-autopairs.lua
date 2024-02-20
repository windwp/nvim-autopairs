local log = require('nvim-autopairs._log')
local utils = require('nvim-autopairs.utils')
local basic_rule = require('nvim-autopairs.rules.basic')
local api = vim.api
local highlighter = nil
local M = {}

M.state = {
    disabled = false,
    rules = {},
    buf_ts = {},
}

local default = {
    map_bs = true,
    map_c_h = false,
    map_c_w = false,
    map_cr = true,
    disable_filetype = { 'TelescopePrompt', 'spectre_panel' },
    disable_in_macro = true,
    disable_in_visualblock = false,
    disable_in_replace_mode = true,
    ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
    break_undo = true,
    check_ts = false,
    enable_moveright = true,
    enable_afterquote = true,
    enable_check_bracket_line = true,
    enable_bracket_in_quote = true,
    enable_abbr = false,
    ts_config = {
        lua = { 'string', 'source', 'string_content' },
        javascript = { 'string', 'template_string' },
    },
}

M.setup = function(opt)
    M.config = vim.tbl_deep_extend('force', default, opt or {})
    if M.config.fast_wrap then
        require('nvim-autopairs.fastwrap').setup(M.config.fast_wrap)
    end
    M.config.rules = basic_rule.setup(M.config)

    if M.config.check_ts then
        local ok, ts_rule = pcall(require, 'nvim-autopairs.rules.ts_basic')
        if ok then
            highlighter = require "vim.treesitter.highlighter"
            M.config.rules = ts_rule.setup(M.config)
        end
    end

    if M.config.map_cr then
        M.map_cr()
    end

    M.force_attach()
    local group = api.nvim_create_augroup('autopairs_buf', { clear = true })
    api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
        group = group, pattern = '*',
        callback = function() M.on_attach() end
    })
    api.nvim_create_autocmd('BufDelete', {
        group = group, pattern = '*',
        callback = function(data)
            local cur = api.nvim_get_current_buf()
            local bufnr = tonumber(data.buf) or 0
            if bufnr ~= cur then
                M.set_buf_rule(nil, bufnr)
            end
        end,
    })
    api.nvim_create_autocmd('FileType', {
        group = group, pattern = '*',
        callback = function() M.force_attach() end
    })
end

M.add_rule = function(rule)
    M.add_rules({ rule })
end

M.get_rule = function(start_pair)
    local tbl = M.get_rules(start_pair)
    if #tbl == 1 then
        return tbl[1]
    end
    return tbl
end

M.get_rules = function(start_pair)
    local tbl = {}
    for _, r in pairs(M.config.rules) do
        if r.start_pair == start_pair then
            table.insert(tbl, r)
        end
    end
    return tbl
end

M.remove_rule = function(pair)
    local tbl = {}
    for _, r in pairs(M.config.rules) do
        if r.start_pair ~= pair then
            table.insert(tbl, r)
        end
    end
    M.config.rules = tbl
    if M.state.rules then
        local state_tbl = {}
        local rules = M.get_buf_rules()
        for _, r in pairs(rules) do
            if r.start_pair ~= pair then
                table.insert(state_tbl, r)
            elseif r.key_map and r.key_map ~= '' then
                api.nvim_buf_del_keymap(0, 'i', r.key_map)
            end
        end
        M.set_buf_rule(state_tbl, 0)
    end
    M.force_attach()
end

M.add_rules = function(rules)
    for _, rule in pairs(rules) do
        table.insert(M.config.rules, rule)
    end
    M.force_attach()
end

M.clear_rules = function()
    M.state.rules = {}
    M.config.rules = {}
end

M.disable = function()
    M.state.disabled = true
end

M.enable = function()
    M.state.disabled = false
end

--- force remap key to buffer
M.force_attach = function(bufnr)
    utils.set_attach(bufnr, 0)
    M.on_attach(bufnr)
end

local del_keymaps = function()
    local status, autopairs_keymaps = pcall(api.nvim_buf_get_var, 0, 'autopairs_keymaps')
    if status and autopairs_keymaps and #autopairs_keymaps > 0 then
        for _, key in pairs(autopairs_keymaps) do
            pcall(api.nvim_buf_del_keymap, 0, 'i', key)
        end
    end
end

local function is_disable()
    if M.state.disabled then
        return true
    end

    if vim.bo.filetype == '' and api.nvim_win_get_config(0).relative ~= '' then
        -- disable for any floating window without filetype
        return true
    end

    if vim.bo.modifiable == false then
        return true
    end

    if M.config.disable_in_macro
        and (vim.fn.reg_recording() ~= '' or vim.fn.reg_executing() ~= '')
    then
        return true
    end

    if M.config.disable_in_replace_mode and vim.api.nvim_get_mode().mode == "R" then
        return true
    end

    if M.config.disable_in_visualblock and utils.is_block_wise_mode() then
        return true
    end

    if utils.check_filetype(M.config.disable_filetype, vim.bo.filetype) then
        del_keymaps()
        M.set_buf_rule({}, 0)
        return true
    end
    return false
end

---@return table <number, Rule>
M.get_buf_rules = function(bufnr)
    return M.state.rules[bufnr or api.nvim_get_current_buf()] or {}
end

---@param rules nil|table list or rule
---@param bufnr number buffer number
M.set_buf_rule = function(rules, bufnr)
    if bufnr == 0 or bufnr == nil then
        bufnr = api.nvim_get_current_buf()
    end
    M.state.rules[bufnr] = rules
end

M.on_attach = function(bufnr)
    -- log.debug('on_attach' .. vim.bo.filetype)
    if is_disable() then
        return
    end
    bufnr = bufnr or api.nvim_get_current_buf()

    local rules = {}
    for _, rule in pairs(M.config.rules) do
        if utils.check_filetype(rule.filetypes, vim.bo.filetype)
            and utils.check_not_filetype(rule.not_filetypes, vim.bo.filetype)
        then
            table.insert(rules, rule)
        end
    end
    -- sort by pair and keymap
    table.sort(rules, function(a, b)
        if a.start_pair == b.start_pair then
            if not b.key_map then
                return a.key_map
            end
            if not a.key_map then
                return b.key_map
            end
            return #a.key_map < #b.key_map
        end
        if #a.start_pair == #b.start_pair then
            return string.byte(a.start_pair) > string.byte(b.start_pair)
        end
        return #a.start_pair > #b.start_pair
    end)

    M.set_buf_rule(rules, bufnr)

    if M.config.check_ts then
        if highlighter and highlighter.active[bufnr] then
            M.state.ts_node = M.config.ts_config[vim.bo.filetype]
        else
            M.state.ts_node = nil
        end
    end

    if utils.is_attached(bufnr) then
        return
    end
    del_keymaps()
    local enable_insert_auto = false
    local autopairs_keymaps = {}
    local expr_map = function(key)
        api.nvim_buf_set_keymap(bufnr, 'i', key, '', {
            expr = true,
            noremap = true,
            desc = "autopairs map key",
            callback = function() return M.autopairs_map(bufnr, key) end,
        })
        table.insert(autopairs_keymaps, key)
    end
    for _, rule in pairs(rules) do
        if rule.key_map ~= nil then
            if rule.is_regex == false then
                if rule.key_map == '' then
                    rule.key_map = rule.start_pair:sub(#rule.start_pair)
                end
                expr_map(rule.key_map)
                local key_end = rule.key_end or rule.end_pair:sub(1, 1)
                if #key_end >= 1 and key_end ~= rule.key_map and rule.move_cond ~= nil then
                    expr_map(key_end)
                end
            else
                if rule.key_map ~= '' then
                    expr_map(rule.key_map)
                elseif rule.is_endwise == false then
                    enable_insert_auto = true
                end
            end
        end
    end
    api.nvim_buf_set_var(bufnr, 'autopairs_keymaps', autopairs_keymaps)

    if enable_insert_auto then
        -- capture all key use it to trigger regex pairs
        -- it can make an issue with paste from register
        api.nvim_create_autocmd('InsertCharPre', {
            group = api.nvim_create_augroup(string.format("autopairs_insert_%d", bufnr), { clear = true }),
            buffer = bufnr,
            callback = function()
                M.autopairs_insert(bufnr, vim.v.char)
            end
        })
    end

    if M.config.fast_wrap and M.config.fast_wrap.map then
        api.nvim_buf_set_keymap(
            bufnr,
            'i',
            M.config.fast_wrap.map,
            "<esc>l<cmd>lua require('nvim-autopairs.fastwrap').show()<cr>",
            { noremap = true }
        )
    end

    if M.config.map_bs then
        api.nvim_buf_set_keymap(
            bufnr,
            'i',
            '<bs>',
            '',
            { callback = M.autopairs_bs, expr = true, noremap = true }
        )
    end

    if M.config.map_c_h then
        api.nvim_buf_set_keymap(
            bufnr,
            "i",
            utils.key.c_h,
            '',
            { callback = M.autopairs_c_h, expr = true, noremap = true }
        )
    end

    if M.config.map_c_w then
        api.nvim_buf_set_keymap(
            bufnr,
            'i',
            '<c-w>',
            '',
            { callback = M.autopairs_c_w, expr = true, noremap = true }
        )
    end
    api.nvim_buf_set_var(bufnr, 'nvim-autopairs', 1)
end

local autopairs_delete = function(bufnr, key)
    if is_disable() then
        return utils.esc(key)
    end
    bufnr = bufnr or api.nvim_get_current_buf()
    local line = utils.text_get_current_line(bufnr)
    local _, col = utils.get_cursor()
    local rules = M.get_buf_rules(bufnr)
    for _, rule in pairs(rules) do
        if rule.start_pair then
            local prev_char, next_char = utils.text_cusor_line(
                line,
                col,
                #rule.start_pair,
                #rule.end_pair,
                rule.is_regex
            )
            if utils.compare(rule.start_pair, prev_char, rule.is_regex)
                and utils.compare(rule.end_pair, next_char, rule.is_regex)
                and rule:can_del({
                    ts_node = M.state.ts_node,
                    rule = rule,
                    bufnr = bufnr,
                    prev_char = prev_char,
                    next_char = next_char,
                    line = line,
                    col = col,
                })
            then
                local input = ''
                for _ = 1, api.nvim_strwidth(rule.start_pair), 1 do
                    input = input .. utils.key.bs
                end
                for _ = 1, api.nvim_strwidth(rule.end_pair), 1 do
                    input = input .. utils.key.del
                end
                return utils.esc('<c-g>U' .. input)
            end
        end
    end
    return utils.esc(key)
end

M.autopairs_c_w = function(bufnr)
    return autopairs_delete(bufnr, '<c-g>U<c-w>')
end

M.autopairs_c_h = function(bufnr)
    return autopairs_delete(bufnr, utils.key.c_h)
end

M.autopairs_bs = function(bufnr)
    return autopairs_delete(bufnr, utils.key.bs)
end

M.autopairs_map = function(bufnr, char)
    if is_disable() then
        return char
    end
    local line = utils.text_get_current_line(bufnr)
    local _, col = utils.get_cursor()
    local new_text = ''
    local add_char = 1
    local rules = M.get_buf_rules(bufnr)
    for _, rule in pairs(rules) do
        if rule.start_pair then
            if char:match('<.*>') then
                new_text = line
                add_char = 0
            else
                new_text = line:sub(1, col) .. char .. line:sub(col + 1, #line)
                add_char = rule.key_map and #rule.key_map or 1
            end

            -- log.debug("new_text:[" .. new_text .. "]")
            local prev_char, next_char = utils.text_cusor_line(
                new_text,
                col + add_char,
                #rule.start_pair,
                #rule.end_pair,
                rule.is_regex
            )
            local cond_opt = {
                ts_node = M.state.ts_node,
                text = new_text,
                rule = rule,
                bufnr = bufnr,
                col = col + 1,
                char = char,
                line = line,
                prev_char = prev_char,
                next_char = next_char,
            }
            -- log.debug("start_pair" .. rule.start_pair)
            -- log.debug('prev_char' .. prev_char)
            -- log.debug('next_char' .. next_char)
            local char_matches_rule = (rule.end_pair == char or rule.key_map == char)
            -- for simple pairs, char will match end_pair
            -- for more complex pairs, user should map the wanted end char with `use_key`
            --   on a dedicated rule
            if char_matches_rule
                and utils.compare(rule.end_pair, next_char, rule.is_regex)
                and rule:can_move(cond_opt)
            then
                local end_pair = rule:get_end_pair(cond_opt)
                local end_pair_length = rule:get_end_pair_length(end_pair)
                return utils.esc(utils.repeat_key(utils.key.join_right, end_pair_length))
            end

            if rule.key_map == char
                and utils.compare(rule.start_pair, prev_char, rule.is_regex)
                and rule:can_pair(cond_opt)
            then
                local end_pair = rule:get_end_pair(cond_opt)
                local end_pair_length = rule:get_end_pair_length(end_pair)
                local move_text = utils.repeat_key(utils.key.join_left, end_pair_length)
                if add_char == 0 then
                    move_text = ''
                    char = ''
                end
                if end_pair:match('<.*>') then
                    end_pair = utils.esc(end_pair)
                end
                local result = char .. end_pair .. utils.esc(move_text)
                if rule.is_undo then
                    result = utils.esc(utils.key.undo_sequence) .. result .. utils.esc(utils.key.undo_sequence)
                end
                if M.config.enable_abbr then
                    result = utils.esc(utils.key.abbr) .. result
                end
                log.debug("key_map :" .. result)
                return result
            end
        end
    end
    return M.autopairs_afterquote(new_text, utils.esc(char))
end

M.autopairs_insert = function(bufnr, char)
    if is_disable() then
        return char
    end
    local line = utils.text_get_current_line(bufnr)
    local _, col = utils.get_cursor()
    local new_text = line:sub(1, col) .. char .. line:sub(col + 1, #line)
    local rules = M.get_buf_rules(bufnr)
    for _, rule in pairs(rules) do
        if rule.start_pair and rule.is_regex and rule.key_map == '' then
            local prev_char, next_char = utils.text_cusor_line(
                new_text,
                col + 1,
                #rule.start_pair,
                #rule.end_pair,
                rule.is_regex
            )
            local cond_opt = {
                ts_node = M.state.ts_node,
                text = new_text,
                rule = rule,
                bufnr = bufnr,
                col = col + 1,
                char = char,
                line = line,
                prev_char = prev_char,
                next_char = next_char,
            }
            -- log.debug("start_pair" .. rule.start_pair)
            -- log.debug('prev_char' .. prev_char)
            -- log.debug('next_char' .. next_char)
            if next_char == rule.end_pair and rule:can_move(cond_opt) then
                utils.set_vchar('')
                vim.schedule(function()
                    utils.feed(utils.key.right, -1)
                end)
                return false
            end

            if utils.compare(rule.start_pair, prev_char, rule.is_regex)
                and rule:can_pair(cond_opt)
            then
                local end_pair = rule:get_end_pair(cond_opt)
                utils.set_vchar(char .. end_pair)
                vim.schedule(function()
                    utils.feed(utils.key.left, rule:get_end_pair_length(end_pair))
                end)
                return
            end
        end
    end
    return char
end

M.autopairs_cr = function(bufnr)
    if is_disable() then
        return utils.esc('<cr>')
    end
    bufnr = bufnr or api.nvim_get_current_buf()
    local line = utils.text_get_current_line(bufnr)
    local _, col = utils.get_cursor()
    -- log.debug("on_cr")
    local rules = M.get_buf_rules(bufnr)
    for _, rule in pairs(rules) do
        if rule.start_pair then
            local prev_char, next_char = utils.text_cusor_line(
                line,
                col,
                #rule.start_pair,
                #rule.end_pair,
                rule.is_regex
            )

            local cond_opt = {
                ts_node = M.state.ts_node,
                check_endwise_ts = true,
                rule = rule,
                bufnr = bufnr,
                col = col,
                line = line,
                prev_char = prev_char,
                next_char = next_char,
            }
            -- log.debug('prev_char' .. rule.start_pair)
            -- log.debug('prev_char' .. prev_char)
            -- log.debug('next_char' .. next_char)
            if rule.is_endwise
                and utils.compare(rule.start_pair, prev_char, rule.is_regex)
                and rule:can_cr(cond_opt)
            then
                local end_pair = rule:get_end_pair(cond_opt)
                return utils.esc(
                    '<CR>' .. end_pair
                    -- FIXME do i need to re indent twice #118
                    .. '<CMD>normal! ====<CR><up><end><CR>'
                )
            end

            cond_opt.check_endwise_ts = false

            if utils.compare(rule.start_pair, prev_char, rule.is_regex)
                and utils.compare(rule.end_pair, next_char, rule.is_regex)
                and rule:can_cr(cond_opt)
            then
                log.debug('do_cr')
                return utils.esc(rule:get_map_cr({ rule = rule, line = line, color = col, bufnr = bufnr }))
            end
        end
    end
    return utils.esc('<cr>')
end

--- add bracket pairs after quote (|"aaaaa" => (|"aaaaaa")
M.autopairs_afterquote = function(line, key_char)
    if M.config.enable_afterquote and not utils.is_block_wise_mode() then
        line = line or utils.text_get_current_line(0)
        local _, col = utils.get_cursor()
        local prev_char, next_char = utils.text_cusor_line(line, col + 1, 1, 1, false)
        if utils.is_bracket(prev_char)
            and utils.is_quote(next_char)
            and not utils.is_in_quotes(line, col, next_char)
        then
            local count = 0
            local index = 0
            local is_prev_slash = false
            local char_end = ''
            for i = col, #line, 1 do
                local char = line:sub(i, i + #next_char - 1)
                if not is_prev_slash and char == next_char then
                    count = count + 1
                    char_end = line:sub(i + 1, i + #next_char)
                    index = i
                end
                is_prev_slash = char == '\\'
            end
            if count == 2 and index >= (#line - 2) then
                local rules = M.get_buf_rules(api.nvim_get_current_buf())
                for _, rule in pairs(rules) do
                    if rule.start_pair == prev_char and char_end ~= rule.end_pair then
                        local new_text = line:sub(0, index)
                            .. rule.end_pair
                            .. line:sub(index + 1, #line)
                        M.state.expr_quote = new_text
                        local append = 'a'
                        if col > 0 then
                            append = 'la'
                        end
                        return utils.esc(
                            "<esc><cmd>lua require'nvim-autopairs'.autopairs_closequote_expr()<cr>" .. append
                        )
                    end
                end
            end
        end
    end
    return key_char
end

M.autopairs_closequote_expr = function()
    ---@diagnostic disable-next-line: param-type-mismatch
    vim.fn.setline('.', M.state.expr_quote)
end

M.check_break_line_char = function()
    return M.autopairs_cr()
end

M.completion_confirm =function ()
    if vim.fn.pumvisible() ~= 0 then
        return M.esc("<cr>")
    else
        return M.autopairs_cr()
    end
end

M.map_cr = function()
    api.nvim_set_keymap(
        'i',
        '<CR>',
        "v:lua.require'nvim-autopairs'.completion_confirm()",
        {  expr = true, noremap = true }
    )
end

M.esc = utils.esc
return M
