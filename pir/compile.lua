files = {
	"objects/httpclient",
	"objects/net",
	"objects/pirdaemon",
	"objects/string",
	"config",
	"pircontroller"
}

for k,v in pairs(files) do
	if (file.open(v..'.lua')) then
		print("Compiling "..v..'.lua')
		file.remove(v..'.lc')
		node.compile(v..'.lua')
		file.remove(v..'.lua')
	else 
		print(v..'.lc already compiled')
	end
end

files = nil

print("Restarting...")
node.restart()