#include common_scripts\utility;
#include maps\_utility;
#include scripts\sp\csm\_cmd_util;

cmd_init_perms()
{
	level.tcs_player_entries = [];
	player_perm_list = getDvar( "tcs_player_cmd_perms" );
	if ( player_perm_list != "" )
	{
		player_entries = strTok( player_perm_list, "," );
		index = 0;
		for ( i = 0; i < player_entries.size; i++ )
		{
			player_entry = player_entries[ i ];
			player_entry_array = strTok( player_entry, " " );
			if ( isDefined( player_entry_array[ 0 ] ) && isDefined( player_entry_array[ 1 ] ) && isDefined( player_entry_array[ 2 ] ) )
			{
				level.tcs_player_entries[ level.tcs_player_entries.size ] = spawnStruct(); 
				level.tcs_player_entries[ level.tcs_player_entries.size -1 ].player_entry = player_entry_array[ 0 ];
				level.tcs_player_entries[ level.tcs_player_entries.size -1 ].rank = player_entry_array[ 1 ];
				level.tcs_player_entries[ level.tcs_player_entries.size -1 ].cmdpower = int( player_entry_array[ 2 ] );
			}
			else 
			{
				level scripts\sp\csm\_com::com_printf( "con|g_log", "permserror", "tcs_player_cmd_perms index " + index + " has (player_entry " + isDefined( player_entry_array[ 0 ] ) + "), (rank " + isDefined( player_entry_array[ 1 ] ) + "), (cmdpower " + isDefined( player_entry_array[ 2 ] ) + ")" );
				level scripts\sp\csm\_com::com_printf( "con|g_log", "permserror", "Please check your tcs_player_cmd_perms dvar" );
			}
			index++;
		}
	}
}

add_player_perms_entry( player )
{
	if ( player_exists_in_perms_system( player ) )
	{
		set_player_perms_entry( player );
		return;
	}
	player_perm_list = getDvar( "tcs_player_cmd_perms" );
	if ( player_perm_list != "" )
	{
		player_entry = player.playername + " " + player.tcs_rank + " " + player.cmdpower;
		if ( player_perm_list[ player_perm_list.size - 1 ] == "," )
		{
			player_perm_list = player_perm_list + player_entry;
		}
		else 
		{
			player_perm_list = player_perm_list + "," + player_entry;
		}
		if ( player_perm_list.size > 1024 )
		{
			return;
		}
		setDvar( "tcs_player_cmd_perms", player_perm_list );
		cmd_init_perms();
	}
}

set_player_perms_entry( player )
{
	player_perm_list = getDvar( "tcs_player_cmd_perms" );
	if ( player_perm_list != "" )
	{
		player_entry_array = undefined;
		player_entries = strTok( player_perm_list, "," );
		index = 0;
		found_player = false;
		for ( i = 0; i < player_entries.size; i++ )
		{
			player_entry = player_entries[ i ];
			player_entry_array = strTok( player_entry, " " );
			player_in_server = level.server cast_str_to_player( player_entry_array[ 0 ], true );
			if ( isDefined( player_in_server ) && player_in_server == player )
			{
				player_entry_array[ 1 ] = player.tcs_rank;
				player_entry_array[ 2 ] = player.cmdpower + "";
				found_player = true;
				break;
			}
			if ( !found_player )
			{
				index++;
			}
		}
		if ( found_player )
		{
			player_entries[ index ] = player_entry_array[ 0 ] + " " + player_entry_array[ 1 ] + " " + player_entry_array[ 2 ];
			new_perms_list = "";
			for ( i = 0; i < player_entries.size; i++ )
			{
				new_perms_list += player_entries[ i ] + ",";
			}
			if ( new_perms_list.size > 1024 )
			{
				return;
			}
			setDvar( "tcs_player_cmd_perms", new_perms_list );
			cmd_init_perms();
		}
	}
}

player_exists_in_perms_system( player )
{
	for ( i = 0; i < level.tcs_player_entries.size; i++ )
	{
		player_in_server = level.server cast_str_to_player( level.tcs_player_entries[ i ].player_entry, true );
		if ( isDefined( player_in_server ) && player_in_server == player )
		{
			return true;
		}
	}
	return false;
}

