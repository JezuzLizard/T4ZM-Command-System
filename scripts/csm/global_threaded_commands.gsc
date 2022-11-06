#include scripts\csm\_cmd_util;
#include common_scripts\utility;
#include maps\_utility;

CMD_CHANGEMAP_f( arg_list )
{
	self notify( "changemap_f" );
	self endon( "changemap_f" );
	channel = self scripts\csm\_com::com_get_cmd_feedback_channel();
	if ( array_validate( arg_list ) )
	{
		alias = arg_list[ 0 ];
		map = find_map_from_alias( alias );
		if ( map != "" )
		{
			display_name = get_display_name_for_map( map );
			message = level.custom_commands_restart_countdown + " second rotate to map " + display_name + " countdown started.";
			level scripts\csm\_com::com_printf( "g_log", "cmdinfo", "Changemap Usage: " + self.playername + " changed map to " + display_name, self );
			level scripts\csm\_com::com_printf( "say|con", "notitle", message, self );
			rotation_string = "map " + map;
			setDvar( "sv_maprotationCurrent", rotation_string );
			for ( i = level.custom_commands_restart_countdown; i > 0; i-- )
			{
				level scripts\csm\_com::com_printf( "con|say", "notitle", i + " seconds" );
				wait 1;
			}
			level notify( "end_commands" );
			wait 0.5;
			exitLevel( false );
			return;
		}
		level scripts\csm\_com::com_printf( channel, "cmderror", "alias " + alias + " is invalid.", self );
	}
	else 
	{
		level scripts\csm\_com::com_printf( channel, "cmderror", "Usage changemap <mapalias>", self );
	}
}

CMD_ROTATE_f( arg_list )
{
	self notify( "rotate_f" );
	self endon( "rotate_f" );
	message = level.custom_commands_restart_countdown + " second rotate countdown started";
	level scripts\csm\_com::com_printf( "g_log", "cmdinfo", "Rotate Usage: " + self.playername + " rotated the map.", self );
	level scripts\csm\_com::com_printf( "say|con", "notitle", message, self );
	for ( i = level.custom_commands_restart_countdown; i > 0; i-- )
	{
		wait 1;
		level scripts\csm\_com::com_printf( "con|say", "notitle", i + " seconds left" );
	}
	level notify( "end_commands" );
	wait 0.5;
	exitLevel( false );
}

CMD_RESTART_f( arg_list )
{
	self notify( "restart_f" );
	self endon( "restart_f" );
	message = level.custom_commands_restart_countdown + " second restart countdown started";
	level scripts\csm\_com::com_printf( "g_log", "cmdinfo", "Restart Usage: " + self.playername + " restarted the map.", self );
	level scripts\csm\_com::com_printf( "say|con", "notitle", message, self );
	for ( i = level.custom_commands_restart_countdown; i > 0; i-- )
	{
		wait 1;
		level scripts\csm\_com::com_printf( "con|say", "notitle", i + " seconds left" );
	}
	level notify( "end_commands" );
	wait 0.5;
	cmdexec( "map_restart" );
}