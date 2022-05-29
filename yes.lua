local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()      
local Window = Library.CreateLib("FapeX", "Ocean")

local Tab = Window:NewTab("Player Tab")
local Section = Tab:NewSection("Player Tabs")

Section:NewButton("Fly (Move With you're Mouse) Press X Too Fly", "Fly", function()
    repeat wait() until game.Players.LocalPlayer.Character
 
local plr = game.Players.LocalPlayer
local char = plr.Character
local hum = char:WaitForChild("Humanoid")
local Torso = char:WaitForChild("LowerTorso")
local Mouse = plr:GetMouse()
local toggle = false
 
Mouse.KeyDown:Connect(function(key)
	if key == "x" then
		if toggle == false then
			toggle = true
			local Anim = Instance.new("Animation")
			Anim.AnimationId = "rbxassetid://7189034627"
			local PlayAnim = hum:LoadAnimation(Anim)
			PlayAnim:Play()
			local BV = Instance.new("BodyVelocity",Torso)
			BV.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
			while toggle == true do
				BV.Velocity = Mouse.Hit.lookVector*100
				wait()
			end
		end
		if toggle == true then
			toggle = false
			Torso:FindFirstChildOfClass("BodyVelocity"):remove()
			local tracks = hum:GetPlayingAnimationTracks()
			for i, stoptracks in pairs(tracks) do
				stoptracks:Stop()
			end
			local Anim = Instance.new("Animation")
			Anim.AnimationId = "http://www.roblox.com/asset/?id=7189034627"
			local PlayAnim = hum:LoadAnimation(Anim)
			PlayAnim:Play()
		end
	end
end)
end)

Section:NewButton("SwagMode", "SwagMode", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/lerkermer/lua-projects/master/SwagModeV002'))()
end)

Section:NewButton("Faded", "Faded", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NighterEpic/Faded/main/YesEpic", true))()
end)

local Tab = Window:NewTab("Aim Tab")
local Section = Tab:NewSection("Aim Tab")

Section:NewButton("Aimlock", "Aimlock", function()
    --[[
    This source is free to use and hopefully a good source for new script developers to learn how to make an aimlock or silent aim.
    * If this is used in any script, please credit me for it.
    * Please do not use this in a paid script.
    
    Sorry for the really ugly code, I didn't think I would be releasing the source, lmao.
--]]

-- *NOTE: If the script doesn't start, remove the code in line 70.
-- Aka: repeat wait() until LP.Character:FindFirstChild("FULLY_LOADED_CHAR");


--// Settings

local Settings = {
    Aimlock = {
        AimPart = "LowerTorso",
        AimlockKey = "Q",
        Prediction = 0.143,

        FOVEnabled = false,
        FOVShow = false,
        FOVSize = 30,

        Enabled = false
    },
    SilentAim = {
        Key = "C",
        AimAt = "LowerTorso",
        PredictionAmount = 0.139,

        FOVEnabled = false,
        FOVShow = false,
        FOVSize = 0,

        Enabled = false,
        KeyToLockOn = false
    },
    CFSpeed = {
        Speed = 2,
        
        Enabled = false,
        Toggled = false,

        Key = "Z"
    }
}

--// Variables (Service)

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local GS = game:GetService("GuiService")
local SG = game:GetService("StarterGui")
local UIS = game:GetService("UserInputService")

--// Variables (regular)

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Camera = WS.CurrentCamera
local GetGuiInset = GS.GetGuiInset

local AimlockState = false
local aimLocked
local lockVictim

--// Anti-Cheat

repeat wait() until LP.Character:FindFirstChild("FULLY_LOADED_CHAR");

for _,ac in pairs(LP.Character:GetChildren()) do
    if (ac:IsA("Script") and ac.Name ~= "Animate" and ac.Name ~= "Health") then
        ac:Destroy();
    end;
end;

LP.Character.ChildAdded:Connect(function(child)
    if (child:IsA("Script") and child.Name ~= "Animate" and ac.Name ~= "Health") then
        child:Destroy();
    end;
end);

--// CFrame Speed

local userInput = game:GetService('UserInputService')
local runService = game:GetService('RunService')

Mouse.KeyDown:connect(function(Key)
    local cfKey = Settings.CFSpeed.Key:lower()
    if (Key == cfKey) then
        if (Settings.CFSpeed.Toggled) then
            Settings.CFSpeed.Enabled = not Settings.CFSpeed.Enabled
            if (Settings.CFSpeed.Enabled == true) then
                repeat
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + game.Players.LocalPlayer.Character.Humanoid.MoveDirection * Settings.CFSpeed.Speed
                    game:GetService("RunService").Stepped:wait()
                until Settings.CFSpeed.Enabled == false
            end
        end
    end
end)

--// FOV Circle

local fov = Drawing.new("Circle")
fov.Filled = false
fov.Transparency = 1
fov.Thickness = 1
fov.Color = Color3.fromRGB(255, 255, 0)

--// Functions

function updateLock()
    if Settings.Aimlock.FOVEnabled == true and Settings.Aimlock.FOVShow == true then
        if fov then
            fov.Radius = Settings.Aimlock.FOVSize * 2
            fov.Visible = Settings.Aimlock.FOVShow
            fov.Position = Vector2.new(Mouse.X, Mouse.Y + GetGuiInset(GS).Y)

            return fov
        end
    else
        Settings.Aimlock.FOVShow = false
        fov.Visible = false
    end
end

function WTVP(arg)
    return Camera:WorldToViewportPoint(arg)
end

function WTSP(arg)
    return Camera.WorldToScreenPoint(Camera, arg)
end

function getClosest()
    local closestPlayer
    local shortestDistance = math.huge

    for i, v in pairs(game.Players:GetPlayers()) do
        local notKO = v.Character:WaitForChild("BodyEffects")["K.O"].Value ~= true
        local notGrabbed = v.Character:FindFirstChild("GRABBING_COINSTRAINT") == nil
        
        if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health ~= 0 and v.Character:FindFirstChild(Settings.Aimlock.AimPart) and notKO and notGrabbed then
            local pos = Camera:WorldToViewportPoint(v.Character.PrimaryPart.Position)
            local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).magnitude
            
            if (Settings.Aimlock.FOVEnabled) then
                if (fov.Radius > magnitude and magnitude < shortestDistance) then
                    closestPlayer = v
                    shortestDistance = magnitude
                end
            else
                if (magnitude < shortestDistance) then
                    closestPlayer = v
                    shortestDistance = magnitude
                end
            end
        end
    end
    return closestPlayer
end

function sendNotification(text)
    game.StarterGui:SetCore("SendNotification", {
        Title = "hakan.software",
        Text = text,
        Duration = 5
    })
end

--// Checks if key is down

Mouse.KeyDown:Connect(function(k)
    local actualKey = Settings.Aimlock.AimlockKey:lower()
    if (k == actualKey) then
        if Settings.Aimlock.Enabled == true then
            aimLocked = not aimLocked
            if aimLocked then
                lockVictim = getClosest()

                sendNotification("Locked onto: "..tostring(lockVictim.Character.Humanoid.DisplayName))
            else
                if lockVictim ~= nil then
                    lockVictim = nil

                    sendNotification("Unlocked!")
                end
            end
        end
    end
end)

--// Loop update FOV and loop camera lock onto target

local localPlayer = game:GetService("Players").LocalPlayer
local currentCamera = game:GetService("Workspace").CurrentCamera
local guiService = game:GetService("GuiService")
local runService = game:GetService("RunService")

