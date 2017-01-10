_G._savedEnv = getfenv()
module( "item_purchase_custom", package.seeall )

-- Utility = require(GetScriptDirectory().."/Utility")

LevelUp = function()
  local npcBot = GetBot();
	if #npcBot.AbilityPriority==0 then
		return;
	end
	
	if GameTime()<10 then
		return;
	end

	local ability=npcBot:GetAbilityByName(npcBot.AbilityPriority[1]);

	if (ability~=nil and ability:CanAbilityBeUpgraded() and ability:GetLevel()<ability:GetMaxLevel()) then
		npcBot:Action_LevelAbility(npcBot.AbilityPriority[1]);
		table.remove( npcBot.AbilityPriority, 1 );
	end
end

function alwaysBuyTP()
	local npcBot = GetBot();
	if DotaTime() < 60 then
		return false;
	end

	local iScrollCount = 0;
  -- Count current number of TP scrolls (how to count stack?)
  for i=0,8 
  do
    local sCurItem = npcBot:GetItemInSlot ( i );
    if ( sCurItem ~= nil and sCurItem:GetName() == "item_tpscroll")
    then
        iScrollCount = iScrollCount + 1;
    end
  end

  if iScrollCount > 1 then
  	return false;
  end

  -- If we are at the sideshop with no TPs, then buy two
  if ( npcBot:DistanceFromSideShop() == 0 ) then
    npcBot:Action_PurchaseItem( "item_tpscroll" );
    npcBot:Action_PurchaseItem( "item_tpscroll" );
    return true;
  end

  if ( npcBot:DistanceFromFountain() == 0 and DOTATime()>30) then
    npcBot:Action_PurchaseItem( "item_tpscroll" );
    return true;
  end
end

function ItemPurchaseThink(LevelUp)
	local npcBot = GetBot();

	alwaysBuyTP();

	----
	if npcBot:GetAbilityPoints()>0 then
		LevelUp(npcBot.AbilityPriority);
	end
	
	if ( npcBot.ItemsToBuy==nil or #npcBot.ItemsToBuy == 0 ) then
		npcBot:SetNextItemPurchaseValue( 0 );
		return;
	end

	local NextItem = npcBot.ItemsToBuy[1];

	npcBot:SetNextItemPurchaseValue( GetItemCost( NextItem ) );

	if (not IsItemPurchasedFromSecretShop( NextItem)) and (not(IsItemPurchasedFromSideShop(NextItem) and npcBot:DistanceFromSideShop()<=2200)) then
		if ( npcBot:GetGold() >= GetItemCost( NextItem ) ) then
			npcBot:Action_PurchaseItem( NextItem );
			table.remove( npcBot.ItemsToBuy, 1 );
		end
	end
end

for k,v in pairs( item_purchase_custom ) do	_G._savedEnv[k] = v end