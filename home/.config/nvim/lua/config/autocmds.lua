-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Prompt Enhance: auto-enhance Claude Code input when triggered from tmux (prefix + E)
local function prompt_enhance()
  local signal = "/tmp/.prompt-enhance-signal"
  local stat = vim.uv.fs_stat(signal)
  if not stat or (os.time() - stat.mtime.sec) > 10 then
    return
  end

  vim.uv.fs_unlink(signal)

  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local input = table.concat(lines, "\n")
  if input == "" then
    vim.notify("Buffer empty — nothing to enhance", vim.log.levels.WARN)
    return
  end

  vim.notify("Enhancing prompt...", vim.log.levels.INFO)

  local sys = "You transform rough prompts into testable specifications."
    .. " Read the input. Output it unchanged, then append:"
    .. " Validation Criteria (2-4 bullets), Test Steps (2-5 bullets), Done Conditions (2-4 bullets)."
    .. " Your ENTIRE output is the enhanced prompt."
    .. " The first line of your output MUST be the first line of the input."
    .. " No introductions. No commentary."

  vim.system(
    { "claude", "-p", "--system-prompt", sys, "--model", "haiku", "--tools", "" },
    { text = true, stdin = input, timeout = 30000 },
    function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          vim.notify("Enhancement failed: " .. (result.stderr or "unknown error"), vim.log.levels.ERROR)
          return
        end

        local enhanced = result.stdout
        if not enhanced or enhanced == "" then
          vim.notify("Enhancement returned empty result", vim.log.levels.WARN)
          return
        end

        enhanced = enhanced:gsub("\n$", "")
        local new_lines = vim.split(enhanced, "\n", { plain = true })
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
        vim.notify("Prompt enhanced!", vim.log.levels.INFO)
      end)
    end
  )
end

vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("prompt_enhance", { clear = true }),
  callback = prompt_enhance,
})

vim.schedule(prompt_enhance)
