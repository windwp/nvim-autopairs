set rtp +=.
set rtp +=/home/trieu/.vim/autoload/plenary.nvim/
runtime! plugin/plenary.vim
source ~/.config/nvim/init.vim

lua require("plenary/busted")
lua require("nvim-autopairs")
lua require("../tests/pairs")

