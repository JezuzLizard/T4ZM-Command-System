#include common_scripts\utility;
#include maps\_utility;

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

find_player_in_server( clientnum_guid_or_name )
{
	if ( !isDefined( clientnum_guid_or_name ) )
	{
		return undefined;
	}
	if ( clientnum_guid_or_name == "self" )
	{
		return self;
	}
	is_int = is_str_int( clientnum_guid_or_name );
	client_num = undefined;
	guid = undefined;
	name = undefined;
	if ( is_int && ( int( clientnum_guid_or_name ) < getDvarInt( "sv_maxclients" ) ) )
	{
		client_num = int( clientnum_guid_or_name );
		enum = 0;
	}
	else if ( is_int )
	{
		guid = int( clientnum_guid_or_name );
		enum = 1;
	}
	else 
	{
		name = clientnum_guid_or_name;
		enum = 2;
	}
	player_data = [];
	players = get_players();
	switch ( enum )
	{
		case 0:
			for ( i = 0; i < players.size; i++ )
			{
				player = players[ i ];
				if ( player getEntityNumber() == client_num )
				{
					return player;
				}
			}
			break;
		case 1:
			for ( i = 0; i < players.size; i++ )
			{
				player = players[ i ];
				if ( player getGUID() == guid )
				{
					return player;
				}
			}
			break;
		case 2:
			for ( i = 0; i < players.size; i++ )
			{
				player = players[ i ];
				if ( clean_player_name_of_clantag( toLower( player.name ) ) == clean_player_name_of_clantag( name ) || isSubStr( toLower( player.name ), name ) )
				{
					return player;
				}
			}
			break;
	}
	return undefined;
}

getDvarIntDefault( dvarname, default_value )
{
	cur_dvar_value = getDvar( dvarname );
	if ( cur_dvar_value != "" )
	{
		return int( cur_dvar_value );
	}
	else 
	{
		return default_value;
	}
}

getDvarStringDefault( dvarname, default_value )
{
	cur_dvar_value = getDvar( dvarname );
	if ( cur_dvar_value != "" )
	{
		return cur_dvar_value;
	}
	else 
	{
		return default_value;
	}
}

is_command_token( char )
{
	if ( isDefined( level.custom_commands_tokens ) )
	{
		for ( i = 0; i < level.custom_commands_tokens.size; i++ )
		{
			if ( char == level.custom_commands_tokens[ i ] )
			{
				return true;
			}
		}
	}
	return false;
}

is_str_int( str )
{
	val = 0;
	list_num = [];
	list_num[ "0" ] = val;
	val++;
	list_num[ "1" ] = val;
	val++;
	list_num[ "2" ] = val;
	val++;
	list_num[ "3" ] = val;
	val++;
	list_num[ "4" ] = val;
	val++;
	list_num[ "5" ] = val;
	val++;
	list_num[ "6" ] = val;
	val++;
	list_num[ "7" ] = val;
	val++;
	list_num[ "8" ] = val;
	val++;
	list_num[ "9" ] = val;
	for ( i = 0; i < str.size; i++ )
	{
		if ( !isDefined( list_num[ str[ i ] ] ) )
		{
			return false;
		}
	}
	return true;
}

