params [ "_sector" ];
private [ "_actual_capture_size", "_red_forces", "_blue_forces", "_ratio" ];

_actual_capture_size = LIB_capture_size;
if ( _sector in sectors_bigtown ) then {
	_actual_capture_size = LIB_capture_size * 1.4;
};

_red_forces = [ (markerpos _sector), _actual_capture_size, LIB_side_enemy ] call grad_liberation_shared_fnc_getUnitsCount;
_blue_forces = [ (markerpos _sector), _actual_capture_size, LIB_side_friendly ] call grad_liberation_shared_fnc_getUnitsCount;
_ratio = -1;

if (_red_forces > 0) then {
	_ratio = _blue_forces / ( _red_forces + _blue_forces );
} else {
	if ( _sector in blufor_sectors || _blue_forces != 0 ) then {
		_ratio = 1;
	} else {
		_ratio = 0;
	};
};

_ratio