local getGuiInset = guiService.GetGuiInset
local mouse = localPlayer:GetMouse()

local silentAimed = false
local silentVictim
local victimMan

local FOVCircle = Drawing.new("Circle")
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(200, 255, 128)
function updateFOV()
    if (FOVCircle) then
        if (Settings.SilentAim.FOVEnabled) then
            FOVCircle.Radius = Settings.SilentAim.FOVSize * 2
            FOVCircle.Visible = Settings.SilentAim.FOVShow
            FOVCircle.Position = Vector2.new(mouse.X, mouse.Y + getGuiInset(guiService).Y)

            return FOVCircle
        elseif (not Settings.SilentAim.FOVEnabled) then
            FOVCircle.Visible = false
        end
    end
end

function getClosestPlayerToCursor()
    local closestPlayer
    local shortestDistance = math.huge

    for i, v in pairs(game.Players:GetPlayers()) do
        if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health ~= 0 and v.Character:FindFirstChild(Settings.SilentAim.AimAt) then
            local pos = currentCamera:WorldToViewportPoint(v.Character.PrimaryPart.Position)
            local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).magnitude
            
            if (Settings.SilentAim.FOVEnabled == true) then
                if (FOVCircle.Radius > magnitude and magnitude < shortestDistance) then
                    closestPlayer = v
                    shortestDistance = magnitude
                end
            else
                if (magnitude < shortestDistance) then
                    closestPlayer = v
                    shortestDistance = magnitude
                end
            end
        end
    end
    return closestPlayer
end

Mouse.KeyDown:Connect(function(k)
    local actualKey = Settings.SilentAim.Key:lower()
    if (k == actualKey) then
        if (Settings.SilentAim.KeyToLockOn == false) then
            return
        end
        if (Settings.SilentAim.Enabled) then
            silentAimed = not silentAimed
                
            if silentAimed then
                silentVictim = getClosestPlayerToCursor()
                sendNotification("Locked onto: " .. tostring(silentVictim.Character.Humanoid.DisplayName))
            elseif not silentAimed and silentVictim ~= nil then
                silentVictim = nil

                sendNotification('Unlocked')
            end
        end
    end
end)

runService.RenderStepped:Connect(function()
    updateFOV()
    updateLock()
    victimMan = getClosestPlayerToCursor()
    if Settings.Aimlock.Enabled == true then
        if lockVictim ~= nil then
            Camera.CFrame = CFrame.new(Camera.CFrame.p, lockVictim.Character[Settings.Aimlock.AimPart].Position + lockVictim.Character[Settings.Aimlock.AimPart].Velocity*Settings.Aimlock.Prediction)
        end
    end
end)

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(...)
    local args = {...}

    if Settings.SilentAim.Enabled and Settings.SilentAim.KeyToLockOn and silentAimed and getnamecallmethod() == "FireServer" and args[2] == "UpdateMousePos" then
        args[3] = silentVictim.Character[Settings.SilentAim.AimAt].Position+(silentVictim.Character[Settings.SilentAim.AimAt].Velocity*Settings.SilentAim.PredictionAmount)
        return old(unpack(args))
    elseif Settings.SilentAim.Enabled and not Settings.SilentAim.KeyToLockOn and getnamecallmethod() == "FireServer" and args[2] == "UpdateMousePos" then
        args[3] = victimMan.Character[Settings.SilentAim.AimAt].Position+(victimMan.Character[Settings.SilentAim.AimAt].Velocity*Settings.SilentAim.PredictionAmount)
        return old(unpack(args))
    end

    return old(...)
end)



----------------------------------------
local lib = loadstring(game:HttpGet("https://pastebin.com/raw/mSwV3R8V"))()
local main = lib:Init()
----------------------------------------

----------------------------------------
local Home = main:CreateTab("Home")
local Config = main:CreateTab("Config", "rbxassetid://6793572208")
local Misc = main:CreateTab("Misc", "rbxassetid://3192519002")
----------------------------------------

----------------------------------------
Home:CreateLabel("Welcome back!", false)
----------------------------------------

----------------------------------------
Config:CreateLabel("Config - Aimlock", true)
Config:CreateToggle("Enabled", function(state)
    Settings.Aimlock.Enabled = state
end)
Config:CreateBox("Prediction", 0.143, function(arg)
    Settings.Aimlock.Prediction = tonumber(arg)
end)
Config:CreateDropdown("AimPart", {'Head', 'UpperTorso', 'HumanoidRootPart', 'LowerTorso'}, 'LowerTorso', function(arg)
    Settings.Aimlock.AimPart = tostring(arg)
end)
Config:CreateToggle("FOV", function(state)
    Settings.Aimlock.FOVEnabled = state
end)
Config:CreateToggle("Show FOV", function(state)
    Settings.Aimlock.FOVShow = state
end)
Config:CreateSlider("FOV Size", 30, 0, 400, 1, function(arg)
    Settings.Aimlock.FOVSize = tonumber(arg)
end)
Config:CreateBind("Keybind", Enum.KeyCode.Q, function(arg)
    Settings.Aimlock.AimlockKey = arg
end)
----------------------------------------

----------------------------------------
Config:CreateLabel("Config - Silent", false)
Config:CreateToggle("Enabled", function(state)
    Settings.SilentAim.Enabled = state
end)
Config:CreateToggle("Key to lock on", function(state)
    Settings.SilentAim.KeyToLockOn = state
end)
Config:CreateBox("Prediction", 0.143, function(arg)
    Settings.SilentAim.PredictionAmount = tonumber(arg)
end)
Config:CreateDropdown("AimPart", {'Head', 'UpperTorso', 'HumanoidRootPart', 'LowerTorso'}, 'LowerTorso', function(arg)
    Settings.SilentAim.AimAt = tostring(arg)
end)
Config:CreateToggle("FOV", function(state)
    Settings.SilentAim.FOVEnabled = state
end)
Config:CreateToggle("Show FOV", function(state)
    Settings.SilentAim.FOVShow = state
end)
Config:CreateSlider("FOV Size", 30, 0, 400, 1, function(arg)
    Settings.SilentAim.FOVSize = tonumber(arg)
end)
Config:CreateBind("Keybind", Enum.KeyCode.Q, function(arg)
    Settings.SilentAim.Key = arg
end)
----------------------------------------

----------------------------------------
Misc:CreateLabel("Miscellaneous", false)
Misc:CreateToggle("CFS State", function(state)
    Settings.CFSpeed.Toggled = state
end)
Misc:CreateSlider("CFrame Speed", 2, 0, 10, 0.1, function(arg)
    Settings.CFSpeed.Speed = tonumber(arg)
end)
Misc:CreateBind("CFS Key", Enum.KeyCode.Z, function(arg)
    Settings.CFSpeed.Key = arg
end)

-- // main script  / / -- 

loadstring(game:HttpGet("https://raw.githubusercontent.com/tenaaki/GenericAimbot/main/v1.0.0"))()
end)

local Tab = Window:NewTab("Macro Tab")
local Section = Tab:NewSection("Macro Tab")

Section:NewButton("Z To Macro", "Z", function()
    Key = Enum.KeyCode.Z -- If you want to change the keybind, change "Q" with something else
loadstring(game:HttpGet("https://pastebin.com/raw/YkYju5rm", true))()
end)


local Tab1 = Window:NewTab("Animation Pack Tab")
local Tab1Section = Tab1:NewSection("Animation Pack Tab")

local Tab2 = Window:NewTab("Normal Animation Tab")
local Tab2Section = Tab2:NewSection("Normal Animation")

-- Tab1

