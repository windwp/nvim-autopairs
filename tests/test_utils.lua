local utils = require('nvim-autopairs.utils')
local log = require('nvim-autopairs._log')
local api = vim.api
local ts_get_node_text = vim.treesitter.get_node_text or vim.treesitter.query.get_node_text

local helpers = {}

function helpers.feed(text, feed_opts, is_replace)
    feed_opts = feed_opts or 'n'
    if not is_replace then
        text = vim.api.nvim_replace_termcodes(text, true, false, true)
    end
    vim.api.nvim_feedkeys(text, feed_opts, true)
end

function helpers.insert(text, is_replace)
    helpers.feed('i' .. text, 'x', is_replace)
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
    ---@diagnostic disable-next-line: param-type-mismatch
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

local compare_text = function(linenr, text_after, name, cursor_add, end_cursor)
    cursor_add = cursor_add or 0
    local new_text = vim.api.nvim_buf_get_lines(
        0,
        linenr - 1,
        linenr + #text_after - 1,
        true
    )
    for i = 1, #text_after, 1 do
        local t = string.gsub(text_after[i], '%|', '')
        if t
            and new_text[i]
            and t:gsub('%s+$', '') ~= new_text[i]:gsub('%s+$', '')
        then
            eq(t, new_text[i], '\n\n text error: ' .. name .. '\n')
        end
        local p_after = string.find(text_after[i], '%|')
        if p_after then
            local row, col = utils.get_cursor()
            if end_cursor then
                eq(row, linenr + i - 2, '\n\n cursor row error: ' .. name .. '\n')
                eq(
                    col + 1,
                    end_cursor,
                    '\n\n end cursor column error : ' .. name .. '\n'
                )
            else
                eq(row, linenr + i - 2, '\n\n cursor row error: ' .. name .. '\n')
                p_after = p_after + cursor_add
                eq(
                    col,
                    math.max(p_after - 2, 0),
                    '\n\n cursor column error : ' .. name .. '\n'
                )
            end
        end
    end
    return true
end

_G.Test_withfile = function(test_data, cb)
    for _, value in pairs(test_data) do
        it('test ' .. value.name, function(_)
            local text_before = {}
            value.linenr = value.linenr or 1
            local pos_before = {
                linenr = value.linenr,
                colnr = 0,
            }
            if not vim.tbl_islist(value.before) then
                value.before = { value.before }
            end
            for index, text in pairs(value.before) do
                local txt = string.gsub(tostring(text), '%|', '')
                table.insert(text_before, txt)
                if string.match(tostring(text), '%|') then
                    if string.find(tostring(text), '%|') then
                        pos_before.colnr = string.find(tostring(text), '%|')
                        pos_before.linenr = value.linenr + index - 1
                    end
                end
            end
            if not vim.tbl_islist(value.after) then
                value.after = { value.after }
            end
            vim.bo.filetype = value.filetype or 'text'
            vim.cmd(':bd!')
            if cb.before_each then
                cb.before_each(value)
            end
            ---@diagnostic disable-next-line: missing-parameter
            if vim.fn.filereadable(vim.fn.expand(value.filepath)) == 1 then
                vim.cmd(':e ' .. value.filepath)
                if value.filetype then
                    vim.bo.filetype = value.filetype
                end
                vim.cmd(':e')
            else
                vim.cmd(':new')
                if value.filetype then
                    vim.bo.filetype = value.filetype
                end
            end
            local status, parser = pcall(vim.treesitter.get_parser, 0)
            if status then
                parser:parse(true)
            end
            vim.api.nvim_buf_set_lines(
                0,
                value.linenr - 1,
                value.linenr + #text_before,
                false,
                text_before
            )
            vim.api.nvim_win_set_cursor(
                0,
                { pos_before.linenr, pos_before.colnr - 1 }
            )
            if type(value.key) == "function" then
                log.debug("call key")
                value.key()
            else
                log.debug('insert:' .. value.key)
                helpers.insert(value.key, value.not_replace_term_code)
                vim.wait(2)
                helpers.feed('<esc>')
            end
            compare_text(
                value.linenr,
                value.after,
                value.name,
                cb.cursor_add,
                value.end_cursor
            )
            if cb.after_each then
                cb.after_each(value)
            end
            vim.cmd(':bd!')
        end)
    end
end

_G.dump_node = function(node)
    local text = ts_get_node_text(node)
    for _, txt in pairs(text) do
        print(txt)
    end
end

_G.dump_node_text = function(target)
    for node in target:iter_children() do
        local node_type = node:type()
        local text = ts_get_node_text(node)
        log.debug('type:' .. node_type .. ' ')
        log.debug(text)
    end
end
