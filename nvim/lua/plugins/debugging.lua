return {
  -- Add DAP support
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
      },
      {
        "mfussenegger/nvim-dap-python",
        -- This is important: make sure to customize this to your python environment
        -- This should point to the python executable where debugpy is installed
        config = function()
          local path = require("mason-registry").get_package("debugpy"):get_install_path()
          local python_path = path .. "/venv/bin/python"
          require("dap-python").setup(python_path)
        end,
      },
    },
  },

  -- Make sure debugpy is installed via Mason
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "debugpy",
      })
    end,
  },
}
