local Rule = {}
local log = require('nvim-autopairs._log')

local Cond = require('nvim-autopairs.conds')

function Rule.new(...)
    local params = {...}
    local opt = {}
    if type(params[1]) == 'table' then
        opt = params[1]
    else
        opt.start_pair = params[1]
        opt.end_pair = params[2]
        if type(params[3]) == "string" then
            opt.filetypes = {params[3]}
        else
            opt.filetypes = params[3]
        end
    end
    opt = vim.tbl_extend('force', {
        -- set to nil mean it will skip on autopairs_map
        key_map       = "",
        start_pair    = nil,
        end_pair      = nil,
        -- function to dynamic update end pair
        end_pair_func = false,
        filetypes     = nil,
        move_cond     = nil,
        del_cond      = {},
        cr_cond       = {},
        pair_cond     = {},
        -- only use on end_wise
        is_endwise    = false,
        -- use regex to compare
        is_regex      = false,
        is_multibyte = false,
        -- some end_pair have key map like <left>.. then the length of string is
        -- not correct
        end_pair_length = nil,
    },opt)

    local function verify(rule)
        -- check multibyte
        if #rule.start_pair ~= vim.api.nvim_strwidth(rule.start_pair) then
            rule:use_multibyte()
        end
        return rule
    end
    local r = setmetatable(opt, {__index = Rule})
    return verify(r)
end

function Rule:use_regex(value,key_map)
    self.is_regex = value
    self.key_map = key_map or ""
    return self
end

function Rule:use_key(key_map)
    self.key_map = key_map or ""
    return self
end

function Rule:use_multibyte()
    self.is_multibyte = true
    self.end_pair_length = vim.fn.strdisplaywidth(self.end_pair)
    self.key_map = string.match(self.start_pair, "[^\128-\191][\128-\191]*$")
    self.key_end = string.match(self.end_pair, "[%z\1-\127\194-\244][\128-\191]*")
    return self
end

function Rule:get_end_pair(opts)
    if self.end_pair_func then
        return self.end_pair_func(opts)
    end
    return self.end_pair
end

function Rule:get_end_pair_length(opts)
    if self.end_pair_length then
        return self.end_pair_length
    end
    if type(opts) == 'string' then
        return #opts
    end
    return self.get_end_pair(opts):length()
end

function Rule:replace_endpair(value,check_pair)
    self.end_pair_func = value
    if check_pair ~= nil then
        if check_pair == true then
            self:with_pair(Cond.after_text_check(self.end_pair))
        else
            self:with_pair(check_pair)
        end
    end
    return self
end

function Rule:set_end_pair_length(length)
    self.end_pair_length = length
    return self
end

function Rule:with_move(cond)
    if self.move_cond == nil then self.move_cond = {}end
    table.insert(self.move_cond, cond)
    return self
end

function Rule:with_del(cond)
    if self.del_cond == nil then self.del_cond = {}end
    table.insert(self.del_cond, cond)
    return self
end


function Rule:with_cr(cond)
    if self.cr_cond == nil then self.cr_cond = {}end
    table.insert(self.cr_cond, cond)
    return self
end

function Rule:with_pair(cond)
    if self.pair_cond == nil then self.pair_cond = {}end
    table.insert(self.pair_cond, cond)
    return self
end

function Rule:only_cr(cond)
    self.key_map = nil
    self.pair_cond = false
    self.move_cond = false
    self.del_cond = false
    if cond then return self:with_cr(cond) end
    return self
end

function Rule:end_wise(cond)
    self.is_endwise = true
    return self:only_cr(cond)
end

local function can_do(conds, opt)
    if type(conds) == 'table' then
        for _, cond in pairs(conds) do
            local result = cond(opt)
            if result ~= nil then
                return result
            end
        end
        return true
    elseif type(conds) == 'function' then
        return conds(opt) == true
    end
    return false
end

function Rule:can_pair(opt)
    return can_do(self.pair_cond, opt)

end

function Rule:can_move(opt)
    return can_do(self.move_cond, opt)
end

function Rule:can_del(opt)
    return can_do(self.del_cond, opt)
end


function Rule:can_cr(opt)
    return can_do(self.cr_cond, opt)
end


return Rule.new
