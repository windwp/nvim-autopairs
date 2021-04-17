local utils = require('nvim-autopairs.utils')
local log = require('nvim-autopairs._log')
local api = vim.api

utils.insert_char = function(text)
		api.nvim_put({text}, "c", true, true)
end

utils.feed = function(text,num)
    if num > 0 then
        num = num + 1
    else
        num = 1
    end

    local result = ''
    for _ = 1, num, 1 do
        result = result .. text
    end
    log.debug("result" .. result)
    api.nvim_feedkeys (api.nvim_replace_termcodes(
        result, true, false, true),
		"x", true)
end

_G.eq = assert.are.same
