-- ~/.config/wezterm/wezterm.lua
-- WezTerm: Gruvbox Dark Hard (contrast tuned up), translucent window, tmux cockpit bar.

local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

local is_mac = wezterm.target_triple:find("darwin") ~= nil
local is_windows = wezterm.target_triple:find("windows") ~= nil

-- true  = WezTerm opens straight into tmux; tmux draws the tabs, splits and status bar
-- false = WezTerm handles tabs/splits itself (Ctrl+a leader)
local use_tmux = false

-- Gruvbox Dark Hard palette, contrast tuned up (shared with Neovim + Starship)
local c = {
  crust = "#0e1010",
  mantle = "#141617",
  base = "#1d2021",
  surface0 = "#282828",
  surface1 = "#3c3836",
  overlay0 = "#7c6f64",
  subtext0 = "#d5c4a1",
  text = "#f4e8c4",
  lavender = "#9cc5c0",
  mauve = "#e59bb6",
  pink = "#ff5f4f",
  yellow = "#ffc83d",
  green = "#c5c934",
}

----------------------------------------------------------------------
-- Colors
----------------------------------------------------------------------
config.colors = {
  foreground = "#f4e8c4",
  background = "#141617",
  cursor_bg = "#ffc83d",
  cursor_border = "#ffc83d",
  cursor_fg = "#141617",
  selection_bg = "#504945",
  selection_fg = "#fbf1c7",
  split = "#ffc83d",
  ansi = { "#282828", "#ff5f4f", "#c5c934", "#ffc83d", "#9cc5c0", "#e59bb6", "#a2d48f", "#d5c4a1" },
  brights = { "#7c6f64", "#ff7b6b", "#d8dc4a", "#ffd666", "#b4d9d4", "#f2b3c9", "#b8e3a6", "#fbf1c7" },
  tab_bar = { background = "rgba(0,0,0,0)" },
}

-- `ox theme` renders colors here; wezterm reloads when the file changes
local theme_file = wezterm.home_dir .. "/.config/ox/current/wezterm.lua"
wezterm.add_to_config_reload_watch_list(theme_file)
local ok, theme = pcall(dofile, theme_file)
if ok then
  c = theme.c
  config.colors = theme.colors
end

----------------------------------------------------------------------
-- Frosted glass background
-- Translucent background plus OS-level blur.
----------------------------------------------------------------------
config.background = {
  {
    source = { Color = c.mantle },
    width = "100%",
    height = "100%",
    opacity = 0.70, -- 1.0 = fully solid; lower = more see-through
  },
}

if is_mac then
  config.macos_window_background_blur = 20
elseif is_windows then
  config.win32_system_backdrop = "Acrylic"
else
  -- Works on KDE Plasma (Wayland). On Hyprland/Sway/GNOME, blur comes from the compositor.
  pcall(function()
    config.kde_window_background_blur = true
  end)
end

----------------------------------------------------------------------
-- Font
----------------------------------------------------------------------
config.font = wezterm.font_with_fallback({
  { family = "Monaspace Neon" }, -- Regular: Monaspace files its Medium weight under a separate name
  { family = "JetBrainsMono Nerd Font", weight = "Medium" }, -- icons, and backup if Monaspace is missing
})
-- comments and other italics use Monaspace Radon, the handwritten style
config.font_rules = {
  {
    italic = true,
    font = wezterm.font_with_fallback({
      { family = "Monaspace Radon", style = "Italic" },
      { family = "JetBrainsMono Nerd Font", style = "Italic" },
    }),
  },
}
config.warn_about_missing_glyphs = false
config.font_size = is_mac and 14.0 or 12.0
config.line_height = 1.15
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }

----------------------------------------------------------------------
-- Window
----------------------------------------------------------------------
config.window_decorations = "RESIZE"
config.window_padding = { left = 18, right = 18, top = 14, bottom = 10 }
config.initial_cols = 130
config.initial_rows = 36
config.adjust_window_size_when_changing_font_size = false
config.window_close_confirmation = "NeverPrompt"
config.inactive_pane_hsb = { saturation = 0.85, brightness = 0.65 }

config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 550
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

