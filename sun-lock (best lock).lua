--[[

░██████╗██╗░░░██╗███╗░░██╗
██╔════╝██║░░░██║████╗░██║
╚█████╗░██║░░░██║██╔██╗██║
░╚═══██╗██║░░░██║██║╚████║
██████╔╝╚██████╔╝██║░╚███║
╚═════╝░░╚═════╝░╚═╝░░╚══╝                                            
]]
local plr = game.Players.LocalPlayer
local Char = script.Parent
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local boom = Instance.new("Part")

local Key = 'P'
local Debounce = true

UIS.InputBegan:Connect(function(Input, IsTyping)
 if IsTyping then return end
 if Input.KeyCode == Enum.KeyCode[Key] and Debounce then
  Debounce = false
  boom.Shape = "Ball"
  local TweenService = game:GetService("TweenService")

local Plrs = game:GetService('Players')
local MyPlr = Plrs.LocalPlayer
repeat
	wait()
until MyPlr.Character ~= nil
local MyChar = MyPlr.Character
local MyGui = game:GetService('CoreGui')
local RunS = game:GetService('RunService')
local Teams = game:GetService('Teams')
local C = workspace.CurrentCamera
repeat
	RunS.RenderStepped:wait()
until C.ViewportSize.X > 0 and C.ViewportSize.Y > 0


local Settings = {
	KeyCodeToToggle = 285, 
	KeyCodeToScrollRight = 275, 
	KeyCodeToScrollLeft = 276,
	ColorCodes = {
		Enemy = Color3.new(1, 0, 0), 
		Ally = Color3.new(0, 1, 0), 
	},
	ShowTracers = true,
	TracerOptions = {
		ShowEnemies = true, 
		ShowAllies = true,
	},
	ShowESP = true,
	ESPOptions = {
		ShowEnemies = true,
		ShowAllies = true,
		ShowHealth = true,
		ShowName = true,
		ShowDistance = true,
	},
	PlayerESPCrap = {},
	PlayerCrap = {},
	FakeCrap = {},
}
local CC = Settings.ColorCodes
local TO = Settings.TracerOptions
local ESPO = Settings.ESPOptions
local PESPC = Settings.PlayerESPCrap
local PC = Settings.PlayerCrap

local DONT_IGNORE = {
	"Head",
	"Torso",
	"HumanoidRootPart",
	"Left Arm",
	"Right Arm",
	"Left Leg",
	"Right Leg",
}

function CheckNameToDontIgnore(Str)
	for i, v in pairs(DONT_IGNORE) do
		if (Str == v) then
			return true
		end
	end
	
	return false
end

local Called = 0
function AddShitToIgnoreList(Par)
	Called = Called + 1
	local Hint = Instance.new("Hint", workspace)
	Hint.Text = "Called: " .. Called
	-- Don't judge...
	print("Preparing ESP...")
	print("This could take a while...")
	wait(5)
	local function ScanEverything(Par)
		for i, v in pairs(Par:GetChildren()) do
			if not (CheckNameToDontIgnore(v.Name)) then
				table.insert(Settings.FakeCrap, v)
				print("Added " .. v.Name)
				v.ChildAdded:connect(function(EEEE)
					ScanEverything(EEEE)
				end)
				ScanEverything(v)
			else
				ScanEverything(v)
			end
		end
	end

	local function Scan(Par)
		for i, v in pairs(Par:GetChildren()) do
			if not (Plrs:FindFirstChild(v.Name)) then
				table.insert(Settings.FakeCrap, v)
				print("Added " .. v.Name)
			else
				ScanEverything(v)
			end
			RunS.RenderStepped:wait()
		end
	end
	Scan(Par)
end

function RecursiveGetChildren(Par)
	local returnValue = {}
	
	local rgc
	rgc = function(Par)
		for i, c in next, Par:GetChildren() do
			table.insert(returnValue, c)
			rgc(c)
		end
	end
	
	rgc(Par)
	
	return returnValue
end

function CheckCameraForPlrModel(Plr)
	local Find = C:FindFirstChild("ESPStuff " .. Plr.Name)
	if (Find) then
		local Find2 = Find:FindFirstChild("Tracer Stuff")
		if not (Find2) then
			local T = Instance.new("Model", Find)
			T.Name = "Tracer Stuff"
		end
		Find2 = Find:FindFirstChild("ESP Stuff")
		if not (Find2) then
			local T = Instance.new("Model", Find)
			T.Name = "ESP Stuff"
		end
		return Find
	end
	local mod = Instance.new("Model", C)
	mod.Name = "ESPStuff " .. Plr.Name
	local T = Instance.new("Model", mod)
	T.Name = "Tracer Stuff"
	local ESP = Instance.new("Model", mod)
	ESP.Name = "ESP Stuff"
	return mod
end

function UpdateTracerCrap(What, Plr)
	if ((MyPlr.Character ~= nil and Plr.Character ~= nil) and (MyPlr.Character.PrimaryPart ~= nil and Plr.Character.PrimaryPart ~= nil)) then
		if ((MyPlr.Character.PrimaryPart.Position - Plr.Character.PrimaryPart.Position).magnitude < 2000) then
			local P = What.Part
			P.Transparency = 0
			local M = P.Mesh
			if (Plr.Character == nil) then -- Only if the player character is nil do we wait for it, or updating the tracer would be laggy as fuck
				repeat
					RunS.RenderStepped:wait()
				until Plr.Character ~= nil
			end
			local R = C:ScreenPointToRay(C.ViewportSize.X / 2, C.ViewportSize.Y, 0)
			local Dist = (R.Origin - (Plr.Character.PrimaryPart.Position - Vector3.new(0, 3, 0))).magnitude
			P.Size = Vector3.new(0.1, 0.1, Dist)
			P.CFrame = CFrame.new(R.Origin, (Plr.Character.PrimaryPart.Position - Vector3.new(0, 4.5, 0))) * CFrame.new(0, 0, -Dist / 2)
			P.BrickColor = BrickColor.new(
				#Teams:GetChildren() > 0 and (
					Plr.TeamColor == MyPlr.TeamColor and CC.Ally or
					Plr.TeamColor ~= MyPlr.TeamColor and CC.Enemy
				) or #Teams:GetChildren() <= 0 and CC.Enemy
			)
			M.Scale = Vector3.new(0.05, 0.05, P.Size.Z / Dist)
		else
			local P = What.Part
			P.Transparency = 1
		end
	end
