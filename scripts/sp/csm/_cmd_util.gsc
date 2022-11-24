#include common_scripts\utility;
#include maps\_utility;

find_map_from_alias( alias )
{
	map = "";
	switch ( alias )
	{
		case "der":
		case "derriese":
		case "factory":
			map = "nazi_zombie_factory";
			break;
		case "shi":
		case "shino":
		case "shinonuma":
		case "sumpf":
			map = "nazi_zombie_sumpf";
			break;
		case "ver":
		case "verruckt":
		case "asylum":
			map = "nazi_zombie_asylum";
			break;
		case "nacht":
		case "prototype":
			map = "nazi_zombie_prototype";
			break;
		default:
			if ( isDefined( level.tcs_custom_map_aliases ) && isDefined( level.tcs_custom_map_aliases[ alias ] ) )
			{
				map = level.tcs_custom_map_aliases[ alias ];
			}
			break;
	}
	return map;
}

get_display_name_for_map( map )
{
	display_name = map;
	switch ( map )
	{
		case "nazi_zombie_factory":
			display_name = "Der Riese";
			break;
		case "nazi_zombie_sumpf":
			display_name = "Shi No Numa";
			break;
		case "nazi_zombie_asylum":
			display_name = "Verruckt";
			break;
		case "nazi_zombie_prototype":
			display_name = "Nacht der Untoten";
			break;
		default:
			if ( isDefined( level.tcs_custom_map_display_names ) && isDefined( level.tcs_custom_map_display_names ) )
			{
				display_name = level.tcs_custom_map_display_names[ map ];
			}
			break;
	}
	return display_name;
}

array_validate( array )
{
	return isDefined( array ) && isArray( array ) && array.size > 0;
}

cast_to_vector( vector_string )
{
	keys = strTok( vector_string, "," );
	vector_array = [];
	for ( i = 0; i < keys.size; i++ )
	{
		setDvar( "float", keys[ i ] );
		vector_array[ i ] = getDvarFloat( "float" ); 
	}
	vector = ( vector_array[ 0 ], vector_array[ 1 ], vector_array[ 2 ] );
	return vector;
}

server_safe_notify_thread( notify_name, index )
{
	wait( ( 0.05 * index ) + 0.05 );
	level notify( notify_name );
}

find_player_in_server( clientnum_guid_or_name, noprint )
{
	if ( !isDefined( noprint ) )
	{
		noprint = false;
	}
	if ( is_true( self.is_server ) || self.cmdpower >= level.CMD_POWER_MODERATOR )
	{
		partial_message = "clientnums and guids";
	}
	else 
	{
		partial_message = "clientnums";	
	}
	channel = self scripts\sp\csm\_com::com_get_cmd_feedback_channel();
	if ( !isDefined( clientnum_guid_or_name ) )
	{
		if ( !noprint )
		{
			level scripts\sp\csm\_com::com_printf( channel, "cmderror", "Try using /playerlist to view " + partial_message + " to use a cmd on instead of the name", self );
		}
		partial_message = undefined;
		return undefined;
	}
	if ( clientnum_guid_or_name == "self" )
	{
		if ( is_true( self.is_server ) )
		{
			if ( isDedicated() )
			{
				level scripts\sp\csm\_com::com_printf( channel, "cmderror", "You cannot use self as an arg for type player as the dedicated server" );
				partial_message = undefined;
				return undefined;
			}
			else
			{
				return level.host;
			}
		}
		return self;
	}
	is_whole_number = is_natural_num( clientnum_guid_or_name );
	client_num = int( clientnum_guid_or_name );
	guid = int( clientnum_guid_or_name );
	if ( is_whole_number )
	{
		players = getPlayers();
		for ( i = 0; i < players.size; i++ )
		{
			player = players[ i ];
			if ( player getEntityNumber() == client_num )
			{
				return player;
			}
		}
		for ( i = 0; i < players.size; i++ )
		{
			player = players[ i ];
			if ( !is_true(player.pers["isBot"]) && player getGUID() == guid )
			{
				return player;
			}
		}
		player = undefined;
	}
	is_whole_number = undefined;
	client_num = undefined;
	guid = undefined;
	name = toLower( clientnum_guid_or_name );
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		player = players[ i ];
		target_playername = toLower( player.playername );
		if ( isSubStr( target_playername, name ) )
		{
			return player;
		}
	}
	player = undefined;
	target_playername = undefined;
	if ( !noprint )
	{
		level scripts\sp\csm\_com::com_printf( channel, "cmderror", "Try using /playerlist to view " + partial_message + " to use a cmd on instead of the name", self );
	}
	name = undefined;
	partial_message = undefined;
	channel = undefined;
	return undefined;
}

is_player_valid( player, checkignoremeflag, ignore_laststand_players )
{
	if ( !isdefined( player ) )
		return 0;

	if ( !isalive( player ) )
		return 0;

	if ( !isplayer( player ) )
		return 0;

	if ( isdefined( player.is_zombie ) && player.is_zombie == 1 )
		return 0;

	if ( player.sessionstate == "spectator" )
		return 0;

	if ( player.sessionstate == "intermission" )
		return 0;

	if ( isdefined( self.intermission ) && self.intermission )
		return 0;

	if ( !( isdefined( ignore_laststand_players ) && ignore_laststand_players ) )
	{
		if ( isDefined( player.revivetrigger ) || is_true( player.lastand ) )
			return 0;
	}

	if ( isdefined( checkignoremeflag ) && checkignoremeflag && player.ignoreme )
		return 0;

	if ( isdefined( level.is_player_valid_override ) )
		return [[ level.is_player_valid_override ]]( player );

	return 1;
}

