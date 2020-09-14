local remoteEvents = game.ReplicatedStorage:WaitForChild("remoteEvents"); 
local sounds = game.ReplicatedStorage:WaitForChild("Sounds")
local enemyHumanoid
local hitPartChildren
local shotDamage
local bullet = game.ReplicatedStorage:WaitForChild("bullet")
local bulletImpact = game.ReplicatedStorage:WaitForChild("bulletImpact")

local bloodEffect = game.ReplicatedStorage:WaitForChild("bloodHit")

local neckC0 = CFrame.new(0, 0.8, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1);
local waistC0 = CFrame.new(0, 0.2, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1);

--Remotes--

local player

local lastShot = tick()

local canShootRemote = remoteEvents:WaitForChild("CanShoot")
local canReloadRemote = remoteEvents:WaitForChild("CanReload")
local hitRemote = remoteEvents:WaitForChild("Hit")
local reloadRemote = remoteEvents:WaitForChild("Reload")
local shootRemote = remoteEvents:WaitForChild("Shoot")
local rayRemote = remoteEvents:WaitForChild("RayEffect")
local bashRemote = remoteEvents:WaitForChild("Bash")
--Sounds--
local emptySound = sounds:WaitForChild("emptyChamber")
local reloadSound = sounds:WaitForChild("shotgunReload")

--Functions--

remoteEvents.setup.OnServerEvent:Connect(function(player, weapon)
	local weapon = weapon:Clone();
	local joint = Instance.new("Motor6D")
	joint.Part0 = player.Character.RightHand;
	joint.Part1 = weapon.Handle;
	joint.Parent = weapon.Handle;
	weapon.Parent = player.Character;
end)

remoteEvents.tiltAt.OnServerEvent:Connect(function(player, theta)
	local neck = player.Character.Head.Neck;
	local waist = player.Character.UpperTorso.Waist;
	
	neck.C0 = neckC0 * CFrame.fromEulerAnglesYXZ(theta*0.5, 0, 0);
	waist.C0 = waistC0 * CFrame.fromEulerAnglesYXZ(theta*0.5, 0, 0);
end)

local function canReload(player, ammo, magMax, reserveAmmo)
	
	if ammo < magMax and reserveAmmo > 0 --[[and math.abs(lastShot - tick()) > (60/90)]] then
		
		return true
		
	end
	
	return false
	
end

local function reload(player, ammo, magMax, reserveAmmo, gun)
	if reserveAmmo > 0 and canReload(player, ammo, magMax, reserveAmmo) then
		--wait(.1)
		local repReloadSound = reloadSound:Clone();
		repReloadSound.Parent = gun:WaitForChild("fakeMuzzle")
		repReloadSound.PlayOnRemove = true
		repReloadSound.PlaybackSpeed = (math.random(3)/15)+.85
		repReloadSound:Destroy()
		
		local gunType
		
		if gun.Name == "Mossberg 500" then gunType = "shotgun" end
		if gun.Name == "Glock 17" then gunType = "pistol" end
		
		if gunType == "shotgun" then
			ammo = ammo + 1
			reserveAmmo = reserveAmmo - 1
		end
		if gunType == "pistol" then
			if reserveAmmo > 0 then
				reserveAmmo = reserveAmmo - (magMax - ammo)
				ammo = magMax
			else
				reserveAmmo = 0
			end
		end
		
		return ammo, reserveAmmo
	end
end

local function canShoot(player, ammo, ROF)
	if math.abs(lastShot - tick()) > (60/ROF) then
		if ammo > 0 then
			return true
		else
			local repEmptySound = emptySound:Clone();
			repEmptySound.Parent = player.Character:WaitForChild("Mossberg 500").fakeMuzzle
			repEmptySound.PlayOnRemove = true
			repEmptySound.PlaybackSpeed = (math.random(3)/15)+.85
			repEmptySound:Destroy()
		end
	end
	return false
end

local function shoot(player, sound, gunModel)
	lastShot = tick()
	local repShootSound = sound:Clone();
	repShootSound.Parent = gunModel:WaitForChild("fakeMuzzle")
	repShootSound.PlayOnRemove = true
	repShootSound.PlaybackSpeed = (math.random(3)/15)+.85
	repShootSound:Destroy()
end

local function bash(player, target)
	
end

local numberKeypoints = {
	NumberSequenceKeypoint.new(0,0);
	NumberSequenceKeypoint.new(1, 6);
}

local colorKeypoints = {
	ColorSequenceKeypoint.new( 0, Color3.new(1, 0, 0)),
	ColorSequenceKeypoint.new(.5, Color3.new(.6, 0, 0)),
	ColorSequenceKeypoint.new( 1, Color3.new(.2, 0, 0))
}

local function hit(player, part, position, distance, normal, damage, range)
	if not part then return end
	if not part.Parent:FindFirstChild("Humanoid") then 
		local bulletImpactClone = bulletImpact:Clone()
		game:GetService("Debris"):AddItem(bulletImpactClone, 1)
		bulletImpactClone.Parent = workspace
		bulletImpactClone.impact.Color = ColorSequence.new(part.Color)
		bulletImpactClone.Position = position
		bulletImpactClone.Orientation = part.Orientation
		bulletImpactClone.impact.Enabled = true
		
		wait(.1)
		bulletImpactClone.impact.Enabled = false
		bulletImpactClone.impactSound:Play()
		return
	end
	
	--wait(distance/150)
	
	shotDamage = damage
	if distance > range then shotDamage = damage / math.sqrt(distance); end
	if part.Name == "FakeHead" or part.Name == "headPart" then shotDamage = shotDamage * 3 end
	part.Parent:FindFirstChild("Humanoid").Health = part.Parent:FindFirstChild("Humanoid").Health - shotDamage

	--bloodDecal
	
	
	
	if part.Name == "FakeHead" and part:FindFirstChild("Neck") then 
		part:FindFirstChild("NeckSocketUpper"):Destroy()
		part:FindFirstChild("Neck"):Destroy()
		part.Parent.neckStub.noHeadBlood.Enabled = true
	end
	
	--local hitForce = Instance.new("BodyThrust", part.Parent:FindFirstChild("UpperTorso")) 
	--hitForce.Force = Vector3.new(10,15,10) - ((Vector3.new(10,15,10)/150 * distance))
	--hitForce.Location = position
	--game:GetService("Debris"):AddItem(hitForce, .02)
	
end

--Listeners--

hitRemote.OnServerEvent:Connect(hit)
shootRemote.OnServerEvent:Connect(shoot)
bashRemote.OnServerEvent:Connect(bash)
canShootRemote.OnServerInvoke = canShoot
canReloadRemote.OnServerInvoke = canReload
reloadRemote.OnServerInvoke = reload