end


local Aim = 1
function UpdateESPGui(HealthBar, HealthTxt, Plr, DistTxt, PlrName)
	if (Plr.Character == nil) then
		repeat
			RunS.RenderStepped:wait()
		until Plr.Character ~= nil
	end
	if ((Plr.Character.PrimaryPart.Position - MyPlr.Character.PrimaryPart.Position).magnitude <= 2000) then
		HealthBar.Parent.Parent.Visible = true
	else
		HealthBar.Parent.Parent.Visible = false
	end
	HealthBar.Size = UDim2.new(Plr.Character.Humanoid.Health / Plr.Character.Humanoid.MaxHealth, -2, 1, -2)
	HealthTxt.Text = math.floor(Plr.Character.Humanoid.Health) .. "/" .. math.floor(Plr.Character.Humanoid.MaxHealth)
	local Dist = (Plr.Character.PrimaryPart.Position - MyPlr.Character.PrimaryPart.Position).magnitude
	DistTxt.Text = math.floor(Dist) .. " Studs"
	PlrName.TextColor3 = (
		#Teams:GetChildren() > 0 and (
			Plr.TeamColor == MyPlr.TeamColor and CC.Ally or
			Plr.TeamColor ~= MyPlr.TeamColor and CC.Enemy
		) or #Teams:GetChildren() <= 0 and CC.Enemy
	)
	DistTxt.TextColor3 = (
		#Teams:GetChildren() > 0 and (
			Plr.TeamColor == MyPlr.TeamColor and CC.Ally or
			Plr.TeamColor ~= MyPlr.TeamColor and CC.Enemy
		) or #Teams:GetChildren() <= 0 and CC.Enemy
	)