find_entity_in_server( entnum_targetname_or_self, noprint )
{
	if ( !isDefined( noprint ) )
	{
		noprint = false;
	}
	channel = self scripts\sp\csm\_com::com_get_cmd_feedback_channel();
	if ( !isDefined( entnum_targetname_or_self ) )
	{
		if ( !noprint )
		{
			level scripts\sp\csm\_com::com_printf( channel, "cmderror", "Try using /entitylist to view entity entnum, and targetname", self );
		}
		return undefined;
	}
	if ( entnum_targetname_or_self == "self" )
	{
		return self;
	}
	entities = getEntArray();
	ent = undefined;
	is_whole_number = is_natural_num( entnum_targetname_or_self );
	entnum = int( entnum_targetname_or_self );
	if ( is_whole_number && entnum < 1023 )
	{	
		for ( i = 0; i < entities.size; i++ )
		{
			ent = entities[ i ];
			if ( !is_entity_valid( ent ) )
			{
				continue;
			}
			if ( ent getEntityNumber() == entnum )
			{	
				is_whole_number = undefined;
				entnum = undefined;
				entities = undefined;
				return ent;
			}
		}
	}
	for ( i = 0; i < entities.size; i++ )
	{
		ent = entities[ i ];
		if ( !is_entity_valid( ent ) )
		{
			continue;
		}
		if ( !isDefined( ent.targetname ) )
		{
			continue;
		}
		if ( ent.targetname == entnum_targetname_or_self )
		{
			return ent;
		}
	}
	if ( !noprint )
	{
		level scripts\sp\csm\_com::com_printf( channel, "cmderror", "Try using /entitylist to view entity entnum, and targetname", self );
	}
	channel = undefined;
	return undefined;
}

is_entity_valid( entity )
{
	if ( !isDefined( entity ) )
	{
		return false;
	}
	if ( isPlayer( entity ) )
	{
		return is_player_valid( entity );
	}
	if ( !isAlive( entity ) )
	{
		return false;
	}
	return true;
}

getDvarIntDefault( dvarname, default_value )
{
	cur_dvar_value = getDvar( dvarname );
	if ( isDefined( cur_dvar_value ) && cur_dvar_value != "" )
	{
		return int( cur_dvar_value );
	}
	else 
	{
		setDvar( dvarname, default_value ); //So the dvar shows up in the console
		return default_value;
	}
}

getDvarStringDefault( dvarname, default_value )
{
	cur_dvar_value = getDvar( dvarname );
	if ( isDefined( cur_dvar_value ) && cur_dvar_value != "" )
	{
		return cur_dvar_value;
	}
	else 
	{
		setDvar( dvarname, default_value );
		return default_value;
	}
}

is_command_token( char )
{
	if ( isDefined( level.custom_commands_tokens ) && isDefined( level.custom_commands_tokens[ char ] ) )
	{
		return true;
	}
	return false;
}

is_str_int( str )
{
	numbers = [];
	for ( i = 0; i < 10; i++ )
	{
		numbers[ i + "" ] = i;
	}
	negative_sign[ "-" ] = true;
	if ( isDefined( negative_sign[ str[ 0 ] ] ) )
	{
		start_index = 1;
	}
	else 
	{
		start_index = 0;
	}
	for ( i = start_index; i < str.size; i++ )
	{
		if ( !isDefined( numbers[ str[ i ] ] ) )
		{
			return false;
		}
	}
	return true;
}

is_natural_num(str)
{
	return is_str_int( str ) && int( str ) >= 0;
}

is_str_float( str )
{
	if ( !is_str_int( str ) )
	{
		return false;
	}
	numbers = [];
	for ( i = 0; i < 10; i++ )
	{
		numbers[ i + "" ] = i;
	}
	negative_sign[ "-" ] = true;
	if ( isDefined( negative_sign[ str[ 0 ] ] ) )
	{
		start_index = 1;
	}
	else 
	{
		start_index = 0;
	}
	period[ "." ] = true;
	periods_found = 0;
	if ( isDefined( period[ str[ str.size - 1 ] ] ) )
	{
		return false;
	}
	for ( i = start_index; i < str.size; i++ )
	{
		if ( isDefined( period[ str[ i ] ] ) )
		{
			periods_found++;
			if ( periods_found > 1 )
			{
				return false;
			}
			continue;
		}
		if ( !isDefined( numbers[ str[ i ] ] ) )
		{
			return false;
		}
	}
	if ( periods_found == 0 )
	{
		return false;
	}
	return true;
}

cast_str_to_vector( str )
{
	floats = strTok( str, "," );
	if ( floats.size != 3 )
	{
		return ( 0, 0, 0 );
	}
	for ( i = 0; i < floats.size; i++ )
	{
		if ( !is_str_float( floats[ i ] ) || !is_str_int( floats[ i ] ) )
		{
			return ( 0, 0, 0 );
		}
	}
	vec = [];
	setDvar( "floatstorage", floats[ 0 ] );
	vec[ 0 ] = getDvarFloat( "floatstorage" );
	setDvar( "floatstorage", floats[ 1 ] );
	vec[ 1 ] = getDvarFloat( "floatstorage" );
	setDvar( "floatstorage", floats[ 2 ] );
	vec[ 2 ] = getDvarFloat( "floatstorage" );
	return ( vec[ 0 ], vec[ 1 ], vec[ 2 ] );
}

