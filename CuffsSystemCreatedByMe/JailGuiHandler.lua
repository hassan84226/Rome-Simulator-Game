local player = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local ef = rs:WaitForChild("Events")
local vars = require(rs:WaitForChild("Modules"):WaitForChild("VarModule"))



local check = ef:WaitForChild("JailTimeCheck"):InvokeServer()

local jt = check[1]
local charge = check[2]

script.Parent.JailTime.Text = "Time left to serve: "..jt
script.Parent.Info.Text = "You have been sent to jail for "..charge

script.Parent.BailR.MouseButton1Click:connect(function()
	ef:WaitForChild("PromptMarket"):FireServer("Bail")
end)



for i=1,jt do
	
	script.Parent.JailTime.Text = "Time left to serve: "..jt-i
	if i == jt then
		script.Parent.Parent:Destroy()
	end
	wait(1)
end