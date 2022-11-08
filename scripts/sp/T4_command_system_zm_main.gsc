#include scripts\sp\csm\_cmd_util;
#include scripts\sp\csm_zm\_zm_cmd_util;
#include common_scripts\utility;
#include maps\_utility;

main()
{
	while ( !is_true( level.command_init_done ) )
	{
		wait 0.05;
	}
	cmd_addservercommand( "spectator", "spectator spec", "spectator <name|guid|clientnum|self>", ::CMD_SPECTATOR_f, level.cmd_power_cheat, 1 );
	cmd_addservercommand( "togglerespawn", "togglerespawn togresp", "togglerespawn <name|guid|clientnum|self>", ::CMD_TOGGLERESPAWN_f, level.cmd_power_cheat, 1 );
	cmd_addservercommand( "killactors", "killactors ka", "killactors", ::CMD_KILLACTORS_f, level.cmd_power_cheat, 0 );
	cmd_addservercommand( "respawnspectators", "respawnspectators respspec", "respawnspectators", ::CMD_RESPAWNSPECTATORS_f, level.cmd_power_cheat, 0 );
	cmd_addservercommand( "givepoints", "givepoints gpts", "givepoints <name|guid|clientnum|self> <amount>", ::CMD_GIVEPOINTS_f, level.cmd_power_cheat, 2 );
	cmd_addservercommand( "giveautokill", "giveautokill gak", "giveautokill <name|guid|clientnum|self>", ::cmd_giveautokill_f, level.cmd_power_cheat, 1 );
	cmd_addclientcommand( "points", "points pts", "points <amount>", ::CMD_POINTS_f, level.cmd_power_cheat, 1 );
	cmd_addclientcommand( "autokill", "autokill ak", "autokill", ::cmd_autokill_f, level.cmd_power_cheat, 0 );
	level thread check_for_command_alias_collisions();
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
			zombie dodamage( zombie.health + 100, (0,0,0) );
		}
	}
	ais = getAiSpeciesArray( "axis", "dog" );
	for ( i = 0; i < ais.size; i++ )
	{
		zombie = ais[ i ];
		if ( isdefined( zombie ) )
		{
			zombie dodamage( zombie.health + 100, (0,0,0) );
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
			result[ "message" ] = "Gave " + target.playername + " " + points + " points";
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
			result[ "message" ] = "Successfully made " + target.playername + " a spectator";
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
			result[ "message" ] = target.playername + " has their respawn toggled";
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
	players = getPlayers();
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

cmd_giveautokill_f( arg_list )
{
	result = [];
	target = undefined;
	if ( array_validate( arg_list ) )
	{
		target = self find_player_in_server( arg_list[ 0 ] );
		if ( isDefined( target ) )
		{
			if ( is_true( target.autokill_active ) )
			{
				target notify( "toggle_autokill" );
			}
			else 
			{
				target thread kill_all_zombs_with_bullets();
				target thread autokill_toggle();
			}
			result[ "cmdinfo" ] = "cmdinfo";
			result[ "message" ] = "Toggled autokill for " + target.playername;
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
		result[ "message" ] = "Usage: giveautokill <name|guid|clientnum|self>"; 
	}
	return result;
}

cmd_autokill_f( arg_list )
{
	result = [];
	if ( is_true( self.autokill_active ) )
	{
		self notify( "toggle_autokill" );
	}
	else 
	{
		self thread kill_all_zombs_with_bullets();
		self thread autokill_toggle();
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Toggled autokill for " + self.playername;
	return result;
}

do_magic_bullets()
{
	zombies = GetAiSpeciesArray( "axis", "all" );
	myeye = self getTagOrigin( "j_head" );
	weap = self GetCurrentWeapon();

	for ( i = 0; i < zombies.size; i++ )
	{
		zombie = zombies[i];

		if ( isDefined( zombie ) )
		{
			hit_loc = undefined;

			if ( randomint( 2 ) )
				hit_loc = zombie getTagOrigin( "j_head" );
			else
				hit_loc = zombie getTagOrigin( "j_spine4" );

			if ( isDefined( hit_loc ) )
			{
				if ( sighttracepassed( myeye, hit_loc, false, self ) )
				{
					magicbullet( weap, myeye, hit_loc, self );
				}
			}
		}
	}
}

kill_all_zombs_with_bullets()
{
	self endon( "disconnect" );
	self endon( "zombified" );
	self endon( "toggle_autokill" );

	for ( ;; )
	{
		wait 0.05;
		self thread do_magic_bullets();
	}
}

autokill_toggle()
{
	self endon( "disconnect" );
	self.autokill_active = true;
	self waittill_either( "zombified", "toggle_autokill" );
	self.autokill_active = false;
}