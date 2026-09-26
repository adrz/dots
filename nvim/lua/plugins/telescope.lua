return {
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    -- We merge with existing LazyVim defaults to not break anything
    opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
      layout_strategy = "horizontal",
      layout_config = {
        horizontal = {
          -- This controls the width of the entire Telescope window (85% of your screen)
          width = 0.85, 
          -- This sets the width of the Results panel relative to the whole layout.
          -- Setting it to 0.35 gives 35% to Results and the remaining 65% to the Preview!
          preview_width = 0.65,
        },
      },
    })
  end,
}
