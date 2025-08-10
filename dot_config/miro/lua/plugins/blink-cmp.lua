-- generic completion engine written in Rust with fuzzy matching

local dump = require('core.utils').dump

-- Use this function to check if the cursor is inside a comment block
local function inside_comment_block()
	if vim.api.nvim_get_mode().mode ~= 'i' then
		return false
	end
	local node_under_cursor = vim.treesitter.get_node()
	local parser = vim.treesitter.get_parser(nil, nil, { error = false })
	local query = vim.treesitter.query.get(vim.bo.filetype, 'highlights')
	if not parser or not node_under_cursor or not query then
		return false
	end
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	row = row - 1
	for id, node, _ in query:iter_captures(node_under_cursor, 0, row, row + 1) do
		if query.captures[id]:find('comment') then
			local start_row, start_col, end_row, end_col = node:range()
			if start_row <= row and row <= end_row then
				if start_row == row and end_row == row then
					if start_col <= col and col <= end_col then
						return true
					end
				elseif start_row == row then
					if start_col <= col then
						return true
					end
				elseif end_row == row then
					if col <= end_col then
						return true
					end
				else
					return true
				end
			end
		end
	end
	return false
end

return {
	'saghen/blink.cmp',
	-- optional: provides snippets for the snippet source
	dependencies = {
		'rafamadriz/friendly-snippets',
		'moyiz/blink-emoji.nvim',
		{
			'Kaiser-Yang/blink-cmp-dictionary',
			dependencies = { 'nvim-lua/plenary.nvim' }
		}
	},

	-- use a release tag to download pre-built binaries
	version = '1.*',
	-- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
	-- build = 'cargo build --release',
	-- If you use nix, you can build from source using latest nightly rust with:
	-- build = 'nix run .#build-plugin',

	opts = {
		-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
		-- 'super-tab' for mappings similar to vscode (tab to accept)
		-- 'enter' for enter to accept
		-- 'none' for no mappings
		--
		-- All presets have the following mappings:
		-- C-space: Open menu or open docs if already open
		-- C-n/C-p or Up/Down: Select next/previous item
		-- C-e: Hide menu
		-- C-k: Toggle signature help (if signature.enabled = true)
		--
		-- See :h blink-cmp-config-keymap for defining your own keymap
		keymap = { preset = 'default' },

		appearance = {
			-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
			-- Adjusts spacing to ensure icons are aligned
			nerd_font_variant = 'normal'
		},

		-- Default was to only show the documentation popup when manually triggered
		-- now enabled
		completion = {
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 750,
			},
			ghost_text = {
				enabled = false,
			},
			menu = {
				auto_show = true,
				draw = {
					columns = {
						{ "kind_icon" },
						{ "label",      "label_description", gap = 1 },
						{ "source_name" },
					}
				}
			}
		},

		signature = { enabled = true },

		-- Default list of enabled providers defined so that you can extend it
		-- elsewhere in your config, without redefining it, due to `opts_extend`
		sources = {
			default = function()
				-- put those which will be shown always
				local result = { 'lsp', 'path', 'snippets', 'buffer' }
				-- blank empty buffer, good for just checking spellings or words
				if (not vim.o.filetype) or (vim.o.filetype == '') or
					-- turn on dictionary in markdown or text file
					vim.tbl_contains({ 'gitcommit', 'markdown', 'text' }, vim.bo.filetype) or
					-- or turn on dictionary if cursor is in the comment block
					inside_comment_block()
				then
					table.insert(result, 'emoji')
					table.insert(result, 'dictionary')
				end
				return result
			end,
			providers = {
				emoji = {
					module = "blink-emoji",
					name = "Emoji",
					score_offset = 5,
					opts = {
						-- the default is to leave the :flushed: syntax
						insert = false
					},
					transform_items = function(_, items)
						if (vim.tbl_count(items) > 1) then
							return items
						else
							return vim.tbl_map(
								function(item)
									-- for all except markdown replace with real unicode character
									-- this essentially reverts the insert=false from above
									if (not vim.tbl_contains({ "markdown" }, vim.bo.filetype)) then
										-- print(string.format("%s -> %s", item.textEdit.newText, item.insertText))
										item.textEdit.newText = item.insertText
									end
									return item
								end,
								items
							)
						end
					end,
				},
				dictionary = {
					module = 'blink-cmp-dictionary',
					name = 'Dict',
					-- Make sure this is at least 2 - 3 is recommended
					min_keyword_length = 3,
					max_items = 8,
					score_offset = -5,
					opts = {
						dictionary_directories = { vim.fn.expand('~/.config/dictionaries') }
					},
				},
				cmdline = {
					-- ignores cmdline completions when executing shell commands
					enabled = function()
						return vim.fn.getcmdtype() ~= ':' or not vim.fn.getcmdline():match("^[%%0-9,'<>%-]*!")
					end,
				}
			}
		},

		-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
		-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
		-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
		--
		-- See the fuzzy documentation for more information
		fuzzy = { implementation = "prefer_rust_with_warning" },

		cmdline = {
			completion = {
				menu = {
					auto_show = true,
				},
				ghost_text = {
					enabled = true,
				}
			}
		}
	},
	opts_extend = { "sources.default" }
}
