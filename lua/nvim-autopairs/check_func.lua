local M={}


M.check_previous_word = function (regex)
  return function(opt)
    return opt.pre_word:match(regex) ~= nil
  end
end




return

