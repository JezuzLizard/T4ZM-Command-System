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
	target = arg_list[ 0 ];
	dvar_name = arg_list[ 1 ];
	dvar_value = arg_list[ 2 ];
	target setClientDvar( dvar_name, dvar_value );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Successfully set " + target.playername + "'s " + dvar_name + " to " + dvar_value;
	return result;
}

cmd_setmovespeedscale_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
	arg_as_float = arg_list[ 1 ];
	target setMoveSpeedScale( arg_as_float );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Set movespeedscale for " + target.playername + " to " + arg_as_float;
	return result;
}

CMD_GIVEGOD_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
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
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Toggled god for " + target.playername;
	return result;
}

CMD_GIVENOTARGET_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
	target.ignoreme = !target.ignoreme;
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Toggled notarget for " + target.playername;
	return result;
}

CMD_GIVEINVISIBLE_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
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
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Toggled invisibility for " + target.playername;
	return result;
}

cmd_giveweapon_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
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
	}
	else 
	{
		target GiveWeapon( weapon, 0 ); 
		target GiveMaxAmmo( weapon ); 
		target SwitchToWeapon( weapon );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Gave " + target.playername + " " + weapon;
	}	
	return result;
}

cmd_giveammo_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
	weapons = target GetWeaponsList(); 

	for( i = 0; i < weapons.size; i++ )
	{
		clipsize = weaponClipSize( weapons[ i ] );
		target SetWeaponAmmoClip( weapons[ i ], clipsize );
		target GiveMaxAmmo( weapons[ i ] );
	}

	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Gave " + target.playername + " full ammo";
	return result;
}

CMD_SETRANK_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
	if ( !is_true( self.is_server ) && self.cmdpower < target.cmdpower )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Insufficient cmdpower to set " + target.playername + "'s rank";
		return result;
	}
	new_rank = arg_list[ 1 ];
	if ( !is_true( self.is_server ) && ( level.tcs_ranks[ new_rank ].cmdpower >= self.cmdpower ) && self.cmdpower < level.CMD_POWER_HOST )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "You cannot set " + target.playername + " to a rank higher than or equal to your own";
		return result;
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Target's new rank is " + new_rank;
	target.tcs_rank = new_rank;
	target.cmdpower = level.tcs_ranks[ new_rank ].cmdpower;
	scripts\sp\csm\_perms::add_player_perms_entry( target );
	level scripts\sp\csm\_com::com_printf( target scripts\sp\csm\_com::com_get_cmd_feedback_channel(), "cmdinfo", "Your new rank is " + new_rank, target );
	return result;
}

/*
	Executes a client command on all players in the server. 
*/
CMD_EXECONALLPLAYERS_f( arg_list )
{
	result = [];
	cmd = arg_list[ 0 ];
	cmd_to_execute = get_cmd_from_alias( cmd );
	if ( !level.tcs_commands[ cmd_to_execute ].is_clientcmd )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "You cannot call a server cmd with execonallplayers";
		return result;
	}
	var_args = [];
	for ( i = 1; i < arg_list.size; i++ )
	{
		var_args[ i - 1 ] = arg_list[ i ];
	}
	is_valid = self test_cmd_is_valid( cmd_to_execute, var_args, true );
	if ( !is_valid )
	{
		return result;
	}
	players = getPlayers();
	if ( players.size == 0 )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "There are no players in the server";
		return result;
	}
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] thread cmd_execute_internal( cmd_to_execute, var_args, true, getDvarIntDefault( "tcs_silent_cmds", 0 ), false );
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Executed " + cmd_to_execute + " on all players";			
	return result;
}

CMD_PLAYERLIST_f( arg_list )
{
	result = [];
	channel = self scripts\sp\csm\_com::com_get_cmd_feedback_channel();
	players = getPlayers();
	if ( players.size == 0 )
	{
		level scripts\sp\csm\_com::com_printf( channel, "notitle", "There are no players in the server", self );
		return;
	}
	self thread list_players_throttled( channel, players );
	return result;
}

list_players_throttled( channel, players )
{
	self notify( "listing_players" );
	self endon( "listing_players" );
	for ( i = 0; i < players.size; i++ )
	{
		if ( is_true( self.is_server ) || self.cmdpower >= level.CMD_POWER_MODERATOR )
		{
			message = "^3" + players[ i ].playername + " " + players[ i ] getGUID() + " " + players[ i ] getEntityNumber();
		}
		else 
		{
			message = "^3" + players[ i ].playername + " " + players[ i ] getEntityNumber();
		}
		level scripts\sp\csm\_com::com_printf( channel, "notitle", message, self );
		wait 0.1;
	}
	if ( !is_true( self.is_server ) )
	{
		level scripts\sp\csm\_com::com_printf( channel, "cmdinfo", "Use shift + ` and scroll to the bottom to view the full list", self );
	}
}

CMD_CMDLIST_f( arg_list )
{
	result = [];
	channel = self scripts\sp\csm\_com::com_get_cmd_feedback_channel();
	self thread list_cmds_throttled( channel );
	return result;
}

