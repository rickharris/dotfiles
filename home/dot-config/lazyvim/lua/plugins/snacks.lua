--!strict

---@module 'lazy'
---@type LazySpec
return {
  {
    "snacks.nvim",
    ---@module "snacks"
    ---@type snacks.Config
    opts = {
      picker = {
        sources = {
          explorer = {
            auto_close = true,
            hidden = true,
            ignored = true,
          },
          files = {
            hidden = true,
          },
          notifications = {
            win = {
              preview = {
                wo = {
                  wrap = true,
                },
              },
            },
          },
        },
      },
    },
  },
}
