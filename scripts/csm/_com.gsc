#include common_scripts\utility;
#include maps\_utility;
#include scripts\csm\_cmd_util;

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
	com_addfilter( "obituary", 1 );
	com_addfilter( "notitle", 1 );

	com_addchannel( "con", ::com_print );
	com_addchannel( "g_log", ::com_logprint );
	com_addchannel( "iprint", ::com_iprintln );
	com_addchannel( "iprintbold", ::com_iprintlnbold );
	com_addchannel( "tell", ::com_tell );
	com_addchannel( "say", ::com_say );
}

com_addfilter( filter, default_value )
{
	if ( !isDefined( level.com_filters ) )
	{
		level.com_filters = [];
	}
	if ( !isDefined( level.com_filters[ filter ] ) )
	{
		level.com_filters[ filter ] = getDvarIntDefault( "com_script_channel_" + filter, default_value );
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

com_iprintln( message, players, arg_list )
{
	if ( array_validate( players ) )
	{
		for ( i = 0; i < players.size; i++ )
		{
			players[ i ] iPrintLn( message );
		}
	}
	else if ( isDefined( players ) )
	{
		players iPrintLn( message );
	}
	else 
	{
		com_print( "com_printf() msg " + message + " sent for channel iprintln has bad players arg" );
	}
}

com_iprintlnbold( message, players, arg_list )
{
	for ( i = 0; i < level.players.size; i++ )
	{
		level.players[ i ] iPrintLnBold( message );
	}
}

com_tell( message, players, arg_list )
{
	if ( array_validate( players ) )
	{
		for ( i = 0; i < players.size; i++ )
		{
			cmdexec( "tell " + players[ i ] getEntityNumber() + " " + message );
		}
	}
	else if ( isDefined( players ) )
	{
		cmdexec( "tell " + players getEntityNumber() + " " + message );
	}
	else 
	{
		com_print( "com_printf() msg " + message + " sent for channel tell has bad players arg" );
	}
}

com_say( message, players, arg_list )
{
	cmdexec( "say " + message );
}

com_printf( channels, filter, message, players, arg_list )
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
			message = com_caps_msg_title( channel, filter ) + message_color_code + message;
			[[ level.com_channels[ channel ] ]]( message, players, arg_list );
		}
	}
}

com_get_cmd_feedback_channel()
{
	return "iprint";
}