cast_bool_to_str( bool, binary_string_options )
{
	options = strTok( binary_string_options, " " );
	if ( options.size == 2 )
	{
		if ( bool )
		{
			return options[ 0 ];
		}
		else 
		{
			return options[ 1 ];
		}
	}
	return bool + "";
}

repackage_args( arg_list )
{
	args_string = "";
	for ( i = 0; i < arg_list.size; i++ )
	{
		args_string = args_string + arg_list[ i ] + " ";
	}
	return args_string;
}

to_upper( str )
{
	mapping = [];
	mapping[ "a" ] = "A";
	mapping[ "b" ] = "B";
	mapping[ "c" ] = "C";
	mapping[ "d" ] = "D";
	mapping[ "e" ] = "E";
	mapping[ "f" ] = "F";
	mapping[ "g" ] = "G";
	mapping[ "h" ] = "H";
	mapping[ "i" ] = "I";
	mapping[ "j" ] = "J";
	mapping[ "k" ] = "K";
	mapping[ "l" ] = "L";
	mapping[ "m" ] = "M";
	mapping[ "n" ] = "N";
	mapping[ "o" ] = "O";
	mapping[ "p" ] = "P";
	mapping[ "q" ] = "Q";
	mapping[ "r" ] = "R";
	mapping[ "s" ] = "S";
	mapping[ "t" ] = "T";
	mapping[ "u" ] = "U";
	mapping[ "v" ] = "V";
	mapping[ "w" ] = "W";
	mapping[ "x" ] = "X";
	mapping[ "y" ] = "Y";
	mapping[ "z" ] = "Z";
	new_str = "";
	for ( i = 0; i < str.size; i++ )
	{
		if ( isDefined( mapping[ str[ i ] ] ) )
		{
			new_str += mapping[ str[ i ] ];
		}
	}
	return new_str;
}

is_true( value )
{
	return isDefined( value ) && value;
}

array2( v1, v2, v3, v4, v5, v6, v7, v8, v9, v10 )
{
	array = [];
	if ( isDefined( v1 ) )
	{
		array[ 0 ] = v1;
	}
	if ( isDefined( v2 ) )
	{
		array[ 1 ] = v2;
	}
	if ( isDefined( v3 ) )
	{
		array[ 2 ] = v3;
	}
	if ( isDefined( v4 ) )
	{
		array[ 3 ] = v4;
	}
	if ( isDefined( v5 ) )
	{
		array[ 4 ] = v5;
	}
	if ( isDefined( v6 ) )
	{
		array[ 5 ] = v6;
	}
	if ( isDefined( v7 ) )
	{
		array[ 6 ] = v7;
	}
	if ( isDefined( v8 ) )
	{
		array[ 7 ] = v8;
	}
	if ( isDefined( v9 ) )
	{
		array[ 8 ] = v9;
	}
	if ( isDefined( v10 ) )
	{
		array[ 9 ] = v10;
	}
	return array;
}

cmd_addservercommand( cmdname, cmdaliases, cmdusage, cmdfunc, rankgroup, minargs, uses_player_validity_check, is_threaded_cmd )
{
	if ( !isDefined( level.tcs_ranks[ rankgroup ] ) )
	{
		level scripts\sp\csm\_com::com_printf( "con|g_log", "cmderror", "Failed to register server cmd " + cmdname + ", attempted to use an unregistered rankgroup " + rankgroup );
		return;
	}
	aliases = [];
	aliases[ 0 ] = cmdname;
	if ( isDefined( cmdaliases ) )
	{
		cmd_aliases_tokens = strTok( cmdaliases, " " );
		for ( i = 1; i < cmd_aliases_tokens.size; i++ )
		{
			aliases[ i ] = cmd_aliases_tokens[ i - 1 ];
		}
	}

	level.server_commands[ cmdname ] = spawnStruct();
	level.server_commands[ cmdname ].usage = cmdusage;
	level.server_commands[ cmdname ].func = cmdfunc;
	level.server_commands[ cmdname ].aliases = aliases;
	level.server_commands[ cmdname ].power = level.tcs_ranks[ rankgroup ].cmdpower;
	level.server_commands[ cmdname ].minargs = minargs;
	level.server_commands[ cmdname ].uses_player_validity_check = uses_player_validity_check;
	level.commands_total++;
	if ( is_true( is_threaded_cmd ) )
	{
		level.threaded_commands[ cmdname ] = true;
	}
	if ( !isDefined( level.server_command_groups ) )
	{
		level.server_command_groups = [];
	}
	if ( !isDefined( level.server_command_groups[ rankgroup ] ) )
	{
		level.server_command_groups[ rankgroup ] = [];
	}
	level.server_command_groups[ rankgroup ][ cmdname ] = true;
	if ( isSubStr( cmdusage, "name|guid|clientnum" ) )
	{
		if ( !isDefined( level.cmds_using_find_player ) )
		{
			level.cmds_using_find_player = [];
		}
		level.cmds_using_find_player[ cmdname ] = true;
	}
}

