#include scripts\csm\_cmd_util;
#include scripts\sp\csm_zm\_zm_cmd_util;
#include common_scripts\utility;
#include maps\_utility;

main()
{
	while ( !is_true( level.command_init_done ) )
	{
		wait 0.05;
	}
	cmd_addservercommand( "spectator", "spectator spec", "spectator <name|guid|clientnum|self>", ::CMD_SPECTATOR_f, level.cmd_power_cheat );
	cmd_addservercommand( "togglerespawn", "togglerespawn togresp", "togglerespawn <name|guid|clientnum|self>", ::CMD_TOGGLERESPAWN_f, level.cmd_power_cheat );
	cmd_addservercommand( "killactors", "killactors ka", "killactors", ::CMD_KILLACTORS_f, level.cmd_power_cheat );
	cmd_addservercommand( "respawnspectators", "respawnspectators respspec", "respawnspectators", ::CMD_RESPAWNSPECTATORS_f, level.cmd_power_cheat );
	cmd_addservercommand( "givepoints", "givepoints gpts", "givepoints <name|guid|clientnum|self> <amount>", ::CMD_GIVEPOINTS_f, level.cmd_power_cheat );
	cmd_addclientcommand( "points", "points pts", "points <amount>", ::CMD_POINTS_f, level.cmd_power_cheat );
	level.zm_command_init_done = true;
}

CMD_KILLACTORS_f( arg_list )
{
	result = [];
	kill_all_zombies();
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Killed all zombies";
	return result;
}

kill_all_zombies()
{
	ais = getaiarray( "axis" );
	for ( i = 0; i < ais.size; i++ )
    {
		zombie = ais[ i ];
        if ( isdefined( zombie ) )
        {
            zombie dodamage( zombie.health + 666, zombie.origin, zombie, zombie, "none", "MOD_SUICIDE" );
        }
    }
}

CMD_GIVEPOINTS_f( arg_list )
{
	result = [];
	target = undefined;
	if ( array_validate( arg_list ) && arg_list.size == 2 )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( isDefined( target ) )
		{
			points = int( arg_list[ 1 ] );
			target give_player_score( points );
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = "Gave " + target.name + " " + points + " points";
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
		result[ "message" ] = "Usage givepoints <name|guid|clientnum|self> <amount>";
	}
	return result;
}

CMD_SPECTATOR_f( arg_list )
{
	result = [];
	target = undefined;
	if ( array_validate( arg_list ) )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( isDefined( target ) )
		{
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = "Successfully made " + target.name + " a spectator";
		}
		else 
		{

			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Could not find player";
		}
	}
	if ( isDefined( target ) )
	{
		target maps\_zombiemode::spawnspectator();
		if ( !isDefined( target.tcs_original_respawn ) )
		{
			target.tcs_original_respawn = target.spectator_respawn;
		}
		target.spectator_respawn = undefined;
	}
	return result;
}

CMD_TOGGLERESPAWN_f( arg_list )
{
	result = [];
	target = undefined;
	if ( array_validate( arg_list ) )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( isDefined( target ) )
		{
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = target.name + " has their respawn toggled";
		}
		else 
		{

			result[ "filter" ] = "cmderror";
			result[ "message" ] = "Could not find player";
		}
	}
	if ( isDefined( target ) )
	{
		currently_respawning = isDefined( target.spectator_respawn );
		if ( !isDefined( target.tcs_original_respawn ) )
		{
			target.tcs_original_respawn = target.spectator_respawn;
		}
		if ( currently_respawning )
		{
			target.spectator_respawn = undefined;
		}
		else 
		{
			target.spectator_respawn = target.tcs_original_respawn;
		}
	}
	return result;
}

CMD_RESPAWNSPECTATORS_f( arg_list )
{
	result = [];
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		if ( players[ i ].sessionstate == "spectator" && isDefined( players[ i ].spectator_respawn ) )
		{
			players[ i ] [[ level.spawnplayer ]]();

			if ( isDefined( level.script ) && level.round_number > 6 && players[ i ].score < 1500 )
			{
				players[ i ].old_score = players[ i ].score;

				if ( isDefined( level.spectator_respawn_custom_score ) )
					players[ i ] [[ level.spectator_respawn_custom_score ]]();

				players[ i ].score = 1500;
			}
		}
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Successfully respawned all spectators";
	return result;
}

CMD_POINTS_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) )
	{
		points = int( arg_list[ 0 ] );
		self give_player_score( points );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = "Gave you " + points + " points";
	}
	else
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage points <amount>";
	}
	return result;
}