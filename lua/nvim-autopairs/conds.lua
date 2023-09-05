local utils = require('nvim-autopairs.utils')
local log = require('nvim-autopairs._log')
---@class CondOpts
---@field ts_node table
---@field text string
---@field rule table
---@field bufnr number
---@field col   number
---@field char  string
---@field line  string
---@field prev_char string
---@field next_char string
---@field is_endwise string

local cond = {}

-- cond
-- @return false when it is not correct
--         true when it is correct
--         nil when it is not determine
-- stylua: ignore
cond.none = function()
    return function() return false end
end
-- stylua: ignore
cond.done = function()
    return function() return true end
end

cond.invert = function(func)
    return function(...)
        local result = func(...)
        if result ~= nil then
            return not result
        end
        return nil
    end
end

cond.before_regex = function(regex, length)
    length = length or 1
    if length < 0 then length = nil end
    ---@param opts CondOpts
    return function(opts)
        log.debug('before_regex')
        local str = utils.text_sub_char(opts.line, opts.col - 1, length or -opts.col)
        if str:match(regex) then
            return true
        end
        return false
    end
end

cond.before_text = function(text)
    local length = #text
    ---@param opts CondOpts
    return function(opts)
        log.debug('before_text')
        local str = utils.text_sub_char(opts.line, opts.col - 1, -length)
        if str == text then
            return true
        end
        return false
    end
end

cond.after_text = function(text)
    local length = #text
    ---@param opts CondOpts
    return function(opts)
        log.debug('after_text')
        local str = utils.text_sub_char(opts.line, opts.col, length)
        if str == text then
            return true
        end
        return false
    end
end