cmd_removeservercommand( cmdname )
{
	new_command_array = [];
	cmd_keys = getArrayKeys( level.server_commands );
	for ( i = 0; i < cmd_keys.size; i++ )
	{
		cmd = cmd_keys[ i ];
		if ( cmdname != cmd )
		{
			new_command_array[ cmd ] = spawnStruct();
			new_command_array[ cmd ].usage = level.server_commands[ cmd ].usage;
			new_command_array[ cmd ].func = level.server_commands[ cmd ].func;
			new_command_array[ cmd ].aliases = level.server_commands[ cmd ].aliases;
			new_command_array[ cmd ].power = level.server_commands[ cmd ].power;
			new_command_array[ cmd ].minargs = level.server_commands[ cmd ].minargs;
			new_command_array[ cmd ].uses_player_validity_check = level.server_commands[ cmd ].uses_player_validity_check;
		}
		else 
		{
			level.threaded_commands[ cmd ] = undefined;
			rankgroups = getArrayKeys( level.server_command_groups );
			for ( j = 0; j < rankgroups.size; j++ )
			{
				if ( isDefined( level.server_command_groups[ rankgroups[ i ] ][ cmd ] ) )
				{
					level.server_command_groups[ rankgroups[ i ] ][ cmd ] = undefined;
					break;
				}
			}
		}
	}
	level.server_commands = new_command_array;
}

cmd_removeservercommandbygroup( rankgroup )
{
	if ( !isDefined( level.server_command_groups[ rankgroup ] ) )
	{
		return;
	}
	commands = getArrayKeys( level.server_command_groups[ rankgroup ] );
	for ( i = 0; i < commands.size; i++ )
	{
		cmd_removeservercommand( commands[ i ] );
	}
}

cmd_setservercommandpower( cmdname, power )
{
	if ( isDefined( level.server_commands[ cmdname ] ) )
	{
		level.server_commands[ cmdname ].power = power;
	}
}

cmd_register_arg_types_for_server_cmd( cmdname, argtypes )
{
	if ( !isDefined( level.server_commands[ cmdname ] ) )
	{
		level scripts\sp\csm\_com::com_printf( "con|g_log", "cmderror", "cmd_register_arg_types_for_server_cmd() " + cmdname + " is not a server cmd" );
		return;
	}
	if ( !isDefined( argtypes ) || argtypes == "" )
	{
		return;
	}
	argtypes_array = strTok( argtypes, " " );
	level.server_commands[ cmdname ].argtypes = argtypes_array;
}

cmd_addclientcommand( cmdname, cmdaliases, cmdusage, cmdfunc, rankgroup, minargs, uses_player_validity_check, is_threaded_cmd )
{
	if ( !isDefined( level.tcs_ranks[ rankgroup ] ) )
	{
		level scripts\sp\csm\_com::com_printf( "con|g_log", "cmderror", "Failed to register client cmd " + cmdname + ", attempted to use an unregistered rankgroup " + rankgroup );
		return;
	}
	aliases = [];
	aliases[ 0 ] = cmdname;
	if ( isDefined( cmdaliases ) )
	{
		cmd_aliases_tokens = strTok( cmdaliases, " " );
		for ( i = 1; i < cmd_aliases_tokens.size; i++ )
		{
			aliases[ i ] = cmd_aliases_tokens[ i - 1 ];
		}
	}
	level.client_commands[ cmdname ] = spawnStruct();
	level.client_commands[ cmdname ].usage = cmdusage;
	level.client_commands[ cmdname ].func = cmdfunc;
	level.client_commands[ cmdname ].aliases = aliases;
	level.client_commands[ cmdname ].power = level.tcs_ranks[ rankgroup ].cmdpower;
	level.client_commands[ cmdname ].minargs = minargs;
	level.client_commands[ cmdname ].uses_player_validity_check = uses_player_validity_check;
	level.commands_total++;
	if ( is_true( is_threaded_cmd ) )
	{
		level.threaded_commands[ cmdname ] = true;
	}
	if ( !isDefined( level.client_command_groups ) )
	{
		level.client_command_groups = [];
	}
	if ( !isDefined( level.client_command_groups[ rankgroup ] ) )
	{
		level.client_command_groups[ rankgroup ] = [];
	}
	level.client_command_groups[ rankgroup ][ cmdname ] = true;
}

cmd_removeclientcommand( cmdname )
{
	new_command_array = [];
	cmd_keys = getArrayKeys( level.client_commands );
	for ( i = 0; i < cmd_keys.size; i++ )
	{
		cmd = cmd_keys[ i ];
		if ( cmdname != cmd )
		{
			new_command_array[ cmd ] = spawnStruct();
			new_command_array[ cmd ].usage = level.client_commands[ cmd ].usage;
			new_command_array[ cmd ].func = level.client_commands[ cmd ].func;
			new_command_array[ cmd ].aliases = level.client_commands[ cmd ].aliases;
			new_command_array[ cmd ].power = level.client_commands[ cmd ].power;
			new_command_array[ cmd ].minargs = level.client_commands[ cmd ].minargs;
			new_command_array[ cmd ].uses_player_validity_check = level.client_commands[ cmd ].uses_player_validity_check;
		}
		else 
		{
			level.threaded_commands[ cmd ] = undefined;
			rankgroups = getArrayKeys( level.client_command_groups );
			for ( j = 0; j < rankgroups.size; j++ )
			{
				if ( isDefined( level.client_command_groups[ rankgroups[ i ] ][ cmd ] ) )
				{
					level.client_command_groups[ rankgroups[ i ] ][ cmd ] = undefined;
					break;
				}
			}
		}
	}
	level.client_commands = new_command_array;
}

