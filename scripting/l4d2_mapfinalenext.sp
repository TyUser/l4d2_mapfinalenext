// SPDX-License-Identifier: GPL-3.0-only
/*
 *
 * Copyright 2011 - 2026 steamcommunity.com/profiles/76561198025355822/
 * Automatic change of the map after the final win.
 * Only the l4d2 coop mode.
 *
 */
#pragma semicolon 1
#include <sourcemod>

/* l4d2_changelevel https://forums.alliedmods.net/showthread.php?p=2669850 */
#define HX_FIXES_LUX 1

#if HX_FIXES_LUX
    #include <l4d2_changelevel>
#endif

#pragma newdecls required

char             sg_l4d2Map[48];
char             sg_mode[24];
int              iPluginS;
int              ig_coop;
int              ig_rs;

public Plugin myinfo =
{
    name        = "[L4D2] mapfinalenext",
    author      = "MAKS",
    description = "L4D2 Coop Map Finale Next",
    version     = "1.7",
    url         = "forums.alliedmods.net/showthread.php?p=2436146"
};

public void OnPluginStart()
{
    ig_rs    = 0;
    iPluginS = 1;

    HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
    HookEvent("finale_win", Event_FinalWin, EventHookMode_PostNoCopy);
}

public void OnMapStart()
{
    ig_coop = 0;
    GetCurrentMap(sg_l4d2Map, sizeof(sg_l4d2Map) - 1);
    if (sg_l4d2Map[0] == 'C')    // fix
    {
        sg_l4d2Map[0] = 'c';
    }

    GetConVarString(FindConVar("mp_gamemode"), sg_mode, sizeof(sg_mode) - 1);

    if (!strcmp(sg_mode, "coop", true))
    {
        ig_coop = 1;
    }
    if (!strcmp(sg_mode, "realism", true))
    {
        ig_coop = 1;
    }

    ig_rs = 0;
    if (iPluginS)
    {
        ig_rs    = 3;
        iPluginS = 0;
    }
}

public Action HxTimerNextMap(Handle timer)
{
    ig_rs = 0;
    if (StrContains(sg_l4d2Map, "c1m", true) != -1)
    {
#if HX_FIXES_LUX
        L4D2_ChangeLevel("c6m1_riverbank");
#else
        ServerCommand("changelevel c6m1_riverbank");
#endif
        return Plugin_Stop;
    }
    if (StrContains(sg_l4d2Map, "c6m", true) != -1)
    {
#if HX_FIXES_LUX
        L4D2_ChangeLevel("c2m1_highway");
#else
        ServerCommand("changelevel c2m1_highway");
#endif
        return Plugin_Stop;
    }
    if (StrContains(sg_l4d2Map, "c2m", true) != -1)
    {
#if HX_FIXES_LUX
        L4D2_ChangeLevel("c3m1_plankcountry");
#else
        ServerCommand("changelevel c3m1_plankcountry");
#endif
        return Plugin_Stop;
    }
    if (StrContains(sg_l4d2Map, "c3m", true) != -1)
    {
#if HX_FIXES_LUX
        L4D2_ChangeLevel("c4m1_milltown_a");
#else
        ServerCommand("changelevel c4m1_milltown_a");
#endif
        return Plugin_Stop;
    }
    if (StrContains(sg_l4d2Map, "c4m", true) != -1)
    {
#if HX_FIXES_LUX
        L4D2_ChangeLevel("c5m1_waterfront");
#else
        ServerCommand("changelevel c5m1_waterfront");
#endif
        return Plugin_Stop;
    }
    if (StrContains(sg_l4d2Map, "c5m", true) != -1)
    {
#if HX_FIXES_LUX
        L4D2_ChangeLevel("c13m1_alpinecreek");
#else
        ServerCommand("changelevel c13m1_alpinecreek");
#endif
        return Plugin_Stop;
    }
    if (StrContains(sg_l4d2Map, "c13m", true) != -1)
    {
#if HX_FIXES_LUX
        L4D2_ChangeLevel("c8m1_apartment");
#else
        ServerCommand("changelevel c8m1_apartment");
#endif
        return Plugin_Stop;
    }
    if (StrContains(sg_l4d2Map, "c8m", true) != -1)
    {
#if HX_FIXES_LUX
        L4D2_ChangeLevel("c9m1_alleys");
#else
        ServerCommand("changelevel c9m1_alleys");
#endif
        return Plugin_Stop;
    }
    if (StrContains(sg_l4d2Map, "c9m", true) != -1)
    {
#if HX_FIXES_LUX
        L4D2_ChangeLevel("c10m1_caves");
#else
        ServerCommand("changelevel c10m1_caves");
#endif
        return Plugin_Stop;
    }
    if (StrContains(sg_l4d2Map, "c10m", true) != -1)
    {
#if HX_FIXES_LUX
        L4D2_ChangeLevel("c11m1_greenhouse");
#else
        ServerCommand("changelevel c11m1_greenhouse");
#endif
        return Plugin_Stop;
    }
    if (StrContains(sg_l4d2Map, "c11m", true) != -1)
    {
#if HX_FIXES_LUX
        L4D2_ChangeLevel("c12m1_hilltop");
#else
        ServerCommand("changelevel c12m1_hilltop");
#endif
        return Plugin_Stop;
    }
    if (StrContains(sg_l4d2Map, "c12m", true) != -1)
    {
#if HX_FIXES_LUX
        L4D2_ChangeLevel("c7m1_docks");
#else
        ServerCommand("changelevel c7m1_docks");
#endif
        return Plugin_Stop;
    }
    if (StrContains(sg_l4d2Map, "c7m", true) != -1)
    {
#if HX_FIXES_LUX
        L4D2_ChangeLevel("c14m1_junkyard");
#else
        ServerCommand("changelevel c14m1_junkyard");
#endif
        return Plugin_Stop;
    }

#if HX_FIXES_LUX
    L4D2_ChangeLevel("c1m1_hotel");
#else
    ServerCommand("changelevel c1m1_hotel");
#endif
    return Plugin_Stop;
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    if (ig_coop)
    {
        ig_rs += 1;
        if (ig_rs > 4)
        {
            int i = 1;
            while (i <= MaxClients)
            {
                if (IsClientInGame(i))
                {
                    PrintToChat(i, "\x05Change Level");
                }
                i += 1;
            }
            CreateTimer(8.0, HxTimerNextMap, _, TIMER_FLAG_NO_MAPCHANGE);
        }
    }
}

public void Event_FinalWin(Event event, const char[] name, bool dontBroadcast)
{
    if (ig_coop)
    {
        CreateTimer(7.0, HxTimerNextMap, _, TIMER_FLAG_NO_MAPCHANGE);
    }
}

public void OnMapEnd()
{
    ig_rs = 0;
}
