local autopairs = require('nvim-autopairs')
local handlers = require('nvim-autopairs.completion.handlers')
local cmp = require('cmp')

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
    python = {
        ["("] = {
            kind = { Kind.Function, Kind.Method },
            handler = handlers.python
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
    plaintex = false,
    context = false,
    haskell = false,
    purescript = false,
    sh = false,
    bash = false
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

return M
