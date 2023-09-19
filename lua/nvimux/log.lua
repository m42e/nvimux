local M = {
	logdata = {},
	logsize = 50,
}

-- Store a line or something else in the log buffer, to be printed on request
M.log = function(log)
	local logstr = os.date("%Y-%m-%d %H:%M:%S") .. " " .. debug.getinfo(2).name
	if type(log) ~= "string" then
		logstr = logstr .. " " .. vim.inspect(log)
	else
		logstr = logstr .. " " .. log
	end
	table.insert(M.logdata, logstr)
	if #M.logdata > M.logsize then
		table.remove(M.logdata, 1)
	end
end

-- Print the stored log entries
M.printlog = function()
	for _, v in ipairs(M.logdata) do
		print(v)
	end
end

return M
