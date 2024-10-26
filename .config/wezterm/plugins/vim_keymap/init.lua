local wez = require "wezterm"

local M = {}

-- STOLEN from https://www.github.com/sravioli/wezterm
-- found there :
-- https://github.com/wez/wezterm/discussions/628

---Map an action using (n)vim-like syntax
---@param lhs string keymap
---@param rhs function|string `wezterm.action.<action>`
---@param tbl table table to insert keys to
M.map = function(lhs, rhs, tbl)
  ---Inserts the keymap in the table
  ---@param key string key to press.
  ---@param mods? string modifiers. defaults to `""`
  local function map(key, mods)
    table.insert(tbl, { key = key, mods = mods or "", action = rhs })
  end

  ---skip checks for single key mapping, just map it.
  if #lhs == 1 then
    map(lhs)
    return
  end

  local aliases =
    { ["CR"] = "Enter", ["BS"] = "Backspace", ["ESC"] = "Escape", ["Bar"] = "|" }
  for i = 0, 9 do
    aliases["k" .. i] = "Numpad" .. i
  end

  local modifiers = { C = "CTRL", S = "SHIFT", W = "SUPER", M = "ALT" }

  local mods = {}
  ---search for a leader key
  if lhs:find "^<leader>" then
    lhs = (lhs:gsub("^<leader>", ""))
    table.insert(mods, "LEADER")
  end

  if lhs:find "%b<>" then
    lhs = lhs:gsub("(%b<>)", function(str)
      return str:sub(2, -2)
    end)

    local keys = M.split(lhs, "%-")
    if #keys == 1 then
      map(aliases[keys[1]] or keys[1])
      return
    end

    local k = keys[#keys]
    if modifiers[k] then
      wez.log_error "keymap cannot end with modifier!"
      return
    else
      table.remove(keys, #keys)
    end
    k = aliases[k] or k

    for _, key in ipairs(keys) do
      table.insert(mods, modifiers[key])
    end

    map(k, table.concat(mods, "|"))
    return
  end

  map(lhs, table.concat(mods, "|"))
end

M.gsplit = function(s, sep, opts)
  local plain
  local trimempty = false
  if type(opts) == "boolean" then
    plain = opts -- For backwards compatibility.
  else
    opts = opts or {}
    plain, trimempty = opts.plain, opts.trimempty
  end

  local start = 1
  local done = false

  -- For `trimempty`: queue of collected segments, to be emitted at next pass.
  local segs = {}
  local empty_start = true -- Only empty segments seen so far.

  local function _pass(i, j, ...)
    if i then
      assert(j + 1 > start, "Infinite loop detected")
      local seg = s:sub(start, i - 1)
      start = j + 1
      return seg, ...
    else
      done = true
      return s:sub(start)
    end
  end

  return function()
    if trimempty and #segs > 0 then
      -- trimempty: Pop the collected segments.
      return table.remove(segs)
    elseif done or (s == "" and sep == "") then
      return nil
    elseif sep == "" then
      if start == #s then
        done = true
      end
      return _pass(start + 1, start)
    end

    local seg = _pass(s:find(sep, start, plain))

    -- Trim empty segments from start/end.
    if trimempty and seg ~= "" then
      empty_start = false
    elseif trimempty and seg == "" then
      while not done and seg == "" do
        table.insert(segs, 1, "")
        seg = _pass(s:find(sep, start, plain))
      end
      if done and seg == "" then
        return nil
      elseif empty_start then
        empty_start = false
        segs = {}
        return seg
      end
      if seg ~= "" then
        table.insert(segs, 1, seg)
      end
      return table.remove(segs)
    end

    return seg
  end
end

M.split = function(s, sep, opts)
  local t = {}
  for c in M.gsplit(s, sep, opts) do
    table.insert(t, c)
  end
  return t
end

return M
