-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Prompt Transform: auto-transform Claude Code input when triggered from tmux (prefix + E)

--- Shared helper that detects a signal file, reads the buffer, calls claude with
--- the given system prompt, and replaces the buffer with the result.
--- @param signal_path string  Absolute path to the signal file
--- @param system_prompt string  System prompt for claude
--- @param label string  Notification text shown during processing
--- @return boolean  true if signal was found and processing started
local function run_prompt_transform(signal_path, system_prompt, label)
  local stat = vim.uv.fs_stat(signal_path)
  if not stat or (os.time() - stat.mtime.sec) > 10 then
    return false
  end

  vim.uv.fs_unlink(signal_path)

  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local input = table.concat(lines, "\n")
  if input == "" then
    vim.notify("Buffer empty — nothing to transform", vim.log.levels.WARN)
    return true
  end

  vim.notify(label, vim.log.levels.INFO, { id = "prompt_transform", timeout = false })

  vim.system(
    { "claude", "-p", "--system-prompt", system_prompt, "--model", "haiku", "--tools", "", "--setting-sources", "" },
    { text = true, stdin = input, timeout = 30000, cwd = "/tmp" },
    function(result)
      vim.schedule(function()
        -- Signal means process was killed (e.g. timeout hit on hung auth)
        if result.signal and result.signal ~= 0 then
          vim.notify("Transform timed out — check `claude` auth", vim.log.levels.ERROR, { id = "prompt_transform" })
          return
        end

        if result.code ~= 0 then
          local stderr = result.stderr or ""
          local stdout = result.stdout or ""
          local msg = (stderr ~= "" and stderr or stdout):match("[^\n]+") or ("exit code " .. (result.code or "?"))
          vim.notify("Transform failed: " .. msg, vim.log.levels.ERROR, { id = "prompt_transform" })
          return
        end

        local output = result.stdout
        if not output or output == "" then
          vim.notify("Transform returned empty result", vim.log.levels.WARN, { id = "prompt_transform" })
          return
        end

        output = output:gsub("\n$", "")
        local new_lines = vim.split(output, "\n", { plain = true })
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
        vim.notify("Prompt transformed!", vim.log.levels.INFO, { id = "prompt_transform" })
      end)
    end
  )

  return true
end

local function enhance()
  local sys = "You rewrite rough prompts into clear, specific, testable specifications."
    .. " Improve the input: fix grammar, add missing context, make intent explicit, remove ambiguity."
    .. " Then append: Validation Criteria (2-4 bullets), Test Steps (2-5 bullets), Done Conditions (2-4 bullets)."
    .. " Start directly with the rewritten prompt text. No labels, no preamble, no 'REWRITTEN PROMPT:', no 'Here is'."
    .. " Use plain text with simple dash bullets. No markdown headers, no bold, no formatting."

  return run_prompt_transform("/tmp/.prompt-enhance-signal", sys, "Enhancing prompt...")
end

local function socratic()
  local sys = "You rewrite direct prompts into Socratic-style prompts that trigger deeper reasoning."
    .. " Instead of instructions, produce a series of guided questions that:"
    .. " - Start with foundational questions about the domain (\"What makes X good?\", \"What does Y need to accomplish?\")"
    .. " - Build toward the specific task by layering constraints and context through questions"
    .. " - End with a synthesis directive (\"Now apply that to [specific case]\")"
    .. " The questions should force the AI to reason through WHY before WHAT."
    .. " Keep the user's original intent and scope — don't expand or reduce what they asked for."
    .. " Output only the rewritten Socratic prompt. No preamble, no labels, no explanation."
    .. " Use plain text. No markdown headers, no bold, no formatting."

  return run_prompt_transform("/tmp/.prompt-socratic-signal", sys, "Socratic rewrite...")
end

local function on_buf_read()
  if socratic() then
    return
  end
  enhance()
end

vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("prompt_enhance", { clear = true }),
  callback = on_buf_read,
})

vim.schedule(on_buf_read)
