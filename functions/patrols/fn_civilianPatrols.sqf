if ( liberation_civilian_activity > 0 ) then {
	for [ {_i=0}, {_i < LIB_civilians_amount}, {_i=_i+1} ] do { [] spawn manageOneCivilianPatrol };
};