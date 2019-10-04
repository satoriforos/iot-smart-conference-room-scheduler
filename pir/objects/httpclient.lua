
-----------------------------------------
-- A simple HTTP Client
-- supports HTTP/1.1 GET and POST
-- 
-- @author Satori Foros 2015-06
-- @example h = HttpClient()
-----------------------------------------

local HttpClient = {
	events = {}, -- how to handle responses
	headers = {
		["Host"] = "",
		["Connection"] = "keep-alive",
		["Accept"] = "*/*"
	},
}
HttpClient.__index = HttpClient

setmetatable(HttpClient, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

-----------------------------------------
-- Constructor method for HttpClient
-- @author Satori Foros 2015-06
-----------------------------------------
function HttpClient:new()
  local self = setmetatable({}, HttpClient)
  return self
end

-----------------------------------------
-- Internal function to perform a Http Request
-- 
-- @author Satori Foros 2015-06
-- 
-- @parameter url URL String, e.g. "http://example.com/test.htm"
-- @parameter method the method, e.g. "POST", "GET", or "PULL"
-- @parameter body string or table e.g. 'a=1&b=2' or "{a:1, b:2}" or {["a"]=1,["b"]=2}
-- 
-- @example h:request("http://example.com/test.htm", PUT, "a=1&b=2")
-- @example h:request("http://example.com:8080/test.htm", POST, "a=1&b=2")
-----------------------------------------
function HttpClient:_request(url, method, body)
	print("HTTP/1.1 "..method.." "..url)
	isSSL = false
	payload = ""
	newLine = "\r\n"

	-- for now assume the payload is json and doesn't need to be formatted
	--[[
	if (type(postData) == "table") then
		payload = ""
		delimeter = "&"
		counter = 0
		for key, value in pairs(postData) do
			key = require("objects.httputils"):urlEncode(key)
			value = require("objects.httputils"):urlEncode(value)
			if (counter > 0) then payload = payload .. delimeter end
			payload = payload .. key .. '=' .. value
			counter = counter + 1
		end
	end
	]]


	-- get the query string
	protocol, request = require("objects.string").split(url, "://")

	-- find the query path
	domain, path = require("objects.string").split(request, "/")
	if path == nil then path = "" end

	-- parse out the port if possible
	domain, port = require("objects.string").split(domain, ":")
	if port == nil then
	--if (not type(port) == "number") then
		if (protocol == "https") then
			port = 443
			isSSL = true
		else
			port = 80
		end
	end 

	--[[
	print("protocol: "..protocol)
	print("domain: "..domain)
	print("port: "..port)
	print("path: "..path)
	]]


	-- build HTTP header payload
	self.headers["Host"] = domain
	headers = method.." /"..path.." HTTP/1.1" .. newLine
	for key,value in pairs(self.headers) do
		headers = headers .. key .. ": " .. value .. newLine
	end
	headers = headers .. newLine

	payload = headers


	-- build body payload if needed
	if (type(body) == "string" and body:len() >0) then
		payload = payload .. body
	end

	-- only execute this on nodemcu
	if (type(node) == "romtable") then
		
		socket = net.createConnection(net.TCP, isSSL)

		socket:on("disconnection", function(socket) print("Disconnected") end)
		socket:on("receive", 
			function(socket, serverResponse)
				socket:close()
				print("received response")
				
				if self.events then
					for functionID, functionName in pairs(self.events) do
						functionName(functionID)
					end
				end

			end 
		)
		socket:on("connection", 
			function(socket) 
				print("connected")
				socket:send(payload)
			end
		)
		socket:connect(port, domain)

		socket = nil

	end
end


-----------------------------------------
-- Perform an HTTP GET,
-- store headers into self.responseHeaders
-- store body into self.responseBody
-- 
-- @author Satori Foros 2015-06
--
-- @parameter url URL String, e.g.  http://example.com/test.htm
-- 
-- @return nil
-- 
-- @example h:get("http://example.com/test.htm")
-----------------------------------------
function HttpClient:get(url)
	response = self:_request(url, "GET", "")
	return response
end


-----------------------------------------
-- Perform an HTTP PUT with query data.
-- this query data can be formatted as a string, such as
-- a query string or JSON, or plain text, or can
-- be formatted as a LUA table,
-- 
-- @author Satori Foros 2015-06
-- 
-- @parameter url URL String, e.g. "http://example.com/test.htm"
-- @parameter body JSON string or preformatted URL query eg '{["a"] = 1, ["b"] = 2}' or 'a=1&b=2&c=3'
-- 
-- @example h:put("http://example.com/test.htm","a=1&b=2&c=3")
-- @example h:put("http://example.com/test.htm","{a:1,b:2}")
-- @example h:put("http://example.com/test.htm", {["a"] = 1, ["b"] = 2})
-----------------------------------------
function HttpClient:put(url, postData)
	response = self:_request(url, "PUT", postData)
end

-----------------------------------------
-- Perform an HTTP POST with query data.
-- this query data can be formatted as a string, such as
-- a query string or JSON, or plain text, or can
-- be formatted as a LUA table,
-- 
-- @author Satori Foros 2015-06
-- 
-- @parameter url URL String, e.g. "http://example.com/test.htm"
-- @parameter body JSON string or preformatted URL query eg '{["a"] = 1, ["b"] = 2}' or 'a=1&b=2&c=3'
-- 
-- @example h:put("http://example.com/test.htm","a=1&b=2&c=3")
-- @example h:put("http://example.com/test.htm","{a:1,b:2}")
-- @example h:put("http://example.com/test.htm", {["a"] = 1, ["b"] = 2})
-----------------------------------------
function HttpClient:post(url, postData)
	response = self:_request(url, "POST", postData)
end



-----------------------------------------
-- Attach an event to be triggered 
-- when a HTTP request happens
-- 
-- @author Satori Foros 2015-06
-- 
-- @parameter function a function to be executed eg function(functionID, header, body) print(body) end
-- @return functionID, e.g. 0
-----------------------------------------
function HttpClient:attachEvent(functionName)
	local tableIndex = #self.events+1
	functionID = 0
	if not tableIndex == nil then
		functionID = tableIndex + 1
	end
	self.events[functionID] = functionName
	return functionID
end


-----------------------------------------
-- Detach an event where the functionID is known
-- 
-- @author Satori Foros 2015-06
-- 
-- @parameter functionID, e.g. 0
-- @return function if found, false otherwise
-----------------------------------------
function HttpClient:detachEvent(functionID)
	result = false
	if self.events[functionID] then
		result = self.events[functionID]
		table.remove(self.events, functionID)
	end
	return result
end

-----------------------------------------
-- Clear all events
-- 
-- @author Satori Foros 2015-06
-----------------------------------------
function HttpClient:clearEvents()
	self.events = {}
end

return HttpClient
