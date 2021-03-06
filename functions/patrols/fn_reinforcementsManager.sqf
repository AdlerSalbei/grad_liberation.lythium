params ["_targetsector"];

if (combat_readiness > 15) then {

	private _init_units_count = (([getmarkerpos _targetsector, LIB_capture_size, LIB_side_enemy] call grad_liberation_common_fnc_getUnitsCount));

	if !(_targetsector in sectors_bigtown) then {
		while {(_init_units_count * 0.75) <= ([getmarkerpos _targetsector, LIB_capture_size, LIB_side_enemy] call grad_liberation_common_fnc_getUnitsCount)} do {
			sleep 5;
		};
	};

	if (_targetsector in active_sectors) then {

		private _nearestower = [markerpos _targetsector, LIB_side_enemy, LIB_radiotower_size * 1.4] call grad_liberation_common_fnc_getNearestTower;

		if (_nearestower != "") then {
			private _reinforcements_time = (((((markerpos _nearestower) distance (markerpos _targetsector)) / 1000) ^ 1.66 ) * 120) / (liberation_difficulty_modifier * liberation_csat_aggressivity);
			if (_targetsector in sectors_bigtown) then {
				_reinforcements_time = _reinforcements_time * 0.35;
			};
			private _current_timer = time;

			waitUntil {sleep 1; (_current_timer + _reinforcements_time < time) || (_targetsector in blufor_sectors) || (_nearestower in blufor_sectors)};

			sleep 15;

			if ((_targetsector in active_sectors) && !(_targetsector in blufor_sectors) && !(_nearestower in blufor_sectors) && (!([] call grad_liberation_common_fnc_isBigtownActive) || _targetsector in sectors_bigtown)) then {
				reinforcements_sector_under_attack = _targetsector;
				reinforcements_set = true;
				["lib_reinforcements",[markertext _targetsector]] remoteExec ["bis_fnc_shownotification"];
				if ((random combat_readiness) > (20 + (30 / liberation_csat_aggressivity))) then {
					[_targetsector] spawn sendParatroopers;
				};
				stats_reinforcements_called = stats_reinforcements_called + 1;
			};
		};
	};
};
