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

return M