list_cmds_throttled( channel )
{
	self notify( "listing_cmds" );
	self endon( "listing_cmds" );
	cmdnames = getArrayKeys( level.tcs_commands );
	for ( i = 0; i < cmdnames.size; i++ )
	{
		if ( self scripts\sp\csm\_perms::has_permission_for_cmd( cmdnames[ i ], false ) )
		{
			message = "^3" + level.tcs_commands[ cmdnames[ i ] ].usage;
			
			level scripts\sp\csm\_com::com_printf( channel, "notitle", message, self );
			wait 0.1;
		}
	}
	if ( !is_true( self.is_server ) )
	{
		level scripts\sp\csm\_com::com_printf( channel, "cmdinfo", "Use shift + ` and scroll to the bottom to view the full list", self );
	}
}

cmd_weaponlist_f( arg_list )
{
	channel = self scripts\sp\csm\_com::com_get_cmd_feedback_channel();
	weapons = getArrayKeys( level.zombie_include_weapons );
	for ( i = 0; i < weapons.size; i++ )
	{
		level scripts\sp\csm\_com::com_printf( channel, "notitle", weapons[ i ], self );
	}
	level scripts\sp\csm\_com::com_printf( channel, "cmdinfo", "Use shift + ` and scroll to the bottom to view the full list", self );
}

cmd_help_f( arg_list )
{
	result = [];
	channel = self scripts\sp\csm\_com::com_get_cmd_feedback_channel();
	if ( is_true( self.is_server ) )
	{
		level scripts\sp\csm\_com::com_printf( channel, "notitle", "^3To view cmds you can use do tcscmd cmdlist in the console", self );
		level scripts\sp\csm\_com::com_printf( channel, "notitle", "^3To view players in the server do tcscmd playerlist in the console", self );
		level scripts\sp\csm\_com::com_printf( channel, "notitle", "^3To view the usage of a specific cmd do tcscmd help <cmdalias>", self );
		if ( isDefined( level.tcs_additional_help_prints_func ) )
		{
			self [[ level.tcs_additional_help_prints_func ]]( channel );
		}
	}
	else 
	{
		level scripts\sp\csm\_com::com_printf( channel, "notitle", "^3To view cmds you can use do /cmdlist in the chat", self );
		level scripts\sp\csm\_com::com_printf( channel, "notitle", "^3To view players in the server do /playerlist in the chat", self );
		level scripts\sp\csm\_com::com_printf( channel, "notitle", "^3To view the usage of a specific cmd do /help <cmdalias>", self );
		if ( isDefined( level.tcs_additional_help_prints_func ) )
		{
			self [[ level.tcs_additional_help_prints_func ]]( channel );
		}
		level scripts\sp\csm\_com::com_printf( channel, "cmdinfo", "^3Use shift + ` and scroll to the bottom to view the full list", self );
	}
	return result;
}

cmd_dodamage_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
	damage = arg_list[ 1 ];
	pos = arg_list[ 2 ];
	attacker = arg_list[ 3 ];
	destructible_piece_index = arg_list[ 4 ];
	mod = arg_list[ 5 ];
	switch ( arg_list.size )
	{
		case 3:
			target dodamage( damage, pos );
			break;
		case 4:
			target dodamage( damage, pos, attacker );
			break;
		case 5:
			target dodamage( damage, pos, attacker, destructible_piece_index );
			break;
		case 6:
			target dodamage( damage, pos, attacker, destructible_piece_index, mod );
			break;
		default:
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Too many parameters sent to cmd dodamage max is 6";
			return result;
	}
	if ( isPlayer( target ) )
	{
		target_name = target.playername;
	}
	else
	{
		target_name = target.classname;
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = self.playername + " executes executes dodamage on " + target_name + " for " + damage + " damage";
	return result;
}

CMD_PAUSE_f( arg_list )
{
	result = [];
	if ( isDefined( arg_list[ 0 ] ) )
	{
		duration = arg_list[ 0 ];
		level thread game_pause( duration );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Game paused for " + duration + " minutes";
	}
	else 
	{
		level thread game_pause( -1 );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Game paused indefinitely use /unpause to end the pause";
	}
	return result;
}

game_pause( duration )
{
	setDvar( "ai_disablespawn", 1 );
	setDvar( "g_ai", 0 );
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		player = players[ i ];
		player enableInvulnerability();
		player.tcs_is_invulnerable = true;
	}
	level thread unpause_after_time( duration );
}

unpause_after_time( duration )
{
	if ( duration < 0 )
	{
		return;
	}
	level notify( "unpause_countdown" );
	level endon( "unpause_countdown" );
	level endon( "game_unpaused" );
	duration_seconds = duration * 60;
	for ( ; duration_seconds > 0; duration_seconds-- )
	{
		wait 1;
	}
	game_unpause();
}

CMD_UNPAUSE_f( arg_list )
{
	result = [];
	game_unpause();
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Game unpaused";
	return result;
}

game_unpause()
{
	level notify( "game_unpaused" );
	setDvar( "ai_disablespawn", 0 );
	setDvar( "g_ai", 1 );
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		player = players[ i ];
		player disableInvulnerability();
		player.tcs_is_invulnerable = false;
	}
}