cmd_cooldown()
{
	if ( is_true( level.doing_command_system_unittest ) )
	{
		return;
	}
	if ( is_true( self.is_server ) )
	{
		return;
	}
	if ( isDefined( level.host ) && self == level.host )
	{
		return;
	}
	if ( self.cmdpower >= level.cmd_power_trusted_user )
	{
		return;
	}
	self.cmd_cooldown = level.custom_commands_cooldown_time;
	while ( self.cmd_cooldown > 0 )
	{
		self.cmd_cooldown--;
		wait 1;
	}
}

can_use_multi_cmds()
{
	if ( is_true( level.doing_command_system_unittest ) )
	{
		return true;
	}
	if ( is_true( self.is_server ) )
	{
		return true;
	}
	if (isDefined( level.host ) && self == level.host )
	{
		return true;
	}
	if ( self.cmdpower >= level.cmd_power_cheat )
	{
		return true;
	}
	return false;
}

has_permission_for_cmd( cmdname, is_clientcmd )
{
	if ( is_true( level.doing_command_system_unittest ) )
	{
		return true;
	}
	if ( is_true( self.is_server ) )
	{
		return true;
	}
	if ( isDefined( level.host ) && self == level.host )
	{
		return true;
	}
	if ( isDefined( level.tcs_ranks[ self.tcs_rank ] ) && isDefined( level.tcs_ranks[ self.tcs_rank ].disallowed_cmds ) )
	{
		for ( i = 0; i < level.tcs_ranks[ self.tcs_rank ].disallowed_cmds.size; i++ )
		{
			disallowed_cmd = level.tcs_ranks[ self.tcs_rank ].disallowed_cmds[ i ];
			if ( disallowed_cmd == "all_cmds" )
			{
				return false;
			}
			else if ( cmdname == disallowed_cmd )
			{
				return false;
			}
			else if ( is_clientcmd )
			{
				if ( disallowed_cmd == "all_client_cmds" )
				{
					return false;
				}
				// In this case the token must be a rank name
				else if ( isDefined( level.client_command_groups[ disallowed_cmd ] ) && isDefined( level.client_command_groups[ disallowed_cmd ][ cmdname ] ) )
				{
					return false;
				}
			}
			else if ( !is_clientcmd )
			{
				if ( disallowed_cmd == "all_server_cmds" )
				{
					return false;
				}
				// In this case the token must be a rank name
				else if ( isDefined( level.server_command_groups[ disallowed_cmd ] ) && isDefined( level.server_command_groups[ disallowed_cmd ][ cmdname ] ) )
				{
					return false;
				}
			}
		}
	}
	if ( isDefined( level.tcs_ranks[ self.tcs_rank ] ) && isDefined( level.tcs_ranks[ self.tcs_rank ].allowed_cmds ) )
	{
		for ( i = 0; i < level.tcs_ranks[ self.tcs_rank ].allowed_cmds.size; i++ )
		{
			allowed_cmd = level.tcs_ranks[ self.tcs_rank ].allowed_cmds[ i ];
			if ( allowed_cmd == "all_cmds" )
			{
				return true;
			}
			else if ( cmdname == allowed_cmd )
			{
				return true;
			}
			else if ( is_clientcmd )
			{
				if ( allowed_cmd == "all_client_cmds" )
				{
					return true;
				}
				// In this case the token must be a rank name
				else if ( isDefined( level.client_command_groups[ allowed_cmd ] ) && isDefined( level.client_command_groups[ allowed_cmd ][ cmdname ] ) )
				{
					return true;
				}
			}
			else if ( !is_clientcmd )
			{
				if ( allowed_cmd == "all_server_cmds" )
				{
					return true;
				}
				// In this case the token must be a rank name
				else if ( isDefined( level.server_command_groups[ allowed_cmd ] ) && isDefined( level.server_command_groups[ allowed_cmd ][ cmdname ] ) )
				{
					return true;
				}
			}
		}
	}
	if ( is_clientcmd && self.cmdpower >= level.client_commands[ cmdname ].power )
	{
		return true;
	}
	if ( !is_clientcmd && self.cmdpower >= level.server_commands[ cmdname ].power )
	{
		return true;
	}
	return false;
}