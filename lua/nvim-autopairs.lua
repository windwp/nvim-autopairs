local MPairs = {}

local pairs_map = {
    ["'"] = "'",
    ['"'] = '"',
    ['('] = ')',
    ['['] = ']',
    ['{'] = '}',
    ['`'] = '`',
}

local disable_filetype = { "TelescopePrompt" }
local check_line_pair = true
local break_line_rule ={
  {
    pairs_map = {
      ['('] = ')',
      ['['] = ']',
      ['{'] = '}',
    },
    disable_filetype = nil,
    filetype = nil
  },
  {
    pairs_map = {
        ['>'] = '<',
    },
    disable_filetype = nil,
    filetype = { 'html' , 'vue' , 'typescriptreact' , 'svelte' , 'javascriptreact' }
  }
}

local ignored_next_char = "%w"

local function is_in_table(tbl, val)
  for _, value in pairs(tbl) do
    if string.match(val, value) then return true end
  end
  return false
end
local function check_filetype(tbl, filetype)
  if tbl == nil then return true end
  return is_in_table(tbl, filetype)
end

local function check_disable_ft(tbl, filetype)
  if tbl == nil then return true end
  return not is_in_table(tbl, filetype)
end


MPairs.setup = function(opts)
  opts                     = opts or {}
  pairs_map                = opts.pairs_map or pairs_map
  disable_filetype         = opts.disable_filetype or disable_filetype
  if opts.check_line_pair ~= nil then check_line_pair = opts.check_line_pair end
  break_line_rule[1].filetypes        = opts.break_line_filetype or break_line_rule[1].filetype
  break_line_rule[1].disable_filetype = opts.break_line_disable_filetype  or disable_filetype
  break_line_rule[2].filetype         = opts.html_break_line_filetype or break_line_rule[2].filetype
  break_line_rule[2].disable_filetype = opts.html_break_line_disable_filetype or disable_filetype
  ignored_next_char = opts.ignored_next_char or ignored_next_char

  for char, char_end in pairs(pairs_map) do
    if string.len(char) == 1 then
      local mapCommand = string.format([[v:lua.MPairs.autopairs("%s","%s")]], char, char_end)
      if char == '"' then
        mapCommand = string.format([[v:lua.MPairs.autopairs('%s','%s')]], char, char_end)
      end
      vim.api.nvim_set_keymap('i', char, mapCommand, {expr = true, noremap = true})
      -- map char to move right when close pairs
      if char== "(" or char == '[' or char == "{" then
        mapCommand = string.format([[v:lua.MPairs.check_jump('%s')]], char_end)
        vim.api.nvim_set_keymap('i', char_end, mapCommand, {expr = true, noremap = true})
      end
    else
      print(string.format("Skip [%s], autopairs plugin is not support that "), char)
    end
  end
  -- delete pairs when press <bs>
  vim.api.nvim_set_keymap('i', "<bs>", "v:lua.MPairs.autopair_bs()", {expr = true, noremap = true})
end

local function esc(cmd)
  return vim.api.nvim_replace_termcodes(cmd, true, false, true)
end

MPairs.autopairs = function(char, char_end)
  local result= MPairs.check_add(char)
  if result == 1 then
   return esc(char..char_end.."<c-g>U<left>")
  elseif result == 2 then
    return esc("<c-g>U<right>")
  else
    return esc(char)
  end
end

MPairs.check_jump = function(char)
  local next_col  = vim.fn.col('.')
  local line      = vim.fn.getline('.')
  local next_char = line:sub(next_col, next_col)
  if  char == next_char then
    return esc("<c-g>U<right>")
  end
  return esc(char)
end


local function is_in_quote(line, pos)
  local cIndex     = 0
  local last_quote = ''
  local result     = false
  while cIndex < string.len(line) and cIndex < pos  do
    cIndex = cIndex + 1
    local char = line:sub(cIndex, cIndex)
    if
      result == true and
      char == last_quote and
      line:sub(cIndex -1, cIndex -1) ~= "\\"
    then
       result = false
     elseif result == false and (char == "'" or char == '"' or char == '`') then
        last_quote = char
        result = true
    end
  end
  return result
end

MPairs.check_add = function(char)
  if not check_disable_ft(disable_filetype, vim.bo.filetype) then return 0 end
  local next_col = vim.fn.col('.')
  local line = vim.fn.getline('.')
  local next_char = line:sub(next_col, next_col)
  local prev_char = line:sub(next_col -1, next_col -1)

  -- move right when have quote on end line or in quote
  -- situtaion  |"  => "|
  if (next_char == "'" or next_char == '"' or next_char == '`') and next_char == char then
    if next_col == string.len(line) then
        return  2
    end
    -- ("|")  => (""|)
    --  ""       |"      "  => ""       "|      "
    if is_in_quote(line, next_col - 1) then
      return 2
    end
  end
  -- don' t add single quote if prev char is word
  -- a| => not add
  if char == "'"  and prev_char:match("%w")then
    return 0
  end

  -- when on end line col not work with autocomplete method so we need to skip it
  if next_col == string.len(line) + 1 then
    -- need to update completion nvim for check
    return 1
  end


  -- situtaion  |(  => not add
  if next_char == char then
    return  0
  end

  -- don't add pairs based on `ignored_next_char`
  -- situation: ignored_next_char = "%w" -> |abcde => not add
  --            ignored_next_char = "[%w%.]" -> |.abcde => not add
  if next_char:match(ignored_next_char) then
    return 0
  end

  local char_end = pairs_map[char]
  if check_line_pair and next_char == char_end  then
    -- ((  many char |)) => add
    -- (   many char |)) => not add
    local count_prev_char = 0
    local count_next_char = 0
    for i = 1, #line, 1 do
      local c = line:sub(i, i)
      if c == char then
        count_prev_char = count_prev_char + 1
      elseif c == char_end then
        count_next_char = count_next_char + 1
      end
    end
    if count_prev_char ~= count_next_char then
      return 0
    end
  end
  return 1
end

-- break line on <CR> and html
-- use it for add new line after enter
MPairs.check_break_line_char = function()
  local result = 0
  local prev_col = vim.fn.col('.') - 1
  local next_col = vim.fn.col('.')
  local prev_char = vim.fn.getline('.'):sub(prev_col, prev_col)
  local next_char = vim.fn.getline('.'):sub(next_col, next_col)
  for _, rule in pairs(break_line_rule) do
    if
      result == 0 and rule.pairs_map[prev_char] == next_char and
      check_filetype(rule.filetype, vim.bo.filetype) and
      check_disable_ft(rule.disable_filetype, vim.bo.filetype)
      then
        result = 1
        break
      end
  end
  if result == 1 then
    return esc("<cr><c-o>O")
  end
  return esc("<cr>")
end

-- delete pair on <bs>
MPairs.autopair_bs = function()
  local next_col = vim.fn.col('.')
  local line = vim.fn.getline('.')
  local next_char = line:sub(next_col, next_col)
  local prev_char = line:sub(next_col - 1 , next_col - 1)
  local char_end = pairs_map[prev_char]
  if char_end ~= nil and next_char == char_end then
    return esc("<c-g>U<bs><right><bs>")
  end
  return esc("<bs>")
end

MPairs.esc = esc
_G.MPairs = MPairs

return MPairs

-- vim: ts=2 sw=2
