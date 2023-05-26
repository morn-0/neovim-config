vim.cmd('colorscheme catppuccin-macchiato')

-- utf8
vim.g.encoding = 'UTF-8'
vim.o.fileencoding = 'utf-8'
-- jk移动时光标下上方保留8行
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
-- 使用相对行号
vim.wo.number = true
vim.wo.relativenumber = true
-- 高亮所在行
vim.wo.cursorline = true
-- 左侧图标指示列
vim.wo.signcolumn = 'yes'
-- 右侧参考线
vim.wo.colorcolumn = '100'
-- 缩进4个空格
vim.o.tabstop = 4
vim.bo.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftround = true
-- >> << 时移动长度
vim.o.shiftwidth = 4
vim.bo.shiftwidth = 4
-- 新行对齐当前行,空格替代tab
vim.o.expandtab = true
vim.bo.expandtab = true
vim.o.autoindent = true
vim.bo.autoindent = true
vim.o.smartindent = true
-- 搜索大小写不敏感，除非包含大写
vim.o.ignorecase = true
vim.o.smartcase = true
-- 搜索不要高亮
vim.o.hlsearch = false
-- 边输入边搜索
vim.o.incsearch = true
-- 使用增强状态栏后不再需要 vim 的模式提
vim.o.showmode = false
-- 命令行高为2
-- vim.o.cmdheight = 2
-- 文件被外部程序修改时自动加载
vim.o.autoread = true
vim.bo.autoread = true
-- 禁止折行
vim.o.wrap = false
vim.wo.wrap = false
-- 行结尾可以跳到下一行
-- vim.o.whichwrap = 'b,s,<,>,[,],h,l'
-- 允许隐藏被修改过的buffer
vim.o.hidden = true
-- 鼠标支持
vim.o.mouse = 'a'
-- 禁止创建备份文件
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
-- smaller updatetime
vim.o.updatetime = 300
-- 设置 timeoutlen 为等待键盘快捷键连击时间200毫秒，可根据需要设置
-- 遇到问题详见：https://github.com/nshen/learn-neovim-lua/issues/1
vim.o.timeoutlen = 200
-- split window 从下边和右边出现
vim.o.splitbelow = true
vim.o.splitright = true
-- 自动补全不自动选中
vim.g.completeopt = 'menu,menuone,noselect,noinsert'
-- 样式
vim.o.termguicolors = true
-- 不可见字符的显示，这里只把空格显示为一个点
vim.o.list = true
vim.o.listchars = 'space:·,eol:↴'
-- 补全增强
vim.o.wildmenu = true
-- Dont' pass messages to |ins-completin menu|
vim.o.shortmess = vim.o.shortmess .. 'c'
vim.o.pumheight = 10
-- always show tabline
-- vim.o.showtabline = 2
-- vim.g.python3_host_prog = "~/.config/nvim/nvim-python/bin/python3"
vim.g.mouse = 'a'
vim.g.undofile = true
vim.o.cursorcolumn = true

vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function ()
    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')

    local width = 4
    if ft == 'dart' or ft == 'javascript' or ft == 'lua' or ft == 'c' or ft == 'cpp' or ft == 'yaml' then
      width = 2
    end

    vim.o.tabstop = width
    vim.bo.tabstop = width
    vim.o.softtabstop = width
    vim.o.shiftround = true
    vim.o.shiftwidth = width
    vim.bo.shiftwidth = width
  end,
})
