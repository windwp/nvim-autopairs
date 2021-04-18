local utils = require('nvim-autopairs.utils')
local log = require('nvim-autopairs._log')
local cond={}

-- cond
-- @return false when it is not correct
--         true when it is correct
--         nil when it is not determine


cond.none = function()
    return function() return false end
end


cond.done = function()
    return function() return true end
end

cond.not_before_regex_check = function(regex, length)
    length = length or 1
    return function(opts)
        log.debug('not_before_regex_check')
        local str = utils.text_sub_char(opts.line, opts.col, - length)
        if str:match(regex) then
            return false
        end
    end
end

cond.not_after_regex_check = function(regex, length)
    length = length or 1
    return function(opts)
        log.debug('not_after_regex_check')
        local str = utils.text_sub_char(opts.line, opts.col + 1, length)
        if str:match(regex) then
            return false
        end
    end
end

cond.check_is_bracket_line=function ()
    return function(opts)
        log.debug('check_is_bracket_line')
        if
           utils.is_bracket(opts.char)
           and opts.next_char == opts.rule.end_pair
        then
            -- ((  many char |)) => add
            -- (   many char |)) => not add
            local count_prev_char = 0
            local count_next_char = 0
            for i = 1, #opts.line, 1 do
                local c = opts.line:sub(i, i)
                if c == opts.char then
                    count_prev_char = count_prev_char + 1
                elseif c == opts.rule.end_pair then
                    count_next_char = count_next_char + 1
                end
            end
            if count_prev_char ~= count_next_char then
                return false
            end
        end
    end
end

cond.not_add_quote_inside_quote = function()
    return function(opts)
        log.debug('not_add_quote_inside_quote')
        if
            utils.is_quote(opts.char)
            and utils.is_in_quote(opts.text, opts.col, opts.char)
        then
            return false
        end
    end
end

cond.move_right = function ()
    return function(opts)
        log.debug("move_right")
        if utils.is_close_bracket(opts.char) then
            return true
        end
        -- move right when have quote on end line or in quote
        -- situtaion  |"  => "|
        if
            utils.is_quote(opts.char)
            and opts.next_char == opts.char
        then
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
