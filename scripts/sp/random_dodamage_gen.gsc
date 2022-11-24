main()
{
	replaceFunc( GetFunction( "maps/_utility", "wait_network_frame" ), ::wait_network_frame );
	build_idflags_array();
	build_hitlocs_array();
	build_mods_array();

	cmd_register_arg_type_handlers( "float", ::arg_generate_rand_float );
	cmd_register_arg_type_handlers( "vector", ::arg_generate_rand_vector );
	cmd_register_arg_type_handlers( "entity", ::arg_generate_rand_entity );
	cmd_register_arg_type_handlers( "zombie", ::arg_generate_rand_entity_not_player );
	cmd_register_arg_type_handlers( "hitloc", ::arg_generate_rand_hitloc );
	cmd_register_arg_type_handlers( "MOD", ::arg_generate_rand_mod );
	cmd_register_arg_type_handlers( "idflags", ::arg_generate_rand_idflags );
	cmd_register_arg_type_handlers( "weapon", ::arg_generate_rand_weapon );
}

wait_network_frame()
{
	wait 0.05;
}

init()
{
	level thread onPlayerConnect();

	level thread spitOutTime();
}

spitOutTime()
{
	startTime = GetTime();

	for ( ;; )
	{
		wait 60;
		PrintConsole( "TIME: " + ( GetTime() - startTime ) );
	}
}

onPlayerConnect()
{
	for ( ;; )
	{
		level waittill( "connected", player );

		player thread onSpawned();
	}
}

onSpawned()
{
	self endon( "disconnect" );

	self.killingAll = false;

	for ( ;; )
	{
		self waittill( "spawned_player" );

		self thread killAllZombsWithBullets();
		self thread watchKillAllButton();
	}
}

watchKillAllButton()
{
	self endon( "disconnect" );
	self endon( "death" );

	wait 5;

	self notifyOnPlayerCommand( "+smoke", "toggle_dodamagetest" );

	for ( ;; )
	{
		self waittill( "toggle_dodamagetest" );

		self.killingAll = !self.killingAll;
		self iPrintLn( "Doing damage randomly: " + self.killingAll );
	}
}

do_random_damage_randomly()
{
	cmd_dodamage_f( create_random_valid_args2() );
}

killAllZombsWithBullets()
{
	self endon( "disconnect" );
	self endon( "death" );

	for ( ;; )
	{
		wait 0.05;

		if ( !self.killingAll )
			continue;

		self do_random_damage_randomly();
	}
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

arg_generate_rand_entity_not_player()
{
	entities = getEntArray();
	if ( entities.size < 4 )
	{
		return undefined;
	}
	entity = entities[ randomInt( entities.size ) ];
	while ( entity getEntityNumber() < 4 )
	{
		entity = entities[ randomInt( entities.size ) ];
	}
	return entity;
}

arg_generate_rand_entity()
{
	entities = getEntArray();
	return entities[ randomInt( entities.size ) ];	
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

arg_generate_rand_weapon()
{
	weapon_keys = getArrayKeys( level.zombie_include_weapons );
	return weapon_keys[ randomInt( weapon_keys.size ) ];	
}

arg_generate_rand_hitloc()
{
	hitlocs = getArrayKeys( level.tcs_hitlocs );
	return hitlocs[ randomInt( hitlocs.size ) ];
}

arg_generate_rand_mod()
{
	mods = getArrayKeys( level.tcs_mods );
	return mods[ randomInt( mods.size ) ];
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

create_random_valid_args2()
{
	args = [];
	types = strTok( "entity_not_player float vector entity entity hitloc MOD idflags weapon", " " );

	minargs = 3;
	for ( i = 0; i < minargs; i++ )
	{
		args[ i ] = generate_args_from_type( types[ i ] );
	}

	max_optional_args = randomInt( types.size );

	for ( i = minargs; i < max_optional_args; i++ )
	{
		args[ i ] = generate_args_from_type( types[ i ] );
	}
	return args;
}

cmd_register_arg_type_handlers( argtype, rand_gen_func )
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
	level.tcs_arg_type_handlers[ argtype ].rand_gen_func = rand_gen_func;
}

generate_args_from_type( type )
{
	if ( isDefined( level.tcs_arg_type_handlers[ type ] ) )
	{
		arg = [[ level.tcs_arg_type_handlers[ type ].rand_gen_func ]]();
		if ( isDefined( arg ) )
		{
			return arg;
		}
	}
	return "";
}

cmd_dodamage_f( arg_list )
{
	result = [];
	target = arg_list[ 0 ];
	if ( !isDefined( target ) )
	{
		return;
	}
	damage = arg_list[ 1 ];
	pos = arg_list[ 2 ];
	attacker = arg_list[ 3 ];
	inflictor = arg_list[ 4 ];
	hitloc = arg_list[ 5 ];
	mod = arg_list[ 6 ];
	idflags = arg_list[ 7 ];
	weapon = arg_list[ 8 ];
	switch ( arg_list.size )
	{
		case 3:
			target dodamage( damage, pos );
			break;
		case 4:
			target dodamage( damage, pos, attacker );
			break;
		case 5:
			target dodamage( damage, pos, attacker, inflictor );
			break;
		case 6:
			target dodamage( damage, pos, attacker, inflictor, hitloc );
			break;
		case 7:
			target dodamage( damage, pos, attacker, inflictor, hitloc, mod );
			break;
		case 8:
			target dodamage( damage, pos, attacker, inflictor, hitloc, mod, idflags );
			break;
		case 9:
			target dodamage( damage, pos, attacker, inflictor, hitloc, mod, idflags, weapon );
			break;
		default:
	}
}