end

function UpdateESPCrap(What, Plr)
	if ((MyPlr.Character ~= nil and Plr.Character ~= nil) and (MyPlr.Character.PrimaryPart ~= nil and Plr.Character.PrimaryPart ~= nil)) then
		if ((MyPlr.Character.PrimaryPart.Position - Plr.Character.PrimaryPart.Position).magnitude < 2000) then
			if (PC[Plr] ~= nil) then
				local viewpoint = C.CoordinateFrame
				
				local PDists = {}
				for i, p in next, PC[Plr] do
					table.insert(PDists, (viewpoint.p - i.Position).magnitude)
				end
				
				local nearestDistance = math.min(unpack(PDists))
				local furthestDistance = math.max(unpack(PDists))
				
				for i, p in next, PC[Plr] do
					local O, M, S = unpack(p)
					
					
					local Dist = (i.Position - viewpoint.p).magnitude
					local DistMult = Aim + (Dist - nearestDistance) / (furthestDistance - nearestDistance)
					
					O.Transparency = math.max(S + (i.Transparency * (1 - S)), 0.001)
					
					local unit = (i.Position - viewpoint.p).unit * DistMult
					local pos = viewpoint.p + unit
					
					local OF = CFrame.new(pos) * CFrame.Angles(i.CFrame:toEulerAnglesXYZ())
					
					O.CFrame = OF
					
					local OS = DistMult / Dist
					
					if (M == nil) then
						O.Mesh.Scale = i.Size * OS
					else
						if (M:IsA("SpecialMesh") and M.MeshType.Name == "FileMesh") or (M:IsA("SpecialMesh") == false) then
							O[M.Name].Scale = M.Scale * OS
						else
							O[M.Name].Scale = M.Scale * i.Size * OS
						end
					end
					
					O.BrickColor = BrickColor.new(
						#Teams:GetChildren() > 0 and (
							Plr.TeamColor == MyPlr.TeamColor and CC.Ally or
							Plr.TeamColor ~= MyPlr.TeamColor and CC.Enemy
						) or #Teams:GetChildren() <= 0 and CC.Enemy
					)
				end
				
				--print("Running")
				local Mouse = MyPlr:GetMouse()
				local R = Ray.new(Mouse.UnitRay.Origin, Mouse.UnitRay.Direction * 5000)
				local RP = workspace:FindPartOnRayWithIgnoreList(R, Settings.FakeCrap, false, true)
				if (RP ~= nil) then
					local Find = Plrs:FindFirstChild(RP.Parent.Name) or Plrs:FindFirstChild(string.sub(RP.Parent.Name, string.len("ESPStuff ") + 1))
					if ((Find and Find:IsA("Player")) and (Find ~= MyPlr and Find == Plr)) then
						Aim = 500000
						wait(3)
					else
						Aim = 1
					end
				else
					Aim = 1
				end
			end
		end
	end
end

