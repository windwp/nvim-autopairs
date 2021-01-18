local helpers = {}
local npairs=require('nvim-autopairs')
npairs.setup()
local eq = assert.are.same
_G.npairs = npairs;

vim.api.nvim_set_keymap('i' , '<CR>','v:lua.npairs.check_break_line_char()', {expr = true , noremap = true})
function helpers.feed(text, feed_opts)
  feed_opts = feed_opts or 'n'
  local to_feed = vim.api.nvim_replace_termcodes(text, true, false, true)
  vim.api.nvim_feedkeys(to_feed, feed_opts, true)
end

function helpers.insert(text)
  helpers.feed('i' .. text, 'x')
end

local data = {
  {
    name = "add normal bracket" ,
    key    = [[{]],
    before = [[aaaa| ]],
    after  = [[aaaa{|} ]]
  },
  {
    name = "add normal bracket" ,
    key    = [[(]],
    before = [[aaaa| ]],
    after  = [[aaaa(|) ]]
  },
   {
    name = "add normal quote" ,
    key    = [["]],
    before = [[aa| aa]],
    after  = [[aa"|" aa]]
  },
   {
    name = "don't add single quote with previous alphabet char" ,
    key    = [[']],
    before = [[aa| aa]],
    after  = [[aa'| aa]]
  },
   {
    name = "don't add single quote on end line",
    key    = [[<right>']],
    before = [[c aa|]],
    after  = [[c aa'|]]
  },
   {
    name = "don't add quote after alphabet char" ,
    key    = [["]],
    before = [[aa  |aa]],
    after  = [[aa  "|aa]]
  },
   {
    name = "don't add pair after alphabet char" ,
    key    = [[(]],
    before = [[aa  |aa]],
    after  = [[aa  (|aa]]
  },
  {
    name = "move right end line " ,
    key    = [["]],
    before = [[aaaa|"]],
    after  = [[aaaa"|]]
  },
  {
    name = "move right when inside quote" ,
    key    = [["]],
    before = [[("abcd|")]],
    after  = [[("abcd"|)]]
  },
  {
    name = "move right when inside quote with special slash" ,
    key    = [["]],
    before = [[("abcd\"|")]],
    after  = [[("abcd\""|)]]
  },
  {
    name = "move right when inside single quote with special slash",
    filetype="javascript",
    key    = [[']],
    before = [[nvim_set_var('test_thing|')]],
    after  = [[nvim_set_var('test_thing'|)]]
  },
  {
    name = "breakline on {" ,
    filetype="javascript",
    key    = [[<cr>]],
    before = [[a{|}]],
    after  = [[}]]
  },
  {
    name = "breakline on (" ,
    filetype="javascript",
    key    = [[<cr>]],
    before = [[a(|)]],
    after  = [[)]]
  },
  {
    name = "breakline on ]" ,
    filetype="javascript",
    key    = [[<cr>]],
    before = [[a[|] ]],
    after  = "] "
  },
  {
    name = "breakline on < html" ,
    filetype="html",
    key    = [[<cr>]],
    before = [[<div>|</div>]],
    after  = [[</div>]]
  }
}

local run_data = {}
for _, value in pairs(data) do
  if value.only == true then
    table.insert(run_data, value)
    break
  end
end
if #run_data == 0 then run_data = data end

describe('autopairs ', function()
  for _, value in pairs(run_data) do
    it("test "..value.name, function()
      local before = string.gsub(value.before , '%|' , "")
      local after = string.gsub(value.after , '%|' , "")
      local p_before = string.find(value.before , '%|')
      local p_after = string.find(value.after , '%|')
      local line = 1
      if value.filetype ~= nil then
        vim.bo.filetype = value.filetype
      else
        vim.bo.filetype = "text"
      end
      vim.fn.setline(line , before)
      vim.fn.setpos('.' ,{0 , line , p_before , 0})
      helpers.insert(value.key)
      helpers.feed("<esc>")
      local result = vim.fn.getline(line)
      local pos = vim.fn.getpos('.')
      if value.key ~= '<cr>' then
        eq(p_after , pos[3]+ 1 , "\n\n pos error: " .. value.name .. "\n")
        eq(after, result , "\n\n text error: " .. value.name .. "\n")
      else
        local line2 = vim.fn.getline(line + 2)
        eq(line + 1, pos[2], '\n\n breakline error:' .. value.name .. "\n")
        eq(after, line2 , "\n\n text error: " .. value.name .. "\n")
        vim.fn.setline(line, '')
        vim.fn.setline(line+ 1, '')
        vim.fn.setline(line+ 2, '')
      end
    end)
  end
  print("end")
end)