cond.after_regex = function(regex, length)
    length = length or 1
    if length < 0 then length = nil end
    ---@param opts CondOpts
    return function(opts)
        log.debug('after_regex')
        local str = utils.text_sub_char(opts.line, opts.col, length or #opts.line)
        if str:match(regex) then
            return true
        end
        return false
    end
end

cond.not_before_text = function(text)
    local length = #text
    return function(opts)
        log.debug('not_before_text')
        local str = utils.text_sub_char(opts.line, opts.col - 1, -length)
        if str == text then
            return false
        end
    end
end

cond.not_after_text = function(text)
    local length = #text
    ---@param opts CondOpts
    return function(opts)
        log.debug('not_after_text')
        local str = utils.text_sub_char(opts.line, opts.col, length)
        if str == text then
            return false
        end
    end
end

cond.not_before_regex = function(regex, length)
    length = length or 1
    if length < 0 then length = nil end
    ---@param opts CondOpts
    return function(opts)
        log.debug('not_before_regex')
        log.debug(length)
        local str = utils.text_sub_char(opts.line, opts.col - 1, length or -opts.col)
        if str:match(regex) then
            return false
        end
    end
end

cond.not_after_regex = function(regex, length)
    length = length or 1
    if length < 0 then length = nil end
    ---@param opts CondOpts
    return function(opts)
        log.debug('not_after_regex')
        local str = utils.text_sub_char(opts.line, opts.col, length or #opts.line)
        if str:match(regex) then
            return false
        end
    end
end

local function count_bracket_char(line, prev_char, next_char)
    local count_prev_char = 0
    local count_next_char = 0
    for i = 1, #line, 1 do
        local c = line:sub(i, i)
        if c == prev_char then
            count_prev_char = count_prev_char + 1
        elseif c == next_char then
            count_next_char = count_next_char + 1
        end
    end
    return count_prev_char, count_next_char
end

-- Checks if bracket chars are balanced around specific postion.
---@param line string
---@param open_char string
---@param close_char string
---@param col integer position
local function is_brackets_balanced_around_position(line, open_char, close_char, col)
    local balance = 0
    for i = 1, #line, 1 do
        local c = line:sub(i, i)
        if c == open_char then
            balance = balance + 1
        elseif balance > 0 and c == close_char then
            balance = balance - 1
            if col <= i and balance == 0 then
                break
            end
        end
    end
    return balance == 0
end

cond.is_bracket_line = function()
    ---@param opts CondOpts
    return function(opts)
        log.debug('is_bracket_line')
        if utils.is_bracket(opts.char) and
            (opts.next_char == opts.rule.end_pair
                or opts.next_char == opts.rule.start_pair)
        then
            -- ((  many char |)) => add
            -- (   many char |)) => not add
            local count_prev_char, count_next_char = count_bracket_char(
                opts.line,
                opts.rule.start_pair,
                opts.rule.end_pair
            )
            if count_prev_char ~= count_next_char then
                return false
            end
        end
    end
end

cond.is_bracket_line_move = function()
    ---@param opts CondOpts
    return function(opts)
        log.debug('is_bracket_line_move')
        if utils.is_close_bracket(opts.char)
            and opts.char == opts.rule.end_pair
        then
            -- ((   many char |)) => move
            -- ((   many char |) => not move
            local is_balanced = is_brackets_balanced_around_position(
                opts.line,
                opts.rule.start_pair,
                opts.char,
                opts.col
            )
            return is_balanced
        end
    end
end

cond.not_inside_quote = function()
    ---@param opts CondOpts
    return function(opts)
        log.debug('not_inside_quote')
        if utils.is_in_quotes(opts.text, opts.col - 1) then
            return false
        end
    end
end

cond.is_inside_quote = function()
    ---@param opts CondOpts
    return function(opts)
        log.debug('is_inside_quote')
        if utils.is_in_quotes(opts.text, opts.col - 1) then
            return true
        end
    end
end

cond.not_add_quote_inside_quote = function()
    ---@param opts CondOpts
    return function(opts)
        log.debug('not_add_quote_inside_quote')
        if utils.is_quote(opts.char)
            and utils.is_in_quotes(opts.text, opts.col - 1)
        then
            return false
        end
    end
end

cond.move_right = function()
    ---@param opts CondOpts
    return function(opts)
        log.debug('move_right')
        if opts.next_char == opts.char then
            if utils.is_close_bracket(opts.char) then
                return
            end
            -- move right when have quote on end line or in quote
            -- situtaion  |"  => "|
            if utils.is_quote(opts.char) then
                if opts.col == string.len(opts.line) then
                    return
                end
                -- ("|")  => (""|)
                --  ""       |"      "  => ""       "|      "
                if utils.is_in_quotes(opts.line, opts.col - 1, opts.char) then
                    return
                end
            end
        end
        return false
    end
end

cond.is_end_line = function()
    ---@param opts CondOpts
    return function(opts)
        log.debug('is_end_line')
        local end_text = opts.line:sub(opts.col + 1)
        -- end text is blank
        if end_text ~= '' and end_text:match('^%s+$') == nil then
            return false
        end
    end
end

--- Check the next char is quote and cursor is inside quote
cond.is_bracket_in_quote = function()
    ---@param opts CondOpts
    return function(opts)
        log.debug("is_bracket_in_quote")
        if utils.is_bracket(opts.char)
            and utils.is_quote(opts.next_char)
            and utils.is_in_quotes(opts.line, opts.col - 1, opts.next_char)
        then
            return true
        end
    end
end

cond.not_filetypes = function(filetypes)
    return function()
        log.debug('not_filetypes')
        for _, filetype in pairs(filetypes) do
            if vim.bo.filetype == filetype then
                return false
            end
        end
    end
end

--- Check the character before the cursor is not equal
---@param char string character to compare
---@param index number the position of character before current curosr
cond.not_before_char = function(char, index)
    index = index or 1
    ---@param opts CondOpts
    return function(opts)
        log.debug('not_before_char')
        local match_char = #opts.line > index
            and opts.line:sub(#opts.line - index, #opts.line - index) or ''
        if match_char == char and match_char ~= "" then
            return false
        end
    end
end

---@deprecated
cond.not_after_regex_check = cond.not_after_regex
---@deprecated
cond.after_regex_check = cond.after_regex
---@deprecated
cond.before_regex_check = cond.before_regex
---@deprecated
cond.not_before_regex_check = cond.not_before_regex
---@deprecated
cond.after_text_check = cond.after_text
---@deprecated
cond.not_after_text_check = cond.not_after_text
---@deprecated
cond.before_text_check = cond.before_text
---@deprecated
cond.not_before_text_check = cond.not_before_text

return cond
