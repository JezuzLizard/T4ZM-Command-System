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
	cmd_addcommand( "spectator", false, "spec", "spectator <name|guid|clientnum|self>", ::CMD_SPECTATOR_f, "cheat", 1, false );
	cmd_addcommand( "togglerespawn", false, "togresp", "togglerespawn <name|guid|clientnum|self>", ::CMD_TOGGLERESPAWN_f, "cheat", 1, false );
	cmd_addcommand( "killactors", false, "ka", "killactors", ::CMD_KILLACTORS_f, "cheat", 0, false );
	cmd_addcommand( "respawnspectators", false, "respspec", "respawnspectators", ::CMD_RESPAWNSPECTATORS_f, "cheat", 0, false );
	cmd_addcommand( "givepoints", false, "gpts", "givepoints <name|guid|clientnum|self> <amount>", ::cmd_givepoints_f, "cheat", 2, false );
	cmd_addcommand( "giveautokill", false, "gak", "giveautokill <name|guid|clientnum|self>", ::cmd_giveautokill_f, "cheat", 1, true );

	cmd_register_arg_types_for_cmd( "spectator", "player" );
	cmd_register_arg_types_for_cmd( "togglerespawn", "player" );
	cmd_register_arg_types_for_cmd( "givepoints", "player int" );

	cmd_addcommand( "points", true, "pts", "points <amount>", ::CMD_POINTS_f, "cheat", 1, false );
	cmd_addcommand( "autokill", true, "ak", "autokill", ::cmd_autokill_f, "cheat", 0, true );

	cmd_register_arg_types_for_cmd( "points", "int" );

	level thread check_for_command_alias_collisions();
	level thread on_unittest_start();
	level.zm_command_init_done = true;
}

on_unittest_start()
{
	while ( true )
	{
		level waittill( "unittest_start" );
		replaceFunc( maps\_callbackglobal::finishPlayerDamageWrapper, ::finishPlayerDamageWrapper_override );
	}
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
	ais = getAiSpeciesArray( "axis", "all" );
	for ( i = 0; i < ais.size; i++ )
	{
		zombie = ais[ i ];
		if ( isdefined( zombie ) )
		{
			zombie dodamage( zombie.health + 100, (0,0,0) );
		}
	}
}

CMD_SPECTATOR_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
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
	target = arg_list[ 0 ];
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
		if ( players[ i ].sessionstate == "spectator" )
		{
			players[ i ] [[ level.spawnplayer ]]();

			if ( isDefined( level.script ) && level.round_number > 6 && players[ i ].score < 1500 )
			{
				players[ i ].old_score = players[ i ].score;

				players[ i ].score = 1500;
				
				if ( isDefined( level.spectator_respawn_custom_score ) )
					players[ i ] [[ level.spectator_respawn_custom_score ]]();
			}
		}
	}
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Successfully respawned all spectators";
	return result;
}

cmd_giveautokill_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
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

cmd_givepoints_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
	points = arg_list[ 1 ];
	target give_player_score( points );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Gave " + target.playername + " " + points + " points";
	return result;	
}

CMD_POINTS_f( arg_list )
{
	result = [];
	points = arg_list[ 0 ];
	self give_player_score( points );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "Gave you " + points + " points";
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