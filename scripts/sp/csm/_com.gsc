#include common_scripts\utility;
#include maps\_utility;
#include scripts\sp\csm\_cmd_util;

com_init()
{
	com_addfilter( "cominfo", 1 );
	com_addfilter( "comwarning", 1 );
	com_addfilter( "comerror", 1 );
	com_addfilter( "cmdinfo", 1 );
	com_addfilter( "cmdwarning", 1 );
	com_addfilter( "cmderror", 1 );
	com_addfilter( "scrinfo", 1 );
	com_addfilter( "scrwarning", 1 );
	com_addfilter( "screrror", 1 );
	com_addfilter( "permsinfo", 1 );
	com_addfilter( "permswarning", 1 );
	com_addfilter( "permserror", 1 ); 
	com_addfilter( "debug", 0 );
	com_addfilter( "notitle", 1 );

	com_addchannel( "con", ::com_print );
	com_addchannel( "g_log", ::com_logprint );
	com_addchannel( "iprint", ::com_iprintln );
	com_addchannel( "iprintbold", ::com_iprintlnbold );
	com_addchannel( "tell", ::com_tell );
	com_addchannel( "say", ::com_say );

	com_addchannel( "iprint_array", ::com_iprintln_array );
	com_addchannel( "tell_array", ::com_tell_array );
}

com_addfilter( filter, default_value )
{
	if ( !isDefined( level.com_filters ) )
	{
		level.com_filters = [];
	}
	if ( !isDefined( level.com_filters[ filter ] ) )
	{
		level.com_filters[ filter ] = getDvarIntDefault( "com_script_filter_" + filter, default_value );
	}
}

com_addchannel( channel, func )
{
	if ( !isDefined( level.com_channels ) )
	{
		level.com_channels = [];
	}
	if ( !isDefined( level.com_channels[ channel ] ) )
	{
		level.com_channels[ channel ] = func;
	}
}

com_is_filter_active( filter )
{
	return is_true( level.com_filters[ filter ] );
}

com_is_channel_active( channel )
{
	return isDefined( level.com_channels[ channel ] );
}

com_caps_msg_title( channel, filter )
{
	if ( filter == "notitle" || channel == "con" )
	{
		return "";
	}
	if ( channel == "g_log" )
	{
		return to_upper( filter ) + ":";
	}
	if ( isSubStr( filter, "error" ) )
	{
		color_code = "^1";
	}
	else if ( isSubStr( filter, "warning" ) )
	{
		color_code = "^3";
	}
	else if ( isSubStr( filter, "info" ) )
	{
		color_code = "^2";
	}
	else 
	{
		color_code = "";
	}
	return color_code + to_upper( filter ) + ":";
}

com_print( message, players, arg_list )
{
	printConsole( message );
}

com_logprint( message, players, arg_list )
{
	logPrint( message + "\n" );
}

com_iprintln( message, player, arg_list )
{
	if ( is_true( level.doing_command_system_unittest ) )
	{
		return;
	}
	if ( isDefined( player ) && !is_true( player.is_server ) )
	{
		player iPrintLn( message );
	}	
}

com_iprintln_array( message, players, arg_list )
{
	if ( is_true( level.doing_command_system_unittest ) )
	{
		return;
	}
	if ( array_validate( players ) )
	{
		for ( i = 0; i < players.size; i++ )
		{
			players[ i ] iPrintLn( message );
		}
	}
}

com_iprintlnbold( message, players, arg_list )
{
	if ( is_true( level.doing_command_system_unittest ) )
	{
		return;
	}
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] iPrintLnBold( message );
	}
}

com_tell( message, player, arg_list )
{
	if ( is_true( level.doing_command_system_unittest ) )
	{
		return;
	}
	if ( isDefined( player ) && !is_true( player.is_server ) )
	{
		cmdexec( "tell " + player getEntityNumber() + " " + message );
	}
}

com_tell_array( message, players, arg_list )
{
	if ( is_true( level.doing_command_system_unittest ) )
	{
		return;
	}
	if ( array_validate( players ) )
	{
		for ( i = 0; i < players.size; i++ )
		{
			cmdexec( "tell " + players[ i ] getEntityNumber() + " " + message );
		}
	}
}

com_say( message, players, arg_list )
{
	if ( is_true( level.doing_command_system_unittest ) )
	{
		return;
	}
	cmdexec( "say " + message );
}

com_printf( channels, filter, message, players )
{
	if ( !isDefined( channels ) )
	{
		return;
	}
	if ( !isDefined( filter ) )
	{
		return;
	}
	if ( !isDefined( message ) )
	{
		return;
	}
	channel_keys = strTok( channels, "|" );
	for ( i = 0; i < channel_keys.size; i++ )
	{
		channel = channel_keys[ i ];
		if ( com_is_channel_active( channel ) && com_is_filter_active( filter ) )
		{
			if ( channel == "g_log" )
			{
				message_color_code = "";
			}
			else 
			{
				message_color_code = "^8";
			}
			message_modified = com_caps_msg_title( channel, filter ) + message_color_code + message;
			if ( array_validate( players ) )
			{
				channel = channel + "_array";
			}
			[[ level.com_channels[ channel ] ]]( message_modified, players );
		}
	}
}

com_get_cmd_feedback_channel()
{
	if ( is_true( self.is_server ) )
	{
		return "con";
	}
	else if ( is_true( level.doing_command_system_unittest ) )
	{
		return "g_log";
	}
	else 
	{
		return "iprint";
	}
}