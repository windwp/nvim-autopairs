local data={
  {
    name = "add normal bracket" ,
    key    = [[(]],
    before = [[aaaa|]],
    after  = [[aaaa(|)]]
  },
  {
    name = "add normal quote" ,
    key    = [["]],
    before = [[aa|aa]],
    after  = [[aa"|"aa]]
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
  }

}
local npairs=require('nvim-autopairs')
npairs.setup()
local eq = assert.are.same
describe('autopairs ', function()
  -- TODO change to use feedkeys
  for _, value in pairs(data) do
    it('test: ' ..value.name , function()
      local before = string.gsub(value.before , '%|' , "")
      local after = string.gsub(value.after , '%|' , "")
      local p_before = string.find(value.before , '%|')
      local p_after = string.find(value.after , '|')
      local line = 1
      vim.fn.col = function(opts)  return p_before end
      -- add 1 space for simulate insert mode location
      vim.fn.setline(line , before)
      vim.fn.setpos('.' ,{0 , line , p_before , 0})
      local result = npairs.check_add(value.key)
      if result == 2  then
        eq(p_before , p_after - 1 , "pos should be correct")
        eq(string.len(value.before) , string.len(value.after) , "text should correct")
      elseif result == 1 then
        eq(p_before , p_after - 1 , "pos should be correct")
        eq(string.len(value.before) , string.len(value.after) - 2 ,"text should correct")
      elseif result == 0 then
        eq(p_before , p_after - 1 , "pos should be correct")
        eq(string.len(value.before) , string.len(value.after) - 2 ,"text should correct")
      else
        assert(false)
      end
    end)
  end
  print("end")
end)

