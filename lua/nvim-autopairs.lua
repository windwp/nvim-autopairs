local log = require('nvim-autopairs._log')
local utils = require('nvim-autopairs.utils')
local basic_rule = require('nvim-autopairs.rules.basic')
local api = vim.api

local M={}

local state = {}

local default = {
    disable_filetype = {"TelescopePrompt", "spectre_panel"},
    ignored_next_char = string.gsub([[ [%w%%%'%[%"%.] ]],"%s+", "")
}

M.setup = function(opt)
    M.config = vim.tbl_extend('force', default, opt or {})
    M.config.rules = basic_rule.setup(M.config)
    api.nvim_exec ([[
    augroup autopairs_buf
    autocmd!
    autocmd BufEnter * :lua require("nvim-autopairs").on_attach()
    augroup end
        ]],false)
end

M.add_rule = function (rule)
    table.insert(M.config.rules, rule)
end

M.add_rules = function (rules)
    for _, rule in pairs(rules) do
        table.insert(M.config.rules, rule)
    end
end

M.clear_rules = function()
    M.config.rules = {}
end

M.disable=function()
    state.disabled = true
end

M.enable = function()
    state.disabled = false
end

M.on_attach = function(bufnr)
    if state.disabled then return end
    bufnr = bufnr or api.nvim_get_current_buf()
    if not utils.check_disable_ft(M.config.disable_filetype, vim.bo.filetype) then return end
    local rules = {};
    for _, rule in pairs(M.config.rules) do
        if utils.check_filetype(rule.filetypes,vim.bo.filetype) then
            table.insert(rules, rule)
        end
    end
    -- sort by length
    table.sort(rules, function (a, b)
        return (#a.start_pair or 0) > (#b.start_pair or 0)
    end)

    state.rules = rules
    if utils.is_attached(bufnr) then return end

    api.nvim_exec(string.format([[
    augroup autopairs_insert_%d
    autocmd!
    autocmd InsertCharPre <buffer=%d> call luaeval("require('nvim-autopairs').autopairs_insert(%d, _A)", v:char)
        augroup end ]],
        bufnr, bufnr, bufnr), false)
    api.nvim_buf_set_keymap(bufnr,
        'i',
        "<bs>",
        string.format("v:lua.MPairs.autopairs_bs(%d)", bufnr), {expr = true, noremap = true})

    api.nvim_buf_set_var(bufnr, "nvim-autopairs", 1)
end

M.autopairs_bs = function(bufnr)
    if state.disabled then return end
    local line = utils.text_get_current_line(bufnr)
    local _, col = utils.get_cursor()
    for _, rule in pairs(state.rules) do
        if rule.start_pair then
            local prev_char, next_char = utils.text_cusor_line(
                line,
                col,
                #rule.start_pair,
                #rule.end_pair,
                rule.is_regex
            )
            if
                utils.is_equal(rule.start_pair, prev_char, rule.is_regex)
                and rule.end_pair == next_char
                and rule:can_del({
                    bufnr = bufnr,
                    prev_char = prev_char,
                    next_char = next_char,
                    line = line
                })
            then
                local input = ""
                for _ = 1, (#rule.start_pair), 1 do
                    input = input .. utils.key.bs
                end
                for _ = 1, #rule.end_pair, 1 do
                    input = input .. utils.key.right .. utils.key.bs
                end
                return utils.esc("<c-g>U" .. input)
            end
        end
    end
    return utils.esc(utils.key.bs)
end


local skip_next = false

M.autopairs_insert = function(bufnr, char)
    if state.disabled then return end
    if skip_next then skip_next = false return end
    local line = utils.text_get_current_line(bufnr)
    local _, col = utils.get_cursor()
    local new_text = line:sub(1, col) .. char .. line:sub(col + 1,#line)
    -- log.debug("new_text:[" .. new_text .. "]")
    for _, rule in pairs(state.rules) do
        if rule.start_pair then
            local prev_char, next_char = utils.text_cusor_line(
                new_text,
                col + 1,
                #rule.start_pair,
                #rule.end_pair, rule.is_regex
            )
            local cond_opt = {
                text = new_text,
                rule = rule,
                bufnr = bufnr,
                col = col,
                char = char,
                line = line,
                prev_char = prev_char,
                next_char = next_char,
            }
            -- log.debug("start_pair" .. rule.start_pair)
            -- log.debug('prev_char' .. prev_char)
            -- log.debug('next_char' .. next_char)
            if
                next_char == rule.end_pair
                and rule:can_move(cond_opt)
            then
                utils.set_vchar("")
                vim.schedule(function()
                    utils.feed(utils.key.right, -1)
                end)
                return false
            end

            if
                utils.is_equal(rule.start_pair, prev_char, rule.is_regex)
                and rule:can_pair(cond_opt)
            then
                -- utils.set_vchar(char .. rule.end_pair)
                utils.set_vchar("")
                vim.schedule(function()
                    local end_pair = rule:get_end_pair(cond_opt)
                    utils.insert_char(char .. end_pair)
                    utils.feed(utils.key.left, #end_pair)
                end)
                return
            end
        end
    end
end

M.autopairs_cr = function(bufnr)
    if state.disabled then return end
    bufnr = bufnr or api.nvim_get_current_buf()
    local line = utils.text_get_current_line(bufnr)
    local _, col = utils.get_cursor()
    for _, rule in pairs(state.rules) do
        if rule.start_pair then
            local prev_char, next_char = utils.text_cusor_line(
                line,
                col,
                #rule.start_pair,
                #rule.end_pair, rule.is_regex
            )
            if
                rule.is_endwise
                and utils.is_equal(rule.start_pair, prev_char, rule.is_regex)
                and rule:can_cr({
                    check_ts = true,
                    bufnr = bufnr,
                    rule = rule,
                    prev_char = prev_char,
                    next_char = next_char,
                    line = line
                })
            then
                log.debug('do endwise')
                return utils.esc(
                        rule.end_pair
                        ..  utils.repeat_key(utils.key.left, 3)
                        .."<cr><esc><<O"
                    )
            end
            if
                rule.start_pair == prev_char
                and rule.end_pair == next_char
                and rule:can_cr({
                    check_ts = false,
                    bufnr = bufnr,
                    rule = rule,
                    prev_char = prev_char,
                    next_char = next_char,
                    line = line
                })
            then
                log.debug('do _cr')
                return utils.esc("<cr><c-o>O")
            end
        end
    end
    return utils.esc("<cr>")
end

M.check_break_line_char = function()
    return M.autopairs_cr()
end

M.esc = utils.esc
_G.MPairs = M
return M