clean_player_name_of_clantag( name )
{
	if ( isSubStr( name, "]" ) )
	{
		keys = strTok( name, "]" );
		return keys[ 1 ];
	}
	return name;
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

is_in_array2( array, value )
{
	keys = getArrayKeys( array );
	for ( i = 0; i < keys.size; i++ )
	{
		if ( array[ keys[ i ] ] == value )
		{
			return true;
		}
	}
	return false;
}

is_true( value )
{
	return isDefined( value ) && value;
}

array2( value1, value2, value3, value4, value5, value6, value7, value8, value9, value10 )
{
	array = [];
	if ( isDefined( value1 ) )
	{
		array[ 0 ] = value1;
	}
	if ( isDefined( value2 ) )
	{
		array[ 1 ] = value2;
	}
	if ( isDefined( value3 ) )
	{
		array[ 2 ] = value3;
	}
	if ( isDefined( value4 ) )
	{
		array[ 3 ] = value4;
	}
	if ( isDefined( value5 ) )
	{
		array[ 4 ] = value5;
	}
	if ( isDefined( value6 ) )
	{
		array[ 5 ] = value6;
	}
	if ( isDefined( value7 ) )
	{
		array[ 6 ] = value7;
	}
	if ( isDefined( value8 ) )
	{
		array[ 7 ] = value8;
	}
	if ( isDefined( value9 ) )
	{
		array[ 8 ] = value9;
	}
	if ( isDefined( value10 ) )
	{
		array[ 9 ] = value10;
	}
}

cmd_addservercommand( cmdname, cmdaliases, cmdusage, cmdfunc, cmdpower, is_threaded_cmd )
{
	aliases = strTok( cmdaliases, " " );
	level.server_commands[ cmdname ] = spawnStruct();
	level.server_commands[ cmdname ].usage = cmdusage;
	level.server_commands[ cmdname ].func = cmdfunc;
	level.server_commands[ cmdname ].aliases = aliases;
	level.server_commands[ cmdname ].power = cmdpower;
	level.commands_total++;
	if ( ceil( level.commands_total / level.commands_page_max ) >= level.commands_page_count )
	{
		level.commands_page_count++;
	}
	if ( is_true( is_threaded_cmd ) )
	{
		level.threaded_commands[ cmdname ] = true;
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
		}
		else 
		{
			level.threaded_commands[ cmd ] = false;
		}
	}
	level.server_commands = new_command_array;
} 

cmd_addclientcommand( cmdname, cmdaliases, cmdusage, cmdfunc, cmdpower, is_threaded_cmd )
{
	aliases = strTok( cmdaliases, " " );
	level.client_commands[ cmdname ] = spawnStruct();
	level.client_commands[ cmdname ].usage = cmdusage;
	level.client_commands[ cmdname ].func = cmdfunc;
	level.client_commands[ cmdname ].aliases = aliases;
	level.client_commands[ cmdname ].power = cmdpower;
	level.commands_total++;
	if ( ceil( level.commands_total / level.commands_page_max ) >= level.commands_page_count )
	{
		level.commands_page_count++;
	}
	if ( is_true( is_threaded_cmd ) )
	{
		level.threaded_commands[ cmdname ] = true;
	}
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
		}
		else 
		{
			level.threaded_commands[ cmd ] = false;
		}
	}
	level.client_commands = new_command_array;
} 

cmd_execute( cmdname, arg_list, is_clientcmd, silent, nologprint )
{
	if ( is_true( level.threaded_commands[ cmdname ] ) )
	{
		if ( is_clientcmd )
		{
			self thread [[ level.client_commands[ cmdname ].func ]]( arg_list );
		}
		else 
		{
			self thread [[ level.server_commands[ cmdname ].func ]]( arg_list );
		}
		return;
	}
	else 
	{
		result = [];
		if ( is_clientcmd )
		{
			result = self [[ level.client_commands[ cmdname].func ]]( arg_list );
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
	channel = self scripts\cmd_system_modules\_com::com_get_cmd_feedback_channel();
	if ( result[ "filter" ] != "cmderror" )
	{
		cmd_log = self.name + " executed " + result[ "message" ];
		if ( !is_true( nologprint ) )
		{
			level scripts\cmd_system_modules\_com::com_printf( "g_log", result[ "filter" ], cmd_log, self );
		}
		if ( isDefined( result[ "channels" ] ) )
		{
			level scripts\cmd_system_modules\_com::com_printf( result[ "channels" ], result[ "filter" ], result[ "message" ], self );
		}
		else 
		{
			level scripts\cmd_system_modules\_com::com_printf( channel, result[ "filter" ], result[ "message" ], self );
		}
	}
	else
	{
		level scripts\cmd_system_modules\_com::com_printf( channel, result[ "filter" ], result[ "message" ], self );
	}
}

//If we have a lot of clientdvars in the pool delay setting them to prevent client command overflow error.
setClientDvarThread( dvar, value, index )
{
	wait( index * 0.25 );
	self setClientDvar( dvar, value );
}