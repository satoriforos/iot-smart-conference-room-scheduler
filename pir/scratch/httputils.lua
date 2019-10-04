-----------------------------------------
-- HTTP Utilities
-- 
-- @author Satori Foros 2015-06
-- @example require("httputils").urlEncode("hello world")
-----------------------------------------
local HttpUtils = {}

-----------------------------------------
-- URL-encode strings
-- 
-- @author Satori Foros 2015-06
-- @source: http://lua-users.org/wiki/StringRecipes
-- 
-- @parameter text to be encoded. e.g. "hello world"
-- @return URL encoded text, e.g. "hello+world"
--
-- @example encodedText = httputils:urlEncode("hello world")
-----------------------------------------
function HttpUtils:urlEncode(text)
	if (not type(text) == "string") then text = tostring(text) end
	text = string.gsub(text, "\n", "\r\n")
	text = string.gsub(text, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
	text = string.gsub(text, " ", "+")
	return text
end

-----------------------------------------
-- URL-decode strings
-- 
-- @author Satori Foros 2015-06
-- @source: http://lua-users.org/wiki/StringRecipes
-- 
-- @parameter text to be decoded. e.g. "hello+world"
-- @return plain text, e.g. "hello world"
--
-- @example: text = httputils:urlDecode("hello+world")
-----------------------------------------
--[[
function HttpUtils:urlDecode(text)
	if (not type(text) == "string") then text = tostring(text) end
	text = string.gsub (text, "+", " ")
	text = string.gsub (text, "%%(%x%x)",
		function(h) return string.char(tonumber(h,16)) end)
	text = string.gsub (text, "\r\n", "\n")
	return text
end
]]


-----------------------------------------
-- Split HTTP headers into a table
-- 
-- @author Satori Foros 2015-06
-- 
-- @parameter text to be decoded. e.g. "Accept: */*\r\nConnection: keep-alive"
-- @return table, e.g. "{["Accept"] = "*/*", ["Connection"] = "keep-alive"}
--
-- @example: headers = httputils:parseHeaders("Accept: */*\r\nConnection: keep-alive")
-----------------------------------------
function HttpUtils:parseHeaders(text)
	local newValueToken = "\r\n"
	local pairToken = ": "
	headers = self:_parseTwoDimensionalArray(text, newValueToken, pairToken)
	return headers
end

-----------------------------------------
-- Split URL Query strings into a table,
-- and url-decode them into text
-- 
-- @author Satori Foros 2015-06
-- 
-- @parameter text to be decoded. e.g. "one+thing=another,but+more=stuff"
-- @return table, e.g. "{["one thing"] = "another", ["but more"] = "stuff"}
--
-- @example: queryValues = httputils:parseHeaders("one+thing=another,but+more=stuff")
-----------------------------------------
--[[
function HttpUtils:parseQueryString = function(text)
	local newValueToken = "\r\n"
	local pairToken = ": "
	tempValues = self:_parseTwoDimensionalArray(text, newValueToken, pairToken)

	values = {}
	for key, value in pairs(tempValues) do
		values[self:urlDecode(key)] = self:urlDecode(value)
	end
	return values
end
]]

-----------------------------------------
-- Parse strings that represent data into tables,
-- used for both parseHeaders and parseQueryString
-- 
-- @author Satori Foros 2015-06
-- 
-- @parameter text to be decoded. e.g. "one+thing=another,but+more=stuff"
-- @return table, e.g. "{["one thing"] = "another", ["but more"] = "stuff"}
-----------------------------------------
function HttpUtils:_parseTwoDimensionalArray(text, newValueToken, pairToken)
	data = {}
	if (text == nil) then return data end
	local valuePairs = require("objects.string").explode(text, newValueToken)
	for k,valuePair in pairs(valuePairs) do
		key, value = require("objects.string").split(valuePair, pairToken)
		data[key] = value
	end
	return value
end


return HttpUtils
