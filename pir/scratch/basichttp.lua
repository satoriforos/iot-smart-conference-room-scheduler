conn=net.createConnection(net.TCP, 0);
conn:on("receive", function(conn, payload) print(payload) end );
conn:connect(80,"jsonplaceholder.typicode.com");
conn:send("GET /posts/1 HTTP/1.1\r\nHost: jsonplaceholder.typicode.com\r\nConnection: keep-alive\r\nAccept: */*\r\n\r\n")



wifi.setmode(wifi.STATION);
wifi.sta.config("example","password");
net.dns.setdnsserver("8.8.8.8");
httpclient = require("objects/httpclient");
httpclient:get("http://jsonplaceholder.typicode.com/posts/1")


conn=net.createConnection(net.TCP, false) 
conn:on("receive", function(conn, pl) print(pl) end)
conn:connect(80,"yahoo.com")
conn:send("GET / HTTP/1.1\r\nHost: www.nodemcu.com\r\nConnection: keep-alive\r\nAccept: */*\r\n\r\n")


httpbody = [[
HTTP/1.0 200 OK
Content-Type: application/json
Content-Length: 5
Server: Werkzeug/0.10.4 Python/2.7.6
Date: Thu, 09 Jul 2015 02:22:34 GMT
 
]]

mac = wifi.ap.getmac()
server = {
	"address" = "10.164.121.159",
	"port" = 5000
}
conn=net.createConnection(net.TCP, 0)
conn:on("receive", function(conn, payload) print(payload) end )
conn:connect(server["port"], server["address"])
conn:send("POST /sensors/"..mac.." HTTP/1.1\r\nHost: example.com\r\nConnection: keep-alive\r\nAccept: */*\r\n\r\n")
