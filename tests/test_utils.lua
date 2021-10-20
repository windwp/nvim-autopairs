local utils = require('nvim-autopairs.utils')
local _, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
local log = require('nvim-autopairs._log')
local api = vim.api

local helpers = {}
function helpers.feed(text, feed_opts)
    feed_opts = feed_opts or 'n'
    local to_feed = vim.api.nvim_replace_termcodes(text, true, false, true)
    vim.api.nvim_feedkeys(to_feed, feed_opts, true)
end

function helpers.insert(text)
    helpers.feed('i' .. text, 'x')
end
utils.insert_char = function(text)
    api.nvim_put({ text }, 'c', true, true)
end

utils.feed = function(text, num)
    local result = ''
    for _ = 1, num, 1 do
        result = result .. text
    end
    api.nvim_feedkeys(
        api.nvim_replace_termcodes(result, true, false, true),
        'x',
        true
    )
end

_G.eq = assert.are.same

_G.Test_filter = function(data)
    local run_data = {}
    for _, value in pairs(data) do
        if value.only == true then
            table.insert(run_data, value)
            break
        end
    end
    if #run_data == 0 then
        run_data = data
    end
    return run_data
end

local compare_text = function(linenr, text_after, name, cursor_add)
    cursor_add = cursor_add or 0
    print(cursor_add)
    local new_text = vim.api.nvim_buf_get_lines(
        0,
        linenr - 1,
        linenr + #text_after,
        true
    )
    if #new_text ~= #text_after + 1 then
        eq(#new_text, #text_after, '\n\n text error: ' .. name .. '\n')
        return false
    end
    for i = 1, #text_after, 1 do
        local t = string.gsub(text_after[i], '%|', '')
        if t:gsub('%s+$', '') ~= new_text[i]:gsub('%s+$', '') then
            eq(t, new_text[i], '\n\n text error: ' .. name .. '\n')
        end
        local p_after = string.find(text_after[i], '%|')
        if p_after then
            -- log.debug(p_after)
            local row, col = utils.get_cursor()
            eq(row, linenr + i - 2, '\n\n cursor row error: ' .. name .. '\n')
            p_after = p_after + cursor_add
            eq(col, p_after -2, '\n\n cursor column error : ' .. name .. '\n')
        end
    end
    return true
end

_G.Test_withfile = function(test_data, cb)
    for _, value in pairs(test_data) do
        it('test ' .. value.name, function()
            local text_before = {}
            local pos_before = {
                linenr = value.linenr,
                colnr = 0,
            }
            if not vim.tbl_islist(value.before) then
                value.before = { value.before }
            end
            for index, text in pairs(value.before) do
                local txt = string.gsub(text, '%|', '')
                table.insert(text_before, txt)
                if string.match(text, '%|') then
                    if string.find(text, '%|') then
                        pos_before.colnr = string.find(text, '%|')
                        pos_before.linenr = value.linenr + index - 1
                    end
                end
            end
            if not vim.tbl_islist(value.after) then
                value.after = { value.after }
            end
            vim.bo.filetype = value.filetype
            if vim.fn.filereadable(vim.fn.expand(value.filepath)) == 1 then
                vim.cmd(':bd!')
                if cb.before then
                    cb.before(value)
                end
                vim.cmd(':e ' .. value.filepath)
                if value.filetype then
                    vim.bo.filetype = value.filetype
                    vim.cmd(':e')
                end
                vim.api.nvim_buf_set_lines(
                    0,
                    value.linenr - 1,
                    value.linenr + #text_before,
                    true,
                    text_before
                )
                ---@diagnostic disable-next-line: redundant-parameter
                vim.fn.cursor(pos_before.linenr, pos_before.colnr)
                log.debug('insert:' .. value.key)

                helpers.insert(value.key)
                vim.wait(10)
                helpers.feed('<esc>')
                if value.key == '<cr>' then
                    local row, col = utils.get_cursor()
                    compare_text(
                        value.linenr,
                        value.after,
                        value.name,
                        cb.cursor_add
                    )
                else
                    compare_text(
                        value.linenr,
                        value.after,
                        value.name,
                        cb.cursor_add
                    )
                end
                if cb.after then
                    cb.after(value)
                end
            else
                eq(false, true, '\n\n file not exist ' .. value.filepath .. '\n')
            end
        end)
    end
end

_G.dump_node = function(node)
    local text = ts_utils.get_node_text(node)
    for _, txt in pairs(text) do
        print(txt)
    end
end

_G.dump_node_text = function(target)
    for node in target:iter_children() do
        local node_type = node:type()
        local text = ts_utils.get_node_text(node)
        log.debug('type:' .. node_type .. ' ')
        log.debug(text)
    end
end
