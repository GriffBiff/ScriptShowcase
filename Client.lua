local replicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService") 

--	replicate guns

--mossberg
local repShotgunModel = replicatedStorage:WaitForChild("Mossberg 500 Persuader (Func)");
local shotgunFake = replicatedStorage:WaitForChild("Mossberg 500");
local shotgunModel = repShotgunModel:Clone();

local muzzleFlare = shotgunModel.fakeMuzzle.muzzleFlare
local muzzleFlash = shotgunModel.fakeMuzzle.muzzleFlash

--glock 17
local repGlock17Model = replicatedStorage:WaitForChild("Glock 17 (Func)");
local glock17Model = repGlock17Model:Clone();
local glock17Fake = replicatedStorage:WaitForChild("Glock 17");

--\player & currentCamera/--
local Players = game:GetService("Players")
local cam = game.Workspace.CurrentCamera
local player = Players.LocalPlayer
local humanoid = player.CharacterAdded:Wait():WaitForChild("Humanoid");
local viewModel = replicatedStorage:WaitForChild("viewModel"):Clone();
humanoid.JumpPower = 10


--global gun contributors
local bulletImpact = game.ReplicatedStorage:WaitForChild("bulletImpact")
local rayCastEvent = script.rayCast
viewModel.Parent = cam;
local bloodHit = replicatedStorage:WaitForChild("bloodHit")
local bloodEffect = replicatedStorage:WaitForChild("bloodHit")
local muzzle

local hitSound = replicatedStorage.Sounds:WaitForChild("hitBasic")
local fireSound

local currentGunModel
local weaponEquipped
local reloading
local reserveAmmo
local ammoCount
local currentGun

local comp = 0
local compGoal
local compensating = false
local rateOfFire
local weaponRecoil
local magMax

local perfectJoint
local difference

local currentGuns = {"Mossberg 500", "Glock 17"}


--\improve stepsound & control speed/--
--local stepSound = humanoid.Parent.Head:WaitForChild("Running")
--stepSound.SoundId = "rbxassetid://1078976955"
--stepSound.PlaybackSpeed = .85
--stepSound.Volume = .05

local strafeAccountSpeed = 0

--\music/--
local music = replicatedStorage.Sounds:WaitForChild("music")
music:Play() 


local actionService = game:GetService("ContextActionService")


--\GUI/--
local mainGui = player.PlayerGui:WaitForChild("mainGui")
local ammoGUI = mainGui:WaitForChild("Ammo")
local crosshair = mainGui:WaitForChild("Crosshair")

--\bullet effects/--
local bloodDecal = game.ReplicatedStorage:WaitForChild("bloodDecal")


--\gun parts/--
local muzzleFlareSmoke


--\remotes/--
local remoteEvents = replicatedStorage:WaitForChild("remoteEvents");
local canShoot = remoteEvents:WaitForChild("CanShoot")
local canReload = remoteEvents:WaitForChild("CanReload")
local hitRemote = remoteEvents:WaitForChild("Hit")
local reloadRemote = remoteEvents:WaitForChild("Reload")
local shootRemote = remoteEvents:WaitForChild("Shoot")
local rayRemote = remoteEvents:WaitForChild("RayEffect")
local bashCast = remoteEvents:WaitForChild("Bash")
local stopReload

--\mouse handle/--
local mouse = player:GetMouse()
mouse.Icon = " "
--mouse.Icon = "rbxassetid://57571495"


--\shotgun setup/
shotgunModel.Parent = viewModel;
local holdAnimation = shotgunModel.Scripts:WaitForChild("holdAnim")
local holdAnimTrack = shotgunModel.Humanoid:LoadAnimation(holdAnimation)
local pumpAction = shotgunModel.Scripts:WaitForChild("pumpAction")
local pumpActionTrack = shotgunModel.Humanoid:LoadAnimation(pumpAction)
local loadShell = shotgunModel.Scripts:WaitForChild("loadShell")
local loadShellTrack = shotgunModel.Humanoid:LoadAnimation(loadShell)
local rootPart = shotgunModel.HumanoidRootPart
remoteEvents.setup:FireServer(shotgunFake);

--\glock17 setup/--
glock17Model.Parent = viewModel;
remoteEvents.setup:FireServer(glock17Fake);

--setup mutable weapon-head motor
local joint = Instance.new("Motor6D");
joint.Name = "headToWeapon"

math.randomseed(tick())

-- \ OBJECTS / --

local scaleKeypoints = {
	--time, size
	NumberSequenceKeypoint.new(0,.7);
	NumberSequenceKeypoint.new( .4, 1);
	NumberSequenceKeypoint.new( 1, 1.2);
}

