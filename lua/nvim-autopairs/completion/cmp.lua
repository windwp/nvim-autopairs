local autopairs = require('nvim-autopairs')
local handlers = require('nvim-autopairs.completion.handlers')
local cmp = require('cmp')
local utils = require('nvim-autopairs.utils')

local Kind = cmp.lsp.CompletionItemKind

local M = {}

M.filetypes = {
    -- Alias to all filetypes
    ["*"] = {
        ["("] = {
            kind = { Kind.Function, Kind.Method },
            handler = handlers["*"]
        }
    },
    clojure = {
        ["("] = {
            kind = { Kind.Function, Kind.Method },
            handler = handlers.lisp
        }
    },
    clojurescript = {
        ["("] = {
            kind = { Kind.Function, Kind.Method },
            handler = handlers.lisp
        }
    },
    fennel = {
        ["("] = {
            kind = { Kind.Function, Kind.Method },
            handler = handlers.lisp
        }
    },
    janet = {
        ["("] = {
            kind = { Kind.Function, Kind.Method },
            handler = handlers.lisp
        }
    },
    tex = false,
    haskell = false,
    purescript = false
}

M.on_confirm_done = function(opts)
    opts = vim.tbl_deep_extend('force', {
        filetypes = M.filetypes
    }, opts or {})

    return function(evt)
        if evt.commit_character then
            return
        end

        local entry = evt.entry
        local commit_character = entry:get_commit_characters()
        local bufnr = vim.api.nvim_get_current_buf()
        local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
        local item = entry:get_completion_item()

        -- Without options and fallback
        if not opts.filetypes[filetype] and not opts.filetypes["*"] then
            return
        end

        if opts.filetypes[filetype] == false then
            return
        end

        -- If filetype is nil then use *
        local completion_options = opts.filetypes[filetype] or opts.filetypes["*"]

        local rules = vim.tbl_filter(function(rule)
            return completion_options[rule.key_map]
        end, autopairs.get_buf_rules(bufnr))

        for char, value in pairs(completion_options) do
            if vim.tbl_contains(value.kind, item.kind) then
                value.handler(char, item, bufnr, rules, commit_character)
            end
        end
    end
end

local loaded_cpp_sort = false
M.cpp_pairs = function()
    local cmp_config = require('cmp.config')
    local cmp_comparetors = cmp_config.get().sorting.comparators

    local unpack = unpack or table.unpack
    local function cpp_sort_cmp(entry1, entry2)
        local kind1 = entry1.completion_item.kind
        local kind2 = entry2.completion_item.kind
        if vim.o.filetype ~= "cpp" then
            return nil
        end
        if kind1 == Kind.Constructor and kind2 == Kind.Class then
            return false
        end
        if kind1 == Kind.Class and kind2 == Kind.Constructor then
            return true
        end
        return nil
    end
    if loaded_cpp_sort == false then
        cmp.setup({
            sorting = {
                comparators = {
                    cpp_sort_cmp,
                    unpack(cmp_comparetors),
                }
            }
        })
        loaded_cpp_sort = true
    end
    return function(evt)
        if not (vim.o.filetype == "c" or vim.o.filetype == "cpp") then
            return
        end

        local c = vim.api.nvim_win_get_cursor(0)[2]
        local line = vim.api.nvim_get_current_line()
        if line:sub(c, c) == '>' then
            return
        end

        local entry = evt.entry
        local item = entry:get_completion_item()
        local pairs = ''
        local functionsig = item.label
        if (functionsig:sub(#functionsig, #functionsig) == '>' or
                functionsig == ' template')
        then
            if functionsig:sub(2, 8) == 'include' then
                pairs = ' '
            end
            pairs = pairs .. '<>'
            pairs = pairs .. utils.esc(utils.key.join_left)
            local old_lazyredraw = vim.o.lazyredraw
            vim.o.lazyredraw = true
            vim.api.nvim_feedkeys(pairs .. utils.esc("<cmd>lua vim.o.lazyredraw =" .. (old_lazyredraw and "true" or "false") .. "<cr>"),"i", false)
        end
    end
end


return M
