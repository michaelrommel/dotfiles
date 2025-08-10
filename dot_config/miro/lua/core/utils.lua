local M = {}

M.utf8 = function(decimal)
	local bytemarkers = { { 0x7FF, 192 }, { 0xFFFF, 224 }, { 0x1FFFFF, 240 } }
	if decimal < 128 then return string.char(decimal) end
	local charbytes = {}
	for bytes, vals in ipairs(bytemarkers) do
		if decimal <= vals[1] then
			for b = bytes + 1, 2, -1 do
				local mod = decimal % 64
				decimal = (decimal - mod) / 64
				charbytes[b] = string.char(128 + mod)
			end
			charbytes[1] = string.char(vals[2] + decimal)
			break
		end
	end
	return table.concat(charbytes)
end

M.dump = function(t)
	local conv = {
		["nil"] = function() return "nil" end,
		["number"] = function(n) return tostring(n) end,
		["string"] = function(s) return '"' .. s .. '"' end,
		["boolean"] = function(b) return tostring(b) end,
		["function"] = function(f) return tostring(f) end,
	}
	if type(t) == "table" then
		local s = "{"
		for k, v in pairs(t) do
			-- print(k)
			-- print(v)
			if type(k) == "number" then
				k = '["' .. k .. '"]'
			else
				k = conv[type(k)](k)
			end
			if type(v) == "table" then
				s = s .. (s == "{" and " " or ", ") .. (k .. " = " .. M.dump(v))
			else
				s = s .. (s == "{" and " " or ", ") .. k .. " = " .. conv[type(v)](v)
			end
		end
		return s .. " }"
	else
		return conv[type(t)](t)
	end
end

M.is_wsl = (function()
	local output = vim.fn.systemlist "uname -r"
	return not not string.find(output[1] or "", "WSL")
end)()

M.is_mac = (function()
	local output = vim.fn.systemlist "uname -s"
	return not not string.find(output[1] or "", "Darwin")
end)()

M.is_linux = (function()
	local output = vim.fn.systemlist "uname -s"
	return not not string.find(output[1] or "", "Linux")
end)()

return M
