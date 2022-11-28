
#include scripts\sp\csm\_cmd_util;
#include common_scripts\utility;
#include maps\_utility;

main()
{
	scripts\sp\csm\_com::com_init();
	level.server = spawnStruct();
	level.server.playername = "Server";
	level.server.is_server = true;
	level.custom_commands_restart_countdown = 10;
	level.commands_total = 0;
	level.custom_commands_cooldown_time = getDvarIntDefault( "tcs_cmd_cd", 5 );
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
	level.tcs_rank_owner = "owner";

	tcs_default_ranks = array2( "none", "user", "trusted", "elevated", "moderator", "cheat", "host", "owner" );
	tcs_default_ranks_cmdpower = array2( 0, 1, 20, 40, 60, 80, 100, 100 );
	level.tcs_ranks = [];
	for ( i = 0; i < tcs_default_ranks.size; i++ )
	{
		rank = tcs_default_ranks[ i ];
		allowedcmds_dvar = getDvarStringDefault( "tcs_rank_" + rank + "_allowedcmds", "" );
		disallowedcmds_dvar = getDvarStringDefault( "tcs_rank_" + rank + "_disallowedcmds", "" );
		cmdpower_dvar = getDvarIntDefault( "tcs_rank_" + rank + "_cmdpower", tcs_default_ranks_cmdpower[ i ] );
		level.tcs_ranks[ rank ] = spawnStruct();
		if ( allowedcmds_dvar != "" )
			level.tcs_ranks[ rank ].allowedcmds = strTok( allowedcmds_dvar, " " );
		else 
			level.tcs_ranks[ rank ].allowedcmds = undefined;

		if ( disallowedcmds_dvar != "" )
			level.tcs_ranks[ rank ].disallowedcmds = strTok( disallowedcmds_dvar, " " );
		else 
			level.tcs_ranks[ rank ].disallowedcmds = undefined;
		level.tcs_ranks[ rank ].cmdpower = cmdpower_dvar;
	}
	custom_ranks_str = getDvarStringDefault( "tcs_custom_rank_names", "" );
	if ( custom_ranks_str != "" )
		custom_ranks = strTok( custom_ranks_str, " " );
	else 
		custom_ranks = undefined;
	if ( isDefined( custom_ranks ) )
	{
		for ( i = 0; i < custom_ranks.size; i++ )
		{
			rank = custom_ranks[ i ];
			allowedcmds_dvar = getDvarStringDefault( "tcs_rank_" + rank + "_allowedcmds", "" );
			disallowedcmds_dvar = getDvarStringDefault( "tcs_rank_" + rank + "_disallowedcmds", "" );
			cmdpower_dvar = getDvarIntDefault( "tcs_rank_" + rank + "_cmdpower", 0 );
			level.tcs_ranks[ rank ] = spawnStruct();
			if ( allowedcmds_dvar != "" )
				level.tcs_ranks[ rank ].allowedcmds = strTok( allowedcmds_dvar, " " );
			else 
				level.tcs_ranks[ rank ].allowedcmds = undefined;

			if ( disallowedcmds_dvar != "" )
				level.tcs_ranks[ rank ].disallowedcmds = strTok( disallowedcmds_dvar, " " );
			else 
				level.tcs_ranks[ rank ].disallowedcmds = undefined;
			level.tcs_ranks[ rank ].cmdpower = cmdpower_dvar;
		}
	}

	level.fl_godmode = 1;
	level.fl_demi_godmode = 2;
	level.fl_notarget = 4;
	level.clientdvars = [];
	tokens_str = getDvarStringDefault( "tcs_cmd_tokens", "" ); //separated by spaces, good tokens are generally not used at the start of a normal message 
	if ( tokens_str != "" )
	{
		tokens = strTok( tokens_str, " " );
		for ( i = 0; i < tokens.size; i++ )
		{
			level.custom_commands_tokens[ tokens[ i ] ] = tokens[ i ];
		}
	}
	// "/" is always useable by default
	scripts\sp\csm\_perms::cmd_init_perms();
	level.tcs_add_server_command_func = ::cmd_addservercommand;
	level.tcs_set_server_command_power_func = ::cmd_setservercommandpower;
	level.tcs_add_client_command_func = ::cmd_addclientcommand;
	level.tcs_set_client_command_power_func = ::cmd_setclientcommandpower;
	level.tcs_remove_server_command = ::cmd_removeservercommand;
	level.tcs_remove_client_command = ::cmd_removeclientcommand;
	level.tcs_remove_server_command_by_group = ::cmd_removeservercommandbygroup;
	level.tcs_remove_client_command_by_group = ::cmd_removeclientcommandbygroup;
	level.tcs_com_printf = scripts\sp\csm\_com::com_printf;
	level.tcs_com_get_feedback_channel = scripts\sp\csm\_com::com_get_cmd_feedback_channel;
	level.tcs_find_player_in_server = ::find_player_in_server;
	level.tcs_check_cmd_collisions = ::check_for_command_alias_collisions;
	level.tcs_player_is_valid_check = scripts\sp\csm\_cmd_util::is_player_valid;
	level.tcs_debug_create_random_valid_args = scripts\sp\csm\_debug::create_random_valid_args2;
	level.tcs_repackage_args = ::repackage_args;
	level.server_commands = [];
	cmd_addservercommand( "setcvar", "scv", "setcvar <name|guid|clientnum|self> <cvarname> <newval>", scripts\sp\csm\global_commands::CMD_SETCVAR_f, "cheat", 3, false );
	cmd_addservercommand( "dvar", undefined, "dvar <dvarname> <newval>", scripts\sp\csm\global_commands::CMD_SERVER_DVAR_f, "cheat", 2, false );
	cmd_addservercommand( "cvarall", "cva", "cvarall <cvarname> <newval>", scripts\sp\csm\global_commands::CMD_CVARALL_f, "cheat", 2, false );
	cmd_addservercommand( "givegod", "ggd", "givegod <name|guid|clientnum|self>", scripts\sp\csm\global_commands::CMD_GIVEGOD_f, "cheat", 1, true );
	cmd_addservercommand( "givenotarget", "gnt", "givenotarget <name|guid|clientnum|self>", scripts\sp\csm\global_commands::CMD_GIVENOTARGET_f, "cheat", 1, true );
	cmd_addservercommand( "giveinvisible", "ginv", "giveinvisible <name|guid|clientnum|self>", scripts\sp\csm\global_commands::CMD_GIVEINVISIBLE_f, "cheat", 1, true );
	cmd_addservercommand( "giveweapon", "givewep", "giveweapon <name|guid|clientnum|self> <weaponname|all>", scripts\sp\csm\global_commands::cmd_giveweapon_f, "cheat", 2, true );
	cmd_addservercommand( "setrank", "sr", "setrank <name|guid|clientnum|self> <rank>", scripts\sp\csm\global_commands::CMD_SETRANK_f, "host", 2, false );
	cmd_addservercommand( "setmovespeedscale", "smvsps smss", "setmovespeedscale <name|guid|clientnum|self> <val>", scripts\sp\csm\global_commands::cmd_setmovespeedscale_f, "cheat", 2, true );

	cmd_addservercommand( "nextmap", "nm", "nextmap <mapalias>", scripts\sp\csm\global_commands::CMD_NEXTMAP_f, "elevated", 1, false );
	cmd_addservercommand( "resetrotation", "rr", "resetrotation", scripts\sp\csm\global_commands::CMD_RESETROTATION_f, "elevated", 0, false );
	cmd_addservercommand( "randomnextmap", "rnm", "randomnextmap", scripts\sp\csm\global_commands::CMD_RANDOMNEXTMAP_f, "elevated", 0, false );
	cmd_addservercommand( "restart", "mr", "restart", scripts\sp\csm\global_threaded_commands::CMD_RESTART_f, "elevated", 0, false, true );
	cmd_addservercommand( "rotate", "ro", "rotate", scripts\sp\csm\global_threaded_commands::CMD_ROTATE_f, "elevated", 0, false, true );
	cmd_addservercommand( "changemap", "cm", "changemap <mapalias>", scripts\sp\csm\global_threaded_commands::CMD_CHANGEMAP_f, "elevated", 1, false, true );
	cmd_addservercommand( "setrotation", "setr", "setrotation <rotationdvar>", scripts\sp\csm\global_commands::CMD_SETROTATION_f, "elevated", 1, false );

	cmd_addservercommand( "lock", undefined, "lock <password>", scripts\sp\csm\global_commands::CMD_LOCK_SERVER_f, "elevated", 1, false );
	cmd_addservercommand( "unlock", "ul", "unlock", scripts\sp\csm\global_commands::CMD_UNLOCK_SERVER_f, "elevated", 0, false );

	cmd_addservercommand( "execonallplayers", "execonall exall", "execonallplayers <cmdname> [cmdargs] ...", scripts\sp\csm\global_commands::CMD_EXECONALLPLAYERS_f, "host", 1, false );

	cmd_addservercommand( "cmdlist", undefined, "cmdlist", scripts\sp\csm\global_commands::CMD_CMDLIST_f, "none", 0, false );
	cmd_addservercommand( "playerlist", "plist", "playerlist", scripts\sp\csm\global_commands::CMD_PLAYERLIST_f, "none", 0, false );
	cmd_addservercommand( "weaponlist", "wlist", "weaponlist", scripts\sp\csm\global_commands::cmd_weaponlist_f, "none", 0, false );

	cmd_addservercommand( "help", undefined, "help [cmdname]", scripts\sp\csm\global_commands::cmd_help_f, "none", 0, false );

	cmd_addservercommand( "unittest", undefined, "unittest [botcount] [duration]", scripts\sp\csm\_debug::cmd_unittest_validargs_f, "host", 0, false );
	cmd_addservercommand( "testcmd", undefined, "testcmd <cmdalias> [threadcount] [duration]", scripts\sp\csm\_debug::cmd_testcmd_f, "host", 1, false );

	cmd_addservercommand( "dodamage", "dd", "dodamage <entitynum|targetname|self> <damage> <origin> [entitynum|targetname|self] [entitynum|targetname|self] [hitloc] [MOD] [idflags] [weapon]", scripts\sp\csm\global_commands::cmd_dodamage_f, "cheat", 3, false );

	cmd_register_arg_types_for_server_cmd( "givegod", "player" );
	cmd_register_arg_types_for_server_cmd( "givenotarget", "player" );
	cmd_register_arg_types_for_server_cmd( "giveinvisible", "player" );
	cmd_register_arg_types_for_server_cmd( "setrank", "player rank" );
	cmd_register_arg_types_for_server_cmd( "setmovespeedscale", "player wholefloat" );
	cmd_register_arg_types_for_server_cmd( "execonallplayers", "cmdalias" );
	cmd_register_arg_types_for_server_cmd( "execonteam", "team cmdalias" );
	cmd_register_arg_types_for_server_cmd( "playerlist", "team" );
	cmd_register_arg_types_for_server_cmd( "help", "cmdalias" );
	cmd_register_arg_types_for_server_cmd( "unittest", "int" );
	cmd_register_arg_types_for_server_cmd( "testcmd", "cmdalias wholenum wholenum" );
	cmd_register_arg_types_for_server_cmd( "dodamage", "entity float vector entity entity hitloc MOD idflags weapon" );


	level.client_commands = [];
	cmd_addclientcommand( "god", undefined, "god", scripts\sp\csm\global_client_commands::CMD_GOD_f, "cheat", 0, true );
	cmd_addclientcommand( "notarget", "nt", "notarget", scripts\sp\csm\global_client_commands::CMD_NOTARGET_f, "cheat", 0, true );
	cmd_addclientcommand( "invisible", "invis", "invisible", scripts\sp\csm\global_client_commands::CMD_INVISIBLE_f, "cheat", 0, true );
	cmd_addclientcommand( "printorigin", "printorg por", "printorigin", scripts\sp\csm\global_client_commands::CMD_PRINTORIGIN_f, "none", 0, false );
	cmd_addclientcommand( "printangles", "printang pan", "printangles", scripts\sp\csm\global_client_commands::CMD_PRINTANGLES_f, "none", 0, false );
	cmd_addclientcommand( "bottomlessclip", "botclip bcl", "bottomlessclip", scripts\sp\csm\global_client_commands::CMD_BOTTOMLESSCLIP_f, "cheat", 0, true );
	cmd_addclientcommand( "teleport", "tele", "teleport <name|guid|clientnum>", scripts\sp\csm\global_client_commands::CMD_TELEPORT_f, "cheat", 1, false );
	cmd_addclientcommand( "cvar", undefined, "cvar <cvarname> <newval>", scripts\sp\csm\global_client_commands::CMD_CVAR_f, "cheat", 2, false );
	cmd_addclientcommand( "weapon", "wep", "weapon <weaponname|all>", scripts\sp\csm\global_client_commands::cmd_weapon_f, "cheat", 1, true );
	cmd_addclientcommand( "movespeedscale", "mvsps mss", "movespeedscale <val>", scripts\sp\csm\global_client_commands::cmd_movespeedscale_f, "cheat", 1, true );
	cmd_addclientcommand( "togglehud", "toghud", "togglehud", scripts\sp\csm\global_client_commands::cmd_togglehud_f, "none", 0, false );

	cmd_register_arg_types_for_client_cmd( "teleport", "player" );
	cmd_register_arg_types_for_client_cmd( "movespeedscale", "wholefloat" );

	cmd_register_arg_type_handlers( "player", ::arg_player_handler, ::arg_generate_rand_player, "not a valid player" );
	cmd_register_arg_type_handlers( "wholenum", ::arg_wholenum_handler, ::arg_generate_rand_wholenum, "not a whole number" );
	cmd_register_arg_type_handlers( "int", ::arg_int_handler, ::arg_generate_rand_int, "not an int" );
	cmd_register_arg_type_handlers( "float", ::arg_float_handler, ::arg_generate_rand_float, "not a float" );
	cmd_register_arg_type_handlers( "wholefloat", ::arg_wholefloat_handler, ::arg_generate_rand_wholefloat, "not a positive float" );
	cmd_register_arg_type_handlers( "vector", ::arg_vector_handler, ::arg_generate_rand_vector, "not a valid vector, format is float,float,float" );
	cmd_register_arg_type_handlers( "cmdalias", ::arg_cmdalias_handler, ::arg_generate_rand_cmdalias, "not a valid cmdalias" );
	cmd_register_arg_type_handlers( "rank", ::arg_rank_handler, ::arg_generate_rand_rank, "not a valid rank" );
	cmd_register_arg_type_handlers( "entity", ::arg_entity_handler, ::arg_generate_rand_entity, "not a valid entity" );
	cmd_register_arg_type_handlers( "hitloc", ::arg_hitloc_handler, ::arg_generate_rand_hitloc, "not a valid hitloc" );
	cmd_register_arg_type_handlers( "MOD", ::arg_mod_handler, ::arg_generate_rand_mod, "not a valid mod" );
	cmd_register_arg_type_handlers( "idflags", ::arg_idflags_handler, ::arg_generate_rand_idflags, "not a valid idflag" );

	build_hitlocs_array();
	build_mods_array();
	build_idflags_array();
	
	if ( !isDedicated() )
	{
		if ( getDvarInt( "g_logsync" ) != 2 )
		{
			setDvar( "g_logsync", 2 );
		}
		if ( getDvar( "g_log" ) == "" )
		{
			setDvar( "g_log", "logs\games_sp.log" );
		}
	}

	level thread command_buffer();
	level thread end_commands_on_end_game();
	level thread scr_dvar_command_watcher();
	level thread tcs_on_connect();
	level thread check_for_command_alias_collisions();
	level.command_init_done = true;
}

