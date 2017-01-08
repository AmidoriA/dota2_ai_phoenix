-- math.randomseed(os.time())
SelectedHeroes = {}
TeamDoneSelection = {}
----------------------------------------------------------------------------------------------------
function randomHero()
	local HeroesImplemented = require(GetScriptDirectory().."/HeroesImplemented")
	::random_again::
	local index = RandomInt(1, #HeroesImplemented)

	for _,v in pairs(SelectedHeroes) do
		-- If heroes already select
	  if v == HeroesImplemented[index] then
	    print(v)
	    print("already selected")
	    goto random_again
	    break
	  end
	end

	table.insert(SelectedHeroes, HeroesImplemented[index])
	return HeroesImplemented[index]
end


function Think()
	local Team = GetTeam()

  for _,v in pairs(TeamDoneSelection) do
		-- If heroes already select
	  if v == Team then
	    return true
	  end
	end

	local IDs=GetTeamPlayers(Team);
	for i,id in pairs(IDs) do
		if IsPlayerBot(id) and (id == 1) then
			SelectHero(id, "npc_dota_hero_phoenix");
			table.insert(SelectedHeroes, "npc_dota_hero_phoenix")
		elseif IsPlayerBot(id) then
			SelectHero(id, randomHero());
		end
	end

	table.insert(TeamDoneSelection, Team)

	-- if ( GetTeam() == TEAM_RADIANT )
	-- then
	-- 	print( "selecting radiant" );
	-- 	SelectHero( 0, randomHero() );
	-- 	SelectHero( 1, "npc_dota_hero_phoenix" ); -- Force selecting Phoenix
	-- 	table.insert(SelectedHeroes, "npc_dota_hero_phoenix")
	-- 	SelectHero( 2, randomHero() );
	-- 	SelectHero( 3, randomHero() );
	-- 	SelectHero( 4, randomHero() );
	-- elseif ( GetTeam() == TEAM_DIRE )
	-- then
	-- 	print( "selecting dire" );
	-- 	SelectHero( 5, randomHero() );
	-- 	SelectHero( 6, randomHero() );
	-- 	SelectHero( 7, randomHero() );
	-- 	SelectHero( 8, randomHero() );
	-- 	SelectHero( 9, randomHero() );
	-- end

end

----------------------------------------------------------------------------------------------------


