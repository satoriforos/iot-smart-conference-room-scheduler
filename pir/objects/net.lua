-----------------------------------------
-- Network setup
-- 
-- @author Satori Foros 2015-06
--
-- @example network = Network()
-----------------------------------------
local Network = {
	WIFI_CONNECT_TIMER = 0,
	WIFI_CONNECT_TIMEOUT = 2500,
	MAX_WIFI_TIMEOUTS = 3,
	numWifiTimeouts = 0

}
Network.__index = Network

setmetatable(Network, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})


-----------------------------------------
-- Constructor method for Network
--
-- @author Satori Foros 2015-06
-----------------------------------------
function Network.new()
  local self = setmetatable({}, Network)
  return self
end

-----------------------------------------
-- Connect to a WiFi access point
--
-- @author Michal Bicz, Satori Foros 2015-06
-- 
-- @parameter wifiSettings a table of access points, e.g. {{["accesspoint"] = "ap", ["password"] = "pass"}
-- @parameter successCallback function to run when wifi connects
-- @parameter failureCallback function to run when wifi connection fails
--
-- @example network:connectWifi({["accesspoint"] = "ap", ["password"] = "pass"}, function() print("Success") end, function() print("Fail") end)
-----------------------------------------
function Network:connectWiFi(wifiSettings, successCallback, failureCallback)
	wifi.setmode(wifi.STATION)
	if (wifiSettings["accesspoint"] and wifiSettings["password"]) then
		wifi.sta.config(wifiSettings["accesspoint"], wifiSettings["password"])
		wifi.sta.connect()

		tmr.alarm(
			self.WIFI_CONNECT_TIMER, 
			self.WIFI_CONNECT_TIMEOUT, 
			1, 
			function() 
				self:_wifiConnect_callback(successCallback, failureCallback) 
			end
		)
	else
		return false  -- FIXME: we should throw an error here
	end
end
 



-----------------------------------------
-- Handle the callback after the WiFi connect timer has expired
--
-- @author Michal Bicz, Satori Foros 2015-06
-- 
-- @parameter successCallback function to run when wifi connects
-- @parameter failureCallback function to run when wifi connection fails
-----------------------------------------
function Network:_wifiConnect_callback(successCallback, failureCallback)
	if wifi.sta.getip() then 
		tmr.stop(self.WIFI_CONNECT_TIMER)
		successCallback()
	else
		self.numWifiTimeouts = self.numWifiTimeouts + 1
		if (self.numWifiTimeouts > self.MAX_WIFI_TIMEOUTS) then
			tmr.stop(self.WIFI_CONNECT_TIMER)
			failureCallback()
		end
	end
end
 

-----------------------------------------
-- Connect the DNS Servers
--
-- @author Satori Foros 2015-06
-- 
-- @parameter dnsServers a table of DNS Servers, e.g. {"8.8.8.8", "8.8.8.4"}
-- 
-- @example network:setDNS({"8.8.8.8", "8.8.8.4"})
-----------------------------------------
function Network:setDNS(DNSServers)
  if DNSServers then
    for index, dns in pairs(DNSServers) do
      net.dns.setdnsserver(dns, index-1)
    end
  -- FIXME: should throw an error here on else
  end
end

-----------------------------------------
-- Return the mac address of the client
--
-- @author Satori Foros 2015-06
-- 
-- @example network:getMacAddress()
-----------------------------------------
function Network:getMacAddress()
	return wifi.sta.getmac()
end

return Network
