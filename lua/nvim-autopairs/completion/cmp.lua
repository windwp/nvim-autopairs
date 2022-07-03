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
    tex = false
}

M.on_confirm_done = function(opts)
    opts = vim.tbl_deep_extend('force', {
        filetypes = M.filetypes
    }, opts or {})

    return function(evt)
        local entry = evt.entry
        local commit_character = evt.commit_character
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

        for char, value in pairs(completion_options) do
            if vim.tbl_contains(value.kind, item.kind) then
                value.handler(char, item, bufnr, commit_character)
            end
        end
    end
end

return M
