--Set PropProtection for Props

function CheckPlayer(ply, ent)

	if !ply:IsAdmin() then

		if ent.name == ply:Nick() and !ent:IsWorld() then

			return true

		else

			PAS.Notify( ply, "You are not allowed to do this!" )
			return false

		end

	else
		return true
	end
	
end
hook.Add( "PhysgunPickup", "Allow Player Pickup", CheckPlayer )
hook.Add( "CanDrive", "Allow Driving", CheckPlayer )


--Set PropProtection for Tools

function CanTool(ply, trace, tool)

	if !ply:IsAdmin() then

		if IsValid( trace.Entity ) then

			ent = trace.Entity

			if !ent:IsWorld() and ent.name == ply:Nick() then

				return true

			else

				PAS.Notify( ply, "You are not allowed to do this!" )
				return false

			end

		end

	else
		return true
	end
 	
end
hook.Add( "CanTool", "Allow Player Tool-Useage", CanTool )


--Add a Non-Admin Restriction for Property things

function PlayerProperty(ply, string, ent)

	if !ply:IsAdmin() then

		if string != "drive" and string != "persist" then

			if ent.name != nil and ent.name == ply:Nick() and !ent.IsWorld() then
			
 				return true

 			else

 				PAS.Notify( ply, "You are not allowed to do this!" )
 				return false

 			end

		else
			return false
		end

	else
		return true
	end

end
hook.Add( "CanProperty", "Allow Player Property", PlayerProperty )
