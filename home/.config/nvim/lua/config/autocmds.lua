-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Prompt Transform: auto-transform Claude Code input when triggered from tmux (prefix + E)

local prompt_dir = vim.fn.expand("~/.claude/skills/prompt-enhance/prompts/")

local function read_prompt(name)
  local path = prompt_dir .. name .. ".md"
  local lines = vim.fn.readfile(path)
  if #lines == 0 then
    vim.notify("Missing prompt: " .. path, vim.log.levels.ERROR)
    return nil
  end
  return table.concat(lines, " ")
end

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

local function blueprint()
  local sys = read_prompt("blueprint")
  if not sys then return false end
  return run_prompt_transform("/tmp/.prompt-blueprint-signal", sys, "Blueprint...")
end

local function optimize()
  local sys = read_prompt("optimize")
  if not sys then return false end
  return run_prompt_transform("/tmp/.prompt-optimize-signal", sys, "Optimizing prompt...")
end

local function socratic()
  local sys = read_prompt("socratic")
  if not sys then return false end
  return run_prompt_transform("/tmp/.prompt-socratic-signal", sys, "Socratic rewrite...")
end

local function on_buf_read()
  if optimize() then
    return
  end
  if socratic() then
    return
  end
  blueprint()
end

vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("prompt_enhance", { clear = true }),
  callback = on_buf_read,
})

vim.schedule(on_buf_read)
