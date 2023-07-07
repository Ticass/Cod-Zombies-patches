#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

//First Box by twitch.tv/AlexInVR

init()
{
	replacefunc(maps\_zombiemode::round_think, ::custom_round_think);
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


custom_round_think()
{
	for( ;; )
	{
		level.round_spawn_func = maps\_zombiemode::round_spawning;
		//////////////////////////////////////////
		//designed by prod DT#36173
		maxreward = 50 * level.round_number;
		if ( maxreward > 500 )
			maxreward = 500;
		level.zombie_vars["rebuild_barrier_cap_per_round"] = maxreward;
		//////////////////////////////////////////

		level.round_timer = level.zombie_vars["zombie_round_time"]; 
		
		add_later_round_spawners();

		maps\_zombiemode::chalk_one_up();
		//		round_text( &"ZOMBIE_ROUND_BEGIN" );

		maps\_zombiemode_powerups::powerup_round_start();

		players = get_players();
		array_thread( players, maps\_zombiemode_blockers::rebuild_barrier_reward_reset );

		level thread maps\_zombiemode::award_grenades_for_survivors();

		level.round_start_time = getTime();
		level thread [[level.round_spawn_func]]();
		level notify("start_of_round");

		maps\_zombiemode::round_wait(); 
		level.first_round = false;
		level notify( "end_of_round" );

		level thread maps\_zombiemode::spectators_respawn();

		//		round_text( &"ZOMBIE_ROUND_END" );
		level thread maps\_zombiemode::chalk_round_hint();

		wait( level.zombie_vars["zombie_between_round_time"] ); 

		// here's the difficulty increase over time area
		timer = level.zombie_vars["zombie_spawn_delay"];

		if( timer < 0.08 )
		{
			timer = 0.08; 
		}	

		level.zombie_vars["zombie_spawn_delay"] = timer * 0.95;

		// Increase the zombie move speed
		level.zombie_move_speed = level.round_number * 8;

		level.round_number++;

		level notify( "between_round_over" );

		printLn( "Round " + level.round_number + " started." );
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
	flag_wait("all_players_spawned");
	hud setTimerUp(1);
}

round_timer()
{	
	timerHud = create_simple_hud( self );
	timerHud.foreground = true; 
	timerHud.sort = 1; 
	timerHud.hidewheninmenu = true; 
	timerHud.alignX = "left"; 
	timerHud.alignY = "top";
	timerHud.horzAlign = "user_left"; 
	timerHud.vertAlign = "user_top";
	timerHud.x = timerHud.x - -700; 
	timerHud.y = timerHud.y + 45;
	timerHud.color =  (1, 0, 0);
	timerHud.alpha = 1;
	flag_wait("all_players_spawned");
	for (;;){
		start_time = GetTime() / 1000;
		timerHud setTimerUp(0);
		level waittill("end_of_round");
		end_time = GetTime() / 1000;
		time = end_time - start_time;
		set_time_frozen(timerHud, time); 
	}
	
}

set_time_frozen(hud, time)
{
	level endon("start_of_round");
	time = time - 0.1;
	while(1)
	{
		hud settimer(time);
		wait(0.5);
	}
}

onPlayerSpawned()
{
	self endon( "disconnect" ); 

	for( ;; )
	{
		
		level waittill( "connected", player ); 
		self thread game_timer();
		self thread round_timer();
		self SetClientDvars( 
			"player_backSpeedScale", "1", 
			"player_strafeSpeedScale", "1");
		
		wait 3;

		self IPrintLnBold("ZWR safe patch by ^1twitch.tv/^2AlexInVR");
	}
	
	
}   