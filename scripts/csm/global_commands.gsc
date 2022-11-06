#include scripts\csm\_cmd_util;
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
	if ( array_validate( arg_list ) )
	{
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
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage nextmap <mapalias>";
	}
	return result;
}

CMD_LOCK_SERVER_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) )
	{
		password = arg_list[ 0 ];
		setDvar( "g_password", password );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Successfully locked the server with key " + password;
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage lock <password>";
	}
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
	if ( array_validate( arg_list ) )
	{
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
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage: setrotation <rotationdvar>";
	}
	return result;
}

CMD_SERVER_DVAR_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) && arg_list.size == 2 )
	{
		dvar_name = arg_list[ 0 ];
		dvar_value = arg_list[ 1 ];
		setDvar( dvar_name, dvar_value );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Successfully set " + dvar_name + " to " + dvar_value;
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage dvar <dvarname> <newval>";
	}
	return result;
}

CMD_CVARALL_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) && arg_list.size == 2 )
	{
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
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage cvarall <dvarname> <newval>";
	}
	return result;
}

CMD_SETCVAR_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) && arg_list.size == 3 )
	{
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
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage cvar <name|guid|clientnum|self> <cvarname> <newval>";
	}
	return result;
}

CMD_GIVEGOD_f( arg_list )
{
	result = [];
	target = undefined;
	if ( array_validate( arg_list ) )
	{
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
	}
	else
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage givegod <name|guid|clientnum|self>";
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
	if ( array_validate( arg_list ) )
	{
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
	}
	else
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage givenotarget <name|guid|clientnum|self>";
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
	if ( array_validate( arg_list ) )
	{
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
	}
	else
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage giveinvisible <name|guid|clientnum|self>";
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

CMD_SETRANK_f( arg_list )
{
	result = [];
	target = undefined;
	if ( array_validate( arg_list ) )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( isDefined( target ) )
		{
			if ( isDefined( arg_list[ 1 ] ) )
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
						scripts\csm\_perms::add_player_perms_entry( target );
						level scripts\csm\_com::com_printf( target scripts\csm\_com::com_get_cmd_feedback_channel(), "cmdinfo", "Your new rank is " + new_rank, target );
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
				result[ "message" ] = "Usage setrank <name|guid|clientnum|self> <rank>";	
			}
		}
		else 
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Could not find player";	
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage setrank <name|guid|clientnum|self> <rank>";	
	}
	return result;
}

/*
	Executes a client command on all players in the server. 
*/
CMD_EXECONALLPLAYERS_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) )
	{
		cmd_to_execute = get_client_cmd_from_alias( arg_list[ 0 ] );
		if ( cmd_to_execute != "" )
		{
			var_args = [];
			for ( i = 1; i < arg_list.size; i++ )
			{
				var_args[ i - 1 ] = arg_list[ i ];
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
			if ( isDefined( arg_list[ 0 ] ) )
			{
				result[ "message" ] = "Cmd " + arg_list[ 0 ] + " is invalid";
			}
			else 
			{
				result[ "message" ] = "Cmd is invalid";
			}
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "execonallplayers <cmdname> [cmdargs]...";
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
	players = getPlayers();
	if ( players.size == 0 )
	{
		level scripts\csm\_com::com_printf( channel, "notitle", "There are no players in the server", self );
		return;
	}
	for ( i = 0; i < players.size; i++ )
	{
		message = "^3" + players[ i ].playername + " " + players[ i ] getGUID() + " " + players[ i ] getEntityNumber();
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
	if ( is_true( self.is_server ) )
	{
		all_commands = level.server_commands;
	}
	else 
	{
		all_commands = array_combine( level.server_commands, level.client_commands );
	}
	all_commands = array_combine( level.server_commands, level.client_commands );
	cmdnames = getArrayKeys( all_commands );
	for ( i = 0; i < cmdnames.size; i++ )
	{
		is_clientcmd = isDefined( level.client_commands[ cmdnames[ i ] ] );
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