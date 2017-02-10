AddCSLuaFile( )

ENT.Base 			= "ent_fizzler_base"

ENT.Editable		= true
ENT.PrintName		= "Laser Field"
ENT.Category		= "Aperture Science"
ENT.Spawnable		= true
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction( ply, trace, ClassName )

	if ( !trace.Hit ) then return end
	
	local firstLaserField = ents.Create( ClassName )
	firstLaserField:SetPos( trace.HitPos )
	firstLaserField:SetModel( "models/props/fizzler_dynamic.mdl" )
	firstLaserField:SetAngles( trace.HitNormal:Angle() )
	firstLaserField:Spawn()
	firstLaserField:SetAngles( firstLaserField:LocalToWorldAngles( Angle( 0, -90, 0 ) ) )

	local traceSecond = util.QuickTrace( firstLaserField:GetPos(), -firstLaserField:GetRight() * 1000, firstLaserField )

	local secondLaserField = ents.Create( ClassName )
	secondLaserField:SetPos( traceSecond.HitPos )
	secondLaserField:SetModel( "models/props/fizzler_dynamic.mdl" )
	secondLaserField:SetAngles( traceSecond.HitNormal:Angle() )
	secondLaserField:Spawn()
	secondLaserField:SetAngles( secondLaserField:LocalToWorldAngles( Angle( 0, -90, 0 ) ) )
	
	firstLaserField:SetAngles( firstLaserField:LocalToWorldAngles( firstLaserField:ModelToInfo().angle ) )
	secondLaserField:SetAngles( secondLaserField:LocalToWorldAngles( secondLaserField:ModelToInfo().angle ) )

	firstLaserField:SetNWEntity( "GASL_ConnectedField", secondLaserField )
	secondLaserField:SetNWEntity( "GASL_ConnectedField", firstLaserField )
	
	constraint.Weld( secondLaserField, firstLaserField, 0, 0, 0, true, true )

	undo.Create( "LaserField" )
		undo.AddEntity( firstLaserField )
		undo.AddEntity( secondLaserField )
		undo.SetPlayer( ply )
	undo.Finish()
	
	return ent

end

function ENT:Draw()

	self:DrawModel()
	
	if ( !self:GetEnable() ) then return end

	self:DrawFizzler( Material( "effects/laserplane" ) )


end

if ( CLIENT ) then

	function ENT:Think()
		
		self.BaseClass.Think( self )

	end
	
	function ENT:Initialize()

		self.BaseClass.Initialize( self )
		//self.BaseClass.BaseClass.Initialize( self )

	end

	return
end

function ENT:Initialize()

	self.BaseClass.Initialize( self )
	self.BaseClass.BaseClass.Initialize( self )

	self:AddInput( "Enable", function( value ) self:ToggleEnable( value ) end )
	
end

function ENT:HandleEntityInField( ent )

	if ( ent:IsPlayer() ) then
		
		ent:TakeDamage( ent:Health(), self, self )
		
	elseif ( ent:GetPhysicsObject():IsValid() ) then
	
	end

end

-- no more client size
if ( CLIENT ) then return end

function ENT:Think()

	self.BaseClass.Think( self )

	return true
	
end