Tab1Section:NewToggle("Zombie", "Changes Animation To Zombie", function(state)
getgenv().zombie = state
game:GetService("RunService").RenderStepped:connect(function()
  if getgenv().zombie then
local Animate =
game.Players.LocalPlayer.Character.Animate
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616158929"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616160636"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616168032"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616163682"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616161997"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616156119"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616157476"
  end
end)
end)

Tab1Section:NewToggle("Astronaut", "Changes Animation To Zombie", function(state)
getgenv().astronaut = state
game:GetService("RunService").RenderStepped:connect(function()
  if getgenv().astronaut then
local Animate =
game.Players.LocalPlayer.Character.Animate
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=891621366"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=891633237"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=891667138"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=891636393"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=891627522"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=891609353"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=891617961"
  end
end)
end)

Tab1Section:NewToggle("Bubbly", "Changes Animation To Zombie", function(state)
getgenv().bubbly = state
game:GetService("RunService").RenderStepped:connect(function()
  if getgenv().bubbly then
local Animate =
game.Players.LocalPlayer.Character.Animate
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=910004836"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=910009958"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=910034870"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=910025107"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=910016857"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=910001910"
Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=910030921"
Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=910028158"
  end
end)
end)

Tab1Section:NewToggle("Cartoony", "Changes Animation To Zombie", function(state)
getgenv().cartoony = state
game:GetService("RunService").RenderStepped:connect(function()
  if getgenv().cartoony then
local Animate =
game.Players.LocalPlayer.Character.Animate
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=742637544"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=742638445"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=742640026"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=742638842"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=742637942"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=742636889"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=742637151"
  end
end)
end)

Tab1Section:NewToggle("Elder", "Changes Animation To Zombie", function(state)
getgenv().elder = state
game:GetService("RunService").RenderStepped:connect(function()
  if getgenv().elder then
local Animate =
game.Players.LocalPlayer.Character.Animate
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=845397899"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=845400520"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=845403856"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=845386501"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=845398858"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=845392038"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=845396048"
  end
end)
end)

Tab1Section:NewToggle("Knight", "Changes Animation To Zombie", function(state)
getgenv().knight = state
game:GetService("RunService").RenderStepped:connect(function()
  if getgenv().knight then
local Animate =
game.Players.LocalPlayer.Character.Animate
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=657595757"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=657568135"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=657552124"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=657564596"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=658409194"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=658360781"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=657600338"
  end
end)
end)

Tab1Section:NewToggle("Levitation", "Changes Animation To Zombie", function(state)
getgenv().levitation = state
game:GetService("RunService").RenderStepped:connect(function()
  if getgenv().levitation then
local Animate =
game.Players.LocalPlayer.Character.Animate
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616006778"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616008087"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616013216"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616010382"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616008936"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616003713"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616005863"
  end
end)
end)

Tab1Section:NewToggle("Mage", "Changes Animation To Zombie", function(state)
getgenv().mage = state
game:GetService("RunService").RenderStepped:connect(function()
  if getgenv().mage then
local Animate =
game.Players.LocalPlayer.Character.Animate
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=707742142"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=707855907"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=707897309"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=707861613"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=707853694"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=707826056"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=707829716"
  end
end)
end)

Tab1Section:NewToggle("Ninja", "Changes Animation To Zombie", function(state)
getgenv().ninja = state
game:GetService("RunService").RenderStepped:connect(function()
  if getgenv().ninja then
local Animate =
game.Players.LocalPlayer.Character.Animate
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=656117400"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=656118341"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=656121766"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=656118852"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=656117878"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=656114359"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=656115606"
  end
end)
end)

Tab1Section:NewToggle("Pirate", "Changes Animation To Zombie", function(state)
getgenv().pirate = state
game:GetService("RunService").RenderStepped:connect(function()
  if getgenv().pirate then
local Animate =
game.Players.LocalPlayer.Character.Animate
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=750781874"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=750782770"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=750785693"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=750783738"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=750782230"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=750779899"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=750780242"
  end
end)
end)

Tab1Section:NewToggle("Robot", "Changes Animation To Zombie", function(state)
getgenv().robot = state
game:GetService("RunService").RenderStepped:connect(function()
  if getgenv().robot then
local Animate =
game.Players.LocalPlayer.Character.Animate
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616088211"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616089559"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616095330"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616091570"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616090535"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616086039"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616087089"
  end
end)
end)

Tab1Section:NewToggle("Stylish", "Changes Animation To Zombie", function(state)
getgenv().stylish = state
game:GetService("RunService").RenderStepped:connect(function()
  if getgenv().stylish then
local Animate =
game.Players.LocalPlayer.Character.Animate
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616136790"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616138447"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616146177"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616140816"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616139451"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616133594"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616134815"
  end
end)
end)

Tab1Section:NewToggle("Super Hero", "Changes Animation To Zombie", function(state)
getgenv().superhero = state
game:GetService("RunService").RenderStepped:connect(function()
  if getgenv().superhero then
local Animate =
game.Players.LocalPlayer.Character.Animate
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616111295"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616113536"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616122287"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616117076"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616115533"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616104706"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616108001"
  end
end)
end)

Tab1Section:NewToggle("Toy", "Changes Animation To Zombie", function(state)
getgenv().toy = state
game:GetService("RunService").RenderStepped:connect(function()
  if getgenv().toy then
local Animate =
game.Players.LocalPlayer.Character.Animate
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=782841498"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=782845736"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=782843345"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=782842708"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=782847020"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=782843869"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=782846423"
  end
end)
end)

Tab1Section:NewToggle("Werewolf", "Changes Animation To Zombie", function(state)
getgenv().werewolf = state
game:GetService("RunService").RenderStepped:connect(function()
  if getgenv().werewolf then
local Animate =
game.Players.LocalPlayer.Character.Animate
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1083195517"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1083214717"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1083178339"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1083216690"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1083218792"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1083182000"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1083189019"
  end
end)
end)

Tab1Section:NewToggle("Vampire", "Changes Animation To Zombie", function(state)
getgenv().vampire = state
game:GetService("RunService").RenderStepped:connect(function()
  if getgenv().vampire then
local Animate =
game.Players.LocalPlayer.Character.Animate
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1083445855"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1083450166"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1083473930"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1083462077"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1083455352"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1083439238"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1083443587"
  end
end)
end)

Tab1Section:NewToggle("Old School", "Changes Animation To Zombie", function(state)
getgenv().oldschool = state
game:GetService("RunService").RenderStepped:connect(function()
  if getgenv().oldschool then
local Animate = game.Players.LocalPlayer.Character.Animate
    Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=5319828216"
    Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=5319831086"
    Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=5319847204,"
    Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=5319844329"
    Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=5319841935"
    Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=5319816685"
    Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=5319839762"
  end
end)
end)

-- Others
Tab2Section:NewToggle("Anthro (Default)", "Changes Animation To Zombie", function(state)
getgenv().anthro = state
game:GetService("RunService").RenderStepped:connect(function()
  if getgenv().anthro then
local Animate =
game.Players.LocalPlayer.Character.Animate
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=2510196951"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=2510197257"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=2510202577"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=2510198475"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=2510197830"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=2510192778"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=2510195892"
  end
end)
end)

Tab2Section:NewToggle("None", "Changes Animation To Zombie", function(state)
getgenv().none = state
game:GetService("RunService").RenderStepped:connect(function()
  if getgenv().none then
local Animate =
game.Players.LocalPlayer.Character.Animate
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=0"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=0"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=0"
Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=0"
  end
end)
end)

local Tab = Window:NewTab("GodMode Tab")
local Section = Tab:NewSection("GodMode Tab")

