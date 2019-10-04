
-- set power pin to on
gpio.write(0, gpio.HIGH)

abort = false

-- give a 5 second timeout before starting init, in case there's a bug
-- https://bigdanzblog.wordpress.com/2015/04/24/esp8266-nodemcu-interrupting-init-lua-during-boot/
function abortInit()
    -- initailize abort boolean flag
    abort = false
    print('Press ENTER to abort startup')
    -- if <CR> is pressed, call abortTest
    uart.on(
    	'data',
    	1, 
    	function(data)
    		print("setting abort to TRUE")
    		abort = true
    		uart.on("data")
    	end, 
    	0
    )
    -- start timer to execute startup function in 5 seconds
    tmr.alarm(
    	0,
    	5000,
    	0,
    	function()
    		uart.on("data")
    		if (abort == true) then
    			print("startup aborted")
    		else
    			print("startup normally")
    		end
    	end
    )
end

tmr.alarm(0,1000,0,abortInit)           -- call abortInit after 1s