function CreateESPStuff(Plr)
	local ESPModel = CheckCameraForPlrModel(Plr)
	PESPC[Plr] = ESPModel
	if (Settings.ShowTracers) then
		local T = ESPModel["Tracer Stuff"]
		if not (T:FindFirstChild(Plr.Name)) then
			local mod = Instance.new("Model", T)
			mod.Name = Plr.Name
			local P = Instance.new("Part", mod)
			P.FormFactor = "Custom"
			P.Material = "Neon"
			P.Transparency = 0
			P.Anchored = true
			P.Locked = true
			P.CanCollide = false
			table.insert(Settings.FakeCrap, P)
			local M = Instance.new("BlockMesh", P)
			RunS:BindToRenderStep("TracerUpdate " .. Plr.Name, Enum.RenderPriority.Character.Value - 1, function()
				UpdateTracerCrap(mod, Plr)
			end)
		end
	end
	if (Settings.ShowESP) then
		local ESP = ESPModel["ESP Stuff"]
		local mod = Instance.new("Model", ESP)
		mod.Name = Plr.Name
		repeat
			RunS.RenderStepped:wait()
		until Plr.Character ~= nil
		for i, v in next, RecursiveGetChildren(Plr.Character) do
			if (v:IsA("BasePart")) then
				local O = Instance.new("Part", mod)
				O.Anchored = true
				O.CanCollide = false
				O.FormFactor = "Custom"
				O.Size = Vector3.new(1, 1, 1)
				O.Name = "Fake " .. v.Name
				O.Material = "SmoothPlastic"
				O.TopSurface = "SmoothNoOutlines"
				O.BottomSurface = "SmoothNoOutlines"
				O.FrontSurface = "SmoothNoOutlines"
				O.BackSurface = "SmoothNoOutlines"
				O.LeftSurface = "SmoothNoOutlines"
				O.RightSurface = "SmoothNoOutlines"
				
				local P = nil
				local PMesh = nil
				for ii, vv in next, RecursiveGetChildren(v) do
					if (vv:IsA("DataModelMesh")) then
						local ThisPMesh = vv:clone()
						
						local meshChanged = vv.Changed:connect(function(Prop)
							if (Prop == "MeshType" or Prop == "MeshId" or Prop == "TextureProp") then
								ThisPMesh[Prop] = vv[Prop]
							end
						end)
						
						PMesh = ThisPMesh
					elseif (vv:IsA("FaceInstance")) then
						vv:clone().Parent = O
					end
				end
				
				if (PMesh == nil) then
					local M = Instance.new("BlockMesh", O)
				else
					PMesh:clone().Parent = O
				end
				
				if (O.Name == "Fake Head") then
					local Info = Instance.new("BillboardGui", O.Mesh)
					Info.Name = "ESPStats"
					Info.Adornee = O
					Info.Size = UDim2.new(0, 100, 0, 75)
					Info.ExtentsOffset = Vector3.new(0, 0.3, 0)
					
					local Stats = Instance.new("Frame", Info)
					Stats.BackgroundTransparency = 1
					Stats.Name = "Stats"
					Stats.Size = UDim2.new(1, 0, 1, 0)
					Stats.Visible = false
					
					local Health = Instance.new("Frame", Stats)
					Health.Name = "HealthBG"
					Health.BackgroundColor3 = Color3.new(0, 0, 0)
					Health.BorderSizePixel = 0
					Health.Position = UDim2.new(0, 0, 0, 25)
					Health.Size = UDim2.new(1, 0, 0, 25)
					
					local HealthBG = Instance.new("Frame", Health)
					HealthBG.Name = "Health"
					HealthBG.BackgroundColor3 = Color3.new(0, 1, 0)
					HealthBG.BorderSizePixel = 0
					HealthBG.Position = UDim2.new(0, 1, 0, 1)
					HealthBG.Size = UDim2.new(1, -2, 1, -2)
					
					local HealthNum = Instance.new("TextLabel", Health)
					HealthNum.Name = "HealthNum"
					HealthNum.BackgroundTransparency = 1
					HealthNum.Size = UDim2.new(1, 0, 1, 0)
					HealthNum.Font = "Legacy"
					HealthNum.FontSize = "Size8"
					HealthNum.Text = "???"
					HealthNum.TextColor3 = Color3.new(1, 0, 0)
					
					local PlrName = Instance.new("TextLabel", Stats)
					PlrName.Name = "PlrName"
					PlrName.BackgroundTransparency = 1
					PlrName.Size = UDim2.new(1, 0, 0, 25)
					PlrName.Font = "Legacy"
					PlrName.FontSize = "Size8"
					PlrName.Text = Plr.Name
					PlrName.TextColor3 = (
						#Teams:GetChildren() > 0 and (
							Plr.TeamColor == MyPlr.TeamColor and CC.Ally or
							Plr.TeamColor ~= MyPlr.TeamColor and CC.Enemy
						) or #Teams:GetChildren() <= 0 and CC.Enemy
					)
					
					local PlrDist = PlrName:clone()
					PlrDist.Parent = PlrName.Parent
					PlrDist.Name = "Dist"
					PlrDist.Text = "???"
					PlrDist.Position = UDim2.new(0, 0, 0, 50)
					PlrDist.TextColor3 = (
						#Teams:GetChildren() > 0 and (
							Plr.TeamColor == MyPlr.TeamColor and CC.Ally or
							Plr.TeamColor ~= MyPlr.TeamColor and CC.Enemy
						) or #Teams:GetChildren() <= 0 and CC.Enemy
					)
					RunS:BindToRenderStep("UpdateESPGui " .. Plr.Name, Enum.RenderPriority.Character.Value - 1, function()
						UpdateESPGui(HealthBG, HealthNum, Plr, PlrDist, PlrName)
					end)
				end
				
				if (PC[Plr] == nil) then
					PC[Plr] = {}
				end
				PC[Plr][v] = {O, PMesh, 0}
				table.insert(Settings.FakeCrap, O)
				table.insert(Settings.FakeCrap, PMesh)
			end
		end
		RunS:BindToRenderStep("UpdateESP " .. Plr.Name, Enum.RenderPriority.Character.Value - 1, function()
			UpdateESPCrap(mod, Plr)
		end)
	end