cmd_removeclientcommandbygroup( rankgroup )
{
	if ( !isDefined( level.client_command_groups[ rankgroup ] ) )
	{
		return;
	}
	commands = getArrayKeys( level.client_command_groups[ rankgroup ] );
	for ( i = 0; i < commands.size; i++ )
	{
		cmd_removeclientcommand( commands[ i ] );
	}
}

cmd_setclientcommandpower( cmdname, power )
{
	if ( isDefined( level.client_commands[ cmdname ] ) )
	{
		level.client_commands[ cmdname ].power = power;
	}
}

cmd_register_arg_types_for_client_cmd( cmdname, argtypes )
{
	if ( !isDefined( level.client_commands[ cmdname ] ) )
	{
		level scripts\sp\csm\_com::com_printf( "con|g_log", "cmderror", "cmd_register_arg_types_for_client_cmd() " + cmdname + " is not a client cmd" );
		return;
	}
	if ( !isDefined( argtypes ) || argtypes == "" )
	{
		return;
	}
	argtypes_array = strTok( argtypes, " " );
	level.client_commands[ cmdname ].argtypes = argtypes_array;
}

cmd_register_arg_type_handlers( argtype, checker_func, rand_gen_func, error_message )
{
	if ( !isDefined( level.tcs_arg_type_handlers ) )
	{
		level.tcs_arg_type_handlers = [];
	}
	if ( !isDefined( argtype ) || argtype == "" )
	{
		return;
	}
	level.tcs_arg_type_handlers[ argtype ] = spawnStruct();
	level.tcs_arg_type_handlers[ argtype ].checker_func = checker_func;
	level.tcs_arg_type_handlers[ argtype ].rand_gen_func = rand_gen_func;
	level.tcs_arg_type_handlers[ argtype ].error_message = error_message;
}

cmd_execute( cmdname, arg_list, is_clientcmd, silent, logprint )
{
	original_arg_list = arg_list;
	channel = self scripts\sp\csm\_com::com_get_cmd_feedback_channel();
	result = [];
	if ( !test_cmd_is_valid( cmdname, arg_list, is_clientcmd ) )
	{
		return;
	}
	if ( is_clientcmd )
	{
		if ( is_true( level.client_commands[ cmdname ].uses_player_validity_check ) )
		{
			if ( isDefined( level.tcs_player_is_valid_check ) && ![[ level.tcs_player_is_valid_check ]]( self ) )
			{
				level scripts\sp\csm\_com::com_printf( channel, "cmderror", "You are not in a valid state for " + cmdname + " to work", self );
				return;
			}
		}
		if ( is_true( level.threaded_commands[ cmdname ] ) )
		{
			self thread [[ level.client_commands[ cmdname ].func ]]( arg_list );
			return;
		}
		else 
		{
			result = self [[ level.client_commands[ cmdname].func ]]( arg_list );
		}
	}
	else 
	{
		if ( is_true ( level.cmds_using_find_player[ cmdname ] ) )
		{
			arg_list[ 0 ] = self find_player_in_server( arg_list[ 0 ] );
			if ( !isDefined( arg_list[ 0 ] ) )
			{
				return;
			}
			if ( is_true( level.server_commands[ cmdname ].uses_player_validity_check ) )
			{
				if ( isDefined( level.tcs_player_is_valid_check ) && ![[ level.tcs_player_is_valid_check ]]( arg_list[ 0 ] ) )
				{
					level scripts\sp\csm\_com::com_printf( channel, "cmderror", "Target " + arg_list[ 0 ].playername + " is not in a valid state for " + cmdname + " to work", self );
					return;
				}
			}
		}
		if ( is_true( level.threaded_commands[ cmdname ] ) )
		{
			self thread [[ level.server_commands[ cmdname ].func ]]( arg_list );
			return;
		}
		else 
		{
			result = self [[ level.server_commands[ cmdname ].func ]]( arg_list );
		}
	}
	if ( !isDefined( result ) || result.size == 0 || is_true( silent ) )
	{
		return;
	}
	channel = self scripts\sp\csm\_com::com_get_cmd_feedback_channel();
	if ( result[ "filter" ] != "cmderror" )
	{
		cmd_log = self.playername + " executed " + cmdname + " " + repackage_args( original_arg_list );
		if ( is_true( logprint ) && !is_true( level.doing_command_system_unittest ) )
		{
			level scripts\sp\csm\_com::com_printf( "g_log", result[ "filter" ], cmd_log );
		}
		if ( isDefined( result[ "channels" ] ) )
		{
			level scripts\sp\csm\_com::com_printf( result[ "channels" ], result[ "filter" ], result[ "message" ], self );
		}
		else 
		{
			level scripts\sp\csm\_com::com_printf( channel, result[ "filter" ], result[ "message" ], self );
		}
	}
	else
	{
		level scripts\sp\csm\_com::com_printf( channel, result[ "filter" ], result[ "message" ], self );
	}
}

//If we have a lot of clientdvars in the pool delay setting them to prevent client command overflow error.
setClientDvarThread( dvar, value, index )
{
	wait( index * 0.25 );
	self setClientDvar( dvar, value );
}

