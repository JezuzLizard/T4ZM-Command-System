#include common_scripts\utility;
#include maps\_utility;
#include scripts\sp\csm\_cmd_util;
#include scripts\sp\csm\_com;

cmd_unittest_validargs_f( arg_list )
{
	result = [];
	level.doing_command_system_unittest = !is_true( level.doing_command_system_unittest );
	if ( level.doing_command_system_unittest )
	{
		if ( isDefined( arg_list[ 0 ] ) )
			required_bots = int( arg_list[ 0 ] );
		else 
			required_bots = 1;
		setDvar( "tcs_unittest", required_bots );
		level.unittest_total_commands_used = 1;
		level thread do_unit_test();
		level notify( "unittest_start" );
	}
	else 
	{
		setDvar( "tcs_unittest", 0 );
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Command system unit test activated";
	return result;
}

do_unit_test()
{
	while ( true )
	{
		required_bots = getDvarInt( "tcs_unittest" );
		if ( required_bots == 0 )
		{
			break;
		}
		bot_count = 0;
		players = getPlayers();
		for ( i = 0; i < players.size; i++ )
		{
			if ( is_true( players[ i ].pers["isBot"] ) )
			{
				bot_count++;
			}
		}
		if ( bot_count < required_bots )
		{
			bot = addtestclient();
			bot.pers[ "isBot" ] = true;
			if ( isDefined( level.bot_command_system_unittest_func ) )
			{
				bot [[ level.bot_command_system_unittest_func ]]();
			}
		}

		wait 1;
	}
	/*
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		if ( is_true( players[ i ].pers["isBot"] ) )
		{
			removeTestClient( players[ i ] getEntityNumber() );
		}
	}
	*/
	level.doing_command_system_unittest = false;
}

activate_random_cmds()
{
	self endon( "disconnect" );
	self.health = 2100000000;
	while ( !isDefined( self._connected ) )
	{
		wait 1;
	}
	while ( true )
	{
		self construct_chat_message();
		wait 0.05;
	}
}

construct_chat_message()
{
	cmdalias = arg_generate_rand_cmdalias();
	//logprint( "random cmdalias: " + cmdalias + "\n" );
	cmdname = get_client_cmd_from_alias( cmdalias );
	is_clientcmd = true;
	if ( cmdname == "" )
	{
		cmdname = get_server_cmd_from_alias( cmdalias );
		is_clientcmd = false;
	}
	if ( cmdname == "" )
	{
		return;
	}
	//logprint( "random cmdname: " + cmdname + "\n" );
	cmdargs = create_random_valid_args2( cmdname, is_clientcmd );
	if ( cmdargs.size == 0 )
	{
		message = cmdname;
	}
	else 
	{
		arg_str = repackage_args( cmdargs );
		message = cmdname + " " + arg_str;
	}
	cmd_log = self.playername + " executed " + message + " count " + level.unittest_total_commands_used;
	level scripts\sp\csm\_com::com_printf( "con", "notitle", cmd_log );
	level scripts\sp\csm\_com::com_printf( "g_log", "cmdinfo", cmd_log );
	level notify( "say", message, self, true );
	level.unittest_total_commands_used++;
}

get_cmdargs_types( cmdname, is_clientcmd )
{
	if ( is_clientcmd )
	{
		return level.client_commands[ cmdname ].argtypes;
	}
	else 
	{
		return level.server_commands[ cmdname ].argtypes;
	}
}

create_random_valid_args2( cmdname, is_clientcmd )
{
	//message = "cmdname: " + cmdname + " is_clientcmd: " + is_clientcmd;
	//logprint( message + "\n" );
	args = [];
	types = get_cmdargs_types( cmdname, is_clientcmd );

	if ( !isDefined( types ) )
	{
		return args;
	}
	if ( is_clientcmd )
	{
		minargs = level.client_commands[ cmdname ].minargs;
	}
	else 
	{
		minargs = level.server_commands[ cmdname ].minargs;
	}
	//message = "minargs: " + minargs;
	//logprint( message + "\n" );
	for ( i = 0; i < minargs; i++ )
	{
		args[ i ] = generate_args_from_type( types[ i ] );
		//message1 = "types defined: " + isDefined( types[ i ] ) + " args defined: " + isDefined( args[ i ] );
		//logprint( message1 + "\n" );
		//message = "minargs: " + minargs +  " types[" + i + "]: " + types[ i ] + " args[" + i + "]: " + args[ i ];
		//logprint( message + "\n" );
	}

	if ( cointoss() ) // 50% chance we don't add optional args
	{
		//message = "returning early (rng)";
		//logprint( message + "\n" );
		return args;
	}

	max_optional_args = randomInt( types.size );

	//message = "max_optional_args: " + max_optional_args;
	//logprint( message + "\n" );
	for ( i = minargs; i < max_optional_args; i++ )
	{
		args[ i ] = generate_args_from_type( types[ i ] );
		//message = "max_optional_args: " + max_optional_args + " types[" + i + "]: " + types[ i ] + " args[" + i + "]: " + args[ i ];
		//logprint( message + "\n" );
	}
	return args;
}

generate_args_from_type( type )
{
	if ( isDefined( level.tcs_arg_type_handlers[ type ] ) )
	{
		return [[ level.tcs_arg_type_handlers[ type ].rand_gen_func ]]() + "";
	}
	return "";
}