end

function RemoveESP(Plr)
	RunS:UnbindFromRenderStep("UpdateESP " .. Plr.Name)
	RunS:UnbindFromRenderStep("UpdateESPGui " .. Plr.Name)
	local Find = C:FindFirstChild("ESPStuff " .. Plr.Name)
	if (Find) then
		Find = Find:FindFirstChild("ESP Stuff")
		if (Find) then
			Find:Destroy()
		end
	end
	PC[Plr] = {}
end

function OnCharacterAdded(Char, Plr)
	RemoveESP(Plr)
	CreateESPStuff(Plr)
	-- Added shit to ingore list
end

function OnPlayerAdded(Plr)
	CreateESPStuff(Plr)
	Plr.CharacterAdded:connect(function(Char)
		OnCharacterAdded(Char, Plr)
	end)
end

function OnPlayerRemoved(Plr)
	RunS:UnbindFromRenderStep("TracerUpdate " .. Plr.Name)
	RunS:UnbindFromRenderStep("UpdateESP " .. Plr.Name)
	RunS:UnbindFromRenderStep("UpdateESPGui " .. Plr.Name)
	local Find = C:FindFirstChild("ESPStuff " .. Plr.Name)
	if (Find) then
		Find:Destroy()
	end
end

function GetCurrentPlayers()
	for i, v in pairs(Plrs:GetPlayers()) do
		if (v ~= MyPlr) then
			CreateESPStuff(v)
			v.CharacterAdded:connect(function(Char)
				OnCharacterAdded(Char, v)
			end)
		end
	end
end

print("Please wait....")
wait(0.5)
AddShitToIgnoreList(workspace)
GetCurrentPlayers()
Plrs.PlayerAdded:connect(OnPlayerAdded)
Plrs.PlayerRemoving:connect(OnPlayerRemoved)
 end
end)





--[[
fake macro section
]]





plr = game:GetService('Players').LocalPlayer
down = true
 
function onButton1Down(mouse)
    down = true
    while down do
        if not down then break end
        local char = plr.Character
        char.HumanoidRootPart.Velocity = char.HumanoidRootPart.CFrame.lookVector * 190
        wait()
    end
end
 
function onButton1Up(mouse)
    down = false
end
 
function onSelected(mouse)
    mouse.KeyDown:connect(function(h) if h:lower()=="h"then onButton1Down(mouse)end end)
    mouse.KeyUp:connect(function(h) if h:lower()=="h"then onButton1Up(mouse)end end)
end
onSelected(game.Players.LocalPlayer:GetMouse())
game.StarterGui:SetCore("SendNotification",{
			Title = "Sun Lock";
			Text = "Hold H to Speed, Press Q to Lock";
			Duration = 1.00;
		})






--[[
Aim Lock Section
]]






