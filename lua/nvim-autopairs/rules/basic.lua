local Rule = require("nvim-autopairs.rule")
local cond = require("nvim-autopairs.conds")

local function basic(opt, ...)
	local move_func = opt.enable_moveright and cond.move_right or cond.none
	local rule = Rule(...):with_move(move_func()):with_pair(cond.not_add_quote_inside_quote())

	if #opt.ignored_next_char > 1 then
		rule:with_pair(cond.not_after_regex(opt.ignored_next_char))
	end
	rule:use_undo(opt.break_undo)
	return rule
end

local function bracket(opt, ...)
	local rule = basic(opt, ...)
	if opt.enable_check_bracket_line == true then
		rule:with_pair(cond.is_bracket_line()):with_move(cond.is_bracket_line_move())
	end
	if opt.enable_bracket_in_quote then
		-- still add bracket if text is quote "|" and next_char have "
		rule:with_pair(cond.is_bracket_in_quote(), 1)
	end
	return rule
end

local function setup(opt)

    -- stylua: ignore
    local rules = {
        Rule("<!--", "-->", 'html'):with_cr(cond.none()),
        Rule("```", "```", { 'markdown', 'vimwiki', 'rmarkdown', 'rmd', 'pandoc' }),
        Rule("```.*$", "```", { 'markdown', 'vimwiki', 'rmarkdown', 'rmd', 'pandoc' })
            :only_cr()
            :use_regex(true),
        Rule('"""', '"""', { 'python', 'elixir', 'julia', 'kotlin' })
            :with_pair(cond.not_before_char('"', 3)),
        Rule("'''", "'''", { 'python' })
            :with_pair(cond.not_before_char('"', 3)),
        basic(opt, "'", "'", '-rust')
            :with_pair(cond.not_before_regex("%w")),
        basic(opt, "'", "'", 'rust')
            :with_pair(cond.not_before_regex("[%w<&]"))
            :with_pair(cond.not_after_text(">")),
        basic(opt, "`", "`"),
        basic(opt, '"', '"', '-vim'),
        basic(opt, '"', '"', 'vim')
            :with_pair(cond.not_before_regex("^%s*$", -1)),
        bracket(opt, "(", ")"),
        bracket(opt, "[", "]"),
        bracket(opt, "{", "}"),
        Rule(">[%w%s]*$", "^%s*</",
            { 'html', 'typescript', 'typescriptreact', 'javascript', 'javascriptreact', 'svelte', 'vue', 'xml',
                'rescript' })
            :only_cr()
            :use_regex(true)
    }
	return rules
end

return { setup = setup, basic = basic, bracket = bracket }
