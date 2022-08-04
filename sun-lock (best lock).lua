--[[

░██████╗██╗░░░██╗███╗░░██╗
██╔════╝██║░░░██║████╗░██║
╚█████╗░██║░░░██║██╔██╗██║
░╚═══██╗██║░░░██║██║╚████║
██████╔╝╚██████╔╝██║░╚███║
╚═════╝░░╚═════╝░╚═╝░░╚══╝                                            
]]

--- Tut

local esp_settings = { ---- table for esp settings 
    esp_settingskey = "p",
    Enabled = true,
    textsize = 8,
    colour = 255,255,255
}

local gui = Instance.new("BillboardGui")
local esp = Instance.new("TextLabel",gui) ---- new instances to make the billboard gui and the textlabel



gui.Name = "Cracked esp"; ---- properties of the esp
gui.ResetOnSpawn = false
gui.AlwaysOnTop = true;
gui.LightInfluence = 0;
gui.Size = UDim2.new(1.75, 0, 1.75, 0);
esp.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
esp.Text = ""
esp.Size = UDim2.new(0.0001, 0.00001, 0.0001, 0.00001);
esp.BorderSizePixel = 4;
esp.BorderColor3 = Color3.new(esp_settings.colour)
esp.BorderSizePixel = 0
esp.Font = "GothamSemibold"
esp.TextSize = esp_settings.textsize
esp.TextColor3 = Color3.fromRGB(esp_settings.colour) -- text colour

game:GetService("RunService").RenderStepped:Connect(function() ---- loops faster than a while loop :)
    for i,v in pairs (game:GetService("Players"):GetPlayers()) do
        if v ~= game:GetService("Players").LocalPlayer and v.Character.Head:FindFirstChild("Cracked esp")==nil  then -- craeting checks for team check, local player etc
            esp.Text = "{"..v.Name.."}"
            gui:Clone().Parent = v.Character.Head
    end
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
