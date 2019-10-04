-- by separating things into a separate file
-- we can test the program without running it init.lua 
if (file.open("pircontroller.lc","r") == nil) then
	print("pircontroller.lc not found")
	print("you may have to compile it by typing 'dofile('compile.lua')")
else
	dofile("pircontroller.lc")
end