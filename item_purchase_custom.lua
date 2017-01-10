_G._savedEnv = getfenv()
module( "item_purchase_custom", package.seeall )

-- Utility = require(GetScriptDirectory().."/Utility")

_LevelUp = function()
  local npcBot = GetBot();
  -- print('_LevelUp');
	if #npcBot.AbilityPriority==0 then
    print(#npcBot.AbilityPriority==0);
		return;
	end
	
  -- Prevent bot try to level up ability before pick screen end
	if DotaTime() < 0 then
		return;
	end

	local ability=npcBot:GetAbilityByName(npcBot.AbilityPriority[1]);

  if(ability == nil) then
    print ('wrong ability name');
  end

	if (ability~=nil and ability:CanAbilityBeUpgraded() and ability:GetLevel()<ability:GetMaxLevel()) then
		npcBot:Action_LevelAbility(npcBot.AbilityPriority[1]);
		table.remove( npcBot.AbilityPriority, 1 );
	end

  -- if not ability:CanAbilityBeUpgraded() then
  --   print('ability:CanAbilityBeUpgraded()');
  --   print(ability:GetName());
  --   print(npcBot:GetUnitName());
  -- end

  -- if not (ability:GetLevel()<ability:GetMaxLevel()) then
  --   print('ability:GetLevel(): '..ability:GetLevel());
  --   print('ability:GetMaxLevel(): '..ability:GetMaxLevel());
  --   print('ability:GetLevel()<ability:GetMaxLevel()');
  -- end

  -- print ('other');
end

function alwaysBuyTP()
	local npcBot = GetBot();

  if not IsCourierAvailable() then
    return false; -- prevent error when courier carrying TP. We cannot count tp in courier
  end

	if DotaTime() < 60 then
		return false;
	end

	local iScrollCount = 0;
  -- Count current number of TP scrolls (how to count stack?)
  for i=0, 15 
  do
    local sCurItem = npcBot:GetItemInSlot ( i );
    if ( sCurItem ~= nil and sCurItem:GetName() == "item_tpscroll")
    then
        iScrollCount = iScrollCount + 1;
    end
  end

  print ('Current TP = '..iScrollCount);
  if iScrollCount > 1 then
    return false;
  end


  -- If we are at the sideshop with no TPs, then buy two
  if ( npcBot:DistanceFromSideShop() == 0 ) then
    npcBot:Action_PurchaseItem( "item_tpscroll" );
    npcBot:Action_PurchaseItem( "item_tpscroll" );
    return true;
  end

  if ( npcBot:DistanceFromFountain() == 0 and DotaTime()>30) then
    print ('Current TP = '..iScrollCount);
    npcBot:Action_PurchaseItem( "item_tpscroll" );
    return true;
  end
end

function ItemPurchaseThink(LevelUp)
	local npcBot = GetBot();

  if DotaTime() < -90 then
    return false;
  end

  if ( npcBot:DistanceFromFountain() == 0 and DotaTime() > 400) then
    Utility.DropJunks();
  end

	alwaysBuyTP();

  -- if Utility.GetHeroLevel() == 1 then
  --   print (npcBot:GetAbilityPoints());
  -- end
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

  if #npcBot.ItemsToBuy > 0 then
    npcBot:SetNextItemPurchaseValue( GetItemCost( npcBot.ItemsToBuy[1] ) );
  end
end

for k,v in pairs( item_purchase_custom ) do	_G._savedEnv[k] = v end