local colorKeypoints = {
	ColorSequenceKeypoint.new( 0, Color3.new(1, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.new(.6, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.new(.2, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.new(.2, 0, 0))
}

local transKeypoints = {
	--time, transparency
	NumberSequenceKeypoint.new( 0, 0);
	NumberSequenceKeypoint.new( .5, 1);
	NumberSequenceKeypoint.new( 1, 1);
}

-- \ COROUTINES / --

local newThread = coroutine.wrap(function()
    print("hola")
	wait(1)
end)

-- \ FUNCTIONS / --

local function equippedWeapon(weapon)
	if weaponEquipped ~= weapon then
		if currentGun then currentGun.Parent = game.Lighting; end
		if weapon == 2 then
			print("equipped glock")
		
			glock17Model.Parent = viewModel
			--mutate head motor for glock
			joint.C0 = CFrame.new(.8, -1, -2);
			joint.Part0 = viewModel.Head;
			joint.Part1 = glock17Model.Handle;
			joint.Parent = viewModel.Head;
			joint.C1 = joint.Part1.CFrame:inverse() * joint.Part0.CFrame * joint.C0
			
			perfectJoint = joint.C1
			
			fireSound = replicatedStorage:WaitForChild("Sounds"):WaitForChild("glockFire")
			currentGunModel = player.Character:WaitForChild("Glock 17")
			currentGun = glock17Model
			
			ammoCount = glock17Model:WaitForChild("ammoCount")
			reserveAmmo = 30
			magMax = 17
			
			rateOfFire = 1200
		end
		if weapon == 1 then
			print("equipped mossberg")
			
			shotgunModel.Parent = viewModel
			--mutate head motor for mossberg
			joint.C0 = CFrame.new(.8, -1, -2);
			joint.Part0 = viewModel.Head;
			joint.Part1 = shotgunModel.Handle;
			joint.Parent = viewModel.Head;
			joint.C1 = joint.Part1.CFrame:inverse() * joint.Part0.CFrame * joint.C0
			
			perfectJoint = joint.C1
			
			fireSound = replicatedStorage:WaitForChild("Sounds"):WaitForChild("mossbergFire")
			currentGunModel = player.Character:WaitForChild("Mossberg 500")
			currentGun = shotgunModel
			
			ammoCount = shotgunModel:WaitForChild("ammoCount")
			reserveAmmo = 20
			magMax = 6
			
			rateOfFire = 90
		end
		muzzle = currentGun:WaitForChild("fakeMuzzle")
		
		muzzleFlareSmoke = currentGun:WaitForChild("fakeMuzzle"):WaitForChild("muzzleFlareSmoke")
	end
end

local function updateArm(key)
	if weaponEquipped then
		local shoulder = viewModel[key.."UpperArm"][key.."Shoulder"];
		local cf = currentGun[key].CFrame * CFrame.Angles(math.pi/2, 0, 0) * CFrame.new(0, 1.5, 0);
		shoulder.C1 = cf:inverse() * shoulder.Part0.CFrame * shoulder.C0;
	end
end

local debounce = 0

--sounds not created in-function
local shotgunPump = replicatedStorage.Sounds:WaitForChild("shotgun pump")
local headshotSound = replicatedStorage.Sounds:WaitForChild("headShot")

local function onDied()
	viewModel.Parent = nil;
end

local function onUpdate(dt)
	if humanoid.Health > 0 then
		viewModel.Head.CFrame = cam.CFrame
		updateArm("Left")
		updateArm("Right");
		humanoid.WalkSpeed = strafeAccountSpeed + 14
		--remoteEvents.tiltAt:FireServer(math.asin(cam.CFrame.LookVector.y));
		if debounce == 0 then
			holdAnimTrack:Play()
			debounce = 1
			wait(2)
			debounce = 0
		end
	end
end

local function onInputBegan(input, process)
	if input.KeyCode == Enum.KeyCode.S then
		strafeAccountSpeed = -2;
	end
	if input.KeyCode == Enum.KeyCode.Two then
		equippedWeapon(2);
		weaponEquipped = 2;
	end
	if input.KeyCode == Enum.KeyCode.One then
		equippedWeapon(1);
		weaponEquipped = 1;
	end
end

local function onInputEnded(input, process)
	if input.KeyCode == Enum.KeyCode.S then
		strafeAccountSpeed = 0
	end
end

function ReturnNormal(PartCF,RayNorm)
    if PartCF.lookVector - RayNorm == Vector3.new(0,0,0) then
        return "Front",5
    elseif PartCF.lookVector + RayNorm == Vector3.new(0,0,0) then
        return "Back",2
    else
        local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = PartCF:components()
        if Vector3.new(R01,R11,R21) == RayNorm then
            return "Top", 1
        elseif Vector3.new(-R01,-R11,-R21) == RayNorm then
            return "Bottom",4
        elseif Vector3.new(-R00,-R10,-R20) == RayNorm then
            return "Left",3
        elseif Vector3.new(R00,R10,R20) == RayNorm then
            return "Right",0
        end
    end
	return
end

local function compensation(start, difference)
	compensating = true
	for i = 0, 100, 10 do	
		game:GetService("RunService").RenderStepped:Wait();
		joint.C1 = start:Lerp(perfectJoint, i/100);
	end
	compensating = false
end

local function reload()
	while canReload:InvokeServer(ammoCount.Value, magMax, reserveAmmo) and not reloading do
		
		print("reloading")
		
		reloading = true
		 
		loadShellTrack:Play()
		
		wait(.7)
		
		local newAmmo, newReserve = reloadRemote:InvokeServer(ammoCount.Value, magMax, reserveAmmo, currentGunModel)
		
		if newAmmo then
			ammoCount.Value = newAmmo
			reserveAmmo = newReserve
			ammoGUI.Text = ammoCount.Value.."/"..reserveAmmo
		end
		
		reloading = false
			
	end
end

local function bash()
	local ray = Ray.new(muzzle.CFrame.p, ((viewModel.Head.CFrame * CFrame.new(0, 0, -250).p) - muzzle.CFrame.p).unit * 500)
	local touch, position, normal = workspace:FindPartOnRay(ray, player.Character, false, true)
	if touch then
		bashCast:FireServer(touch)
	end
end

local PicSize = 1

local function applyBlood(touch, position, normal)
	local SizeWidth = touch.Size.X
	local SizeHeight = touch.Size.Y
	local Face, Val = ReturnNormal(touch.CFrame,normal)
	if Face == nil then
		Face, Val = "Front", 5
	end
	if Face == "Top" or Face == "Bottom" then
		SizeWidth = touch.Size.Z
	    SizeHeight = touch.Size.X
	elseif Face == "Right" or Face == "Left" then
		SizeWidth = touch.Size.Z
		SizeHeight = touch.Size.Y
	end
		
	local bloodDecalClone = bloodDecal:Clone()
	bloodDecalClone.Parent = touch
	bloodDecalClone.Face = Val
	bloodDecalClone.CanvasSize = Vector2.new(SizeWidth,SizeHeight)
	local Size = -(touch.CFrame:toObjectSpace(CFrame.new(position))).p
	local bloodImage = bloodDecalClone.bulletWound
	 if Face == "Front" then
	 	bloodImage.Position = UDim2.new(.5+(Size.X/(SizeWidth)),-PicSize/2,.5+(Size.Y/(SizeHeight)),-PicSize/2)
	 elseif Face == "Back" then
	    bloodImage.Position = UDim2.new(.5+(-Size.X/(SizeWidth)),-PicSize/2,.5+(Size.Y/(SizeHeight)),-PicSize/2)
	 elseif Face == "Right" then
	    bloodImage.Position = UDim2.new(.5+(Size.Z/(SizeWidth)),-PicSize/2,.5+(Size.Y/(SizeHeight)),-PicSize/2)
	 elseif Face == "Left" then
	    bloodImage.Position = UDim2.new(.5+(-Size.Z/(SizeWidth)),-PicSize/2,.5+(Size.Y/(SizeHeight)),-PicSize/2)
	 elseif Face == "Top" then
	    bloodImage.Position = UDim2.new(.5+(Size.Z/(SizeWidth)),-PicSize/2,.5+(-Size.X/(SizeHeight)),-PicSize/2)
	 elseif Face == "Bottom" then
	    bloodImage.Position = UDim2.new(.5+(Size.Z/(SizeWidth)),-PicSize/2,.5+(Size.X/(SizeHeight)),-PicSize/2)
	 end
	
	local bloodHitClone = bloodEffect:Clone()
	bloodHitClone.Parent = workspace
	bloodHitClone.CFrame = CFrame.new(position.X, position.Y, position.Z) * CFrame.Angles(touch.Rotation.X, touch.Rotation.X, touch.Rotation.Z)
	bloodHitClone.bloodEffect.EmissionDirection = Face
	bloodHitClone.smallBloodEffect.EmissionDirection = Face

	local bloodHitWeld = Instance.new("WeldConstraint")
	bloodHitWeld.Parent = bloodHitClone
	bloodHitWeld.Part0 = bloodHitClone
	bloodHitWeld.Part1 = touch
	
	bloodHitClone.bloodEffect.Size = NumberSequence.new(scaleKeypoints)
	bloodHitClone.smallBloodEffect.Size = NumberSequence.new(scaleKeypoints)
	
	bloodHitClone.bloodEffect.Color = ColorSequence.new(colorKeypoints)
	bloodHitClone.smallBloodEffect.Color = ColorSequence.new(colorKeypoints)
	
	bloodHitClone.bloodEffect.Transparency = NumberSequence.new(transKeypoints)
	bloodHitClone.smallBloodEffect.Transparency = NumberSequence.new(transKeypoints)
	
	game:GetService("Debris"):AddItem(bloodHitClone, 1.5)

end

local distance
local lastShot = tick()
local optimize

local function fire()
	optimize = tick()
	--newThread()
 	if weaponEquipped and math.abs(lastShot - tick()) > (60/rateOfFire) and ammoCount.Value > 0 --[[canShoot:InvokeServer(ammoCount.Value, rateOfFire)]] then
	lastShot = tick()
	
		if reloading then
			stopReload = true
			loadShellTrack:Stop()
		end
		
		muzzleFlash.Enabled = true
		muzzleFlareSmoke.Enabled = true
		muzzleFlare.Enabled = true
		shootRemote:FireServer(fireSound, currentGunModel)
		
		if currentGuns[weaponEquipped] == "Mossberg 500" then
			for i = 0, 8, 1 do
				local ray = Ray.new(muzzle.CFrame.p, ((viewModel.Head.CFrame * CFrame.fromAxisAngle(Vector3.new(math.pi*math.random(-10,10)/((-1*-1)*500), math.pi*math.random(-10,10)/((-1)*500), 0).unit, math.random(1,4)*(0.03/(-1)*-1)) * CFrame.new(0, 0, -50).p) - muzzle.CFrame.p).unit * 500)
				local touch, position, normal = workspace:FindPartOnRay(ray, player.Character, false, true)
	
				if touch then
					distance = (position-muzzle.CFrame.p) .magnitude
					hitRemote:FireServer(touch, position, distance, normal, 50, 20)
					if touch.Parent:FindFirstChild("Humanoid") then
						applyBlood(touch, position, normal)
					elseif touch.Name == "FakeHead" or touch.Name == "headPart" then
						headshotSound:Play()
					end
				end
				
				rayCastEvent:Fire(position, muzzle.CFrame.p)
				weaponRecoil = .6
			end
		end
		
		if currentGuns[weaponEquipped] == "Glock 17" then
			local ray = Ray.new(muzzle.CFrame.p, ((viewModel.Head.CFrame * CFrame.new(0, 0, -1000).p) - muzzle.CFrame.p).unit * 150)
			local touch, position, normal = workspace:FindPartOnRay(ray, player.Character, false, true)
			
			if touch then
				distance = (position-muzzle.CFrame.p).magnitude
				hitRemote:FireServer(touch, position, distance, normal, 30, 80)
				if touch.Parent:FindFirstChild("Humanoid") then
					applyBlood(touch, position, normal)
				elseif touch.Name == "FakeHead" or touch.Name == "headPart" then
					headshotSound:Play()
				end
			end
				
			rayCastEvent:Fire(position, muzzle.CFrame.p)
			weaponRecoil = .4
		end
		
		
		ammoCount.Value = ammoCount.Value - 1
		ammoGUI.Text = ammoCount.Value.."/"..reserveAmmo
		
		--compGoal = joint.C1
		
		cam.CFrame = cam.CFrame * CFrame.fromAxisAngle(Vector3.new(math.pi/2,math.pi*math.random(-3,3)/30,0).unit*weaponRecoil, 0.1*weaponRecoil)
		joint.C1 = joint.C1 * CFrame.Angles((math.random(10,20)/35)*-1*weaponRecoil,((math.random(-10,10)-3)/100)*weaponRecoil,0)	
		joint.C1 = joint.C1 * CFrame.new(0 * weaponRecoil, .1 * weaponRecoil, -1.5 * weaponRecoil)
		
		
		difference = (joint.C1.p - perfectJoint.p).magnitude;
		--print(difference)
		compensation(joint.C1, difference);
		
		print(tick() - optimize)
		
		wait()
		muzzleFlare.Enabled = false
		muzzleFlash.Enabled = false
		muzzleFlareSmoke.Enabled = false
		pumpActionTrack:Play();
		if currentGuns[weaponEquipped] == "Mossberg 500" then shotgunPump:Play(); end
		
		wait(.7)
		
	end
end

player.CameraMode = Enum.CameraMode.LockFirstPerson

humanoid.Died:Connect(onDied);
mouse.Button1Down:Connect(fire);
actionService:BindAction("Reload", reload, false, Enum.KeyCode.R)
--mouse.Button2Down:Connect(bash);
game:GetService("RunService").RenderStepped:Connect(onUpdate);
game:GetService("UserInputService").InputBegan:Connect(onInputBegan);
game:GetService("UserInputService").InputEnded:Connect(onInputEnded);