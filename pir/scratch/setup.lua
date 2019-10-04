local module = {}

function module.blink()
    time = 1000000
    gpio.write(0, gpio.HIGH)
    tmr.delay(time)
    gpio.write(0, gpio.LOW)
    tmr.delay(time)
    gpio.write(0, gpio.HIGH)
    tmr.delay(time)
 end

local function wifi_wait_ip()
  if wifi.sta.getip() then 
    tmr.stop(1)
    print("wifi ready: " .. wifi.sta.getip())
    set_dns()
    app.start()
  else
    tmr.stop(1)
    print("wifi not ready!")
    module.blink()
  end
end
 
local function wifi_start(aps)
  for key,value in pairs(aps) do
    print("wifi AP: " .. key .. ": " .. value)
    if config.SSID and config.SSID[key] then
      wifi.sta.config(key, config.SSID[key])
      wifi.sta.connect()
      config.SSID = nil  -- more secure and save memory
      tmr.alarm(1, 2500, 1, wifi_wait_ip)
      break
    else
      print("Configuration not found!")
    end
  end
end
 
function module.start()
  if wifi.sta.getip() then
    print("got IP, not reconfiguring")
    app.start()
  else
    print("no IP, configuring")
     wifi.setmode(wifi.STATION);
    wifi.sta.getap(wifi_start)
  end
  
end

local function set_dns()
  if config.DNS then
    for index, dns in pairs(config.DNS) do
      net.dns.setdnsserver(dns, index)
    end
  end
end
 
return module