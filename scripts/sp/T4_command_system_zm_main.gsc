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
	cmd_addservercommand( "spectator", "spec", "spectator <name|guid|clientnum|self>", ::CMD_SPECTATOR_f, level.cmd_power_cheat, 1 );
	cmd_addservercommand( "togglerespawn", "togresp", "togglerespawn <name|guid|clientnum|self>", ::CMD_TOGGLERESPAWN_f, level.cmd_power_cheat, 1 );
	cmd_addservercommand( "killactors", "ka", "killactors", ::CMD_KILLACTORS_f, level.cmd_power_cheat, 0 );
	cmd_addservercommand( "respawnspectators", "respspec", "respawnspectators", ::CMD_RESPAWNSPECTATORS_f, level.cmd_power_cheat, 0 );
	cmd_addservercommand( "givepoints", "gpts", "givepoints <name|guid|clientnum|self> <amount>", ::CMD_GIVEPOINTS_f, level.cmd_power_cheat, 2 );
	cmd_addservercommand( "giveautokill", "gak", "giveautokill <name|guid|clientnum|self>", ::cmd_giveautokill_f, level.cmd_power_cheat, 1 );
	cmd_addclientcommand( "points", "pts", "points <amount>", ::CMD_POINTS_f, level.cmd_power_cheat, 1 );
	cmd_addclientcommand( "autokill", "ak", "autokill", ::cmd_autokill_f, level.cmd_power_cheat, 0 );
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
	target = self find_player_in_server( arg_list[ 0 ] );
	if ( !isDefined( target ) )
	{
		return result;
	}
	points = int( arg_list[ 1 ] );
	target give_player_score( points );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Gave " + target.playername + " " + points + " points";
	return result;
}

CMD_SPECTATOR_f( arg_list )
{
	result = [];
	target = self find_player_in_server( arg_list[ 0 ] );
	if ( !isDefined( target ) )
	{
		return result;
	}
	target maps\_zombiemode::spawnspectator();
	if ( !isDefined( target.tcs_original_respawn ) )
	{
		target.tcs_original_respawn = target.spectator_respawn;
	}
	target.spectator_respawn = undefined;
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Successfully made " + target.playername + " a spectator";
	return result;
}

CMD_TOGGLERESPAWN_f( arg_list )
{
	result = [];
	target = self find_player_in_server( arg_list[ 0 ] );
	if ( !isDefined( target ) )
	{
		return result;
	}
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
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = target.playername + " has their respawn toggled";
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
	points = int( arg_list[ 0 ] );
	self give_player_score( points );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Gave you " + points + " points";
	return result;
}

cmd_giveautokill_f( arg_list )
{
	result = [];
	target = self find_player_in_server( arg_list[ 0 ] );
	if ( !isDefined( target ) )
	{
		return result;
	}
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
	self endon( "disconnect" );
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
		while ( self isThrowingGrenade() || isDefined( self.is_drinking ) && self.is_drinking > 0 || self isSwitchingWeapons() )
		{
			wait 0.05;
		}
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