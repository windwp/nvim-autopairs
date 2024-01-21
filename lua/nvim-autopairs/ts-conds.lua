local _, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')

local log = require('nvim-autopairs._log')
local parsers = require'nvim-treesitter.parsers'
local utils = require('nvim-autopairs.utils')
local ts_get_node_text = vim.treesitter.get_node_text or vim.treesitter.query.get_node_text

local conds = {}

conds.is_endwise_node = function(nodes)
    if nodes == nil then return function() return true end end
    if type(nodes) == 'string' then nodes = {nodes} end

    return function (opts)
        log.debug('is_endwise_node')
        if not opts.check_endwise_ts then return true end
        if nodes == nil then return true end
        if #nodes == 0 then return true end

        parsers.get_parser():parse()
        local target = ts_utils.get_node_at_cursor()
        if target ~= nil and utils.is_in_table(nodes, target:type()) then
            local text = ts_get_node_text(target) or {""}
            local last = text[#text]:match(opts.rule.end_pair)
            -- check last character is match with end_pair
            if last == nil then
                return true
            end
                -- log.debug('last:' .. last)
                -- if match then we need tocheck parent node
                --  some time treesiter is group 2 node  then we need check that
                local begin_target,_, end_target = target:range()
                local begin_parent,_, end_parent = target:parent():range()
                -- log.debug(target:range())
                -- log.debug(ts_get_node_text(target))
                -- log.debug(target:parent():range())
                -- log.debug(ts_get_node_text(target:parent()))
                if
                    (
                        begin_target ~= begin_parent
                        and end_target == end_parent
                    )
                    or
                    (end_parent - end_target == 1)
                then
                    return true
                end
                -- return true
            else
        end
        return false
    end
end

conds.is_in_range = function(callback, position)
    assert(
        type(callback) == 'function' and type(position) == 'function',
        'callback and position should be a function'
    )
    return function(opts)
        log.debug('is_in_range')
        if not parsers.has_parser() then
            return
        end
        local cursor = position()
        assert(
            type(cursor) == 'table' and #cursor == 2,
            'position should be return a table like {line, col}'
        )
        local line = cursor[1]
        local col = cursor[2]

        local bufnr = 0
        local root_lang_tree = parsers.get_parser(bufnr)
        local lang_tree = root_lang_tree:language_for_range({ line, col, line, col })

        local result

        for _, tree in ipairs(lang_tree:trees()) do
            local root = tree:root()
            if root and vim.treesitter.is_in_node_range(root, line, col) then
                local node = root:named_descendant_for_range(line, col, line, col)
                local anonymous_node = root:descendant_for_range(
                    line,
                    col,
                    line,
                    col
                )

                result = {
                    node = node,
                    lang = lang_tree:lang(),
                    type = node:type(),
                    cursor = vim.api.nvim_win_get_cursor(0),
                    line = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, true)[1],
                    range = { node:range() },
                    anonymous = anonymous_node:type(),
                }
            end
        end

        return callback(result)
    end
end

conds.is_ts_node = function(nodes)
    if type(nodes) == 'string' then nodes = {nodes} end
    assert(nodes ~= nil, "ts nodes should be string or table")
    return function (opts)
        log.debug('is_ts_node')
        if #nodes == 0 then return  end

        parsers.get_parser():parse()
        local target = ts_utils.get_node_at_cursor()
        if target ~= nil and utils.is_in_table(nodes, target:type()) then
            return true
        end
        return false
    end
end

conds.is_not_ts_node = function(nodes)
    if type(nodes) == 'string' then nodes = {nodes} end
    assert(nodes ~= nil, "ts nodes should be string or table")
    return function (opts)
        log.debug('is_not_ts_node')
        if #nodes == 0 then return  end

        parsers.get_parser():parse()
        local target = ts_utils.get_node_at_cursor()
        if target ~= nil and utils.is_in_table(nodes, target:type()) then
            return false
        end
    end
end

conds.is_not_ts_node_comment = function()
    return function(opts)
        log.debug('not_in_ts_node_comment')
        if not opts.ts_node then return end

        parsers.get_parser():parse()
        local target = ts_utils.get_node_at_cursor()
        if target ~= nil and utils.is_in_table(opts.ts_node, target:type()) then
            return false
        end
    end
end

conds.is_not_in_context = function()
    return function(opts)
        local context = require("nvim-autopairs.ts-utils")
            .get_language_tree_at_position({ utils.get_cursor() })
        if not vim.tbl_contains(opts.rule.filetypes, context:lang()) then
            return false
        end
    end
end

return conds
