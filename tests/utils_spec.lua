local utils = require('nvim-autopairs.utils')
local log = require('nvim-autopairs._log')

local eq = assert.are.same

local data = {
    {
        text   = "add normal bracket",
        start  = 2,
        num    = 2,
        result = 'dd'
    },


    {
        text   = "iood",
        start  = 1,
        num    = 2,
        result = 'io'
    },
    {
        text   = "add normal bracket",
        start  = 0,
        num    = -2,
        result = ''
    },

    {
        text   = "add normal bracket",
        start  = 3,
        num    = -2,
        result = 'dd'
    },
    {
        text   = [["""]],
        start  = 3,
        num    = -3,
        result = '"""'
    },

    {
        text   = [["""]],
        start  = 3,
        num    = 3,
        result = '"'
    },

    {
        text   = [["""]],
        start  = 2,
        num    = 2,
        result = '""'
    },
}

describe('utils test substring ', function()
    for _, value in pairs(data) do
        it('test sub: ' .. value.text, function()
            local result = utils.text_sub_char(value.text, value.start, value.num)
            eq(value.result, result, 'start  ' .. value.start .. ' num' .. value.num)
        end)
    end
end)

vim.wait(100)
