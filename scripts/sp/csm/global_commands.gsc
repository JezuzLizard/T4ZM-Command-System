#include scripts\sp\csm\_cmd_util;
#include common_scripts\utility;
#include maps\_utility;

CMD_RANDOMNEXTMAP_f( arg_list )
{
	result = [];
	string = getDvarStringDefault( "tcs_random_map_list", "nazi_zombie_factory nazi_zombie_sumpf nazi_zombie_asylum nazi_zombie_prototype" );
	map_keys = strTok( string, " " );
	random_map = map_keys[ randomInt( map_keys.size ) ];
	rotation_string = "map " + random_map;
	setDvar( "sv_maprotationCurrent", rotation_string );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Set new secret random map";
	return result;
}

CMD_RESETROTATION_f( arg_list )
{
	result = [];
	setDvar( "sv_maprotationCurrent", getDvar( "sv_maprotation" ) );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Successfully reset the map rotation";
	return result;
}

CMD_NEXTMAP_f( arg_list )
{
	result = [];
	alias = arg_list[ 0 ];
	map = find_map_from_alias( alias );
	if ( map != "" )
	{
		rotation_string = "map " + map;
		display_name = get_display_name_for_map( map );
		setDvar( "sv_maprotationCurrent", rotation_string );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Successfully set next map to " + display_name;
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Unknown map alias " + alias;
	}
	return result;
}

CMD_LOCK_SERVER_f( arg_list )
{
	result = [];
	password = arg_list[ 0 ];
	setDvar( "g_password", password );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Successfully locked the server with key " + password;
	return result;
}

CMD_UNLOCK_SERVER_f( arg_list )
{
	result = [];
	setDvar( "g_password", "" );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Successfully unlocked the server";
	return result;
}

CMD_SETROTATION_f( arg_list )
{
	result = [];
	new_rotation = getDvar( arg_list[ 0 ] );
	if ( new_rotation != "" )
	{
		setDvar( "sv_maprotationCurrent", new_rotation );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Successfully set the rotation to " + new_rotation + "'s value";
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "New rotation dvar is blank";
	}
	return result;
}

CMD_SERVER_DVAR_f( arg_list )
{
	result = [];
	dvar_name = arg_list[ 0 ];
	dvar_value = arg_list[ 1 ];
	setDvar( dvar_name, dvar_value );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Successfully set " + dvar_name + " to " + dvar_value;
	return result;
}

CMD_CVARALL_f( arg_list )
{
	result = [];
	dvar_name = arg_list[ 0 ];
	dvar_value = arg_list[ 1 ];
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] setClientDvar( dvar_name, dvar_value );
	}
	new_dvar = [];
	new_dvar[ "name" ] = dvar_name;
	new_dvar[ "value" ] = dvar_value; 
	level.clientdvars[ level.clientdvars.size ] = new_dvar;
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Successfully set " + dvar_name + " to " + dvar_value + " for all players";
	return result;
}

CMD_SETCVAR_f( arg_list )
{
	result = [];
	player = self find_player_in_server( arg_list[ 0 ] );
	if ( isDefined( player ) )
	{
		dvar_name = arg_list[ 1 ];
		dvar_value = arg_list[ 2 ];
		player setClientDvar( dvar_name, dvar_value );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Successfully set " + player.playername + "'s " + dvar_name + " to " + dvar_value;
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Could not find player";
	}
	return result;
}

cmd_setmovespeedscale_f( arg_list )
{
	result = [];
	target = self find_player_in_server( arg_list[ 0 ] );
	if ( !isDefined( target ) )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Could not find player";
		return result;
	}
	setDvar( "floatstorage", arg_list[ 1 ] );
	arg_as_float = getDvarFloat( "floatstorage" );
	target setMoveSpeedScale( arg_as_float );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Set movespeedscale for " + target.playername " to " + arg_as_float;
	return result;
}

CMD_GIVEGOD_f( arg_list )
{
	result = [];
	target = undefined;
	target = self find_player_in_server( arg_list[ 0 ] );
	if ( !isDefined( target ) )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Could not find player";
	}
	else 
	{
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Toggled god for " + target.playername;
	}
	if ( isDefined( target ) )
	{
		if ( !is_true( target.tcs_is_invulnerable ) )
		{
			target enableInvulnerability();
			target.tcs_is_invulnerable = true;
		}
		else 
		{
			target disableInvulnerability();
			target.tcs_is_invulnerable = false;
		}
	}
	return result;
}