Section:NewButton("GodMode V3 Swag", "Retard", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/lerkermer/lua-projects/master/Godv3'))()
end)

local Tab = Window:NewTab("Fe Among Us Tab")
local Section = Tab:NewSection("Fe Among Us Tab")

Section:NewButton("Among Us", "Ayo", function()
local netboost = 1000 --velocity 
--netboost usage: 
--set to false to disable
--set to a vector3 value if you dont want the velocity to change
--set to a number to change the velocity in real time with magnitude equal to the number
local idleMag = 0.005 --used only in case netboost is set to a number value
--if magnitude of the real velocity of a part is lower than this
--then the fake velocity is being set to Vector3.new(0, netboost, 0)
--the lower value the less you jitter but you might loose network ownership
local simradius = "shp" --simulation radius (net bypass) method
--"shp" - sethiddenproperty
--"ssr" - setsimulationradius
--false - disable
local antiragdoll = true --removes hingeConstraints and ballSocketConstraints from your character
local newanimate = false --disables the animate script and enables after reanimation
local discharscripts = true --disables all localScripts parented to your character before reanimation
local R15toR6 = true --tries to convert your character to r6 if its r15
local addtools = false --puts all tools from backpack to character and lets you hold them after reanimation
local loadtime = game:GetService("Players").RespawnTime + 0.5 --anti respawn delay
local method = 3 --reanimation method
--methods:
--0 - breakJoints (takes [loadtime] seconds to laod)
--1 - limbs
--2 - limbs + anti respawn
--3 - limbs + breakJoints after [loadtime] seconds
--4 - remove humanoid + breakJoints
--5 - remove humanoid + limbs
local alignmode = 2 --AlignPosition mode
--modes:
--1 - AlignPosition rigidity enabled true
--2 - 2 AlignPositions rigidity enabled both true and false
--3 - AlignPosition rigidity enabled false
local hedafterneck = true --disable aligns for head and enable after neck is removed

local lp = game:GetService("Players").LocalPlayer
local rs = game:GetService("RunService")
local stepped = rs.Stepped
local heartbeat = rs.Heartbeat
local renderstepped = rs.RenderStepped
local sg = game:GetService("StarterGui")
local ws = game:GetService("Workspace")
local cf = CFrame.new
local v3 = Vector3.new
local v3_0 = v3(0, 0, 0)
local inf = math.huge

local c = lp.Character

if not (c and c.Parent) then
    return
end

for i, v in pairs(c:GetDescendants()) do
    if v:IsA("CharacterMesh") or v:IsA("SpecialMesh") then
        v:Destroy()
    end
end

c:GetPropertyChangedSignal("Parent"):Connect(function()
    if not (c and c.Parent) then
        c = nil
    end
end)

local function gp(parent, name, className)
	local ret = nil
	pcall(function()
		for i, v in pairs(parent:GetChildren()) do
			if (v.Name == name) and v:IsA(className) then
				ret = v
				break
			end
		end
	end)
	return ret
end

local function align(Part0, Part1)
	Part0.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0.0001, 0.0001, 0.0001, 0.0001)

	local att0 = Instance.new("Attachment", Part0)
	att0.Orientation = v3_0
	att0.Position = v3_0
	att0.Name = "att0_" .. Part0.Name
	local att1 = Instance.new("Attachment", Part1)
	att1.Orientation = v3_0
	att1.Position = v3_0
	att1.Name = "att1_" .. Part1.Name

	if (alignmode == 1) or (alignmode == 2) then
    	local ape = Instance.new("AlignPosition", att0)
    	ape.ApplyAtCenterOfMass = false
    	ape.MaxForce = inf
    	ape.MaxVelocity = inf
    	ape.ReactionForceEnabled = false
    	ape.Responsiveness = 200
    	ape.Attachment1 = att1
    	ape.Attachment0 = att0
    	ape.Name = "AlignPositionRtrue"
    	ape.RigidityEnabled = true
	end

	if (alignmode == 2) or (alignmode == 3) then
    	local apd = Instance.new("AlignPosition", att0)
    	apd.ApplyAtCenterOfMass = false
    	apd.MaxForce = inf
    	apd.MaxVelocity = inf
    	apd.ReactionForceEnabled = false
    	apd.Responsiveness = 200
    	apd.Attachment1 = att1
    	apd.Attachment0 = att0
    	apd.Name = "AlignPositionRfalse"
    	apd.RigidityEnabled = false
    end

	local ao = Instance.new("AlignOrientation", att0)
	ao.MaxAngularVelocity = inf
	ao.MaxTorque = inf
	ao.PrimaryAxisOnly = false
	ao.ReactionTorqueEnabled = false
	ao.Responsiveness = 200
	ao.Attachment1 = att1
	ao.Attachment0 = att0
	ao.RigidityEnabled = false

    if netboost then
        Part0:GetPropertyChangedSignal("Parent"):Connect(function()
            if not (Part0 and Part0.Parent) then
                Part0 = nil
            end
        end)
        spawn(function()
            if typeof(netboost) == "Vector3" then
    	        local vel = v3_0
    	        local rotvel = v3_0
            	while Part0 do
                    Part0.Velocity = vel
                    Part0.RotVelocity = rotvel
                    heartbeat:Wait()
                    if Part0 then
                        vel = Part0.Velocity
                        Part0.Velocity = netboost
                        Part0.RotVelocity = v3_0
                        stepped:Wait()
                    end
                end
        	elseif typeof(netboost) == "number" then
    	        local vel = v3_0
    	        local rotvel = v3_0
            	while Part0 do
                    Part0.Velocity = vel
                    Part0.RotVelocity = rotvel
                    heartbeat:Wait()
                    if Part0 then
                        local newvel = vel
                        local mag = newvel.Magnitude
                        if mag < idleMag then
                            newvel = v3(0, netboost, 0)
                        else
                            local multiplier = netboost / mag
                            newvel *= v3(multiplier,  multiplier, multiplier)
                        end
                        vel = Part0.Velocity
                        rotvel = Part0.RotVelocity
                        Part0.Velocity = newvel
                        Part0.RotVelocity = v3_0
                        stepped:Wait()
                    end
                end
        	end
        end)
    end
end

local function respawnrequest()
    local c = lp.Character
    local ccfr = ws.CurrentCamera.CFrame
	local fc = Instance.new("Model")
	local nh = Instance.new("Humanoid", fc)
	lp.Character = fc
	nh.Health = 0
	lp.Character = c
	fc:Destroy()
    local con = nil
    local function confunc()
        con:Disconnect()
        ws.CurrentCamera.CFrame = ccfr
    end
    con = renderstepped:Connect(confunc)
end

local destroyhum = (method == 4) or (method == 5)
local breakjoints = (method == 0) or (method == 4)
local antirespawn = (method == 0) or (method == 2) or (method == 3)

addtools = addtools and gp(lp, "Backpack", "Backpack")

if simradius == "shp" then
    local shp = sethiddenproperty or set_hidden_property or set_hidden_prop or sethiddenprop
    if shp then
        spawn(function()
            while c and heartbeat:Wait() do
                shp(lp, "SimulationRadius", inf)
            end
        end)
    end
elseif simradius == "ssr" then
    local ssr = setsimulationradius or set_simulation_radius or set_sim_radius or setsimradius or set_simulation_rad or setsimulationrad
    if ssr then
        spawn(function()
            while c and heartbeat:Wait() do
                ssr(inf)
            end
        end)
    end
end

