------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
require( GetScriptDirectory().."/mode_secret_shop_custom" )
Utility = require(GetScriptDirectory().."/Utility")
----------

function OnStart()
	mode_secret_shop_custom.OnStart();
end

function OnEnd()
	mode_secret_shop_custom.OnEnd();
end

function GetDesire()
	return mode_secret_shop_custom.GetDesire();
end

function Think()
	mode_secret_shop_custom.Think();
end

--------
