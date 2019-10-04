conn=net.createConnection(net.TCP, 0)
    conn:on("receive", function(conn, payload) print(payload) end )
    conn:connect(80,"jsonplaceholder.typicode.com")
    conn:send("GET /posts/1 HTTP/1.1\r\nHost: jsonplaceholder.typicode.com\r\n"
        .."Connection: keep-alive\r\nAccept: */*\r\n\r\n")



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
