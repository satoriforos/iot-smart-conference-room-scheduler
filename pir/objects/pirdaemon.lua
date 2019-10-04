
-----------------------------------------
-- the PIR Daemon
-- polls the Passive Infrared Sensor for activity
-- and sends results to server
-- 
-- @author Satori Foros 2015-06
-- @example pir = PIRDaemon()
-----------------------------------------

local PIRDaemon = {
	PIR_TIMER = 1,  -- the alarm ID of the PIR timer
	HTTP_TIMER = 2, -- the alarm ID of the HTTP timer
	PIR_PIN = 0, -- the pin associated with the PIR
	LIGHT_PIN = 0,
	PIR_READING_THRESHOLD = 100, -- adc reading gerater than this number triggers motion
	PIR_MIN_TIMEOUT = 100,
	HTTP_MIN_TIMEOUT = 100,
	motionDetected = false,
	httpclient = nil,
	registered = false
}
PIRDaemon.__index = PIRDaemon

setmetatable(PIRDaemon, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

-----------------------------------------
-- Constructor method for PIRDaemon
--
-- @author Satori Foros 2015-06
-----------------------------------------
function PIRDaemon.new()
  local self = setmetatable({}, PIRDaemon)
  return self
end


-----------------------------------------
-- Load a HTTPClient
-- 
-- @author Satori Foros 2015-06
-- 
-- @param HttpClient an HTTPClient
--
-- @example pir:blink(HttpClient())
-----------------------------------------
function PIRDaemon:setHttpClient(httpClient)
	self.httpclient = httpClient
end

-----------------------------------------
-- Blink the status light
-- 
-- @author Satori Foros 2015-06
-- 
-- @param timout how long to wait between blinks in milliseconds
-- @param numRepeats the number of times to blink the light
--
-- @example pir:blink(1000, 3)
-----------------------------------------
function PIRDaemon:blink(timeout, numRepeats)
    gpio.write(self.LIGHT_PIN, gpio.LOW)
    tmr.delay(timeout)
    while (numRepeats > 0) do
    	gpio.write(self.LIGHT_PIN, gpio.HIGH)
    	tmr.delay(timeout)
    	gpio.write(self.LIGHT_PIN, gpio.LOW)
    	tmr.delay(timeout)
     	numRepeats = numRepeats - 1
    end
    gpio.write(self.LIGHT_PIN, gpio.HIGH)
end

-----------------------------------------
-- Start communicating with the server
-- 
-- @author Satori Foros 2015-06
-- 
-- @param timout milliseconds the how often poll the PIR_PIN
--
-- @example pir:startPIR(1000)
-----------------------------------------
function PIRDaemon:startPIR(timeout)
	reading = 0
	if (not type(timeout) == "number") or (timeout < self.PIR_MIN_TIMEOUT) then 
		timeout = self.PIR_MIN_TIMEOUT 
	end
	tmr.alarm(
		self.PIR_TIMER, 
		timeout, 
		1, 
		function()
			reading = adc.read(self.PIR_PIN)
			if (reading > self.PIR_READING_THRESHOLD) then
				-- only notify on change
				if (self.motionDetected == false) then
					print("Motion detected")
				end
				self.motionDetected = true
			end
		end 
	)
end



-----------------------------------------
-- Stop polling the PIR
-- 
-- @author Satori Foros 2015-06
-----------------------------------------
function PIRDaemon:stopPIR()
	tmr.stop(self.PIR_TIMER)
end

-----------------------------------------
-- Register this client with the server
--
-- @author Satori Foros 2015-06
--
-- @param serverURL the url of the Server
-- @param clientID a unique identifier for this client (probably the MAC address)
-- @param callbackFunction a callback function to be run when the registration completes.  e.g. callbackFunction(responseBody)
-- 
-- @example: pir:register('http://example.com', 'aa:bb:cc:dd:ee:ff:11:22:33', function(responseBody) print(responseBody) end)
-----------------------------------------
function PIRDaemon:register(serverURL, clientID, callbackFunction)
	-- POST /sensors/MACADDRESS
	serverURI = serverURL..'/sensors/'..clientID
	self.httpclient:attachEvent(
		--[[
		function(functionID, headers, body) 
			self.registered = true
			callbackFunction(functionID, headers, body)
		end
		]]
		-- we save memory by not parsing headers in httpclient
		function(functionID) 
			self.registered = true
			callbackFunction(functionID)
		end
	)
	self.httpclient:post(serverURI, "")
end


-----------------------------------------
-- Start communicating the motion sensor status with the server
-- at regular intervals.  You must first register the PIR with register()
--
-- @author Satori Foros 2015-06
--
-- @param timout milliseconds the how often to contact the server
-- @param serverURL the url of the Server
-- @param clientID the uniqu identifier for this client (probably the MAC address)
--
-- @example pir:startHeartbeat(1000, 'http://example.com', 'aa:bb:cc:dd:ee:ff:11:22:33')
-----------------------------------------
function PIRDaemon:startHeartbeat(timeout, serverURL, clientID)
	if (not type(timeout) == "number") or (timeout < self.HTTP_MIN_TIMEOUT) then 
		timeout = self.HTTP_MIN_TIMEOUT 
	end
	tmr.alarm(
		self.HTTP_TIMER, 
		timeout, 
		1, 
		function()
			-- PUT /sensors/MACADDRESS
			-- motion=true/false
			serverURI = serverURL..'/sensors/'..clientID
			postData = {["motion"] = tostring(self.motionDetected)}

			self.httpclient:attachEvent(
				function(functionID)
					self.motionDetected = false
				end
			)
			self.httpclient:put(serverURI, cjson.encode(postData))
		end 
	)
end


-----------------------------------------
-- Stop communicating with the server
-- 
-- @author Satori Foros 2015-06
--
-- @example: pir:stopHeartbeat()
-----------------------------------------
function PIRDaemon:stopHeartbeat()
	tmr.stop(self.HTTP_TIMER)
end

return PIRDaemon
