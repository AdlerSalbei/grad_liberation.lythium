private [ "_accelerated_time" ];

while { true } do {
	if ( liberation_shorter_nights && ( daytime > 21 || daytime < 3 ) ) then {
		_accelerated_time = liberation_time_factor * 3;
		if ( _accelerated_time > 100 ) then {
			_accelerated_time = 100;
		};
		setTimeMultiplier _accelerated_time;
	} else {
		setTimeMultiplier liberation_time_factor;
	};
	sleep 10;
};
