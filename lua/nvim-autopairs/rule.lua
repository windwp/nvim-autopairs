local Cond = require('nvim-autopairs.conds')

--- @class Rule
--- @field start_pair string
--- @field end_pair string
--- @field end_pair_func function    dynamic change end_pair
--- @field map_cr_func function      dynamic change mapping_cr
--- @field end_pair_length number    change end_pair length for key map like <left>
--- @field key_map string|nil        equal nil mean it will skip on autopairs map
--- @field filetypes table|nil
--- @field not_filetypes table|nil
--- @field is_regex boolean          use regex to compare
--- @field is_multibyte boolean
--- @field is_endwise boolean        only use on end_wise
--- @field is_undo boolean           add break undo sequence

local Rule = setmetatable({}, {
    __call = function(self, ...)
        return self.new(...)
    end,
})

---@return Rule
function Rule.new(...)
    local params = { ... }
    local opt = {}
    if type(params[1]) == 'table' then
        opt = params[1]
    else
        opt.start_pair = params[1]
        opt.end_pair = params[2]
        if type(params[3]) == 'string' then
            opt.filetypes = { params[3] }
        else
            opt.filetypes = params[3]
        end
    end
    opt = vim.tbl_extend('force', {
        key_map         = "",
        start_pair      = nil,
        end_pair        = nil,
        end_pair_func   = false,
        filetypes       = nil,
        not_filetypes   = nil,
        move_cond       = nil,
        del_cond        = {},
        cr_cond         = {},
        pair_cond       = {},
        is_endwise      = false,
        is_regex        = false,
        is_multibyte    = false,
        end_pair_length = nil,
    }, opt) or {}

    ---@param rule Rule
    local function constructor(rule)
        -- check multibyte
        if #rule.start_pair ~= vim.api.nvim_strwidth(rule.start_pair) then
            rule:use_multibyte()
        end
        -- check filetypes and not_filetypes
        -- if have something like "-vim" it will add to not_filetypes
        if rule.filetypes then
            local ft, not_ft = {}, {}
            for _, value in pairs(rule.filetypes) do
                if value:sub(1, 1) == '-' then
                    table.insert(not_ft, value:sub(2, #value))
                else
                    table.insert(ft, value)
                end
            end
            rule.filetypes = #ft > 0 and ft or nil
            rule.not_filetypes = #not_ft > 0 and not_ft or nil
        end
        return rule
    end

    local r = setmetatable(opt, { __index = Rule })
    return constructor(r)
end

function Rule:use_regex(value, key_map)
    self.is_regex = value
    self.key_map = key_map or ''
    return self
end

function Rule:use_key(key_map)
    self.key_map = key_map or ''
    return self
end

function Rule:use_undo(value)
    self.is_undo = value
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

function Rule:get_map_cr(opts)
    if self.map_cr_func then
        return self.map_cr_func(opts)
    end
    return '<c-g>u<CR><CMD>normal! ====<CR><up><end><CR>'
end
function Rule:replace_map_cr(value)
    self.map_cr_func = value
    return self
end

function Rule:get_end_pair_length(opts)
    if self.end_pair_length then
        return self.end_pair_length
    end
    if type(opts) == 'string' then
        return #opts
    end
    return #self.get_end_pair(opts)
end

function Rule:replace_endpair(value, check_pair)
    self.end_pair_func = value
    if check_pair ~= nil then
        if check_pair == true then
            self:with_pair(Cond.after_text(self.end_pair))
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
    if self.move_cond == nil then self.move_cond = {} end
    table.insert(self.move_cond, cond)
    return self
end

function Rule:with_del(cond)
    if self.del_cond == nil then self.del_cond = {} end
    table.insert(self.del_cond, cond)
    return self
end

function Rule:with_cr(cond)
    if self.cr_cond == nil then self.cr_cond = {} end
    table.insert(self.cr_cond, cond)
    return self
end

---add condition to rule
---@param cond any
---@param pos number|nil = 1. It have higher priority to another condition
---@return Rule
function Rule:with_pair(cond, pos)
    if self.pair_cond == nil then self.pair_cond = {} end
    self.pair_cond[pos or (#self.pair_cond + 1)] = cond
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

return Rule
