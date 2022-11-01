
#include scripts\csm\_cmd_util;
#include common_scripts\utility;
#include maps\_utility;

main()
{
	scripts\csm\_com::com_init();
	level.custom_commands_restart_countdown = 5;
	level.commands_total = 0;
	level.commands_page_count = 0;
	level.commands_page_max = 4;
	level.custom_commands_cooldown_time = getDvarIntDefault( "tcs_cmd_cd", 5 );
	level.tcs_use_silent_commands = getDvarIntDefault( "tcs_silent_cmds", 0 );
	level.tcs_logprint_cmd_usage = getDvarIntDefault( "tcs_logprint_cmd_usage", 1 );
	level.cmd_power_none = 0;
	level.cmd_power_user = 1;
	level.cmd_power_trusted_user = 20;
	level.cmd_power_elevated_user = 40;
	level.cmd_power_moderator = 60;
	level.cmd_power_cheat = 80;
	level.cmd_power_host = 100;
	level.tcs_rank_none = "none";
	level.tcs_rank_user = "user";
	level.tcs_rank_trusted_user = "trusted";
	level.tcs_rank_elevated_user = "elevated";
	level.tcs_rank_moderator = "moderator";
	level.tcs_rank_cheat = "cheat";
	level.tcs_rank_host = "host";
	level.fl_godmode = 1;
	level.fl_demi_godmode = 2;
	level.fl_notarget = 4;
	level.clientdvars = [];
	tokens = getDvarStringDefault( "tcs_cmd_tokens", "" ); //separated by spaces, good tokens are generally not used at the start of a normal message 
	if ( tokens != "" )
	{
		level.custom_commands_tokens = strTok( tokens, " " );
	}
	// "\" is always useable by default
	scripts\csm\_perms::cmd_init_perms();
	level.tcs_add_server_command_func = ::cmd_addservercommand;
	level.tcs_add_client_command_func = ::cmd_addclientcommand;
	level.tcs_remove_server_command = ::cmd_removeservercommand;
	level.tcs_remove_client_command = ::cmd_removeclientcommand;
	level.server_commands = [];
	cmd_addservercommand( "setcvar", "setcvar scv", "setcvar <name|guid|clientnum|self> <cvarname> <newval>", scripts\csm\global_commands::CMD_SETCVAR_f, level.cmd_power_cheat );
	cmd_addservercommand( "dvar", "dvar dv", "dvar <dvarname> <newval>", scripts\csm\global_commands::CMD_SERVER_DVAR_f, level.cmd_power_cheat );
	cmd_addservercommand( "cvarall", "cvarall cva", "cvarall <cvarname> <newval>", scripts\csm\global_commands::CMD_CVARALL_f, level.cmd_power_cheat );
	cmd_addservercommand( "givegod", "givegod ggd", "givegod <name|guid|clientnum|self>", scripts\csm\global_commands::CMD_GIVEGOD_f, level.cmd_power_cheat );
	cmd_addservercommand( "givenotarget", "givenotarget gnt", "givenotarget <name|guid|clientnum|self>", scripts\csm\global_commands::CMD_GIVENOTARGET_f, level.cmd_power_cheat );
	cmd_addservercommand( "giveinvisible", "giveinvisible ginv", "giveinvisible <name|guid|clientnum|self>", scripts\csm\global_commands::CMD_GIVEINVISIBLE_f, level.cmd_power_cheat );
	cmd_addservercommand( "setrank", "setrank sr", "setrank <name|guid|clientnum|self> <rank>", scripts\csm\global_commands::CMD_SETRANK_f, level.cmd_power_host );

	cmd_addservercommand( "execonallplayers", "execonallplayers execonall exall", "execonallplayers <cmdname> [cmdargs] ...", scripts\csm\global_commands::CMD_EXECONALLPLAYERS_f, level.cmd_power_host );

	level.client_commands = [];
	cmd_addclientcommand( "god", "god", "god", scripts\csm\global_client_commands::CMD_GOD_f, level.cmd_power_cheat );
	cmd_addclientcommand( "notarget", "notarget nt", "notarget", scripts\csm\global_client_commands::CMD_NOTARGET_f, level.cmd_power_cheat );
	cmd_addclientcommand( "invisible", "invisible invis", "invisible", scripts\csm\global_client_commands::CMD_INVISIBLE_f, level.cmd_power_cheat );
	cmd_addclientcommand( "printorigin", "printorigin printorg por", "printorigin", scripts\csm\global_client_commands::CMD_PRINTORIGIN_f, level.cmd_power_none );
	cmd_addclientcommand( "printangles", "printangles printang pan", "printangles", scripts\csm\global_client_commands::CMD_PRINTANGLES_f, level.cmd_power_none );
	cmd_addclientcommand( "bottomlessclip", "bottomlessclip botclip bcl", "bottomlessclip", scripts\csm\global_client_commands::CMD_BOTTOMLESSCLIP_f, level.cmd_power_cheat );
	cmd_addclientcommand( "teleport", "teleport tele", "teleport <name|guid|clientnum|origin>", scripts\csm\global_client_commands::CMD_TELEPORT_f, level.cmd_power_cheat );
	cmd_addclientcommand( "cvar", "cvar cv", "cvar <cvarname> <newval>", scripts\csm\global_client_commands::CMD_CVAR_f, level.cmd_power_cheat );
	cmd_addclientcommand( "cmdlist", "cmdlist cl", "cmdlist [pagenumber]", scripts\csm\global_client_commands::CMD_CMDLIST_f, level.cmd_power_none, true );
	cmd_addclientcommand( "playerlist", "playerlist plist", "playerlist [pagenumber] [team]", scripts\csm\global_client_commands::CMD_PLAYERLIST_f, level.cmd_power_none, true );
	level thread command_buffer();
	level thread end_commands_on_end_game();
	level thread scr_dvar_command_watcher();
	level thread tcs_on_connect();
	level.command_init_done = true;
}