CMD_GIVENOTARGET_f( arg_list )
{
	result = [];
	target = undefined;
	target = self find_player_in_server( arg_list[ 0 ] );
	if ( !isDefined( target ) )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Could not find player";
	}
	else 
	{
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Toggled notarget for " + target.playername;
	}
	if ( isDefined( target ) )
	{
		target.ignoreme = !target.ignoreme;
	}
	return result;
}

CMD_GIVEINVISIBLE_f( arg_list )
{
	result = [];
	target = undefined;
	target = self find_player_in_server( arg_list[ 0 ] );
	if ( !isDefined( target ) )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Could not find player";
	}
	else 
	{
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Toggled invisibility for " + target.playername;
	}
	if ( isDefined( target ) )
	{
		if ( !is_true( target.tcs_is_invisible ) )
		{
			target hide();
			target.tcs_is_invisible = true;
		}
		else 
		{
			target show();
			target.tcs_is_invisible = false;
		}
	}
	return result;
}

cmd_giveweapon_f( arg_list )
{
	result = [];
	target = self find_player_in_server( arg_list[ 0 ] );
	if ( !isDefined( target ) )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Could not find player";	
		return result;
	}
	weapon = arg_list[ 1 ];
	if ( weapon == "all" )
	{
		weapons = getArrayKeys( level.zombie_include_weapons );
		for ( i = 0; i < weapons.size; i++ )
		{
			weapon_to_give = weapons[ i ];
			if ( !target hasWeapon( weapon_to_give ) )
			{
				target GiveWeapon( weapon_to_give, 0 ); 
				target GiveMaxAmmo( weapon_to_give ); 
			}
			else 
			{
				target GiveMaxAmmo( weapon_to_give ); 
			}
		}
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Gave " + target.playername + " all weapons";
		return result;
	}
	else 
	{
		if ( isDefined( level.zombie_include_weapons[ weapon ] ) )
		{
			target GiveWeapon( weapon, 0 ); 
			target GiveMaxAmmo( weapon ); 
			target SwitchToWeapon( weapon );
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = "Gave " + target.playername + " " + weapon;
		}
		else 
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Weapon " + weapon + " is not available on map";
		}
		return result;
	}	
}

CMD_SETRANK_f( arg_list )
{
	result = [];
	target = undefined;
	target = self find_player_in_server( arg_list[ 0 ] );
	if ( isDefined( target ) )
	{
		if ( self.cmdpower_server > target.cmdpower_server )
		{
			new_cmdpower_server = undefined;
			new_cmdpower_client = undefined;
			new_rank = undefined;
			switch ( arg_list[ 1 ] )
			{
				case "none":
					new_cmdpower_server = level.cmd_power_none;
					new_cmdpower_client = level.cmd_power_none;
					new_rank = level.tcs_rank_none;
					break;
				case "user":
					new_cmdpower_server = level.cmd_power_user;
					new_cmdpower_client = level.cmd_power_user;
					new_rank = level.tcs_rank_user;
					break;
				case "trs":
				case "trusted":
					new_cmdpower_server = level.cmd_power_trusted_user;
					new_cmdpower_client = level.cmd_power_trusted_user;
					new_rank = level.tcs_rank_trusted_user;
					break;
				case "ele":
				case "elevated":
					new_cmdpower_server = level.cmd_power_elevated_user;
					new_cmdpower_client = level.cmd_power_elevated_user;
					new_rank = level.tcs_rank_elevated_user;
					break;
				case "mod":
				case "moderator":
					new_cmdpower_server = level.cmd_power_moderator;
					new_cmdpower_client = level.cmd_power_moderator;
					new_rank = level.tcs_rank_moderator;
					break;
				case "cht":
				case "cheat":
					new_cmdpower_server = level.cmd_power_cheat;
					new_cmdpower_client = level.cmd_power_cheat;
					new_rank = level.tcs_rank_cheat;
					break;
				case "host":
				case "owner":
					new_cmdpower_server = level.cmd_power_host;
					new_cmdpower_client = level.cmd_power_host;
					new_rank = level.tcs_rank_host;
					break;
				default:
					break;
			}
			if ( isDefined( new_rank ) )
			{
				result[ "filter" ] = "cmdinfo";
				result[ "message" ] = "Target's new rank is " + new_rank;
				target.tcs_rank = new_rank;
				target.cmdpower_server = new_cmdpower_server;
				target.cmdpower_client = new_cmdpower_client;
				scripts\sp\csm\_perms::add_player_perms_entry( target );
				level scripts\sp\csm\_com::com_printf( target scripts\sp\csm\_com::com_get_cmd_feedback_channel(), "cmdinfo", "Your new rank is " + new_rank, target );
			}
			else 
			{
				result[ "filter" ] = "cmderror";
				result[ "message" ] = "Invalid rank " + arg_list[ 1 ];
			}
		}
		else 
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Insufficient cmdpower to set " + target.playername + "'s rank";
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Could not find player";	
	}
	return result;
}

