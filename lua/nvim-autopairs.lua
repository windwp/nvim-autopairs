local log = require('nvim-autopairs._log')
local utils = require('nvim-autopairs.utils')
local basic_rule = require('nvim-autopairs.rules.basic')
local api = vim.api

local M={}

local state = {}
local default = {
    disable_filetype = {"TelescopePrompt", "spectre_panel"},
    rules = basic_rule
}
M.setup = function(opt)
    M.config = vim.tbl_extend('force', default, opt or {})
    api.nvim_exec ([[
    augroup autopairs_buf
    autocmd!
    autocmd BufEnter * :lua require("nvim-autopairs").on_attach()
    augroup end
        ]],false)

end

M.on_attach = function(bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()
    if utils.is_attached(bufnr) then return end
    if not utils.check_disable_ft(M.config.disable_filetype, vim.bo.filetype) then return end

    state.rules = M.config.rules
    api.nvim_exec(string.format([[
    augroup autopairs_insert_%d
    autocmd!
    autocmd InsertCharPre <buffer=%d> call luaeval("require('nvim-autopairs').autopairs_insert(%d, _A)", v:char)
        augroup end ]],
        bufnr, bufnr, bufnr), false)

    api.nvim_buf_set_var(bufnr, "nvim-autopairs", 1)
end

M.autopairs_bs = function()
end


local skip_next = false
M.autopairs_insert = function(bufnr, char)
    if skip_next then skip_next = false return end
    local line = utils.text_get_current_line(bufnr)
    log.debug("-----------------")
    log.debug("line:" .. line)
    log.debug("char:" .. char)
    local _, col = utils.get_cursor()
    log.debug(vim.inspect(col))
    local filetype = vim.bo.filetype
    local new_text = line:sub(1, col) .. char .. line:sub(col + 1,#line)
    log.debug("new_text:[" .. new_text .. "]")
    for _, rule in pairs(state.rules) do
        if rule.start_pair and utils.check_filetype(rule.filetypes, filetype) then
            local prev_char = utils.text_sub_char(new_text, col + 1,-#rule.start_pair)
            local next_char = utils.text_sub_char(new_text, col + 2,#rule.start_pair)
            if rule.start_pair == '(' then
                log.debug("start_pair" .. rule.start_pair)
                log.debug('prev_char' .. prev_char)
                log.debug('next_char' .. next_char)
            end
            if prev_char == rule.start_pair then
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

                if rule:can_move(cond_opt) then
                    vim.schedule(function()
                        utils.feed(utils.key.del, 1)
                    end)
                    return
                end
                if rule:can_pair(cond_opt) then
                    log.debug('match')
                    vim.schedule(function()
                        utils.insert_char(rule.end_pair)
                        utils.feed(utils.key.left, #rule.end_pair)
                    end)
                    return
                end
            end
        end
    end
end

M.autopairs_cr=function()
end
M.esc = utils.esc
_G.MPairs = M
return M
