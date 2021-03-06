if (!isServer) exitWith {};

params ["_index", "_nearfob", "_clientID"];

logiError = 0;

if (((liberation_logistics select _index) select 1) <= 0) exitWith {logiError = 1; _clientID publicVariableClient "logiError";};

private _storage_areas = [_nearfob nearobjects (LIB_fob_range * 2), {(_x getVariable ["liberation_storage_type",-1]) == 0}] call BIS_fnc_conditionalSelect;

if ((count _storage_areas) == 0) exitWith {(localize "STR_LOGISTIC_NOSPACE") remoteExec ["hint",_clientID]; logiError = 1; _clientID publicVariableClient "logiError";};

private _price_s = 50;
private _price_a = 0;
private _price_f = 50;

private _crateSum = (ceil(_price_s / 100)) + (ceil(_price_a / 100)) + (ceil(_price_f / 100));

private _spaceSum = 0;

{
	if (typeOf _x == liberation_large_storage_building) then {
		_spaceSum = _spaceSum + (count liberation_large_storage_positions) - (count (attachedObjects _x));
	};
	if (typeOf _x == liberation_small_storage_building) then {
		_spaceSum = _spaceSum + (count liberation_small_storage_positions) - (count (attachedObjects _x));
	};
} forEach _storage_areas;

if (_spaceSum < _crateSum) exitWith {(localize "STR_LOGISTIC_NOSPACE") remoteExec ["hint",_clientID]; logiError = 1; _clientID publicVariableClient "logiError";};

{
	private _space = 0;
	if (typeOf _x == liberation_large_storage_building) then {
		_space = (count liberation_large_storage_positions) - (count (attachedObjects _x));
	};
	if (typeOf _x == liberation_small_storage_building) then {
		_space = (count liberation_small_storage_positions) - (count (attachedObjects _x));
	};

	while {(_space > 0) && (_price_s > 0)} do {
		private _amount = 100;
		if ((_price_s / 100) < 1) then {
			_amount = _price_s;
		};
		_price_s = _price_s - _amount;
		private _crate = [liberation_supply_crate, _amount, getPos _x] call grad_liberation_common_fnc_createCrate;
		[_crate, _x] call grad_liberation_common_fnc_crateToStorage;
		_space = _space - 1;
	};

	while {(_space > 0) && (_price_a > 0)} do {
		private _amount = 100;
		if ((_price_a / 100) < 1) then {
			_amount = _price_a;
		};
		_price_a = _price_a - _amount;
		private _crate = [liberation_ammo_crate, _amount, getPos _x] call grad_liberation_common_fnc_createCrate;
		[_crate, _x] call grad_liberation_common_fnc_crateToStorage;
		_space = _space - 1;
	};

	while {(_space > 0) && (_price_f > 0)} do {
		private _amount = 100;
		if ((_price_f / 100) < 1) then {
			_amount = _price_f;
		};
		_price_f = _price_f - _amount;
		private _crate = [liberation_fuel_crate, _amount, getPos _x] call grad_liberation_common_fnc_createCrate;
		[_crate, _x] call grad_liberation_common_fnc_crateToStorage;
		_space = _space - 1;
	};

	if ((_price_s == 0) && (_price_a == 0) && (_price_f == 0)) exitWith {};
} forEach _storage_areas;

please_recalculate = true;

(liberation_logistics select _index) set [1, ((liberation_logistics select _index) select 1) - 1];