antiragdoll = antiragdoll and function(v)
    if v:IsA("HingeConstraint") or v:IsA("BallSocketConstraint") then
        v.Parent = nil
    end
end

if antiragdoll then
    for i, v in pairs(c:GetDescendants()) do
        antiragdoll(v)
    end
    c.DescendantAdded:Connect(antiragdoll)
end

if antirespawn then
    respawnrequest()
end

if method == 0 then
	wait(loadtime)
	if not c then
	    return
	end
end

if discharscripts then
    for i, v in pairs(c:GetChildren()) do
        if v:IsA("LocalScript") then
            v.Disabled = true
        end
    end
elseif newanimate then
    local animate = gp(c, "Animate", "LocalScript")
    if animate and (not animate.Disabled) then
        animate.Disabled = true
    else
        newanimate = false
    end
end

local hum = c:FindFirstChildOfClass("Humanoid")
if hum then
    for i, v in pairs(hum:GetPlayingAnimationTracks()) do
	    v:Stop()
    end
end

if addtools then
    for i, v in pairs(addtools:GetChildren()) do
        if v:IsA("Tool") then
            v.Parent = c
        end
    end
end

pcall(function()
    settings().Physics.AllowSleep = false
    settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
end)

local OLDscripts = {}

for i, v in pairs(c:GetDescendants()) do
	if v.ClassName == "Script" then
		table.insert(OLDscripts, v)
	end
end

local scriptNames = {}

for i, v in pairs(c:GetDescendants()) do
	if v:IsA("BasePart") then
	    local newName = tostring(i)
	    local exists = true
	    while exists do
		    exists = false
		    for i, v in pairs(OLDscripts) do
		        if v.Name == newName then
		            exists = true
		        end
		    end
		    if exists then
		        newName = newName .. "_"    
		    end
	    end
        table.insert(scriptNames, newName)
		Instance.new("Script", v).Name = newName
	end
end

c.Archivable = true
local cl = c:Clone()
for i, v in pairs(cl:GetDescendants()) do
    pcall(function()
        v.Transparency = 1
        v.Anchored = false
    end)
end

local model = Instance.new("Model", c)
model.Name = model.ClassName

model:GetPropertyChangedSignal("Parent"):Connect(function()
    if not (model and model.Parent) then
        model = nil
    end
end)

for i, v in pairs(c:GetChildren()) do
	if v ~= model then
	    if destroyhum and v:IsA("Humanoid") then
	        v:Destroy()
	    else
	        if addtools and v:IsA("Tool") then
	            for i1, v1 in pairs(v:GetDescendants()) do
	                if v1 and v1.Parent and v1:IsA("BasePart") then
	                    local bv = Instance.new("BodyVelocity", v1)
	                    bv.Velocity = v3_0
	                    bv.MaxForce = v3(1000, 1000, 1000)
	                    bv.P = 1250
	                    bv.Name = "bv_" .. v.Name
	                end
	            end
	        end
		    v.Parent = model
	    end
	end
end
local head = gp(model, "Head", "BasePart")
local torso = gp(model, "Torso", "BasePart") or gp(model, "UpperTorso", "BasePart")
if breakjoints then
    model:BreakJoints()
else
    if head and torso then
        for i, v in pairs(model:GetDescendants()) do
            if v:IsA("Weld") or v:IsA("Snap") or v:IsA("Glue") or v:IsA("Motor") or v:IsA("Motor6D") then
                local save = false
                if (v.Part0 == torso) and (v.Part1 == head) then
                    save = true
                end
                if (v.Part0 == head) and (v.Part1 == torso) then
                    save = true
                end
                if save then
                    if hedafterneck then
                        hedafterneck = v
                    end
                else
                    v:Destroy()
                end
            end
        end
    end
    if method == 3 then
        spawn(function()
            wait(loadtime)
            if model then
                model:BreakJoints()
            end
        end)
    end
end

cl.Parent = c
for i, v in pairs(cl:GetChildren()) do
	v.Parent = c
end
cl:Destroy()

local modelDes = {}
for i, v in pairs(model:GetDescendants()) do
    if v:IsA("BasePart") then
        i = tostring(i)
        local con = nil
        con = v:GetPropertyChangedSignal("Parent"):Connect(function()
            if not (v and v.Parent) then
                con:Disconnect()
                modelDes[i] = nil
            end
        end)
        modelDes[i] = v
    end
end
local modelcolcon = nil
local function modelcolf()
    if model then
        for i, v in pairs(modelDes) do
			v.CanCollide = false
		end
    else
        modelcolcon:Disconnect()
    end
end
modelcolcon = stepped:Connect(modelcolf)
modelcolf()

for i, scr in pairs(model:GetDescendants()) do
	if (scr.ClassName == "Script") and table.find(scriptNames, scr.Name) then
		local Part0 = scr.Parent
		if Part0:IsA("BasePart") then
			for i1, scr1 in pairs(c:GetDescendants()) do
				if (scr1.ClassName == "Script") and (scr1.Name == scr.Name) and (not scr1:IsDescendantOf(model)) then
					local Part1 = scr1.Parent
					if (Part1.ClassName == Part0.ClassName) and (Part1.Name == Part0.Name) then
						align(Part0, Part1)
						break
					end
				end
			end
		end
	end
end

if (typeof(hedafterneck) == "Instance") and head and head.Parent then
    local aligns = {}
    for i, v in pairs(head:GetDescendants()) do
        if v:IsA("AlignPosition") or v:IsA("AlignOrientation") then
            table.insert(aligns, v)
            v.Enabled = false
        end
    end
    spawn(function()
        while c and hedafterneck and hedafterneck.Parent do
            stepped:Wait()
        end
        if not (c and head and head.Parent) then
            return
        end
        for i, v in pairs(aligns) do
            pcall(function()
                v.Enabled = true
            end)
        end
    end)
end

for i, v in pairs(c:GetDescendants()) do
	if v and v.Parent then
		if v.ClassName == "Script" then
			if table.find(scriptNames, v.Name) then
				v:Destroy()
			end
		elseif not v:IsDescendantOf(model) then
			if v:IsA("Decal") then
			    v.Transparency = 1
			elseif v:IsA("ForceField") then
			    v.Visible = false
			elseif v:IsA("Sound") then
			    v.Playing = false
			elseif v:IsA("BillboardGui") or v:IsA("SurfaceGui") or v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
				v.Enabled = false
			end
		end
	end
end

if newanimate then
    local animate = gp(c, "Animate", "LocalScript")
    if animate then
        animate.Disabled = false
    end
end

if addtools then
    for i, v in pairs(c:GetChildren()) do
        if v:IsA("Tool") then
            v.Parent = addtools
        end
    end
end

local hum0 = model:FindFirstChildOfClass("Humanoid")
local hum1 = c:FindFirstChildOfClass("Humanoid")
if hum1 then
    ws.CurrentCamera.CameraSubject = hum1
    local camSubCon = nil
    local function camSubFunc()
        camSubCon:Disconnect()
        if c and hum1 and (hum1.Parent == c) then
            ws.CurrentCamera.CameraSubject = hum1
        end
    end
    camSubCon = renderstepped:Connect(camSubFunc)
	if hum0 then
		hum0.Changed:Connect(function(prop)
			if (prop == "Jump") and hum1 and hum1.Parent then
				hum1.Jump = hum0.Jump
			end
		end)
	else
	    lp.Character = nil
	    lp.Character = c
	end
end

