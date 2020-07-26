AddCSLuaFile()
SWEP.Base = "weapon_base"
SWEP.Category = "Ace's SWEPS"

SWEP.PrintName = "Waypoint Designator"
SWEP.Author = "Ace"
SWEP.Contact = "github.com/hiisuuii/waypointsystem-swep"
SWEP.Instructions = "R to change color, LMB to place/remove, RMB to zoom"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/ace/sw/w_macrobinoculars.mdl"

SWEP.AutoSwitchFrom = false
SWEP.AutoSwitchTo = false
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.Weight = 1 
SWEP.DrawAmmo = false
SWEP.DrawWeaponInfoBox = true
SWEP.DrawCrosshair = true
SWEP.Primary.Delay = 1
SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false

local waypointcolor = 1
local LastRld = -1
local zoomed = false

local colors = {
		[1] = "Red",
		[2] = "Green",
		[3] = "Blue",
		[4] = "Yellow",
		[5] = "Purple"
		}

if SERVER then
	util.AddNetworkString("wpname")
end

function SWEP:ShouldDrawViewModel()
	return false
end

function SWEP:Initialize()
	self:SetHoldType("camera")
end

function SWEP:Reload()
	if LastRld < CurTime() then 
		if waypointcolor >= 5 then
			waypointcolor = 1
		elseif waypointcolor >= 1 then
			waypointcolor = waypointcolor + 1
		end
		if CLIENT then
			self.Owner:ChatPrint("Waypoint color set to "..colors[waypointcolor])
		end
		//print(waypointcolor) //debug
		LastRld = CurTime() + 0.5
	end
end

function SWEP:Deploy()
	zoomed = false
end

function SWEP:Think()
	
end

function SWEP:PrimaryAttack()
	if SERVER then
		local hitpos = self.Owner:GetEyeTrace().HitPos
		local alreadyPoint = false

		for k,v in ipairs(ents.FindInSphere(hitpos,320)) do
			if v:GetClass() == "waypoint_marker" then
				if (v:GetWPOwner() == self.Owner) or (self.Owner:IsAdmin()) then
					v:Remove()
				else
					self.Owner:ChatPrint("That waypoint is not owned by you! It is owned by "..v:GetWPOwner())
				end
				alreadyPoint = true
			else
				alreadyPoint = false
			end
		end

		if alreadyPoint then
			return
		else
			ent = ents.Create("waypoint_marker")
			ent:SetPos(self.Owner:GetEyeTrace().HitPos)
			ent:SetColorType(waypointcolor)
			ent:SetWPOwner(self.Owner)
		end
	end

end

function SWEP:SecondaryAttack()
	if(self.Owner:KeyDown(IN_SPEED)) then
		if(IsFirstTimePredicted()) then
			DermaPanel()
			//print("dicks") //debug
		zoomed = false
		end
	elseif not (self.Owner:KeyDown(IN_SPEED)) then
		if not(zoomed) then
			if(IsFirstTimePredicted()) then
			//if CLIENT then
				self.Owner:SetFOV(30,0.3)
			//end
			zoomed = true
			end
		elseif(zoomed) then
			if(IsFirstTimePredicted()) then
			//if CLIENT then
				self.Owner:SetFOV(0,0.3)
			//end
			zoomed = false
			end
		end
	end
end

function SWEP:DrawHUD()
	if(zoomed) then
		surface.SetDrawColor(0, 0, 0, 255)
		surface.SetTexture(surface.GetTextureID("ace/binocularhud"))
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	end
end

function SWEP:AdjustMouseSensitivity()
     
	//if self.Owner:KeyDown(IN_ATTACK2) then
	if(zoomed) then
       	return 0.25
   	else 
   	 	return 1
   	end
end

local WaypointName = ""
function DermaPanel()
	if CLIENT then
		local Frame = vgui.Create( "DFrame" )
		local framew = ScrW()* 300/1920
		local frameh = ScrH() * 75/1080
		Frame:SetPos( ScrW()/2 - (framew)/2, ScrH()/2 - (frameh)/2 ) 
		Frame:SetSize( framew, frameh ) 
		Frame:SetTitle( "Set waypoint name" ) 
		Frame:SetVisible( true ) 
		Frame:SetDraggable( true ) 
		Frame:ShowCloseButton( true ) 
		Frame:MakePopup()

		local NameEntry = vgui.Create("DTextEntry", Frame)
		NameEntry:SetPos(10, 40)
		NameEntry:SetSize(framew - (ScrW() * 20/1920),25)
		NameEntry:SetText("Waypoint Name")
		NameEntry:SetUpdateOnType(true)
		NameEntry.OnValueChange = function(self)
			WaypointName = self:GetValue()

			net.Start("wpname")
			net.WriteString(WaypointName)
			net.SendToServer()

		end
	end
end



