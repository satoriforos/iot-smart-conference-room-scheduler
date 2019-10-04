local module = {}
-----------------------------------------
-- Register the MAC address with the server
--
-- @author Michal Bicz 2015-06
-----------------------------------------
local function module.report()
  local protocol = "http"
  local mac = wifi.sta.getmac()
  local host = "172.16.32.100"
  local path = "/sensors/"..mac
  local port = 5000
  local method = 'PUT'
  local http_ver = 'HTTP/1.1'
  local motion = true
  
  conn = net.createConnection(net.TCP, 0)
  conn:on("receive", function(sck, c) print(c) end )
  conn:connect(port, host) 
  print("Hitting "..host)
  conn:send(method.." "..path.." "..http_ver.."\r\n")
  conn:send("Host: "..host..":"..port.."\r\n")
  conn:send("Accept: */*\r\n")
  conn:send("Content-Length: 11\r\n")
  conn:send("Content-Type: application/x-www-form-urlencoded\r\n\r\n")
  conn:send("motion="..tostring(motion).."\r\n")

end

-----------------------------------------
-- Send a heartbeat to the server
--
-- @author Michal Bicz 2015-06
-----------------------------------------
local function start()
  print("application start")
  current_ip = wifi.sta.getip()
  print("IP address: " .. wifi.sta.getip())
  -- dofile("server.lua")
  tmr.alarm(2, 5000, 1, module.report)
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

 
return module

