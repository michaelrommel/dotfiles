-- this extends treesitter to know about a language's
-- structure for text objects
return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	lazy = true,
	config = function()
		require("nvim-treesitter.configs").setup({
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
						["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
						["l="] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
						["r="] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },
						["aa"] = { query = "@parameter.outer", desc = "Select outer part of an argument" },
						["ia"] = { query = "@parameter.inner", desc = "Select inner part of an argument" },
						["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
						["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },
						["af"] = { query = "@call.outer", desc = "Select outer part of a function call" },
						["if"] = { query = "@call.inner", desc = "Select inner part of a function call" },
						["am"] = { query = "@function.outer", desc = "Select outer part of a function definition" },
						["im"] = { query = "@function.inner", desc = "Select inner part of a function definition" },
					}
				}
			}
		})
	end
}
