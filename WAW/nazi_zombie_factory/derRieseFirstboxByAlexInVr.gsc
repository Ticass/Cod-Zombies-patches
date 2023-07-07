
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
		player thread OnPlayerSpawned();
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
	hud.x = hud.x - -820; 
	hud.y = hud.y + 35; 
	hud.alpha = 1;
	time_text = string(GetTime() / 1000);
	flag_wait("all_players_spawned");
	while (1){
		hud setTimerUp(1);
		hud setTimer(time_text);
	}
	
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







custom_treasure_chest_ChooseRandomWeapon( player )
{
	if (level.round_number <= 20){
		if (!(player HasWeapon("tesla_gun"))){
			return "tesla_gun";
		}

		if (!(player HasWeapon("zombie_cymbal_monkey"))){
			return "zombie_cymbal_monkey";
		}

		if (!(player HasWeapon("ray_gun"))){
			return "ray_gun";
		}

		
	}

	keys = GetArrayKeys( level.zombie_weapons );

	// Filter out any weapons the player already has
	filtered = [];
	for( i = 0; i < keys.size; i++ )
	{
		if( !maps\_zombiemode_weapons::get_is_in_box( keys[i] ) )
		{
			continue;
		}
		
		if( player maps\_zombiemode_weapons::has_weapon_or_upgrade( keys[i] ) )
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
				if( players[i] maps\_zombiemode_weapons::has_weapon_or_upgrade( keys2[q] ) )
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

	if (level.round_number <= 20){
		if (!(player HasWeapon("tesla_gun"))){
			return "tesla_gun";
		}

		if (!(player HasWeapon("zombie_cymbal_monkey"))){
			return "zombie_cymbal_monkey";
		}

		if (!(player HasWeapon("ray_gun"))){
			return "ray_gun";
		}

		
	}

	keys = GetArrayKeys( level.zombie_weapons );

	// Filter out any weapons the player already has
	filtered = [];
	for( i = 0; i < keys.size; i++ )
	{
		if( !maps\_zombiemode_weapons::get_is_in_box( keys[i] ) )
		{
			continue;
		}
		
		if( player maps\_zombiemode_weapons::has_weapon_or_upgrade( keys[i] ) )
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
				if( players[i] maps\_zombiemode_weapons::has_weapon_or_upgrade( keys2[q] ) )
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

weapon_give_custom( weapon, is_upgrade )
{
	primaryWeapons = self GetWeaponsListPrimaries(); 
	current_weapon = undefined; 

	//if is not an upgraded perk purchase

	self play_sound_on_ent( "purchase" );
	self GiveWeapon( weapon, 0 ); 
	self GiveMaxAmmo( weapon ); 
	self SwitchToWeapon( weapon );
	 
	maps\_zombiemode_weapons::play_weapon_vo(weapon);
}

power_electric_switch_custom()
{
	trig = getent("use_power_switch","targetname");
	master_switch = getent("power_switch","targetname");	
	master_switch notsolid();
	//master_switch rotatepitch(90,1);
	trig sethintstring(&"ZOMBIE_ELECTRIC_SWITCH");
		
	//turn off the buyable door triggers for electric doors
// 	door_trigs = getentarray("electric_door","script_noteworthy");
// 	array_thread(door_trigs,::set_door_unusable);
// 	array_thread(door_trigs,::play_door_dialog);

	cheat = false;
	
/# 
	if( GetDvarInt( "zombie_cheat" ) >= 3 )
	{
		wait( 5 );
		cheat = true;
	}
#/	

	user = undefined;
	
	// MM - turning on the power powers the entire map
// 	if ( IsDefined(user) )	// only send a notify if we weren't originally triggered through script
// 	{
// 		other_trig = getent("use_warehouse_switch","targetname");
// 		other_trig notify( "trigger", undefined );
// 
// 		wuen_trig = getent("use_wuen_switch", "targetname" );
// 		wuen_trig notify( "trigger", undefined );
// 	}

	master_switch rotateroll(-90,.3);

	//TO DO (TUEY) - kick off a 'switch' on client script here that operates similiarly to Berlin2 subway.
	master_switch playsound("switch_flip");
	flag_set( "electricity_on" );
	wait_network_frame();
	clientnotify( "revive_on" );
	wait_network_frame();
	clientnotify( "fast_reload_on" );
	wait_network_frame();
	clientnotify( "doubletap_on" );
	wait_network_frame();
	clientnotify( "jugger_on" );
	wait_network_frame();
	level notify( "sleight_on" );
	wait_network_frame();
	level notify( "revive_on" );
	wait_network_frame();
	level notify( "doubletap_on" );
	wait_network_frame();
	level notify( "juggernog_on" );
	wait_network_frame();
	level notify( "Pack_A_Punch_on" );
	wait_network_frame();
	level notify( "specialty_armorvest_power_on" );
	wait_network_frame();
	level notify( "specialty_rof_power_on" );
	wait_network_frame();
	level notify( "specialty_quickrevive_power_on" );
	wait_network_frame();
	level notify( "specialty_fastreload_power_on" );
	wait_network_frame();

//	clientnotify( "power_on" );
	ClientNotify( "pl1" );	// power lights on
	exploder(600);

	trig delete();	
	
	playfx(level._effect["switch_sparks"] ,getstruct("power_switch_fx","targetname").origin);

	// Don't want east or west to spawn when in south zone, but vice versa is okay
	maps\_zombiemode_zone_manager::connect_zones( "outside_east_zone", "outside_south_zone" );
	maps\_zombiemode_zone_manager::connect_zones( "outside_west_zone", "outside_south_zone", true );
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

		
		wait 1.5;

		self IPrintLnBold("First box by ^1twitch.tv/^2AlexInVR");
		// level.round_number = 20;
		// self maps\_zombiemode_score::add_to_player_score( 20000 );
		// flag_set("electricity_on");
		// flag_set( "teleporter_pad_link_1" );
		// flag_set( "teleporter_pad_link_2" );
		// flag_set( "teleporter_pad_link_3" );
		// level thread power_electric_switch_custom();
		// level maps\_zombiemode_perks::turn_PackAPunch_on();
		// player weapon_give_custom("tesla_gun_upgraded");
		// player weapon_give_custom("ray_gun_upgraded");
		// player TakeWeapon("zombie_colt");
		// player maps\_zombiemode_cymbal_monkey::player_give_cymbal_monkey();
		// player SetPerk("specialty_fastreload");
		// player maps\_zombiemode_perks::perk_hud_create("specialty_fastreload");
		// player maps\_zombiemode_bowie::give_bowie();
	}
	
}