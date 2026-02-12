return {
  "tpope/vim-projectionist",
  event = { "BufReadPre", "BufNewFile" },
  init = function()
    vim.g.projectionist_heuristics = vim.tbl_deep_extend(
      "force",
      vim.g.projectionist_heuristics or {},
      {
        ["src/"] = {
          ["src/*.ts"] = {
            alternate = {
              "tests/unit/{}.spec.ts",
              "tests/e2e/{}.spec.ts",
            },
          },
          ["tests/unit/*.spec.ts"] = {
            alternate = "src/{}.ts",
          },
          ["tests/e2e/*.spec.ts"] = {
            alternate = "src/{}.ts",
          },
        },
      }
    )
  end,
}