local Settings = {
    AimLock = {
        Enabled = true,
        Aimlockkey = "q",
        Prediction = 0.151,
        Aimpart = 'HumanoidRootPart',
        Notifications = false
    },
    Settings = {
        Thickness = 3,
        Transparency = 1,
        Color = Color3.fromRGB(45, 194, 50),
        FOV = true
    }
 
}
 
local CurrentCamera = game:GetService("Workspace").CurrentCamera
local Inset = game:GetService("GuiService"):GetGuiInset().Y
local RunService = game:GetService("RunService")
 
local Mouse = game.Players.LocalPlayer:GetMouse()
local LocalPlayer = game.Players.LocalPlayer
 
local Line = Drawing.new("Line")
local Circle = Drawing.new("Circle")
 
local Plr
 
Mouse.KeyDown:Connect(function(KeyPressed)
    if KeyPressed == (Settings.AimLock.Aimlockkey) then
        if Settings.AimLock.Enabled == true then
            Settings.AimLock.Enabled = false
            if Settings.AimLock.Notifications == true then
                Plr = FindClosestPlayer()
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Sun Lock",
                    Text = "Unlocked"
                })
            end
        else
            Plr = FindClosestPlayer()
            Settings.AimLock.Enabled = true
            if Settings.AimLock.Notifications == true then
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Sun Lock",
                    Text = "Locked On To:  " .. tostring(Plr.Character.Humanoid.DisplayName)
                })
            end
        end
    end
end)
 
function FindClosestPlayer()
    local ClosestDistance, ClosestPlayer = math.huge, nil;
    for _, Player in next, game:GetService("Players"):GetPlayers() do
        local ISNTKNOCKED = Player.Character:WaitForChild("BodyEffects")["K.O"].Value ~= true
        local ISNTGRABBED = Player.Character:FindFirstChild("GRABBING_COINSTRAINT") == nil
 
        if Player ~= LocalPlayer then
            local Character = Player.Character
            if Character and Character.Humanoid.Health > 1 and ISNTKNOCKED and ISNTGRABBED then
                local Position, IsVisibleOnViewPort = CurrentCamera:WorldToViewportPoint(Character.HumanoidRootPart
                                                                                             .Position)
                if IsVisibleOnViewPort then
                    local Distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Position.X, Position.Y)).Magnitude
                    if Distance < ClosestDistance then
                        ClosestPlayer = Player
                        ClosestDistance = Distance
                    end
                end
            end
        end
    end
    return ClosestPlayer, ClosestDistance
end
 
RunService.Heartbeat:connect(function()
    if Settings.AimLock.Enabled == true then
        local Vector = CurrentCamera:WorldToViewportPoint(Plr.Character[Settings.AimLock.Aimpart].Position +
                                                              (Plr.Character[Settings.AimLock.Aimpart].Velocity *
                                                              Settings.AimLock.Prediction))
        Line.Color = Settings.Settings.Color
        Line.Transparency = Settings.Settings .Transparency
        Line.Thickness = Settings.Settings .Thickness
        Line.From = Vector2.new(Mouse.X, Mouse.Y + Inset)
        Line.To = Vector2.new(Vector.X, Vector.Y)
        Line.Visible = true
        Circle.Position = Vector2.new(Mouse.X, Mouse.Y + Inset)
        Circle.Visible = Settings.Settings.FOV
        Circle.Thickness = 1.5
        Circle.Thickness = 2
        Circle.Radius = 60
        Circle.Color = Settings.Settings.Color
    elseif Settings.AimLock.FOV == true then
        Circle.Visible = true
    else
        Circle.Visible = false
        Line.Visible = false
    end
end)
 
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(...)
    local args = {...}
    if Settings.AimLock.Enabled and getnamecallmethod() == "FireServer" and args[2] == "UpdateMousePos" then
        args[3] = Plr.Character[Settings.AimLock.Aimpart].Position +
                      (Plr.Character[Settings.AimLock.Aimpart].Velocity * Settings.AimLock.Prediction)
 
        return old(unpack(args))
    end
    return old(...)
end)
