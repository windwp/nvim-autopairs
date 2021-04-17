local utils = require('nvim-autopairs.utils')
local log = require('nvim-autopairs._log')
local cond={}

cond.none = function()
    return function() return false end
end

cond.not_before_regex_check = function(regex, length)
    length = length or 1
    return function(opts)
        local str = utils.text_sub_char(opts.line, opts.col, - length)
        if str:match(regex) then
            return false
        end
        return true
    end
end

cond.not_after_regex_check = function(regex, length)
    length = length or 1
    return function(opts)
        local str = utils.text_sub_char(opts.line, opts.col + 1, length)
        if str:match(regex) then
            return false
        end
        return true
    end
end


cond.not_add_quote_inside_quote=function()
    return function(opts)
        if
            utils.is_quote(opts.char)
            and utils.is_in_quote(opts.text, opts.col, opts.char)
        then
            return false
        end
        return true
    end
end

cond.move_right = function ()
    return function(opts)
        if
            utils.is_quote(opts.char)
            and opts.next_char == opts.char
        then
            if opts.col + 1 == string.len(opts.line) then
                log.debug("move right correct")
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
