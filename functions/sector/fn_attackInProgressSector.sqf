params [ "_sector" ];
private [ "_attacktime", "_ownership", "_grp", "_squad_type" ];

sleep 5;

_ownership = [ markerpos _sector ] call grad_liberation_common_fnc_sectorOwnership;
if ( _ownership != LIB_side_enemy ) exitWith {};

_squad_type = blufor_squad_inf_light;
if ( _sector in sectors_military ) then {
	_squad_type = blufor_squad_inf;
};

if ( liberation_blufor_defenders ) then {
	_grp = creategroup LIB_side_friendly;
	{ _x createUnit [ markerpos _sector, _grp,'this addMPEventHandler ["MPKilled", {_this spawn [] call grad_liberation_common_fnc_killManager}]']; } foreach _squad_type;
	sleep 3;
	_grp setBehaviour "COMBAT";
};

sleep 60;

_ownership = [ markerpos _sector ] call grad_liberation_common_fnc_sectorOwnership;
if ( _ownership == LIB_side_friendly ) exitWith {
	if ( liberation_blufor_defenders ) then {
		{
			if ( alive _x ) then { deleteVehicle _x };
		} foreach units _grp;
	};
};

[_sector, 1] remoteExec ["remote_call_sector"];
_attacktime = LIB_vulnerability_timer;

while { _attacktime > 0 && ( _ownership == LIB_side_enemy || _ownership == LIB_side_resistance ) } do {
	_ownership = [markerpos _sector] call grad_liberation_common_fnc_sectorOwnership;
	_attacktime = _attacktime - 1;
	sleep 1;
};

waitUntil {
	sleep 1;
	[markerpos _sector] call grad_liberation_common_fnc_sectorOwnership != LIB_side_resistance;
};

if ( LIB_endgame == 0 ) then {
	if ( _attacktime <= 1 && ( [markerpos _sector] call grad_liberation_common_fnc_sectorOwnership == LIB_side_enemy ) ) then {
		blufor_sectors = blufor_sectors - [ _sector ];
		publicVariable "blufor_sectors";
		[_sector, 2] remoteExec ["remote_call_sector"];
		reset_battlegroups_ai = true;
		trigger_server_save = true;
		stats_sectors_lost = stats_sectors_lost + 1;
		{
			if (_sector in _x) exitWith {
				if ((count (_x select 3)) == 3) then {
					{
						detach _x;
						deleteVehicle _x;
					} forEach (attachedObjects ((nearestObjects [((_x select 3) select 0), [liberation_small_storage_building], 10]) select 0));
					
					deleteVehicle ((nearestObjects [((_x select 3) select 0), [liberation_small_storage_building], 10]) select 0);
				};
				liberation_production = liberation_production - [_x];
			};
		} forEach liberation_production;
	} else {
		[_sector, 3] remoteExec ["remote_call_sector"];
		{ [_x] spawn prisonnerAi; } foreach ( [ (markerpos _sector) nearEntities [ "Man", LIB_capture_size * 0.8 ], { side group _x == LIB_side_enemy } ] call BIS_fnc_conditionalSelect );
	};
};

sleep 60;

if ( liberation_blufor_defenders ) then {
	{
		if ( alive _x ) then { deleteVehicle _x };
	} foreach units _grp;
};