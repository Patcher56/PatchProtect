-----------------
--  SET OWNER  --
-----------------

-- SET OWNER OF PROPS
function sv_PProtect.SpawnedProp( ply, mdl, ent )

	ent.PatchPPOwner = ply
	ent:SetNetworkedEntity("PatchPPOwner", ply)

end
hook.Add("PlayerSpawnedProp", "SpawnedProp", sv_PProtect.SpawnedProp)

-- SET OWNER OF ENTS
function sv_PProtect.SpawnedEnt( ply, ent )

	ent.PatchPPOwner = ply
	ent:SetNetworkedEntity("PatchPPOwner", ply)

end
hook.Add("PlayerSpawnedEffect", "SpawnedEffect", sv_PProtect.SpawnedEnt)
hook.Add("PlayerSpawnedNPC", "SpawnedNPC", sv_PProtect.SpawnedEnt)
hook.Add("PlayerSpawnedRagdoll", "SpawnedRagdoll", sv_PProtect.SpawnedEnt)
hook.Add("PlayerSpawnedSENT", "SpawnedSENT", sv_PProtect.SpawnedEnt)
hook.Add("PlayerSpawnedSWEP", "SpawnedSWEP", sv_PProtect.SpawnedEnt)
hook.Add("PlayerSpawnedVehicle", "SpawnedVehicle", sv_PProtect.SpawnedEnt)


--SET OWNER OF TOOL-ENTS
if cleanup then
	
	local Clean = cleanup.Add

	function cleanup.Add(ply, type, ent)

		if ply:IsPlayer() and ent:IsValid() and ply.spawned == true then

			ent.PatchPPOwner = ply
			ent:SetNetworkedEntity("PatchPPOwner", ply)
			ply.spawned = false

		end

		Clean(ply, type, ent)

	end

end



--------------------
--  CHECK PLAYER  --
--------------------

function sv_PProtect.checkPlayer(ply, ent)

	if tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 then return true end
	if ply:IsAdmin() and tonumber(sv_PProtect.Settings.PropProtection["noantiadmin"]) == 1 then return true end

	if !ent:IsWorld() and ent.PatchPPOwner == ply then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to do this!" )
		return false
	end

end
hook.Add( "PhysgunPickup", "AllowPlayerPickup", sv_PProtect.checkPlayer )
hook.Add( "CanDrive", "AllowDriving", sv_PProtect.checkPlayer )
hook.Add( "CanUse", "AllowUseing", sv_PProtect.checkPlayer )


----------------------------
--  TOOL PROP PROTECTION  --
----------------------------

function sv_PProtect.canTool(ply, trace, tool)

	if tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 then return true end
	if ply:IsAdmin() and tonumber(sv_PProtect.Settings.PropProtection["noantiadmin"]) == 1 then return true end

	local ent = trace.Entity
	if ent:IsWorld() and tonumber(sv_PProtect.Settings.PropProtection["tool_world"]) == 0 then return false end
	if ent.PatchPPOwner == ply or ent:IsWorld() then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to do this!" )
		return false
	end
 	
end
hook.Add( "CanTool", "AllowToolUsage", sv_PProtect.canTool )



--------------------------------
--  PROPERTY PROP PROTECTION  --
--------------------------------

function sv_PProtect.playerProperty(ply, string, ent)

	if tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 then return true end
	if ply:IsAdmin() and tonumber(sv_PProtect.Settings.PropProtection["noantiadmin"]) == 1 then return true end

	if string == "drive" and tonumber(sv_PProtect.Settings.PropProtection["cdrive"]) == 0 then return false end

	if !ent:IsWorld() and ent.PatchPPOwner == ply and string != "persist" then
 		return true
 	else
 		sv_PProtect.Notify( ply, "You are not allowed to do this!" )
 		return false
 	end

end
hook.Add( "CanProperty", "AllowProperty", sv_PProtect.playerProperty )



------------------------------------------
--  DISCONNECTED PLAYER'S PROP CLEANUP  --
------------------------------------------

-- PLAYER LEFT SERVER
function sv_PProtect.setCleanupProps( ply )

	local plyname = ply:Nick()
	
	if tonumber(sv_PProtect.Settings.PropProtection["propdelete"]) == 0 or tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 then return end

	for k, v in pairs( ents.GetAll() ) do

		ent = v
		if ent.PatchPPOwner == ply then
			ent.PatchPPCleanup = ply:Nick()
		end

	end
	
	-- Create Timer
	timer.Create( "CleanupPropsOf" .. plyname , tonumber(sv_PProtect.Settings.PropProtection["propdelete_delay"]), 1, function()

		for k, v in pairs( ents.GetAll() ) do

			ent = v
			if ent.PatchPPCleanup == plyname then
				ent:Remove()
			end

		end
		print( "[PatchProtect - Cleanup] Removed " .. plyname .. "'s Props!" )

	end )

end
hook.Add( "PlayerDisconnected", "CleanupDisconnectedPlayersProps", sv_PProtect.setCleanupProps )

-- PLAYER CAME BACK
function sv_PProtect.checkComeback( ply )

	if tonumber(sv_PProtect.Settings.PropProtection["propdelete"]) == 0 or tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 then return end

	if timer.Exists( "CleanupPropsOf" .. ply:Nick() ) then
		timer.Destroy( "CleanupPropsOf" .. ply:Nick() )
	end

	if ent.PatchPPCleanup == ply then
		ent.PatchPPCleanup = ""
	end

end
hook.Add( "PlayerSpawn", "CheckAbortCleanup", sv_PProtect.checkComeback )



---------------------------------
--  CLEANUP MAP/PLAYERS PROPS  --
---------------------------------

-- CLEANUP EVERYTHING
function sv_PProtect.CleanupEverything()

	if !ply:IsAdmin() and !ply:IsSuperAdmin() then return end

	game.CleanUpMap()
	sv_PProtect.InfoNotify(ply, "Cleaned Map!")

end
concommand.Add("btn_cleanup", sv_PProtect.CleanupEverything)

-- CLEANUP PLAYERS PROPS
function sv_PProtect.CleanupPlayersProps( ply, cmd, args )

	if !ply:IsAdmin() and !ply:IsSuperAdmin() then return end

	for k, v in pairs( ents.GetAll() ) do

		ent = v
		if ent.PatchPPOwner == tostring(args[1]) then
			ent:Remove()
		end

	end

	sv_PProtect.InfoNotify(ply, "Cleaned " .. tostring(args[1]) .. "'s Props!")

end
concommand.Add("btn_cleanup_player", sv_PProtect.CleanupPlayersProps)
