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
		api.nvim_put({text}, "c", true, true)
end

utils.feed = function(text,num)
    local result = ''
    for _ = 1, num, 1 do
        result = result .. text
    end
    api.nvim_feedkeys (api.nvim_replace_termcodes(
        result, true, false, true),
		"x", true)
end

_G.eq = assert.are.same

_G.Test_filter = function (data)
    local run_data = {}
    for _, value in pairs(data) do
        if value.only == true then
            table.insert(run_data, value)
            break
        end
    end
    if #run_data == 0 then run_data = data end
    return run_data
end



_G.Test_withfile = function(test_data, cb)
    for _, value in pairs(test_data) do
        it("test "..value.name, function()
            local text_before = {}
            local pos_before = {
                linenr = value.linenr,
                colnr = 0
            }
            if not vim.tbl_islist(value.before) then
                value.before = {value.before}
            end
            -- local numlnr = 0
            for index, text in pairs(value.before) do
                local txt = string.gsub(text, '%|' , "")
                table.insert(text_before, txt )
                if string.match( text, "%|") then
                    if string.find(text,'%|') then
                        pos_before.colnr = string.find(text, '%|')
                        pos_before.linenr = value.linenr + index-1
                    end
                end
            end
            local after = string.gsub(value.after, '%|' , "")
            local p_after = string.find(value.after , '%|')
            vim.bo.filetype = value.filetype
            if vim.fn.filereadable(vim.fn.expand(value.filepath)) == 1 then
                vim.cmd(":bd!")
                if cb.before then cb.before(value) end
                vim.cmd(":e " .. value.filepath)
                if value.filetype then
                    vim.bo.filetype = value.filetype
                    vim.cmd(":e")
                end
                vim.api.nvim_buf_set_lines(0, value.linenr -1, value.linenr +#text_before, false, text_before)
                local texdfsa = vim.fn.getline(pos_before.linenr)
                log.debug(vim.inspect(texdfsa))
                vim.fn.cursor(pos_before.linenr, pos_before.colnr)
                log.debug("insert:"..value.key)
                helpers.insert(value.key)
                vim.wait(10)
                helpers.feed("<esc>")
                if value.key == '<cr>' then
                    local result = vim.fn.getline(pos_before.linenr + 2)
                    local pos = vim.fn.getpos('.')
                    eq(pos_before.linenr + 1, pos[2], '\n\n breakline error:' .. value.name .. "\n")
                    eq(after, result , "\n\n text error: " .. value.name .. "\n")

                else
                    local result = vim.fn.getline(pos_before.linenr)
                    local pos = vim.fn.getpos('.')
                    eq(after, result , "\n\n text error: " .. value.name .. "\n")
                    eq(p_after, pos[3] + 1, "\n\n pos error: " .. value.name .. "\n")
                end
                if cb.after then cb.after(value) end
            else
                eq(false, true, "\n\n file not exist " .. value.filepath .. "\n")
            end
        end)
    end
end

_G.dump_node = function(node)
    local text=ts_utils.get_node_text(node)
    for _, txt in pairs(text) do
        print(txt)
    end
end



_G.dump_node_text = function(target)
    for node in target:iter_children() do
        local node_type = node:type()
        local text = ts_utils.get_node_text(node)
        log.debug("type:" .. node_type .. " ")
        log.debug(text)
    end
end
