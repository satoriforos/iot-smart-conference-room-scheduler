-- WARNING: THIS CODE RUNS OUT OF RAM on NODEMCU

-- Include required objects
config     = require("config")
network    = require("objects.net")
pirdaemon = require("objects.pirdaemon")

---------------------------------
-- BOOTSTRAP PROCESS
---------------------------------
--
-- 1) Connect Network
-- 2) Set DNS servers
-- 3) Register with server
-- 4) Start Passive Infrared Sensor
-- 5) Start heartbeat with server
--
---------------------------------
gpio.write(0, gpio.LOW)

network:connectWiFi(config.WiFi, 
	function() 
		wifiConnected() 
	end, 
	function() 
		wifiFailed() 
	end
)


-----------------------------------------
-- Event: wifi was connected
-- Next: set DNS and register with server
--
-- @author Satori Foros 2015-06
-- 
-----------------------------------------
function wifiConnected()
	print("wifi connected")
	print("setting DNS")
	network:setDNS(config.DNS)
	gpio.write(0, gpio.HIGH)
	network = nil

	pirdaemon:setHttpClient(require("objects.httpclient"))
	print("registering mac address with server...")
	pirdaemon:register(
		config.serverURL, 
		config.clientID, 
		function(functionID)
			print("Registered!")
			pirRegistered(serverResponse)
		end
	)

end


-----------------------------------------
-- Event: wifi failed to connected.  
-- Next: Blink the status light three times
--
-- @author Satori Foros 2015-06
-- 
-----------------------------------------
function wifiFailed()
	print("wifi failed")
	pirdaemon:blink(1000, 3)
end

-----------------------------------------
-- Event: registered with server
-- Next: begin PIR monitoring, start heartbeat with server
--
-- @author Satori Foros 2015-06
-- 
-----------------------------------------
function pirRegistered(body)
	print("Starting PIR and heartbeat")
	pirdaemon:startPIR(config.timeouts["PIR"])
	pirdaemon:startHeartbeat(
		config.timeouts["heartbeat"], 
		config.serverURL, 
		config.clientID
	)
end
