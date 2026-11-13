return {
  palette = {
    dark0_hard = "@BG@", dark0 = "@BG0@", dark1 = "@BG2@", dark2 = "@BG3@", dark4 = "@GRAY@",
    light1 = "@FG@", light2 = "@FG2@", gray = "@DIM@",
    bright_red = "@RED@", bright_green = "@GREEN@", bright_yellow = "@YELLOW@",
    bright_blue = "@BLUE@", bright_purple = "@PURPLE@", bright_aqua = "@AQUA@", bright_orange = "@ORANGE@",
  },
  overrides = {
    CursorLine = { bg = "@BG0@" },
    CursorLineNr = { fg = "@ACCENT@", bold = true },
    LineNr = { fg = "@GRAY@" },
    SignColumn = { bg = "NONE" },
    NormalFloat = { bg = "NONE" },
    FloatBorder = { fg = "@ACCENT@", bg = "NONE" },
    WinSeparator = { fg = "@BG2@" },
    Visual = { bg = "@BG3@" },
    SnacksDashboardHeader = { fg = "@ACCENT@" },
    SnacksDashboardKey = { fg = "@ACCENT2@" },
  },
}
