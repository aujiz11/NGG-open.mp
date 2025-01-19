 
 //=======================[Official SA:MP/Streamer Callbacks]============================
public Float:SetPlayerToFacePos(playerid, Float:X, Float:Y)
{
	new
		Float:pX1,
		Float:pY1,
		Float:pZ1,
		Float:ang;

	if(!IsPlayerConnected(playerid)) return 0.0;

	GetPlayerPos(playerid, pX1, pY1, pZ1);

	if( Y > pY1 ) ang = (-acos((X - pX1) / floatsqroot((X - pX1)*(X - pX1) + (Y - pY1)*(Y - pY1))) - 90.0);
	else if( Y < pY1 && X < pX1 ) ang = (acos((X - pX1) / floatsqroot((X - pX1)*(X - pX1) + (Y - pY1)*(Y - pY1))) - 450.0);
	else if( Y < pY1 ) ang = (acos((X - pX1) / floatsqroot((X - pX1)*(X - pX1) + (Y - pY1)*(Y - pY1))) - 90.0);

	if(X > pX1) ang = (floatabs(floatabs(ang) + 180.0));
	else ang = (floatabs(ang) - 180.0);

	ang += 180.0;

	SetPlayerFacingAngle(playerid, ang);

 	return ang;
}
public AdminFly(playerid)
{
	if(!IsPlayerConnected(playerid))
		return flying[playerid] = false;

	if(flying[playerid])
	{
	    if(!IsPlayerInAnyVehicle(playerid))
	    {
			new
			    keys,
				ud,
				lr,
				Float:x[2],
				Float:y[2],
				Float:z;

			GetPlayerKeys(playerid, keys, ud, lr);
			GetPlayerVelocity(playerid, x[0], y[0], z);
			if(ud == KEY_UP)
			{
				GetPlayerCameraPos(playerid, x[0], y[0], z);
				GetPlayerCameraFrontVector(playerid, x[1], y[1], z);
    			ApplyAnimation(playerid, "PED", "FALL_skyDive", 4.1, false, false, false, false, 0);
				SetPlayerToFacePos(playerid, x[0] + x[1], y[0] + y[1]);
				SetPlayerVelocity(playerid, x[1], y[1], z);
			}
			else
			SetPlayerVelocity(playerid, 0.0, 0.0, 0.01);
		}
		SetTimerEx("AdminFly", 100, false, "d", playerid);
	}
	return 0;
}
public OnVehicleSpawn(vehicleid) {

	if(DynVeh[vehicleid] != -1)
	{
	    DynVeh_Spawn(DynVeh[vehicleid]);
	}
    TruckContents{vehicleid} = 0;
	Vehicle_ResetData(vehicleid);
	new
		v;


	foreach(new i: Player)
	{
		if((v = GetPlayerVehicle(i, vehicleid)) != -1) {
			DestroyVehicle(vehicleid);

			new
				iVehicleID = CreateVehicle(PlayerVehicleInfo[i][v][pvModelId], PlayerVehicleInfo[i][v][pvPosX], PlayerVehicleInfo[i][v][pvPosY], PlayerVehicleInfo[i][v][pvPosZ], PlayerVehicleInfo[i][v][pvPosAngle],PlayerVehicleInfo[i][v][pvColor1], PlayerVehicleInfo[i][v][pvColor2], -1);

            SetVehicleVirtualWorld(iVehicleID, PlayerVehicleInfo[i][v][pvVW]);
            LinkVehicleToInterior(iVehicleID, PlayerVehicleInfo[i][v][pvInt]);

			PlayerVehicleInfo[i][v][pvId] = iVehicleID;

			Vehicle_ResetData(iVehicleID);
			if(!isnull(PlayerVehicleInfo[i][v][pvPlate])) {
				SetVehicleNumberPlate(iVehicleID, PlayerVehicleInfo[i][v][pvPlate]);
			}
			if(PlayerVehicleInfo[i][v][pvLocked] == 1) LockPlayerVehicle(i, iVehicleID, PlayerVehicleInfo[i][v][pvLock]);
			ChangeVehiclePaintjob(iVehicleID, PlayerVehicleInfo[i][v][pvPaintJob]);
			ChangeVehicleColours(iVehicleID, PlayerVehicleInfo[i][v][pvColor1], PlayerVehicleInfo[i][v][pvColor2]);
			for(new m = 0; m < MAX_MODS; m++)
			{
				if (PlayerVehicleInfo[i][v][pvMods][m] >= 1000 && PlayerVehicleInfo[i][v][pvMods][m] <= 1193)
				{
					if (InvalidModCheck(PlayerVehicleInfo[i][v][pvModelId], PlayerVehicleInfo[i][v][pvMods][m]))
					{
						AddVehicleComponent(iVehicleID, PlayerVehicleInfo[i][v][pvMods][m]);
					}
					else
					{
						PlayerVehicleInfo[i][v][pvMods][m] = 0;
					}
				}
			}
			new string[128];
			format(string, sizeof(string), "Your %s has been sent to the location at which you last parked it.", GetVehicleName(iVehicleID));
			SendClientMessageEx(i, COLOR_GRAD1, string);
		}
		if(IsValidDynamicObject(CrateVehicleLoad[vehicleid][vForkObject]))
	    {
	    	DestroyDynamicObject(CrateVehicleLoad[vehicleid][vForkObject]);
		}
	}
    CrateVehicleLoad[vehicleid][vForkLoaded] = 0;
	for(new i = 0; i < sizeof(CrateInfo); i++)
    {
		if(CrateInfo[i][InVehicle] == vehicleid)
		{
	    	CrateInfo[i][crActive] = 0;
		    CrateInfo[i][InVehicle] = INVALID_VEHICLE_ID;
		    CrateInfo[i][crObject] = 0;
		    CrateInfo[i][crX] = 0;
		    CrateInfo[i][crY] = 0;
		    CrateInfo[i][crZ] = 0;
		    break;
		}
    }
}

public OnVehicleMod(playerid, vehicleid, componentid) 
{
	new string[128];
    for(new i = 0; i < sizeof(IsRim); i++)
	{
		if(IsRim[i] == componentid)
		{
		    if(!legalRims(playerid, componentid, vehicleid))
		    {
				if(HackingMods[playerid] < 3)
				{
					new szMessage[128];
					format(szMessage, sizeof(szMessage), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) may be hacking vehicle mods (%s (%d) %s to a %s (ID: %d))", GetPlayerNameEx(playerid), playerid, partName(componentid), componentid, partType(GetVehicleComponentType(componentid)), GetVehicleName(vehicleid), GetPlayerVehicleID(playerid));
					ABroadCast(COLOR_YELLOW, szMessage, 2);
					format(szMessage, sizeof(szMessage), "%s may be hacking vehicle mods (%s (%d) %s to a %s (ID: %d))", GetPlayerNameEx(playerid), partName(componentid), componentid, partType(GetVehicleComponentType(componentid)), GetVehicleName(vehicleid), GetPlayerVehicleID(playerid));
					Log("logs/hack.log", szMessage);
					HackingMods[playerid]++;
					return 0;
				}
				else if(HackingMods[playerid] == 3)
				{
					format(string, sizeof(string), "AdmCmd: %s has been banned, reason: Hacking Vehicle Modifications.", GetPlayerNameEx(playerid));
					ABroadCast(COLOR_LIGHTRED, string, 2);
					SendClientMessageEx(playerid, COLOR_LIGHTRED, string);
					PlayerInfo[playerid][pBanned] = 3;
					new playerip[32];
					GetPlayerIp(playerid, playerip, sizeof(playerip));
					format(string, sizeof(string), "AdmCmd: %s (IP:%s) da bi khoa tai khoan, ly do: Hacking Vehicle Modifications.", GetPlayerNameEx(playerid), playerip);
					PlayerInfo[playerid][pBanned] = 3;
					Log("logs/ban.log", string);
					new ip[32];
					GetPlayerIp(playerid, ip, sizeof(ip));
					SystemBan(playerid, "[System] (Hacking Vehicle Modifications)");
					MySQLBan(GetPlayerSQLId(playerid), playerip, "Hacking Vehicle Modifications", 1, "System");
					HackingMods[playerid] = 0;
					Kick(playerid);
					TotalAutoBan++;
					return 0;
				}
		    }
		}
	}
	if(!(1 <= GetPlayerInterior(playerid) <= 3) && !GetPVarType(playerid, "unMod")) {
		new
			szMessage[128];
		
		if(HackingMods[playerid] < 3)		
		{
			format(szMessage, sizeof(szMessage), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) may be hacking vehicle mods (%s (%d) %s to a %s (ID: %d))", GetPlayerNameEx(playerid), playerid, partName(componentid), componentid, partType(GetVehicleComponentType(componentid)), GetVehicleName(vehicleid), GetPlayerVehicleID(playerid));
			ABroadCast(COLOR_YELLOW, szMessage, 2);
			format(szMessage, sizeof(szMessage), "%s may be hacking vehicle mods (%s (%d) %s to a %s (ID: %d))", GetPlayerNameEx(playerid), partName(componentid), componentid, partType(GetVehicleComponentType(componentid)), GetVehicleName(vehicleid), GetPlayerVehicleID(playerid));
			Log("logs/hack.log", szMessage);
			HackingMods[playerid]++;
			return 0;
		}
		else if(HackingMods[playerid] == 3)
		{
			format(string, sizeof(string), "AdmCmd: %s has been banned, reason: Hacking Vehicle Modifications.", GetPlayerNameEx(playerid));
			ABroadCast(COLOR_LIGHTRED, string, 2);
			SendClientMessageEx(playerid, COLOR_LIGHTRED, string);
			PlayerInfo[playerid][pBanned] = 3;
			new playerip[32];
			GetPlayerIp(playerid, playerip, sizeof(playerip));
			format(string, sizeof(string), "AdmCmd: %s (IP:%s) da bi khoa tai khoan, reason: Hacking Vehicle Modifications.", GetPlayerNameEx(playerid), playerip);
			PlayerInfo[playerid][pBanned] = 3;
			Log("logs/ban.log", string);
			new ip[32];
			GetPlayerIp(playerid, ip, sizeof(ip));
			SystemBan(playerid, "[System] (Hacking Vehicle Modifications)");
			MySQLBan(GetPlayerSQLId(playerid), playerip, "Hacking Vehicle Modifications", 1, "System");
			HackingMods[playerid] = 0;
			Kick(playerid);
			TotalAutoBan++;
			return 0;
		}
	}
	if(GetPVarType(playerid, "unMod")) DeletePVar(playerid, "unMod");
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
    if(objectid != gFerrisWheel) return 0;

    SetTimer("RotateWheel",3*1000,false);
    return 1;
}

public OnDynamicObjectMoved(objectid)
{
	if(objectid == CarrierS[5])
	{
	    canmove = 0;
	}

	new Float:x, Float:y, Float:z;
	for(new i; i < sizeof(Obj_FloorDoors); i ++)
	{
		if(objectid == Obj_FloorDoors[i][0])
		{
		    GetDynamicObjectPos(Obj_FloorDoors[i][0], x, y, z);

		    if(x < X_DOOR_L_OPENED - 0.5)   // Some floor doors have shut, move the elevator to next floor in queue:
		    {
				Elevator_MoveToFloor(ElevatorQueue[0]);
				RemoveFirstQueueFloor();
			}
		}
	}

	if(objectid == Obj_Elevator)   // The elevator reached the specified floor.
	{
	    KillTimer(ElevatorBoostTimer);  // Kills the timer, in case the elevator reached the floor before boost.

	    FloorRequestedBy[ElevatorFloor] = INVALID_PLAYER_ID;

	    Elevator_OpenDoors();
	    Floor_OpenDoors(ElevatorFloor);

	    GetDynamicObjectPos(Obj_Elevator, x, y, z);
	    Label_Elevator	= CreateDynamic3DTextLabel("Press '~k~~GROUP_CONTROL_BWD~' de su dung thang may", COLOR_YELLOW, 1784.9822, -1302.0426, z - 0.9, 4.0);

	    ElevatorState 	= ELEVATOR_STATE_WAITING;
	    SetTimer("Elevator_TurnToIdle", ELEVATOR_WAIT_TIME, false);
	}

	if (objectid == BikeParkourObjects[0]) // container
	{
		switch (BikeParkourObjectStage[0])
		{
			case 0:
			{
				MoveDynamicObject(BikeParkourObjects[0], 2847.5302734, -2231.2675781, 99.0883789, 0.5, 0.0, 0.0, 179.7253418); // to end
				++BikeParkourObjectStage[0];
			}

			case 1:
			{
				MoveDynamicObject(BikeParkourObjects[0], 2848.1015625, -2238.1552734, 99.0883789, 0.5, 0.0000000, 0.0000000, 90.0000000); // to middle
				BikeParkourObjectStage[0] = 2;
			}

			case 2:
			{
				MoveDynamicObject(BikeParkourObjects[0], 2848.1015625, -2243.1552734, 99.0883789, 0.5, 0.0, 0.0, 90.0000000); // to beginning
				BikeParkourObjectStage[0] = 3;
			}

			case 3:
			{
				MoveDynamicObject(BikeParkourObjects[0], 2848.1015625, -2238.1552734, 99.0883789, 0.5, 0.0, 0.0, 90.0000000); // to middle
				BikeParkourObjectStage[0] = 0;
			}
		}
	}
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
	if(areaid == NGGShop)
	{
		SetPlayerArmedWeapon(playerid, 0);
	}
	foreach(new i: Player)
	{
		if(GetPVarType(i, "pBoomBoxArea"))
		{
			if(areaid == GetPVarInt(i, "pBoomBoxArea"))
			{
				new station[256];
				GetPVarString(i, "pBoomBoxStation", station, sizeof(station));
				if(!isnull(station))
				{
					PlayAudioStreamForPlayerEx(playerid, station, GetPVarFloat(i, "pBoomBoxX"), GetPVarFloat(i, "pBoomBoxY"), GetPVarFloat(i, "pBoomBoxZ"), 30.0, true);
				}
				return 1;
			}
		}
	}
	if(areaid == audiourlid)
	{
	    PlayAudioStreamForPlayerEx(playerid, audiourlurl, audiourlparams[0], audiourlparams[1], audiourlparams[2], audiourlparams[3], true);
	}
	return 1;
}

public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	foreach(new i: Player)
	{
		if(GetPVarType(i, "pBoomBoxArea"))
		{
			if(areaid == GetPVarInt(i, "pBoomBoxArea"))
			{
				StopAudioStreamForPlayerEx(playerid);
				return 1;
			}
		}
	}
	if(areaid == audiourlid)
	{
		StopAudioStreamForPlayerEx(playerid);
	}
	if(areaid == NGGShop && GetPVarInt(playerid, "ShopTP") == 1)
	{
		if(GetPVarType(playerid, "PlayerCuffed") || GetPVarType(playerid, "Injured") || GetPVarType(playerid, "IsFrozen") || PlayerInfo[playerid][pHospital] || PlayerInfo[playerid][pJailTime] > 0)
			return DeletePVar(playerid, "ShopTP");
		Player_StreamPrep(playerid, GetPVarFloat(playerid, "tmpX"), GetPVarFloat(playerid, "tmpY"), GetPVarFloat(playerid, "tmpZ"), FREEZE_TIME);
		SetPlayerInterior(playerid, GetPVarInt(playerid, "tmpInt"));
		SetPlayerVirtualWorld(playerid, GetPVarInt(playerid, "tmpVW"));
		DeletePVar(playerid, "ShopTP");
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Cam on ban da nghe tham cua hang cua chung toi, hay  som quay tro lai cua hang cua chung toi nhe!");
	}
	return 1;
}

public OnPlayerUpdate(playerid)
{
	// Do not put heavy cpu checks in here. Use the 1 second timer.
	if(playerTabbed[playerid] >= 1)
	{
		playerTabbed[playerid] = 0;
	}
	playerSeconds[playerid] = gettime();

	if(PlayerInfo[playerid][pNation] == -1 && TutStep[playerid] == 24 && RegistrationStep[playerid] == 3)
	{
	    NationSel_HandleNationSelection(playerid);
	    return 1;
	}

	new pCurWeap = GetPlayerWeapon(playerid);
    if(pCurWeap != pCurrentWeapon{playerid})
    {
        OnPlayerChangeWeapon(playerid, pCurWeap);
        pCurrentWeapon{playerid} = pCurWeap;
    }

    new drunknew = GetPlayerDrunkLevel(playerid);
    if (drunknew < 100) { // go back up, keep cycling.
        SetPlayerDrunkLevel(playerid, 2000);
    } else {

        if (pDrunkLevelLast[playerid] != drunknew) {

            new wfps = pDrunkLevelLast[playerid] - drunknew;

            if ((wfps > 0) && (wfps < 200))
                pFPS[playerid] = wfps;

            pDrunkLevelLast[playerid] = drunknew;
        }

    }
    if(acstruct[playerid][checkmaptp] == 1 && PlayerInfo[playerid][pAdmin] < 2) //blah
	{
	    new Float:dis = GetPlayerDistanceFromPoint(playerid, acstruct[playerid][maptp][0], acstruct[playerid][maptp][1], acstruct[playerid][maptp][2]);
	    if(dis < 5.0)
	    {
			new Float:disd = GetPlayerDistanceFromPoint(playerid, acstruct[playerid][LastOnFootPosition][0], acstruct[playerid][LastOnFootPosition][1], acstruct[playerid][LastOnFootPosition][2]);
			if(disd > 25.0)
			{
		        new srelay[256], Float:X, Float:Y, Float:Z;
		        GetPlayerPos(playerid, X, Y, Z);
				format(srelay, sizeof(srelay), "[mapteleport] %s %d (%0.2f, %0.2f, %0.2f -> %0.2f, %0.2f, %0.2f [%0.2f, %0.2f, %0.2f]) (%f, %f) (%d) (%d)", GetPlayerNameExt(playerid), playerid, \
				acstruct[playerid][LastOnFootPosition][0], acstruct[playerid][LastOnFootPosition][1], acstruct[playerid][LastOnFootPosition][2], \
				X, Y, Z, acstruct[playerid][maptp][0], acstruct[playerid][maptp][1], acstruct[playerid][maptp][2], \
				disd, dis, GetPlayerState(playerid), (GetTickCount()-acstruct[playerid][maptplastclick]));
				Log("logs/hack.log", srelay);

	            format( srelay, sizeof( srelay ), "{AA3333}AdmWarning{FFFF00}: %s has been banned, reason: TP Hacking", GetPlayerNameExt(playerid));
				ABroadCast( COLOR_YELLOW, srelay, 2 );
				SendClientMessage(playerid, COLOR_LIGHTRED, srelay );
				PlayerInfo[playerid][pBanned] = 3;
				new playerip[32];
				GetPlayerIp(playerid, playerip, sizeof(playerip));
				format( srelay, sizeof( srelay ), "%s (IP:%s) da bi khoa tai khoan, reason: TP Hacking", GetPlayerNameExt(playerid), playerip);
				PlayerInfo[playerid][pBanned] = 3;
				Log("logs/ban.log", srelay);
				SystemBan(playerid, "[System] (Teleport Hacking)");
				MySQLBan(GetPlayerSQLId(playerid),playerip,"TP Hacking", 1,"System");
				SetTimerEx("KickEx", 1000, false, "i", playerid);
				TotalAutoBan++;
			}
		}
	    acstruct[playerid][checkmaptp] = 0;
	}
	GetPlayerPos(playerid, acstruct[playerid][LastOnFootPosition][0], acstruct[playerid][LastOnFootPosition][1], acstruct[playerid][LastOnFootPosition][2]);

    if(control[playerid] == 1)
	{
	   	new Keys,ud,lr;
	   	GetPlayerKeys(playerid,Keys,ud,lr);

		if(ud > 0)
		{
			if(canmove == 1) return 1;
	    	else canmove = 1;

			new distance = controldistance[playerid];
		    new speed = controlspeed[playerid];

		    new Float:XA[17], Float:YA[17], Float:ZA[17];
		    new Float:XB[14], Float:YB[14], Float:ZB[14];
		    new Float:XC[3], Float:YC[3], Float:ZC[3];

			for(new x;x<sizeof(Carrier);x++)
			{
			    GetDynamicObjectPos(Carrier[x], XA[x], YA[x], ZA[x]);
			}
			for(new x;x<sizeof(CarrierS);x++)
			{
			    GetDynamicObjectPos(CarrierS[x], XB[x], YB[x], ZB[x]);
			}

			GetDynamicObjectPos(sidelift, XC[0], YC[0], ZC[0]);
			GetDynamicObjectPos(backhatch, XC[1], YC[1], ZC[1]);
			GetDynamicObjectPos(backlift, XC[2], YC[2], ZC[2]);

			for(new x;x<sizeof(Carrier);x++)
			{
   				MoveDynamicObject(Carrier[x], XA[x]-distance, YA[x], ZA[x], speed);
			}
			for(new x;x<sizeof(CarrierS);x++)
			{
				MoveDynamicObject(CarrierS[x], XB[x]-distance, YB[x], ZB[x], speed);
			}

			MoveDynamicObject(sidelift, XC[0]-distance, YC[0], ZC[0], speed);
			MoveDynamicObject(backhatch, XC[1]-distance, YC[1], ZC[1], speed);
			MoveDynamicObject(backlift, XC[2]-distance, YC[2], ZC[2], speed);
		}
	    else if(ud < 0)
		{
		    if(canmove == 1) return 1;
		    else canmove = 1;

			new distance = controldistance[playerid];
		    new speed = controlspeed[playerid];

		    new Float:XA[17], Float:YA[17], Float:ZA[17];
		    new Float:XB[14], Float:YB[14], Float:ZB[14];
	    	new Float:XC[3], Float:YC[3], Float:ZC[3];

			for(new x;x<sizeof(Carrier);x++)
			{
			    GetDynamicObjectPos(Carrier[x], XA[x], YA[x], ZA[x]);
			}
			for(new x;x<sizeof(CarrierS);x++)
			{
			    GetDynamicObjectPos(CarrierS[x], XB[x], YB[x], ZB[x]);
			}

			GetDynamicObjectPos(sidelift, XC[0], YC[0], ZC[0]);
			GetDynamicObjectPos(backhatch, XC[1], YC[1], ZC[1]);
			GetDynamicObjectPos(backlift, XC[2], YC[2], ZC[2]);

			for(new x;x<sizeof(Carrier);x++)
			{
   				MoveDynamicObject(Carrier[x], XA[x]+distance, YA[x], ZA[x], speed);
			}
			for(new x;x<sizeof(CarrierS);x++)
			{
				MoveDynamicObject(CarrierS[x], XB[x]+distance, YB[x], ZB[x], speed);
			}

			MoveDynamicObject(sidelift, XC[0]+distance, YC[0], ZC[0], speed);
			MoveDynamicObject(backhatch, XC[1]+distance, YC[1], ZC[1], speed);
			MoveDynamicObject(backlift, XC[2]+distance, YC[2], ZC[2], speed);
		}

		if(lr > 0)
		{
  			if(canmove == 1) return 1;
		   	else canmove = 1;

		    new distance = controldistance[playerid];
		    new speed = controlspeed[playerid];

	   	 	new Float:XA[17], Float:YA[17], Float:ZA[17];
		    new Float:XB[14], Float:YB[14], Float:ZB[14];
		    new Float:XC[3], Float:YC[3], Float:ZC[3];

			for(new x;x<sizeof(Carrier);x++)
			{
			    GetDynamicObjectPos(Carrier[x], XA[x], YA[x], ZA[x]);
			}
			for(new x;x<sizeof(CarrierS);x++)
			{
			    GetDynamicObjectPos(CarrierS[x], XB[x], YB[x], ZB[x]);
			}

			GetDynamicObjectPos(sidelift, XC[0], YC[0], ZC[0]);
			GetDynamicObjectPos(backhatch, XC[1], YC[1], ZC[1]);
			GetDynamicObjectPos(backlift, XC[2], YC[2], ZC[2]);

			for(new x;x<sizeof(Carrier);x++)
			{
   				MoveDynamicObject(Carrier[x], XA[x], YA[x]-distance, ZA[x], speed);
			}
			for(new x;x<sizeof(CarrierS);x++)
			{
				MoveDynamicObject(CarrierS[x], XB[x], YB[x]-distance, ZB[x], speed);
			}

			MoveDynamicObject(sidelift, XC[0], YC[0]-distance, ZC[0], speed);
			MoveDynamicObject(backhatch, XC[1], YC[1]-distance, ZC[1], speed);
			MoveDynamicObject(backlift, XC[2], YC[2]-distance, ZC[2], speed);
		}
  		else if(lr < 0)
		{
  			if(canmove == 1) return 1;
  			else canmove = 1;

			new distance = controldistance[playerid];
		   	new speed = controlspeed[playerid];

		   	new Float:XA[17], Float:YA[17], Float:ZA[17];
		    new Float:XB[14], Float:YB[14], Float:ZB[14];
			new Float:XC[3], Float:YC[3], Float:ZC[3];

			for(new x;x<sizeof(Carrier);x++)
			{
			    GetDynamicObjectPos(Carrier[x], XA[x], YA[x], ZA[x]);
			}
			for(new x;x<sizeof(CarrierS);x++)
			{
			    GetDynamicObjectPos(CarrierS[x], XB[x], YB[x], ZB[x]);
			}

			GetDynamicObjectPos(sidelift, XC[0], YC[0], ZC[0]);
			GetDynamicObjectPos(backhatch, XC[1], YC[1], ZC[1]);
			GetDynamicObjectPos(backlift, XC[2], YC[2], ZC[2]);

			for(new x;x<sizeof(Carrier);x++)
			{
   				MoveDynamicObject(Carrier[x], XA[x], YA[x]+distance, ZA[x], speed);
			}
			for(new x;x<sizeof(CarrierS);x++)
			{
				MoveDynamicObject(CarrierS[x], XB[x], YB[x]+distance, ZB[x], speed);
			}

			MoveDynamicObject(sidelift, XC[0], YC[0]+distance, ZC[0], speed);
			MoveDynamicObject(backhatch, XC[1], YC[1]+distance, ZC[1], speed);
			MoveDynamicObject(backlift, XC[2], YC[2]+distance, ZC[2], speed);
		}
	}
	return 1;
}

public OnPlayerEditObject(playerid, playerobject, objectid, EDIT_RESPONSE:response, 
		Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
	return 1;
}

public OnPlayerEditAttachedObject( playerid, response, index, modelid, boneid,
                                   Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ,
                                   Float:fRotX, Float:fRotY, Float:fRotZ,
                                   Float:fScaleX, Float:fScaleY, Float:fScaleZ )
{
	if(response == EDIT_RESPONSE_FINAL)
	{
	    if(fOffsetX > 1.4)
		{
			fOffsetX = 1.4;
			SendClientMessage(playerid, COLOR_WHITE, "Maximum X Offset exeeded, damped to maximum");
		}
	    if(fOffsetY > 1.4) {
			fOffsetY = 1.4;
			SendClientMessage(playerid, COLOR_WHITE, "Maximum Y Offset exeeded, damped to maximum");
		}
	    if(fOffsetZ > 1.4) {
			fOffsetZ = 1.4;
			SendClientMessage(playerid, COLOR_WHITE, "Maximum Z Offset exeeded, damped to maximum");
		}
	    if(fOffsetX < -1.4) {
			fOffsetX = -1.4;
			SendClientMessage(playerid, COLOR_WHITE, "Maximum X Offset exeeded, damped to maximum");
		}
	    if(fOffsetY < -1.4) {
			fOffsetY = -1.4;
			SendClientMessage(playerid, COLOR_WHITE, "Maximum Y Offset exeeded, damped to maximum");
		}
	    if(fOffsetZ < -1.4) {
			fOffsetZ = -1.4;
			SendClientMessage(playerid, COLOR_WHITE, "Maximum Z Offset exeeded, damped to maximum");
		}
	    if(fScaleX > 1.5) {
			fScaleX = 1.5;
			SendClientMessage(playerid, COLOR_WHITE, "Maximum X Scale exeeded, damped to maximum");
		}
	    if(fScaleY > 1.5) {
			fScaleY = 1.5;
			SendClientMessage(playerid, COLOR_WHITE, "Maximum Y Scale exeeded, damped to maximum");
		}
		if(fScaleZ > 1.5) {
			fScaleZ = 1.5;
			SendClientMessage(playerid, COLOR_WHITE, "Maximum Z Scale exeeded, damped to maximum");
		}

	    new slotid = GetPVarInt(playerid, "ToySlot");
		PlayerToyInfo[playerid][slotid][ptPosX] = fOffsetX;
		PlayerToyInfo[playerid][slotid][ptPosY] = fOffsetY;
		PlayerToyInfo[playerid][slotid][ptPosZ] = fOffsetZ;
		PlayerToyInfo[playerid][slotid][ptRotX] = fRotX;
		PlayerToyInfo[playerid][slotid][ptRotY] = fRotY;
		PlayerToyInfo[playerid][slotid][ptRotZ] = fRotZ;
		PlayerToyInfo[playerid][slotid][ptScaleX] = fScaleX;
		PlayerToyInfo[playerid][slotid][ptScaleY] = fScaleY;
		PlayerToyInfo[playerid][slotid][ptScaleZ] = fScaleZ;

	    g_mysql_SaveToys(playerid,slotid);
		ShowEditMenu(playerid);
	}
	else
	{
	    ShowEditMenu(playerid);
		SendClientMessage(playerid, COLOR_WHITE, "Ban da dung viec chinh sua toys.");
	}
	return 1;
}

public OnPlayerInteriorChange(playerid,newinteriorid,oldinteriorid)
{
	if(gPlayerLogged{playerid} && GetPVarInt(playerid, "EventToken") == 0)
	{
		PlayerInfo[playerid][pInt] = newinteriorid;
	}
	foreach(new i: Player) {
		if(Spectating[i] > 0 && Spectate[i] == playerid) {
			SetTimerEx("SpecUpdate", 1500, false, "i", i);
		}
	}
}

public OnPlayerPressButton(playerid, buttonid)
{
	if(buttonid == lockdownbutton)
	{
		new iGroupID = PlayerInfo[playerid][pMember];
	    if(PlayerInfo[playerid][pRank] >= arrGroupData[iGroupID][g_iCrateIsland])
	    {
			new string[128];
			if(IslandGateStatus == 0)
			{
			    MoveDynamicObject(IslandGate, -1083.90002441,4289.70019531,7.59999990, 0.3);
			    foreach(new i: Player)
			    {
			        if(IsPlayerInRangeOfPoint(i, 500, -1083.90002441,4289.70019531,7.59999990))
			        {
			            SendClientMessageEx(i, COLOR_YELLOW, " NHUNG KE XAM NHAP TRAI PHEP! LOCKDOWN SEQUENCE INITIATED!!");
			        }
			    }
				format(string, sizeof(string), "** %s has initiated a lockdown sequence at the San Andreas Military Island. **", GetPlayerNameEx(playerid));
				SendFamilyMessage(iGroupID, DEPTRADIO, string);
				IslandGateStatus = gettime();
				IslandThreatElimTimer = SetTimer("IslandThreatElim", 1800000, false);
			}
			else
			{
			    KillTimer(IslandThreatElimTimer);
		    	IslandThreatElim();
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GRAD2, " Chi co SAAS moi co tham quyen lam viec nay! ");
		}
		return 1;
	}
	if(buttonid == FBILobbyLeftBTN[0] || buttonid == FBILobbyLeftBTN[1])
	{
	    if(IsACop(playerid))
	    {
	        MoveDynamicObject(FBILobbyLeft,293.93002319,-1498.43457031,-46.13965225,4);
			SetTimer("CloseFBILobbyLeft", 2500, false);
	    }
	    else
	    {
	        SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
	}
	if(buttonid == FBILobbyRightBTN[0] || buttonid == FBILobbyRightBTN[1])
	{
	    if(IsACop(playerid))
	    {
	        MoveDynamicObject(FBILobbyRight,303.84756470,-1521.62988281,-46.13965225,4);
			SetTimer("CloseFBILobbyRight", 2500, false);
	    }
	    else
	    {
	        SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
	}
	if(buttonid == FBIPrivateBTN[0] || buttonid == FBIPrivateBTN[1])
	{
	    if(IsACop(playerid) && PlayerInfo[playerid][pRank] >= 5)
	    {
	        MoveDynamicObject(FBIPrivate[0],299.29986572,-1491.75842285,-28.73300552,4);
	        MoveDynamicObject(FBIPrivate[1],299.33737183,-1496.86145020,-28.73300552,4);
			SetTimer("CloseFBIPrivate", 2500, false);
	    }
	    else
	    {
	        SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
	}
	if(buttonid == SANewsStudio)
	{
	    if(IsAReporter(playerid) || IsACop(playerid))
	    {
	        MoveDynamicObject(SANewsStudioA,625.60937500,-9.80000019,1106.96081543,4);
	 		MoveDynamicObject(SANewsStudioB,625.64941406,-14.77000046,1106.96081543,4);
			SetTimer("CloseSANewsStudio", 2500, false);
	    }
	    else
	    {
	        SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
	}
	if(buttonid == SANewsPrivate)
	{
	    if(IsAReporter(playerid) || IsACop(playerid))
	    {
	        MoveDynamicObject(SANewsPrivateA,625.60937500,0.55000001,1106.96081543,4);
	 		MoveDynamicObject(SANewsPrivateB,625.65002441,-4.54999995,1106.96081543,4);
			SetTimer("CloseSANewsPrivate", 2500, false);
	    }
	    else
	    {
	        SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
	}
	if(buttonid == SANewsPrivateOPP)
	{
	    if(IsAReporter(playerid) || IsACop(playerid))
	    {
	        MoveDynamicObject(SANewsPrivateA,625.60937500,0.55000001,1106.96081543,4);
	 		MoveDynamicObject(SANewsPrivateB,625.65002441,-4.54999995,1106.96081543,4);
			SetTimer("CloseSANewsPrivate", 2500, false);
	    }
	    else
	    {
	        SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
	}
	if(buttonid == SANewsOffice)
	{
	    if((IsAReporter(playerid) && PlayerInfo[playerid][pRank] >=5) || IsACop(playerid))
	    {
	        MoveDynamicObject(SANewsOfficeA,613.66998291,17.82812500,1106.98425293,4);
	 		MoveDynamicObject(SANewsOfficeB,618.69000244,17.86899948,1106.98425293,4);
			SetTimer("CloseSANewsOffice", 2500, false);
	    }
	    else
	    {
	        SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
	}
	if(buttonid == sasdbtn1)
	{
	    if(IsACop(playerid) && PlayerInfo[playerid][pRank] >= 5)
	    {
	        MoveDynamicObject(sasd1A,2510.65332031,-1697.00976562,561.79223633,4);
	 		MoveDynamicObject(sasd1B,2515.67211914,-1696.97485352,561.79223633,4);
			SetTimer("CloseSASD1", 2500, false);
	    }
	    else
	    {
	        SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
	}
	if(buttonid == sasdbtn2)
	{
	    if(IsACop(playerid) && PlayerInfo[playerid][pRank] >= 3)
	    {
	        MoveDynamicObject(sasd5A,2523.86059570,-1660.07177734,561.80206299,4);
	 		MoveDynamicObject(sasd5B,2518.84228516,-1660.10888672,561.80004883,4);
	 		//2522.86059570,-1660.07177734,561.80206299
			//2519.84228516,-1660.10888672,561.80004883
			SetTimer("CloseSASD5", 2500, false);
	    }
	    else
	    {
	        SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
	}
	if(buttonid == sasdbtn3)
	{
	    if(IsACop(playerid) && PlayerInfo[playerid][pRank] >= 5)
	    {
	        MoveDynamicObject(sasd3A,2521.15600586,-1697.01550293,561.79223633,4);
	 		MoveDynamicObject(sasd3B,2526.15893555,-1696.98010254,561.79223633,4);
			SetTimer("CloseSASD3", 2500, false);
	    }
	    else
	    {
	        SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
	}
	if(buttonid == sasdbtn4)
	{
		if(IsACop(playerid) && PlayerInfo[playerid][pRank] >= 5)
	    {
            MoveDynamicObject(sasd2A,2515.87548828,-1697.01525879,561.79223633,4);
	 		MoveDynamicObject(sasd2B,2520.89257812,-1696.97509766,561.79223633,4);
			SetTimer("CloseSASD2", 2500, false);
	    }
	    else
	    {
	        SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
	}
	if(buttonid == sasdbtn5)
	{
		if(IsACop(playerid) && PlayerInfo[playerid][pRank] >= 3)
	    {
	        MoveDynamicObject(sasd4A,2510.84130859,-1660.08081055,561.79528809,4);
	 		MoveDynamicObject(sasd4B,2515.81982422,-1660.04650879,561.80004883,4);
			SetTimer("CloseSASD4", 2500, false);
	    }
	    else
	    {
	        SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
	}
	if(buttonid == nooseenter[0] || buttonid == nooseenter[1])
	{
		if(IsACop(playerid))
	    {
	        MoveDynamicObject(entrancedoor,-766.27539062,2536.58691406,10023,2);
			SetTimer("CloseEntranceDoor", 5000, false);
	    }
	    else
	    {
	        SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
	}
	if(buttonid == radarroom[0] || buttonid == radarroom[1])
	{
		if(IsACop(playerid))
	    {
			MoveDynamicObject(blastdoor[1],-746.02636719,2535.19433594,10025,2);
			SetTimer("CloseBlastDoor2", 5000, false);
	    }
	    else
	    {
	        SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
	}
	if(buttonid == intergate[0] || buttonid == intergate[1])
	{
		if(IsACop(playerid))
	    {
			MoveDynamicObject(blastdoor[2],-765.26171875,2552.31347656,10025,2);
			SetTimer("CloseBlastDoor3", 5000, false);
	    }
	    else
	    {
	        SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
	}
	if(buttonid == intergate[2])
	{
		if(IsACop(playerid))
	    {
			MoveDynamicObject(cage,-773.52050781,2545.62109375,10025,2);
			SetTimer("CloseCage", 5000, false);
	    }
	    else
	    {
	        SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
	}
	if(buttonid == ncontrolroom[0] || buttonid == ncontrolroom[1])
	{
		if(IsACop(playerid) && PlayerInfo[playerid][pRank] >= 5)
	    {
	        if(ncontrolroomopened == 1)
	        {
				MoveDynamicObject(ncontrolroomobjects[0],-760.61718750,2544.21679688,10024.92480469,2);
				MoveDynamicObject(ncontrolroomobjects[1],-759.52246094,2560.88574219,10024.79785156,2);
				MoveDynamicObject(ncontrolroomobjects[2],-755.53906250,2538.61035156,10025.02636719,2);
				ncontrolroomopened = 0;
			}
			else if(ncontrolroomopened == 0)
			{
				MoveDynamicObject(ncontrolroomobjects[0],-760.61718750,2544.21679688,10020.92480469,2);
				MoveDynamicObject(ncontrolroomobjects[1],-759.52246094,2560.88574219,10020.79785156,2);
				MoveDynamicObject(ncontrolroomobjects[2],-755.53906250,2538.61035156,10021.02636719,2);
				ncontrolroomopened = 1;
			}
	    }
	    else
	    {
	        SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
	}
	if(buttonid == bottomroom[0] || buttonid == bottomroom[1])
	{
		if(IsACop(playerid))
	    {
			MoveDynamicObject(blastdoor[0],-764.11816406,2568.81445312,10025.05566406,2);
			SetTimer("CloseBlastDoor", 5000, false);
	    }
	    else
	    {
	        SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
	}
	if(buttonid == westout)
	{
		if(!IsACop(playerid))
		{
			SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
		MoveDynamicObject(westlobby1,239.71582031,115.09179688,1002.21502686,4);
		MoveDynamicObject(westlobby2,239.67968750,120.09960938,1002.21502686,4);
		SetTimer("CloseWestLobby", 2500, false);
	}
	if(buttonid == eastout)
	{
		if(!IsACop(playerid))
		{
			SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
 		MoveDynamicObject(eastlobby1,253.14941406,111.59960938,1002.21502686,4);
 		MoveDynamicObject(eastlobby2,253.18457031,106.59960938,1002.21502686,4);
		SetTimer("CloseEastLobby", 2500, false);
	}
	if(buttonid == lockerin || buttonid == lockerout)
	{
		if(!IsACop(playerid))
		{
			SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
		MoveDynamicObject(locker1,268.29980469,112.56640625,1003.61718750,4);
		MoveDynamicObject(locker2,263.29980469,112.52929688,1003.61718750,4);
		SetTimer("CloseLocker", 2500, false);
	}
	if(buttonid == cctvin || buttonid == cctvout)
	{
		if(!IsACop(playerid))
		{
			SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
		MoveDynamicObject(cctv1,263.44921875,115.79980469,1003.61718750,4);
		MoveDynamicObject(cctv2,268.46875000,115.83691406,1003.61718750,4);
		SetTimer("CloseCCTV", 2500, false);
	}
	if(buttonid == chiefin || buttonid == chiefout)
	{
		if(!IsACop(playerid) || PlayerInfo[playerid][pRank] < 6)
		{
			SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
		MoveDynamicObject(chief1,228.0,119.50000000,1009.21875000,4);
		MoveDynamicObject(chief2,230.0,119.53515625,1009.21875000,4);
	    SetTimer("CloseChief", 2500, false);
	}
	if(buttonid == elevator)
	{
		if(!IsACop(playerid))
		{
			SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
		//else ShowPlayerDialog( playerid, ELEVATOR3, DIALOG_STYLE_LIST, "Elevator", "Rooftop\nGarage", "Lua chont", "Huy bo");
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Thang may nay khong su dung duoc.");
	}
	if(buttonid == garagekey)
	{
		if(!IsACop(playerid))
		{
			SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
		//else ShowPlayerDialog( playerid, ELEVATOR2, DIALOG_STYLE_LIST, "Elevator", "Rooftop\nInterior", "Lua chont", "Huy bo");
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Thang may nay khong su dung duoc.");
	}
	if(buttonid == roofkey)
	{
		if(!IsACop(playerid))
		{
			SendClientMessageEx(playerid,COLOR_GREY,"Truy cap bi tu choi.");
			return 1;
		}
		//else ShowPlayerDialog( playerid, ELEVATOR, DIALOG_STYLE_LIST, "Elevator", "Interior\nGarage", "Lua chont", "Huy bo");
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Thang may nay khong su dung duoc.");
	}
	if(buttonid == westin)
	{
		MoveDynamicObject(westlobby1,239.71582031,115.09179688,1002.21502686,4);
		MoveDynamicObject(westlobby2,239.67968750,120.09960938,1002.21502686,4);
		SetTimer("CloseWestLobby", 2500, false);
	}
	if(buttonid == eastin)
	{
	    MoveDynamicObject(eastlobby1,253.14941406,111.59960938,1002.21502686,4);
	    MoveDynamicObject(eastlobby2,253.18457031,106.59960938,1002.21502686,4);
		SetTimer("CloseEastLobby", 2500, false);
	}
	if (buttonid == PrisonButtons[0] || buttonid == PrisonButtons[3] || buttonid == PrisonButtons[5] || buttonid == PrisonButtons[6] || buttonid == PrisonButtons[7])
	{
 		if (IsACop(playerid))
   		{
            ShowPlayerDialog(playerid, PANEL, DIALOG_STYLE_LIST, "Easter Basin Correctional Facility Controls", "Prison Controls\r\nLockdown All\r\nClear Lockdown\r\nDistress Beacon", "Lua chont", "Huy bo");
		}
		else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong duoc phep su dung bang dieu khien.");
	}
	if(buttonid == PrisonButtons[1])
	{
	    if(IsACop(playerid))
	    {
     		MoveDynamicObject(BlastDoors[0],-2093.0048828125, -203.93110656738, 1994.6691894531, 1);
			SetTimer("ClosePrisonDoor", 3000, false);
	    }
	    else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong duoc phep su dung bang dieu khien nay.");
	}
	if(buttonid == PrisonButtons[2])
	{
	    if(IsACop(playerid))
	    {
			MoveDynamicObject(BlastDoors[1], -2088.7998046875, -211.2998046875, 1996.7062988281, 1);
		 	MoveDynamicObject(BlastDoors[6], -2088.76562500,-209.21093750,998.66918945, 1);
			SetTimer("ClosePrisonDoor2", 3000, false);
	    }
	    else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong duoc phep su dung bang dieu khien nay.");
	}
	if(buttonid == PrisonButtons[4]) //
	{
	    if(IsACop(playerid))
	    {
     		MoveDynamicObject(BlastDoors[11], -2050.50097656,-205.82617188,987.02539062, 1);
			SetTimer("ClosePrisonDoor3", 3000, false);
	    }
	    else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong duoc phep su dung bang dieu khien nay.");
	}
	if(buttonid == PrisonButtons[8]) //
	{
	    if(IsACop(playerid))
	    {
     		MoveDynamicObject(BlastDoors[16], -2057.9, -143.4, 987.24, 1);
			SetTimer("ClosePrisonDoor4", 3000, false);
	    }
	    else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong duoc phep su dung bang dieu khien nay.");
	}
	if (buttonid == SFPDButton[0] || buttonid == SFPDButton[3])
	{
	    if(IsACop(playerid))
	    {
			MoveDynamicObject(SFPDObject[0], -1636.02539062, 700.0, 19994.54101562, 2.5);
			SetTimer("SFPD", 3000, false);
		}
		else
		{
		    SendClientMessageEx(playerid, COLOR_GREY, "Truy cap bi tu choi.");
		}
	}

	if (buttonid == SFPDButton[1] || buttonid == SFPDButton[2])
	{
	    if(IsACop(playerid))
	    {
			MoveDynamicObject(SFPDObject[1], -1635.99414062,698,19994.55078125, 2.5);
			SetTimer("SFPD1", 3000, false);
		}
		else
		{
		    SendClientMessageEx(playerid, COLOR_GREY, "Truy cap bi tu choi.");
		}
	}

	if (buttonid == SFPDButton[4] || buttonid == SFPDButton[5])
	{
	    if(IsACop(playerid))
	    {
			MoveDynamicObject(SFPDObject[2], -1623.8,712.56250000,19994.85937500, 2.5);
			SetTimer("SFPD2", 3000, false);
		}
		else
		{
		    SendClientMessageEx(playerid, COLOR_GREY, "Truy cap bi tu choi.");
		}
	}

	if (buttonid == SFPDButton[6] || buttonid == SFPDButton[7])
	{
	    if(IsACop(playerid))
	    {
			MoveDynamicObject(SFPDObject[3], -1613.92871094,679.6,19989.05468750, 2.5);
            SetTimer("SFPD3", 3000, false);
		}
		else
		{
		    SendClientMessageEx(playerid, COLOR_GREY, "Truy cap bi tu choi.");
		}
	}

	if (buttonid == SFPDButton[8] || buttonid == SFPDButton[9])
	{
	    if(IsACop(playerid))
	    {
			MoveDynamicObject(SFPDObject[4], -1636.0,712.56250000,19994.85937500, 2.5);
			SetTimer("SFPD4", 3000, false);
		}
		else
		{
            SendClientMessageEx(playerid, COLOR_GREY, "Truy cap bi tu choi.");
		}
	}
	return false;
}

public OnEnterExitModShop( playerid, enterexit, interiorid ) {
	if(!enterexit && GetPlayerVehicle(playerid, GetPlayerVehicleID(playerid)) > -1) UpdatePlayerVehicleMods(playerid, GetPlayerVehicle(playerid, GetPlayerVehicleID(playerid)));
	if(!enterexit && DynVeh[GetPlayerVehicleID(playerid)] != -1) UpdateGroupVehicleMods(GetPlayerVehicleID(playerid));
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
    if(GetPlayerVehicle(playerid, vehicleid) > -1)
	{
		PlayerVehicleInfo[playerid][GetPlayerVehicle(playerid, vehicleid)][pvPaintJob] = paintjobid;
	}
    return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
    if(GetPlayerVehicle(playerid, vehicleid) > -1)
	{
		PlayerVehicleInfo[playerid][GetPlayerVehicle(playerid, vehicleid)][pvColor1] = color1;
		PlayerVehicleInfo[playerid][GetPlayerVehicle(playerid, vehicleid)][pvColor2] = color2;
	}
    return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(GetPVarInt(playerid, "mS_ignore_next_esc") == 1) {
		SetPVarInt(playerid, "mS_ignore_next_esc", 0);
		return CallLocalFunction("MP_OPCTD", "ii", playerid, _:clickedid);
	}
   	if(GetPVarInt(playerid, "mS_list_active") == 0) return CallLocalFunction("MP_OPCTD", "ii", playerid, _:clickedid);

	// Handle: They cancelled (with ESC)
	if(clickedid == Text:INVALID_TEXT_DRAW) {
		new listid = mS_GetPlayerCurrentListID(playerid);
		if(listid == mS_CUSTOM_LISTID)
		{
			new extraid = GetPVarInt(playerid, "mS_custom_extraid");
			mS_DestroySelectionMenu(playerid);
			CallLocalFunction("OnPlayerModelSelectionEx", "dddd", playerid, 0, extraid, -1);
			PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
		}
		else
		{
			mS_DestroySelectionMenu(playerid);
			CallLocalFunction("OnPlayerModelSelection", "dddd", playerid, 0, listid, -1);
			PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
		}
        return 1;
	}
	return 0;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(GetPVarInt(playerid, "mS_list_active") == 1 || (GetTickCount()-GetPVarInt(playerid, "mS_list_time")) > 200)
	{
		new curpage = GetPVarInt(playerid, "mS_list_page");

		// Handle: cancel button
		if(playertextid == gCancelButtonTextDrawId[playerid]) {
			new listID = mS_GetPlayerCurrentListID(playerid);
			if(listID == mS_CUSTOM_LISTID)
			{
				new extraid = GetPVarInt(playerid, "mS_custom_extraid");
				HideModelSelectionMenu(playerid);
				CallLocalFunction("OnPlayerModelSelectionEx", "dddd", playerid, 0, extraid, -1);
				PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
			}
			else
			{
				HideModelSelectionMenu(playerid);
				CallLocalFunction("OnPlayerModelSelection", "dddd", playerid, 0, listID, -1);
				PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
			}
			return 1;
		}

		// Handle: next button
		if(playertextid == gNextButtonTextDrawId[playerid]) {
			new listID = mS_GetPlayerCurrentListID(playerid);
			if(listID == mS_CUSTOM_LISTID)
			{
				if(curpage < (mS_GetNumberOfPagesEx(playerid) - 1)) {
					SetPVarInt(playerid, "mS_list_page", curpage + 1);
					mS_ShowPlayerMPs(playerid);
					mS_UpdatePageTextDraw(playerid);
					PlayerPlaySound(playerid, 1083, 0.0, 0.0, 0.0);
				} else {
					PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
				}
			}
			else
			{
				if(curpage < (mS_GetNumberOfPages(listID) - 1)) {
					SetPVarInt(playerid, "mS_list_page", curpage + 1);
					mS_ShowPlayerMPs(playerid);
					mS_UpdatePageTextDraw(playerid);
					PlayerPlaySound(playerid, 1083, 0.0, 0.0, 0.0);
				} else {
					PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
				}
			}
			return 1;
		}

		// Handle: previous button
		if(playertextid == gPrevButtonTextDrawId[playerid]) {
			if(curpage > 0) {
				SetPVarInt(playerid, "mS_list_page", curpage - 1);
				mS_ShowPlayerMPs(playerid);
				mS_UpdatePageTextDraw(playerid);
				PlayerPlaySound(playerid, 1084, 0.0, 0.0, 0.0);
			} else {
				PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
			}
			return 1;
		}

		// Search in the array of textdraws used for the items
		new x=0;
		while(x != mS_SELECTION_ITEMS) {
			if(playertextid == gSelectionItems[playerid][x]) {
				new listID = mS_GetPlayerCurrentListID(playerid);
				if(listID == mS_CUSTOM_LISTID)
				{
					PlayerPlaySound(playerid, 1083, 0.0, 0.0, 0.0);
					new item_id = gSelectionItemsTag[playerid][x];
					new extraid = GetPVarInt(playerid, "mS_custom_extraid");
					HideModelSelectionMenu(playerid);
					CallLocalFunction("OnPlayerModelSelectionEx", "dddd", playerid, 1, extraid, item_id);
					return 1;
				}
				else
				{
					PlayerPlaySound(playerid, 1083, 0.0, 0.0, 0.0);
					new item_id = gSelectionItemsTag[playerid][x];
					HideModelSelectionMenu(playerid);
					CallLocalFunction("OnPlayerModelSelection", "dddd", playerid, 1, listID, item_id);
					return 1;
				}
			}
			x++;
		}
	}

	new tableid = GetPVarInt(playerid, "pkrTableID")-1;
	if(playertextid == PlayerPokerUI[playerid][38])
	{
		switch(GetPVarInt(playerid, "pkrActionOptions"))
 		{
			case 1: // Raise
			{
				PokerRaiseHand(playerid);
				PokerTable[tableid][pkrRotations] = 0;
			}
			case 2: // Call
			{
				PokerCallHand(playerid);
			}
			case 3: // Check
			{
				PokerCheckHand(playerid);
				PokerRotateActivePlayer(tableid);
			}
 		}
	}
	if(playertextid == PlayerPokerUI[playerid][39])
	{
		switch(GetPVarInt(playerid, "pkrActionOptions"))
		{
			case 1: // Check
			{
				PokerCheckHand(playerid);
				PokerRotateActivePlayer(tableid);
			}
			case 2: // Raise
			{
				PokerRaiseHand(playerid);
				PokerTable[tableid][pkrRotations] = 0;
			}
			case 3: // Fold
			{
				PokerFoldHand(playerid);
				PokerRotateActivePlayer(tableid);
			}
		}
	}
	if(playertextid == PlayerPokerUI[playerid][40])
	{
		switch(GetPVarInt(playerid, "pkrActionOptions"))
		{
			case 1: // Fold
			{
				PokerFoldHand(playerid);
				PokerRotateActivePlayer(tableid);
			}
			case 2: // Fold
			{
				PokerFoldHand(playerid);
				PokerRotateActivePlayer(tableid);
			}
		}
	}
	if(playertextid == PlayerPokerUI[playerid][41]) // LEAVE
	{
		if(GetPVarType(playerid, "pkrTableID")) {
			LeavePokerTable(playerid);
		}
	}
	return 1;
}

public OnPlayerModelSelection(playerid, response, listid, modelid)
{
	/*if(!response)
	{
 		if(listid == CarList)
	    {
	        print("[ListReloaded]");
	        ToyList = LoadModelSelectionMenu("ToyList.txt");
			CarList = LoadModelSelectionMenu("CarList.txt");
			PlaneList = LoadModelSelectionMenu("PlaneList.txt");
			BoatList = LoadModelSelectionMenu("BoatList.txt");
			SkinList = LoadModelSelectionMenu("SkinList.txt");
	    }
	} */
	if(listid == ToyList2 || listid == ToyList)
	{
	    if(response)
	    {
	        if(modelid == 18647)
	        {
				ShowPlayerDialog(playerid, DIALOG_SHOPNEON, DIALOG_STYLE_LIST, "Den Neon", "Den Neon Do\nDen Neon Xanh\nDen Neon Xanh La Cay\nDen Neon Vang\nDen Neon Hong\nDen Neon Trang", "Lua chont", "Huy bo");
	        }
	        else
	        {
   	 			new stringg[512];
				for(new z;z<MAX_PLAYERTOYS;z++)
				{
					new name[24];
   					format(name, sizeof(name), "None");

					for(new i;i<sizeof(HoldingObjectsAll);i++)
					{
						if(HoldingObjectsAll[i][holdingmodelid] == PlayerToyInfo[playerid][z][ptModelID])
						{
							format(name, sizeof(name), "%s", HoldingObjectsAll[i][holdingmodelname]);
						}
					}

					format(stringg, sizeof(stringg), "%s(%d) %s (Bone: %s)\n", stringg, z, name, HoldingBones[PlayerToyInfo[playerid][z][ptBone]]);
				}
				printf("MODELID: %d", modelid);
				ShowPlayerDialog(playerid, DIALOG_SHOPBUYTOYS, DIALOG_STYLE_LIST, "Chon mot slot", stringg, "Lua chont", "Huy bo");
	  			SetPVarInt(playerid, "ToyID", modelid);
			}
	    }
	    else SendClientMessage(playerid, COLOR_GREY, "Ban da dong cua hang do choi.");
    	return 1;
	}
	if(listid == BoatList)
	{
		if(response)
		{
			new string[128];
			SetPVarInt(playerid, "VehicleID", modelid), SetPVarInt(playerid, "BoatShop", 1);
			format(string, sizeof(string), "Item: %s\nCredits cua ban: %s\nCost: {FFD700}%s{A9C4E4}\nCredits Left: %s", VehicleName[modelid-400], number_format(PlayerInfo[playerid][pCredits]),number_format(ShopItems[5][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[5][sItemPrice]));
			ShowPlayerDialog(playerid, DIALOG_CARSHOP, DIALOG_STYLE_MSGBOX, "Cua hang xe", string, "Mua", "Huy bo");
		}
	}
	if(listid == PlaneList)
	{
		if(response)
		{
			new string[128];
			SetPVarInt(playerid, "VehicleID", modelid);
			format(string, sizeof(string), "Item: %s\nCredits cua ban: %s\nCost: {FFD700}%s{A9C4E4}\nCredits Left: %s", VehicleName[modelid-400], number_format(PlayerInfo[playerid][pCredits]),number_format(ShopItems[5][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[5][sItemPrice]));
			ShowPlayerDialog(playerid, DIALOG_CARSHOP, DIALOG_STYLE_MSGBOX, "Cua hang xe", string, "Mua", "Huy bo");
		}
	}
	if(listid == CarList2 || listid == CarList)
	{
	    if(response)
	    {
			if(GetPVarInt(playerid, "PlayerCuffed") != 0) // Check to see if you're tazed or cuffed
			{
				DeletePVar(playerid, "voucherdialog");
				DeletePVar(playerid, "WhoIsThis");
				return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong the lam dieu nay khi dang bi cong tay.");
			}
			if(IsPlayerInAnyVehicle(playerid))
			{
				DeletePVar(playerid, "voucherdialog");
				DeletePVar(playerid, "WhoIsThis");
				return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong the lam dieu nay khi dang trong mot chiec xe.");
			}
			if(GetPVarInt(playerid, "voucherdialog") == 0)
			{
				if(!GetPVarType(playerid, "RentaCar"))
				{
					new string[128];
					SetPVarInt(playerid, "VehicleID", modelid);
					format(string, sizeof(string), "Item: %s\nCredits cua ban: %s\nGia: {FFD700}%s{A9C4E4}\nCredits Left: %s", VehicleName[modelid-400], number_format(PlayerInfo[playerid][pCredits]),number_format(ShopItems[5][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[5][sItemPrice]));
					ShowPlayerDialog(playerid, DIALOG_CARSHOP, DIALOG_STYLE_MSGBOX, "Cua hang xe", string, "Mua", "Huy bo");
				}
				else
				{
					new string[128];
					SetPVarInt(playerid, "VehicleID", modelid);
					format(string, sizeof(string), "Item: %s\nCredits cua ban: %s\nGia: {FFD700}%s{A9C4E4}\nCredits Left: %s", VehicleName[modelid-400], number_format(PlayerInfo[playerid][pCredits]),number_format(ShopItems[20][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[20][sItemPrice]));
					ShowPlayerDialog(playerid, DIALOG_RENTACAR, DIALOG_STYLE_MSGBOX, "Thue xe", string, "Mua", "Huy bo");
				}
			}
			else if(GetPVarInt(playerid, "voucherdialog") == 1)
			{	
				if(!vehicleCountCheck(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Kho xe da day, Ban khong the mua them xe duoc nua - Ban co the mua them slot xe cua ban thong qua /vstorage.");
				if(!vehicleSpawnCountCheck(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban co qua nhieu xe duoc lay ra, vui long cat bot xe cua ban vao kho.");
				
				new Float: arr_fPlayerPos[4], szLog[128], szString[128];
				GetPlayerPos(playerid, arr_fPlayerPos[0], arr_fPlayerPos[1], arr_fPlayerPos[2]);
				GetPlayerFacingAngle(playerid, arr_fPlayerPos[3]);
				CreatePlayerVehicle(playerid, GetPlayerFreeVehicleId(playerid), modelid, arr_fPlayerPos[0], arr_fPlayerPos[1], arr_fPlayerPos[2], arr_fPlayerPos[3], 0, 0, 2000000, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
				
				PlayerInfo[playerid][pVehVoucher]--;
				format(szString, sizeof(szString), "You have successfully used one of your car voucher(s), you have %d car voucher(s) left.", PlayerInfo[playerid][pVehVoucher]);
				SendClientMessageEx(playerid, COLOR_CYAN, szString);
				format(szLog, sizeof(szLog), "%s has used one of his car voucher(s) and has %d left.", GetPlayerNameEx(playerid), PlayerInfo[playerid][pVehVoucher]);
				Log("logs/vouchers.log", szLog);
				DeletePVar(playerid, "voucherdialog");
				DeletePVar(playerid, "WhoIsThis");
			}			
		}
		DeletePVar(playerid, "RentaCar");
	}
	if(listid == CarList3)
	{
	    if(response)
	    {
	        new string[128];
       		SetPVarInt(playerid, "VehicleID", modelid);
       		format(string, sizeof(string), "Item: %s\nGia: 1 Restricted Car Voucher", VehicleName[modelid-400]);
   			ShowPlayerDialog(playerid, DIALOG_CARSHOP2, DIALOG_STYLE_MSGBOX, "Restricted Vehicle Shop", string, "Mua", "Huy bo");
	    }
	}
	if(listid == SkinList) 
	{
		if(response)
		{
			if(PlayerInfo[playerid][pDonateRank] >= 2)
			{
				if (PlayerInfo[playerid][pModel] == modelid)
					return SendClientMessageEx(playerid, COLOR_GREY, "Ban dang su dung skin nay.");
					
				PlayerInfo[playerid][pModel] = modelid;
				SetPlayerSkin(playerid, modelid);
				return SendClientMessageEx(playerid, COLOR_YELLOW, "VIP: Ban da thay doi skin mien phi.");
			}	
			if(IsValidSkin(modelid) == 0)
			{
				if(GetPVarInt(playerid, "freeSkin") == 1)
			    {
					SendClientMessageEx(playerid, COLOR_GREY, "Skin nay bi gioi han cho Faction hoac Family!");
	            	ShowModelSelectionMenu(playerid, SkinList, "Thay doi skin.");
				} 
				else {
					SendClientMessageEx(playerid, COLOR_GREY, "That skin ID is either invalid or restricted to faction or family!");
	            	ShowModelSelectionMenu(playerid, SkinList, "Thay doi skin.");
				}
			}
			else {
				if (PlayerInfo[playerid][pModel] == modelid)
				{
					return SendClientMessageEx(playerid, COLOR_GREY, "Ban dang su dung skin nay.");
				}
			    if(GetPVarInt(playerid, "freeSkin") == 1)
			    {
					PlayerInfo[playerid][pModel] = modelid;
					SetPlayerSkin(playerid, modelid);
					SetPVarInt(playerid, "freeSkin", 0);
			    }
			    else
			    {
			        new 
						string[128],
						iBusiness = InBusiness(playerid);

			        if(GetPlayerCash(playerid) < GetPVarInt(playerid, "SkinChangeCost")) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong the su dung skin nay!");
					GameTextForPlayer(playerid, "~g~Clothes purchased!", 2000, 1);
					PlayerInfo[playerid][pModel] = modelid;
					SetPlayerSkin(playerid, modelid);

					Businesses[iBusiness][bInventory]--;
					Businesses[iBusiness][bTotalSales]++;
					Businesses[iBusiness][bSafeBalance] += TaxSale(GetPVarInt(playerid, "SkinChangeCost"));
                    GivePlayerCash(playerid, -GetPVarInt(playerid, "SkinChangeCost"));

					format(string, sizeof(string), "%s (IP: %s) da mua skin %d trong %s (%d) cho %d.", GetPlayerNameEx(playerid), GetPlayerIpEx(playerid), modelid, Businesses[InBusiness(playerid)][bName],InBusiness(playerid),GetPVarInt(playerid, "SkinChangeCost"));
					Log("logs/business.log", string);
					DeletePVar(playerid, "SkinChangeCost");
				}
			}
		}
	}
	return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	acstruct[playerid][checkmaptp] = 1; acstruct[playerid][maptplastclick] = GetTickCount();
	acstruct[playerid][maptp][0] = fX; acstruct[playerid][maptp][1] = fY; acstruct[playerid][maptp][2] = fZ;
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid)
{
	if(GetPVarInt(playerid, "commitSuicide") == 1)
	{
		SetPVarInt(playerid, "commitSuicide", 0);
	}
	if(issuerid != INVALID_PLAYER_ID)
	{
	    ShotPlayer[issuerid][playerid] = gettime();
	    LastShot[playerid] = gettime();
		aLastShot[playerid] = issuerid;
		if(GetPVarType(playerid, "gt_Spraying"))
		{
			DeletePVar(playerid, "gt_Spraying");
		}
		if(prisonactive == 0)
	    {
			if(amount == 0)
  			{
    			if(weaponid != 54 && weaponid != 4)
	    		{
					if(GetPVarInt(playerid, "CleoWarning") == 2)
					{
					    if(PlayerInfo[playerid][pJailTime] > 0) return 1;
					    new totalwealth = PlayerInfo[playerid][pAccount] + GetPlayerCash(playerid);
						if(PlayerInfo[playerid][pPhousekey] != INVALID_HOUSE_ID && HouseInfo[PlayerInfo[playerid][pPhousekey]][hOwnerID] == GetPlayerSQLId(playerid)) totalwealth += HouseInfo[PlayerInfo[playerid][pPhousekey]][hSafeMoney];
						if(PlayerInfo[playerid][pPhousekey2] != INVALID_HOUSE_ID && HouseInfo[PlayerInfo[playerid][pPhousekey2]][hOwnerID] == GetPlayerSQLId(playerid)) totalwealth += HouseInfo[PlayerInfo[playerid][pPhousekey2]][hSafeMoney];

						new fine = 15*totalwealth/100;
						if(fine < 1) fine = 1000000;
						GivePlayerCash(playerid, -fine);
                        PlayerInfo[playerid][pWarns] += 1;
	                    SetPlayerArmedWeapon(playerid, 0);
						if(GetPVarInt(playerid, "IsInArena") >= 0)
						{
							LeavePaintballArena(playerid, GetPVarInt(playerid, "IsInArena"));
						}
						new string[128];
						GameTextForPlayer(playerid, "~w~Chao mung ban den ~n~~r~Fort DeMorgan", 5000, 3);
						ResetPlayerWeaponsEx(playerid);
						SendClientMessageEx(playerid, COLOR_CYAN, "Tang 15% CLEO vao tai khoan cua ban cung voi thoi gian ngoi tu 3 gio - neu con su dung ban co the bi khoa tai khoan");
						ShowPlayerDialog(playerid,DIALOG_NOTHING,DIALOG_STYLE_MSGBOX,"BUSTED!","Tang 15% CLEO vao tai khoan cua ban cung voi thoi gian ngoi tu 3 gio - neu con su dung ban co the bi khoa tai khoan","Thoat","");

						if(PlayerInfo[playerid][pLevel] > 3) {
						    format(string, sizeof(string), "AdmCmd: %s da bi dua vao tu boi Admin, ly do: BUSTED!", GetPlayerNameEx(playerid), GetPlayerNameEx(playerid));
							SendClientMessageToAllEx(COLOR_LIGHTRED, string);
						}
						else {
						    format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s da bi dua vao tu boi Admin, ly do: BUSTED!", GetPlayerNameEx(playerid), GetPlayerNameEx(playerid));
							ABroadCast(COLOR_YELLOW, string, 3);
						}
						PlayerInfo[playerid][pWantedLevel] = 0;
						SetPlayerWantedLevel(playerid, 0);
						SetPlayerHealth(playerid, 0x7FB00000);
						PlayerInfo[playerid][pJailTime] = 180*60;
						SetTimerEx("IdiotSound", 10000, false, "i", playerid);
						strcpy(PlayerInfo[playerid][pPrisonReason], "[OOC][PRISON] BUSTED!", 128);
						strcpy(PlayerInfo[playerid][pPrisonedBy], "System", 128);
						PhoneOnline[playerid] = 1;
						SetPlayerInterior(playerid, 1);
						PlayerInfo[playerid][pInt] = 1;
						new rand = random(sizeof(OOCPrisonSpawns));
						Streamer_UpdateEx(playerid, OOCPrisonSpawns[rand][0], OOCPrisonSpawns[rand][1], OOCPrisonSpawns[rand][2]);
						SetPlayerPos(playerid, OOCPrisonSpawns[rand][0], OOCPrisonSpawns[rand][1], OOCPrisonSpawns[rand][2]);
						SetPlayerSkin(playerid, 50);
						SetPlayerColor(playerid, TEAM_APRISON_COLOR);
						Player_StreamPrep(playerid, OOCPrisonSpawns[rand][0], OOCPrisonSpawns[rand][1], OOCPrisonSpawns[rand][2], FREEZE_TIME);
						new WeaponName[ 32 ];
						GetWeaponName( weaponid, WeaponName, sizeof( WeaponName ) );
						format(string, sizeof(string), "[PRISONED] %s(%d) (Ping: %d) | damage: %f | Weapon: %s | Issuer: %s(%d) | Frames: %d", GetPlayerNameExt(playerid), playerid, GetPlayerPing(playerid), amount, WeaponName, GetPlayerNameExt(issuerid), issuerid, pFPS[playerid]);
						Log("logs/cleo.log", string);
						foreach(new i : Player)
					    {
					        if(IsPlayerAdmin(i))
					        {
								SendClientMessageEx(i, COLOR_CYAN, string);
					        }
					    }
						DeletePVar(playerid, "CleoWarning");
					}
					else
					{
					    new WeaponName[ 32 ], string[128];
						GetWeaponName( weaponid, WeaponName, sizeof( WeaponName ) );
						format(string, sizeof(string), "%s(%d) (Ping: %d) | damage: %f | Weapon: %s | Issuer: %s(%d) | Frames: %d", GetPlayerNameExt(playerid), playerid, GetPlayerPing(playerid), amount, WeaponName, GetPlayerNameExt(issuerid), issuerid, pFPS[playerid]);
						Log("logs/cleo.log", string);
						foreach(new i : Player)
					    {
					        if(IsPlayerAdmin(i))
					        {
								SendClientMessageEx(i, COLOR_CYAN, string);
					        }
					    }
					    SetPVarInt(playerid, "CleoWarning", GetPVarInt(playerid, "CleoWarning")+1);
					}
				}
			}
		}
	}

	if(GetPVarInt(playerid, "PlayerCuffed") == 1)
	{
		new Float:currenthealth;
		GetPlayerHealth(playerid, currenthealth);
		if(currenthealth+amount > 100) SetPlayerHealth(playerid, 100); else SetPlayerHealth(playerid, currenthealth+amount);
	}

	foreach(new i: Player) {
		if(PlayerInfo[i][pAdmin] >= 2 && GetPVarType(i, "_dCheck") && GetPVarInt(i, "_dCheck") == playerid) {
			new string[128];
			format(string, sizeof(string), "Damagecheck on %s: Issuer: %s (%d) | Weapon: %s | Damage: %f", GetPlayerNameEx(playerid), GetPlayerNameEx(issuerid), issuerid, GetWeaponNameEx(weaponid), amount);
			SendClientMessageEx(i, COLOR_WHITE, string);
		}	
	}	
	new Float:actual_damage = amount;
	//fitness damage modifier
	if (weaponid == 0 || weaponid == 1 || weaponid == 2 || weaponid == 3 || weaponid == 5 || weaponid == 6 || weaponid == 7 || weaponid == 8)
	{
	    new Float: multiply;

	    if(PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pJailTime] > 0 || HelpingNewbie[playerid] != INVALID_PLAYER_ID || GetPVarInt(playerid, "eventStaff") >= 1) return 1;
		
		if(hgActive == 1 && HungerPlayerInfo[playerid][hgInEvent] == 1) return 1;
		
		if (PlayerInfo[issuerid][pFitness] < 50)
		{
 			multiply = 2;
		}
		else if (PlayerInfo[issuerid][pFitness] >= 50 && PlayerInfo[issuerid][pFitness] <= 79)
		{
		    multiply = 3.5;
		}
		else if (PlayerInfo[issuerid][pFitness] >= 80)
		{
		    multiply = 5;
		}

		if (PlayerInfo[playerid][pFitness] >= 80)
		{
			actual_damage = actual_damage/2;
		}

  		actual_damage *= multiply;

	}

	//heroin damage reduction
	if (GetPVarInt(playerid, "HeroinDamageResist") == 1) {
		actual_damage *= 0.25;
	}

	//armor & hp calculations AFTER damage modifiers
	new Float:difference;
	new Float:health, Float:armour;
	GetPlayerHealth(playerid, health);
	GetPlayerArmour(playerid, armour);

	if (armour == 0)
	{
		if (actual_damage > amount)
		{
			difference = actual_damage - amount;
			SetPlayerHealth(playerid, health - difference);
		}
		else if (actual_damage < amount)
		{
			difference = amount - actual_damage;
			SetPlayerHealth(playerid, health - difference);
		}
	}
	else if (armour >= actual_damage)
	{
		if (actual_damage > amount)
		{
			difference = actual_damage - amount;
			SetPlayerArmor(playerid, armour - difference);
		}
		else if (actual_damage < amount)
		{
			difference = amount - actual_damage;
			SetPlayerArmor(playerid, armour - difference);
		}
	}
	else // damage needs to be split between armour & health
	{
		if (actual_damage > amount)
		{
			difference = actual_damage - amount;

			new Float:leftOver = difference - armour;
			SetPlayerArmor(playerid, 0);
			SetPlayerHealth(playerid, health - leftOver);
		}
		else if (actual_damage < amount)
		{
			difference = amount - actual_damage;

			new Float:leftOver = difference - armour;
			SetPlayerArmor(playerid, 0);
			SetPlayerHealth(playerid, health - leftOver);
		}
	}


	return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid)
{
	if (damagedid == INVALID_PLAYER_ID) return 1;
	if (playerid == INVALID_PLAYER_ID) return 1;

    if(pTazer{playerid} == 1)
	{
	    if(weaponid !=  23) {
	    	new string[44 + MAX_PLAYER_NAME];
			RemovePlayerWeaponEx(playerid, 23);
			GivePlayerValidWeapon(playerid, pTazerReplace{playerid}, 60000);
			format(string, sizeof(string), "* %s holsters their tazer.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			pTazer{playerid} = 0;
			return 1;
		}
		if(!ProxDetectorS(20.0, playerid, damagedid)) {
			new string[44 + (MAX_PLAYER_NAME * 2)];
			format(string, sizeof(string), "* %s fires their tazer at %s, missing them.", GetPlayerNameEx(playerid), GetPlayerNameEx(damagedid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			return 1;
		}
 		if(TazerTimeout[playerid] > 0 && !GetPVarType(damagedid, "IsFrozen"))
  		{
  		    new Float:hp;
  		    GetPlayerHealth(damagedid, hp);
  		    SetPlayerHealth(damagedid, hp-amount);
			return 1;
		}
		if(GetPlayerState(damagedid) == PLAYER_STATE_ONFOOT && PlayerCuffed[damagedid] == 0 && PlayerInfo[playerid][pHasTazer] == 1)
		{
		    if(PlayerInfo[damagedid][pAdmin] >= 2 && PlayerInfo[damagedid][pTogReports] != 1)
			{
			    SendClientMessageEx(playerid, COLOR_GRAD2, "Admin khong the bi tazer!");
			    new Float:hp;
	  		    GetPlayerHealth(damagedid, hp);
	  		    SetPlayerHealth(damagedid, hp+amount);
				return 1;
			}
			#if defined zombiemode
			if(GetPVarInt(damagedid, "pIsZombie"))
			{
			    SendClientMessageEx(playerid, COLOR_GRAD2, "Zombie khong the bi tazer!");
				return 1;
			}
			#endif
			new Float:X, Float:Y, Float:Z, Float:hp;
	  		GetPlayerPos(playerid, X, Y, Z);
			GetPlayerHealth(damagedid, hp);
			new string[44 + (MAX_PLAYER_NAME * 2)];
			format(string, sizeof(string), "* %s da ban sung dien lam te liet %s .", GetPlayerNameEx(playerid), GetPlayerNameEx(damagedid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			GameTextForPlayer(damagedid, "~r~Tazed", 3500, 3);
   			SetPlayerHealth(damagedid, hp+amount);
			TogglePlayerControllable(damagedid, false);
			ApplyAnimation(damagedid,"CRACK","crckdeth2",4.1,false,true,true,true,1,1);
			PlayerPlaySound(damagedid, 1085, X, Y, Z);
			PlayerPlaySound(playerid, 1085, X, Y, Z);
			PlayerCuffed[damagedid] = 1;
			SetPVarInt(damagedid, "PlayerCuffed", 1);
			PlayerCuffedTime[damagedid] = 16;
			SetPVarInt(damagedid, "IsFrozen", 1);
			TazerTimeout[playerid] = 6;
			SetTimerEx("TazerTimer",1000,false,"d",playerid);
			GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~n~~r~Dang tai Tazer... ~w~5", 1500,3);
		}
	}
	return 1;
}

/*public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid)
{
	if(PlayerInfo[playerid][pAdmin] >= 2 && GetPVarType(playerid, "pGodMode")) return 1;
	if(weaponid == 50)
	{
		return 1;
	}

	new Float:armour, Float:HP;
	GetPlayerArmour(playerid, armour);
	GetPlayerHealth(playerid, HP);

	if(HP <= 0) return 1;

	if(((GetTickCount() - pSSHealthTime[playerid][0]) > (pSSHealthTime[playerid][1] * 2)))
	{
	    if(weaponid != 54 && weaponid != 37 && weaponid != 38 && weaponid != 51 && weaponid != 53)
	    {
			if(HP <= 0) return 1; // let them die if they are dead!

			if((pSSArmour[playerid] > 0) && (((pSSArmour[playerid] > armour) && ((pSSArmour[playerid]-armour) > 1)) || ((pSSArmour[playerid] < armour) && ((armour-pSSArmour[playerid]) > 1))))
			{
			    if(pSSArmour[playerid] > armour)
			    {
			        new string[128];
					format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) is possibly armour hacking", GetPlayerNameEx(playerid), playerid);
			 		ABroadCast( COLOR_YELLOW, string, 2 );

			 		format(string, sizeof(string), "{AA3333}Expected Armour: {AA3333}%f | {AA3333}Armour: {AA3333}%f]", pSSArmour[playerid], armour);
					ABroadCast( COLOR_YELLOW, string, 2 );
				}
			}
			if((pSSHealth[playerid] > 0) && (((pSSHealth[playerid] > HP) && ((pSSHealth[playerid]-HP) > 1)) || ((pSSHealth[playerid] < HP) && ((HP-pSSHealth[playerid]) > 1))))
		 	{
		 	    if(pSSHealth[playerid] > HP)
		 	    {
		 	        new string[128];
					format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) is possibly health hacking", GetPlayerNameEx(playerid), playerid);
			 		ABroadCast( COLOR_YELLOW, string, 2 );

			 		format(string, sizeof(string), "{AA3333}Expected HP: {AA3333}%f | {AA3333}HP: {AA3333}%f]", pSSHealth[playerid], HP);
			 	 	ABroadCast( COLOR_YELLOW, string, 2 );
				}
			}
		}
	}

	if(armour > 0)
	{
		if(armour >= amount)
		{
		    //Don't set double damage for drowning, splat, fire
		    if(weaponid == 54 || weaponid == 53 || weaponid == 37)
			{
				pSSArmour[playerid] = (pSSArmour[playerid]-amount);
			}
			else
			{
				SetPlayerArmor(playerid, pSSArmour[playerid]-amount);
			}
		}
		else
		{
			if(weaponid == 54 || weaponid == 53 || weaponid == 37)
		    {
		        pSSArmour[playerid] = 0;
		        pSSHealth[playerid] = (pSSHealth[playerid]-(amount-pSSArmour[playerid]));
			}
			else
			{
				SetPlayerArmor(playerid, 0);
				SetPlayerHealth(playerid, pSSHealth[playerid]-(amount-pSSArmour[playerid]));
			}
		}
	}
	else
	{
 		if(weaponid == 54 || weaponid == 53 || weaponid == 37)
 		{
		 	pSSHealth[playerid] = (pSSHealth[playerid]-amount);
		}
 		else
	 	{
	 		SetPlayerHealth(playerid, pSSHealth[playerid]-amount);
		}
	}
	return 1;
}*/

public OnPlayerStreamIn(playerid, forplayerid)
{
    switch(Backup[playerid]) {
		case 1: {
	        if(PlayerInfo[playerid][pMember] == PlayerInfo[forplayerid][pMember])
	        {
	            new string[128];
	            if(GetPVarInt(playerid, "InRangeBackup") < 1)
	            {
		            SetPVarInt(playerid, "InRangeBackup", 30);
		            format(string, sizeof(string), "Ban dang o trong pham vi cua %s's goi backup(Code 3) (Mau xanh danh dau tren minimap)", GetPlayerNameEx(playerid));
		            SendClientMessageEx(forplayerid, DEPTRADIO, string);
				}
	  			SetPlayerMarkerForPlayer(forplayerid, playerid, 0x2641FEAA);
			}
		}
		case 2: {
  			if(PlayerInfo[playerid][pMember] == PlayerInfo[forplayerid][pMember])
	        {
	            new string[128];
	            if(GetPVarInt(playerid, "InRangeBackup") < 1)
	            {
		            SetPVarInt(playerid, "InRangeBackup", 30);
		            format(string, sizeof(string), "Ban dang o trong pham vi cua %s's goi backup(Code 2) (Mau xanh la tren minimap)", GetPlayerNameEx(playerid));
		            SendClientMessageEx(forplayerid, DEPTRADIO, string);
				}
	  			SetPlayerMarkerForPlayer(forplayerid, playerid, 0x00FF33AA);
			}
		}
		case 3: {
  			if(IsACop(forplayerid))
	        {
	            new string[128];
	            if(GetPVarInt(playerid, "InRangeBackup") < 1)
	            {
		            SetPVarInt(playerid, "InRangeBackup", 30);
		            format(string, sizeof(string), "Ban dang o trong pham vi cua %s's goi backup(Code 3) (Mau xanh danh dau tren minimap)", GetPlayerNameEx(playerid));
		            SendClientMessageEx(forplayerid, DEPTRADIO, string);
				}
	  			SetPlayerMarkerForPlayer(forplayerid, playerid, 0x2641FEAA);
			}
		}
	}
    return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
    if(Backup[playerid] > 0) {
        if(IsACop(forplayerid))
        {
  			SetPlayerToTeamColor(playerid);
		}
	}
    return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    IsPlayerEntering{playerid} = true;
	Seatbelt[playerid] = 0;
	if(PlayerCuffed[playerid] != 0) SetPVarInt( playerid, "ToBeEjected", 1 );

	if(ispassenger) {
		if(GetPVarType(playerid, "Injured")) {
			SetPlayerPos(playerid, GetPVarFloat(playerid,"MedicX"), GetPVarFloat(playerid,"MedicY"), GetPVarFloat(playerid,"MedicZ"));
			ClearAnimations(playerid);
			ApplyAnimation(playerid, "KNIFE", "KILL_Knife_Ped_Die", 4.0, false, true, true, true, 0, 1);
		}
		else if(PlayerCuffed[playerid] != 0) {
			ClearAnimations(playerid);
			ApplyAnimation(playerid,"ped","cower",1,true,false,false,false,0,1);
			TogglePlayerControllable(playerid, false);
		}
	}
	SetPVarInt(playerid, "LastWeapon", GetPlayerWeapon(playerid));

	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
	if(engine == VEHICLE_PARAMS_UNSET) switch(GetVehicleModel(vehicleid)) {
		case 509, 481, 510: VehicleFuel[vehicleid] = GetVehicleFuelCapacity(vehicleid), arr_Engine{vehicleid} = 1, SetVehicleParamsEx(vehicleid,VEHICLE_PARAMS_ON,lights,alarm,doors,bonnet,boot,objective);
		default: SetVehicleParamsEx(vehicleid,VEHICLE_PARAMS_OFF,VEHICLE_PARAMS_OFF,alarm,doors,bonnet,boot,objective), arr_Engine{vehicleid} = 0;
	}

	if(GetPVarInt(playerid, "UsingSprunk") == 1)
	{
		SetPVarInt(playerid, "UsingSprunk", 0);
		SetPVarInt(playerid, "DrinkCooledDown", 0);
	}

    if(GetPVarType(playerid, "Pizza") && !(IsAPizzaCar(vehicleid)))
	{
	    new Float:slx, Float:sly, Float:slz;
		GetPlayerPos(playerid, slx, sly, slz);
		SetPlayerPos(playerid, slx, sly, slz+1.3);
		PlayerPlaySound(playerid, 1130, slx, sly, slz+1.3);
		RemovePlayerFromVehicle(playerid);
		defer NOPCheck(playerid);
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban can o pizzaboy khi cung cap banh pizza!");
		return 1;
	}
	if(!ispassenger)
	{
	    SetPlayerArmedWeapon(playerid, 0);
		if(IsVIPcar(vehicleid))
		{
		    if(PlayerInfo[playerid][pDonateRank] == 0)
			{
			    new Float:slx, Float:sly, Float:slz;
				GetPlayerPos(playerid, slx, sly, slz);
				SetPlayerPos(playerid, slx, sly, slz+1.3);
				PlayerPlaySound(playerid, 1130, slx, sly, slz+1.3);
			    RemovePlayerFromVehicle(playerid);
			    defer NOPCheck(playerid);
			    SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong phai VIP, day la chiec xe duoc lay tu gara VIP!");
			}
		}
		else if(IsWeaponizedVehicle(GetVehicleModel(vehicleid)))
	    {
	        if(PlayerInfo[playerid][pLevel] < 6)
	        {
				if(gettime() > GetPVarInt(playerid, "timeWepVeh"))
				{
					new szString[128];
					format(szString, sizeof(szString), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) has entered a weaponize vehicle (Vehicle ID: %d) (Level: %d)", GetPlayerNameEx(playerid), playerid, vehicleid, PlayerInfo[playerid][pLevel]);
					ABroadCast(COLOR_YELLOW, szString, 2);
					SetPVarInt(playerid, "timeWepVeh", gettime()+5);
				}	
			}
		}
		else if(IsFamedVeh(vehicleid))
		{
		    if(PlayerInfo[playerid][pFamed] > 0 || PlayerInfo[playerid][pFamed] < 8)
		    {
				if(IsOSModel(vehicleid))
				{
				    if(PlayerInfo[playerid][pFamed] < 1)
				    {
                        new Float:slx, Float:sly, Float:slz;
						GetPlayerPos(playerid, slx, sly, slz);
						SetPlayerPos(playerid, slx, sly, slz+1.3);
						PlayerPlaySound(playerid, 1130, slx, sly, slz+1.3);
					    RemovePlayerFromVehicle(playerid);
					    defer NOPCheck(playerid);
					    SendClientMessageEx(playerid, COLOR_GRAD2, "Day la xe Old-School, ban khong the su dung chiec xe nay.");
					}
				}
				else if(IsCOSModel(vehicleid))
				{
					if(PlayerInfo[playerid][pFamed] < 2)
					{
					    new Float:slx, Float:sly, Float:slz;
						GetPlayerPos(playerid, slx, sly, slz);
						SetPlayerPos(playerid, slx, sly, slz+1.3);
						PlayerPlaySound(playerid, 1130, slx, sly, slz+1.3);
					    RemovePlayerFromVehicle(playerid);
					    defer NOPCheck(playerid);
					    SendClientMessageEx(playerid, COLOR_GRAD2, "Day la xe Chartered Old-School, ban khong the su dung chiec xe nay.");
					}
				}
				else if(IsFamedModel(vehicleid))
				{
				    if(PlayerInfo[playerid][pFamed] < 3)
				    {
				        new Float:slx, Float:sly, Float:slz;
						GetPlayerPos(playerid, slx, sly, slz);
						SetPlayerPos(playerid, slx, sly, slz+1.3);
						PlayerPlaySound(playerid, 1130, slx, sly, slz+1.3);
					    RemovePlayerFromVehicle(playerid);
					    defer NOPCheck(playerid);
					    SendClientMessageEx(playerid, COLOR_GRAD2, "Day la xe Famed, ban khong the su dung chiec xe nay.");
					}
				}
			}
		}
		else if(IsAPizzaCar(vehicleid))
		{
		    if(PlayerInfo[playerid][pJob] != 21 && PlayerInfo[playerid][pJob2] != 21)
		    {
			    new Float:slx, Float:sly, Float:slz;
				GetPlayerPos(playerid, slx, sly, slz);
				SetPlayerPos(playerid, slx, sly, slz+1.3);
				PlayerPlaySound(playerid, 1130, slx, sly, slz+1.3);
			    RemovePlayerFromVehicle(playerid);
			    defer NOPCheck(playerid);
			    SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong phai pizza!");
			}
		}

		else if(IsATruckerCar(vehicleid))
		{
		    if((PlayerInfo[playerid][pJob] == 20 || PlayerInfo[playerid][pJob2] == 20))
			{
				new string[128];
				new iTruckContents = TruckContents{vehicleid};
				new truckcontentname[50];
				if(iTruckContents == 1)
				{ format(truckcontentname, sizeof(truckcontentname), "{00F70C}Thuc pham & Do uong");}
				else if(iTruckContents == 2)
				{ format(truckcontentname, sizeof(truckcontentname), "{00F70C}Quan ao"); }
				else if(iTruckContents == 3)
				{ format(truckcontentname, sizeof(truckcontentname), "{00F70C}Vat lieu hop phap"); }
				else if(iTruckContents == 4)
				{ format(truckcontentname, sizeof(truckcontentname), "{00F70C}Vat pham 24/7"); }
				else if(iTruckContents == 5)
				{ format(truckcontentname, sizeof(truckcontentname), "{FF0606}Vu khi khong hop phap"); }
				else if(iTruckContents == 6)
				{ format(truckcontentname, sizeof(truckcontentname), "{FF0606}Ma tuy"); }
				else if(iTruckContents == 7)
				{ format(truckcontentname, sizeof(truckcontentname), "{FF0606}Vat lieu khong hop phap"); }
				if(iTruckContents == 0)
				{ format(truckcontentname, sizeof(truckcontentname), "%s",  GetInventoryType(TruckDeliveringTo[vehicleid])); }
				format(string, sizeof(string), "SHIPMENT CONTRACTOR: (Dang ky xe: %s %d) - (Noi dung: %s{FFFF00})", GetVehicleName(vehicleid), vehicleid, truckcontentname);
				SendClientMessageEx(playerid, COLOR_YELLOW, string);

				if(IsACop(playerid))
				{
					SendClientMessageEx(playerid, COLOR_DBLUE, "LAW ENFORCEMENT: De loai bo bat ki hang hoa khong hop phap nao,su dung /clearcargo de dua no ra khoi xe.");
				}
				if(TruckDeliveringTo[vehicleid] != INVALID_BUSINESS_ID && TruckUsed[playerid] == INVALID_VEHICLE_ID)
				{
					SendClientMessageEx(playerid, COLOR_YELLOW, "SHIPMENT CONTRACTOR JOB: De cung cap cac  hang hoa,su dung /hijackcargo cho tai xe.");
				}
				else if(TruckUsed[playerid] == INVALID_VEHICLE_ID)
				{
    				SendClientMessageEx(playerid, COLOR_YELLOW, "SHIPMENT CONTRACTOR JOB: De co duoc hang hoa,su dung /loadshipment cho tai xe.");
				}
				else if(TruckUsed[playerid] == vehicleid && gPlayerCheckpointStatus[playerid] == CHECKPOINT_RETURNTRUCK)
				{
					SendClientMessageEx(playerid, COLOR_YELLOW, "SHIPMENT CONTRACTOR JOB: Day la chuyen hang cua ban,ban khong co luong vi chua tra lai cho ben cang.");
				}
				else if(TruckUsed[playerid] == vehicleid)
   				{
      				SendClientMessageEx(playerid, COLOR_YELLOW, "SHIPMENT CONTRACTOR JOB: Day la chuyen hang cua ban,ban chua cung cap hang hoa.");
     			}
				else if(TruckUsed[playerid] != INVALID_VEHICLE_ID)
   				{
      				SendClientMessageEx(playerid, COLOR_YELLOW, "SHIPMENT CONTRACTOR JOB: Ban co chuyen hang khac can van chuyen, su dung /huybo shipment de huy bo giao chuyen hang nay.");
     			}
			}
		    else if(!IsABoat(vehicleid))
			{
			    RemovePlayerFromVehicle(playerid);
			    new Float:slx, Float:sly, Float:slz;
				GetPlayerPos(playerid, slx, sly, slz);
				SetPlayerPos(playerid, slx, sly, slz);
			    defer NOPCheck(playerid);
			    SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong phai la nha thau lo hang!");
			}
		}
	   	else if(IsAPlane(vehicleid))
		{
	  		if(PlayerInfo[playerid][pFlyLic] != 1)
	  		{
		  		RemovePlayerFromVehicle(playerid);
		  		new Float:slx, Float:sly, Float:slz;
				GetPlayerPos(playerid, slx, sly, slz);
				SetPlayerPos(playerid, slx, sly, slz);
		  		defer NOPCheck(playerid);
			 	SendClientMessageEx(playerid,COLOR_GREY,"Ban khong co giay phep thi cong!");
	  		}
		}
		else if(IsAHelicopter(vehicleid))
		{
		    PlayerInfo[playerid][pAGuns][GetWeaponSlot(46)] = 46;
			GivePlayerValidWeapon(playerid, 46, 60000);
		}
		else if(IsAnTaxi(vehicleid) || IsAnBus(vehicleid))
		{
	        if(PlayerInfo[playerid][pJob] == 17 || PlayerInfo[playerid][pJob2] == 17 || IsATaxiDriver(playerid) || PlayerInfo[playerid][pTaxiLicense] == 1)
			{
			}
		    else
			{
		        SendClientMessageEx(playerid,COLOR_GREY,"   Ban khong phai nhan vien Taxi/Bus!");
		        RemovePlayerFromVehicle(playerid);
		        new Float:slx, Float:sly, Float:slz;
				GetPlayerPos(playerid, slx, sly, slz);
				SetPlayerPos(playerid, slx, sly, slz);
		    }
		}
		else if(IsASpawnedTrain(vehicleid))
		{
	        if((0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) && (arrGroupData[PlayerInfo[playerid][pMember]][g_iGroupType] == 7 || arrGroupData[PlayerInfo[playerid][pLeader]][g_iGroupType] == 7))
			{
			}
		    else
			{
		        SendClientMessageEx(playerid,COLOR_GREY,"   Ban khong thuoc bo phan van chuyen!");
		        RemovePlayerFromVehicle(playerid);
		        new Float:slx, Float:sly, Float:slz;
				GetPlayerPos(playerid, slx, sly, slz);
				SetPlayerPos(playerid, slx, sly, slz);
		    }
		}
	}
	else if(!IsPlayerInRangeOfVehicle(playerid, vehicleid, 7.5) || LockStatus{vehicleid} >= 1) { // G-bugging fix
		ClearAnimations(playerid);
	}

	return 1;
}

public OnPlayerConnect(playerid) {
	if(IsPlayerNPC(playerid)) return 1;
	
	g_arrQueryHandle{playerid} = random(256);

	TotalConnect++;
	if(Iter_Count(Player) > MaxPlayersConnected) {
		MaxPlayersConnected = Iter_Count(Player);
		getdate(MPYear,MPMonth,MPDay);
	}

	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 1);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 1);

	SetPVarInt(playerid, "IsInArena", -1);
	SetPVarInt(playerid, "ArenaNumber", -1);
	SetPVarInt(playerid, "ArenaEnterPass", -1);
	SetPVarInt(playerid, "ArenaEnterTeam", -1);
	SetPVarInt(playerid, "EditingTurfs", -1);
	SetPVarInt(playerid, "EditingTurfsStage", -1);
	SetPVarInt(playerid, "EditingHillStage", -1);
	SetPVarInt(playerid, "EditingFamC", -1);
	SetPVarInt(playerid, "editingfamhq", INVALID_FAMILY_ID);
	SetPVarInt(playerid, "UsingSurfAttachedObject", -1);
	SetPVarInt(playerid, "UsingBriefAttachedObject", -1);
	SetPVarInt(playerid, "AOSlotPaintballFlag", -1);
	SetPVarInt(playerid, "MovingStretcher", -1);
	SetPVarInt(playerid, "DraggingPlayer", INVALID_PLAYER_ID);
	SetPVarInt(playerid, "ttSeller", INVALID_PLAYER_ID);
	SetPVarInt(playerid, "ttBuyer", INVALID_PLAYER_ID);
	SetPVarInt(playerid, "ttCost", 0);
	SetPVarInt(playerid, "buyingVoucher", INVALID_PLAYER_ID);
	SetPVarInt(playerid, "sellerVoucher", INVALID_PLAYER_ID);
	SetPVarInt(playerid, "buyerVoucher", INVALID_PLAYER_ID);
	DeletePVar(playerid, "BeingDragged");
	DeletePVar(playerid, "PlayerCuffed");
	DeletePVar(playerid, "COMMUNITY_ADVISOR_REQUEST");
	
	HackingMods[playerid] = 0;
	pSpeed[playerid] = 0.0;
	//SetTimerEx("HackingTimer", 1000, false, "i", playerid);

	for(new i = 0; i < 3; i++) {
		StopaniFloats[playerid][i] = 0;
	}

	for(new i = 0; i < 3; i++) {
        ConfigEventCPs[playerid][i] = 0;
    }
    ConfigEventCPId[playerid] = 0;
    RCPIdCurrent[playerid] = 0;

	for(new i = 0; i < 6; i++) {
	    EventFloats[playerid][i] = 0.0;
	}
	EventLastInt[playerid] = 0; EventLastVW[playerid] = 0;

	for(new i = 0; i < 6; i++) {
		HHcheckFloats[playerid][i] = 0;
	}

	for(new i = 0; i < MAX_PLAYERVEHICLES; ++i) {
		PlayerVehicleInfo[playerid][i][pvModelId] = 0;
		PlayerVehicleInfo[playerid][i][pvId] = INVALID_PLAYER_VEHICLE_ID;
		PlayerVehicleInfo[playerid][i][pvSpawned] = 0;
		PlayerVehicleInfo[playerid][i][pvSlotId] = 0;
	}
	
	for(new i = 0; i < MAX_PLAYERTOYS; i++) {
		PlayerToyInfo[playerid][i][ptID] = -1;
		PlayerToyInfo[playerid][i][ptModelID] = 0;
		PlayerToyInfo[playerid][i][ptBone] = 0;
		PlayerToyInfo[playerid][i][ptSpecial] = 0;
	}

	for(new i = 0; i < 11; i++) {
		PlayerHoldingObject[playerid][i] = 0;
	}

	for(new i = 0; i < 5; i++) {
		LottoNumbers[playerid][i] = 0;
	}

	for(new i = 0; i < MAX_BUSINESSSALES; i++) {
        Selected[playerid][i] = 0;
	}
	for(new x=0; x < mS_SELECTION_ITEMS; x++) {
        gSelectionItems[playerid][x] = PlayerText:INVALID_TEXT_DRAW;
	}

	gHeaderTextDrawId[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gBackgroundTextDrawId[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gCurrentPageTextDrawId[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gNextButtonTextDrawId[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gPrevButtonTextDrawId[playerid] = PlayerText:INVALID_TEXT_DRAW;
    gCancelButtonTextDrawId[playerid] = PlayerText:INVALID_TEXT_DRAW;

    SpoofKill[playerid] = 0;
	KillTime[playerid] = 0;
	gItemAt[playerid] = 0;
	TruckUsed[playerid] = INVALID_VEHICLE_ID;
	pDrunkLevelLast[playerid] = 0;
    pFPS[playerid] = 0;
	BackupClearTimer[playerid] = 0;
	Backup[playerid] = 0;
    CarRadars[playerid] = 0;
    CurrentArmor[playerid] = 0.0;
	PlayerInfo[playerid][pReg] = 0;
	HHcheckVW[playerid] = 0;
	HHcheckInt[playerid] = 0;
	OrderAssignedTo[playerid] = INVALID_PLAYER_ID;
	TruckUsed[playerid] = INVALID_VEHICLE_ID;
	HouseOffer[playerid] = INVALID_PLAYER_ID;
	House[playerid] = 0;
	HousePrice[playerid] = 0;
	playerTabbed[playerid] = 0;
	playerAFK[playerid] = 0;
	gBug{playerid} = 1;
	TazerTimeout[playerid] = 0;
	gRadio{playerid} = 1;
	playerLastTyped[playerid] = 0;
	pTazer{playerid} = 0;
	pTazerReplace{playerid} = 0;
	pCurrentWeapon{playerid} = 0;
	MedicAccepted[playerid] = INVALID_PLAYER_ID;
	DefendOffer[playerid] = INVALID_PLAYER_ID;
	AppealOffer[playerid] = INVALID_PLAYER_ID;
	AppealOfferAccepted[playerid] = 0;
	PlayerInfo[playerid][pWantedLevel] = 0;
	DefendPrice[playerid] = 0;
	Spectating[playerid] = 0;
	GettingSpectated[playerid] = INVALID_PLAYER_ID;
	PlayerInfo[playerid][pPhonePrivacy] = 0;
	NewbieTimer[playerid] = 0;
	HlKickTimer[playerid] = 0;
	HelperTimer[playerid] = 0;
	VehicleOffer[playerid] = INVALID_PLAYER_ID;
	VehiclePrice[playerid] = 0;
	VehicleId[playerid] = -1;
	NOPTrigger[playerid] = 0;
	JustReported[playerid] = -1;
	UsedCrack[playerid] = 0;
	UsedWeed[playerid] = 0;
	SexOffer[playerid] = INVALID_PLAYER_ID;
	DrinkOffer[playerid] =  INVALID_PLAYER_ID;
	PotOffer[playerid] = INVALID_PLAYER_ID;
	PotStorageID[playerid] = -1;
	CrackOffer[playerid] = INVALID_PLAYER_ID;
	CrackStorageID[playerid] = -1;
	GunOffer[playerid] = INVALID_PLAYER_ID;
	GunStorageID[playerid] = -1;
	CraftOffer[playerid] = INVALID_PLAYER_ID;
	RepairOffer[playerid] = INVALID_PLAYER_ID;
	GuardOffer[playerid] = INVALID_PLAYER_ID;
	LiveOffer[playerid] = INVALID_PLAYER_ID;
	RefillOffer[playerid] = INVALID_PLAYER_ID;
	MatsOffer[playerid] = INVALID_PLAYER_ID;
	MatsStorageID[playerid] = -1;
	MatsPrice[playerid] = 0;
	MatsAmount[playerid] = 0;
	BoxOffer[playerid] = INVALID_PLAYER_ID;
	MarryWitnessOffer[playerid] = INVALID_PLAYER_ID;
	ProposeOffer[playerid] = INVALID_PLAYER_ID;
	DivorceOffer[playerid] = INVALID_PLAYER_ID;
	HidePM[playerid] = 0;
	PhoneOnline[playerid] = 0;
	unbanip[playerid][0] = 0;
    advisorchat[playerid] = 1;
	ChosenSkin[playerid]=0;
	SelectFChar[playerid]=0;
	MatsHolding[playerid]=0;
	MatDeliver[playerid]=0;
	MatDeliver2[playerid]=0;
	szAdvert[playerid][0] = 0;
	AdvertType[playerid] = 0;
	SelectFCharPlace[playerid]=0;
	GettingJob[playerid]=0;
	GettingJob2[playerid]=0;
	GuardOffer[playerid]= INVALID_PLAYER_ID;
	GuardPrice[playerid]=0;
	ApprovedLawyer[playerid]=0;
	CallLawyer[playerid]=0;
	WantLawyer[playerid]=0;
	CurrentMoney[playerid]=0;
	UsedFind[playerid]=0;
	CP[playerid]=0;
	Condom[playerid]=0;
	SexOffer[playerid]= INVALID_PLAYER_ID;
	SexPrice[playerid]=0;
	PlayerInfo[playerid][pAdmin]=0;
	RepairOffer[playerid]= INVALID_PLAYER_ID;
	RepairPrice[playerid]=0;
	RepairCar[playerid]=0;
	TalkingLive[playerid]=INVALID_PLAYER_ID;
	LiveOffer[playerid]= INVALID_PLAYER_ID;
	RefillOffer[playerid]= INVALID_PLAYER_ID;
	RefillPrice[playerid]=0;
	InsidePlane[playerid]=INVALID_VEHICLE_ID;
	InsideMainMenu{playerid}=0;
	InsideTut{playerid}=0;
	PotOffer[playerid]= INVALID_PLAYER_ID;
	PotStorageID[playerid]=-1;
	CrackOffer[playerid]= INVALID_PLAYER_ID;
	CrackStorageID[playerid]=-1;
	PlayerCuffed[playerid]=0;
	PlayerCuffedTime[playerid]=0;
	PotPrice[playerid]=0;
	CrackPrice[playerid]=0;
	RegistrationStep[playerid]=0;
	PotGram[playerid]=0;
	CrackGram[playerid]=0;
	PlayerInfo[playerid][pBanned]=0;
	ConnectedToPC[playerid]=0;
	OrderReady[playerid]=0;
	GunId[playerid]=0;
	GunMats[playerid]=0;
	CraftId[playerid]=0;
	CraftMats[playerid]=0;
	HitOffer[playerid]= INVALID_PLAYER_ID;
	HitToGet[playerid]= INVALID_PLAYER_ID;
	InviteOffer[playerid]= INVALID_PLAYER_ID;
	InviteFamily[playerid]=INVALID_FAMILY_ID;
	hInviteHouse[playerid]=INVALID_HOUSE_ID;
	hInviteOffer[playerid]= INVALID_PLAYER_ID;
	hInviteOfferTo[playerid]= INVALID_PLAYER_ID;
	JailPrice[playerid]=0;
	GotHit[playerid]=0;
	GoChase[playerid]= INVALID_PLAYER_ID;
	GetChased[playerid]= INVALID_PLAYER_ID;
	CalledCops[playerid]=0;
	CopsCallTime[playerid]=0;
	BoxWaitTime[playerid]=0;
	CalledMedics[playerid]=0;
	TransportDuty[playerid]=0;
	PlayerTied[playerid]=0;
	MedicsCallTime[playerid]=0;
	BusCallTime[playerid]=0;
	TaxiCallTime[playerid]=0;
	EMSCallTime[playerid]=0;
	MedicCallTime[playerid]=0;
	MechanicCallTime[playerid]=0;
	FindTimePoints[playerid]=0;
	FindingPlayer[playerid]=-1;
	FindTime[playerid]=0;
	JobDuty[playerid]=0;
	Mobile[playerid]=INVALID_PLAYER_ID;
	Music[playerid]=0;
	BoxOffer[playerid]= INVALID_PLAYER_ID;
	PlayerBoxing[playerid]=0;
	Spectate[playerid]= INVALID_PLAYER_ID;
	PlayerDrunk[playerid]=0;
	PlayerDrunkTime[playerid]=0;
	format(PlayerInfo[playerid][pPrisonReason],128,"None");
	FishCount[playerid]=0;
	HelpingNewbie[playerid]= INVALID_PLAYER_ID;
	turfWarsRadar[playerid]=0;
	courtjail[playerid]=0;
	gLastCar[playerid]=0;
	FirstSpawn[playerid]=0;
	JetPack[playerid]=0;
	PlayerInfo[playerid][pKills]=0;
	PlayerInfo[playerid][pPaintTeam]=0;
	TextSpamTimes[playerid] = 0;
	TextSpamUnmute[playerid] = 0;
 	CommandSpamTimes[playerid] = 0;
	CommandSpamUnmute[playerid] = 0;
	gOoc[playerid] = 0;
	arr_Towing[playerid] = INVALID_VEHICLE_ID;
	gNews[playerid] = 0;
	gNewbie[playerid] = 1;
	gHelp[playerid] = 1;
	gFam[playerid] = 0;
	gPlayerLogged{playerid} = 0;
	gPlayerLogTries[playerid] = 0;
	IsSpawned[playerid] = 0;
	SpawnKick[playerid] = 0;	
	PlayerStoned[playerid] = 0;
	PlayerInfo[playerid][pPot] = 0;
	StartTime[playerid] = 0;
	TicketOffer[playerid] = INVALID_PLAYER_ID;
	TicketMoney[playerid] = 0;
	PlayerInfo[playerid][pVehicleKeysFrom] = INVALID_PLAYER_ID;
	ActiveChatbox[playerid] = 1;
	TutStep[playerid] = 0;
	PlayerInfo[playerid][pVehicleKeys] = INVALID_PLAYER_VEHICLE_ID;
	TaxiAccepted[playerid] = INVALID_PLAYER_ID;
	EMSAccepted[playerid] = INVALID_PLAYER_ID;
	BusAccepted[playerid] = INVALID_PLAYER_ID;
	PlayerInfo[playerid][pCrack] = 0;
	HireCar[playerid] = 299;
	TransportValue[playerid] = 0;
	TransportMoney[playerid] = 0;
	TransportTime[playerid] = 0;
	TransportCost[playerid] = 0;
	TransportDriver[playerid] = INVALID_PLAYER_ID;
	Locator[playerid] = 0;
	ReleasingMenu[playerid] = INVALID_PLAYER_ID;
	Fishes[playerid][pLastFish] = 0;
	Fishes[playerid][pFishID] = 0;
	ProposeOffer[playerid] = INVALID_PLAYER_ID;
	MarryWitness[playerid] = INVALID_PLAYER_ID;
	MarryWitnessOffer[playerid] = INVALID_PLAYER_ID;
	MarriageCeremoney[playerid] = 0;
	ProposedTo[playerid] = INVALID_PLAYER_ID;
	GotProposedBy[playerid] = INVALID_PLAYER_ID;
	DivorceOffer[playerid] = INVALID_PLAYER_ID;
	gBike[playerid] = 0;
	gBikeRenting[playerid] = 0;
	Fixr[playerid] = 0;
	VehicleSpawned[playerid] = 0;
	ReportCount[playerid] = 0;
	ReportHourCount[playerid] = 0;
	PlayerInfo[playerid][pServiceTime] = 0;
	Homes[playerid] = 0;
	sobeitCheckvar[playerid] = 0;
	sobeitCheckIsDone[playerid] = 0;
	IsPlayerFrozen[playerid] = 0;
	strdel(PlayerInfo[playerid][pAutoTextReply], 0, 64);
	rBigEarT[playerid] = 0;
	aLastShot[playerid] = INVALID_PLAYER_ID;	
	if(IsValidDynamic3DTextLabel(RFLTeamN3D[playerid])) {
		DestroyDynamic3DTextLabel(RFLTeamN3D[playerid]);
	}

	// These need to be reset to prevent some bugs (DO NOT REMOVE)
	PlayerInfo[playerid][pModel] = 0;
	PlayerInfo[playerid][pLeader] = INVALID_GROUP_ID;
	PlayerInfo[playerid][pMember] = INVALID_GROUP_ID;
	PlayerInfo[playerid][pDivision] = INVALID_DIVISION;
	PlayerInfo[playerid][pFMember] = INVALID_FAMILY_ID;
	PlayerInfo[playerid][pRank] = INVALID_RANK;
	PlayerInfo[playerid][pOrder] = 0;
	PlayerInfo[playerid][pOrderConfirmed] = 0;
	PlayerInfo[playerid][pBusiness] = INVALID_BUSINESS_ID;
	acstruct[playerid][LastOnFootPosition][0] = 0.0; acstruct[playerid][LastOnFootPosition][1] = 0.0; acstruct[playerid][LastOnFootPosition][2] = 0.0;
	acstruct[playerid][checkmaptp] = 0; acstruct[playerid][maptplastclick] = 0;
	acstruct[playerid][maptp][0] = 0.0; acstruct[playerid][maptp][1] = 0.0; acstruct[playerid][maptp][2] = 0.0;

	for(new x = 0; x < MAX_PLAYERS; x++)
	{
	    ShotPlayer[playerid][x] = 0;
	}

	for(new v = 0; v < MAX_PLAYERVEHICLES; v++) {
		PlayerVehicleInfo[playerid][v][pvAllowedPlayerId] = INVALID_PLAYER_ID;
	}

	for(new s = 0; s < 12; s++) {
		PlayerInfo[playerid][pAGuns][s] = 0;
		PlayerInfo[playerid][pGuns][s] = 0;
	}

	for(new s = 0; s < 40; s++) {
		ListItemReportId[playerid][s] = -1;
	}

	for(new s = 0; s < 20; s++) {
		ListItemRCPId[playerid][s] = -1;
	}

	CancelReport[playerid] = -1;
	GiveKeysTo[playerid] = INVALID_PLAYER_ID;
	RocketExplosions[playerid] = -1;
	ClearFishes(playerid);
	ClearMarriage(playerid);

	// Crash Fix - GhoulSlayeR
	if(!InvalidNameCheck(playerid)) {
		return 1;
	}
	
	CheckAdminWhitelist(playerid);
	CheckBanEx(playerid);
	
	/*new string[128], serial[64];
	gpci(playerid, serial, sizeof(serial));
	format(string, sizeof(string), "%s/checks/gpci.php?g=%s&n=%s&i=%s", SAMP_WEB, serial, GetPlayerNameExt(playerid), GetPlayerIpEx(playerid));
	HTTP(0, HTTP_HEAD, string, "", "");*/

	// Main Menu Features
	InsideMainMenu{playerid} = 0;
	InsideTut{playerid} = 0;

	//TogglePlayerSpectating(playerid, true);
	ShowMainMenuGUI(playerid);
	SetPlayerJoinCamera(playerid);
	ClearChatbox(playerid);
	SetPlayerVirtualWorld(playerid, 0);

	SetPlayerColor(playerid,TEAM_HIT_COLOR);
	SendClientMessage( playerid, COLOR_WHITE, "SERVER: Chao mung ban tham gia Grand Theft Auto � Viet Nam Community." );

	SyncPlayerTime(playerid);

	ShowNoticeGUIFrame(playerid, 1);
	
	logincheck[playerid] = SetTimerEx("LoginCheck", 120000, false, "i", playerid);
	
	SetTimerEx("LoginCheckEx", 5000, false, "i", playerid);

	//RemoveBuildings(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(!isnull(unbanip[playerid]))
	{
	    new string[26];
	    format(string, sizeof(string), "unbanip %s", unbanip[playerid]);
	    SendRconCommand(string);
	}
	KillTimer(logincheck[playerid]);
	foreach(new i: Player) {
		if(Spectating[i] > 0 && Spectate[i] == playerid) {
			SetPVarInt(i, "SpecOff", 1);
			Spectating[i] = 0;
			Spectate[i] = INVALID_PLAYER_ID;
			GettingSpectated[playerid] = INVALID_PLAYER_ID;
			TogglePlayerSpectating(i, false);
			SendClientMessageEx(i, COLOR_WHITE, "Nguoi choi ban dang theo doi da thoat khoi may chu.");
		}
		if(GetPVarType(i, "_dCheck") && GetPVarInt(i, "_dCheck") == playerid) {
			DeletePVar(i, "_dCheck");
			SendClientMessageEx(i, COLOR_WHITE, "Nguoi choi ban dang kiem tra da thoat khoi may chu.");
		}	
	}		
	// Why save on people who haven't logged in!
	if(gPlayerLogged{playerid} == 1)
	{
		g_mysql_RemoveDumpFile(GetPlayerSQLId(playerid));

		if(HungerPlayerInfo[playerid][hgInEvent] == 1)
		{
			if(hgActive == 2)
			{
				if(hgPlayerCount == 3)
				{
					new szmessage[128];
					format(szmessage, sizeof(szmessage), "** %s da dung thu ba trong su kien Hunger Games.", GetPlayerNameEx(playerid));
					SendClientMessageToAll(COLOR_LIGHTBLUE, szmessage);
						
					SetPlayerHealth(playerid, HungerPlayerInfo[playerid][hgLastHealth]);
					SetPlayerArmor(playerid, HungerPlayerInfo[playerid][hgLastArmour]);
					SetPlayerVirtualWorld(playerid, HungerPlayerInfo[playerid][hgLastVW]);
					SetPlayerInterior(playerid, HungerPlayerInfo[playerid][hgLastInt]);
					SetPlayerPos(playerid, HungerPlayerInfo[playerid][hgLastPosition][0], HungerPlayerInfo[playerid][hgLastPosition][1], HungerPlayerInfo[playerid][hgLastPosition][2]);
							
					ResetPlayerWeapons(playerid);
						
					HungerPlayerInfo[playerid][hgInEvent] = 0;
					hgPlayerCount--;
					HideHungerGamesTextdraw(playerid);
					PlayerInfo[playerid][pRewardDrawChance] += 10;
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "** Ban da nhan 10 Draw Chances trong su kien Fall Into Fun.");
					
					for(new w = 0; w < 12; w++)
					{
						PlayerInfo[playerid][pGuns][w] = HungerPlayerInfo[playerid][hgLastWeapon][w];
						if(PlayerInfo[playerid][pGuns][w] > 0 && PlayerInfo[playerid][pAGuns][w] == 0)
						{
							GivePlayerValidWeapon(playerid, PlayerInfo[playerid][pGuns][w], 60000);
						}
					}
				}
				else if(hgPlayerCount == 2)
				{
					new szmessage[128];
					format(szmessage, sizeof(szmessage), "** %s da dung thu hai trong su kien Hunger Games.", GetPlayerNameEx(playerid));
					SendClientMessageToAll(COLOR_LIGHTBLUE, szmessage);
						
					SetPlayerHealth(playerid, HungerPlayerInfo[playerid][hgLastHealth]);
					SetPlayerArmor(playerid, HungerPlayerInfo[playerid][hgLastArmour]);
					SetPlayerVirtualWorld(playerid, HungerPlayerInfo[playerid][hgLastVW]);
					SetPlayerInterior(playerid, HungerPlayerInfo[playerid][hgLastInt]);
					SetPlayerPos(playerid, HungerPlayerInfo[playerid][hgLastPosition][0], HungerPlayerInfo[playerid][hgLastPosition][1], HungerPlayerInfo[playerid][hgLastPosition][2]);
							
					ResetPlayerWeapons(playerid);
						
					HungerPlayerInfo[playerid][hgInEvent] = 0;
					hgPlayerCount--;
					HideHungerGamesTextdraw(playerid);
					PlayerInfo[playerid][pRewardDrawChance] += 25;
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "** Ban nhan duoc 25 Draw Chances trong su kien Fall Into Fun.");
					
					for(new w = 0; w < 12; w++)
					{
						PlayerInfo[playerid][pGuns][w] = HungerPlayerInfo[playerid][hgLastWeapon][w];
						if(PlayerInfo[playerid][pGuns][w] > 0 && PlayerInfo[playerid][pAGuns][w] == 0)
						{
							GivePlayerValidWeapon(playerid, PlayerInfo[playerid][pGuns][w], 60000);
						}
					}
						
					for(new i = 0; i < MAX_PLAYERS; i++)
					{
						if(HungerPlayerInfo[i][hgInEvent] == 1)
						{
							format(szmessage, sizeof(szmessage), "** %s da dung vi tri dau tien trong su kien Hunger Games.", GetPlayerNameEx(i));
							SendClientMessageToAll(COLOR_LIGHTBLUE, szmessage);
								
							SetPlayerHealth(i, HungerPlayerInfo[i][hgLastHealth]);
							SetPlayerArmor(i, HungerPlayerInfo[i][hgLastArmour]);
							SetPlayerVirtualWorld(i, HungerPlayerInfo[i][hgLastVW]);
							SetPlayerInterior(i, HungerPlayerInfo[i][hgLastInt]);
							SetPlayerPos(i, HungerPlayerInfo[i][hgLastPosition][0], HungerPlayerInfo[i][hgLastPosition][1], HungerPlayerInfo[i][hgLastPosition][2]);
									
							ResetPlayerWeapons(i);
								
							HungerPlayerInfo[i][hgInEvent] = 0;
							hgPlayerCount--;
							HideHungerGamesTextdraw(i);
							PlayerInfo[i][pRewardDrawChance] += 50;
							SendClientMessageEx(i, COLOR_LIGHTBLUE, "** Ban nhan duoc 50 Draw Chances trong su kien Fall Into Fun.");
							hgActive = 0;
							
							for(new w = 0; w < 12; w++)
							{
								PlayerInfo[i][pGuns][w] = HungerPlayerInfo[i][hgLastWeapon][w];
								if(PlayerInfo[i][pGuns][w] > 0 && PlayerInfo[i][pAGuns][w] == 0)
								{
									GivePlayerValidWeapon(i, PlayerInfo[i][pGuns][w], 60000);
								}
							}
						}
					}
					
					for(new i = 0; i < 600; i++)
					{
						if(IsValidDynamic3DTextLabel(HungerBackpackInfo[i][hgBackpack3DText]))
						{
							DestroyDynamic3DTextLabel(HungerBackpackInfo[i][hgBackpack3DText]);
						}
						if(IsValidDynamicPickup(HungerBackpackInfo[i][hgBackpackPickupId]))
						{
							DestroyDynamicPickup(HungerBackpackInfo[i][hgBackpackPickupId]);
						}
						
						HungerBackpackInfo[i][hgActiveEx] = 0;
					}
				}
				else if(hgPlayerCount > 3)
				{
					SetPlayerHealth(playerid, HungerPlayerInfo[playerid][hgLastHealth]);
					SetPlayerArmor(playerid, HungerPlayerInfo[playerid][hgLastArmour]);
					SetPlayerVirtualWorld(playerid, HungerPlayerInfo[playerid][hgLastVW]);
					SetPlayerInterior(playerid, HungerPlayerInfo[playerid][hgLastInt]);
					SetPlayerPos(playerid, HungerPlayerInfo[playerid][hgLastPosition][0], HungerPlayerInfo[playerid][hgLastPosition][1], HungerPlayerInfo[playerid][hgLastPosition][2]);
							
					ResetPlayerWeapons(playerid);
						
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da bi chet trong su kien Hunger Games, chuc may man trong su kien sau.");
						
					HungerPlayerInfo[playerid][hgInEvent] = 0;
					hgPlayerCount--;
						
					HideHungerGamesTextdraw(playerid);
					
					for(new w = 0; w < 12; w++)
					{
						PlayerInfo[playerid][pGuns][w] = HungerPlayerInfo[playerid][hgLastWeapon][w];
						if(PlayerInfo[playerid][pGuns][w] > 0 && PlayerInfo[playerid][pAGuns][w] == 0)
						{
							GivePlayerValidWeapon(playerid, PlayerInfo[playerid][pGuns][w], 60000);
						}
					}
				}
				
				new string[128];
				format(string, sizeof(string), "Nguoi choi trong su kien: %d", hgPlayerCount);
				for(new i = 0; i < MAX_PLAYERS; i++)
				{
					PlayerTextDrawSetString(i, HungerPlayerInfo[i][hgPlayerText], string);
				}
							
				return true;
			}
		}
		if (GetPVarInt(playerid, "_BikeParkourStage") > 0)
		{
			new slot = GetPVarInt(playerid, "_BikeParkourSlot");
			new biz = InBusiness(playerid);

			DestroyDynamicPickup(GetPVarInt(playerid, "_BikeParkourPickup"));

			Businesses[biz][bGymBikePlayers][slot] = INVALID_PLAYER_ID;

			if (GetPVarInt(playerid, "_BikeParkourStage") > 1)
			{
				DestroyVehicle(Businesses[biz][bGymBikeVehicles][slot]);
				Businesses[biz][bGymBikeVehicles][slot] = INVALID_VEHICLE_ID;
			}
		}
		if(GetPVarType(playerid, "Gas_TrailerID"))
		{
		    if(GetVehicleModel(GetPVarInt(playerid, "Gas_TrailerID")) == 584)
		    {
		        printf("Deleting Trailer. Veh ID %d Player %s", GetPVarInt(playerid, "Gas_TrailerID"), GetPlayerNameExt(playerid));
		        DestroyVehicle(GetPVarInt(playerid, "Gas_TrailerID"));
		    }
		}
		if (GetPVarType(playerid, "_BoxingFight"))
		{
			new fighterid = GetPVarInt(playerid, "_BoxingFight") - 1;
			DeletePVar(fighterid, "_BoxingFight");
			SendClientMessageEx(fighterid, COLOR_GREY, "Nguoi choi ban dang thi dau da roi khoi arena.");
			SetPVarInt(fighterid, "_BoxingFightOver", gettime() + 1);
			new biz = InBusiness(fighterid);

			if (Businesses[biz][bGymBoxingArena1][0] == fighterid || Businesses[biz][bGymBoxingArena1][1] == fighterid) // first arena
			{
				Businesses[biz][bGymBoxingArena1][0] = INVALID_PLAYER_ID;
				Businesses[biz][bGymBoxingArena1][1] = INVALID_PLAYER_ID;
			}
			else if (Businesses[biz][bGymBoxingArena2][0] == fighterid || Businesses[biz][bGymBoxingArena2][1] == fighterid) // second arena
			{
				Businesses[biz][bGymBoxingArena2][0] = INVALID_PLAYER_ID;
				Businesses[biz][bGymBoxingArena2][1] = INVALID_PLAYER_ID;
			}

			PlayerInfo[playerid][pPos_x] = 2913.2175;
			PlayerInfo[playerid][pPos_y] = -2288.1914;
			PlayerInfo[playerid][pPos_z] = 7.2543;
		}
		if(RocketExplosions[playerid] != -1)
		{
			DestroyDynamicObject(Rocket[playerid]);
			DestroyDynamicObject(RocketLight[playerid]);
			DestroyDynamicObject(RocketSmoke[playerid]);
		}

		if(GetPVarType(playerid, "pBoomBox"))
		{
		    DestroyDynamicObject(GetPVarInt(playerid, "pBoomBox"));
		    DestroyDynamic3DTextLabel(Text3D:GetPVarInt(playerid, "pBoomBoxLabel"));
		    if(GetPVarType(playerid, "pBoomBoxArea"))
		    {
		        new string[128];
				format(string, sizeof(string), "The boombox owner (%s) has logged off", GetPlayerNameEx(playerid));
		        foreach(new i: Player)
		        {
		            if(IsPlayerInDynamicArea(i, GetPVarInt(playerid, "pBoomBoxArea")))
		            {
		                StopAudioStreamForPlayerEx(i);
		                SendClientMessage(i, COLOR_PURPLE, string);
					}
				}
			}
		}
		#if defined zombiemode
		if(GetPVarType(playerid, "pZombieBit"))
		{
            MakeZombie(playerid);
		}
		#endif
		if(GetPVarType(playerid, "RentedVehicle")) {
		    DestroyVehicle(GetPVarInt(playerid, "RentedVehicle"));
		}
		if(GetPVarType(playerid, "pkrTableID")) {
			LeavePokerTable(playerid);
		}

		if(GetPVarType(playerid, "pTable")) {
		    DestroyPokerTable(GetPVarInt(playerid, "pTable"));
		}
		if(GetPVarInt(playerid, "DraggingPlayer") != INVALID_PLAYER_ID)
		{
            DeletePVar(GetPVarInt(playerid, "DraggingPlayer"), "BeingDragged");
		}
		if(pTazer{playerid} == 1) GivePlayerValidWeapon(playerid,pTazerReplace{playerid},60000);
		if(GetPVarInt(playerid, "SpeedRadar") == 1) GivePlayerValidWeapon(playerid, GetPVarInt(playerid, "RadarReplacement"), 60000);

		if(GetPVarInt(playerid, "MovingStretcher") != -1) {
			KillTimer(GetPVarInt(playerid, "TickEMSMove"));
		}

		if(GetPVarInt(playerid, "Injured") == 1) {
			PlayerInfo[playerid][pHospital] = 1;
			KillEMSQueue(playerid);
			ResetPlayerWeaponsEx(playerid);
		}
		if(GetPVarInt(playerid, "HeroinEffect")) {
			KillTimer(GetPVarInt(playerid, "HeroinEffect"));
			PlayerInfo[playerid][pHospital] = 1;
			KillEMSQueue(playerid);
			ResetPlayerWeaponsEx(playerid);
		}
		if(GetPVarInt(playerid, "AttemptPurify"))
		{
			Purification[0] = 0;
	    	KillTimer(GetPVarInt(playerid, "AttemptPurify"));
		}
		if(control[playerid] == 1) {
			control[playerid] = 0;
			KillTimer(ControlTimer[playerid]);
		}
		if(PlayerInfo[playerid][pLockCar] != INVALID_VEHICLE_ID) {
			vehicle_unlock_doors(PlayerInfo[playerid][pLockCar]);
			PlayerInfo[playerid][pLockCar] = INVALID_VEHICLE_ID;
		}

		if(PlayerInfo[playerid][pVehicleKeysFrom] != INVALID_PLAYER_ID) {
			PlayerVehicleInfo[PlayerInfo[playerid][pVehicleKeysFrom]][PlayerInfo[playerid][pVehicleKeys]][pvAllowedPlayerId] = INVALID_PLAYER_ID;
		}
		if(GetPVarInt(playerid, "ttSeller") != INVALID_PLAYER_ID) 
		{
			SendClientMessageEx(GetPVarInt(playerid, "ttSeller"), COLOR_GRAD2, "Nguoi mua da thoat ket noi voi may chu.");
			SetPVarInt(GetPVarInt(playerid, "ttSeller"), "ttBuyer", INVALID_PLAYER_ID);
			SetPVarInt(GetPVarInt(playerid, "ttSeller"), "ttCost", 0);
			SetPVarInt(playerid, "ttSeller", INVALID_PLAYER_ID);		
			HideTradeToysGUI(playerid);
		}
		if(GetPVarInt(playerid, "buyerVoucher") != INVALID_PLAYER_ID)
		{
			SetPVarInt(GetPVarInt(playerid, "buyerVoucher"), "sellerVoucher", INVALID_PLAYER_ID);
		}
		if(GetPVarInt(playerid, "sellerVoucher") != INVALID_PLAYER_ID)
		{
			SetPVarInt(GetPVarInt(playerid, "sellerVoucher"), "buyerVoucher", INVALID_PLAYER_ID);
		}
		if(HackingMods[playerid] > 0) { HackingMods[playerid] = 0; }
		
		if(gettime() >= PlayerInfo[playerid][pMechTime]) PlayerInfo[playerid][pMechTime] = 0;
		if(gettime() >= PlayerInfo[playerid][pLawyerTime]) PlayerInfo[playerid][pLawyerTime] = 0;
		if(gettime() >= PlayerInfo[playerid][pDrugsTime]) PlayerInfo[playerid][pDrugsTime] = 0;
		if(gettime() >= PlayerInfo[playerid][pSexTime]) PlayerInfo[playerid][pSexTime] = 0;
		
		for(new i = 0; i < MAX_PLAYERVEHICLES; ++i) {
			if(PlayerVehicleInfo[playerid][i][pvSpawned] == 1)
			{
				if(PlayerVehicleInfo[playerid][i][pvId] != INVALID_PLAYER_VEHICLE_ID && IsVehicleInTow(PlayerVehicleInfo[playerid][i][pvId]))
				{
					DetachTrailerFromVehicle(GetPlayerVehicleID(playerid));
					PlayerVehicleInfo[playerid][i][pvImpounded] = 1;
					PlayerVehicleInfo[playerid][i][pvSpawned] = 0;
					SetVehiclePos(PlayerVehicleInfo[playerid][i][pvId], 0, 0, 0); // Attempted desync fix
					DestroyVehicle(PlayerVehicleInfo[playerid][i][pvId]);
					PlayerVehicleInfo[playerid][i][pvId] = INVALID_PLAYER_VEHICLE_ID;
					g_mysql_SaveVehicle(playerid, i);
				}
			}
		}

		new string[128];
		switch(reason)
		{
			case 0:
			{
				if(PlayerInfo[playerid][pAdmin] >= 2 && Spectating[playerid] == 1)
				{
					PlayerInfo[playerid][pPos_x] = GetPVarFloat(playerid, "SpecPosX");
					PlayerInfo[playerid][pPos_y] = GetPVarFloat(playerid, "SpecPosY");
					PlayerInfo[playerid][pPos_z] = GetPVarFloat(playerid, "SpecPosZ");
					PlayerInfo[playerid][pInt] = GetPVarInt(playerid, "SpecInt");
					PlayerInfo[playerid][pVW] = GetPVarInt(playerid, "SpecVW");
					DeletePVar(playerid, "SpecOff");
					if(GetPVarType(playerid, "pGodMode"))
					{
						SetPlayerHealth(playerid, 0x7FB00000);
						SetPlayerArmor(playerid, 0x7FB00000);
					}
					GettingSpectated[Spectate[playerid]] = INVALID_PLAYER_ID;
					Spectate[playerid] = INVALID_PLAYER_ID;
				}
				else
				{
					format(string, sizeof(string), "%s da thoat khoi may chu (timeout).", GetPlayerNameEx(playerid));
					ProxDetector(30.0, playerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
				format(string, sizeof(string), "%s (ID: %d | SQL ID: %d | Level: %d | IP: %s) has timed out.", GetPlayerNameExt(playerid), playerid, GetPlayerSQLId(playerid), PlayerInfo[playerid][pLevel], PlayerInfo[playerid][pIP]);
				Log("logs/login.log", string);
				if(PlayerCuffed[playerid] != 0)
				{
					if(PlayerCuffed[playerid] == 2)
				    {
					    SetPlayerHealth(playerid, GetPVarFloat(playerid, "cuffhealth"));
	                    SetPlayerArmor(playerid, GetPVarFloat(playerid, "cuffarmor"));
	                    DeletePVar(playerid, "cuffhealth");
						DeletePVar(playerid, "PlayerCuffed");
					}
					strcpy(PlayerInfo[playerid][pPrisonReason], "[OOC] Roi khoi khi dang bi cong tay [Timeout]", 128);
					strcpy(PlayerInfo[playerid][pPrisonedBy], "System", 128);
					PlayerInfo[playerid][pJailTime] += 60*60;
				}
			}
			case 1:
			{
				if(PlayerInfo[playerid][pAdmin] >= 2 && Spectating[playerid] == 1)
				{
					PlayerInfo[playerid][pPos_x] = GetPVarFloat(playerid, "SpecPosX");
					PlayerInfo[playerid][pPos_y] = GetPVarFloat(playerid, "SpecPosY");
					PlayerInfo[playerid][pPos_z] = GetPVarFloat(playerid, "SpecPosZ");
					PlayerInfo[playerid][pInt] = GetPVarInt(playerid, "SpecInt");
					PlayerInfo[playerid][pVW] = GetPVarInt(playerid, "SpecVW");
					DeletePVar(playerid, "SpecOff");
					if(GetPVarType(playerid, "pGodMode"))
					{
						SetPlayerHealth(playerid, 0x7FB00000);
						SetPlayerArmor(playerid, 0x7FB00000);
					}
					GettingSpectated[Spectate[playerid]] = INVALID_PLAYER_ID;
					Spectate[playerid] = INVALID_PLAYER_ID;
				}
				else
				{
					format(string, sizeof(string), "%s da thoat khoi may chu (leaving).", GetPlayerNameEx(playerid));
					ProxDetector(30.0, playerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
				format(string, sizeof(string), "%s (ID: %d | SQL ID: %d | Level: %d | IP: %s) has disconnected.", GetPlayerNameExt(playerid), playerid, GetPlayerSQLId(playerid), PlayerInfo[playerid][pLevel], PlayerInfo[playerid][pIP]);
				Log("logs/login.log", string);
				if(PlayerCuffed[playerid] != 0)
				{
				    if(PlayerCuffed[playerid] == 2)
				    {
					    SetPlayerHealth(playerid, GetPVarFloat(playerid, "cuffhealth"));
	                    SetPlayerArmor(playerid, GetPVarFloat(playerid, "cuffarmor"));
	                    DeletePVar(playerid, "cuffhealth");
						DeletePVar(playerid, "PlayerCuffed");
					}
					strcpy(PlayerInfo[playerid][pPrisonReason], "[OOC] Roi khoi khi dang bi cong tay [Leaving]", 128);
					strcpy(PlayerInfo[playerid][pPrisonedBy], "System", 128);
					PlayerInfo[playerid][pJailTime] += 60*60;
					new szMessage[80+MAX_PLAYER_NAME];
					format(szMessage, sizeof(szMessage), "{AA3333}AdmWarning{FFFF00}: %s da thoat (/q) khoi may chu khi dang bi cong tay.", GetPlayerNameEx(playerid));
					ABroadCast(COLOR_YELLOW, szMessage, 2);
				}
			}
			case 2:
			{
				if(PlayerInfo[playerid][pAdmin] >= 2 && Spectating[playerid] == 1)
				{
					PlayerInfo[playerid][pPos_x] = GetPVarFloat(playerid, "SpecPosX");
					PlayerInfo[playerid][pPos_y] = GetPVarFloat(playerid, "SpecPosY");
					PlayerInfo[playerid][pPos_z] = GetPVarFloat(playerid, "SpecPosZ");
					PlayerInfo[playerid][pInt] = GetPVarInt(playerid, "SpecInt");
					PlayerInfo[playerid][pVW] = GetPVarInt(playerid, "SpecVW");
					DeletePVar(playerid, "SpecOff");
					if(GetPVarType(playerid, "pGodMode"))
					{
						SetPlayerHealth(playerid, 0x7FB00000);
						SetPlayerArmor(playerid, 0x7FB00000);
					}
					GettingSpectated[Spectate[playerid]] = INVALID_PLAYER_ID;
					Spectate[playerid] = INVALID_PLAYER_ID;
				}
				else
				{
					format(string, sizeof(string), "%s da thoat khoi may chu (kicked/banned).", GetPlayerNameEx(playerid));
					ProxDetector(30.0, playerid, string, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				}
				format(string, sizeof(string), "%s (ID: %d | SQL ID: %d | Level: %d | IP: %s) has been kicked/banned.", GetPlayerNameExt(playerid), playerid, GetPlayerSQLId(playerid), PlayerInfo[playerid][pLevel], PlayerInfo[playerid][pIP]);
				Log("logs/login.log", string);
			}
		}
		if(EventKernel[EventRequest] == playerid)
		{
			EventKernel[EventRequest] = INVALID_PLAYER_ID;
			ABroadCast( COLOR_YELLOW, "{AA3333}AdmWarning{FFFF00}: Nguoi choi gui yeu cau da bi disconneted/crashed.", 4 );
		}
		if(EventKernel[EventCreator] == playerid)
		{
			EventKernel[EventCreator] = INVALID_PLAYER_ID;
			ABroadCast( COLOR_YELLOW, "{AA3333}AdmWarning{FFFF00}: Nguoi choi tao event da bi disconneted/crashed.", 4 );
		}
		for(new x; x < sizeof(EventKernel[EventStaff]); x++) {
			if(EventKernel[EventStaff][x] == playerid) {
				EventKernel[EventStaff][x] = INVALID_PLAYER_ID;
				RemovePlayerWeaponEx(playerid, 38);
				break;
			}
		}
		if(GetPVarInt(playerid, "IsInArena") >= 0)
		{
			LeavePaintballArena(playerid, GetPVarInt(playerid, "IsInArena"));
			PlayerInfo[playerid][pInt] = GetPVarInt(playerid, "pbOldInt");
			PlayerInfo[playerid][pVW] = GetPVarInt(playerid, "pbOldVW");
			PlayerInfo[playerid][pPos_x] = GetPVarFloat(playerid, "pbOldX");
			PlayerInfo[playerid][pPos_y] = GetPVarFloat(playerid, "pbOldY");
			PlayerInfo[playerid][pPos_z] = GetPVarFloat(playerid, "pbOldZ");
			PlayerInfo[playerid][pHealth] = GetPVarFloat(playerid, "pbOldHealth");
			PlayerInfo[playerid][pArmor] = GetPVarFloat(playerid, "pbOldArmor");
			SetPlayerHealth(playerid,GetPVarFloat(playerid, "pbOldHealth"));
			SetPlayerArmor(playerid,GetPVarFloat(playerid, "pbOldArmor"));
		}
		else if(GetPVarInt(playerid, "EventToken") == 0 && !GetPVarType(playerid, "LoadingObjects"))
		{
		    if(IsPlayerInRangeOfPoint(playerid, 1200, -1083.90002441,4289.70019531,7.59999990) && PlayerInfo[playerid][pMember] == INVALID_GROUP_ID)
			{
				PlayerInfo[playerid][pInt] = 0;
				PlayerInfo[playerid][pVW] = 0;
				GetPlayerFacingAngle(playerid, PlayerInfo[playerid][pPos_r]);
				PlayerInfo[playerid][pPos_x] = 1529.6;
				PlayerInfo[playerid][pPos_y] = -1691.2;
				PlayerInfo[playerid][pPos_z] = 13.3;
			}
			else
			{
				new Float: x, Float: y, Float: z;
				PlayerInfo[playerid][pInt] = GetPlayerInterior(playerid);
				PlayerInfo[playerid][pVW] = GetPlayerVirtualWorld(playerid);
				GetPlayerPos(playerid, x, y, z);
				GetPlayerFacingAngle(playerid, PlayerInfo[playerid][pPos_r]);
				PlayerInfo[playerid][pPos_x] = x;
				PlayerInfo[playerid][pPos_y] = y;
				PlayerInfo[playerid][pPos_z] = z;
			}
		}
		else
		{
			PlayerInfo[playerid][pInt] = EventLastInt[playerid];
			PlayerInfo[playerid][pVW] = EventLastVW[playerid];
			PlayerInfo[playerid][pPos_r] = EventFloats[playerid][0];
			PlayerInfo[playerid][pPos_x] = EventFloats[playerid][1];
			PlayerInfo[playerid][pPos_y] = EventFloats[playerid][2];
			PlayerInfo[playerid][pPos_z] = EventFloats[playerid][3];
		}
		if(WatchingTV[playerid] == 1)
		{
			PlayerInfo[playerid][pInt] = BroadcastLastInt[playerid];
			PlayerInfo[playerid][pVW] = BroadcastLastVW[playerid];
			PlayerInfo[playerid][pPos_r] = BroadcastFloats[playerid][0];
			PlayerInfo[playerid][pPos_x] = BroadcastFloats[playerid][1];
			PlayerInfo[playerid][pPos_y] = BroadcastFloats[playerid][2];
			PlayerInfo[playerid][pPos_z] = BroadcastFloats[playerid][3];
			WatchingTV[playerid] = 0;
			viewers--;
			UpdateSANewsBroadcast();
		}
		if(gBike[playerid] >= 0 && gBikeRenting[playerid] == 1)
		{
			gBike[playerid] = 0;
			gBikeRenting[playerid] = 0;
			KillTimer(GetPVarInt(playerid, "RentTime"));
		}

		if(GetPVarInt(playerid, "gpsonoff") == 1) TextDrawDestroy(GPS[playerid]);

		if(PlayerInfo[playerid][pAdmin] >= 2) TextDrawDestroy(PriorityReport[playerid]);

		if(InsidePlane[playerid] != INVALID_VEHICLE_ID)
		{
			if(!IsAPlane(InsidePlane[playerid]))
			{
				GivePlayerValidWeapon(playerid, 46, 60000);
				PlayerInfo[playerid][pPos_x] = 0.000000;
				PlayerInfo[playerid][pPos_y] = 0.000000;
				PlayerInfo[playerid][pPos_z] = 420.000000;
			}
			else
			{
				new Float:X, Float:Y, Float:Z;
				GetVehiclePos(InsidePlane[playerid], X, Y, Z);
				PlayerInfo[playerid][pPos_x] = X;
				PlayerInfo[playerid][pPos_y] = Y;
				PlayerInfo[playerid][pPos_z] = Z;
				if(Z > 50.0)
				{
					GivePlayerValidWeapon(playerid, 46, 60000);
				}
			}
			PlayerInfo[playerid][pVW] = 0;
			SetPlayerVirtualWorld(playerid, 0);
			PlayerInfo[playerid][pInt] = 0;
			SetPlayerInterior(playerid, 0);
			InsidePlane[playerid] = INVALID_VEHICLE_ID;
		}

		OnPlayerStatsUpdate(playerid);
		if(reason == 0)
		{
			new Float:pos[4];
			for(new v = 0; v < MAX_PLAYERVEHICLES; v++) 
			{
				if(PlayerVehicleInfo[playerid][v][pvId] != INVALID_PLAYER_VEHICLE_ID)
				{
					GetVehiclePos(PlayerVehicleInfo[playerid][v][pvId], pos[0], pos[1], pos[2]);
					GetVehicleZAngle(PlayerVehicleInfo[playerid][v][pvId], pos[3]);
					if(PlayerVehicleInfo[playerid][v][pvPosX] != pos[0])
					{
						PlayerVehicleInfo[playerid][v][pvCrashFlag] = 1;
						PlayerVehicleInfo[playerid][v][pvCrashVW] = GetVehicleVirtualWorld(PlayerVehicleInfo[playerid][v][pvId]);
						PlayerVehicleInfo[playerid][v][pvCrashX] = pos[0];
						PlayerVehicleInfo[playerid][v][pvCrashY] = pos[1];
						PlayerVehicleInfo[playerid][v][pvCrashZ] = pos[2];
						PlayerVehicleInfo[playerid][v][pvCrashAngle] = pos[3];
						g_mysql_SaveVehicle(playerid, v);
					}
				}
			}
				
		}
		UnloadPlayerVehicles(playerid);
		g_mysql_AccountOnline(playerid, 0);

		for(new i = 0; i < MAX_REPORTS; i++)
		{
			if(Reports[i][ReportFrom] == playerid)
			{
				Reports[i][ReportFrom] = INVALID_PLAYER_ID;
				Reports[i][BeingUsed] = 0;
				Reports[i][TimeToExpire] = 0;
        		Reports[i][ReportPriority] = 0;
        		Reports[i][ReportLevel] = 0;
			}
		}
		for(new i = 0; i < MAX_CALLS; i++)
		{
			if(Calls[i][CallFrom] == playerid)
			{
				if(Calls[i][BeingUsed] == 1) DeletePVar(Calls[i][CallFrom], "Has911Call");
				strmid(Calls[i][Area], "None", 0, 4, 4);
				strmid(Calls[i][MainZone], "None", 0, 4, 4);
				strmid(Calls[i][Description], "None", 0, 4, 4);
				Calls[i][RespondingID] = INVALID_PLAYER_ID;
				Calls[i][CallFrom] = INVALID_PLAYER_ID;
				Calls[i][Type] = -1;
				Calls[i][TimeToExpire] = 0;
			}
		}
		foreach(new i: Player)
		{
		    if (GetPVarType(i, "hFind") && GetPVarInt(i, "hFind") == playerid)
		    {
		        SendClientMessageEx(i, COLOR_GREY, "Khong ket noi duoc voi may chu, ban co the thu lai sau.");
		        DeletePVar(i, "hFind");
				DisablePlayerCheckpoint(i);
		    }
		    if (GetPVarType(i, "Backup") && GetPVarInt(i, "Backup") == playerid)
		    {
		        SendClientMessageEx(i, COLOR_GREY, "Nguoi goi backup da thoat ket noi may chu.");
		        DeletePVar(i, "Backup");
		    }
			if(TaxiAccepted[i] == playerid)
			{
				TaxiAccepted[i] = INVALID_PLAYER_ID;
				GameTextForPlayer(i, "~w~Nguoi goi TAXI~n~~r~da thoat may chu", 5000, 1);
				TaxiCallTime[i] = 0;
				DisablePlayerCheckpoint(i);
			}
			if(EMSAccepted[i] == playerid)
			{
				EMSAccepted[i] = INVALID_PLAYER_ID;
				GameTextForPlayer(i, "~w~Nguoi goi EMS~n~~r~da thoat may chu", 5000, 1);
				EMSCallTime[i] = 0;
				DisablePlayerCheckpoint(i);
			}
			if(BusAccepted[i] == playerid)
			{
				BusAccepted[i] = INVALID_PLAYER_ID;
				GameTextForPlayer(i, "~w~Nguoi goi BUS~n~~r~da thoat may chu", 5000, 1);
				BusCallTime[i] = 0;
				DisablePlayerCheckpoint(i);
			}
			if(MedicAccepted[i] == playerid)
			{
				TaxiAccepted[playerid] = INVALID_PLAYER_ID; BusAccepted[playerid] = INVALID_PLAYER_ID; MedicAccepted[playerid] = INVALID_PLAYER_ID;
				GameTextForPlayer(i, "~w~Nguoi goi MEDIC~n~~r~da thoat may chu", 5000, 1);
				MedicCallTime[i] = 0;
				DisablePlayerCheckpoint(i);
			}
			if(OrderAssignedTo[i] == playerid)
			{
			   OrderAssignedTo[i] = INVALID_PLAYER_ID;
			}
		}
		if(TransportCost[playerid] > 0 && TransportDriver[playerid] != INVALID_PLAYER_ID)
		{
			if(IsPlayerConnected(TransportDriver[playerid]))
			{
				TransportMoney[TransportDriver[playerid]] += TransportCost[playerid];
				TransportTime[TransportDriver[playerid]] = 0;
				TransportCost[TransportDriver[playerid]] = 0;
				format(string, sizeof(string), "~w~Hanh khach da thoat~n~~g~Kiem duoc $%d",TransportCost[playerid]);
				GameTextForPlayer(TransportDriver[playerid], string, 5000, 1);
				TransportDriver[playerid] = INVALID_PLAYER_ID;
			}
		}
		if(GotHit[playerid] > 0)
		{
			if(GetChased[playerid] != INVALID_PLAYER_ID)
			{
				if(IsPlayerConnected(GetChased[playerid]))
				{
					SendClientMessageEx(GetChased[playerid], COLOR_YELLOW, "Your hit has left the server.");
					GoChase[GetChased[playerid]] = INVALID_PLAYER_ID;
				}
			}
		}
		if(GoChase[playerid] != INVALID_PLAYER_ID)
		{
		  GetChased[GoChase[playerid]] = INVALID_PLAYER_ID;
		  GotHit[GoChase[playerid]] = INVALID_PLAYER_ID;
		}
		if(HireCar[playerid] != 299)
		{
			vehicle_unlock_doors(HireCar[playerid]);
		}
		if (gLastCar[playerid] > 0)
		{
			if(PlayerInfo[playerid][pPhousekey] != gLastCar[playerid]-1)
			{
				vehicle_unlock_doors(gLastCar[playerid]);
			}
		}
		if(PlayerBoxing[playerid] > 0)
		{
			if(Boxer1 == playerid)
			{
				if(IsPlayerConnected(Boxer2))
				{
					if(IsPlayerInRangeOfPoint(PlayerBoxing[Boxer2], 20.0, 768.94, -70.87, 1001.56))
					{
						PlayerBoxing[Boxer2] = 0;
						SetPlayerPos(Boxer2, 768.48, -73.66, 1000.57);
						SetPlayerInterior(Boxer2, 7);
						GameTextForPlayer(Boxer2, "~r~Match interupted", 5000, 1);
					}
					PlayerBoxing[Boxer2] = 0;
					SetPlayerPos(Boxer2, 765.8433,3.2924,1000.7186);
					SetPlayerInterior(Boxer2, 5);
					GameTextForPlayer(Boxer2, "~r~Match interupted", 5000, 1);
				}
			}
			else if(Boxer2 == playerid)
			{
				if(IsPlayerConnected(Boxer1))
				{
					if(IsPlayerInRangeOfPoint(PlayerBoxing[Boxer1],20.0,764.35, -66.48, 1001.56))
					{
						PlayerBoxing[Boxer1] = 0;
						SetPlayerPos(Boxer1, 768.48, -73.66, 1000.57);
						SetPlayerInterior(Boxer1, 7);
						GameTextForPlayer(Boxer1, "~r~Match interupted", 5000, 1);
					}
					PlayerBoxing[Boxer1] = 0;
					SetPlayerPos(Boxer1, 765.8433,3.2924,1000.7186);
					SetPlayerInterior(Boxer1, 5);
					GameTextForPlayer(Boxer1, "~r~Match interupted", 5000, 1);
				}
			}
			InRing = 0;
			RoundStarted = 0;
			Boxer1 = INVALID_PLAYER_ID;
			Boxer2 = INVALID_PLAYER_ID;
			TBoxer = INVALID_PLAYER_ID;
		}
		if(GetPVarInt(playerid, "AdvisorDuty") == 1)
		{
			Advisors--;
		}
		if(TransportDuty[playerid] == 1)
		{
			TaxiDrivers -= 1;
		}
		else if(TransportDuty[playerid] == 2)
		{
			BusDrivers -= 1;
		}
		if(PlayerInfo[playerid][pJob] == 11 || PlayerInfo[playerid][pJob2] == 11)
		{
			if(JobDuty[playerid] == 1) { Medics -= 1; }
		}
		if(PlayerInfo[playerid][pJob] == 7 || PlayerInfo[playerid][pJob2] == 7)
		{
			if(GetPVarInt(playerid, "MechanicDuty") == 1) { Mechanics -= 1; }
		}
		if(PlayerInfo[playerid][pJob] == 11 || PlayerInfo[playerid][pJob2] == 11)
		{
			if(JobDuty[playerid] == 1) { Coastguard -= 1; }
		}
		new Float:health, Float:armor;
		if(GetPVarType(playerid, "pGodMode") == 1)
		{
			health = GetPVarFloat(playerid, "pPreGodHealth");
			SetPlayerHealth(playerid,health);
			armor = GetPVarFloat(playerid, "pPreGodArmor");
			SetPlayerArmor(playerid, armor);
			DeletePVar(playerid, "pGodMode");
			DeletePVar(playerid, "pPreGodHealth");
			DeletePVar(playerid, "pPreGodArmor");
		}
		if(GetPVarInt(playerid, "ttSeller") >= 0)
		{
			DeletePVar(playerid, "ttSeller");
			HideTradeToysGUI(playerid);
		}
		if(IsValidDynamic3DTextLabel(RFLTeamN3D[playerid])) {
			DestroyDynamic3DTextLabel(RFLTeamN3D[playerid]);
		}	
		pSpeed[playerid] = 0.0;
		SetPVarInt(playerid, "PlayerOwnASurf", 0);
	}
	DeletePVar(playerid, "pTmpEmail");
	DeletePVar(playerid, "NullEmail");
	DeletePVar(playerid, "ViewedPMOTD");
	gPlayerLogged{playerid} = 0;
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
    if(!success)
    {
        new pip[16], string[128];
        foreach(new i : Player)
        {
            GetPlayerIp(i, pip, sizeof(pip));
            if(!strcmp(ip, pip, true))
            {
				new logins = GetPVarInt(i, "RconFailedLogin")+1;
				SetPVarInt(i, "RconFailedLogin", logins);
				if(GetPVarInt(i, "RconFailedLogin") >= 3)
				{
					format(string, sizeof(string), "AdmCmd: %s (IP: %s) da bi khoa tai khoan khi co gang dang nhap vao RCON nhieu lan", GetPlayerNameEx(i), pip);
					Log("logs/ban.log", string);
					PlayerInfo[i][pBanned] = 1;
					MySQLBan(GetPlayerSQLId(i),pip,"Dang nhap RCON that bai",1,"System");
					SystemBan(i, "[System] Dang nhap RCON that bai");
					Kick(i);
				}
            }
        }
    }
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if(IsPlayerNPC(playerid)) return 1;
	IsSpawned[playerid] = 0;
	SpawnKick[playerid] = 0;
	if(IsPlayerConnected(playerid) && IsPlayerConnected(killerid))
	{
		SetPVarInt(playerid, "PlayerOwnASurf", 0);
	    #if defined zombiemode
    	if(zombieevent == 1 && GetPVarType(playerid, "pIsZombie"))
		{
			new string[128];
   			format(string, sizeof(string), "INSERT INTO humankills (id,num) VALUES (%d,1) ON DUPLICATE KEY UPDATE num = num + 1", GetPlayerSQLId(killerid));
			mysql_function_query(MainPipeline, string, false, "OnQueryFinish", "ii", SENDDATA_THREAD, killerid);
		}

		if(zombieevent == 1 && GetPVarType(playerid, "pIsZombie"))
		{
  			new Float:mX, Float:mY, Float:mZ;
			GetPlayerPos(playerid, mX, mY, mZ);

			SetPVarFloat(playerid, "MedicX", mX);
			SetPVarFloat(playerid, "MedicY", mY);
			SetPVarFloat(playerid, "MedicZ", mZ);
		}
	    #endif
	    
	    if(SpoofKill[playerid] == 0)
			KillTime[playerid] = gettime();

		SpoofKill[playerid]++;


		if(SpoofKill[playerid] >= 4)
		{
			if((gettime() - KillTime[playerid]) <= 2)
			{
				new string[128];
				format(string, sizeof(string), "WARNING: %s (IP:%s) attempted to spoof kills and has been auto-banned.", GetPlayerNameEx( playerid ), PlayerInfo[playerid][pIP] );
				ABroadCast(COLOR_YELLOW, string, 2);
				PlayerInfo[playerid][pBanned] = 3;
				MySQLBan(GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), "Tried to spoof kills", 1, "System");
				SystemBan(playerid, "[System] (Tried to spoof kills)");
				Log("logs/ban.log", string);
				TotalAutoBan++;
				Kick(playerid);
			}
			else
			{
				SpoofKill[playerid] = 0;
			}
		}
	    
	    RemoveArmor(playerid);

		if (GetPVarInt(playerid, "_SwimmingActivity") >= 1)
		{
			DisablePlayerCheckpoint(playerid);
			DeletePVar(playerid, "_SwimmingActivity");
		}
		if (GetPVarInt(playerid, "_BoxingQueue") == 1)
		{
			DeletePVar(playerid, "_BoxingQueue");
		}
		if (GetPVarInt(playerid, "_BoxingFight") != 0)
		{
			new winner = GetPVarInt(playerid, "_BoxingFight") - 1;
			SendClientMessageEx(winner, COLOR_GREEN, "Ban da gianh duoc chien thang!");
			SendClientMessageEx(playerid, COLOR_RED, "Ban da mat chien dau!");

			DeletePVar(winner, "_BoxingFight");
			DeletePVar(playerid, "_BoxingFight");

			PlayerInfo[winner][pFitness] += 6;
			PlayerInfo[playerid][pFitness] += 4;

			if (PlayerInfo[winner][pFitness] > 100)
				PlayerInfo[winner][pFitness] = 100;

			if (PlayerInfo[playerid][pFitness] > 100)
				PlayerInfo[playerid][pFitness] = 100;

			new time = gettime();
			SetPVarInt(playerid, "_BoxingFightOver", time + 8);
			SetPVarInt(winner, "_BoxingFightOver", time + 1);
		}
	    if (_vhudVisible[playerid] == 1)
		{
			HideVehicleHUDForPlayer(playerid); // incase vehicle despawns
		}
		if (CarRadars[playerid] > 0)
		{
			CarRadars[playerid] = 0;
			PlayerTextDrawHide(playerid, _crTextTarget[playerid]);
			PlayerTextDrawHide(playerid, _crTextSpeed[playerid]);
			PlayerTextDrawHide(playerid, _crTickets[playerid]);
			DeletePVar(playerid, "_lastTicketWarning");
		}
	    if(GetPVarInt(playerid, "AttemptPurify"))
		{
			Purification[0] = 0;
	    	KillTimer(GetPVarInt(playerid, "AttemptPurify"));
		}
		if(GetPVarInt(playerid, "HeroinEffect"))
		{
		    DeletePVar(playerid, "HeroinEffect");
			KillTimer(GetPVarInt(playerid, "HeroinEffect"));
		}
		if(GetPVarInt(playerid, "InjectHeroin"))
		{
		    KillTimer(GetPVarInt(playerid, "InjectHeroin"));
		}
		new weaponname[32];
		GetWeaponName(reason, weaponname, sizeof(weaponname));

	 	new query[256];
		format(query, sizeof(query), "INSERT INTO `kills` (`id`, `killerid`, `killedid`, `date`, `weapon`) VALUES (NULL, %d, %d, NOW(), '%s')", GetPlayerSQLId(killerid), GetPlayerSQLId(playerid), weaponname);
		mysql_function_query(MainPipeline, query, false, "OnQueryFinish", "i", SENDDATA_THREAD);

	 	if(GetPVarInt(killerid, "IsInArena") >= 0) PlayerInfo[killerid][pDMKills]++;
	}

    TextDrawHideForPlayer(playerid, BFText);
    DeletePVar(playerid, "BlindFolded");
	pTazer{playerid} = 0;
	InsidePlane[playerid] = INVALID_VEHICLE_ID;
	DeletePVar(playerid, "SpeedRadar");
    DeletePVar(playerid, "UsingSprunk");
    KillTimer(GetPVarInt(playerid, "firstaid5"));
  	DeletePVar(playerid, "usingfirstaid");
	if(GetPVarInt(playerid, "MovingStretcher") != -1)
	{
	    KillTimer(GetPVarInt(playerid, "TickEMSMove"));
	    DeletePVar(GetPVarInt(playerid, "MovingStretcher"), "OnStretcher");
	    SetPVarInt(playerid, "MovingStretcher", -1);
	}

	if(IsPlayerConnected(Mobile[playerid]))
	{
		new
			iCaller = Mobile[playerid],
			szMessage[64];

		SendClientMessageEx(iCaller, COLOR_GRAD2, "The line went dead.");
		format(szMessage, sizeof(szMessage), "* %s puts away their cellphone.", GetPlayerNameEx(iCaller));
		ProxDetector(30.0, iCaller, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		CellTime[iCaller] = 0;
		Mobile[iCaller] = INVALID_PLAYER_ID;
	}
	Mobile[playerid] = INVALID_PLAYER_ID;
	CellTime[playerid] = 0;
	RingTone[playerid] = 0;

	if(GetPVarType(playerid, "SpecOff"))
	{
		SpawnPlayer(playerid);
		return 1;
	}

	if(GetPVarInt(playerid, "Injured") == 1)
	{
		foreach(new i: Player)
		{
			if(EMSAccepted[i] == playerid)
			{
				EMSAccepted[i] = INVALID_PLAYER_ID;
				GameTextForPlayer(i, "~w~Nguoi goi EMS~n~~r~Da chet", 5000, 1);
				EMSCallTime[i] = 0;
				DisablePlayerCheckpoint(i);
			}
		}
     	SendClientMessageEx(playerid, COLOR_WHITE, "Ban dang trong tinh trang nguy kich,cac bac si dang co gang cuu song ban.");
	    KillEMSQueue(playerid);
	    ResetPlayerWeaponsEx(playerid);
	    return 1;
	}

	if(GetPVarInt(playerid, "EventToken") == 0)
	{
	    if(GetPVarInt(playerid, "IsInArena") == -1)
		{
			if(HungerPlayerInfo[playerid][hgInEvent] != 1)
			{
				new Float:mX, Float:mY, Float:mZ;
				GetPlayerPos(playerid, mX, mY, mZ);

				SetPVarFloat(playerid, "MedicX", mX);
				SetPVarFloat(playerid, "MedicY", mY);
				SetPVarFloat(playerid, "MedicZ", mZ);
				SetPVarInt(playerid, "MedicVW", GetPlayerVirtualWorld(playerid));
				SetPVarInt(playerid, "MedicInt", GetPlayerInterior(playerid));

				SetPVarInt(playerid, "Injured", 1);
			}
		}
	}

	if(GetPVarInt(playerid, "IsInArena") >= 0)
	{
		new
			iPlayer = GetPVarInt(playerid, "IsInArena"),
			iKiller = GetPVarInt(killerid, "IsInArena"),
			szMessage[96];

	    if(GetPVarInt(playerid, "AOSlotPaintballFlag") != -1)
	    {
     		switch(PlayerInfo[playerid][pPaintTeam])
       		{
         		case 1:
           		{
					DropFlagPaintballArena(playerid, iPlayer, 2);
     			}
        		case 2:
          		{
            		DropFlagPaintballArena(playerid, iPlayer, 1);
            	}
        	}
	    }
		if(reason >= 0 && reason <= 46)
		{
		    new weapon[24];
			++PlayerInfo[killerid][pKills];
		    ++PlayerInfo[playerid][pDeaths];
			if(PlayerInfo[killerid][pPaintTeam] == 1)
			{
			    if(PlayerInfo[killerid][pPaintTeam] == PlayerInfo[playerid][pPaintTeam])
			    {
			        --PaintBallArena[iKiller][pbTeamRedKills];
			        ++PaintBallArena[iPlayer][pbTeamBlueKills];
			        SetPlayerHealth(killerid, 0);
			        PlayerInfo[killerid][pKills] -= 2;
			        ++PlayerInfo[killerid][pDeaths];
		    		--PlayerInfo[playerid][pDeaths];
			        SendClientMessageEx(killerid, COLOR_WHITE, "Ban da duoc canh  cao truoc, khong the kill team!");
			    }
			    else
			    {
		    		++PaintBallArena[iKiller][pbTeamRedKills];
		    		++PaintBallArena[iPlayer][pbTeamBlueDeaths];
				}
			}
			if(PlayerInfo[killerid][pPaintTeam] == 2)
			{
			    if(PlayerInfo[killerid][pPaintTeam] == PlayerInfo[playerid][pPaintTeam])
			    {
			        --PaintBallArena[iKiller][pbTeamBlueKills];
			        ++PaintBallArena[iPlayer][pbTeamRedKills];
			        SetPlayerHealth(killerid, 0);
			        PlayerInfo[killerid][pKills] -= 2;
			        ++PlayerInfo[killerid][pDeaths];
		    		--PlayerInfo[playerid][pDeaths];
			        SendClientMessageEx(killerid, COLOR_WHITE, "Ban da duoc canh bao truoc, khong the kill team!");
			    }
		    	++PaintBallArena[iKiller][pbTeamBlueKills];
		    	++PaintBallArena[iPlayer][pbTeamRedDeaths];
			}
			GetWeaponName(reason,weapon,sizeof(weapon));
			if(PaintBallArena[iKiller][pbTimeLeft] < 12)
			{
				GivePlayerCash(killerid, 1000);
				format(szMessage,sizeof(szMessage),"[Paintball Arena] %s da nhan duoc $1000 tien thuong!",GetPlayerNameEx(killerid));
				SendPaintballArenaMessage(iKiller, COLOR_YELLOW, szMessage);
				////SendAudioToPlayer(killerid, 19, 100);
			}
			if(reason == 0) format(szMessage,sizeof(szMessage),"[Paintball Arena] %s da giet %s bang nam dam cua minh!",GetPlayerNameEx(killerid),GetPlayerNameEx(playerid));
			else format(szMessage,sizeof(szMessage),"[Paintball Arena] %s da giet %s voi %s.",GetPlayerNameEx(killerid),GetPlayerNameEx(playerid),weapon);
		}
		else
		{
		    ++PlayerInfo[playerid][pDeaths];
			format(szMessage,sizeof(szMessage),"[Paintball Arena] %s da chet.",GetPlayerNameEx(playerid));
		}
	    SendPaintballArenaMessage(iPlayer, COLOR_RED, szMessage);
	}

	if(GetPVarInt(playerid, "Injured") == 0)
	{
		if( GetPVarInt(playerid, "EventToken") >= 1 || GetPVarInt(playerid, "IsInArena") >= 0)
		{
			DisablePlayerCheckpoint(playerid);
			ResetPlayerWeapons(playerid);
		}
		else
		{
			ResetPlayerWeaponsEx(playerid);
		}
	}
	if(IsPlayerConnected(killerid) && PlayerInfo[killerid][pAdmin] < 2 && GetPlayerState(killerid) == PLAYER_STATE_DRIVER)
	{
		switch(reason)
		{
			case 49: {
			    new szMessage[128];
				format(szMessage, sizeof(szMessage), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) da dam xe giet %s (ID %d) toi chet.", GetPlayerNameEx(killerid), killerid, GetPlayerNameEx(playerid), playerid);
				ABroadCast(COLOR_YELLOW, szMessage, 2);
			}
			case 50: if(IsAHelicopter(GetPlayerVehicleID(killerid))) {
			    new szMessage[128];
				format(szMessage, sizeof(szMessage), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) da su dung may bay giet chet %s (ID %d).", GetPlayerNameEx(killerid), killerid, GetPlayerNameEx(playerid), playerid);
				ABroadCast(COLOR_YELLOW, szMessage, 2);
			}
			default: switch(GetPlayerWeapon(killerid)) {
				case 32, 28, 29: {
				    new szMessage[128];
					format(szMessage, sizeof(szMessage), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) da lai xe giet %s (ID %d) toi chet.", GetPlayerNameEx(killerid), killerid, GetPlayerNameEx(playerid), playerid);
					ABroadCast(COLOR_YELLOW, szMessage, 2);
				}
			}
		}
	}

	if (gPlayerCheckpointStatus[playerid] > 4 && gPlayerCheckpointStatus[playerid] < 11)
	{
		DisablePlayerCheckpoint(playerid);
		gPlayerCheckpointStatus[playerid] = CHECKPOINT_NONE;
	}

	if(PlayerInfo[playerid][pHeadValue] >= 1)
	{
		if(IsPlayerConnected(killerid))
		{
			if(GoChase[killerid] == playerid)
			{
				new szMessage[64 + MAX_PLAYER_NAME];
				new takemoney = floatround((PlayerInfo[playerid][pHeadValue] / 4) * 2);
				GivePlayerCash(killerid, takemoney);
				GivePlayerCash(playerid, -takemoney);
				format(szMessage, sizeof(szMessage),"Hitman %s da hoan thanh hop dong giet %s va nhan duoc tien thuong $%d.",GetPlayerNameEx(killerid),GetPlayerNameEx(playerid),takemoney);
				SendGroupMessage(2, COLOR_YELLOW, szMessage);
				format(szMessage, sizeof(szMessage),"Ban da bi mot sat thu giet hai, va bi mat so tien $%d ten nguoi .",takemoney);
   				ResetPlayerWeaponsEx(playerid);
				// SpawnPlayer(playerid);
				SendClientMessageEx(playerid, COLOR_YELLOW, szMessage);
				// KillEMSQueue(playerid);
				PlayerInfo[playerid][pHeadValue] = 0;
				PlayerInfo[killerid][pCHits] += 1;
				GotHit[playerid] = 0;
				GetChased[playerid] = INVALID_PLAYER_ID;
				GoChase[killerid] = INVALID_PLAYER_ID;
			}
		}
	}
	if(IsPlayerConnected(killerid))
 	{
		if(GoChase[playerid] == killerid)
		{
			new szMessage[64 + MAX_PLAYER_NAME];
			new takemoney = floatround((PlayerInfo[killerid][pHeadValue] / 4) * 2);
			GivePlayerCash(killerid, takemoney);
			format(szMessage, sizeof(szMessage),"Hitman %s da lam that bai mot hop dong giet %s va bi mat $%d.",GetPlayerNameEx(playerid),GetPlayerNameEx(killerid),takemoney);
			SendGroupMessage(2, COLOR_YELLOW, szMessage);
			GivePlayerCash(playerid, -takemoney);
		   	format(szMessage, sizeof(szMessage),"Ban da giet mot Hitman, va nhan duoc tieng boi thuong $%d, moi hop dong giet ban da bi xoa bo.",takemoney);
			SendClientMessageEx(killerid, COLOR_YELLOW, szMessage);
			PlayerInfo[killerid][pHeadValue] = 0;
			PlayerInfo[playerid][pFHits] += 1;
			GotHit[playerid] = 0;
			GetChased[killerid] = INVALID_PLAYER_ID;
			GoChase[playerid] = INVALID_PLAYER_ID;
		}
	}
	SetPlayerColor(playerid,TEAM_HIT_COLOR);
	if(IsValidDynamic3DTextLabel(RFLTeamN3D[playerid])) {
		DestroyDynamic3DTextLabel(RFLTeamN3D[playerid]);
	}	
	return 1;
}

public OnVehicleDeath(vehicleid) {
    new Float:X, Float:Y, Float:Z;
    new Float:XB, Float:YB, Float:ZB;
    VehicleStatus{vehicleid} = 1;
    TruckContents{vehicleid} = 0;
	foreach(new i: Player)
	{
	    if(InsidePlane[i] == vehicleid)
	    {
			GetVehiclePos(InsidePlane[i], X, Y, Z);
			SetPlayerPos(i, X-4, Y-2.3, Z);
			GetVehiclePos(InsidePlane[i], XB, YB, ZB);
			if(ZB > 50.0)
			{
				PlayerInfo[i][pAGuns][GetWeaponSlot(46)] = 46;
				GivePlayerValidWeapon(i, 46, 60000);
			}
   			PlayerInfo[i][pVW] = 0;
			SetPlayerVirtualWorld(i, 0);
			PlayerInfo[i][pInt] = 0;
			SetPlayerInterior(i, 0);
			InsidePlane[i] = INVALID_VEHICLE_ID;
			SendClientMessageEx(i, COLOR_WHITE, "Chiec may bay da bi hu hong qua nang, ban khong the su dung no!");
	    }
	    if(GetPVarInt(i, "NGPassengerVeh") == vehicleid)
	    {
	        TogglePlayerSpectating(i, false);
		}
	}
    /*if(DynVeh[vehicleid] != -1)
	{
		DynVeh_Spawn(DynVeh[vehicleid]);
	}*/
    if(IsValidDynamicObject(CrateVehicleLoad[vehicleid][vForkObject]) && CrateVehicleLoad[vehicleid][vForkLoaded] == 1)
    {
    	DestroyDynamicObject(CrateVehicleLoad[vehicleid][vForkObject]);
	}
    CrateVehicleLoad[vehicleid][vForkLoaded] = 0;
    for(new i = 0; i < sizeof(CrateInfo); i++)
    {
		if(CrateInfo[i][InVehicle] == vehicleid)
		{
		    CrateInfo[i][InVehicle] = INVALID_VEHICLE_ID;
		    CrateInfo[i][crObject] = INVALID_OBJECT_ID;
		    CrateInfo[i][crActive] = 0;
		    CrateInfo[i][crX] = 0;
		    CrateInfo[i][crY] = 0;
		    CrateInfo[i][crZ] = 0;
		    break;
		}
    }
	arr_Engine{vehicleid} = 0;
}

public OnPlayerSpawn(playerid)
{
    if(IsPlayerNPC(playerid)) return 1;
    if(!gPlayerLogged{playerid})
    {
        SendClientMessageEx(playerid, COLOR_WHITE, "ERROR: Ban chua dang nhap!");
        SetTimerEx("KickEx", 1000, false, "i", playerid);
        return 1;
	}
	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 1);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 1);

 	if(sobeitCheckvar[playerid] == 0)
	{
	    if(PlayerInfo[playerid][pInt] == 0 && PlayerInfo[playerid][pVW] == 0)
	    {
			if(sobeitCheckIsDone[playerid] == 0)
			{
			    if(PlayerInfo[playerid][pAdmin] < 2)
			    {
			        if(PlayerInfo[playerid][pHospital] == 0)
			        {
					    sobeitCheckIsDone[playerid] = 1;
					    SetTimerEx("sobeitCheck", 10000, false, "i", playerid);
						TogglePlayerControllable(playerid, false);
					}
				}
			}
  		}
	}

	if(GetPVarInt(playerid, "NGPassenger") == 1)
	{
	    new Float:X, Float:Y, Float:Z;
	    GetVehiclePos(GetPVarInt(playerid, "NGPassengerVeh"), X, Y, Z);
	    SetPlayerPos(playerid, (X-2.557), (Y-3.049), Z);
	    SetPlayerWeaponsEx(playerid);
        GivePlayerValidWeapon(playerid, 46, 60000);
        SetPlayerSkin(playerid, GetPVarInt(playerid, "NGPassengerSkin"));
        SetPlayerHealth(playerid, GetPVarFloat(playerid, "NGPassengerHP"));
        if(GetPVarFloat(playerid, "NGPassengerArmor") > 0) {
        	SetPlayerArmor(playerid, GetPVarFloat(playerid, "NGPassengerArmor"));
        }
		DeletePVar(playerid, "NGPassenger");
	    DeletePVar(playerid, "NGPassengerVeh");
		DeletePVar(playerid, "NGPassengerArmor");
		DeletePVar(playerid, "NGPassengerHP");
		DeletePVar(playerid, "NGPassengerSkin");
	    return 1;
	}
	if(InsidePlane[playerid] != INVALID_VEHICLE_ID)
	{
		SetPlayerPos(playerid, GetPVarFloat(playerid, "air_Xpos"), GetPVarFloat(playerid, "air_Ypos"), GetPVarFloat(playerid, "air_Zpos"));
		SetPlayerFacingAngle(playerid, GetPVarFloat(playerid, "air_Rpos"));
		SetPlayerHealth(playerid, GetPVarFloat(playerid, "air_HP"));
		if(GetPVarFloat(playerid, "air_Arm") > 0) {
			SetPlayerArmor(playerid, GetPVarFloat(playerid, "air_Arm"));
		}
		SetPlayerWeaponsEx(playerid);
		SetPlayerToTeamColor(playerid);
        SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
		SetPlayerInterior(playerid, GetPVarInt(playerid, "air_Int"));

		DeletePVar(playerid, "air_Xpos");
		DeletePVar(playerid, "air_Ypos");
		DeletePVar(playerid, "air_Zpos");
		DeletePVar(playerid, "air_Rpos");
		DeletePVar(playerid, "air_HP");
		DeletePVar(playerid, "air_Arm");
		DeletePVar(playerid, "air_Mode");
		DeletePVar(playerid, "air_Int");

		SetCameraBehindPlayer(playerid);
		SetPlayerVirtualWorld(playerid, InsidePlane[playerid]);
		return 1;
	}
	SyncPlayerTime(playerid);

	if(GetPVarType(playerid, "STD")) {
		DeletePVar(playerid, "STD");
	}

	SetPlayerTeam(playerid, NO_TEAM);
	SetPlayerSpawn(playerid);
	SetPlayerWeapons(playerid);
	SetPlayerToTeamColor(playerid);
	IsSpawned[playerid] = 1;
	SpawnKick[playerid] = 0;
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
    if(GetPVarInt(playerid, "EventToken") == 1 && GetPVarInt(playerid, "InWaterStationRCP") == 1)
	{
	    KillTimer(GetPVarInt(playerid, "WSRCPTimerId"));
	    SetPVarInt(playerid, "WSRCPTimerId", 0);
     	SetPVarInt(playerid, "InWaterStationRCP", 0);
     	RCPIdCurrent[playerid]++;
		if(EventRCPT[RCPIdCurrent[playerid]] == 1) {
	        DisablePlayerCheckpoint(playerid);
			SetPlayerCheckpoint(playerid, EventRCPX[RCPIdCurrent[playerid]], EventRCPY[RCPIdCurrent[playerid]], EventRCPZ[RCPIdCurrent[playerid]], EventRCPS[RCPIdCurrent[playerid]]);
		}
		else if(EventRCPT[RCPIdCurrent[playerid]] == 4) {
		    DisablePlayerCheckpoint(playerid);
		    SetPlayerCheckpoint(playerid, EventRCPX[RCPIdCurrent[playerid]], EventRCPY[RCPIdCurrent[playerid]], EventRCPZ[RCPIdCurrent[playerid]], EventRCPS[RCPIdCurrent[playerid]]);
		} else {
		    DisablePlayerCheckpoint(playerid);
		    SetPlayerCheckpoint(playerid, EventRCPX[RCPIdCurrent[playerid]], EventRCPY[RCPIdCurrent[playerid]], EventRCPZ[RCPIdCurrent[playerid]], EventRCPS[RCPIdCurrent[playerid]]);
		}
		SendClientMessageEx(playerid, COLOR_WHITE, "You have exited the checkpoint, you are no longer getting rehydrated.");
		return 1;
	}
    if(GetPVarInt(playerid,"IsInArena") >= 0)
	{
	    new arenaid = GetPVarInt(playerid, "IsInArena");
	    if(PaintBallArena[arenaid][pbGameType] == 4 || PaintBallArena[arenaid][pbGameType] == 5)
	    {
	        //SendAudioToPlayer(playerid, 24, 100);
	    }
	    return 1;
	}
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
    if(GetPVarInt(playerid, "EventToken") == 1)
	{
	    if(EventKernel[EventFootRace] == 1 && IsPlayerInAnyVehicle(playerid))
	    {
			return SendClientMessageEx(playerid, COLOR_WHITE, "Ban dang ben trong mot chiec xe, ban khong the tham gia su kien, vui long ra ngoai xe.");
	    }
	    if(EventRCPT[RCPIdCurrent[playerid]] == 3 && PlayerInfo[playerid][pHydration] < 60) {
		    SendClientMessageEx(playerid, COLOR_WHITE, "You have entered a Watering Station checkpoint, you need to stay here in order to get rehydrated again.");
		    SendClientMessageEx(playerid, COLOR_WHITE, "You may choose to leave at any point or wait until you get the message of fully rehydrated.");
            SetPVarInt(playerid, "WSRCPTimerId", SetTimerEx("WateringStation", 4000, true, "i", playerid));
            SetPVarInt(playerid, "InWaterStationRCP", 1);
            return 1;
		}
	    else if(EventRCPT[RCPIdCurrent[playerid]] == 4) {
			RCPIdCurrent[playerid] = 0;
			PlayerInfo[playerid][pHydration] -= 4;
			PlayerInfo[playerid][pRacePlayerLaps]++;
			if(PlayerInfo[playerid][pRacePlayerLaps] % 10 == 0) {
			    GiftPlayer(MAX_PLAYERS, playerid);
			}
			else if(PlayerInfo[playerid][pRacePlayerLaps] == 25) {
			    PlayerInfo[playerid][pEXPToken]++;
			    SendClientMessageEx(playerid, COLOR_YELLOW, "Ban da duoc nhan doi EXP Token cho viec hoan thanh 25 vong dua");
			}
			if(toglapcount == 0 && rflstatus > 0) {
				RaceTotalLaps++;
				Misc_Save();
				new query[128];
				if(PlayerInfo[playerid][pRFLTeam] != -1) {
					RFLInfo[PlayerInfo[playerid][pRFLTeam]][RFLlaps] +=1;
					format(query, sizeof(query), "UPDATE `rflteams` SET `laps` = %d WHERE `id` = %d;",
					RFLInfo[PlayerInfo[playerid][pRFLTeam]][RFLlaps],
					RFLInfo[PlayerInfo[playerid][pRFLTeam]][RFLsqlid]);
					mysql_function_query(MainPipeline, query, false, "OnQueryFinish", "i", SENDDATA_THREAD);
				}
				format(query, sizeof(query), "UPDATE `accounts` SET `RacePlayerLaps` = %d WHERE `id` = %d;", PlayerInfo[playerid][pRacePlayerLaps], GetPlayerSQLId(playerid));
				mysql_function_query(MainPipeline, query, false, "OnQueryFinish", "i", SENDDATA_THREAD);
			}
			new string[128];
			if(PlayerInfo[playerid][pRFLTeam] != -1) {
				format(string, sizeof(string), "Hoan thanh vong dua, So vong dua: %d | Vong dua team hoan thanh: %d | Vong dua hoan thanh: %d", PlayerInfo[playerid][pRacePlayerLaps], RFLInfo[PlayerInfo[playerid][pRFLTeam]][RFLlaps], RaceTotalLaps);
			}
			else {
				format(string, sizeof(string), "Hoan thanh vong dua, So vong dua: %d | Vong dua hoan thanh: %d", PlayerInfo[playerid][pRacePlayerLaps], RaceTotalLaps);
			}
			SendClientMessageEx(playerid, COLOR_WHITE, string);
		}
	    else 
		{
	    	RCPIdCurrent[playerid]++;
            PlayerInfo[playerid][pHydration] -= 4;
		}
		new string[128];
        if(PlayerInfo[playerid][pHydration] > 60)
        {
			format(string, sizeof(string), "Hydration level normal(%d)", PlayerInfo[playerid][pHydration]);
			SendClientMessageEx(playerid, COLOR_GREEN, string);
		}
		else if(PlayerInfo[playerid][pHydration] < 61 && PlayerInfo[playerid][pHydration] > 30)
		{
		    format(string, sizeof(string), "Hydration level low(%d)", PlayerInfo[playerid][pHydration]);
			SendClientMessageEx(playerid, COLOR_YELLOW, string);
		}
		else if(PlayerInfo[playerid][pHydration] < 31 && PlayerInfo[playerid][pHydration] > 0)
		{
		    format(string, sizeof(string), "Hydration level very low(%d)", PlayerInfo[playerid][pHydration]);
			SendClientMessageEx(playerid, COLOR_RED, string);
		}
		else if(PlayerInfo[playerid][pHydration] < 0)
		{
		    SendClientMessageEx(playerid, COLOR_WHITE, "Ban da bi dua vao tram cap cuu, FDSA se cuu ban va dua vao tram cap cuu gan nhat.");
            DeletePVar(playerid, "EventToken");
			DisablePlayerCheckpoint(playerid);
			PlayerInfo[playerid][pHydration] = 100;
			if(IsValidDynamic3DTextLabel(RFLTeamN3D[playerid])) {
				DestroyDynamic3DTextLabel(RFLTeamN3D[playerid]);
			}	
			SetPlayerHealth(playerid, 0);
			return 1;
		}
	    if(EventRCPT[RCPIdCurrent[playerid]] == 1) {
	        DisablePlayerCheckpoint(playerid);
			SetPlayerCheckpoint(playerid, EventRCPX[RCPIdCurrent[playerid]], EventRCPY[RCPIdCurrent[playerid]], EventRCPZ[RCPIdCurrent[playerid]], EventRCPS[RCPIdCurrent[playerid]]);
		}
		else if(EventRCPT[RCPIdCurrent[playerid]] == 4) {
		    DisablePlayerCheckpoint(playerid);
		    SetPlayerCheckpoint(playerid, EventRCPX[RCPIdCurrent[playerid]], EventRCPY[RCPIdCurrent[playerid]], EventRCPZ[RCPIdCurrent[playerid]], EventRCPS[RCPIdCurrent[playerid]]);
		} else {
		    DisablePlayerCheckpoint(playerid);
		    SetPlayerCheckpoint(playerid, EventRCPX[RCPIdCurrent[playerid]], EventRCPY[RCPIdCurrent[playerid]], EventRCPZ[RCPIdCurrent[playerid]], EventRCPS[RCPIdCurrent[playerid]]);
		}
		return 1;
	}
	if(GetPVarInt(playerid,"IsInArena") >= 0)
	{
	    new arenaid = GetPVarInt(playerid, "IsInArena");
	    if(PaintBallArena[arenaid][pbGameType] == 4 || PaintBallArena[arenaid][pbGameType] == 5)
	    {
	        //SendAudioToPlayer(playerid, 23, 100);
	    }
	    return 1;
	}
	if(GetPVarInt(playerid, "ShopCheckpoint") != 0)
	{
	    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	    DisablePlayerCheckpoint(playerid);
		DeletePVar(playerid, "ShopCheckpoint");
		return 1;
	}
	if(GetPVarInt(playerid,"TrackCar") != 0)
	{
	    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	    DisablePlayerCheckpoint(playerid);
		DeletePVar(playerid, "TrackCar");
		return 1;
	}
	if(GetPVarInt(playerid,"DV_TrackCar") != 0)
	{
	    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	    DisablePlayerCheckpoint(playerid);
		DeletePVar(playerid, "DV_TrackCar");
		return 1;
	}
	if(GetPVarInt(playerid,"bpanic") != 0)
	{
	    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	    DisablePlayerCheckpoint(playerid);
		DeletePVar(playerid, "bpanic");
		return 1;
	}
	if(GetPVarInt(playerid,"igps") != 0)
	{
	    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	    DisablePlayerCheckpoint(playerid);
		DeletePVar(playerid, "igps");
		return 1;
	}
	for(new h = 0; h < MAX_POINTS; h++)
	{
		if(Points[h][Type] == 3 && GetPVarInt(playerid, "CrateDeliver") == 1 && IsPlayerInRangeOfPoint(playerid, 6.0, 2166.3772,-1675.3829,15.0859))
		{
			new string[128];
		    if(GetPVarInt(playerid, "tpDrugRunTimer") != 0)
	    	{
			   	format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) is possibly teleport drugrunning.", GetPlayerNameEx(playerid), playerid);
			   	ABroadCast( COLOR_YELLOW, string, 2 );
			   	// format(string, sizeof(string), "%s (ID %d) is possibly teleport drugrunning.", GetPlayerNameEx(playerid), playerid);
			   	// Log("logs/hack.log", string);
			}
			DisablePlayerCheckpoint(playerid);
			new level = PlayerInfo[playerid][pSmugSkill];
   			if(level >= 0 && level <= 20)
			{
			    SendClientMessageEx(playerid, COLOR_LIGHTBLUE,"* ban nhan duoc $1250 cho viec cung cap Drug Crates.");
				GivePlayerCash(playerid, 1250);
			}
			else if(level >= 21 && level <= 50)
			{
			    SendClientMessageEx(playerid, COLOR_LIGHTBLUE,"* ban nhan duoc $1500 cho viec cung cap Drug Crates.");
				GivePlayerCash(playerid, 1500);
			}
			else if(level >= 51 && level <= 100)
			{
			    SendClientMessageEx(playerid, COLOR_LIGHTBLUE,"* ban nhan duoc $2000 cho viec cung cap Drug Crates.");
				GivePlayerCash(playerid, 2000);
			}
			else if(level >= 101 && level <= 200)
			{
			    SendClientMessageEx(playerid, COLOR_LIGHTBLUE,"* ban nhan duoc $3000 cho viec cung cap Drug Crates.");
				GivePlayerCash(playerid, 3000);
			}
			else if(level >= 201)
			{
			    SendClientMessageEx(playerid, COLOR_LIGHTBLUE,"* ban nhan duoc $4000 cho viec cung cap Drug Crates.");
				GivePlayerCash(playerid, 4000);
			}
			DeletePVar(playerid, "CrateDeliver");
			PlayerInfo[playerid][pCrates] = 0;
			Points[h][Stock] += 10;

			if(DoubleXP) {
				SendClientMessageEx(playerid, COLOR_YELLOW, "You have gained 2 smuggler skill points instead of 1. (Double XP Active)");
				PlayerInfo[playerid][pSmugSkill] += 2;
				PlayerInfo[playerid][pXP] += PlayerInfo[playerid][pLevel] * XP_RATE * 2;
			}
			else
 			if(PlayerInfo[playerid][pDoubleEXP] > 0)
		    {
				format(string, sizeof(string), "You have gained 2 smuggler skill points instead of 1. You have %d hours left on the Double EXP token.", PlayerInfo[playerid][pDoubleEXP]);
				SendClientMessageEx(playerid, COLOR_YELLOW, string);
   				PlayerInfo[playerid][pSmugSkill] += 2;
				PlayerInfo[playerid][pXP] += PlayerInfo[playerid][pLevel] * XP_RATE * 2;
			}
			else
			{
  				PlayerInfo[playerid][pSmugSkill] += 1;
			}

			format(string, sizeof(string), " POT/OPIUM AVAILABLE: %d/1000.", Points[h][Stock]);
			UpdateDynamic3DTextLabelText(Points[h][TextLabel], COLOR_YELLOW, string);
			return 1;
		}
		else if(Points[h][Type] == 4 && GetPVarInt(playerid, "CrateDeliver") == 2 && IsPlayerInRangeOfPoint(playerid, 6.0, 2354.2808,-1169.2959,28.0066))
		{
			new string[128];
		    if(GetPVarInt(playerid, "tpDrugRunTimer") != 0)
	    	{
			   	format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) is possibly teleport drugrunning.", GetPlayerNameEx(playerid), playerid);
			   	ABroadCast( COLOR_YELLOW, string, 2 );
			   	// format(string, sizeof(string), "%s (ID %d) is possibly teleport drugrunning.", GetPlayerNameEx(playerid), playerid);
			   	// Log("logs/hack.log", string);
			}
			DisablePlayerCheckpoint(playerid);
			new level = PlayerInfo[playerid][pSmugSkill];
			if(level >= 0 && level <= 20)
			{
			    SendClientMessageEx(playerid, COLOR_LIGHTBLUE,"* ban nhan duoc $1250 cho viec cung cap Drug Crates.");
				GivePlayerCash(playerid, 1250);
			}
			else if(level >= 21 && level <= 50)
			{
			    SendClientMessageEx(playerid, COLOR_LIGHTBLUE,"* ban nhan duoc $1500 cho viec cung cap Drug Crates.");
				GivePlayerCash(playerid, 1500);
			}
			else if(level >= 51 && level <= 100)
			{
			    SendClientMessageEx(playerid, COLOR_LIGHTBLUE,"* ban nhan duoc $2000 cho viec cung cap Drug Crates.");
				GivePlayerCash(playerid, 2000);
			}
			else if(level >= 101 && level <= 200)
			{
			    SendClientMessageEx(playerid, COLOR_LIGHTBLUE,"* ban nhan duoc $3000 cho viec cung cap Drug Crates.");
				GivePlayerCash(playerid, 3000);
			}
			else if(level >= 201)
			{
			    SendClientMessageEx(playerid, COLOR_LIGHTBLUE,"* ban nhan duoc $4000 cho viec cung cap Drug Crates.");
				GivePlayerCash(playerid, 4000);
			}
			DeletePVar(playerid, "CrateDeliver");
			PlayerInfo[playerid][pCrates] = 0;
			Points[h][Stock] += 10;
			PlayerInfo[playerid][pSmugSkill]++;
			format(string, sizeof(string), " CRACK AVAILABLE: %d/1000.", Points[h][Stock]);
			UpdateDynamic3DTextLabelText(Points[h][TextLabel], COLOR_YELLOW, string);
			return 1;
		}
		else if(Points[h][Type] == 2 && GetPVarInt(playerid, "MatDeliver") == Points[h][MatPoint] && IsPlayerInRangeOfPoint(playerid, 6.0, Points[h][Pointx], Points[h][Pointy], Points[h][Pointz]))
		{
			if(GetPVarInt(playerid, "Packages") > 0)
			{
				new string[128];
				if(GetPVarInt(playerid, "tpMatRunTimer") != 0)
			    {
			    	format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) is possibly teleport matrunning.", GetPlayerNameEx(playerid), playerid);
			    	ABroadCast( COLOR_YELLOW, string, 2 );
			    	// format(string, sizeof(string), "%s (ID %d) is possibly teleport matrunning.", GetPlayerNameEx(playerid), playerid);
			    	// Log("logs/hack.log", string);
				}
				new payout = (25)*(GetPVarInt(playerid, "Packages"));

				if(PlayerInfo[playerid][pDonateRank] == 1)
				{
					TransferStorage(playerid, -1, -1, -1, 4, 375, -1, 2);
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Nha may da dua 375 vat lieu va cho ban 15 goi vat lieu.");
					SendClientMessageEx(playerid, COLOR_YELLOW,"Bronze VIP: ban nhan duoc 1.5x vat lieu.");

				}
				else if(PlayerInfo[playerid][pDonateRank] == 2 || PlayerInfo[playerid][pDonateRank] == 3)
				{
				    TransferStorage(playerid, -1, -1, -1, 4, 500, -1, 2);
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Nha may da dua 500 vat lieu va cho ban 20 goi vat lieu.");
					SendClientMessageEx(playerid, COLOR_YELLOW,"Silver & Gold VIP: ban nhan duoc 2x vat lieu.");

				}
				else if(PlayerInfo[playerid][pDonateRank] >= 4)
				{
				    TransferStorage(playerid, -1, -1, -1, 4, 625, -1, 2);
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Nha may da dua 625 vat lieu va cho ban 25 goi vat lieu.");
					SendClientMessageEx(playerid, COLOR_YELLOW,"Platinum VIP: ban nhan duoc 2.5x vat lieu.");

				}
				else
				{
    				TransferStorage(playerid, -1, -1, -1, 4, 250, -1, 2);
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Nha may da dua 250 vat lieu va cho ban 10 goi vat lieu.");
				}

				DeletePVar(playerid, "Packages");
				DeletePVar(playerid, "MatDeliver");
				DisablePlayerCheckpoint(playerid);

				for(new p = 0; p < sizeof(FamilyInfo); p++)
				{
					if(strcmp(Points[h][Owner], FamilyInfo[p][FamilyName], true) == 0)
					{
						FamilyInfo[p][FamilyBank] = FamilyInfo[p][FamilyBank]+(payout/3);
						//SendClientMessageEx(playerid, COLOR_WHITE, " Family owner recieved 50 percent of the cost.");
					}
				}
				return 1;
			}
		}
		else if(GetPVarInt(playerid, "MatDeliver") == 333 && IsPlayerInRangeOfPoint(playerid, 6.0, -330.44, -467.54, 0.85))
		{
			if(GetPVarInt(playerid, "Packages") > 0)
			{
				new vehicle = GetPlayerVehicleID(playerid);
				if(IsABoat(vehicle))
				{
					if(PlayerInfo[playerid][pDonateRank] == 1)
					{
				    	TransferStorage(playerid, -1, -1, -1, 4, 675, -1, 2);
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Nha may da dua 675 vat lieu va cho ban 23 goi vat lieu.");
						SendClientMessageEx(playerid, COLOR_YELLOW,"Bronze VIP: ban nhan duoc 1.5x vat lieu.");
					}
					else if(PlayerInfo[playerid][pDonateRank] == 2 || PlayerInfo[playerid][pDonateRank] == 3)
					{
				    	TransferStorage(playerid, -1, -1, -1, 4, 900, -1, 2);
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Nha may da dua 900 vat lieu va cho ban 30 goi vat lieu.");
						SendClientMessageEx(playerid, COLOR_YELLOW,"Silver & Gold VIP: ban nhan duoc 2x vat lieu.");

					}
					else if(PlayerInfo[playerid][pDonateRank] >= 4)
					{
				    	TransferStorage(playerid, -1, -1, -1, 4, 1125, -1, 2);
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Nha may da dua 1125 vat lieu va cho ban 38 goi vat lieu.");
						SendClientMessageEx(playerid, COLOR_YELLOW,"Platinum VIP: ban nhan duoc 2.5x vat lieu.");

					}
					else
					{
						TransferStorage(playerid, -1, -1, -1, 4, 450, -1, 2);
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Nha may da dua 450 vat lieu va cho ban 15 goi vat lieu.");
					}
					DeletePVar(playerid, "Packages");
					DeletePVar(playerid, "MatDeliver");
					DisablePlayerCheckpoint(playerid);
				}
				else
				{
					GameTextForPlayer(playerid, "~r~Ban khong o tren thuyen!", 3000, 1);
					return 1;
				}

				if(GetPVarInt(playerid, "tpMatRunTimer") != 0)
			    {
					new string[128];
			    	format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) is possibly teleport matrunning.", GetPlayerNameEx(playerid), playerid);
			    	ABroadCast( COLOR_YELLOW, string, 2 );
			    	// format(string, sizeof(string), "%s (ID %d) is possibly teleport matrunning.", GetPlayerNameEx(playerid), playerid);
			    	// Log("logs/hack.log", string);
				}
				return 1;
			}
		}
		else if(GetPVarInt(playerid, "MatDeliver") == 444 && IsPlayerInRangeOfPoint(playerid, 6.0, -1872.879760, 1416.312500, 7.180089))
		{
			if(GetPVarInt(playerid, "Packages") > 0)
			{
				if(PlayerInfo[playerid][pDonateRank] == 1)
				{
				    TransferStorage(playerid, -1, -1, -1, 4, 450, -1, 2);
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Nha may da dua 450 vat lieu va cho ban 18 goi vat lieu.");
					SendClientMessageEx(playerid, COLOR_YELLOW,"Bronze VIP: ban nhan duoc 1.5x vat lieu.");

				}
				else if(PlayerInfo[playerid][pDonateRank] == 2 || PlayerInfo[playerid][pDonateRank] == 3)
				{
				    TransferStorage(playerid, -1, -1, -1, 4, 600, -1, 2);
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Nha may da dua 600 vat lieu va cho ban 24 goi vat lieu.");
					SendClientMessageEx(playerid, COLOR_YELLOW,"Silver & Gold VIP: ban nhan duoc 2x vat lieu.");

				}
				else if(PlayerInfo[playerid][pDonateRank] >= 4)
				{
				    TransferStorage(playerid, -1, -1, -1, 4, 750, -1, 2);
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Nha may da dua 750 vat lieu va cho ban 30 goi vat lieu.");
					SendClientMessageEx(playerid, COLOR_YELLOW,"Platinum VIP: ban nhan duoc 2.5x vat lieu.");

				}
				else
				{
			    	TransferStorage(playerid, -1, -1, -1, 4, 300, -1, 2);
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Nha may da dua 300 vat lieu va cho ban 12 goi vat lieu.");
				}

				DeletePVar(playerid, "Packages");
				DeletePVar(playerid, "MatDeliver");
				DisablePlayerCheckpoint(playerid);

				if(GetPVarInt(playerid, "tpMatRunTimer") != 0)
			    {
					new string[128];
			    	format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) is possibly teleport matrunning.", GetPlayerNameEx(playerid), playerid);
			    	ABroadCast( COLOR_YELLOW, string, 2 );
			    	// format(string, sizeof(string), "%s (ID %d) is possibly teleport matrunning.", GetPlayerNameEx(playerid), playerid);
			    	// Log("logs/hack.log", string);
				}
				return 1;
			}
		}
		else if(GetPVarInt(playerid, "MatDeliver") == 555 && IsPlayerInRangeOfPoint(playerid, 6.0, -688.7897, 966.1434, 12.1627))
		{
			if(GetPVarInt(playerid, "Packages") > 0)
			{
				if(PlayerInfo[playerid][pDonateRank] == 1)
				{
				    TransferStorage(playerid, -1, -1, -1, 4, 450, -1, 2);
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Nha may da dua 450 vat lieu va cho ban 18 goi vat lieu.");
					SendClientMessageEx(playerid, COLOR_YELLOW,"Bronze VIP: ban nhan duoc 1.5x vat lieu.");

				}
				else if(PlayerInfo[playerid][pDonateRank] == 2 || PlayerInfo[playerid][pDonateRank] == 3)
				{
				    TransferStorage(playerid, -1, -1, -1, 4, 600, -1, 2);
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Nha may da dua 600 vat lieu va cho ban 24 goi vat lieu.");
					SendClientMessageEx(playerid, COLOR_YELLOW,"Silver & Gold VIP: ban nhan duoc 2x vat lieu.");

				}
				else if(PlayerInfo[playerid][pDonateRank] >= 4)
				{
				    TransferStorage(playerid, -1, -1, -1, 4, 750, -1, 2);
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Nha may da dua 750 vat lieu va cho ban 30 goi vat lieu.");
					SendClientMessageEx(playerid, COLOR_YELLOW,"Platinum VIP: ban nhan duoc 2.5x vat lieu.");

				}
				else
				{
			    	TransferStorage(playerid, -1, -1, -1, 4, 300, -1, 2);
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Nha may da dua 300 vat lieu va cho ban 12 goi vat lieu.");
				}

				DeletePVar(playerid, "Packages");
				DeletePVar(playerid, "MatDeliver");
				DisablePlayerCheckpoint(playerid);

				if(GetPVarInt(playerid, "tpMatRunTimer") != 0)
			    {
					new string[128];
			    	format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) is possibly teleport matrunning.", GetPlayerNameEx(playerid), playerid);
			    	ABroadCast( COLOR_YELLOW, string, 2 );
			    	// format(string, sizeof(string), "%s (ID %d) is possibly teleport matrunning.", GetPlayerNameEx(playerid), playerid);
			    	// Log("logs/hack.log", string);
				}
				return 1;
			}
		}
	}
	if(GetPVarInt(playerid, "TruckDeliver") > 0 && gPlayerCheckpointStatus[playerid] != CHECKPOINT_RETURNTRUCK)
	{
	    new vehicleid = GetPlayerVehicleID(playerid);
	    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
	    {
	        SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong o trong Truck!");
	        return 1;
	    }
	    if(TruckUsed[playerid] != INVALID_VEHICLE_ID && vehicleid != TruckUsed[playerid])
	    {
	        SendClientMessageEx(playerid, COLOR_WHITE, "Day khong phai xe Truck va hang hoa cua ban de cung cap!");
	        return 1;
	    }

		if(!IsAtTruckDeliveryPoint(playerid))
 		{// In the case the player finds a way to exploit the checkpoint to different location
			CancelTruckDelivery(playerid);
			SendClientMessageEx(playerid, COLOR_REALRED, "ERROR: Wrong checkpoint entered. Truck delivery canceled completely.");
			return 1;
   		}

		if(GetPVarInt(playerid, "tpTruckRunTimer") != 0)
		{
  			new string[128];
			format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) is possibly teleport truck/boat running.", GetPlayerNameEx(playerid), playerid);
  			ABroadCast( COLOR_YELLOW, string, 2 );
    		// format(string, sizeof(string), "%s (ID %d) is possibly teleport truckrunning.", GetPlayerNameEx(playerid), playerid);
	    	// Log("logs/hack.log", string);
		}
		new truckdeliver = GetPVarInt(playerid, "TruckDeliver");
		TruckContents{vehicleid} = 0;

		if(truckdeliver == 1)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban cung cap Thuc pham & do uong,tra lai phuong tien van chuyen cho ben cang de nhan luong cua ban.");
		}
		else if(truckdeliver == 2)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban cung cap Quan ao,tra lai phuong tien van chuyen cho ben cang de nhan luong cua ban.");
		}
		else if(truckdeliver == 3)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban cung cap Vat lieu, tra lai truvehicleck cho ben cang cua ban de nhan luong.");
		}
		else if(truckdeliver == 4)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban cung cap Vat pham 24/7,tra lai phuong tien van chuyen cho ben cang de nhan luong cua ban.");
		}
		else if(truckdeliver == 5)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban cung cap Vu khi,tra lai phuong tien van chuyen cho ben cang de nhan luong cua ban.");
		}
		else if(truckdeliver == 6)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban cung cap Mat tuy,tra lai phuong tien van chuyen cho ben cang de nhan luong cua ban.");
		}
		else if(truckdeliver == 7)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban cung cap Vat lieu khong hop phap,tra lai phuong tien van chuyen cho ben cang de nhan luong cua ban.");
		}
		DisablePlayerCheckpoint(playerid);

		gPlayerCheckpointStatus[playerid] = CHECKPOINT_RETURNTRUCK;
		if(!IsABoat(vehicleid))
		{
			SetPlayerCheckpoint(playerid, -1548.087524, 123.590423, 3.554687, 5);
			GameTextForPlayer(playerid, "~w~Dia diem ~r~Ben cang San Fierro", 5000, 1);
			SendClientMessageEx(playerid, COLOR_WHITE, "HINT: Quay tro lai ben cang San Fierro (diem checkpoint tren radar).");
		}
		else
		{
			SetPlayerCheckpoint(playerid, 2098.6543,-104.3568,-0.4820, 5);
			GameTextForPlayer(playerid, "~w~Dia diem ~r~Ben cang Palamino", 5000, 1);
			SendClientMessageEx(playerid, COLOR_WHITE, "HINT: Quay tro lai ben cang Palamino (diem checkpoint tren radar).");
		}

		SetPVarInt(playerid, "tpTruckRunTimer", 30);
		SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_TPTRUCKRUNTIMER);
		return 1;
	}
	if(gPlayerCheckpointStatus[playerid] == CHECKPOINT_DELIVERY)
	{
	    new vehicleid = GetPlayerVehicleID(playerid);
	    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
	    {
	        SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong o tren xe truck!");
	        return 1;
	    }
	    if(TruckUsed[playerid] != INVALID_VEHICLE_ID && vehicleid != TruckUsed[playerid])
	    {
	        SendClientMessageEx(playerid, COLOR_WHITE, "Day khong phai xe va hang hoa cua ban can van chuyen!");
	        return 1;
	    }

		new business = TruckDeliveringTo[vehicleid];

		if (!IsPlayerInRangeOfPoint(playerid, 20.0, Businesses[business][bSupplyPos][0], Businesses[business][bSupplyPos][1], Businesses[business][bSupplyPos][2])) return 1;

		if(GetPVarInt(playerid, "tpTruckRunTimer") != 0)
		{
  			new string[128];
			format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) is possibly teleport truck/boat running.", GetPlayerNameEx(playerid), playerid);
  			ABroadCast( COLOR_YELLOW, string, 2 );
    		// format(string, sizeof(string), "%s (ID %d) is possibly teleport truckrunning.", GetPlayerNameEx(playerid), playerid);
	    	// Log("logs/hack.log", string);
		}

		new string[128];
		format(string, sizeof(string), "* Ban da gui %s den %s. Tra lai xe tai toi ben cang San Fierro de nhan tien.", GetInventoryType(business), Businesses[business][bName]);
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, string);

		Businesses[business][bOrderState] = 3;
		Businesses[business][bInventory] += Businesses[business][bOrderAmount];
		foreach (new i: Player)
		{
			if (PlayerInfo[i][pBusiness] == business) SendClientMessageEx(i, COLOR_WHITE, "An order has just been delivered to your business.");
		}

		/*if (Businesses[business][bType] == BUSINESS_TYPE_NEWCARDEALERSHIP)
		{
		    new iSlot = GetPVarInt(playerid, "CarryingSlot");
		    new iVehicle = GetPVarInt(playerid , "CarryingVehicle");
		    if (GetDistanceToCar(playerid, iVehicle) > 10.0) return SendClientMessageEx(playerid, COLOR_WHITE, "The vehicle is not with you.");
			Businesses[business][DealershipVehStock][iSlot] = 1;
			SetVehiclePos(iVehicle, Businesses[business][bParkPosX][iSlot], Businesses[business][bParkPosY][iSlot], Businesses[business][bParkPosZ][iSlot]);
			SetVehicleZAngle(iVehicle, Businesses[business][bParkAngle][iSlot]);
			DeletePVar(playerid, "CarryingSlot");
			DeletePVar(playerid, "CarryingVehicle");
		}*/
		if (Businesses[business][bType] == BUSINESS_TYPE_GASSTATION)
		{
			for (new i; i < MAX_BUSINESS_GAS_PUMPS; i++)
			{
				Businesses[business][GasPumpGallons][i] = Businesses[business][GasPumpCapacity][i];
			}
			DestroyVehicle(GetVehicleTrailer(vehicleid));
			DeletePVar(playerid, "Gas_TrailerID");
		}
		SaveBusiness(business);
		DisablePlayerCheckpoint(playerid);

		gPlayerCheckpointStatus[playerid] = CHECKPOINT_RETURNTRUCK;
		SetPlayerCheckpoint(playerid, -1548.087524, 123.590423, 3.554687, 5);
		GameTextForPlayer(playerid, "~w~Dia diem ~r~Ben cang San Fierro", 5000, 1);
		SendClientMessageEx(playerid, COLOR_WHITE, "HINT: Quay lai ben cang San Fierro (diem checkpoint tren radar).");

		//SetPVarInt(playerid, "tpTruckRunTimer", 30);
		//SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_TPTRUCKRUNTIMER);
		return 1;
	}
	// Pizza Delivery
	if(GetPVarInt(playerid, "Pizza") > 0 && IsPlayerInRangeOfPoint(playerid, 5.0, HouseInfo[GetPVarInt(playerid, "Pizza")-1][hExteriorX], HouseInfo[GetPVarInt(playerid, "Pizza")-1][hExteriorY], HouseInfo[GetPVarInt(playerid, "Pizza")-1][hExteriorZ]) && GetPlayerInterior(playerid) == HouseInfo[GetPVarInt(playerid, "Pizza")-1][hExtIW] && GetPlayerVirtualWorld(playerid) == HouseInfo[GetPVarInt(playerid, "Pizza")-1][hExtVW])
	{
	    new string[128];
		if (GetPVarInt(playerid, "tpPizzaTimer") != 0)
		{
			format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) is possibly teleport pizzarunning.", GetPlayerNameEx(playerid), playerid);
  			ABroadCast( COLOR_YELLOW, string, 2 );
    		// format(string, sizeof(string), "%s (ID %d) is possibly teleport pizzarunning.", GetPlayerNameEx(playerid), playerid);
	    	// Log("logs/hack.log", string);
		}
		format(string, sizeof(string), "Ban da van chuyen banh pizza toi dich! Ban nhan duoc $%d tien banh.", (GetPVarInt(playerid, "pizzaTimer") * 70));
		Misc_Save();
		GivePlayerCash(playerid, floatround((GetPVarInt(playerid, "pizzaTimer") * 70), floatround_round));
		SendClientMessageEx(playerid, COLOR_WHITE, string);
		DeletePVar(playerid, "Pizza");
		DisablePlayerCheckpoint(playerid);

	}
	if(GetPVarInt(playerid, "Finding")>=1)
	{
	    DeletePVar(playerid, "Finding");
	    DisablePlayerCheckpoint(playerid);
	    GameTextForPlayer(playerid, "~w~Reached destination", 5000, 1);
	}
	if(TaxiCallTime[playerid] > 0 && TaxiAccepted[playerid] != INVALID_PLAYER_ID)
	{
		TaxiAccepted[playerid] = INVALID_PLAYER_ID;
		GameTextForPlayer(playerid, "~w~Reached destination", 5000, 1);
		TaxiCallTime[playerid] = 0;
		DisablePlayerCheckpoint(playerid);
	}
	else if(EMSCallTime[playerid] > 0 && EMSAccepted[playerid] != INVALID_PLAYER_ID)
	{
	    if(GetPVarInt(EMSAccepted[playerid], "Injured") == 1)
	    {
	    	SendEMSQueue(EMSAccepted[playerid],2);
	    	EMSAccepted[playerid] = INVALID_PLAYER_ID;
	    	GameTextForPlayer(playerid, "~w~Reached destination", 5000, 1);
	    	EMSCallTime[playerid] = 0;
	    	DisablePlayerCheckpoint(playerid);
		}
		else
		{
            EMSAccepted[playerid] = INVALID_PLAYER_ID;
		    GameTextForPlayer(playerid, "~r~Patient has died", 5000, 1);
		    EMSCallTime[playerid] = 0;
	    	DisablePlayerCheckpoint(playerid);
		}
	}
	else if(BusCallTime[playerid] > 0 && BusAccepted[playerid] != INVALID_PLAYER_ID)
	{
		BusAccepted[playerid] = INVALID_PLAYER_ID;
		GameTextForPlayer(playerid, "~w~Reached destination", 5000, 1);
		BusCallTime[playerid] = 0;
		DisablePlayerCheckpoint(playerid);
	}
	else if(MedicCallTime[playerid] > 0 && MedicAccepted[playerid] != INVALID_PLAYER_ID)
	{
		MedicAccepted[playerid] = INVALID_PLAYER_ID;
		GameTextForPlayer(playerid, "~w~Reached patient", 5000, 1);
		MedicCallTime[playerid] = 0;
		DisablePlayerCheckpoint(playerid);
	}
	else
	{
		switch (gPlayerCheckpointStatus[playerid])
		{
			case CHECKPOINT_HOME:
			{
				PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);
				new i = hInviteHouse[playerid];
				DisablePlayerCheckpoint(playerid);
				gPlayerCheckpointStatus[playerid] = CHECKPOINT_NONE;
				SetPlayerInterior(playerid,HouseInfo[i][hIntIW]);
				SetPlayerPos(playerid,HouseInfo[i][hInteriorX],HouseInfo[i][hInteriorY],HouseInfo[i][hInteriorZ]);
				GameTextForPlayer(playerid, "~w~Welcome Home", 5000, 1);
				PlayerInfo[playerid][pInt] = HouseInfo[i][hIntIW];
				PlayerInfo[playerid][pVW] = HouseInfo[i][hIntVW];
				SetPlayerVirtualWorld(playerid,HouseInfo[i][hIntVW]);
				if(HouseInfo[i][hCustomInterior] == 1) Player_StreamPrep(playerid, HouseInfo[i][hInteriorX],HouseInfo[i][hInteriorY],HouseInfo[i][hInteriorZ], FREEZE_TIME);
				hInviteOffer[playerid] = INVALID_PLAYER_ID;
				hInviteHouse[playerid] = INVALID_HOUSE_ID;
			}
			case CHECKPOINT_LOADTRUCK:
			{
			    if(IsPlayerInRangeOfPoint(playerid, 6, -1572.767822, 81.137527, 3.554687) || IsPlayerInRangeOfPoint(playerid, 6, 2098.6543,-104.3568,-0.4820))
			    {
				    new vehicleid = GetPlayerVehicleID(playerid);
	   				if(IsATruckerCar(vehicleid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		    		{
				    	PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);
				    	DisablePlayerCheckpoint(playerid);
				    	gPlayerCheckpointStatus[playerid] = CHECKPOINT_NONE;
						TogglePlayerControllable(playerid, false);
						SetPVarInt(playerid, "IsFrozen", 1);
						DisplayOrders(playerid);
					}
					else return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong lai dung xe tai hoac tau truck!");
				}
			}
			case CHECKPOINT_RETURNTRUCK:
			{
			    if(!IsPlayerInRangeOfPoint(playerid, 6, -1548.087524, 123.590423, 3.554687) && !IsPlayerInRangeOfPoint(playerid, 6, 2098.6543,-104.3568,-0.4820))
			    {// In the case the person finds a way to exploit the checkpoint to different location
                    CancelTruckDelivery(playerid);
                    SendClientMessageEx(playerid, COLOR_REALRED, "ERROR: Wrong checkpoint entered. Truck delivery canceled completely.");
					return 1;
			    }
 				if(GetPVarInt(playerid, "tpTruckRunTimer") != 0)
				{
  					new string[128];
					format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) is possibly teleport truck/boat running.", GetPlayerNameEx(playerid), playerid);
  					ABroadCast( COLOR_YELLOW, string, 2 );
    				// format(string, sizeof(string), "%s (ID %d) is possibly teleport truckrunning.", GetPlayerNameEx(playerid), playerid);
	    			// Log("logs/hack.log", string);
				}
   				new vehicleid = GetPlayerVehicleID(playerid);
				if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
	    		{
	        		SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong o trong xe van chuyen hang!");
	        		return 1;
	    		}
	    		if(TruckUsed[playerid] != INVALID_VEHICLE_ID && vehicleid != TruckUsed[playerid])
	    		{
	        		SendClientMessageEx(playerid, COLOR_WHITE, "Day khong phai la chiec xe cua ban van chuyen hang, vui long su dung dung xe cua ban de nhan thu lao!");
	        		return 1;
	    		}

			    PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);
			    DisablePlayerCheckpoint(playerid);
			    gPlayerCheckpointStatus[playerid] = CHECKPOINT_NONE;
				new route = TruckRoute[vehicleid];
   				new string[128], payment;
				new level = PlayerInfo[playerid][pTruckSkill];
				if(level >= 0 && level <= 50) payment = 4000;
				else if(level >= 51 && level <= 100) payment = 6250;
				else if(level >= 101 && level <= 200) payment = 8500;
				else if(level >= 201 && level <= 400) payment = 9750;
				else if(level >= 401) payment = 10500;
				new Float:distancepay;
				if(IsABoat(vehicleid))
				{
				    distancepay = floatmul(GetDistance(2098.6543,-104.3568,-0.4820, BoatDropoffs[route][PosX], BoatDropoffs[route][PosY], BoatDropoffs[route][PosZ]), 1.5);
				}
				else
				{
				    distancepay = floatmul(GetDistance(-1572.767822, 81.137527, 3.554687, TruckerDropoffs[route][PosX], TruckerDropoffs[route][PosY], TruckerDropoffs[route][PosZ]), 1.5);
				}
				payment += floatround(distancepay);
				if(TruckDeliveringTo[vehicleid] != INVALID_BUSINESS_ID) {
					new iBusiness = TruckDeliveringTo[vehicleid];
			 		new Float: iDist = GetPlayerDistanceFromPoint(playerid, Businesses[iBusiness][bSupplyPos][0], Businesses[iBusiness][bSupplyPos][1], Businesses[iBusiness][bSupplyPos][2]);

				 	payment = floatround(iDist / 3000 * payment);
					if (payment > 25000) payment = 25000;

					GivePlayerCash(playerid, payment);
					format(string, sizeof(string), "* Ban duoc tra $%d cho viec van chuyen hang hoa va tra lai xe.", payment);

				    SendClientMessageEx(playerid, COLOR_LIGHTBLUE, string);
				    SetVehicleToRespawn(vehicleid);
				}
				else {
				    DeletePVar(playerid, "LoadType");
				    new truckdeliver = GetPVarInt(playerid, "TruckDeliver");
					TruckContents{vehicleid} = 0;

					if(truckdeliver >= 1 && truckdeliver <= 5)
					{
						GivePlayerCash(playerid, payment);
						format(string, sizeof(string), "* Ban duoc tra $%d cho viec van chuyen hang hoa va tra lai xe.", payment);
					}
					else if(truckdeliver >= 5 && truckdeliver <= 7)
					{
						payment = floatround(payment * 1.25);
						GivePlayerCash(playerid, payment);
		    			format(string, sizeof(string), "* Ban duoc tra $%d cho viec van chuyen hang hoa va tra lai xe.", payment);
		    			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* ban nhan duoc 25 phan tram tien thuong do rui ro cua hang hoa.");

					}
				    SendClientMessageEx(playerid, COLOR_LIGHTBLUE, string);
					if(truckdeliver == 5) // Weapons
					{
						if(PlayerInfo[playerid][pConnectHours] >= 2 && PlayerInfo[playerid][pWRestricted] <= 0)
						{
							if(level >= 0 && level <= 50)
							{
								SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan duoc mien phi 9mm cho viec van chuyen vu khi trai phep.");
								GivePlayerValidWeapon(playerid, 22, 60000);
							}
							else if(level >= 51 && level <= 100)
							{
								SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan duoc mien phi Shotgun cho viec van chuyen vu khi trai phep.");
								GivePlayerValidWeapon(playerid, 25, 60000);
							}
							else if(level >= 101 && level <= 200)
							{
								SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan duoc mien phi MP5 cho viec van chuyen vu khi trai phep.");
								GivePlayerValidWeapon(playerid, 29, 60000);
							}
							else if(level >= 201 && level <= 400)
							{
								SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan duoc mien phi Deagle cho viec van chuyen vu khi trai phep.");
								GivePlayerValidWeapon(playerid, 24, 60000);
							}
							else if(level >= 401)
							{
								SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban nhan duoc mien phi AK-47 cho viec van chuyen vu khi trai phep.");
								GivePlayerValidWeapon(playerid, 30, 60000);
							}
						}
						else
						{
							SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban khong nhan duoc vu khi do ban co mot lenh gioi han vu khi.");
						}
					}
					if(truckdeliver == 6) // Drugs
					{

						if(level >= 0 && level <= 50)
						{
		                    SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da nhan duoc 2 pot & 1 cho viec van chuyen ma tuy bat hop phap.");
						    PlayerInfo[playerid][pPot] += 2;
						    PlayerInfo[playerid][pCrack] += 1;
						}
						else if(level >= 51 && level <= 100)
						{
		                    SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da nhan duoc 4 pot & 2 cho viec van chuyen ma tuy bat hop phap.");
					    	PlayerInfo[playerid][pPot] += 4;
					    	PlayerInfo[playerid][pCrack] += 2;
						}
						else if(level >= 101 && level <= 200)
						{
		                    SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da nhan duoc 6 pot & 3 cho viec van chuyen ma tuy bat hop phap.");
					    	PlayerInfo[playerid][pPot] += 6;
					    	PlayerInfo[playerid][pCrack] += 3;
						}
						else if(level >= 201 && level <= 400)
						{
		                    SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da nhan duoc 8 pot & 4 cho viec van chuyen ma tuy bat hop phap.");
					  	  	PlayerInfo[playerid][pPot] += 8;
					    	PlayerInfo[playerid][pCrack] += 4;
						}
						else if(level >= 401)
						{
		                    SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da nhan duoc 10 pot & 5 cho viec van chuyen ma tuy bat hop phap.");
					   	 	PlayerInfo[playerid][pPot] += 10;
					    	PlayerInfo[playerid][pCrack] += 5;
						}
					}
					if(truckdeliver == 7) // Illegal materials
					{
						if(level >= 0 && level <= 50)
						{
		                    SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da nhan duoc 100 cho viec van chuyen vat lieu bat hop phap.");
							PlayerInfo[playerid][pMats] += 100;
						}
						else if(level >= 51 && level <= 100)
						{
		                    SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da nhan duoc 200 cho viec van chuyen vat lieu bat hop phap.");
							PlayerInfo[playerid][pMats] += 200;
						}
						else if(level >= 101 && level <= 200)
						{
		                    SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da nhan duoc 400 cho viec van chuyen vat lieu bat hop phap.");
							PlayerInfo[playerid][pMats] += 400;
						}
						else if(level >= 201 && level <= 400)
						{
		                    SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da nhan duoc 600 cho viec van chuyen vat lieu bat hop phap.");
							PlayerInfo[playerid][pMats] += 600;
						}
						else if(level >= 401)
						{
		                    SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da nhan duoc 1000 cho viec van chuyen vat lieu bat hop phap.");
							PlayerInfo[playerid][pMats] += 1000;
						}
					}
				    SetVehicleToRespawn(vehicleid);
				}
				if(DoubleXP) {
					SendClientMessageEx(playerid, COLOR_YELLOW, "Ban da duoc 2 diem ky nang truck thay vi 1 diem. (Nhan doi XP)");
					PlayerInfo[playerid][pTruckSkill] += 2;
					PlayerInfo[playerid][pXP] += PlayerInfo[playerid][pLevel] * XP_RATE * 2;
				}
				else
				if(PlayerInfo[playerid][pDoubleEXP] > 0 && !DoubleXP)
				{
					format(string, sizeof(string), "Ban da duoc 2 ky nang truck thay vi 1 diem. Ban co %d gio con lai de nhan doi EXP token.", PlayerInfo[playerid][pDoubleEXP]);
					SendClientMessageEx(playerid, COLOR_YELLOW, string);
					PlayerInfo[playerid][pTruckSkill] += 2;
					PlayerInfo[playerid][pXP] += PlayerInfo[playerid][pLevel] * XP_RATE * 2;
				}
				else
				{
					PlayerInfo[playerid][pTruckSkill] += 1;
					PlayerInfo[playerid][pXP] += PlayerInfo[playerid][pLevel] * XP_RATE;
				}

				TruckUsed[playerid] = INVALID_VEHICLE_ID;
				DeletePVar(playerid, "TruckDeliver");

				new mypoint = -1;
				for (new i=0; i<MAX_POINTS; i++)
				{
					if(strcmp(Points[i][Name], "San Fierro Docks", true) == 0)
					{
						mypoint = i;
					}
				}
				for(new i = 0; i < sizeof(FamilyInfo); i++)
				{
					if(strcmp(Points[mypoint][Owner], FamilyInfo[i][FamilyName], true) == 0)
					{
						Misc_Save();
						FamilyInfo[i][FamilyBank] = FamilyInfo[i][FamilyBank]+(200);
					}
			 	}
			}
			case CHECKPOINT_HITMAN:
			{
			    PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);
			    DisablePlayerCheckpoint(playerid);
			    gPlayerCheckpointStatus[playerid] = CHECKPOINT_NONE;
			    SendClientMessageEx(playerid, COLOR_GRAD2, "  Su dung /enter de vao HQ.");
			}
			case CHECKPOINT_HITMAN2:
			{
			    PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);
			    DisablePlayerCheckpoint(playerid);
			    gPlayerCheckpointStatus[playerid] = CHECKPOINT_NONE;
			    SendClientMessageEx(playerid, COLOR_GRAD2, "  Su dung /enter de vao HQ.");
			}
			case CHECKPOINT_HITMAN3:
			{
			    PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);
			    DisablePlayerCheckpoint(playerid);
			    gPlayerCheckpointStatus[playerid] = CHECKPOINT_NONE;
			    SendClientMessageEx(playerid, COLOR_GRAD2, "  Su dung /order de su dung vu khi  cua ban.");
			}
		}
	}
	if (GetPVarInt(playerid, "_SwimmingActivity") > 0)
	{
		new stage = GetPVarInt(playerid, "_SwimmingActivity");

		switch (stage)
		{
			case 1:
			{
				SetPlayerCheckpoint(playerid, 2889.5471, -2269.0251, 0.2176, 2.0);
				SetPVarInt(playerid, "_SwimmingActivity", 2);
			}

			case 2:
			{
				SetPlayerCheckpoint(playerid, 2839.7312, -2268.6123, -0.9815, 2.0);
				SetPVarInt(playerid, "_SwimmingActivity", 3);
			}

			case 3:
			{
				SetPlayerCheckpoint(playerid, 2839.5469, -2281.9521, -0.8549, 2.0);
				SetPVarInt(playerid, "_SwimmingActivity", 4);
			}

			case 4:
			{
				SetPlayerCheckpoint(playerid, 2888.1426, -2284.0317, 0.1347, 2.0);
				SetPVarInt(playerid, "_SwimmingActivity", 5);
			}

			case 5:
			{
				SetPlayerCheckpoint(playerid, 2889.5471, -2269.0251, 0.2176, 2.0);
				SetPVarInt(playerid, "_SwimmingActivity", 6);
			}

			case 6:
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "Tap hoan thanh! The luc cua ban da tang len dang ke.");
				if (PlayerInfo[playerid][pFitness] != 100) PlayerInfo[playerid][pFitness] += 3;
				SendClientMessageEx(playerid, COLOR_WHITE, "Neu ban tap luyen xong, su dung /stopswimming.");
				SetPVarInt(playerid, "_SwimmingActivity", 3);
				SetPlayerCheckpoint(playerid, 2839.7312, -2268.6123, -0.9815, 2.0);
			}
		}
	}

	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(newkeys & KEY_NO)
    {
        if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
       {
            new engine, lights, alarm, doors, bonnet, boot, objective,vehicleid;
            vehicleid = GetPlayerVehicleID(playerid);
            if(GetVehicleModel(vehicleid) == 481 || GetVehicleModel(vehicleid) == 509 || GetVehicleModel(vehicleid) == 510) return SendClientMessageEx(playerid,COLOR_WHITE,"Lenh nay khong the su dung trong chiec xe nay.");
            GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
            if(engine == VEHICLE_PARAMS_ON)
            {
            SetVehicleEngine(vehicleid, playerid);
            }
            else if((engine == VEHICLE_PARAMS_OFF || engine == VEHICLE_PARAMS_UNSET))
            {
            new string[128];
            format(string, sizeof(string), "{FF8000}** {C2A2DA}%s dua chia khoa vao o va bat dong co xe.", GetPlayerNameEx(playerid));
            ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
            SendClientMessageEx(playerid, COLOR_WHITE, "Dong co xe dang duoc mo, xin vui long doi....");
            SetTimerEx("SetVehicleEngine", 1000, false, "dd",  vehicleid, playerid);
            }
        }
    }
	if(GetPVarInt(playerid, "Injured") == 1) return 1;
	if(newkeys & KEY_SECONDARY_ATTACK)
	{
	    new string[128];
	    if(!GetPVarType(playerid, "Tackling"))	{
	        if(GetPVarInt(playerid, "TackleMode") == 1 && GetPlayerTargetPlayer(playerid) != INVALID_PLAYER_ID && PlayerCuffed[GetPlayerTargetPlayer(playerid)] == 0 && ProxDetectorS(4.0, playerid, GetPlayerTargetPlayer(playerid)) && !IsPlayerNPC(GetPlayerTargetPlayer(playerid)))
	        {
		        if(GetPVarInt(playerid, "CopTackleCooldown") != 0)
		        {
		            format(string, sizeof(string), "Ban dang kiet suc! Phai doi %d giay de co the tiep tuc lai.", GetPVarInt(playerid, "CopTackleCooldown"));
		            return SendClientMessageEx(playerid, COLOR_GRAD2, string);
		        }
	            if(PlayerInfo[GetPlayerTargetPlayer(playerid)][pAdmin] >= 2 && PlayerInfo[GetPlayerTargetPlayer(playerid)][pTogReports] != 1)
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Admins can not be tackled!");
					return 1;
				}
				#if defined zombiemode
				if(GetPVarInt(GetPlayerTargetPlayer(playerid), "pIsZombie"))
				{
				    SendClientMessageEx(playerid, COLOR_GRAD2, "Zombies can not be tackled!");
					return 1;
				}
				#endif
	            if(PlayerInfo[playerid][pFitness] >= PlayerInfo[GetPlayerTargetPlayer(playerid)][pFitness]) // Player is more fit or as fit as the player they are tackling
	            {
			        TacklePlayer(playerid, GetPlayerTargetPlayer(playerid));
	            }
	            else if(PlayerInfo[playerid][pFitness] < PlayerInfo[GetPlayerTargetPlayer(playerid)][pFitness])
	            {
					new tacklechance = random(10);
					switch(tacklechance)
					{
					    case 0..6: //success
					    {
					        TacklePlayer(playerid, GetPlayerTargetPlayer(playerid));
						}
					    default: // fail
					    {
							format(string, sizeof(string), "** %s leaps at %s attempting to tackle them but is not able.", GetPlayerNameEx(playerid), GetPlayerNameEx(GetPlayerTargetPlayer(playerid)));
							ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
							TogglePlayerControllable(playerid, false);
							SetTimerEx("CopGetUp", 2500, false, "i", playerid);
							ApplyAnimation(playerid, "SWEET", "Sweet_injuredloop", 4.0, true, true, true, true, 0, 1);
					    }
					}
	            }
	        }
		}
	}
    if(newkeys & KEY_NO)
	{
		if(InsideTradeToys[playerid] == 1)
		{
			if(IsPlayerConnected(GetPVarInt(playerid, "ttSeller")))
			{
				new string[128];
				format(string, sizeof(string), "%s ban tu choi loi de nghi mua toy.", GetPlayerNameEx(playerid));
				SendClientMessageEx(GetPVarInt(playerid, "ttSeller"), COLOR_LIGHTBLUE, string);
				SendClientMessageEx(playerid, COLOR_LIGHTRED, "Ban tu choi loi de nghi mua toy.");
				
				SetPVarInt(GetPVarInt(playerid, "ttSeller"), "ttBuyer", INVALID_PLAYER_ID);
				SetPVarInt(GetPVarInt(playerid, "ttSeller"), "ttCost", 0);
				SetPVarInt(playerid, "ttSeller", INVALID_PLAYER_ID);
				
				HideTradeToysGUI(playerid);
				return 1;
				}
				else {
				SendClientMessageEx(playerid, COLOR_LIGHTRED, "Nguoi de nghi giao dich da thoat ket noi may chu.");
				SetPVarInt(playerid, "ttSeller", INVALID_PLAYER_ID);
				
				HideTradeToysGUI(playerid);
			}	
		}
	}
    if(newkeys & KEY_YES)
    {
		if(InsideTradeToys[playerid] == 1)
		{		
			if(IsPlayerConnected(GetPVarInt(playerid, "ttSeller")))
			{
				ShowPlayerDialog(playerid, CONFIRMSELLTOY, DIALOG_STYLE_MSGBOX, "Vui long xac nhan lua chon cua ban", "Ban co chac chan muon mua toy nay voi so tien quy dinh?", "Dong y", "Khong");
			}
			else {
				SendClientMessageEx(playerid, COLOR_LIGHTRED, "Nguoi de nghi giao dich da thoat ket noi may chu.");
				SetPVarInt(playerid, "ttSeller", INVALID_PLAYER_ID);
				
				HideTradeToysGUI(playerid);
			}	
		}
        if(InsideTut{playerid} > 0)
		{
			TutorialStep(playerid);
			TogglePlayerControllable(playerid, false);
			return 1;
		}
		if(GetPVarType(playerid, "Tackling"))	{
		    CopGetUp(playerid);
		    ClearTackle(GetPVarInt(playerid, "Tackling"));
		    return 1;
		}
        if(GetPlayerTargetPlayer(playerid) != INVALID_PLAYER_ID && ProxDetectorS(5.0, playerid, GetPlayerTargetPlayer(playerid)) && !IsPlayerNPC(GetPlayerTargetPlayer(playerid)))
        {
            if(GetPVarInt(playerid, "TackleMode") == 1) {
		    	return 1;
			}
            new string[64];
			new name[MAX_PLAYER_NAME+8];
			format(name, sizeof(name), "{FF0000}%s", GetPlayerNameEx(GetPlayerTargetPlayer(playerid)));
			SetPVarString(playerid, "pInteractName", name);
			SetPVarInt(playerid, "pInteractID", GetPlayerTargetPlayer(playerid));
            format(string, sizeof(string), "Pay\nGive\n");
            /*if (PlayerInfo[playerid][pJob] == 9 || PlayerInfo[playerid][pJob2] == 9)
			{
			    format(string, sizeof(string), "%sSell Gun\n", string);
			}
			if(PlayerInfo[playerid][pJob] == 9 || PlayerInfo[playerid][pJob2] == 9 || PlayerInfo[playerid][pJob] == 18 || PlayerInfo[playerid][pJob2] == 18)
			{
			    format(string, sizeof(string), "%sSell Mats\n", string);
			}
			if(PlayerInfo[playerid][pJob] == 4 || PlayerInfo[playerid][pJob2] == 4)
			{
			    format(string, sizeof(string), "%sSell Pot\nSell Crack\n", string);
			}
			if(PlayerInfo[playerid][pJob] == 8 || PlayerInfo[playerid][pJob2] == 8)
			{
			    format(string, sizeof(string), "%sGuard\n", string);
			}
			if(PlayerInfo[playerid][pJob] == 19 || PlayerInfo[playerid][pJob2] == 19)
			{
			    format(string, sizeof(string), "%sSell Drink\n", string);
			}*/
			ShowPlayerDialog(playerid, INTERACTMAIN, DIALOG_STYLE_LIST, name, string, "Lua chont", "Huy bo");
        }
    }
	// If the client clicked the fire key and is currently injured
	else if((newkeys && KEY_FIRE) && GetPVarInt(playerid, "Injured") == 1)
	{
		ClearAnimations(playerid);
		return 1;
	}
	else if((newkeys & KEY_FIRE) && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && GetPlayerWeapon(playerid) == SPEEDGUN && GetPVarType(playerid, "SpeedRadar"))
	{
	    if(GetPVarInt(playerid, "RadarTimeout") == 0)
	    {
			new Float:x,Float:y,Float:z;
			foreach(new i: Player)
			{
				if(IsPlayerStreamedIn(i, playerid))
				{
					GetPlayerPos(i,x,y,z);
					if(IsPlayerAimingAt(playerid,x,y,z,10))
					{
						new string[68];
						format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~b~Bien so xe: ~w~%d~n~~b~Toc do: ~w~%.0f MPH", GetPlayerVehicleID(i), fVehSpeed[i]);
						GameTextForPlayer(playerid, string,3500, 3);
						format(string, sizeof(string), "Bien so xe: %d. Toc do: %.0f MPH", GetPlayerVehicleID(i), fVehSpeed[i]);
						SendClientMessageEx(playerid, COLOR_GRAD4, string);
						SetPVarInt(playerid, "RadarTimeout", 1);
						SetTimerEx("RadarCooldown", 3000, false, "i", playerid);
						return 1;
					}
				}
			}
		}
	}
	else if((newkeys & 16) && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && PlayerCuffed[playerid] == 0 && PlayerInfo[playerid][pBeingSentenced] == 0 && GetPVarType(playerid,"UsingAnim") && !GetPVarType(playerid, "IsFrozen"))
	{
		ClearAnimations(playerid);
		DeletePVar(playerid,"UsingAnim");
	}
	else if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_DRINK_BEER && (newkeys & KEY_FIRE))
	{
	    if(GetPVarInt(playerid, "DrinkCooledDown") == 1)
	    {
			new Float: cHealth;
			GetPlayerHealth(playerid, cHealth);
		    if(cHealth < 100)
		    {
				SetPlayerHealth(playerid, cHealth+5);
		    }
		    else
		    {
		        SendClientMessageEx(playerid, COLOR_GREY, "* Ban ket thuc uong va vut bo no di.");
		        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
		    }
			DeletePVar(playerid, "DrinkCooledDown");
		    SetTimerEx("DrinkCooldown", 2500, false, "i", playerid);
			return 1;
		}
	}
	else if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_DRINK_WINE && (newkeys & KEY_FIRE))
	{
	    if(GetPVarInt(playerid, "DrinkCooledDown") == 1)
	    {
			new Float: cHealth;
			GetPlayerHealth(playerid, cHealth);
		    if(cHealth < 100)
		    {
				SetPlayerHealth(playerid, cHealth+8);
		    }
		    else
		    {
		        SendClientMessageEx(playerid, COLOR_GREY, "* Ban ket thuc uong va vut bo no di.");
		        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
		    }
			DeletePVar(playerid, "DrinkCooledDown");
		    SetTimerEx("DrinkCooldown", 2500, false, "i", playerid);
			return 1;
		}
	}

	else if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_DRINK_SPRUNK && (newkeys & KEY_FIRE))
	{
		if(GetPVarInt(playerid, "DrinkCooledDown") == 1 && GetPVarInt(playerid, "UsingSprunk") == 1)
		{
			new Float: cHealth;
			GetPlayerHealth(playerid, cHealth);
			if(cHealth < 100)
			{
				SetPlayerHealth(playerid, cHealth+2);
			}
			else
			{
				DeletePVar(playerid, "UsingSprunk");
				SendClientMessageEx(playerid, COLOR_GREY, "* Ban ket thuc uong va vut bo no di.");
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
			}
			DeletePVar(playerid, "DrinkCooledDown");
			SetTimerEx("DrinkCooldown", 2500, false, "i", playerid);
			return 1;
		}
	}
	else if(IsKeyJustDown(KEY_SECONDARY_ATTACK, newkeys, oldkeys))
	{
	    if(GetPVarInt(playerid, "NGPassenger") == 1)
	    {
	        TogglePlayerSpectating(playerid, true);
		}
		if(GetPVarInt(playerid, "UsingSprunk"))
		{
			DeletePVar(playerid, "UsingSprunk");
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
			return 1;
		}
	}
	else if(!IsPlayerInAnyVehicle(playerid) && newkeys & KEY_CTRL_BACK)
	{

	    new Float:pos[3];
	    GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	    if(pos[1] < -1301.4 && pos[1] > -1303.2417 && pos[0] < 1786.2131 && pos[0] > 1784.1555)
		{    // He is using the elevator button
		    PlayerPlaySound(playerid, 1083, 0.0, 0.0, 0.0);
		    ApplyAnimation(playerid, "HEIST9", "Use_SwipeCard", 10.0, false, false, false, false, 0);
	        ShowElevatorDialog(playerid, 1);
		}
		else    // Is he in a floor button?
		{
		    if(pos[1] > -1301.4 && pos[1] < -1299.1447 && pos[0] < 1785.6147 && pos[0] > 1781.9902)
		    {
		        // He is most likely using it, check floor:
				new i=20;
				while(pos[2] < GetDoorsZCoordForFloor(i) + 3.5 && i > 0)
				    i --;

				if(i == 0 && pos[2] < GetDoorsZCoordForFloor(0) + 2.0)
				    i = -1;

				if(i <= 19)
				{
				    PlayerPlaySound(playerid, 1083, 0.0, 0.0, 0.0);
		    		ApplyAnimation(playerid, "HEIST9", "Use_SwipeCard", 10.0, false, false, false, false, 0);
					CallElevator(playerid, i + 1);
					GameTextForPlayer(playerid, "~r~Yeu cau thanh may", 3500, 4);
				}
		    }
		}
	}
	else if(IsKeyJustDown(128, newkeys, oldkeys))
	{
	    if(ConfigEventCPs[playerid][1] == 1 && ConfigEventCPs[playerid][0] == 1) {
        	SendClientMessageEx(playerid, COLOR_WHITE, "Ban da huy bo giai doan 1, ban khong the chinh sua lai vi tri checkpoint's.");
        	ConfigEventCPs[playerid][1] = 0;
        	ConfigEventCPs[playerid][0] = 0;
        	ConfigEventCPs[playerid][2] = 0;
		}
		else if(ConfigEventCPs[playerid][1] == 2 && ConfigEventCPs[playerid][0] == 1) {
        	TogglePlayerControllable(playerid, true);
        	SendClientMessageEx(playerid, COLOR_WHITE, "Ban da huy bo giai doan 2, hay chon mot vi tri khac. Neu ban muon huy bo giai doan 1(Edit CP Position) nhan nut AIM lai lan nua.");
        	ConfigEventCPs[playerid][1] = 1;
		}
		if(GetPVarInt(playerid, "CreateGT") == 1)
		{
			DeletePVar(playerid, "CreateGT");
			SendClientMessageEx(playerid, COLOR_GREY, "Ban da ngung tao gang tag.");
		}
		if(GetPVarInt(playerid, "gt_Edit") == 1)
		{
			DeletePVar(playerid, "gt_ID");
			DeletePVar(playerid, "gt_Edit");
			SendClientMessageEx(playerid, COLOR_GREY, "Ban da dung chinh sua vi tri.");
		}
	}
	else if (IsKeyJustDown(KEY_FIRE, newkeys, oldkeys))
 	{
 	    if(ConfigEventCPs[playerid][1] == 1 && ConfigEventCPs[playerid][0] == 1) {
		    TogglePlayerControllable(playerid, false);
		    new string[92], Float: x, Float: y, Float: z;
			GetPlayerPos(playerid, x, y, z);
		    format(string, sizeof(string), "Position: X = %f.3 Y = %f.3 Z = %f.3", x, y, z);
		    SendClientMessageEx(playerid, COLOR_WHITE, "Ban co chac chan day la mot vi tri chinh xac?,vui long bam nut fire de xac nhan dieu nay, ban co the huy dieu nay bang nut AIM.");
            SendClientMessageEx(playerid, COLOR_YELLOW, string);
            ConfigEventCPs[playerid][1] = 2;
		}
		else if(ConfigEventCPs[playerid][1] == 2 && ConfigEventCPs[playerid][0] == 1) {
		    TogglePlayerControllable(playerid, true);
		    new string[298];
			GetPlayerPos(playerid, EventRCPX[ConfigEventCPId[playerid]], EventRCPY[ConfigEventCPId[playerid]], EventRCPZ[ConfigEventCPId[playerid]]);
		    format(string, sizeof(string), "Ban da tao ra mot vi tri duong dua. Vi tri: X = %f.3 Y = %f.3 Z = %f.3 - ID:%d", EventRCPX[ConfigEventCPId[playerid]], EventRCPY[ConfigEventCPId[playerid]], EventRCPZ[ConfigEventCPId[playerid]], ConfigEventCPId[playerid]);
		    SendClientMessageEx(playerid, COLOR_WHITE, string);
			if(ConfigEventCPs[playerid][2] == 1)
			{
			    EventRCPU[ConfigEventCPId[playerid]] = 1;
            	EventRCPS[ConfigEventCPId[playerid]] = 10.0;
            	if(ConfigEventCPId[playerid] == 0) {
					EventRCPT[ConfigEventCPId[playerid]] = 1;
					SetPlayerCheckpoint(playerid, EventRCPX[ConfigEventCPId[playerid]], EventRCPY[ConfigEventCPId[playerid]], EventRCPZ[ConfigEventCPId[playerid]], EventRCPS[ConfigEventCPId[playerid]]);
				}
            	else {
					EventRCPT[ConfigEventCPId[playerid]] = 2;
					SetPlayerCheckpoint(playerid, EventRCPX[ConfigEventCPId[playerid]], EventRCPY[ConfigEventCPId[playerid]], EventRCPZ[ConfigEventCPId[playerid]], EventRCPS[ConfigEventCPId[playerid]]);
				}
				ConfigEventCPs[playerid][1] = 3;
            	format(string,sizeof(string),"Race Checkpoint %d Size", ConfigEventCPId[playerid]);
				ShowPlayerDialog(playerid,RCPSIZE,DIALOG_STYLE_INPUT,string,"Ban dang trong giai doan 3, co nghia la ban  phai chon kich thuoc cua Checkpointt\nBan co the xem truoc Checkpoint(Buoc ra ngoai Checkpoint de quan sat)\nNote: Checkpoint duoc thiet lap ve mac dinh,\nBan co the tam dung checkpoint va no khong bi anh huong.","Dong y","Huy bo");
			}
			else
			{
	        	if(EventRCPT[ConfigEventCPId[playerid]] == 1) {
					SetPlayerCheckpoint(playerid, EventRCPX[ConfigEventCPId[playerid]], EventRCPY[ConfigEventCPId[playerid]], EventRCPZ[ConfigEventCPId[playerid]], EventRCPS[ConfigEventCPId[playerid]]);
				}
				else if(EventRCPT[ConfigEventCPId[playerid]] == 4) {
				    SetPlayerCheckpoint(playerid, EventRCPX[ConfigEventCPId[playerid]], EventRCPY[ConfigEventCPId[playerid]], EventRCPZ[ConfigEventCPId[playerid]], EventRCPS[ConfigEventCPId[playerid]]);
				}
				else {
				    SetPlayerCheckpoint(playerid, EventRCPX[ConfigEventCPId[playerid]], EventRCPY[ConfigEventCPId[playerid]], EventRCPZ[ConfigEventCPId[playerid]], EventRCPS[ConfigEventCPId[playerid]]);
				}
			}
		}
 	    if( PlayerInfo[playerid][pC4Used] == 1 )
 	    {
			if(GoChase[playerid] != INVALID_PLAYER_ID)
			{
			    if(IsPlayerInRangeOfPoint(GoChase[playerid], 12.0, GetPVarFloat(playerid, "DYN_C4_FLOAT_X"), GetPVarFloat(playerid, "DYN_C4_FLOAT_Y"), GetPVarFloat(playerid, "DYN_C4_FLOAT_Z")))
			    {
			        if(PlayerInfo[GoChase[playerid]][pHeadValue] >= 1)
					{
						if (IsAHitman(playerid))
						{
							new string[128];
							new takemoney = (PlayerInfo[GoChase[playerid]][pHeadValue] / 4) * 2;
							GivePlayerCash(playerid, takemoney);
							GivePlayerCash(GoChase[playerid], -takemoney);
							format(string,sizeof(string),"Hitman %s da hoan thanh hop dong %s va nhan duoc $%d",GetPlayerNameEx(playerid),GetPlayerNameEx(GoChase[playerid]),takemoney);
							SendGroupMessage(2, COLOR_YELLOW, string);
							format(string,sizeof(string),"Ban da bi mot himan giet hai, va bi mat $%d tien trong nguoi!",takemoney);
							ResetPlayerWeaponsEx(GoChase[playerid]);
						    // SpawnPlayer(GoChase[playerid]);
							SendClientMessageEx(GoChase[playerid], COLOR_YELLOW, string);
							PlayerInfo[GoChase[playerid]][pHeadValue] = 0;
							PlayerInfo[playerid][pCHits] += 1;
							SetPlayerHealth(GoChase[playerid], 0.0);
							// KillEMSQueue(GoChase[playerid]);
							GotHit[GoChase[playerid]] = 0;
							GetChased[GoChase[playerid]] = INVALID_PLAYER_ID;
							GoChase[playerid] = INVALID_PLAYER_ID;
						}
					}
			    }
			}
 	        PlayerInfo[playerid][pC4Used] = 0;
			CreateExplosion(GetPVarFloat(playerid, "DYN_C4_FLOAT_X"), GetPVarFloat(playerid, "DYN_C4_FLOAT_Y"), GetPVarFloat(playerid, "DYN_C4_FLOAT_Z"), 7, 8);
			PickUpC4(playerid);
			SendClientMessageEx(playerid, COLOR_YELLOW, " Qua Bom da duoc kich hoat no!");
			PlayerInfo[playerid][pC4Used] = 0;
			return 1;
 	    }
 	    if(GetPVarInt(playerid, "MovingStretcher") != -1)
 	    {
 	        KillTimer(GetPVarInt(playerid, "TickEMSMove"));
		    MoveEMS(playerid);
			return 1;
 	    }
		if(GetPVarInt(playerid, "editingfamhq") != INVALID_FAMILY_ID)
		{
		    if(GetPVarInt(playerid, "editingfamhqaction") == 1)
		    {
      			DeletePVar(playerid, "editingfamhqaction");
		        TogglePlayerControllable(playerid, false);
	        	ShowPlayerDialog(playerid,HQENTRANCE,DIALOG_STYLE_MSGBOX,"Warning:","Day la loi vao ma ban muon?","Dong y","Huy bo");
		    }
		    else if(GetPVarInt(playerid, "editingfamhqaction") == 2)
		    {
		        DeletePVar(playerid, "editingfamhqaction");
		        TogglePlayerControllable(playerid, false);
	        	ShowPlayerDialog(playerid,HQEXIT,DIALOG_STYLE_MSGBOX,"Warning:","Day la loi thoat ma ban muon?","Dong y","Huy bo");
		    }
		    else if(GetPVarInt(playerid, "editingfamhqaction") == 5)
		    {
		        TogglePlayerControllable(playerid, false);
	        	ShowPlayerDialog(playerid,HQENTRANCE,DIALOG_STYLE_MSGBOX,"Warning:","Dat la loi vao ma ban muon?","Dong y","Huy bo");
		    }
		    else if(GetPVarInt(playerid, "editingfamhqaction") == 6)
		    {
		        TogglePlayerControllable(playerid, false);
	        	ShowPlayerDialog(playerid,HQEXIT,DIALOG_STYLE_MSGBOX,"Warning:","Day la loi thoat ma ban muon?","Dong y","Huy bo");
		    }

		}
		if(GetPVarInt(playerid, "DraggingPlayer") != INVALID_PLAYER_ID)
		{
			new Float:dX, Float:dY, Float:dZ, string[128];
    		GetPlayerPos(playerid, dX, dY, dZ);
			floatsub(dX, 0.4);
			floatsub(dY, 0.4);

    		SetPVarFloat(GetPVarInt(playerid, "DraggingPlayer"), "DragX", dX);
			SetPVarFloat(GetPVarInt(playerid, "DraggingPlayer"), "DragY", dY);
			SetPVarFloat(GetPVarInt(playerid, "DraggingPlayer"), "DragZ", dZ);
			SetPVarInt(GetPVarInt(playerid, "DraggingPlayer"), "DragWorld", GetPlayerVirtualWorld(playerid));
			SetPVarInt(GetPVarInt(playerid, "DraggingPlayer"), "DragInt", GetPlayerInterior(playerid));
			Streamer_UpdateEx(GetPVarInt(playerid, "DraggingPlayer"), dX, dY, dZ);
			SetPlayerPos(GetPVarInt(playerid, "DraggingPlayer"), dX, dY, dZ);
			SetPlayerInterior(GetPVarInt(playerid, "DraggingPlayer"), GetPlayerInterior(playerid));
			SetPlayerVirtualWorld(GetPVarInt(playerid, "DraggingPlayer"), GetPlayerVirtualWorld(playerid));
			ClearAnimations(GetPVarInt(playerid, "DraggingPlayer"));
			ApplyAnimation(GetPVarInt(playerid, "DraggingPlayer"), "ped","cower",1,true,false,false,false,0,1);
            DeletePVar(GetPVarInt(playerid, "DraggingPlayer"), "BeingDragged");
            SetPVarInt(playerid, "DraggingPlayer", INVALID_PLAYER_ID);
            format(string, sizeof(string), "* You have stopped dragging %s.", GetPlayerNameEx(GetPVarInt(playerid, "DraggingPlayer")));
            SendClientMessage(playerid, COLOR_GRAD2, string);
		}
		if(GetPVarInt(playerid, "CreateGT") == 1)
		{
			if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pGangModerator] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong duoc phep su dung hanh dong nay");
			new gangtag = GetFreeGangTag();
			if(gangtag == -1)
			{
				DeletePVar(playerid, "CreateGT");
				SendClientMessageEx(playerid, COLOR_GREY, "There is no free gang tag to use!");
				return 1;
			}
			new Float:pPosX, Float:pPosY, Float:pPosZ, string[128];
			GetPlayerPos(playerid, pPosX, pPosY, pPosZ);
			GangTags[gangtag][gt_PosX] = pPosX;
			GangTags[gangtag][gt_PosY] = pPosY;
			GangTags[gangtag][gt_PosZ] = pPosZ;
			GangTags[gangtag][gt_Used] = 1;
			GangTags[gangtag][gt_VW] = GetPlayerVirtualWorld(playerid);
			GangTags[gangtag][gt_Int] = GetPlayerInterior(playerid);
			DeletePVar(playerid, "CreateGT");
			CreateGangTag(gangtag);
			format(string, sizeof(string), "Gangtag %d da duoc tao, su dung /gtedit de chinh sua va toi uu hoa vi tri!", gangtag);
			SendClientMessageEx(playerid, COLOR_WHITE, string);
			format(string, sizeof(string), "%s da tao gang %d.", GetPlayerNameEx(playerid), gangtag);
			Log("Logs/GangTags.log", string);
			SaveGangTag(gangtag);
		}
		if(GetPVarInt(playerid, "gt_Edit") == 1)
		{
			if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pGangModerator] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong duoc phep su dung lenh nay.");
			new gangtag = GetPVarInt(playerid, "gt_ID");
			new Float:pPosX, Float:pPosY, Float:pPosZ, string[128];
			GetPlayerPos(playerid, pPosX, pPosY, pPosZ);
			GangTags[gangtag][gt_PosX] = pPosX;
			GangTags[gangtag][gt_PosY] = pPosY;
			GangTags[gangtag][gt_PosZ] = pPosZ;
			GangTags[gangtag][gt_VW] = GetPlayerVirtualWorld(playerid);
			GangTags[gangtag][gt_Int] = GetPlayerInterior(playerid);
			DeletePVar(playerid, "gt_ID");
			DeletePVar(playerid, "gt_Edit");
			CreateGangTag(gangtag);
			format(string, sizeof(string), "Ban da thay doi vi tri cua gang tag %d!", gangtag);
			SendClientMessageEx(playerid, COLOR_WHITE, string);
			format(string, sizeof(string), "%s da thay doi vi tri cua gangtag %d.", GetPlayerNameEx(playerid), gangtag);
			Log("Logs/GangTags.log", string);
			SaveGangTag(gangtag);
		}
		if(GetPVarType(playerid, "gt_Spraying"))
		{
			new tagid = GetPVarInt(playerid, "gt_Spray");
			GangTags[tagid][gt_TimeLeft] = 0;
			KillTimer(GangTags[tagid][gt_Timer]);
			DeletePVar(playerid, "gt_Spraying");
			DeletePVar(playerid, "gt_Spray");
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da ngung spraying.");
			ClearAnimations(playerid);
		}
	}
	else if((newkeys & KEY_SPRINT) && GetPlayerState(playerid) == 2)// Pressing the gas, detonates the bomb.
	{
		new string[128], vehicleid = GetPlayerVehicleID(playerid);
		if(GetChased[playerid] != INVALID_PLAYER_ID && VehicleBomb{vehicleid} == 1)
		{
			if(PlayerInfo[playerid][pHeadValue] >= 1)
			{
				if (IsAHitman(GetChased[playerid]))
				{
					new Float:boomx, Float:boomy, Float:boomz;
					GetPlayerPos(playerid,boomx, boomy, boomz);
					CreateExplosion(boomx, boomy , boomz, 7, 1);
					VehicleBomb{vehicleid} = 0;
					PlacedVehicleBomb[GetChased[playerid]] = INVALID_VEHICLE_ID;
					new takemoney = (PlayerInfo[playerid][pHeadValue] / 4) * 2;
					GivePlayerCash(GetChased[playerid], takemoney);
					GivePlayerCash(playerid, -takemoney);
					format(string,sizeof(string),"Hitman %s da hoan thanh hop dong giet %s va nhan duoc tien thuong $%d.",GetPlayerNameEx(GetChased[playerid]),GetPlayerNameEx(playerid),takemoney);
					SendGroupMessage(2, COLOR_YELLOW, string);
					format(string,sizeof(string),"Ban da bi sat hai boi mot hitman va mat di $%d so tien trong nguoi!",takemoney);
					ResetPlayerWeaponsEx(playerid);
					SendClientMessageEx(playerid, COLOR_YELLOW, string);
					PlayerInfo[playerid][pHeadValue] = 0;
					PlayerInfo[GetChased[playerid]][pCHits] += 1;
					SetPlayerHealth(playerid, 0.0);
					GoChase[GetChased[playerid]] = INVALID_PLAYER_ID;
					PlayerInfo[GetChased[playerid]][pC4Used] = 0;
					PlayerInfo[GetChased[playerid]][pC4] = 0;
					GotHit[playerid] = 0;
					GetChased[playerid] = INVALID_PLAYER_ID;
					return 1;
				}
			}
		}
    }
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
 		if(!IsPlayerEntering{playerid})
		{
			if(GetPVarInt(playerid, "TeleportWarnings") == 3) {
				new string[128];
		    	format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) may have just teleported into a vehicle.", GetPlayerNameEx(playerid), playerid);
				ABroadCast(COLOR_YELLOW, string, 2);
				DeletePVar(playerid, "TeleportWarnings");
			}
			else
			{
			    SetPVarInt(playerid, "TeleportWarnings", GetPVarInt(playerid, "TeleportWarnings")+1);
			}
		}
		if (CarRadars[playerid] > 0)
		{
			PlayerTextDrawShow(playerid, _crTextTarget[playerid]);
			PlayerTextDrawShow(playerid, _crTextSpeed[playerid]);
			PlayerTextDrawShow(playerid, _crTickets[playerid]);
			DeletePVar(playerid, "_lastTicketWarning");
		}
	}
	IsPlayerEntering{playerid} = false;
	if(newstate == PLAYER_STATE_PASSENGER)
	{
		if (PlayerInfo[playerid][pSpeedo] != 0)
		{
			ShowVehicleHUDForPlayer(playerid);
		}
	}
	if(newstate == PLAYER_STATE_DRIVER)
	{
		if (IsAtGym(playerid))
		{
			new biz = InBusiness(playerid);
			new veh = GetPlayerVehicleID(playerid);

			for (new it = 0; it < 10; ++it)
			{
				if (Businesses[biz][bGymBikeVehicles][it] == veh)
				{
					if (GetPVarInt(playerid, "_BikeParkourSlot") != it)
					{
						RemovePlayerFromVehicle(playerid);
						SendClientMessageEx(playerid, COLOR_GRAD2, "Do khong phai chiec xe cua ban!");
					}
				}
			}
		}

		if (PlayerInfo[playerid][pSpeedo] != 0)
		{
			ShowVehicleHUDForPlayer(playerid);
		}

	    new vehicleid = GetPlayerVehicleID(playerid);
		if(GetVehicleModel(vehicleid) == 530)
		{
		    if(CrateVehicleLoad[vehicleid][vForkLoaded])
		    {
			    new Float: pX, Float: pY, Float: pZ;
				GetPlayerPos(playerid, pX, pY, pZ);
				SetPVarFloat(playerid, "tpForkliftX", pX);
		 		SetPVarFloat(playerid, "tpForkliftY", pY);
		  		SetPVarFloat(playerid, "tpForkliftZ", pZ);
				SetPVarInt(playerid, "tpForkliftTimer", 80);
				SetPVarInt(playerid, "tpForkliftID", GetPlayerVehicleID(playerid));
				SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_CRATETIMER);
		    }
		}
	}
    if(newstate != 2) NOPTrigger[playerid] = 0;
	//Specating
	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER || newstate == PLAYER_STATE_ONFOOT)
	{
		foreach(new i: Player) {
			if(PlayerInfo[i][pAdmin] >= 2 || GetPVarType(i, "pWatchdogWatching")) {
				if(Spectating[i] > 0 && Spectate[i] == playerid) {
					if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER) {
						TogglePlayerSpectating(i, true);
						new carid = GetPlayerVehicleID( playerid );
						PlayerSpectateVehicle( i, carid );
					}	
					else if(newstate == PLAYER_STATE_ONFOOT) {
						TogglePlayerSpectating(i, true);
						PlayerSpectatePlayer( i, playerid );
						SetPlayerInterior( i, GetPlayerInterior( playerid ) );
					}	
				}
			}
		}
	}	
	if(newstate == PLAYER_STATE_ONFOOT)
	{
		StopAudioStreamForPlayerEx(playerid);
		if(GetPVarType(playerid, "Siren"))
		{
  			if(IsPlayerAttachedObjectSlotUsed(playerid, MAX_PLAYER_ATTACHED_OBJECTS - 2)) RemovePlayerAttachedObject(playerid, MAX_PLAYER_ATTACHED_OBJECTS - 2);
    		if(IsPlayerAttachedObjectSlotUsed(playerid, MAX_PLAYER_ATTACHED_OBJECTS - 1)) RemovePlayerAttachedObject(playerid, MAX_PLAYER_ATTACHED_OBJECTS - 1);
      		DeletePVar(playerid, "Siren");
		}

		/*if(GettingSpectated[playerid] != INVALID_PLAYER_ID && PlayerInfo[GettingSpectated[playerid]][pAdmin] >= 2) {
			new spectator = GettingSpectated[playerid];
	        // Preventing possible buffer overflows with the arrays
	 		TogglePlayerSpectating(spectator, true);
			PlayerSpectatePlayer( spectator, playerid );
			SetPlayerInterior( spectator, GetPlayerInterior( playerid ) );
			SetPlayerInterior( spectator, GetPlayerInterior( playerid ) );
			SetPlayerVirtualWorld( spectator, GetPlayerVirtualWorld( playerid ) );
		}*/

	    if(oldstate == PLAYER_STATE_DRIVER)
		{
			if (_vhudVisible[playerid] == 1)
			{
				HideVehicleHUDForPlayer(playerid); // incase vehicle despawns
			}
			if (CarRadars[playerid] > 0)
			{
				PlayerTextDrawHide(playerid, _crTextTarget[playerid]);
				PlayerTextDrawHide(playerid, _crTextSpeed[playerid]);
				PlayerTextDrawHide(playerid, _crTickets[playerid]);
				DeletePVar(playerid, "_lastTicketWarning");
			}

			SetPlayerWeaponsEx(playerid);
		}
		else if(oldstate == PLAYER_STATE_PASSENGER) SetPlayerWeaponsEx(playerid);

		if(ConnectedToPC[playerid] == 1337)//mdc
	    {
            SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Luc nay ban da roi khoi MDC.");
	        ConnectedToPC[playerid] = 0;
		}
        if(TransportDuty[playerid] > 0)
		{
		    if(TransportDuty[playerid] == 1)
			{
		        TaxiDrivers -= 1;
			}
			else if(TransportDuty[playerid] == 2)
			{
			    BusDrivers -= 1;
			}
			TransportDuty[playerid] = 0;
			new string[70]; // increased buf size as full message wasn't getting shown
			format(string, sizeof(string), "* Ban da off duty va nhan duoc $%d.", TransportMoney[playerid]);
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, string);

			foreach(new i: Player)
			{
				if (TransportDriver[i] == playerid)
				{
					GivePlayerCash(i, -TransportCost[i]);
					format(string, sizeof(string), "* Tai xe da roi khoi xe, cho nen ban phai tra $%d.", TransportCost[i]);
					TransportCost[i] = 0; // I've not used either of these two variables before, could be more that resetting
					TransportDriver[i] = INVALID_PLAYER_ID;
					SendClientMessageEx(i, COLOR_LIGHTBLUE, string);
				}
			}

			GivePlayerCash(playerid, TransportMoney[playerid]);
			TransportValue[playerid] = 0; TransportMoney[playerid] = 0;
			if(!IsATaxiDriver(playerid)) { SetPlayerColor(playerid, TEAM_HIT_COLOR); }
			TransportTime[playerid] = 0;
   			TransportCost[playerid] = 0;
		}
		if(TransportDriver[playerid] < MAX_PLAYERS)
		{
			new string[128];
			TransportMoney[TransportDriver[playerid]] += TransportCost[playerid];
			format(string, sizeof(string), "~w~Chi phi di xe~n~~r~$%d",TransportCost[playerid]);
			GameTextForPlayer(playerid, string, 5000, 3);
			format(string, sizeof(string), "~w~Hanh khach roi khoi xe taxi.~n~~g~Kiem duoc $%d",TransportCost[playerid]);
			GameTextForPlayer(TransportDriver[playerid], string, 5000, 3);
			GivePlayerCash(playerid, -TransportCost[playerid]);

			if(TransportCost[playerid] >= 10000)
			{
				format(string, sizeof(string), "%s (IP:%s) has taxied %s (IP:%s) $%d in this session.", GetPlayerNameEx(playerid), GetPlayerIpEx(playerid), GetPlayerNameEx(TransportDriver[playerid]), GetPlayerIpEx(TransportDriver[playerid]), TransportCost[playerid]);
				//Log("logs/pay.log", string);
				ABroadCast(COLOR_YELLOW, string, 2);
			}
			TransportTime[TransportDriver[playerid]] = 0;
			TransportCost[TransportDriver[playerid]] = 0;
			TransportCost[playerid] = 0;
			TransportTime[playerid] = 0;
			TransportDriver[playerid] = INVALID_PLAYER_ID;
		}
	}
    if(newstate == PLAYER_STATE_PASSENGER) // TAXI & BUSSES
	{
	    #if defined zombiemode
   		if(zombieevent == 1 && GetPVarType(playerid, "pIsZombie"))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Zombie khong the di vao xe oto.");
			new Float:X, Float:Y, Float:Z;
			GetPlayerPos(playerid, X, Y, Z);
			SetPlayerPos(playerid, X, Y, Z);
			return 1;
		}
		#endif
		fVehSpeed[playerid] = 0;
		fVehHealth[playerid] = 0;
 		if(!isnull(stationidv[GetPlayerVehicleID(playerid)]))
		{
   			PlayAudioStreamForPlayerEx(playerid, stationidv[GetPlayerVehicleID(playerid)]);
		}
        new vehicleid = GetPlayerVehicleID(playerid);
	    /*if(vehicleid == NGVehicles[12] ||
		vehicleid == NGVehicles[13] ||
		vehicleid == NGVehicles[14] ||
		vehicleid == NGVehicles[15] ||
		vehicleid == NGVehicles[16] ||
		vehicleid == NGVehicles[17])
		{
		    TogglePlayerSpectating(playerid, true);
			PlayerSpectateVehicle(playerid, vehicleid);
			SetPVarInt(playerid, "NGPassenger", 1);
			SetPVarInt(playerid, "NGPassengerVeh", vehicleid);
			SetPVarInt(playerid, "NGPassengerSkin", GetPlayerSkin(playerid));
			new Float:health, Float:armour;
			GetPlayerHealth(playerid, health);
			GetPlayerArmour(playerid, armour);
			SetPVarFloat(playerid, "NGPassengerHP", health);
			SetPVarFloat(playerid, "NGPassengerArmor", armour);
		}*/

        if(PlayerInfo[playerid][pGuns][4] > 0)	SetPlayerArmedWeapon(playerid,PlayerInfo[playerid][pGuns][4]);
		else SetPlayerArmedWeapon(playerid,0);

	    gLastCar[playerid] = vehicleid;
	    foreach(new i: Player)
	    {
     		if(IsPlayerInVehicle(i, vehicleid) && GetPlayerState(i) == 2 && TransportDuty[i] > 0)
       		{
				if(GetPlayerCash(playerid) < TransportValue[i])
				{
					new string[28];
					format(string, sizeof(string), "* Ban can $%d de vao.", TransportValue[i]);
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, string);
					RemovePlayerFromVehicle(playerid);
					new Float:X, Float:Y, Float:Z;
					GetPlayerPos(playerid, X, Y, Z);
					SetPlayerPos(playerid, X, Y, Z+2);
					TogglePlayerControllable(playerid, true);
				}
				else
				{
					new string[35+MAX_PLAYER_NAME];
					if(TransportDuty[i] == 1)
					{
						format(string, sizeof(string), "* Ban dua $%d tien cho tai xe taxi.", TransportValue[i]);
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "* Hanh khach %s da buoc vao taxi cua ban.", GetPlayerNameEx(playerid));
						SendClientMessageEx(i, COLOR_LIGHTBLUE, string);
						TransportTime[i] = 1;
						TransportTime[playerid] = 1;
						TransportCost[playerid] = TransportValue[i];
						TransportCost[i] = TransportValue[i];
						TransportDriver[playerid] = i;
					}
					else if(TransportDuty[i] == 2)
					{
						format(string, sizeof(string), "* Ban dua $%d cho tai xe taxi.", TransportValue[i]);
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "* Hanh khach %s da buoc vao taxi cua ban.", GetPlayerNameEx(playerid));
						SendClientMessageEx(i, COLOR_LIGHTBLUE, string);
					}
					GivePlayerCash(playerid, - TransportValue[i]);
					TransportMoney[i] += TransportValue[i];
				}
      		}
	    }
	}
	if(newstate == PLAYER_STATE_WASTED)
	{
	    if(GetPVarInt(playerid, "EventToken") == 0)
	    {
			SetPVarInt(playerid, "MedicBill", 1);
		}
		if(ConnectedToPC[playerid] == 1337)//mdc
	    {
	        ConnectedToPC[playerid] = 0;
		}
		Seatbelt[playerid] = 0;
	}
	if(newstate == PLAYER_STATE_DRIVER)
	{
	    #if defined zombiemode
    	if(zombieevent == 1 && GetPVarType(playerid, "pIsZombie"))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Zombie khong the lai xe.");
			new Float:X, Float:Y, Float:Z;
			GetPlayerPos(playerid, X, Y, Z);
			SetPlayerPos(playerid, X, Y, Z);
			return 1;
		}
		#endif
		fVehSpeed[playerid] = 0;
		fVehHealth[playerid] = 0;
	    if(!isnull(stationidv[GetPlayerVehicleID(playerid)]))
		{
   			PlayAudioStreamForPlayerEx(playerid, stationidv[GetPlayerVehicleID(playerid)]);
		}

		SetPlayerArmedWeapon(playerid, 0);

		new
			newcar = GetPlayerVehicleID(playerid),
			engine, lights, alarm, doors, bonnet, boot, objective, v;

		gLastCar[playerid] = newcar;
		if(GetPVarInt(playerid, "EventToken") == 1) {
			if(EventKernel[EventFootRace] == 1) {
				new Float:X, Float:Y, Float:Z;
				GetPlayerPos(playerid, X, Y, Z);
				SetPlayerPos(playerid, X, Y, Z+1.3);
				SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong the tham gia su kien khi dang o ben trong mot chiec xe.");
				return 1;
			}
		}
	 	foreach(new i: Player)
		{
	   		v = GetPlayerVehicle(i, newcar);
		    if(v != -1) {
				if(i == playerid) {

					new
						string[128];

					format(string, sizeof(string),"Ban la chu so huu cua %s.", GetVehicleName(newcar));
					SendClientMessageEx(playerid, COLOR_GREY, string);
					if(PlayerVehicleInfo[i][v][pvTicket] != 0)
					{
						format(string, sizeof(string),"Chiec xe nay co $%d tien phat chua thanh toan. Ban phai tra tien ve tai DMV canh Cityhall.", PlayerVehicleInfo[i][v][pvTicket]);
						SendClientMessageEx(playerid, COLOR_GREY, string);
						SendClientMessageEx(playerid, COLOR_GREY, "Neu ban khong tra tien phat xe trong thoi gian som, tien phat xe se tang va co the bi thu giu phuong tien.");
					}
				}
				else if(i == PlayerInfo[playerid][pVehicleKeysFrom] && v == PlayerInfo[playerid][pVehicleKeys]) {

					new
						string[64 + MAX_PLAYER_NAME];

					format(string, sizeof(string),"Ban co chia khoa xe %s tu chu so huu %s.", GetVehicleName(newcar), GetPlayerNameEx(i));
					SendClientMessageEx(playerid, COLOR_GREY, string);
				}
				else if(PlayerVehicleInfo[i][v][pvLocked] == 1 && PlayerVehicleInfo[i][v][pvLock] == 1) {
				    GetVehicleParamsEx(newcar,engine,lights,alarm,doors,bonnet,boot,objective);
					SetVehicleParamsEx(newcar,engine,lights,VEHICLE_PARAMS_ON,doors,bonnet,boot,objective);
					SetTimerEx("DisableVehicleAlarm", 20000, false, "d",  newcar);
				}
				else if(PlayerVehicleInfo[i][v][pvLocked] == 1 && PlayerVehicleInfo[i][v][pvLock] == 2) { // Electronic Lock System

					new
						string[49 + MAX_PLAYER_NAME];

	          		if(PlayerInfo[playerid][pAdmin] < 2)
					{
						new Float:slx, Float:sly, Float:slz;
						GetPlayerPos(playerid, slx, sly, slz);
						SetPlayerPos(playerid, slx, sly, slz+1.3);
						RemovePlayerFromVehicle(playerid);
						defer NOPCheck(playerid);
					}
					else
					{
	    				format(string, sizeof(string), "Warning: Chiec xe %s thuoc so huu cua %s.", GetVehicleName(newcar), GetPlayerNameEx(i));
	      				SendClientMessageEx(playerid, COLOR_GREY, string);
					}
				}
				return 1;
			}
		}
		new vehicleid = newcar;
		if(IsVIPcar(vehicleid))
		{
		    if(PlayerInfo[playerid][pDonateRank] > 0)
			{
				SendClientMessageEx(playerid, COLOR_YELLOW, "VIP: Day la chiec xe duoc lay tu gara VIP, vi the nhien lieu khong bi gioi han.");
			}
		    else
			{
			    new Float:slx, Float:sly, Float:slz;
				GetPlayerPos(playerid, slx, sly, slz);
				SetPlayerPos(playerid, slx, sly, slz+1.3);
				PlayerPlaySound(playerid, 1130, slx, sly, slz+1.3);
			    RemovePlayerFromVehicle(playerid);
			    defer NOPCheck(playerid);
			    SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong phai la VIP, day la chiec xe chi danh cho  VIP!");
			}
		}
		else if(IsFamedVeh(vehicleid))
		{
		    if(PlayerInfo[playerid][pFamed] < 1)
		    {
		        new Float:slx, Float:sly, Float:slz;
				GetPlayerPos(playerid, slx, sly, slz);
				SetPlayerPos(playerid, slx, sly, slz+1.3);
				PlayerPlaySound(playerid, 1130, slx, sly, slz+1.3);
			    RemovePlayerFromVehicle(playerid);
			    defer NOPCheck(playerid);
			    SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong phai la Famed Member, chiec xe da duoc lay tu gare Famed!");
			 }
			 else {
			    SendClientMessageEx(playerid, COLOR_YELLOW, "Famed: Day la chiec xe duoc lay tu gara Famed, vi the nhien lieu khong bi gioi han.");
			 }
		}
		else if(DynVeh[vehicleid] != -1)
		{
			new string[128], Float:slx, Float:sly, Float:slz;
			GetPlayerPos(playerid, slx, sly, slz);
			if(DynVehicleInfo[DynVeh[vehicleid]][gv_igID] != INVALID_GROUP_ID && (PlayerInfo[playerid][pMember] != DynVehicleInfo[DynVeh[vehicleid]][gv_igID]))
			{
				RemovePlayerFromVehicle(playerid);
				SetPlayerPos(playerid, slx, sly, slz+1.3);
				defer NOPCheck(playerid);
				format(string, sizeof(string), "Ban can phai o trong %s de lai chiec xe nay.", arrGroupData[DynVehicleInfo[DynVeh[vehicleid]][gv_igID]][g_szGroupName]);
				SendClientMessageEx(playerid, COLOR_GRAD2, string);
			}
			else if(DynVehicleInfo[DynVeh[vehicleid]][gv_igDivID] != 0 && PlayerInfo[playerid][pDivision] != DynVehicleInfo[DynVeh[vehicleid]][gv_igDivID])
			{
				RemovePlayerFromVehicle(playerid);
				SetPlayerPos(playerid, slx, sly, slz+1.3);
				defer NOPCheck(playerid);
				format(string, sizeof(string), "Ban can phai o trong %s's %s phan chia de lai xe nay.",
				arrGroupData[DynVehicleInfo[DynVeh[vehicleid]][gv_igID]][g_szGroupName],
				arrGroupDivisions[DynVehicleInfo[DynVeh[vehicleid]][gv_igID]][DynVehicleInfo[DynVeh[vehicleid]][gv_igDivID]]);
				SendClientMessageEx(playerid, COLOR_GRAD2, string);
			}
			else if(DynVehicleInfo[DynVeh[vehicleid]][gv_ifID] != 0 && (PlayerInfo[playerid][pFMember] != DynVehicleInfo[DynVeh[vehicleid]][gv_ifID]))
			{
				RemovePlayerFromVehicle(playerid);
				SetPlayerPos(playerid, slx, sly, slz+1.3);
				defer NOPCheck(playerid);
			}
			else if(DynVehicleInfo[DynVeh[vehicleid]][gv_irID] != 0 && (PlayerInfo[playerid][pRank] < DynVehicleInfo[DynVeh[vehicleid]][gv_irID]))
			{
				RemovePlayerFromVehicle(playerid);
				SetPlayerPos(playerid, slx, sly, slz+1.3);
				defer NOPCheck(playerid);
			}
		}
	   	else if(IsAPlane(vehicleid))
		{
	  		if(PlayerInfo[playerid][pFlyLic] != 1)
	  		{
		  		RemovePlayerFromVehicle(playerid);
		  		new Float:slx, Float:sly, Float:slz;
				GetPlayerPos(playerid, slx, sly, slz);
				SetPlayerPos(playerid, slx, sly, slz);
		  		defer NOPCheck(playerid);
			 	SendClientMessageEx(playerid,COLOR_GREY,"Ban khong co bang lai may bay!");
	  		}
		}
		else if(IsAHelicopter(vehicleid))
		{
		    PlayerInfo[playerid][pAGuns][GetWeaponSlot(46)] = 46;
			GivePlayerValidWeapon(playerid, 46, 60000);
		}
		else if(IsAnTaxi(vehicleid) || IsAnBus(vehicleid))
		{
	        if(PlayerInfo[playerid][pJob] == 17 || PlayerInfo[playerid][pJob2] == 17 || IsATaxiDriver(playerid) || PlayerInfo[playerid][pTaxiLicense] == 1)
			{
			}
		    else
			{
		        SendClientMessageEx(playerid,COLOR_GREY,"   Ban khong phai la tai xe Taxi/Bus!");
		        RemovePlayerFromVehicle(playerid);
		        new Float:slx, Float:sly, Float:slz;
				GetPlayerPos(playerid, slx, sly, slz);
				SetPlayerPos(playerid, slx, sly, slz);
				defer NOPCheck(playerid);
		    }
		}

		if(GetCarBusiness(newcar) != INVALID_BUSINESS_ID && PlayerInfo[playerid][pAdmin] < 1337)
        {

            new
				iBusiness = GetCarBusiness(newcar),
				iSlot = GetBusinessCarSlot(newcar),
				string[128];

			if(Businesses[iBusiness][bInventory] == 0) {
			    SendClientMessageEx(playerid,COLOR_GREY,"Cua hang nay da het hang.");
		        RemovePlayerFromVehicle(playerid);
		        new Float:slx, Float:sly, Float:slz;
				GetPlayerPos(playerid, slx, sly, slz);
				SetPlayerPos(playerid, slx, sly, slz);
				defer NOPCheck(playerid);
				return 1;
			}
			format(string, sizeof(string), "Ban co muon mua xe %s\nChi phi xe la $%s.", GetVehicleName(newcar), number_format(Businesses[iBusiness][bPrice][iSlot]));
		    ShowPlayerDialog(playerid,DIALOG_CDBUY,DIALOG_STYLE_MSGBOX,"Mua xe",string,"Mua","Huy bo");
		    TogglePlayerControllable(playerid, false);
		    return 1;
        }
	    if(DynVeh[vehicleid] != -1 && DynVehicleInfo[DynVeh[vehicleid]][gv_iType] == 1)
	    {
	        SendClientMessageEx(playerid, COLOR_GRAD1, "Crate Related Commands: /loadforklift /(un)loadplane /cargo /igps /announcetakeoff /cgun /crates /destroycrate /cratelimit");
	        SendClientMessageEx(playerid, COLOR_GRAD1, " /(un)loadcrate /delivercrate");
	    }
		GetVehicleParamsEx(newcar,engine,lights,alarm,doors,bonnet,boot,objective);
		if((engine == VEHICLE_PARAMS_UNSET || engine == VEHICLE_PARAMS_OFF) && GetVehicleModel(newcar) != 509 && GetVehicleModel(newcar) != 481 && GetVehicleModel(newcar) != 510 && (DynVeh[newcar] != -1 && GetVehicleModel(newcar) == 592 && DynVehicleInfo[DynVeh[newcar]][gv_iType] != 1) ) {
			SendClientMessageEx(playerid, COLOR_WHITE, "This vehicle's engine is not running - if you wish to start it, type /car engine.");
		}
		else if((engine == VEHICLE_PARAMS_UNSET || engine == VEHICLE_PARAMS_OFF) && (DynVeh[newcar] != -1 && GetVehicleModel(newcar) == 592 && DynVehicleInfo[DynVeh[newcar]][gv_iType] == 1))
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "You must request clearance to take off. /announcetakeoff to put in the request.");
		}
	}
	if((newstate == 2 || newstate == 3 || newstate == 7 || newstate == 9) && pTazer{playerid} == 1)
	{
		GivePlayerValidWeapon(playerid, pTazerReplace{playerid}, 60000);
		pTazer{playerid} = 0;
	}
	if(newstate == PLAYER_STATE_SPAWNED)
	{
		if(ConnectedToPC[playerid] == 1337)//mdc
	    {
	        ConnectedToPC[playerid] = 0;
		}
	}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	if (_vhudVisible[playerid] == 1)
	{
		HideVehicleHUDForPlayer(playerid);
	}
	if (CarRadars[playerid] > 0)
	{
		PlayerTextDrawHide(playerid, _crTextTarget[playerid]);
		PlayerTextDrawHide(playerid, _crTextSpeed[playerid]);
		PlayerTextDrawHide(playerid, _crTickets[playerid]);
		DeletePVar(playerid, "_lastTicketWarning");
	}

	switch(Seatbelt[playerid])
	{
	    case 1:
	    {
			new string[128];
	        if(IsABike(vehicleid))
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "Ban da thao mu bao hiem cua ban ra khoi dau.");
				format(string, sizeof(string), "* %s voi lay chiec mu bao hiem,dua no ra khoi dau.", GetPlayerNameEx(playerid));
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "Ban da thao day an toan ra khoi nguoi.");
				format(string, sizeof(string), "* %s voi lay day an toan,thao no ra khoi chot an toan.", GetPlayerNameEx(playerid));
			}
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
  			Seatbelt[playerid] = 0;
	    }
	}

	if(GetPVarInt(playerid, "rccam") == 1)
	{
		DestroyVehicle(GetPVarInt(playerid, "rcveh"));
	    SetPlayerPos(playerid, GetPVarFloat(playerid, "rcX"), GetPVarFloat(playerid, "rcY"), GetPVarFloat(playerid, "rcZ"));
		DeletePVar(playerid, "rccam");
	    KillTimer(GetPVarInt(playerid, "rccamtimer"));
	}
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    if(IsPlayerNPC(playerid)) return 1;
	if(gPlayerLogged{playerid} == 1)
	{
		TogglePlayerSpectating(playerid, true);
		SetTimerEx("ForceSpawn", 10, false, "i", playerid);
	}
	else
	{
		TogglePlayerSpectating(playerid, true);
		SetPlayerJoinCamera(playerid);
	}

	return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
    new string[500];
    if(!success)
    {
        format(string,sizeof(string),"SERVER: Khong co lenh %s trong he thong,su dung /trogiup de xem cac lenh co ban.", cmdtext);
        SendClientMessageEx(playerid, COLOR_WHITE, string);
    }
    return 1;
}

public OnPlayerCommandReceived(playerid, cmdtext[]) {

	if(gPlayerLogged{playerid} != 1) {
		SendClientMessageEx(playerid, COLOR_RED, "Ban chua dang nhap.");
		return 0;
	}

	playerLastTyped[playerid] = 0;
	printf("[zcmd] [%s]: %s", GetPlayerNameEx(playerid), cmdtext);

	if(PlayerInfo[playerid][pMuted] == 1) {
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong the noi chuyen, ban dang bi mute!");
		return 0;
	}
	if(CommandSpamUnmute[playerid] != 0) {
		SendClientMessage(playerid, COLOR_WHITE, "Ban dang bi mute khoi kenh cho truyen.");
		return 0;
	}
	if(++CommandSpamTimes[playerid] >= 5 && PlayerInfo[playerid][pAdmin] < 1337) {
		CommandSpamTimes[playerid] = 0;
		CommandSpamUnmute[playerid] = 10;
		SendClientMessageEx(playerid, COLOR_YELLOW, "Ban dang noi chuyen qua nhanh. Xin vui long thu lai sau 10 giay.");
		SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_FLOODPROTECTION);
		return 0;
	}

	if(strfind(cmdtext, "|") != -1 || strfind(cmdtext, "\n") != -1 || strfind(cmdtext, "\r") != -1) {
	    SendClientMessageEx(playerid, COLOR_GREY, "Ban khong duoc su dung cac ki hieu dac biet trong cau lenh.");
		return 0;
	}

    if (strcmp(GiftCode, "off") != 0 && strfind(cmdtext, "/giftcode") == -1)
    {
		if(strfind(cmdtext, GiftCode) != -1)
		{
		    SendClientMessageEx(playerid, COLOR_GREY, "Ban khong the cho nguoi khac gift code.");
		    return 0;
		}
	}

	if(PlayerInfo[playerid][pAdmin] < 2 && CheckServerAd(cmdtext))
	{
		new string[128];
		format(string,sizeof(string),"{AA3333}AdmWarning{FFFF00}: %s (ID: %d) co the dang quang cao may chu: '{AA3333}%s{FFFF00}'.", GetPlayerNameEx(playerid), playerid, cmdtext);
		ABroadCast(COLOR_YELLOW, string, 2);
		Log("logs/hack.log", string);
		return 0;
	}
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(gPlayerLogged{playerid} != 1)
	{
		SendClientMessageEx(playerid, COLOR_RED, "Ban chua dang nhap.");
		return 0;
	}

	new sendername[MAX_PLAYER_NAME];
	new giveplayer[MAX_PLAYER_NAME];
	new string[128];
	playerLastTyped[playerid] = 0;


	if(TextSpamUnmute[playerid] != 0)
	{
		if(PlayerInfo[playerid][pAdmin] < 2)
		{
			SendClientMessage(playerid, COLOR_WHITE, "Ban bi mute, ban khong the noi chuyen duoc nua.");
			return 0;
		}
	}

	if(PlayerInfo[playerid][pAdmin] < 2)
	{
		if(++TextSpamTimes[playerid] == 5)
		{
			TextSpamTimes[playerid] = 0;
			TextSpamUnmute[playerid] = 10;
			SendClientMessageEx(playerid, COLOR_YELLOW, "Ban dang noi chuyen qua nhanh. Vui long thu lai sau 10 giay.");
			SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_FLOODPROTECTION);
			return 0;
		}
	}


 	/*Compares last string with current, if the same, alert the staff only on the 3rd command. (Expires after 5 secs)
	if(PlayerInfo[playerid][pAdmin] < 2) {
		new laststring[128];
		if(GetPVarString(playerid, "LastText", laststring, 128)) {
			if(!strcmp(laststring, text, true)) {
				TextSpamTimes[playerid]++;

				if(TextSpamTimes[playerid] == 2) {
					TextSpamTimer[playerid] = 30;
					TextSpamTimes[playerid] = 0;
					format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) is spamming with: %s", GetPlayerNameEx(playerid), playerid, text);
					ABroadCast(COLOR_YELLOW, string, 2);
				}
			}
		}
		SetPVarString(playerid, "LastText", text);
	}*/

	if(strfind(text, "|", true) != -1) {
	    SendClientMessageEx(playerid, COLOR_RED, "Ban khong the su dung '|' nhan vat trong van ban.");
		return 0;
	}
	
	if(PlayerInfo[playerid][pMuted] == 1)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong the noi chuyen, ban dang bi mute!");
		return 0;
	}

	if (strcmp(GiftCode, "off") != 0 && strfind(text, "/giftcode") == -1)
    {
		if(strfind(text, GiftCode) != -1)
		{
		    SendClientMessageEx(playerid, COLOR_GREY, "Ban khong the cho nguoi khac gift code..");
		    return 0;
		}
	}

	if(PlayerInfo[playerid][pAdmin] < 2 && CheckServerAd(text))
	{
		format(string,sizeof(string),"{AA3333}AdmWarning{FFFF00}: %s (ID: %d) co the dang quang cao may chu: '{AA3333}%s{FFFF00}'.", GetPlayerNameEx(playerid), playerid, text);
		ABroadCast(COLOR_YELLOW, string, 2);
		Log("logs/hack.log", string);
		return 0;
	}

	if(GetPVarInt(playerid, "ChoosingDrugs") == 1)
	{
		if (strcmp("pot", text, true) == 0)
		{
			new mypoint = -1;
			for (new i=0; i<MAX_POINTS; i++)
			{
				if (IsPlayerInRangeOfPoint(playerid, 3.0, Points[i][Pointx], Points[i][Pointy], Points[i][Pointz]) && strcmp(Points[i][Name], "Drug Factory", true) == 0)
				{
					mypoint = i;
				}
			}
			if (mypoint == -1)
			{
				SendClientMessageEx(playerid, COLOR_GREY, " Ban khong o trong Drug Factory!");
				return 0;
			}
			if(PlayerInfo[playerid][pCrates])
			{
				SendClientMessageEx(playerid, COLOR_GREY, "   Ban khong the lay them Drug Crates duoc nua!");
				SetPVarInt(playerid, "ChoosingDrugs", 0);
				return 0;
			}
			if(GetPlayerCash(playerid) > 1000)
			{
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE,"* Ban da mua Drug Crates voi gia $1000.");
				GivePlayerCash(playerid, -1000);
				PlayerInfo[playerid][pCrates] = 1;
				SetPVarInt(playerid, "CrateDeliver", 1);
				SetPVarInt(playerid, "ChoosingDrugs", 0);
				SetPVarInt(playerid, "tpDrugRunTimer", 45);
				SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_TPDRUGRUNTIMER);
				SetPlayerCheckpoint(playerid, 2166.3772,-1675.3829,15.0859, 3);
				for(new i = 0; i < sizeof(FamilyInfo); i++)
				{
					if(strcmp(Points[mypoint][Owner], FamilyInfo[i][FamilyName], true) == 0)
					{
						FamilyInfo[i][FamilyBank] += 500;
					}
				}
				return 0;
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY," Ban khong co du $1000!");
				SetPVarInt(playerid, "ChoosingDrugs", 0);
   				return 0;
			}
		}
		else if (strcmp("crack", text, true) == 0)
		{
			new mypoint = -1;
			for (new i=0; i<MAX_POINTS; i++)
			{
				if (IsPlayerInRangeOfPoint(playerid, 3.0, Points[i][Pointx], Points[i][Pointy], Points[i][Pointz]) && strcmp(Points[i][Name], "Drug Factory", true) == 0)
				{
					mypoint = i;
				}
			}
			if (mypoint == -1)
			{
				SendClientMessageEx(playerid, COLOR_GREY, " Ban khong o Drug Factory!");
				return 0;
			}
			if(PlayerInfo[playerid][pCrates])
			{
				SendClientMessageEx(playerid, COLOR_GREY, "   Ban khong the lay them Drug Crates duoc nua!");
				SetPVarInt(playerid, "ChoosingDrugs", 0);
				return 0;
			}
			if(GetPlayerCash(playerid) > 1000)
			{
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE,"* Ban da mua Drug Crates voi gia $1000.");
				GivePlayerCash(playerid, -1000);
				PlayerInfo[playerid][pCrates] = 1;
				SetPVarInt(playerid, "CrateDeliver", 2);
				SetPVarInt(playerid, "ChoosingDrugs", 0);
				SetPVarInt(playerid, "tpDrugRunTimer", 45);
				SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_TPDRUGRUNTIMER);
				SetPlayerCheckpoint(playerid, 2354.2808,-1169.2959,28.0066, 3);
				for(new i = 0; i < sizeof(FamilyInfo); i++)
				{
					if(strcmp(Points[mypoint][Owner], FamilyInfo[i][FamilyName], true) == 0)
					{
						FamilyInfo[i][FamilyBank] += 500;
					}
				}
				return 0;
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY," Ban khong co du $1000!");
				SetPVarInt(playerid, "ChoosingDrugs", 0);
   				return 0;
			}
		}
		else
		{
	 		SendClientMessageEx(playerid, COLOR_LIGHTRED,"Nhung loai thuoc ma ban muon buon lau? Su dung 'crack' hoac 'pot'.");
			return 0;
		}
	}
	if(MarriageCeremoney[playerid] > 0)
	{
		if (strcmp("yes", text, true) == 0)
		{
			if(GotProposedBy[playerid] != INVALID_PLAYER_ID)
			{
				if(IsPlayerConnected(GotProposedBy[playerid]))
				{
					GetPlayerName(playerid, sendername, sizeof(sendername));
					GetPlayerName(GotProposedBy[playerid], giveplayer, sizeof(giveplayer));
					format(string, sizeof(string), "Cha su: %s dong y lay %s lam oxin mien phi? (Su dung 'yes' - nhap bat cu thu khac se tu choi ket hon).", giveplayer,sendername);
					SendClientMessageEx(GotProposedBy[playerid], COLOR_WHITE, string);
					MarriageCeremoney[GotProposedBy[playerid]] = 1;
					MarriageCeremoney[playerid] = 0;
					GotProposedBy[playerid] = INVALID_PLAYER_ID;
					return 0; // Yeah... no more "YES DILDOS SEX RAPE LOL" broadcast to the whole server
				}
				else
				{
					MarriageCeremoney[playerid] = 0;
					GotProposedBy[playerid] = INVALID_PLAYER_ID;
					return 0;
				}
			}
			else if(ProposedTo[playerid] != INVALID_PLAYER_ID)
			{
				if(IsPlayerConnected(ProposedTo[playerid]))
				{
					GetPlayerName(playerid, sendername, sizeof(sendername));
					GetPlayerName(ProposedTo[playerid], giveplayer, sizeof(giveplayer));
					if(PlayerInfo[playerid][pSex] == 1 && PlayerInfo[ProposedTo[playerid]][pSex] == 2)
					{
						format(string, sizeof(string), "Cha xu: %s va %s than men,Chu re co the hon Co dau.", sendername, giveplayer);
						SendClientMessageEx(playerid, COLOR_WHITE, string);
				   		format(string, sizeof(string), "Priest: %s va %s than men,Co dau co the hon Chu re.", giveplayer, sendername);
						SendClientMessageEx(ProposedTo[playerid], COLOR_WHITE, string);
						format(string, sizeof(string), "BAN TIN GAY: Da co mot dam cuoi cua cap doi Gay duoc  to chuc tai le duong! %s va %s da dong y thong ass nhau.", sendername, giveplayer);
						OOCNews(COLOR_WHITE, string);
					}
					else if(PlayerInfo[playerid][pSex] == 1 && PlayerInfo[ProposedTo[playerid]][pSex] == 1)
					{
						format(string, sizeof(string), "Cha xu: %s va %s than men, Chu re co the hon Co dau.", sendername, giveplayer);
						SendClientMessageEx(playerid, COLOR_WHITE, string);
				   		format(string, sizeof(string), "Cha xu: %s va %s than men, Co dau co the hon Chu re.", giveplayer, sendername);
						SendClientMessageEx(ProposedTo[playerid], COLOR_WHITE, string);
						format(string, sizeof(string), "Marriage News: We have a new gay couple! %s & %s have been married.", sendername, giveplayer);
						OOCNews(COLOR_WHITE, string);
					}
					else if(PlayerInfo[playerid][pSex] == 2 && PlayerInfo[ProposedTo[playerid]][pSex] == 2)
					{
						format(string, sizeof(string), "Cha xu: %s va %s than men, Chu re co the hon Co dau.", sendername, giveplayer);
						SendClientMessageEx(playerid, COLOR_WHITE, string);
				   		format(string, sizeof(string), "Cha xu: %s va %s than men, Co dau co the hon Chu re.", giveplayer, sendername);
						SendClientMessageEx(ProposedTo[playerid], COLOR_WHITE, string);
						format(string, sizeof(string), "BAN TIN GAY: Da co mot dam cuoi cua cap doi Gay duoc  to chuc tai le duong! %s va %s da dong y thong ass nhau.", sendername, giveplayer);
						OOCNews(COLOR_WHITE, string);
					}
					//MarriageCeremoney[ProposedTo[playerid]] = 1;
					MarriageCeremoney[ProposedTo[playerid]] = 0;
					MarriageCeremoney[playerid] = 0;
					PlayerInfo[ProposedTo[playerid]][pMarriedID] = GetPlayerSQLId(playerid);
					format(PlayerInfo[ProposedTo[playerid]][pMarriedName], MAX_PLAYER_NAME, "%s", sendername);
					PlayerInfo[playerid][pMarriedID] = GetPlayerSQLId(ProposedTo[playerid]);
					format(PlayerInfo[playerid][pMarriedName], MAX_PLAYER_NAME, "%s", giveplayer);
					GivePlayerCash(playerid, - 100000);
					ProposedTo[playerid] = INVALID_PLAYER_ID;
					MarriageCeremoney[playerid] = 0;
					return 0;
				}
				else
				{
					MarriageCeremoney[playerid] = 0;
					ProposedTo[playerid] = INVALID_PLAYER_ID;
					return 0;
				}
			}
		}
		else
		{
			if(GotProposedBy[playerid] != INVALID_PLAYER_ID)
			{
				if(IsPlayerConnected(GotProposedBy[playerid]))
				{
					format(string, sizeof(string), "* Ban co muon ket hon %s, no 'yes' de tra loi.", GetPlayerNameEx(GotProposedBy[playerid]));
					SendClientMessageEx(playerid, COLOR_YELLOW, string);
					format(string, sizeof(string), "* %s muon cuoi ban lam vo, no 'yes' de tra loi.",GetPlayerNameEx(playerid));
					SendClientMessageEx(GotProposedBy[playerid], COLOR_YELLOW, string);
					return 0;
				}
				else
				{
					MarriageCeremoney[playerid] = 0;
					GotProposedBy[playerid] = INVALID_PLAYER_ID;
					return 0;
				}
			}
			else if(ProposedTo[playerid] != INVALID_PLAYER_ID)
			{
				if(IsPlayerConnected(ProposedTo[playerid]))
				{
					format(string, sizeof(string), "* Ban khong muon ket hon %s, no 'yes' de tra loi.",GetPlayerNameEx(ProposedTo[playerid]));
					SendClientMessageEx(playerid, COLOR_YELLOW, string);
					format(string, sizeof(string), "* %s muon cuoi ban, no 'yes' de tra loi.",GetPlayerNameEx(playerid));
					SendClientMessageEx(ProposedTo[playerid], COLOR_YELLOW, string);
					return 0;
				}
				else
				{
					MarriageCeremoney[playerid] = 0;
					ProposedTo[playerid] = INVALID_PLAYER_ID;
					return 0;
				}
			}
		}
		return 0;
	}
	if(CallLawyer[playerid] == 111)
	{
		if (strcmp("yes", text, true) == 0)
		{
			format(string, sizeof(string), "** %s o tu, va can mot luat su. Hay den don canh sat.", GetPlayerNameEx(playerid));
			SendJobMessage(2, TEAM_AZTECAS_COLOR, string);
			SendJobMessage(2, TEAM_AZTECAS_COLOR, "* Khi ban o don canh sat, yeu cau mot si quan chap thuan voi ban /accept lawyer.");
			SendClientMessageEx(playerid, COLOR_LIGHTRED, "Mot yeu cau da duoc gui di toi cac luat su dang lam viec.");
			WantLawyer[playerid] = 0;
			CallLawyer[playerid] = 0;
			return 0;
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_LIGHTRED, "Khong co luat su nao dang lam viec, thoi gian  o tu cua ban da duoc thuc thi.");
			WantLawyer[playerid] = 0;
			CallLawyer[playerid] = 0;
			return 0;
		}
	}
	if(TalkingLive[playerid] != INVALID_PLAYER_ID)
	{
		if(IsAReporter(playerid))
		{
			format(string, sizeof(string), "Live|Phong vien %s: %s", GetPlayerNameEx(playerid), text);
			OOCNews(COLOR_LIGHTGREEN, string);
		}
		else
		{
			format(string, sizeof(string), "Live|Nguoi dan %s: %s", GetPlayerNameEx(playerid), text);
			OOCNews(COLOR_LIGHTGREEN, string);
		}
		return 0;
	}
	if(Mobile[playerid] != INVALID_PLAYER_ID)
	{
		format(string, sizeof(string), "(cellphone) %s noi: %s", GetPlayerNameEx(playerid), text);
		ProxDetector(20.0, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
		if(IsPlayerConnected(Mobile[playerid]))
		{
			if(Mobile[Mobile[playerid]] == playerid)
			{
				if(PlayerInfo[Mobile[playerid]][pSpeakerPhone] != 0)
				{
				    format(string, sizeof(string), "(speakerphone) %s noi: %s", GetPlayerNameEx(playerid), text);
					ProxDetector(20.0, Mobile[playerid], string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
				}
				else
				{
				    SendClientMessageEx(Mobile[playerid], COLOR_YELLOW,string);
				}
				if(PlayerInfo[playerid][pBugged] != INVALID_GROUP_ID)
			    {
			    	format(string, sizeof(string), "{8D8DFF}(BUGGED) {CBCCCE}%s (cellphone): %s", GetPlayerNameEx(playerid), text);
			    }
			    else if(PlayerInfo[Mobile[playerid]][pBugged] != INVALID_GROUP_ID){
			    	format(string, sizeof(string), "{8D8DFF}(BUG ID %d) {CBCCCE}%s (cellphone): %s", Mobile[playerid], GetPlayerNameEx(playerid), text);
			    }
				SendBugMessage(PlayerInfo[playerid][pBugged], string);
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_YELLOW,"Khong co ai o dau day!");
		}
		return 0;
	}

	sendername = GetPlayerNameEx(playerid);

	if(GetPVarInt(playerid, "IsInArena") >= 0)
	{
		new a = GetPVarInt(playerid, "IsInArena");
		if(PaintBallArena[a][pbGameType] == 2 || PaintBallArena[a][pbGameType] == 3 || PaintBallArena[a][pbGameType] == 5)
		{
			if(PlayerInfo[playerid][pPaintTeam] == 1)
			{
				format(string, sizeof(string), "[Paintball Arena] ({FF0000}Red Team{FFFFFF}) %s noi: %s", sendername, text);
			}
			if(PlayerInfo[playerid][pPaintTeam] == 2)
			{
				format(string, sizeof(string), "[Paintball Arena] ({0000FF}Blue Team{FFFFFF}) %s noi: %s", sendername, text);
			}
		}
		else
		{
			format(string, sizeof(string), "[Paintball Arena] %s noi: %s", sendername, text);
		}
		SendPaintballArenaMessage(a, COLOR_WHITE, string);
		return 0;
	}

	new accent[32];

	switch(PlayerInfo[playerid][pAccent])
	{
		case 0, 1: accent = "";
		case 2: accent = "{E068E6}(Ha Noi){FFFFFF} ";
		case 3: accent = "{F03535}(Sai Gon){FFFFFF} ";
		case 4: accent = "{7DD183}(Da Nang){FFFFFF} ";
		case 5: accent = "{DAA4F5}(Mien Bac){FFFFFF} ";
		case 6: accent = "{A4A8F5}(Mien Nam){FFFFFF} ";
		case 7: accent = "{9BEBDE}(Mien Trung){FFFFFF} ";
		case 8: accent = "{FFF52E}(Crazy){FFFFFF} ";
		case 9: accent = "{FAC832}(Kid){FFFFFF} ";
		case 10: accent = "{575752}(Troll){FFFFFF} ";
		case 11: accent = "{7ECCB9}(Music){FFFFFF} ";
		case 12: accent = "{F0E95B}(Haivl){FFFFFF} ";
		case 13: accent = "{FF0000}(Cute){FFFFFF} ";
		case 14: accent = "{A7B5B1}(Les){FFFFFF} ";
		case 15: accent = "{A7B5B1}(Gay){FFFFFF} ";
		case 16: accent = "{DBD67B}(Nha Giau){FFFFFF} ";
		case 17: accent = "{FF0000}(Dai Gia){FFFFFF} ";
		case 18: accent = "{575752}(Nha Ngheo){FFFFFF} ";
		case 19: accent = "{678AAC}(An May){FFFFFF} ";
		case 20: accent = "{678AAC}(An Xin){FFFFFF} ";
		case 21: accent = "{9277AB}(Gangster){FFFFFF} ";
		case 22: accent = "{D98FC5}(Mr.){FFFFFF} ";
		case 23: accent = "{8FD9D5}(Sinh Vien){FFFFFF} ";
		case 24: accent = "{68BA9F}(Hoc Sinh){FFFFFF} ";
		case 25: accent = "{B9BDBC}(Tre Trau){FFFFFF} ";
		case 26: accent = "{676C70}(GAMING){FFFFFF} ";
		case 27: accent = "{FF0000}(Sieu Quay){FFFFFF} ";
		case 28: accent = "{FF0000}(Sieu Nhan){FFFFFF} ";
	}

	if(WatchingTV[playerid] != 1) {

		new Float: f_playerPos[3];
		GetPlayerPos(playerid, f_playerPos[0], f_playerPos[1], f_playerPos[2]);
		new str[128];
		foreach(new i: Player)
		{
			if((InsidePlane[playerid] == GetPlayerVehicleID(i) && GetPlayerState(i) == 2) || (InsidePlane[i] == GetPlayerVehicleID(playerid) && GetPlayerState(playerid) == 2) || (InsidePlane[playerid] != INVALID_VEHICLE_ID && InsidePlane[playerid] == InsidePlane[i])) {
				/*if(PlayerInfo[playerid][pDuty] || IsAHitman(playerid)) format(string, sizeof(string), "%s{%06x}%s{E6E6E6} noi: %s", accent, GetPlayerColor(playerid) >>> 8, sendername, text);*/
				format(string, sizeof(string), "%s%s noi: %s", accent, sendername, text);
				SendClientMessageEx(i, COLOR_FADE1, string);
			}
			else if(GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid)) {
				if(IsPlayerInRangeOfPoint(i, 20.0 * 0.6, f_playerPos[0], f_playerPos[1], f_playerPos[2]) && PlayerInfo[i][pBugged] >= 0 && PlayerInfo[playerid][pAdmin] < 2 && PlayerInfo[i][pAdmin] < 2)
				{
				    if(playerid == i)
				    {
						format(string, sizeof(string), "%s%s noi: %s", accent, sendername, text);
				    	format(str, sizeof(str), "{8D8DFF}(BUGGED) {CBCCCE}%s", string);
				    }
				    else {
						format(string, sizeof(string), "%s%s noi: %s", accent, sendername, text);
				    	format(str, sizeof(str), "{8D8DFF}(BUG ID %d) {CBCCCE}%s", i,string);
				    }
				    SendBugMessage(PlayerInfo[i][pBugged], str);
				}

				if(IsPlayerInRangeOfPoint(i, 20.0 / 16, f_playerPos[0], f_playerPos[1], f_playerPos[2])) {
					format(string, sizeof(string), "%s%s noi: %s", accent, sendername, text);
					SendClientMessageEx(i, COLOR_FADE1, string);
				}
				else if(IsPlayerInRangeOfPoint(i, 20.0 / 8, f_playerPos[0], f_playerPos[1], f_playerPos[2])) {
					format(string, sizeof(string), "%s%s noi: %s", accent, sendername, text);
					SendClientMessageEx(i, COLOR_FADE2, string);
				}
				else if(IsPlayerInRangeOfPoint(i, 20.0 / 4, f_playerPos[0], f_playerPos[1], f_playerPos[2])) {
					format(string, sizeof(string), "%s%s noi: %s", accent, sendername, text);
					SendClientMessageEx(i, COLOR_FADE3, string);
				}
				else if(IsPlayerInRangeOfPoint(i, 20.0 / 2, f_playerPos[0], f_playerPos[1], f_playerPos[2])) {
					format(string, sizeof(string), "%s%s noi: %s", accent, sendername, text);
					SendClientMessageEx(i, COLOR_FADE4, string);
				}
				else if(IsPlayerInRangeOfPoint(i, 20.0, f_playerPos[0], f_playerPos[1], f_playerPos[2])) {
					format(string, sizeof(string), "%s%s noi: %s", accent, sendername, text);
					SendClientMessageEx(i, COLOR_FADE5, string);
				}
			}
			if(GetPVarInt(i, "BigEar") == 1 || GetPVarInt(i, "BigEar") == 6 && GetPVarInt(i, "BigEarPlayer") == playerid) {
				format(string, sizeof(string), "%s%s noi: %s", accent, sendername, text);
				new string2[128] = "(BE) ";
				strcat(string2,string, sizeof(string2));
				SendClientMessageEx(i, COLOR_FADE1, string);
			}
		}
	}
	SetPlayerChatBubble(playerid,text,COLOR_WHITE,20.0,5000);

	format(string, sizeof(string), "(BE) %s: %s", GetPlayerNameEx(playerid), text);
	foreach(new i: Player)
	{
	    if(PlayerInfo[i][pAdmin] > 1 && GetPVarInt(i, "BigEar") == 3)
	    {
	        SendClientMessageEx(i, COLOR_WHITE, string);
		}
	}
	return 0;
}

public OnUnoccupiedVehicleUpdate(vehicleid, playerid, passenger_seat)
{
	if(DynVeh[vehicleid] != -1)
	{
	    new vw[1];
		vw[0] = GetVehicleVirtualWorld(vehicleid);
	    if(DynVehicleInfo[DynVeh[vehicleid]][gv_iAttachedObjectModel][0] != INVALID_OBJECT_ID)
	    {
	    	Streamer_SetArrayData(STREAMER_TYPE_OBJECT, DynVehicleInfo[DynVeh[vehicleid]][gv_iAttachedObjectID][0], E_STREAMER_WORLD_ID, vw[0]);

		}
		if(DynVehicleInfo[DynVeh[vehicleid]][gv_iAttachedObjectModel][1] != INVALID_OBJECT_ID)
	    {
			Streamer_SetArrayData(STREAMER_TYPE_OBJECT, DynVehicleInfo[DynVeh[vehicleid]][gv_iAttachedObjectID][1], E_STREAMER_WORLD_ID, vw[0]);

		}
	}
	return 1;
}

public OnPlayerModelSelectionEx(playerid, response, extraid, modelid)
{
	if(extraid == DYNAMIC_FAMILY_CLOTHES)
	{
		if(response)
		{
			PlayerInfo[playerid][pModel] = modelid;
			SetPlayerSkin(playerid, modelid);
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban da thay doi skin cua ban.");
		}
		else
			return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da thoat lua chon  skin.");
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	if((PlayerInfo[playerid][pAdmin] >= 1 || PlayerInfo[playerid][pSMod] >= 2) && source == CLICK_SOURCE_SCOREBOARD)
	{
		new szString[5], string[MAX_PLAYER_NAME+82];
		format(szString, sizeof(szString), "%i", clickedplayerid);
		format(string, sizeof(string), "Ban co muon cung cap cho %s mot lan doi ten mien phi?", GetPlayerNameEx(clickedplayerid));
		SetPVarString(playerid, "nrn", szString);
		ShowPlayerDialog(playerid, DIALOG_NRNCONFIRM, DIALOG_STYLE_MSGBOX, "Xac nhan dieu nay", string, "Dong y", "Khong");
	} 
	return true;
}

public OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	if(response == EDIT_RESPONSE_FINAL)
	{
		new string[128];
		if(GetPVarInt(playerid, "gt_Edit") == 2)
		{
			if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pGangModerator] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong duoc phep su dung lenh nay!");
			new gangtag = GetPVarInt(playerid, "gt_ID");
			GangTags[gangtag][gt_PosX] = x;
			GangTags[gangtag][gt_PosY] = y;
			GangTags[gangtag][gt_PosZ] = z;
			GangTags[gangtag][gt_PosRX] = rx;
			GangTags[gangtag][gt_PosRY] = ry;
			GangTags[gangtag][gt_PosRZ] = rz;
			CreateGangTag(gangtag);
			format(string, sizeof(string), "Ban chinh sua vi tri gang tag %d!", gangtag);
			SendClientMessageEx(playerid, COLOR_WHITE, string);
			format(string, sizeof(string), "%s sua vi tri gang tag %d.", GetPlayerNameEx(playerid), gangtag);
			Log("Logs/GangTags.log", string);
			DeletePVar(playerid, "gt_ID");
			DeletePVar(playerid, "gt_Edit");
			SaveGangTag(gangtag);
		}
		if(GetPVarInt(playerid, "gEdit") == 1)
		{
			if(PlayerInfo[playerid][pAdmin] < 4) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong duoc phep su dung lenh nay!");
			new gateid = GetPVarInt(playerid, "EditingGateID");
			GateInfo[gateid][gPosX] = x;
			GateInfo[gateid][gPosY] = y;
			GateInfo[gateid][gPosZ] = z;
			GateInfo[gateid][gRotX] = rx;
			GateInfo[gateid][gRotY] = ry;
			GateInfo[gateid][gRotZ] = rz;
			CreateGate(gateid);
			SaveGate(gateid);
			format(string, sizeof(string), "Ban da chinh sua xong vi tri mo GATE ID: %d", gateid);
			SendClientMessage(playerid, COLOR_WHITE, string);
			DeletePVar(playerid, "gEdit");
			DeletePVar(playerid, "EditingGateID");
		}
		if(GetPVarInt(playerid, "gEdit") == 2)
		{
			if(PlayerInfo[playerid][pAdmin] < 4) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong duoc phep su dung lenh nay!");
			new gateid = GetPVarInt(playerid, "EditingGateID");
			GateInfo[gateid][gPosXM] = x;
			GateInfo[gateid][gPosYM] = y;
			GateInfo[gateid][gPosZM] = z;
			GateInfo[gateid][gRotXM] = rx;
			GateInfo[gateid][gRotYM] = ry;
			GateInfo[gateid][gRotZM] = rz;
			CreateGate(gateid);
			SaveGate(gateid);
			format(string, sizeof(string), "Ban da chinh sua xong vi tri dong GATE ID: %d", gateid);
			SendClientMessage(playerid, COLOR_WHITE, string);
			DeletePVar(playerid, "gEdit");
			DeletePVar(playerid, "EditingGateID");
		}
	}
	if(response == EDIT_RESPONSE_CANCEL)
	{
		if(GetPVarInt(playerid, "gt_Edit") == 2)
		{
			new gangid = GetPVarInt(playerid, "gt_ID");
			SetDynamicObjectPos(GangTags[gangid][gt_Object], GangTags[gangid][gt_PosX], GangTags[gangid][gt_PosY], GangTags[gangid][gt_PosZ]);
			SetDynamicObjectRot(GangTags[gangid][gt_Object], GangTags[gangid][gt_PosRX], GangTags[gangid][gt_PosRY], GangTags[gangid][gt_PosRZ]);
			DeletePVar(playerid, "gt_Edit");
			DeletePVar(playerid, "gt_ID");
			SendClientMessageEx(playerid, COLOR_GREY, "Ban da dung chinh sua tag gang nay!");
		}
		if(GetPVarType(playerid, "gEdit") == 1)
		{
			CreateGate(GetPVarInt(playerid, "EditingGateID"));
			DeletePVar(playerid, "gEdit");
			DeletePVar(playerid, "EditingGateID");
			SendClientMessage(playerid, COLOR_WHITE, "Ban da dung chinh sua GATE.");
		}
	}
	return 1;
}
