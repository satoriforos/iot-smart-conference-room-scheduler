config = require("config")
network = require("objects.net")
--httpclient = require("objects.httpclient")
url = 'http://example.com'


network:connectWiFi(
	config.WiFi,
	function()
		print("WiFi Connected")
		network.setDNS(config.DNS)
		httpget();
	end,
	function()
		print("No WiFi")
	end
)

function httpget()
	print("executing http get")
	--[[
	httpclient:attachEvent(
		function(functionID, headers, body) 
			print(functionID, headers, body)
		end
	)
	httpclient:get(url)
	]]
		domain = "example.com"
		port = 80
		payload = "GET /posts/1 HTTP/1.1\r\nHost: jsonplaceholder.typicode.com\r\nConnection: keep-alive\r\nAccept: */*\r\n\r\n"
		socket = net.createConnection(net.TCP, false)
		socket:on("connection", 
			function(socket) 
				print("Connected to "..domain..":"..port) 
				print("----- Sending to Server:-----")
				print("-----------------------------")
				print(payload)
				print("-----------------------------")
	
				socket:send(payload)
			end 
		)
		socket:on("receive", 
			function(socket, serverResponse)
				socket:close()
				--[[
				print("----- Received from Server -----")
				print("--------------------------------")
				print(serverResponse)
				print("--------------------------------")

				print("---- Executing Callbacks ----")
				]]
				print("received response")
				-- we save memory by not parsing headers
				--headers, body = require("objects.string").split(serverResponse, "\r\n\r\n")
				if self.events then
					for functionID, functionName in pairs(self.events) do
						--functionName(functionID, headers, body)
						functionName(functionID)
					end
				end
				

			end 
		)
		socket:on("disconnection", 
			function(socket) 
				print("Disconnected") 
			end 
		)

		print("Connecting to "..domain..":"..port) 
		socket:connect(port, domain)
	

end


-- for f,v in pairs(file.list()) do print(f) end

--[[
wifi.setmode(wifi.STATION);
wifi.sta.config("example","password")
net.dns.setdnsserver("8.8.8.8")
]]
--[[
httpclient = require("objects.httpclient")
httpclient:attachEvent(function(functionID, header, body) print(body) end)
url = "http://yahoo.com"
httpclient:get(url)
]]

-- print(cjson.encode({["key"]="value"}))
--[[ 
h,b = require("objects.string").split(httpbody, "\n\n")
print('"'..h..'"')
]]


--[[
local thing = {
	events = {},

	attachEvent = function(self, functionName)
		functionID = #self.events+1
		self.events[functionID] = functionName
		return functionID
	end
}

functionID = thing:attachEvent(function(index) print(index..": Hello") end)
functionID = thing:attachEvent(function(index) print(index..": There") end)
functionID = thing:attachEvent(function(index) print(index..": World") end)


for k,v in pairs(thing.events) do
	v(k)
--	print(k,v)

end
]]














		socket = net.createConnection(net.TCP, isSSL)
		socket:on("connection", 
			function(socket) 
				print("Connected to "..domain..":"..port) 
				print("----- Sending to Server:-----")
				print("-----------------------------")
				print(payload)
				print("-----------------------------")
	
				socket:send(payload)
			end 
		)
		socket:on("receive", 
			function(socket, serverResponse)
				socket:close()
				--[[
				print("----- Received from Server -----")
				print("--------------------------------")
				print(serverResponse)
				print("--------------------------------")

				print("---- Executing Callbacks ----")
				]]
				print("received response")
				-- we save memory by not parsing headers
				--headers, body = require("objects.string").split(serverResponse, "\r\n\r\n")
				if self.events then
					for functionID, functionName in pairs(self.events) do
						--functionName(functionID, headers, body)
						functionName(functionID)
					end
				end
				

			end 
		)
		socket:on("disconnection", 
			function(socket) 
				print("Disconnected") 
			end 
		)

		print("Connecting to "..domain..":"..port) 
		socket:connect(port, domain)


	
	else -- execute in lua shell
		serverResponse = [[
HTTP/1.0 200 OK\r
Content-Type: application/json\r
Content-Length: 5\r
Server: Werkzeug/0.10.4 Python/2.7.6\r
Date: Thu, 09 Jul 2015 02:22:34 GMT\r
\r
]]
		self:_httpResponse_callback(server, serverResponse)
	end
	
