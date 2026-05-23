--// CHEVSTRAP LUA HUB V2
--// Salva Config + FFlags
--// Copy JSON igual Chevstrap

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local CONFIG_FILE = "ChevstrapConfig.json"
local FLAGS_FILE = "ChevstrapFlags.json"

-- CONFIG
local Config = {
	TextureQuality = "Mid",
	GraySky = false,
	NoShadows = false,
	NoGrass = false,
	LowRendering = false
}

-- FLAGS
local SavedFlags = {
	FIntTaskSchedulerTargetFps = 999,
	DFIntTextureQualityOverride = 1,
	FIntDebugForceMSAASamples = 0
}

-- LOAD CONFIG
if isfile and isfile(CONFIG_FILE) then
	local success,data = pcall(function()
		return HttpService:JSONDecode(readfile(CONFIG_FILE))
	end)

	if success and data then
		for i,v in pairs(data) do
			Config[i] = v
		end
	end
end

-- LOAD FLAGS
if isfile and isfile(FLAGS_FILE) then
	local success,data = pcall(function()
		return HttpService:JSONDecode(readfile(FLAGS_FILE))
	end)

	if success and data then
		SavedFlags = data
	end
end

-- SAVE
local function SaveConfig()
	if writefile then
		writefile(CONFIG_FILE,HttpService:JSONEncode(Config))
	end
end

local function SaveFlags()
	if writefile then
		writefile(FLAGS_FILE,HttpService:JSONEncode(SavedFlags))
	end
end

-- APPLY FLAGS
local function ApplySavedFlags()
	for flag,value in pairs(SavedFlags) do
		pcall(function()
			setfflag(flag,tostring(value))
		end)
	end

	if SavedFlags.FIntTaskSchedulerTargetFps and setfpscap then
		setfpscap(SavedFlags.FIntTaskSchedulerTargetFps)
	end
end

-- TEXTURE
local function ApplyTexture(mode)
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("Texture") or v:IsA("Decal") then

			if mode == "Lowest" then
				v.Transparency = 1

			elseif mode == "Low" then
				v.Transparency = 0.7

			elseif mode == "Mid" then
				v.Transparency = 0.3

			elseif mode == "High" then
				v.Transparency = 0
			end
		end
	end
end

-- APPLY CONFIG
local function ApplySettings()

	Lighting.GlobalShadows = not Config.NoShadows

	if Terrain then
		Terrain.Decoration = not Config.NoGrass
	end

	if Config.GraySky then

		Lighting.ClockTime = 14
		Lighting.FogColor = Color3.fromRGB(120,120,120)
		Lighting.OutdoorAmbient = Color3.fromRGB(150,150,150)

		local sky = Lighting:FindFirstChildOfClass("Sky")

		if sky then
			sky:Destroy()
		end
	end

	if Config.LowRendering then
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	end

	ApplyTexture(Config.TextureQuality)
end

ApplySettings()
ApplySavedFlags()

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ChevstrapLua"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

-- TOP BAR
local TopBar = Instance.new("Frame")
TopBar.Parent = gui
TopBar.Size = UDim2.new(0,430,0,35)
TopBar.Position = UDim2.new(0.5,-215,0,70)
TopBar.BackgroundColor3 = Color3.fromRGB(15,15,15)
TopBar.BorderSizePixel = 0

Instance.new("UICorner",TopBar).CornerRadius = UDim.new(0,8)

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1,-80,1,0)
Title.Text = "Chevstrap Lua"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.new(1,1,1)

-- BUTTONS
local MinBtn = Instance.new("TextButton")
MinBtn.Parent = TopBar
MinBtn.Size = UDim2.new(0,35,1,0)
MinBtn.Position = UDim2.new(1,-70,0,0)
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
MinBtn.TextColor3 = Color3.new(1,1,1)

local MaxBtn = Instance.new("TextButton")
MaxBtn.Parent = TopBar
MaxBtn.Size = UDim2.new(0,35,1,0)
MaxBtn.Position = UDim2.new(1,-35,0,0)
MaxBtn.Text = "+"
MaxBtn.Font = Enum.Font.GothamBold
MaxBtn.TextSize = 18
MaxBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
MaxBtn.TextColor3 = Color3.new(1,1,1)

