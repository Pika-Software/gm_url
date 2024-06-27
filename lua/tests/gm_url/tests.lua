local URL, decodeURIComponent
do
	local _obj_0 = include("url.yue")
	URL, decodeURIComponent = _obj_0.URL, _obj_0.decodeURIComponent
end
local urltestdata = include("urltestdata.lua")
-- First let's decode the test data
for _index_0 = 1, #urltestdata do
	local test = urltestdata[_index_0]
	if istable(test) then
		for key, value in pairs(test) do
			if isstring(value) then
				test[key] = decodeURIComponent(value)
			end
		end
	end
end
local cases = { }
for _index_0 = 1, #urltestdata do
	local test = urltestdata[_index_0]
	if isstring(test) then
		cases[#cases + 1] = {
			name = test,
			func = function() end
		}
		goto _continue_0
	end
	local prefix = (test.base and test.base ~= "about:blank") and "(" .. tostring(test.base) .. ") " or ""
	local name = tostring(prefix) .. tostring(test.input) .. " -> " .. tostring(not test.failure and test.href or "failure")
	local func
	func = function()
		local ok, url = pcall(URL, test.input, test.base)
		if test.failure then
			if ok then
				print("expected failure but got: " .. tostring(url.href))
			end
			expect(ok).to.beFalse()
			return
		end
		if not ok then
			print("failed to parse: " .. tostring(url))
			expect(ok).to.beTrue()
		end
		expect(url.protocol).to.eq(test.protocol)
		if test.password ~= "" then
			expect(url.password).to.eq(test.password)
		end
		if test.username ~= "" then
			expect(url.username).to.eq(test.username)
		end
		if test.hostname ~= "" then
			expect(url.hostname).to.eq(test.hostname)
		end
		local port = tonumber(test.port)
		if port then
			expect(url.port).to.eq(port)
		end
		expect(url.host).to.eq(test.host)
		if test.origin and test.origin ~= "null" then
			expect(url.origin).to.eq(test.origin)
		end
		if test.pathname ~= "" then
			expect(url.pathname).to.eq(test.pathname)
		end
		return
	end
	cases[#cases + 1] = {
		name = name,
		func = func
	}
	::_continue_0::
end
return {
	cases = cases,
	groupName = "gm_url whatwg-url tests"
}
