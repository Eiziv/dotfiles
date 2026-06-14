vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.scrolloff = 5

vim.opt.cursorline = true
vim.opt.textwidth = 100
vim.opt.colorcolumn = '+1'
vim.opt.formatoptions = 'cqj'

vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath('data') .. '/undodir'

vim.opt.path = vim.o.path .. '**'
vim.opt.wildmenu = true
vim.opt.wildignore = {
  "**/.direnv/**",
  "**/node_modules/**",
  "**/vendor/**",
};

vim.api.nvim_set_hl(0, 'Normal', { bg='none' })
vim.api.nvim_set_hl(0, 'StatusLine', { bg='none' })
vim.api.nvim_set_hl(0, 'StatusLineNC', { bg='none', fg='gray' })
vim.api.nvim_set_hl(0, 'WinBar', { bg='none' })
vim.api.nvim_set_hl(0, 'WinBarNC', { bg='none', fg='gray' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg='none' })
vim.api.nvim_set_hl(0, 'FloatBorder', { bg='none' })
vim.api.nvim_set_hl(0, 'Pmenu', { bg='none' })
vim.api.nvim_set_hl(0, 'PmenuBorder', { bg='none' })

vim.opt.winborder = "rounded";
vim.opt.pumborder = "rounded";

vim.opt.cmdheight = 1
vim.opt.showcmd = true

vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('ReturnToLastLine', { clear = true }),
  callback = function()
    local last = vim.fn.line([['"]])
    if last > 1 and last < vim.fn.line("$") then
      vim.cmd([[normal! g'"]])
    end
  end
})

vim.opt.list = true
vim.opt.listchars = {
  trail = '~',
  tab = '|  ',
  leadmultispace = ':' .. string.rep(' ', vim.opt.shiftwidth:get() - 1),
}

local function update()
  local listchars = vim.opt_local.listchars:get()
  listchars.leadmultispace = ':' .. string.rep(' ', vim.opt_local.shiftwidth:get() - 1)
  vim.opt_local.listchars = listchars
end

local group = vim.api.nvim_create_augroup('ListcharsLeadmultispaceWidth', { clear = true }),

vim.api.nvim_create_autocmd('OptionSet', {
  group = group,
  pattern = 'shiftwidth',
  callback = update,
})

vim.api.nvim_create_autocmd({ 'FileType', 'BufWinEnter' }, {
  group = group,
  callback = update,
})

vim.api.nvim_create_autocmd(
  {'BufEnter', 'BufAdd', 'BufDelete', 'BufLeave', 'BufModifiedSet', 'BufWrite'},
  {
    group = vim.api.nvim_create_augroup("WinBarBuffers", { clear = true }),
    pattern = "*",
    callback = function()
      local buffers = {}
      local current = vim.api.nvim_win_get_buf(0)

      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[bufnr].buflisted then
          local name = vim.fn.fnamemodify(vim.fn.bufname(bufnr), ":t")
          if name == "" then name = "[No name]" end

          local highlight = bufnr == current and "WinBar" or "WinBarNC"
          local modified = vim.bo[bufnr].modified and "*" or ""

          table.insert(buffers, string.format(
            "%%#%s# %d:%s%s %%*",
            highlight, bufnr, name, modified
          ))
        end
      end

      if #buffers > 1 and vim.bo[current].buflisted then
        vim.opt_local.winbar = table.concat(buffers)
        vim.keymap.set({'n','v'}, '<C-n>', ':bn<cr>', { buffer = current })
        vim.keymap.set({'n','v'}, '<C-p>', ':bp<cr>', { buffer = current })

      else
        vim.opt_local.winbar = ""
        pcall(function()
          vim.keymap.del({'n','v'}, '<C-n>', { buffer = current })
          vim.keymap.del({'n','v'}, '<C-p>', { buffer = current })
        end)
      end
    end
  }
)

vim.keymap.set({'n','v'}, '<C-c>', '"+y')
vim.keymap.set({'n','v'}, '<C-v>', '"+p')
vim.keymap.set({'n','v'}, '<C-x>', '"+d')

-- Use C-q for block visual mode
vim.keymap.set({'n','v'}, '<C-q>', '<C-v>', { noremap = true})
