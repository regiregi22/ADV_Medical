/*
ADV-aceSplint - by Belbo
*/

private _handle = _this spawn {

	params ["_target","_oldBPS","_oldGetHitPoint","_oldGetHitPoint_BP","_hitPointArray","_selectionNumber"];

	_hitPointArray params ["_hitpoint","_bodyPart","_selection","_str"];

	[_target,format ["Reopening of Splint is being handled for %1.",_bodyPart]] call adv_aceSplint_fnc_diag;

	private _chance = (missionNamespace getVariable ["adv_aceSplint_reopenChance",0]) min 100;
	private _reuse = (missionNamespace getVariable ["adv_aceSplint_reuseChance",80]) min 100;
	private _reopenTime = missionNamespace getVariable ["adv_aceSplint_reopenTime",600];
	private _time = (_reopenTime + ( round(random 60)-30 )) max 30;

	_target setVariable ["adv_aceSplint_reopenUndo",false];
	
	if (ceil random 100 <= _chance) exitWith {
		[_target,format ["Splint for %1 will reopen in %2 seconds.",_bodyPart,_time]] call adv_aceSplint_fnc_diag;
		
		//make sure we exit, if PAK is used:
		private _pakHandle = ["ace_treatmentSucceded",{
			params ["_caller", "_target", "_selectionName", "_className"];
			if (toUpper _className isEqualTo "PERSONALAIDKIT" && local _target) exitWith {
				_target setVariable ["adv_aceSplint_reopenUndo",true];
			};
		}] call CBA_fnc_addEventHandler;
		
		sleep _time;
		
		["ace_treatmentSucceded", _pakHandle] call CBA_fnc_removeEventHandler;
		if (_target getVariable "adv_aceSplint_reopenUndo") exitWith {
			[_target,"Splint was supposed to fall off, but PAK prevented that."] call adv_aceSplint_fnc_diag;		
			nil
		};
		
		private _bps = _target getVariable ["ace_medical_bodypartstatus",[0,0,0,0,0,0]];
		_bps set [_selectionNumber,_oldBPS];
		_target setVariable ["ace_medical_bodypartstatus",_bps,true];
		
		private _splints = _target getVariable ["adv_aceSplint_splints",[0,0,0,0,0,0]];
		_splints set [_selectionNumber,0];
		_target setVariable ["adv_aceSplint_splints",_splints,true];

		[_target,_hitpoint,_oldGetHitPoint,false] call ace_medical_fnc_setHitPointDamage;
		[_target,_bodyPart,_oldGetHitPoint_BP,false] call ace_medical_fnc_setHitPointDamage;
		
		private _lost = if (ceil random 100 <= _reuse) then { false } else { true };
		if (_lost) then {
			[localize "STR_ADV_ACESPLINT_REOPEN_HINT_LOST", "\adv_aceSplint\ui\splint.paa", nil, _target, 2.7] call ace_common_fnc_displayTextPicture;
		} else {
			[localize "STR_ADV_ACESPLINT_REOPEN_HINT", "\adv_aceSplint\ui\splint.paa", nil, _target, 2.7] call ace_common_fnc_displayTextPicture;
			/*
			if (vehicle _target isEqualTo _target) exitWith {
				private _usedSplint = createVehicle ["WeaponHolderSimulated", _target modelToWorldVisual (_target selectionPosition _selection), [], 0, "CAN_COLLIDE"];
				_usedSplint addItemCargoGlobal ["adv_aceSplint_splint", 1];
				_usedSplint setVelocity [sin(getdir _target+0)*1,cos(getdir _target+0)*1.5,0];
			};
			*/
			_target addItem "adv_aceSplint_splint";
		};
		
		[_target, "activity", localize "STR_ADV_ACESPLINT_REOPEN", []] call ace_medical_fnc_addToLog;
		[_target, "activity_view", localize "STR_ADV_ACESPLINT_REOPEN", []] call ace_medical_fnc_addToLog;
		
		[_target,format ["Splint for %1 has reopened, new ace_medical_bodypartstatus is %2",_bodyPart,_bps]] call adv_aceSplint_fnc_diag;
	};
};

_handle