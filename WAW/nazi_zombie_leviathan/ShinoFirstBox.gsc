#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

//First Box by twitch.tv/AlexInVR

init()
{
	 replacefunc(maps\_zombiemode_weapons::treasure_chest_ChooseRandomWeapon, ::custom_treasure_chest_ChooseRandomWeapon);
	 replacefunc(maps\_zombiemode_weapons::treasure_chest_ChooseWeightedRandomWeapon, ::custom_treasure_chest_ChooseWeightedRandomWeapon);
	thread onConnect();
   
}

onConnect()
{
	for(;;)
	{
		level waittill( "connecting", player );
		player thread onPlayerSpawned();
	}
}

get_is_in_box( weapon_name )
{
	AssertEx( IsDefined( level.zombie_weapons[weapon_name] ), weapon_name + " was not included or is not part of the zombie weapon list." );
	
	return level.zombie_weapons[weapon_name].is_in_box;
}

has_weapon_or_upgrade( weaponname )
{
	has_weapon = false;
	
	// If the weapon you're checking doesn't exist, it will return undefined
	if( IsDefined( level.zombie_include_weapons[weaponname] ) )
	{
		has_weapon = self HasWeapon( weaponname );
	}
	
	if( !has_weapon && isdefined( level.zombie_include_weapons[weaponname+"_upgraded"] ) )
	{
		has_weapon = self HasWeapon( weaponname+"_upgraded" );
	}

	return has_weapon;
}


custom_treasure_chest_ChooseRandomWeapon( player )
{

	if (level.round_number <= 25){
			if (!(player HasWeapon("zombie_zap_gun_dw"))){
				return "zombie_zap_gun_dw";
			}

			if (!(player HasWeapon("zombie_raygunmk2"))){
				return "zombie_raygunmk2";
			}
		}

	keys = GetArrayKeys( level.zombie_weapons );

	// Filter out any weapons the player already has
	filtered = [];
	for( i = 0; i < keys.size; i++ )
	{
		if( !get_is_in_box( keys[i] ) )
		{
			continue;
		}
		
		if( player has_weapon_or_upgrade( keys[i] ) )
		{
			continue;
		}
		
		if( player has_weapon_or_upgrade( "ballistic_knife_sickle" && keys[i] == "ballistic_knife"))
		{
			continue;
		}
		
		if( !IsDefined( keys[i] ) )
		{
			continue;
		}

		filtered[filtered.size] = keys[i];
	}
	
	// Filter out the limited weapons
	if( IsDefined( level.limited_weapons ) )
	{
		keys2 = GetArrayKeys( level.limited_weapons );
		players = get_players();
		pap_triggers = GetEntArray("zombie_vending_upgrade", "targetname");
		for( q = 0; q < keys2.size; q++ )
		{
			count = 0;
			for( i = 0; i < players.size; i++ )
			{
				if( players[i] has_weapon_or_upgrade( keys2[q] ) )
				{
					count++;
				}
			}

			// Check the pack a punch machines to see if they are holding what we're looking for
			for ( k=0; k<pap_triggers.size; k++ )
			{
				if ( IsDefined(pap_triggers[k].current_weapon) && pap_triggers[k].current_weapon == keys2[q] )
				{
					count++;
				}
			}

			if( count >= level.limited_weapons[keys2[q]] )
			{
				filtered = array_remove( filtered, keys2[q] );
			}
		}
	}

	return filtered[RandomInt( filtered.size )];
}

custom_treasure_chest_ChooseWeightedRandomWeapon( player )
{
	if (level.round_number <= 25){
			if (!(player HasWeapon("zombie_zap_gun_dw"))){
				return "zombie_zap_gun_dw";
			}

			if (!(player HasWeapon("zombie_raygunmk2"))){
				return "zombie_raygunmk2";
			}
		}

	keys = GetArrayKeys( level.zombie_weapons );

	// Filter out any weapons the player already has
	filtered = [];
	for( i = 0; i < keys.size; i++ )
	{
		if( !get_is_in_box( keys[i] ) )
		{
			continue;
		}
		
		if( player has_weapon_or_upgrade( keys[i] ) )
		{
			continue;
		}

		if( !IsDefined( keys[i] ) )
		{
			continue;
		}

		num_entries = [[ level.weapon_weighting_funcs[keys[i]] ]]();
		
		for( j = 0; j < num_entries; j++ )
		{
			filtered[filtered.size] = keys[i];
		}
	}
	
	// Filter out the limited weapons
	if( IsDefined( level.limited_weapons ) )
	{
		keys2 = GetArrayKeys( level.limited_weapons );
		players = get_players();
		pap_triggers = GetEntArray("zombie_vending_upgrade", "targetname");
		for( q = 0; q < keys2.size; q++ )
		{
			count = 0;
			for( i = 0; i < players.size; i++ )
			{
				if( players[i] has_weapon_or_upgrade( keys2[q] ) )
				{
					count++;
				}
			}

			// Check the pack a punch machines to see if they are holding what we're looking for
			for ( k=0; k<pap_triggers.size; k++ )
			{
				if ( IsDefined(pap_triggers[k].current_weapon) && pap_triggers[k].current_weapon == keys2[q] )
				{
					count++;
				}
			}

			if( count >= level.limited_weapons[keys2[q]] )
			{
				filtered = array_remove( filtered, keys2[q] );
			}
		}
	}
	
	return filtered[RandomInt( filtered.size )];
}



timer_til_despawn(floatHeight)
{


	// SRS 9/3/2008: if we timed out, move the weapon back into the box instead of deleting it
	putBackTime = 12;
	self MoveTo( self.origin - ( 0, 0, floatHeight ), putBackTime, ( putBackTime * 0.5 ) );
	wait( putBackTime );

	if(isdefined(self))
	{	
		self Delete();
	}
}

game_timer()
{	
	hud = create_simple_hud( self );
	hud.foreground = true; 
	hud.sort = 1; 
	hud.hidewheninmenu = true; 
	hud.alignX = "left"; 
	hud.alignY = "top";
	hud.horzAlign = "user_left"; 
	hud.vertAlign = "user_top";
	hud.x = hud.x - -700; 
	hud.y = hud.y + 35; 
	hud.alpha = 1;
	time_text = GetTime() / 1000;
	flag_wait("all_players_spawned");
	while (1){
		hud setTimerUp(0);
		hud setTimer(time_text);
	}
	
}

onPlayerSpawned()
{
	self endon( "disconnect" ); 

	for( ;; )
	{
		
		level waittill( "connected", player ); 
		self thread game_timer();
		self SetClientDvars( 
			"player_backSpeedScale", "1", 
			"player_strafeSpeedScale", "1");

		
		wait 3;

		self IPrintLnBold("First box by ^1twitch.tv/^2AlexInVR");
	}
	level waittill( "connected", player ); 
	
}   