init()
{
}

scr_dvar_command_watcher()
{
	level endon( "end_commands" );
	wait 1;
	while ( true )
	{
		dvar_value = getDvar( "tcscmd" );
		if ( dvar_value != "" )
		{
			level notify( "say", dvar_value, undefined, false );
			setDvar( "tcscmd", "" );
		}
		wait 0.05;
	}
}

command_buffer()
{
	level endon( "end_commands" );
	while ( true )
	{
		level waittill( "say", message, player, isHidden );
		if ( isDefined( player ) && !isHidden && !is_command_token( message[ 0 ] ) )
		{
			continue;
		}
		if ( !isDefined( player ) )
		{
			player = level.host;
		}
		channel = player scripts\csm\_com::com_get_cmd_feedback_channel();
		if ( isDefined( player.cmd_cooldown ) && player.cmd_cooldown > 0 )
		{
			level scripts\csm\_com::com_printf( channel, "cmderror", "You cannot use another command for " + player.cmd_cooldown + " seconds", player );
			continue;
		}
		message = toLower( message );
		multi_cmds = scripts\csm\_text_parser::parse_cmd_message( message );
		if ( multi_cmds.size < 1 )
		{
			level scripts\csm\_com::com_printf( channel, "cmderror", "Invalid command", self );
			continue;
		}
		if ( multi_cmds.size > 1 && !player scripts\csm\_perms::can_use_multi_cmds() )
		{
			temp_array_index = multi_cmds[ 0 ];
			multi_cmds = [];
			multi_cmds[ 0 ] = temp_array_index;
			level scripts\csm\_com::com_printf( channel, "cmdwarning", "You do not have permission to use multi cmds; only executing the first cmd" );
		}
		for ( cmd_index = 0; cmd_index < multi_cmds.size; cmd_index++ )
		{
			cmdname = multi_cmds[ cmd_index ][ "cmdname" ];
			args = multi_cmds[ cmd_index ][ "args" ];
			is_clientcmd = multi_cmds[ cmd_index ][ "is_clientcmd" ];
			if ( !player scripts\csm\_perms::has_permission_for_cmd( cmdname, is_clientcmd ) )
			{
				level scripts\csm\_com::com_printf( channel, "cmderror", "You do not have permission to use " + cmdname + " command", player );
			}
			else
			{
				player cmd_execute( cmdname, args, is_clientcmd, level.tcs_use_silent_commands, level.tcs_logprint_cmd_usage );
				player thread scripts\csm\_perms::cmd_cooldown();
			}
		}
	}
}

end_commands_on_end_game()
{
	level waittill_either( "end_game", "game_ended" );
	wait 10;
	level notify( "end_commands" );
}

tcs_on_connect()
{
	level endon( "end_commands" );
	while ( true )
	{
		level waittill( "connected", player );
		for ( i = 0; i < level.clientdvars.size; i++ )
		{
			dvar = level.clientdvars[ i ];
			player thread setClientDvarThread( dvar[ "name" ], dvar[ "value" ], i );
		}
		if ( player isHost() )
		{
			player.cmdpower_server = level.cmd_power_host;
			player.cmdpower_client = level.cmd_power_host;
			player.tcs_rank = level.tcs_rank_host;
			level.host = player;
		}
		else if ( array_validate( level.tcs_player_entries ) )
		{
			for ( i = 0; i < level.tcs_player_entries.size; i++ )
			{
				entry = level.tcs_player_entries[ i ];
				if ( find_player_in_server( entry.player_entry ) == player )
				{
					player.cmdpower_server = entry.cmdpower_server;
					player.cmdpower_client = entry.cmdpower_client;
					player.tcs_rank = entry.rank;
				}
			}
		}
		else 
		{
			player.cmdpower_server = getDvarIntDefault( "tcs_cmdpower_server_default", level.cmd_power_user );
			player.cmdpower_client = getDvarIntDefault( "tcs_cmdpower_client_default", level.cmd_power_user );
			player.tcs_rank = getDvarStringDefault( "tcs_default_rank", level.tcs_rank_user );
		}
	}
}