check_for_command_alias_collisions()
{
	wait 5;
	server_command_keys = getArrayKeys( level.server_commands );
	client_command_keys = getArrayKeys( level.client_commands );
	aliases = [];
	for ( i = 0; i < client_command_keys.size; i++ )
	{
		for ( j = 0; j < level.client_commands[ client_command_keys[ i ] ].aliases.size; j++ )
		{
			aliases[ aliases.size ] = level.client_commands[ client_command_keys[ i ] ].aliases[ j ];
		}
	}
	for ( i = 0; i < server_command_keys.size; i++ )
	{
		for ( j = 0; j < level.server_commands[ server_command_keys[ i ] ].aliases.size; j++ )
		{
			aliases[ aliases.size ] = level.server_commands[ server_command_keys[ i ] ].aliases[ j ];
		}
	}
	for ( i = 0; i < aliases.size; i++ )
	{
		for ( j = i + 1; j < aliases.size; j++ )
		{
			if ( aliases[ i ] == aliases[ j ] )
			{
				level scripts\sp\csm\_com::com_printf( "con", "cmderror", "Command alias collision detected alias " + aliases[ i ] + " is duplicated", level );
				break;
			}
		}
	}
}

parse_cmd_message( message )
{
	if ( message == "" )
	{
		return [];
	}
	//Strip command tokens.
	stripped_message = message;
	if ( is_command_token( message[ 0 ] ) )
	{
		stripped_message = "";
		for ( i = 1; i < message.size; i++ )
		{
			stripped_message += message[ i ];
		}
	}
	multi_cmds = [];
	command_keys = [];
	multiple_cmds_keys = strTok( stripped_message, ";" );
	for ( i = 0; i < multiple_cmds_keys.size; i++ )
	{
		cmd_args = strTok( multiple_cmds_keys[ i ], " " );
		cmdname = get_client_cmd_from_alias( cmd_args[ 0 ] );
		cmd_is_clientcmd = true;
		if ( cmdname == "" )
		{
			cmdname = get_server_cmd_from_alias( cmd_args[ 0 ] );
			cmd_is_clientcmd = false;
		}
		if ( cmdname != "" )
		{
			command_keys[ "cmdname" ] = cmdname;
			command_keys[ "args" ] = [];
			for ( j = 1; j < cmd_args.size; j++ )
			{
				command_keys[ "args" ][ j - 1 ] = cmd_args[ j ];
			}
			command_keys[ "is_clientcmd" ] = cmd_is_clientcmd;
			multi_cmds[ multi_cmds.size ] = command_keys;
		}
	}
	return multi_cmds;
}

get_server_cmd_from_alias( alias )
{
	if ( alias == "" )
	{
		return "";
	}
	command_keys = getArrayKeys( level.server_commands );
	for ( i = 0; i < command_keys.size; i++ )
	{
		for ( j = 0; j < level.server_commands[ command_keys[ i ] ].aliases.size; j++ )
		{
			if ( alias == level.server_commands[ command_keys[ i ] ].aliases[ j ] )
			{
				return command_keys[ i ];
			}
		}
	}
	return "";
}

get_client_cmd_from_alias( alias )
{
	if ( alias == "" )
	{
		return "";
	}
	command_keys = getArrayKeys( level.client_commands );
	for ( i = 0; i < command_keys.size; i++ )
	{
		for ( j = 0; j < level.client_commands[ command_keys[ i ] ].aliases.size; j++ )
		{
			if ( alias == level.client_commands[ command_keys[ i ] ].aliases[ j ] )
			{
				return command_keys[ i ];
			}
		}
	}
	return "";
}

test_cmd_is_valid( cmdname, arg_list, is_clientcmd )
{
	channel = self scripts\sp\csm\_com::com_get_cmd_feedback_channel();
	if ( is_clientcmd )
	{
		if ( arg_list.size < level.client_commands[ cmdname ].minargs )
		{
			level scripts\sp\csm\_com::com_printf( channel, "cmderror", "Usage: " + level.client_commands[ cmdname ].usage, self );
			return false;
		}
		if ( isDefined( level.client_commands[ cmdname ].argtypes ) && arg_list.size > 0 )
		{
			argtypes = level.client_commands[ cmdname ].argtypes;
			for ( i = 0; i < argtypes.size; i++ )
			{
				if ( isDefined( level.tcs_arg_type_handlers[ argtypes[ i ] ].checker_func ) )
				{
					if ( ![[ level.tcs_arg_type_handlers[ argtypes[ i ] ].checker_func ]]( arg_list[ i ] ) )
					{
						arg_num = i;
						level scripts\sp\csm\_com::com_printf( channel, "cmderror", "Arg " +  arg_num + " " + arg_list[ i ] + " is " + level.tcs_arg_type_handlers[ argtypes[ i ] ].error_message, self );
						return false;
					}
				}
			}
		}
	}
	else
	{
		if ( arg_list.size < level.server_commands[ cmdname ].minargs )
		{
			level scripts\sp\csm\_com::com_printf( channel, "cmderror", "Usage: " + level.server_commands[ cmdname ].usage, self );
			return false;
		}
		if ( isDefined( level.server_commands[ cmdname ].argtypes ) && arg_list.size > 0 )
		{
			argtypes = level.server_commands[ cmdname ].argtypes;
			for ( i = 0; i < argtypes.size; i++ )
			{
				if ( isDefined( level.tcs_arg_type_handlers[ argtypes[ i ] ].checker_func ) )
				{
					if ( ![[ level.tcs_arg_type_handlers[ argtypes[ i ] ].checker_func ]]( arg_list[ i ] ) )
					{
						arg_num = i;
						level scripts\sp\csm\_com::com_printf( channel, "cmderror", "Arg " +  arg_num + " " + arg_list[ i ] + " is " + level.tcs_arg_type_handlers[ argtypes[ i ] ].error_message, self );
						return false;
					}
				}
			}
		}
	}
	return true;
}