init()
{
	do_unit_test = getDvarIntDefault( "tcs_unittest", 0 ) > 0;
	if ( do_unit_test )
	{
		arg_list = [];
		arg_list[ 0 ] = getDvarInt( "tcs_unittest" );
		scripts\sp\csm\_debug::cmd_unittest_validargs_f( arg_list );
	}
}

scr_dvar_command_watcher()
{
	level endon( "end_commands" );
	wait 1;
	setDvar( "tcscmd", "" ); // Initialize our dvar for sending commands from the server console. 
	while ( true )
	{
		parse_command_dvar();
		wait 0.05;
	}
}

parse_command_dvar()
{
	dvar_value = getDvar( "tcscmd" );
	if ( dvar_value != "" )
	{
		level notify( "say", dvar_value, undefined, false );
		setDvar( "tcscmd", "" );
	}
	dvar_value = undefined;
}

command_buffer()
{
	level endon( "end_commands" );
	while ( true )
	{
		level waittill( "say", message, player, isHidden );
		level cmd_execute( message, player, is_hidden );
	}
}

cmd_execute( message, player, is_hidden )
{
	if ( isDefined( player ) && !isHidden && !is_command_token( message[ 0 ] ) )
	{
		return;
	}
	if ( !isDefined( player ) )
	{
		if ( isDedicated() )
		{
			player = level.server;
		}
		else 
		{
			player = level.host;
		}
	}
	channel = player scripts\sp\csm\_com::com_get_cmd_feedback_channel();
	if ( isDefined( player.cmd_cooldown ) && player.cmd_cooldown > 0 )
	{
		level scripts\sp\csm\_com::com_printf( channel, "cmderror", "You cannot use another command for " + player.cmd_cooldown + " seconds", player );
		return;
	}
	message = toLower( message );
	multi_cmds = parse_cmd_message( message );
	if ( multi_cmds.size < 1 )
	{
		level scripts\sp\csm\_com::com_printf( channel, "cmderror", "Invalid command", player );
		return;
	}
	if ( multi_cmds.size > 1 && !player scripts\sp\csm\_perms::can_use_multi_cmds() )
	{
		temp_array_index = multi_cmds[ 0 ];
		multi_cmds = [];
		multi_cmds[ 0 ] = temp_array_index;
		level scripts\sp\csm\_com::com_printf( channel, "cmdwarning", "You do not have permission to use multi cmds; only executing the first cmd" );
	}
	for ( cmd_index = 0; cmd_index < multi_cmds.size; cmd_index++ )
	{
		cmdname = multi_cmds[ cmd_index ][ "cmdname" ];
		args = multi_cmds[ cmd_index ][ "args" ];
		is_clientcmd = multi_cmds[ cmd_index ][ "is_clientcmd" ];
		if ( !player scripts\sp\csm\_perms::has_permission_for_cmd( cmdname, is_clientcmd ) )
		{
			level scripts\sp\csm\_com::com_printf( channel, "cmderror", "You do not have permission to use " + cmdname + " command", player );
		}
		else
		{
			if ( is_clientcmd && is_true( player.is_server ) )
			{
				level scripts\sp\csm\_com::com_printf( channel, "cmderror", "You cannot use " + cmdname + " client command as the server", player );
			}
			else 
			{
				player cmd_execute_internal( cmdname, args, is_clientcmd, getDvarIntDefault( "tcs_silent_cmds", 0 ), getDvarIntDefault( "tcs_logprint_cmd_usage", 1 ) );
				player thread scripts\sp\csm\_perms::cmd_cooldown();
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
		player on_connect_internal();
	}
}

on_connect_internal()
{
	is_bot = is_true( self.pers[ "isBot"] );
	if ( is_bot )
	{
		if ( is_true( level.doing_command_system_testcmd ) )
		{
			self thread scripts\sp\csm\_debug::activate_specific_cmd();
		}
		else if ( is_true( level.doing_command_system_unittest ) )
		{
			self thread scripts\sp\csm\_debug::activate_random_cmds();
		}
	}
	for ( i = 0; i < level.clientdvars.size; i++ )
	{
		dvar = level.clientdvars[ i ];
		self thread setClientDvarThread( dvar[ "name" ], dvar[ "value" ], i );
	}
	found_entry = false;
	if ( self isHost() )
	{
		self.cmdpower = level.CMD_POWER_HOST;
		self.tcs_rank = level.TCS_RANK_HOST;
		level.host = self;
		found_entry = true;
	}
	else if ( array_validate( level.tcs_player_entries ) )
	{
		for ( i = 0; i < level.tcs_player_entries.size; i++ )
		{
			entry = level.tcs_player_entries[ i ];
			player_in_server = level.server cast_str_to_player( entry.player_entry, true );
			if ( isDefined( player_in_server ) && player_in_server == self )
			{
				self.cmdpower = entry.cmdpower;
				self.tcs_rank = entry.rank;
				found_entry = true;
			}
		}
	}
	if ( !is_true( found_entry ) )
	{
		self.cmdpower = getDvarIntDefault( "tcs_cmdpower_default", level.CMD_POWER_USER );
		self.tcs_rank = getDvarStringDefault( "tcs_default_rank", level.TCS_RANK_USER );
	}
	self._connected = true;
	is_bot = undefined;
	dvar = undefined;
	found_entry = undefined;
	entry = undefined;
	player_in_server = undefined;
}