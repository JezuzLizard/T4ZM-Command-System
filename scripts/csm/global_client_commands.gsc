#include common_scripts\utility;
#include maps\_utility;
#include scripts\csm\_cmd_util;

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
	on_off = cast_bool_to_str( !is_true( self.tcs_is_notarget ), "on off" );
	if ( on_off == "on" )
	{
		self.ignoreme = true;
		self.tcs_is_notarget = true;
	}
	else 
	{
		self.ignoreme = false;
		self.tcs_is_notarget = false;
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
	target = undefined;
	if ( array_validate( arg_list ) )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( !isDefined( target ) )
		{
			origin = cast_to_vector( arg_list[ 0 ] );
			if ( origin.size == 3 )
			{
				self setOrigin( origin );
				result[ "filter" ] = "cmdinfo";
				result[ "message" ] = "You have successfully teleported";
			}
			else 
			{
				result[ "filter" ] = "cmderror";
				result[ "message" ] = "Usage teleport <name|guid|clientnum|origin>";
			}
		}
		else 
		{
			self setOrigin( self.origin + anglesToForward( self.angles ) * 64 + anglesToRight( self.angles ) * 64 );
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = "Successfully teleported to " + target.name + "'s position";
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage teleport <name|guid|clientnum|origin>";		
	}
	return result;
}

CMD_CVAR_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) && arg_list.size == 2 )
	{
		self setClientDvar( arg_list[ 0 ], arg_list[ 1 ] );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Successfully set " + arg_list[ 0 ] + " to " + arg_list[ 1 ];
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage cvar <cvarname> <newval>";
	}
	return result;
}

CMD_PLAYERLIST_f( arg_list )
{
	channel = self scripts\csm\_com::com_get_cmd_feedback_channel();
	if ( channel != "con" )
	{
		channel = "iprint";
	}
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		message = "^3" + players[ i ].name + " " + players[ i ] getGUID() + " " + players[ i ] getEntityNumber();
		level scripts\csm\_com::com_printf( channel, "notitle", message, self );
	}
	if ( !is_true( self.is_server ) )
	{
		level scripts\csm\_com::com_printf( channel, "cmdinfo", "Use shift + ` and scroll to the bottom to view the full list", self );
	}
}

CMD_CMDLIST_f( arg_list )
{
	channel = self scripts\csm\_com::com_get_cmd_feedback_channel();
	if ( channel != "con" )
	{
		channel = "iprint";
	}
	all_commands = array_combine( level.server_commands, level.client_commands );
	cmdnames = getArrayKeys( all_commands );
	client_commands = getArrayKeys( level.client_commands );
	for ( i = 0; i < cmdnames.size; i++ )
	{
		is_clientcmd = is_in_array2( client_commands, cmdnames[ i ] );
		if ( self scripts\csm\_perms::has_permission_for_cmd( cmdnames[ i ], is_clientcmd ) )
		{
			message = "^3" + all_commands[ cmdnames[ i ] ].usage;
			level scripts\csm\_com::com_printf( channel, "notitle", message, self );
		}
	}
	if ( !is_true( self.is_server ) )
	{
		level scripts\csm\_com::com_printf( channel, "cmdinfo", "Use shift + ` and scroll to the bottom to view the full list", self );
	}
}