-- MAIN
local Main = Instance.new("ScrollingFrame")
Main.Parent = gui
Main.Size = UDim2.new(0,430,0,420)
Main.Position = UDim2.new(0.5,-215,0,110)
Main.CanvasSize = UDim2.new(0,0,0,900)
Main.ScrollBarThickness = 4
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.BorderSizePixel = 0

Instance.new("UICorner",Main).CornerRadius = UDim.new(0,8)

local Layout = Instance.new("UIListLayout",Main)
Layout.Padding = UDim.new(0,8)

-- CREATE BUTTON
local function CreateButton(text,callback)

	local Btn = Instance.new("TextButton")
	Btn.Parent = Main
	Btn.Size = UDim2.new(1,-10,0,40)
	Btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
	Btn.TextColor3 = Color3.new(1,1,1)
	Btn.Font = Enum.Font.GothamBold
	Btn.TextSize = 15
	Btn.Text = text

	Instance.new("UICorner",Btn).CornerRadius = UDim.new(0,6)

	Btn.MouseButton1Click:Connect(callback)
end

-- TEXTURES
CreateButton("Texture Lowest",function()
	Config.TextureQuality = "Lowest"
	ApplySettings()
	SaveConfig()
end)

CreateButton("Texture Low",function()
	Config.TextureQuality = "Low"
	ApplySettings()
	SaveConfig()
end)

CreateButton("Texture Mid",function()
	Config.TextureQuality = "Mid"
	ApplySettings()
	SaveConfig()
end)

CreateButton("Texture High",function()
	Config.TextureQuality = "High"
	ApplySettings()
	SaveConfig()
end)

-- VISUAL
CreateButton("Toggle Gray Sky",function()
	Config.GraySky = not Config.GraySky
	ApplySettings()
	SaveConfig()
end)

CreateButton("Toggle No Shadows",function()
	Config.NoShadows = not Config.NoShadows
	ApplySettings()
	SaveConfig()
end)

CreateButton("Toggle Remove Grass",function()
	Config.NoGrass = not Config.NoGrass
	ApplySettings()
	SaveConfig()
end)

CreateButton("Toggle Low Rendering",function()
	Config.LowRendering = not Config.LowRendering
	ApplySettings()
	SaveConfig()
end)

-- FLAGS
CreateButton("FPS UNLOCK",function()
	SavedFlags.FIntTaskSchedulerTargetFps = 999
	ApplySavedFlags()
	SaveFlags()
end)

CreateButton("FPS 60",function()
	SavedFlags.FIntTaskSchedulerTargetFps = 60
	ApplySavedFlags()
	SaveFlags()
end)

CreateButton("MSAA OFF",function()
	SavedFlags.FIntDebugForceMSAASamples = 0
	ApplySavedFlags()
	SaveFlags()
end)

CreateButton("Texture Flag Lowest",function()
	SavedFlags.DFIntTextureQualityOverride = 0
	ApplySavedFlags()
	SaveFlags()
end)

CreateButton("Texture Flag High",function()
	SavedFlags.DFIntTextureQualityOverride = 3
	ApplySavedFlags()
	SaveFlags()
end)

-- COPY FLAGS
CreateButton("Copy Flags JSON",function()

	local json = HttpService:JSONEncode(SavedFlags)

	if setclipboard then
		setclipboard(json)
	end
end)

-- MINIMIZE
local minimized = false

MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	Main.Visible = not minimized
end)

MaxBtn.MouseButton1Click:Connect(function()
	Main.Visible = true
	minimized = false
end)

-- DRAG
local dragging = false
local dragInput
local dragStart
local startPos

TopBar.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = true
		dragStart = input.Position
		startPos = TopBar.Position

		input.Changed:Connect(function()

			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

TopBar.InputChanged:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if input == dragInput and dragging then

		local delta = input.Position - dragStart

		TopBar.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)

		Main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y + 40
		)
	end
end)
