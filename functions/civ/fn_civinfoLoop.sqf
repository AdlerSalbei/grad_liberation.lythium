waitUntil {sleep 10; ({_x in sectors_capture || _x in sectors_bigtown} count blufor_sectors) > 0};

if (liberation_civinfo_debug > 0) then {private _text = format ["[KP LIBERATION] [CIVINFO] Loop spawned on: %1", debug_source];_text remoteExec ["diag_log",2];};

while {true} do {
	uiSleep (liberation_civinfo_min + round (random (liberation_civinfo_max - liberation_civinfo_min)));
	
	if (liberation_civinfo_debug > 0) then {private _text = "[KP LIBERATION] [CIVINFO] Informant sleep passed";_text remoteExec ["diag_log",2];};

	waitUntil {
		sleep 10;
		({_x in sectors_capture || _x in sectors_bigtown} count blufor_sectors) > 0 &&
		liberation_civ_rep >= 25
	};

	if (liberation_civinfo_debug > 0) then {private _text = "[KP LIBERATION] [CIVINFO] Informant waitUntil passed";_text remoteExec ["diag_log",2];};

	if ((liberation_civinfo_chance >= (random 100)) && LIB_endgame == 0) then {
		private _sector = selectRandom ([blufor_sectors, {_x in sectors_capture || _x in sectors_bigtown}] call BIS_fnc_conditionalSelect);
		private _house = (nearestObjects [[((getMarkerPos _sector select 0) - 100 + (random 200)), ((getMarkerPos _sector select 1) - 100 + (random 200))],["House", "Building"], 100]) select 0;
		
		private _grp = createGroup LIB_side_civilian;
		private _informant = _grp createUnit [(selectRandom civilians), getMarkerPos _sector, [], 0, "NONE"];
		private _waiting_time = liberation_civinfo_duration;

		_informant addMPEventHandler ["MPKilled", {_this spawn [] call grad_liberation_common_fnc_killManager}];
		_informant setPos (selectRandom (_house buildingPos -1));
		_informant setUnitPos "UP";
		sleep 1;
		_informant disableAI "ANIM";
		_informant disableAI "MOVE";
		_informant playmove "AmovPercMstpSnonWnonDnon_AmovPercMstpSsurWnonDnon";
		sleep 2;
		_informant setCaptive true;

		if (liberation_civinfo_debug > 0) then {private _text = format ["[KP LIBERATION] [CIVINFO] Informant %1 spawned on: %2 - Position: %3", name _informant, debug_source, getPos _informant];_text remoteExec ["diag_log",2];};

		[0, getPos _informant] remoteExec ["civinfo_notifications"];

		while {alive _informant && ((side (group _informant)) == LIB_side_civilian) && _waiting_time > 0} do {
			uiSleep 1;			
			private _player_near = false;
			{
				if (((_x distance _informant) < 150) && (alive _x)) exitWith {_player_near = true};
			} foreach allPlayers;

			if !(_player_near) then {
				_waiting_time = _waiting_time - 1;
			};

			if ((liberation_civinfo_debug > 0) && ((_waiting_time % 60) == 0)) then {private _text = format ["[KP LIBERATION] [CIVINFO] Informant will despawn in %1 minutes", round (_waiting_time / 60)];_text remoteExec ["diag_log",2];};
		};

		if (_waiting_time > 0) then {
			if (alive _informant) then {
				_informant enableAI "ANIM";
				_informant enableAI "MOVE";
				sleep 1;
				[_informant] remoteExec ["civinfo_escort"];
			} else {
				if (liberation_civinfo_debug > 0) then {private _text = "[KP LIBERATION] [CIVINFO] Informant is dead";_text remoteExec ["diag_log",2];};
				[3] remoteExec ["civinfo_notifications"];
			};
		} else {
			deleteVehicle _informant;
			if (liberation_civinfo_debug > 0) then {private _text = "[KP LIBERATION] [CIVINFO] Informant despawned";_text remoteExec ["diag_log",2];};
			[2] remoteExec ["civinfo_notifications"];
		};
	} else {
		if (liberation_civinfo_debug > 0) then {private _text = "[KP LIBERATION] [CIVINFO] Informant spawn chance missed";_text remoteExec ["diag_log",2];};
	};
};