build_hitlocs_array()
{
	level.tcs_hitlocs = [];
	level.tcs_hitlocs[ "none" ] = true;
	level.tcs_hitlocs[ "gun" ] = true;
	level.tcs_hitlocs[ "head" ] = true;
	level.tcs_hitlocs[ "helmet" ] = true;
	level.tcs_hitlocs[ "neck" ] = true;
	level.tcs_hitlocs[ "shield" ] = true;
	level.tcs_hitlocs[ "torso_upper" ] = true;
	level.tcs_hitlocs[ "torso_lower" ] = true;
	level.tcs_hitlocs[ "left_arm_lower" ] = true;
	level.tcs_hitlocs[ "left_arm_upper" ] = true;
	level.tcs_hitlocs[ "right_arm_lower" ] = true;
	level.tcs_hitlocs[ "right_arm_upper" ] = true;
	level.tcs_hitlocs[ "left_hand" ] = true;
	level.tcs_hitlocs[ "right_hand" ] = true;
	level.tcs_hitlocs[ "left_leg_lower" ] = true;
	level.tcs_hitlocs[ "left_leg_upper" ] = true;
	level.tcs_hitlocs[ "right_leg_lower" ] = true;
	level.tcs_hitlocs[ "right_leg_upper" ] = true;
	level.tcs_hitlocs[ "left_foot" ] = true;
	level.tcs_hitlocs[ "right_foot" ] = true;
}

build_mods_array()
{
	level.tcs_mods = [];
	level.tcs_mods[ "MOD_UNKNOWN" ] = true;
	level.tcs_mods[ "MOD_PISTOL_BULLET" ] = true;
	level.tcs_mods[ "MOD_RIFLE_BULLET" ] = true;
	level.tcs_mods[ "MOD_GRENADE" ] = true;
	level.tcs_mods[ "MOD_GRENADE_SPLASH" ] = true;
	level.tcs_mods[ "MOD_PROJECTILE" ] = true;
	level.tcs_mods[ "MOD_PROJECTILE_SPLASH" ] = true;
	level.tcs_mods[ "MOD_MELEE" ] = true;
	level.tcs_mods[ "MOD_BAYONET" ] = true;
	level.tcs_mods[ "MOD_HEAD_SHOT" ] = true;
	level.tcs_mods[ "MOD_CRUSH" ] = true;
	level.tcs_mods[ "MOD_TELEFRAG" ] = true;
	level.tcs_mods[ "MOD_FALLING" ] = true;
 	level.tcs_mods[ "MOD_SUICIDE" ] = true;
	level.tcs_mods[ "MOD_TRIGGER_HURT" ] = true;
	level.tcs_mods[ "MOD_EXPLOSIVE" ] = true;
	level.tcs_mods[ "MOD_IMPACT" ] = true;
	level.tcs_mods[ "MOD_BURNED" ] = true;
	level.tcs_mods[ "MOD_HIT_BY_OBJECT" ] = true;
	level.tcs_mods[ "MOD_DROWN" ] = true;
}

build_idflags_array()
{
	level.tcs_idflags = [];
	level.tcs_idflags[ level.tcs_idflags.size ] = 1;
	level.tcs_idflags[ level.tcs_idflags.size ] = 2;
	level.tcs_idflags[ level.tcs_idflags.size ] = 4;
	level.tcs_idflags[ level.tcs_idflags.size ] = 8;
	level.tcs_idflags[ level.tcs_idflags.size ] = 16;
	level.tcs_idflags[ level.tcs_idflags.size ] = 32;
}

arg_player_handler( arg )
{
	return isDefined( self find_player_in_server( arg ) ); 
}

arg_generate_rand_player()
{
	randomint = randomInt( 4 );
	players = getPlayers();

	random_player = undefined;
	if ( randomint < 3 )
	{
		random_player = players[ randomInt( players.size ) ];
	}
	
	switch ( randomint )
	{
		case 0:
			return random_player getEntityNumber();
		case 1:
			return random_player getGuid();
		case 2:
			return random_player.playername;
		case 3:
			return "self";
	}
}

arg_wholenum_handler( arg )
{
	return is_natural_num( arg );
}

arg_generate_rand_wholenum()
{
	return randomint( 1000000 );
}

arg_int_handler( arg )
{
	return is_str_int( arg );
}

arg_generate_rand_int()
{
	if ( cointoss() )
	{
		return randomInt( 1000000 );
	}
	else 
	{
		return randomInt( 1000000 ) * -1;
	}
}

arg_float_handler( arg )
{
	return is_str_float( arg ) || is_str_int( arg );
}

arg_generate_rand_float()
{
	if ( cointoss() )
	{
		return randomFloat( 1000000 );
	}
	else 
	{
		return randomFloat( 1000000 ) * -1;
	}
}

