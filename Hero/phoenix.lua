default = require( GetScriptDirectory().."/Hero/_default");

local HeroSettings = {
  ['alias'] = 'phoenix'
};

HeroSettings.DiveToLocation = function (npcBot, location)
  local currentLocation = npcBot:GetLocation();
  local abilityIcarusDive = npcBot:GetAbilityByName( "phoenix_icarus_dive" );

  if (not abilityIcarusDive:IsFullyCastable()) or abilityIcarusDive:IsHidden() then
    return false;
  end

  npcBot.DiveStartLocation = currentLocation;
  npcBot:Action_UseAbilityOnLocation( abilityIcarusDive, location );
  return true;
end

for k,v in pairs(default) do
  if HeroSettings[k] == nil then
    HeroSettings[k] = v;
  end
end

return HeroSettings;