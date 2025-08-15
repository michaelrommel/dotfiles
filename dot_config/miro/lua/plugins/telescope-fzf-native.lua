-- native fzf integration
return {
	"nvim-telescope/telescope-fzf-native.nvim",
	lazy = true,
	build =
	"cmake -S. -Bbuild -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
	-- "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
}
