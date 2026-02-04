// SPDX-License-Identifier: GPL-3.0-only
/*
 *
 * Copyright 2011 - 2021 steamcommunity.com/profiles/76561198025355822/
 * Automatic change of the map after the final win.
 * Only the l4d2 coop mode.
 *
*/
#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#tryinclude <l4d2_changelevel>

/* l4d2_changelevel https://forums.alliedmods.net/showthread.php?p=2669850 */
#define PLUGIN_VERSION "1.7"
#define CVAR_FLAGS FCVAR_NOTIFY

#if defined _l4d2_changelevel_included
bool bLateload = false, bChangeLevelLib = false;
#endif

char sg_l4d2Map[48], sg_mode[24];
ConVar g_hCvarEnable, g_hCvarCountdown, g_hCvarRoundsLimit;
bool bHooked = false, bg_coop = false;
int iRoundsLimit = 0, ig_rs = 0;
float fCointdown = 0.0;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	if(GetEngineVersion() != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2 game.");
		return APLRes_SilentFailure;
	}
	#if defined _l4d2_changelevel_included
	bLateload = late;
	#endif

	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "[L4D2] mapfinalenext",
	author = "MAKS(Edit. by BloodyBlade)",
	description = "L4D2 Coop Map Finale Next",
	version = PLUGIN_VERSION,
	url = "forums.alliedmods.net/showthread.php?p=2436146"
};