arg_vector_handler( arg )
{
	comma[ "," ] = true;
	for ( i = 0; i < arg.size; i++ )
	{
		if ( ( i % 2 ) == 0 )
		{
			if ( !is_str_float( arg[ i ] ) || !is_str_int( arg[ i ] ) )
			{
				return false;
			}
		}
		else if ( ( i % 2 ) == 1 && !isDefined( comma[ arg[ i ] ] ) )
		{
			return false;
		}
	}
	return true;
}

arg_generate_rand_vector()
{
	vec = [];
	for ( i = 0; i < 3; i++ )
	{
		if ( cointoss() )
		{
			vec[ i ] = randomFloat( 1000 );
		}
		else
		{
			vec[ i ] = randomFloat( 1000 ) * -1;
		}
	}
	result = "";
	for ( i = 0; i < vec.size; i++ )
	{
		if ( i == ( vec.size - 1 ) )
		{
			result += vec[ i ];
		}
		else 
		{
			result += vec[ i ] + ",";
		}
	}
	return result;
}

arg_cmdalias_handler( arg )
{
	cmd_to_execute = get_client_cmd_from_alias( arg );
	if ( cmd_to_execute == "" )
	{
		cmd_to_execute = get_server_cmd_from_alias( arg );
	}
	return cmd_to_execute != "";
}

arg_generate_rand_cmdalias()
{
	server_command_keys = getArrayKeys( level.server_commands );
	client_command_keys = getArrayKeys( level.client_commands );
	aliases = [];
	blacklisted_cmds_client = array2( "cvar" );
	for ( i = 0; i < client_command_keys.size; i++ )
	{
		cmd_is_blacklisted = false;
		for ( j = 0; j < blacklisted_cmds_client.size; j++ )
		{
			if ( client_command_keys[ i ] == blacklisted_cmds_client[ j ] )
			{
				cmd_is_blacklisted = true;
				break;
			}
		}
		if ( cmd_is_blacklisted )
		{
			continue;
		}
		for ( j = 0; j < level.client_commands[ client_command_keys[ i ] ].aliases.size; j++ )
		{
			aliases[ aliases.size ] = level.client_commands[ client_command_keys[ i ] ].aliases[ j ];
		}
	}
	blacklisted_cmds_server1 = array2( "rotate", "restart", "changemap", "unittest", "unittestinvalidargs", "setcvar", "dvar", "cvarall", "spectator", "execonallplayers" );
	blacklisted_cmds_server2 = array2( "setrotation", "resetrotation", "nextmap" );
	for ( i = 0; i < server_command_keys.size; i++ )
	{
		cmd_is_blacklisted = false;
		for ( k = 0; k < blacklisted_cmds_server1.size; k++ )
		{
			if ( server_command_keys[ i ] == blacklisted_cmds_server1[ k ] )
			{
				cmd_is_blacklisted = true;
				break;
			}
		}
		for ( k = 0; k < blacklisted_cmds_server2.size; k++ )
		{
			if ( server_command_keys[ i ] == blacklisted_cmds_server2[ k ] )
			{
				cmd_is_blacklisted = true;
				break;
			}
		}
		if ( cmd_is_blacklisted )
		{
			continue;
		}
		for ( j = 0; j < level.server_commands[ server_command_keys[ i ] ].aliases.size; j++ )
		{
			aliases[ aliases.size ] = level.server_commands[ server_command_keys[ i ] ].aliases[ j ];
		}
	}
	return aliases[ randomInt( aliases.size ) ];
}

arg_rank_handler( arg )
{
	return isDefined( level.tcs_ranks[ arg ] );
}

arg_generate_rand_rank()
{
	ranks = getArrayKeys( level.tcs_ranks );
	return ranks[ randomInt( ranks.size ) ]; 
}

arg_entity_handler( arg )
{
	return isDefined( self find_entity_in_server( arg ) );
}

arg_generate_rand_entity()
{
	randomint = randomInt( 3 );
	entities = getEntArray();
	
	random_entity = undefined;
	if ( randomint < 2 )
	{
		random_entity = entities[ randomInt( entities.size ) ];
	}

	switch ( randomint )
	{
		case 0:
			return random_entity getEntityNumber();
		case 1:
			return random_entity.targetname;
		case 2:
			return "self";
	}
}

arg_hitloc_handler( arg )
{
	return isDefined( level.tcs_hitlocs[ arg ] );
}

arg_generate_rand_hitloc()
{
	hitlocs = getArrayKeys( level.tcs_hitlocs );
	return hitlocs[ randomInt( hitlocs.size ) ];
}

arg_mod_handler( arg )
{
	return isDefined( level.tcs_mods[ arg ] );
}

arg_generate_rand_mod()
{
	mods = getArrayKeys( level.tcs_mods );
	return mods[ randomInt( mods.size ) ];
}

arg_idflags_handler( arg )
{
	return is_natural_num( arg ) && int( arg ) < 2048;
} 

arg_generate_rand_idflags()
{
	flags = 0;
	idflags_array = level.tcs_idflags;
	max_flags_to_add = randomInt( level.tcs_idflags.size );
	for ( i = 0; i < max_flags_to_add; i++ )
	{
		random_flag_index = randomInt( idflags_array );
		flags |= idflags_array[ random_flag_index ];
		new_array = [];
		for ( j = 0; j < idflags_array.size; j++ )
		{
			if ( j == random_flag_index )
				continue;
			new_array[ new_array.size ] = idflags_array[ j ];
		}
		idflags_array = new_array;
		if ( idflags_array.size <= 0 )
		{
			return flags;
		}
	}
	return flags;
}