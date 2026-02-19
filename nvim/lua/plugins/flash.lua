return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      -- 1. Normal Mode: 's' activates Flash (Jump)
      {
        "s",
        mode = { "n", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },

      -- 2. Visual Mode: Disable 's' so Mini Surround can use it
      { "s", mode = { "x" }, false },

      -- 3. Keep 'S' for Treesitter search (optional, but good to have)
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
    },
  },
}