local rb = Instance.new("BindableEvent", c)
rb.Event:Connect(function()
	rb:Destroy()
	sg:SetCore("ResetButtonCallback", true)
	if destroyhum then
	    c:BreakJoints()
	    return
	end
	if antirespawn then
	    if hum0 and hum0.Parent and (hum0.Health > 0) then
	        model:BreakJoints()
	        hum0.Health = 0
	    end
		respawnrequest()
	else
	    if hum0 and hum0.Parent and (hum0.Health > 0) then
	        model:BreakJoints()
	        hum0.Health = 0
	    end
	end
end)
sg:SetCore("ResetButtonCallback", rb)

spawn(function()
	while c do
		if hum0 and hum0.Parent and hum1 and hum1.Parent then
            hum1.Jump = hum0.Jump
        end
		wait()
	end
	sg:SetCore("ResetButtonCallback", true)
end)

R15toR6 = R15toR6 and hum1 and (hum1.RigType == Enum.HumanoidRigType.R15)
if R15toR6 then
	local cfr = nil
	pcall(function()
		cfr = gp(c, "HumanoidRootPart", "BasePart").CFrame
	end)
	if cfr then
		local R6parts = { 
			head = {
				Name = "Head",
				Size = v3(2, 1, 1),
				R15 = {
					Head = 0
				}
			},
			torso = {
				Name = "Torso",
				Size = v3(2, 2, 1),
				R15 = {
					UpperTorso = 0.2,
					LowerTorso = -0.8
				}
			},
			root = {
				Name = "HumanoidRootPart",
				Size = v3(2, 2, 1),
				R15 = {
					HumanoidRootPart = 0
				}
			},
			leftArm = {
				Name = "Left Arm",
				Size = v3(1, 2, 1),
				R15 = {
					LeftHand = -0.85,
					LeftLowerArm = -0.2,
					LeftUpperArm = 0.4
				}
			},
			rightArm = {
				Name = "Right Arm",
				Size = v3(1, 2, 1),
				R15 = {
					RightHand = -0.85,
					RightLowerArm = -0.2,
					RightUpperArm = 0.4
				}
			},
			leftLeg = {
				Name = "Left Leg",
				Size = v3(1, 2, 1),
				R15 = {
					LeftFoot = -0.85,
					LeftLowerLeg = -0.15,
					LeftUpperLeg = 0.6
				}
			},
			rightLeg = {
				Name = "Right Leg",
				Size = v3(1, 2, 1),
				R15 = {
					RightFoot = -0.85,
					RightLowerLeg = -0.15,
					RightUpperLeg = 0.6
				}
			}
		}
		for i, v in pairs(c:GetChildren()) do
			if v:IsA("BasePart") then
				for i1, v1 in pairs(v:GetChildren()) do
					if v1:IsA("Motor6D") then
						v1.Part0 = nil
					end
				end
			end
		end
		for i, v in pairs(R6parts) do
			local part = Instance.new("Part")
			part.Name = v.Name
			part.Size = v.Size
			part.CFrame = cfr
			part.Anchored = false
			part.Transparency = 1
			part.CanCollide = false
			for i1, v1 in pairs(v.R15) do
				local R15part = gp(c, i1, "BasePart")
				local att = gp(R15part, "att1_" .. i1, "Attachment")
				if R15part then
					local weld = Instance.new("Weld", R15part)
					weld.Name = "Weld_" .. i1
					weld.Part0 = part
					weld.Part1 = R15part
					weld.C0 = cf(0, v1, 0)
					weld.C1 = cf(0, 0, 0)
					R15part.Massless = true
					R15part.Name = "R15_" .. i1
					R15part.Parent = part
				    if att then
				        att.Parent = part
				        att.Position = v3(0, v1, 0)
				    end
				end
			end
			part.Parent = c
			R6parts[i] = part
		end
		local R6joints = {
			neck = {
				Parent = R6parts.torso,
				Name = "Neck",
				Part0 = R6parts.torso,
				Part1 = R6parts.head,
				C0 = cf(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
				C1 = cf(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
			},
			rootJoint = {
				Parent = R6parts.root,
				Name = "RootJoint" ,
				Part0 = R6parts.root,
				Part1 = R6parts.torso,
				C0 = cf(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
				C1 = cf(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
			},
			rightShoulder = {
				Parent = R6parts.torso,
				Name = "Right Shoulder",
				Part0 = R6parts.torso,
				Part1 = R6parts.rightArm,
				C0 = cf(1, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
				C1 = cf(-0.5, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
			},
			leftShoulder = {
				Parent = R6parts.torso,
				Name = "Left Shoulder",
				Part0 = R6parts.torso,
				Part1 = R6parts.leftArm,
				C0 = cf(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
				C1 = cf(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
			},
			rightHip = {
				Parent = R6parts.torso,
				Name = "Right Hip",
				Part0 = R6parts.torso,
				Part1 = R6parts.rightLeg,
				C0 = cf(1, -1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
				C1 = cf(0.5, 1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
			},
			leftHip = {
				Parent = R6parts.torso,
				Name = "Left Hip" ,
				Part0 = R6parts.torso,
				Part1 = R6parts.leftLeg,
				C0 = cf(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
				C1 = cf(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
			}
		}
		for i, v in pairs(R6joints) do
			local joint = Instance.new("Motor6D")
			for prop, val in pairs(v) do
				joint[prop] = val
			end
			R6joints[i] = joint
		end
		hum1.RigType = Enum.HumanoidRigType.R6
		hum1.HipHeight = 0
	end
end

wait()
if not c then
    return
end

local venttoggle = false
local vented = false
local mode2 = false
local attack = false
local modetoggle = false
local dead = false
local dtoggle = false
local sittoggle = false
local sit = false
local sine = 0
local mouse = lp:GetMouse()

local joints = {
    ["RootJoint"] = "",
    ["Neck"] = "",
    ["Right Hip"] = "",
    ["Left Hip"] = "",
    ["Left Shoulder"] = "",
    ["Right Shoulder"] = ""
}

for i, v in pairs(c:GetDescendants()) do
    if v:IsA("Motor6D") and (joints[v.Name] == "") and (not v:IsDescendantOf(model)) then
        joints[v.Name] = v
    end
end

for i, v in pairs(joints) do
    if v and (v ~= "") then
        v.C0 = cf(0, 0, 0)
        v.C1 = cf(0, 0, 0)
    else
        return
    end
end

local Root = gp(c, "HumanoidRootPart", "BasePart")
if not Root then
    return
end

local function replace(a)
    local b, c = a.Part0, a.Part1
    a.Part1, a.Part0 = b, c
end

replace(joints["Left Shoulder"])
replace(joints["Right Shoulder"])
replace(joints["Left Hip"])
replace(joints["Right Hip"])

for i, v in pairs(c:GetChildren()) do
    if v:IsA("Accessory") then
        v:Destroy()
    end
end

joints.Neck.C0 = cf(0, 0.3, -0.5)

mouse.Button1Down:Connect(function()
    if not (kill or mode2 or dead) then
        attack = true
        vented = false
        hum1.WalkSpeed = 0
        wait(0.5)
        hum1.WalkSpeed = 16
        attack = false
    end
end)

mouse.KeyDown:Connect(function(key)
    if not c then 
        return 
    end
    key = key:lower()
    if k == "e" then
        if not venttoggle then
            modetoggle = false
            mode2 = false
            venttoggle = true
            vented = true
            hum1.WalkSpeed = 100
            position = "ventidle"
        elseif venttoggle then
            venttoggle = false
            vented = false
            hum1.WalkSpeed = 16
        end
    elseif key == "f" then
        if not modetoggle then
            venttoggle = false
            vented = false
            modetoggle = true
            mode2 = true
            sittoggle = false
            sit = false
            hum1.WalkSpeed = 60
        elseif modetoggle then
            modetoggle = false
            mode2 = false
            hum1.WalkSpeed = 16
        end
    elseif key == "q" then
        if dtoggle == false then
            venttoggle = false
            vented = false
            modetoggle = false
            mode2 = false
            dtoggle = true
            dead = true
            sittoggle = false
            sit = false
            hum1.WalkSpeed = 0
        elseif dtoggle == true then
            dtoggle = false
            dead = false
            hum1.WalkSpeed = 16
        end
    elseif key == "c" then
        if sittoggle == false then
            venttoggle = false
            vented = false
            modetoggle = false
            mode2 = false
            dtoggle = false
            dead = false
            sittoggle = true
            sit = true
            hum1.WalkSpeed = 0
        elseif sittoggle == true then
            sittoggle = false
            sit = false
            hum1.WalkSpeed = 16
        end
    end
end)

local pose = "idle"
while stepped:Wait() and c do
    if attack then
        pose = "attack"
    elseif dead then
        pose = "dead"
    elseif sit then
        pose = "sit"
    elseif mode2 then
        if Root.Velocity.Magnitude < 2 then
            pose = "idle2"
        elseif Root.Velocity.Magnitude > 20 then
            pose = "walk2"
        end
    else
        if Root.Velocity.y > 1 then
            pose = "jump"
        elseif Root.Velocity.y < -1 then
            pose = "fall"
        elseif Root.Velocity.Magnitude < 2 then
            pose = "idle"
        elseif Root.Velocity.Magnitude < 20 then
            pose = "walk"
        elseif Root.Velocity.Magnitude > 20 then
            pose = "run"
        end 
    end
    sine += 1
    if pose == "idle" then
        joints["RootJoint"].C0 = joints["RootJoint"].C0:lerp(CFrame.new(0 + 0 * math.sin(sine/12), 0 + 0.3 * math.sin(sine/12), 0 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(0 + 10 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12))),0.1)
        joints["Right Hip"].C0 = joints["Right Hip"].C0:lerp(CFrame.new(-0.5 + 0 * math.sin(sine/12), 2 + 0.3 * math.sin(sine/12), 0.3 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(0 + 10 * math.sin(sine/12)), math.rad(20 + 0 * math.sin(sine/12)), math.rad(-3 + 0 * math.sin(sine/12))),0.1)
        joints["Left Hip"].C0 = joints["Left Hip"].C0:lerp(CFrame.new(0.5 + 0 * math.sin(sine/12), 2 + 0.3 * math.sin(sine/12), 0.3 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(0 + 10 * math.sin(sine/12)), math.rad(-20 + 0 * math.sin(sine/12)), math.rad(3 + 0 * math.sin(sine/12))),0.1)
    elseif pose == "walk" then
        joints["RootJoint"].C0 = joints["RootJoint"].C0:lerp(CFrame.new(0 + 0 * math.sin(sine/12), 0 + 0.3 * math.sin(sine/12), 0 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(-10 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12))),0.1)
        joints["Right Hip"].C0 = joints["Right Hip"].C0:lerp(CFrame.new(-0.5 + 0 * math.sin(sine/12), 2 + 0.3 * math.sin(sine/12), 0.3 + 0.3 * math.sin(sine/12)) * CFrame.Angles(math.rad(0 + 30 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12))),0.1)
        joints["Left Hip"].C0 = joints["Left Hip"].C0:lerp(CFrame.new(0.5 + 0 * math.sin(sine/12), 2 + 0.3 * math.sin(sine/12), 0.3 + -0.3 * math.sin(sine/12)) * CFrame.Angles(math.rad(0 + -30 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12))),0.1)
    elseif pose == "jump" then
        joints["RootJoint"].C0 = joints["RootJoint"].C0:lerp(CFrame.new(0 + 0 * math.sin(sine/12), 0 + 0 * math.sin(sine/12), 0 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12))),0.1)
        joints["Right Hip"].C0 = joints["Right Hip"].C0:lerp(CFrame.new(-0.5 + 0 * math.sin(sine/12), 0.5 + 0 * math.sin(sine/12), 0.5 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(15 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12))),0.1)
        joints["Left Hip"].C0 = joints["Left Hip"].C0:lerp(CFrame.new(0.5 + 0 * math.sin(sine/12), 1 + 0 * math.sin(sine/12), 0.5 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(10 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12))),0.1)
    elseif pose == "fall" then
        joints["RootJoint"].C0 = joints["RootJoint"].C0:lerp(CFrame.new(0 + 0 * math.sin(sine/12), 0 + 0 * math.sin(sine/12), 0 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12))),0.1)
        joints["Right Hip"].C0 = joints["Right Hip"].C0:lerp(CFrame.new(-0.5 + 0 * math.sin(sine/12), 0.5 + 0 * math.sin(sine/12), 0.5 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(15 + 10 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12)), math.rad(-10 + 0 * math.sin(sine/12))),0.1)
        joints["Left Hip"].C0 = joints["Left Hip"].C0:lerp(CFrame.new(0.5 + 0 * math.sin(sine/12), 1 + 0 * math.sin(sine/12), 0.5 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(10 + 5 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12)), math.rad(10 + 0 * math.sin(sine/12))),0.1)
    elseif pose == "vent" then
        joints["RootJoint"].C0 = joints["RootJoint"].C0:lerp(CFrame.new(0 + 0 * math.sin(sine/12), 0 + -8 * math.sin(sine/12), 0 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12))),0.1)
        joints["Right Hip"].C0 = joints["Right Hip"].C0:lerp(CFrame.new(-0.5 + 0 * math.sin(sine/12), 1.5 + 0 * math.sin(sine/12), 1 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(26.02 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12))),0.1)
        joints["Left Hip"].C0 = joints["Left Hip"].C0:lerp(CFrame.new(0.5 + 0 * math.sin(sine/12), 2 + 0 * math.sin(sine/12), 0 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12))),0.1)
    elseif pose == "ventidle" then
        joints["RootJoint"].C0 = joints["RootJoint"].C0:lerp(CFrame.new(0 + 0 * math.sin(sine/12), -20 + 0 * math.sin(sine/12), 0 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12))),0.1)
        joints["Right Hip"].C0 = joints["Right Hip"].C0:lerp(CFrame.new(-0.5 + 0 * math.sin(sine/12), 1.5 + 0 * math.sin(sine/12), 1 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(26.02 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12))),0.1)
        joints["Left Hip"].C0 = joints["Left Hip"].C0:lerp(CFrame.new(0.5 + 0 * math.sin(sine/12), 2 + 0 * math.sin(sine/12), 0 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12))),0.1)
    elseif pose == "idle2" then
        joints["RootJoint"].C0 = joints["RootJoint"].C0:lerp(CFrame.new(0 + 0 * math.sin(sine/20), 3 + 0.3 * math.sin(sine/20), 0 + 0 * math.sin(sine/20)) * CFrame.Angles(math.rad(0 + 20 * math.sin(sine/20)), math.rad(0 + 0 * math.sin(sine/20)), math.rad(0 + 0 * math.sin(sine/20))),0.1)
        joints["Right Hip"].C0 = joints["Right Hip"].C0:lerp(CFrame.new(-0.5 + 0 * math.sin(sine/20), 1 + 0 * math.sin(sine/20), 1 + 0 * math.sin(sine/20)) * CFrame.Angles(math.rad(20 + -20 * math.sin(sine/20)), math.rad(0 + 0 * math.sin(sine/20)), math.rad(0 + 0 * math.sin(sine/20))),0.1)
        joints["Left Hip"].C0 = joints["Left Hip"].C0:lerp(CFrame.new(0.5 + 0 * math.sin(sine/20), 2 + 0 * math.sin(sine/20), 0.5 + -0.5 * math.sin(sine/20)) * CFrame.Angles(math.rad(10 + -20 * math.sin(sine/20)), math.rad(0 + 0 * math.sin(sine/20)), math.rad(0 + 0 * math.sin(sine/20))),0.1)
    elseif pose == "walk2" then
        joints["RootJoint"].C0 = joints["RootJoint"].C0:lerp(CFrame.new(0 + 0 * math.sin(sine/20), 3 + 0.3 * math.sin(sine/20), 0 + 0 * math.sin(sine/20)) * CFrame.Angles(math.rad(-60 + 10 * math.sin(sine/20)), math.rad(0 + 0 * math.sin(sine/20)), math.rad(0 + 0 * math.sin(sine/20))),0.1)
        joints["Right Hip"].C0 = joints["Right Hip"].C0:lerp(CFrame.new(-0.4 + 0 * math.sin(sine/20), 2 + 0 * math.sin(sine/20), 0.3 + 0 * math.sin(sine/20)) * CFrame.Angles(math.rad(0 + -10 * math.sin(sine/20)), math.rad(0 + 0 * math.sin(sine/20)), math.rad(-5 + 0 * math.sin(sine/20))),0.1)
        joints["Left Hip"].C0 = joints["Left Hip"].C0:lerp(CFrame.new(0.5 + 0 * math.sin(sine/20), 1 + 0 * math.sin(sine/20), 0.5 + 0 * math.sin(sine/20)) * CFrame.Angles(math.rad(0 + -20 * math.sin(sine/20)), math.rad(0 + 0 * math.sin(sine/20)), math.rad(5 + 0 * math.sin(sine/20))),0.1)
    elseif pose == "attack" then
        joints["RootJoint"].C0 = joints["RootJoint"].C0:lerp(CFrame.new(0 + 0 * math.sin(sine/5), 0 + 0 * math.sin(sine/5), 0 + 0 * math.sin(sine/5)) * CFrame.Angles(math.rad(30 + 0 * math.sin(sine/5)), math.rad(0 + 0 * math.sin(sine/5)), math.rad(0 + 0 * math.sin(sine/5))),0.1)
        joints["Right Hip"].C0 = joints["Right Hip"].C0:lerp(CFrame.new(-0.4 + 0 * math.sin(sine/12), 2 + 0 * math.sin(sine/12), 0.5 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(30 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12)), math.rad(-4 + 0 * math.sin(sine/12))),0.1)
        joints["Left Hip"].C0 = joints["Left Hip"].C0:lerp(CFrame.new(0.4 + 0 * math.sin(sine/12), 2 + 0 * math.sin(sine/12), 0.5 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(30 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12)), math.rad(4 + 0 * math.sin(sine/12))),0.1)
    elseif pose == "sit" then
        joints["RootJoint"].C0 = joints["RootJoint"].C0:lerp(CFrame.new(0 + 0 * math.sin(sine/5), -1.8 + 0 * math.sin(sine/5), 0 + 0 * math.sin(sine/5)) * CFrame.Angles(math.rad(10 + 0 * math.sin(sine/5)), math.rad(0 + 0 * math.sin(sine/5)), math.rad(0 + 0 * math.sin(sine/5))),0.1)
        joints["Right Hip"].C0 = joints["Right Hip"].C0:lerp(CFrame.new(-0.4 + 0 * math.sin(sine/12), 1 + 0 * math.sin(sine/12), -1 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(-90 + 0 * math.sin(sine/12)), math.rad(10 + 0 * math.sin(sine/12)), math.rad(-4 + 0 * math.sin(sine/12))),0.1)
        joints["Left Hip"].C0 = joints["Left Hip"].C0:lerp(CFrame.new(0.4 + 0 * math.sin(sine/12), 1 + 0 * math.sin(sine/12), -1 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(-90 + 0 * math.sin(sine/12)), math.rad(-10 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12))),0.1)
    elseif pose == "dead" then
        joints["RootJoint"].C0 = joints["RootJoint"].C0:lerp(CFrame.new(0 + 0 * math.sin(sine/5), -2.5 + 0 * math.sin(sine/5), -1 + 0 * math.sin(sine/5)) * CFrame.Angles(math.rad(-90 + 0 * math.sin(sine/5)), math.rad(0 + 0 * math.sin(sine/5)), math.rad(0 + 0 * math.sin(sine/5))),0.1)
        joints["Right Hip"].C0 = joints["Right Hip"].C0:lerp(CFrame.new(-0.4 + 0 * math.sin(sine/12), 3 + 0 * math.sin(sine/12), 0 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12)), math.rad(-4 + 0 * math.sin(sine/12))),0.1)
        joints["Left Hip"].C0 = joints["Left Hip"].C0:lerp(CFrame.new(0.4 + 0 * math.sin(sine/12), 3 + 0 * math.sin(sine/12), 0 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12)), math.rad(4 + 0 * math.sin(sine/12))),0.1)
    end
    joints["Right Shoulder"].C0 = joints["Right Shoulder"].C0:lerp(CFrame.new(-0.4 + 0 * math.sin(sine/12), 0 + 0 * math.sin(sine/12), -0.8 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12))),0.1)
    joints["Left Shoulder"].C0 = joints["Left Shoulder"].C0:lerp(CFrame.new(0.4 + 0 * math.sin(sine/12), 0 + 0 * math.sin(sine/12), -0.8 + 0 * math.sin(sine/12)) * CFrame.Angles(math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12)), math.rad(0 + 0 * math.sin(sine/12))),0.1)
