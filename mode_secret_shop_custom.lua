------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

_G._savedEnv = getfenv()
module( "mode_secret_shop_custom", package.seeall )
----------
Utility = require( GetScriptDirectory().."/Utility")
----------

function  OnStart()
	local npcBot=GetBot();
	Utility.InitPath();
	npcBot.IsGoingToShop=true;
end

function OnEnd()
	local npcBot=GetBot();
	npcBot.IsGoingToShop=false;
	Utility.InitPath();
end

function GetDesire()
	local npcBot=GetBot();
	if npcBot.IsGoingToShop==nil then
		npcBot.IsGoingToShop=false;
	end

	if npcBot.ItemsToBuy==nil then
		return 0.0;
	end
	
	
	local NextItem=npcBot.ItemsToBuy[1];
	
	if not IsItemPurchasedFromSecretShop(NextItem) then
		return 0.0;
	end

	if npcBot:GetGold() < GetItemCost( NextItem ) then
		return 0.0;
	end

	local secLoc=Utility.GetSecretShop();

	local desire = 0.0;

	local desireDistance = 0.1;
	local distance = GetUnitToLocationDistance(npcBot, secLoc);
	local desireDistanceFactor = (-3.974 * math.log(distance)) + 38.963; -- desire is higher when near the secret shop

	desireDistance = desireDistance * desireDistanceFactor;
	desire = desireDistance;

	print ("Shop distance: "..distance);
	print ("Secret Shop Desire: "..desire);

	return desire;
end

function Think()
	local npcBot=GetBot();
	if npcBot.ItemsToBuy==nil or #npcBot.ItemsToBuy==0 then
		return;
	end
	
	if npcBot:IsUsingAbility() or npcBot:IsChanneling() then
		return;
	end
	
	local NextItem=npcBot.ItemsToBuy[1];

	if not IsItemPurchasedFromSecretShop(NextItem) then
		return;
	end
	if npcBot:GetGold() < GetItemCost( NextItem ) then
		return;
	end
	
	local secLoc=Utility.GetSecretShop();

	-- Going to shop
	if GetUnitToLocationDistance(npcBot,secLoc) > 250 then
		Utility.MoveSafelyToLocation(secLoc);
		return;
	end

	-- Buy item
	if npcBot:GetGold() >= GetItemCost( NextItem ) then
		npcBot:Action_PurchaseItem( NextItem );
		table.remove( npcBot.ItemsToBuy, 1 );
		return;
	end
	
end

--------
for k,v in pairs( mode_secret_shop_custom ) do	_G._savedEnv[k] = v end