config.max_fps = 120
config.animation_fps = 60
config.scrollback_lines = 10000
config.audible_bell = "Disabled"
config.check_for_updates = false

if use_tmux then
  local shell = os.getenv("SHELL") or "/bin/zsh"
  config.default_prog = {
    shell, "-l", "-c",
    "command -v tmux >/dev/null && exec tmux new-session -A -s main || exec " .. shell .. " -l",
  }
end

----------------------------------------------------------------------
-- Tab bar (tmux-style: "1: zsh  2: nvim", active tab highlighted)
----------------------------------------------------------------------
config.enable_tab_bar = not use_tmux
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 32
config.status_update_interval = 1000

local function basename(s)
  if not s or s == "" then
    return nil
  end
  local name = s:match("([^/\\]+)$") or s
  return (name:gsub("%.exe$", ""))
end

wezterm.on("format-tab-title", function(tab, _, _, _, hover, max_width)
  local idx = tab.tab_index + 1
  local label = tab.tab_title
  if not label or label == "" then
    label = basename(tab.active_pane.foreground_process_name) or tab.active_pane.title
  end
  local zoomed = tab.active_pane.is_zoomed and " \u{f065}" or ""
  label = wezterm.truncate_right(label, max_width - 6)
  local text = " " .. idx .. ": " .. label .. zoomed .. " "

  if tab.is_active then
    return {
      { Background = { Color = c.yellow } },
      { Foreground = { Color = c.crust } },
      { Attribute = { Intensity = "Bold" } },
      { Text = text },
    }
  end
  return {
    { Background = { Color = "rgba(0,0,0,0)" } },
    { Foreground = { Color = hover and c.text or c.overlay0 } },
    { Text = text },
  }
end)

wezterm.on("update-status", function(window, _)
  local leader = window:leader_is_active()
  window:set_left_status(wezterm.format({
    { Foreground = { Color = leader and c.pink or c.mauve } },
    { Text = leader and " \u{f489} LEADER " or " \u{f489}  " },
  }))
  window:set_right_status(wezterm.format({
    { Foreground = { Color = c.subtext0 } },
    { Text = "\u{f017}  " .. wezterm.strftime("%Y-%m-%d  %H:%M") .. "  " },
  }))
end)

----------------------------------------------------------------------
-- Keys: tmux-like, leader = Ctrl+a (only used when use_tmux = false)
----------------------------------------------------------------------
if not use_tmux then
  config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

  config.keys = {
    -- splits
    { key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

    -- move between panes
    { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
    { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
    { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
    { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

    -- pane actions
    { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
    { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
    { key = "r", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },

    -- tabs
    { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
    { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
    {
      key = ",",
      mods = "LEADER",
      action = act.PromptInputLine({
        description = "Rename tab",
        action = wezterm.action_callback(function(window, _, line)
          if line then
            window:active_tab():set_title(line)
          end
        end),
      }),
    },

    -- copy mode, command palette
    { key = "[", mods = "LEADER", action = act.ActivateCopyMode },
    { key = "Space", mods = "LEADER", action = act.ActivateCommandPalette },

    -- press Ctrl+a twice to send a real Ctrl+a to the shell
    { key = "a", mods = "LEADER|CTRL", action = act.SendKey({ key = "a", mods = "CTRL" }) },
  }

  for i = 1, 9 do
    table.insert(config.keys, { key = tostring(i), mods = "LEADER", action = act.ActivateTab(i - 1) })
  end

  config.key_tables = {
    resize_pane = {
      { key = "h", action = act.AdjustPaneSize({ "Left", 3 }) },
      { key = "j", action = act.AdjustPaneSize({ "Down", 3 }) },
      { key = "k", action = act.AdjustPaneSize({ "Up", 3 }) },
      { key = "l", action = act.AdjustPaneSize({ "Right", 3 }) },
      { key = "Escape", action = "PopKeyTable" },
      { key = "Enter", action = "PopKeyTable" },
    },
  }
end

-- Ctrl+V pastes on Linux/Windows (Ctrl+Shift+V also works; Mac uses Cmd+V)
if not is_mac then
  config.keys = config.keys or {}
  table.insert(config.keys, { key = "v", mods = "CTRL", action = act.PasteFrom("Clipboard") })
end

return config