end
end)


local Tab = Window:NewTab("KeyBind Tab")
local Section = Tab:NewSection("KeyBind Info")

Section:NewKeybind("KeyBind", "Dumass", Enum.KeyCode.V, function()
	Library:ToggleUI()
end)

wait(1)

local function callback(Text)
 if Text == "Copy Link" then
  setclipboard("https://discord.gg/kJxcggMc")
elseif Text == ("Close") then
 print ("Closed")
 end
end

local NotificationBindable = Instance.new("BindableFunction")
NotificationBindable.OnInvoke = callback
--
game.StarterGui:SetCore("SendNotification",  {
 Title = "Thanks For Using FapeX";
 Text = "Join Our Discord For More Info  https://discord.gg/kJxcggMc";
 Icon = "";
 Duration = 99999999999999;
 Button1 = "Copy Link";
 Button2 = "Close";
 Callback = NotificationBindable;
})


function dragify(Frame)
dragToggle = nil
dragSpeed = .25 -- You can edit this.
dragInput = nil
dragStart = nil
dragPos = nil

function updateInput(input)
Delta = input.Position - dragStart
Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + Delta.X, startPos.Y.Scale, startPos.Y.Offset + Delta.Y)
game:GetService("TweenService"):Create(Frame, TweenInfo.new(.25), {Position = Position}):Play()
end

Frame.InputBegan:Connect(function(input)
if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
dragToggle = true
dragStart = input.Position
startPos = Frame.Position
input.Changed:Connect(function()
if (input.UserInputState == Enum.UserInputState.End) then
dragToggle = false
end
end)
end
end)

Frame.InputChanged:Connect(function(input)
if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
dragInput = input
end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
if (input == dragInput and dragToggle) then
updateInput(input)
end
end)
end