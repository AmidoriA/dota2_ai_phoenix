function OnStart()
	local npcBot = GetBot();
  npcBot:Action_Chat("Attack!!", false);

  local abilityFireSpirits = npcBot:GetAbilityByName( "phoenix_fire_spirits" );

  if npcBot:GetMana() > 300 and abilityFireSpirits:IsFullyCastable() and not abilityFireSpirits:IsHidden() then
  	npcBot:Action_UseAbility( abilityFireSpirits );
  end
end