public void OnPluginStart()
{
	CreateConVar("l4d2_mapfinalenext_version", PLUGIN_VERSION, "[L4D2] mapfinalenext plugin version", CVAR_FLAGS|FCVAR_DONTRECORD);
	g_hCvarEnable = CreateConVar("l4d2_mapfinalenext_enable", "1", "Enable/Disable the plugin (1 - Enable, 0 - Disable)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarCountdown = CreateConVar("l4d2_mapfinalenext_countdown", "8", "How many seconds before the map will be changed?", CVAR_FLAGS, true, 0.0, true, 60.0);
	g_hCvarRoundsLimit = CreateConVar("l4d2_mapfinalenext_rounds_limit", "5", "How many rounds lost before the map will be changed?", CVAR_FLAGS, true, 0.0, true, 10.0);
	AutoExecConfig(true, "l4d2_mapfinalenext");
	g_hCvarEnable.AddChangeHook(ConVarPluginOnChanged);
	g_hCvarCountdown.AddChangeHook(ConVarsChanged);
	g_hCvarRoundsLimit.AddChangeHook(ConVarsChanged);

	#if defined _l4d2_changelevel_included
	if(bLateload)
	{
		bChangeLevelLib = LibraryExists("l4d2_changelevel");
	}
	#endif
}

#if defined _l4d2_changelevel_included
public void OnLibraryAdded(const char[] name)
{
	if(strcmp(name, "l4d2_changelevel") == 0)
	{
		bChangeLevelLib = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if(strcmp(name, "l4d2_changelevel") == 0)
	{
		bChangeLevelLib = false;
	}
}
#endif

public void OnMapStart()
{
	ig_rs = 0;
	GetCurrentMap(sg_l4d2Map, sizeof(sg_l4d2Map)-1);
	if (sg_l4d2Map[0] == 'C') // fix
	{
		sg_l4d2Map[0] = 'c';
	}

	FindConVar("mp_gamemode").GetString(sg_mode, sizeof(sg_mode)-1);

	if (!strcmp(sg_mode, "coop", true) || !strcmp(sg_mode, "realism", true))
	{
		bg_coop = true;
	}
	else
	{
		bg_coop = false;
	}
}

public void OnConfigsExecuted()
{
	IsAllowed();
}

void ConVarPluginOnChanged(ConVar hVariable, const char[] strOldValue, const char[] strNewValue)
{
	IsAllowed();
}

void ConVarsChanged(ConVar hVariable, const char[] strOldValue, const char[] strNewValue)
{
	fCointdown = g_hCvarCountdown.FloatValue;
	iRoundsLimit = g_hCvarRoundsLimit.IntValue;
}

void IsAllowed()
{
	bool bPluginOn = g_hCvarEnable.BoolValue;
	if(!bHooked && bPluginOn)
	{
		bHooked = true;
		HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
		HookEvent("finale_win", Event_FinalWin, EventHookMode_PostNoCopy);
	}
	else if(bHooked && !bPluginOn)
	{
		bHooked = false;
		UnhookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
		UnhookEvent("finale_win", Event_FinalWin, EventHookMode_PostNoCopy);
	}
}

void Event_RoundStart(Event event, const char [] name, bool dontBroadcast)
{
	if (bg_coop)
	{
		ig_rs++;
		if (ig_rs == iRoundsLimit)
		{
			PrintToChatAll("\x05Change Level");
			CreateTimer(fCointdown, HxTimerNextMap, _, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

void Event_FinalWin(Event event, const char [] name, bool dontBroadcast)
{
	if (bg_coop)
	{
		CreateTimer(fCointdown, HxTimerNextMap, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

Action HxTimerNextMap(Handle timer)
{
	if(!bHooked) return Plugin_Stop;

	if (StrContains(sg_l4d2Map, "c1m", true) != -1)
	{
		#if defined _l4d2_changelevel_included
		if(bChangeLevelLib)
		{
			L4D2_ChangeLevel("c6m1_riverbank");
		}
		else
		{
			ServerCommand("changelevel c6m1_riverbank");
		}
		#else
		ServerCommand("changelevel c6m1_riverbank");
		#endif
		return Plugin_Stop;
	}
	else if (StrContains(sg_l4d2Map, "c6m", true) != -1)
	{
		#if defined _l4d2_changelevel_included
		if(bChangeLevelLib)
		{
			L4D2_ChangeLevel("c2m1_highway");
		}
		else
		{
			ServerCommand("changelevel c2m1_highway");
		}
		#else
		ServerCommand("changelevel c2m1_highway");
		#endif
		return Plugin_Stop;
	}
	else if (StrContains(sg_l4d2Map, "c2m", true) != -1)
	{
		#if defined _l4d2_changelevel_included
		if(bChangeLevelLib)
		{
			L4D2_ChangeLevel("c3m1_plankcountry");
		}
		else
		{
			ServerCommand("changelevel c3m1_plankcountry");
		}
		#else
		ServerCommand("changelevel c3m1_plankcountry");
		#endif
		return Plugin_Stop;
	}
	else if (StrContains(sg_l4d2Map, "c3m", true) != -1)
	{
		#if defined _l4d2_changelevel_included
		if(bChangeLevelLib)
		{
			L4D2_ChangeLevel("c4m1_milltown_a");
		}
		else
		{
			ServerCommand("changelevel c4m1_milltown_a");
		}
		#else
		ServerCommand("changelevel c4m1_milltown_a");
		#endif
		return Plugin_Stop;
	}
	else if (StrContains(sg_l4d2Map, "c4m", true) != -1)
	{
		#if defined _l4d2_changelevel_included
		if(bChangeLevelLib)
		{
			L4D2_ChangeLevel("c5m1_waterfront");
		}
		else
		{
			ServerCommand("changelevel c5m1_waterfront");
		}
		#else
		ServerCommand("changelevel c5m1_waterfront");
		#endif
		return Plugin_Stop;
	}
	else if (StrContains(sg_l4d2Map, "c5m", true) != -1)
	{
		#if defined _l4d2_changelevel_included
		if(bChangeLevelLib)
		{
			L4D2_ChangeLevel("c13m1_alpinecreek");
		}
		else
		{
			ServerCommand("changelevel c13m1_alpinecreek");
		}
		#else
		ServerCommand("changelevel c13m1_alpinecreek");
		#endif
		return Plugin_Stop;
	}
	else if (StrContains(sg_l4d2Map, "c13m", true) != -1)
	{
		#if defined _l4d2_changelevel_included
		if(bChangeLevelLib)
		{
			L4D2_ChangeLevel("c8m1_apartment");
		}
		else
		{
			ServerCommand("changelevel c8m1_apartment");
		}
		#else
		ServerCommand("changelevel c8m1_apartment");
		#endif
		return Plugin_Stop;
	}
	else if (StrContains(sg_l4d2Map, "c8m", true) != -1)
	{
		#if defined _l4d2_changelevel_included
		if(bChangeLevelLib)
		{
			L4D2_ChangeLevel("c9m1_alleys");
		}
		else
		{
			ServerCommand("changelevel c9m1_alleys");
		}
		#else
		ServerCommand("changelevel c9m1_alleys");
		#endif
		return Plugin_Stop;
	}
	else if (StrContains(sg_l4d2Map, "c9m", true) != -1)
	{
		#if defined _l4d2_changelevel_included
		if(bChangeLevelLib)
		{
			L4D2_ChangeLevel("c10m1_caves");
		}
		else
		{
			ServerCommand("changelevel c10m1_caves");
		}
		#else
		ServerCommand("changelevel c10m1_caves");
		#endif
		return Plugin_Stop;
	}
	else if (StrContains(sg_l4d2Map, "c10m", true) != -1)
	{
		#if defined _l4d2_changelevel_included
		if(bChangeLevelLib)
		{
			L4D2_ChangeLevel("c11m1_greenhouse");
		}
		else
		{
			ServerCommand("changelevel c11m1_greenhouse");
		}
		#else
		ServerCommand("changelevel c11m1_greenhouse");
		#endif
		return Plugin_Stop;
	}
	else if (StrContains(sg_l4d2Map, "c11m", true) != -1)
	{
		#if defined _l4d2_changelevel_included
		if(bChangeLevelLib)
		{
			L4D2_ChangeLevel("c12m1_hilltop");
		}
		else
		{
			ServerCommand("changelevel c12m1_hilltop");
		}
		#else
		ServerCommand("changelevel c12m1_hilltop");
		#endif
		return Plugin_Stop;
	}
	else if (StrContains(sg_l4d2Map, "c12m", true) != -1)
	{
		#if defined _l4d2_changelevel_included
		if(bChangeLevelLib)
		{
			L4D2_ChangeLevel("c7m1_docks");
		}
		else
		{
			ServerCommand("changelevel c7m1_docks");
		}
		#else
		ServerCommand("changelevel c7m1_docks");
		#endif
		return Plugin_Stop;
	}
	else if (StrContains(sg_l4d2Map, "c7m", true) != -1)
	{
		#if defined _l4d2_changelevel_included
		if(bChangeLevelLib)
		{
			L4D2_ChangeLevel("c14m1_junkyard");
		}
		else
		{
			ServerCommand("changelevel c14m1_junkyard");
		}
		#else
		ServerCommand("changelevel c14m1_junkyard");
		#endif
		return Plugin_Stop;
	}
	else
	{
		#if defined _l4d2_changelevel_included
		if(bChangeLevelLib)
		{
			L4D2_ChangeLevel("c1m1_hotel");
		}
		else
		{
			ServerCommand("changelevel c1m1_hotel");
		}
		#else
		ServerCommand("changelevel c1m1_hotel");
		#endif
		return Plugin_Stop;
	}
}
