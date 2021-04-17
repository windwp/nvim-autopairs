local utils = require('nvim-autopairs.utils')
local log = require('nvim-autopairs._log')
local cond={}

cond.not_regex_check = function(regex, length)
    length = length or 1
    return function(opts)
        local str = utils.text_sub_char(opts.line, opts.col, - length)
        log.debug(vim.inspect(str))
        if str:match(regex) then
            return false
        end
        return true
    end
end
cond.move_right = function ()
    return function(opts)
        log.debug("move right test")
        log.debug(opts)
        if utils.is_quote(opts.char)
            and opts.next_char == opts.char
        then
            local length = string.len(opts.line)            -- situtaion  |"  => "|
            log.debug("is quote" .. length)          -- move right when have quote on end line or in quote
            if opts.col + 1 == string.len(opts.line) then
                return true 
            end
            -- ("|")  => (""|)
            --  ""       |"      "  => ""       "|      "
            if utils.is_in_quote(opts.text, opts.col  - 1, opts.char) then
                return  true
            end
        end
        return false
    end
end
return cond
