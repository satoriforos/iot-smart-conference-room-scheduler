local module = {}
 
module.WiFi = { ["accesspoint"] = "", ["password"] = "" }
module.DNS = {
	"8.8.8.8",
	"8.8.8.4"
}
module.serverURL = "http://example.com"
module.timeouts = {
	["PIR"] = 1000,
	["heartbeat"] = 5000
}
module.clientID = wifi.sta.getmac()

return module