#include common_scripts\utility;
#include maps\_utility;
#include scripts\sp\csm\_cmd_util;

CMD_GOD_f( arg_list )
{
	result = [];
	on_off = cast_bool_to_str( !is_true( self.tcs_is_invulnerable ), "on off" );
	if ( on_off == "on" )
	{
		self enableInvulnerability();
		self.tcs_is_invulnerable = true;
	}
	else 
	{
		self disableInvulnerability();
		self.tcs_is_invulnerable = false;
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "God " + on_off;
	return result;
}

CMD_NOTARGET_f( arg_list )
{
	result = [];
	on_off = cast_bool_to_str( !is_true( self.ignoreme ), "on off" );
	if ( on_off == "on" )
	{
		self.ignoreme = true;
	}
	else 
	{
		self.ignoreme = false;
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Notarget " + on_off;
	return result;
}

CMD_INVISIBLE_f( arg_list )
{
	result = [];
	on_off = cast_bool_to_str( !is_true( self.tcs_is_invisible ), "on off" );
	if ( on_off == "on" )
	{
		self hide();
		self.tcs_is_invisible = true;
	}
	else 
	{
		self show();
		self.tcs_is_invisible = false;
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Invisible " + on_off;
	return result;
}

CMD_PRINTORIGIN_f( arg_list )
{
	result = [];
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Your origin is " + self.origin;
	return result;
}

CMD_PRINTANGLES_f( arg_list )
{
	result = [];
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Your angles are " + self.angles;
	return result;
}

CMD_BOTTOMLESSCLIP_f( arg_list )
{
	result = [];
	on_off = cast_bool_to_str( !is_true( self.tcs_bottomless_clip ), "on off" );
	if ( on_off == "on" )
	{
		self thread bottomless_clip();
		self.tcs_bottomless_clip = true;
	}
	else 
	{
		self notify( "stop_bottomless_clip" );
		self.tcs_bottomless_clip = false;
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Bottomless Clip " + on_off;
	return result;
}

bottomless_clip()
{
	self endon( "disconnect" );
	self endon( "stop_bottomless_clip" );
	while ( true )
	{
		weapon = self getCurrentWeapon();
		if ( weapon != "none" )
		{
			self setWeaponAmmoClip( weapon, weaponClipSize( weapon ) );
			self giveMaxAmmo( weapon );
		}
		wait 0.05;
	}
}

CMD_TELEPORT_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
	if ( target == self )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "You cannot teleport to yourself";
		return result;
	}
	self setOrigin( target.origin + anglesToForward( target.angles ) * 64 + anglesToRight( target.angles ) * 64 );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Successfully teleported to " + target.playername + "'s position";
	return result;
}

CMD_CVAR_f( arg_list )
{
	result = [];
	self setClientDvar( arg_list[ 0 ], arg_list[ 1 ] );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Successfully set " + arg_list[ 0 ] + " to " + arg_list[ 1 ];
	return result;
}

cmd_weapon_f( arg_list )
{
	result = [];
	weapon = arg_list[ 0 ];
	if ( weapon == "all" )
	{
		weapons = getArrayKeys( level.zombie_include_weapons );
		for ( i = 0; i < weapons.size; i++ )
		{
			weapon_to_give = weapons[ i ];
			if ( !self hasWeapon( weapon_to_give ) )
			{
				self GiveWeapon( weapon_to_give, 0 ); 
				self GiveMaxAmmo( weapon_to_give ); 
			}
			else 
			{
				self GiveMaxAmmo( weapon_to_give ); 
			}
		}
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Gave you all weapons";
		return result;
	}
	else 
	{
		self GiveWeapon( weapon, 0 ); 
		self GiveMaxAmmo( weapon ); 
		self SwitchToWeapon( weapon );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Gave you " + weapon;
		return result;
	}
}

cmd_movespeedscale_f( arg_list )
{
	result = [];
	arg_as_float = arg_list[ 0 ];
	self setMoveSpeedScale( arg_as_float );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Set your movespeedscale to " + arg_as_float;
	return result;
}

cmd_togglehud_f( arg_list )
{
	result = [];
	self.tcs_hud_toggled = !is_true( self.tcs_hud_toggled );
	message = cast_bool_to_str( self.tcs_hud_toggled, "off on" );
	if ( self.tcs_hud_toggled )
	{
		self setClientDvar( "cg_drawhud", 0 );
		level.chalk_hud1_old_alpha = level.chalk_hud1.alpha;
		level.chalk_hud2_old_alpha = level.chalk_hud2.alpha;
		level.chalk_hud1.alpha = 0;
		level.chalk_hud2.alpha = 0;
	}
	else 
	{
		self setClientDvar( "cg_drawhud", 1 );
		level.chalk_hud1.alpha = level.chalk_hud1_old_alpha;
		level.chalk_hud2.alpha = level.chalk_hud2_old_alpha;
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Your hud is toggled " + message;
	return result;
}