/*
	Executes a client command on all players in the server. 
*/
CMD_EXECONALLPLAYERS_f( arg_list )
{
	result = [];
	cmd_to_execute = get_client_cmd_from_alias( arg_list[ 0 ] );
	if ( cmd_to_execute != "" )
	{
		var_args = [];
		for ( i = 1; i < arg_list.size; i++ )
		{
			var_args[ i - 1 ] = arg_list[ i ];
		}
		is_valid = self test_cmd_is_valid( cmd_to_execute, var_args, true );
		if ( !is_valid )
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Insufficient num args sent to " + cmd_to_execute + " from execonallplayers";
			return result;
		}
		players = getPlayers();
		for ( i = 0; i < players.size; i++ )
		{
			players[ i ] thread cmd_execute( cmd_to_execute, var_args, true, level.tcs_use_silent_commands, true );
		}
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Executed " + cmd_to_execute + " on all players";			
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Cmd " + arg_list[ 0 ] + " is invalid";
	}
	return result;
}

CMD_PLAYERLIST_f( arg_list )
{
	channel = self scripts\sp\csm\_com::com_get_cmd_feedback_channel();
	if ( channel != "con" )
	{
		channel = "iprint";
	}
	players = getPlayers();
	if ( players.size == 0 )
	{
		level scripts\sp\csm\_com::com_printf( channel, "notitle", "There are no players in the server", self );
		return;
	}
	for ( i = 0; i < players.size; i++ )
	{
		message = "^3" + players[ i ].playername + " " + players[ i ] getGUID() + " " + players[ i ] getEntityNumber();
		level scripts\sp\csm\_com::com_printf( channel, "notitle", message, self );
	}
	if ( !is_true( self.is_server ) )
	{
		level scripts\sp\csm\_com::com_printf( channel, "cmdinfo", "Use shift + ` and scroll to the bottom to view the full list", self );
	}
}

CMD_CMDLIST_f( arg_list )
{
	channel = self scripts\sp\csm\_com::com_get_cmd_feedback_channel();
	if ( channel != "con" )
	{
		channel = "iprint";
	}
	cmdnames = getArrayKeys( level.server_commands );
	for ( i = 0; i < cmdnames.size; i++ )
	{
		if ( self scripts\sp\csm\_perms::has_permission_for_cmd( cmdnames[ i ], false ) )
		{
			message = "^3" + level.server_commands[ cmdnames[ i ] ].usage;
			level scripts\sp\csm\_com::com_printf( channel, "notitle", message, self );
		}
	}
	if ( is_true( self.is_server ) )
	{
		return;
	}
	cmdnames = getArrayKeys( level.client_commands );
	for ( i = 0; i < cmdnames.size; i++ )
	{
		if ( self scripts\sp\csm\_perms::has_permission_for_cmd( cmdnames[ i ], true ) )
		{
			message = "^3" + level.client_commands[ cmdnames[ i ] ].usage;
			level scripts\sp\csm\_com::com_printf( channel, "notitle", message, self );
		}
	}

	level scripts\sp\csm\_com::com_printf( channel, "cmdinfo", "Use shift + ` and scroll to the bottom to view the full list", self );
}

cmd_weaponlist_f( arg_list )
{
	channel = self scripts\sp\csm\_com::com_get_cmd_feedback_channel();
	if ( channel != "con" )
	{
		channel = "iprint";
	}
	weapons = getArrayKeys( level.zombie_include_weapons );
	for ( i = 0; i < weapons.size; i++ )
	{
		level scripts\sp\csm\_com::com_printf( channel, "notitle", weapons[ i ], self );
	}
	level scripts\sp\csm\_com::com_printf( channel, "cmdinfo", "Use shift + ` and scroll to the bottom to view the full list", self );
}