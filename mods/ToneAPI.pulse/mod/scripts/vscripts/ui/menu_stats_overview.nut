untyped

global function InitViewStatsOverviewMenu

struct
{
	var menu
	array<ItemDisplayData> allTitans
	array<ItemDisplayData> allPilotWeapons
	table<string, array<string> > titanStatLoadout
} file

const MAX_DOTS_ON_GRAPH = 10
table <string, int> titanKillData = {}
table <string, int> pilotKillData = {}

const IMAGE_TITAN_STRYDER = $"ui/menu/personal_stats/ps_titan_icon_stryder"
const IMAGE_TITAN_ATLAS = $"ui/menu/personal_stats/ps_titan_icon_atlas"
const IMAGE_TITAN_OGRE = $"ui/menu/personal_stats/ps_titan_icon_ogre"

void function InitViewStatsOverviewMenu()
{
	PrecacheHUDMaterial( IMAGE_TITAN_STRYDER )
	PrecacheHUDMaterial( IMAGE_TITAN_ATLAS )
	PrecacheHUDMaterial( IMAGE_TITAN_OGRE )

	var menu = GetMenu( "ViewStats_Overview_Menu" )
	file.menu = menu

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnStatsOverview_Open )

	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

void function GetTitanKills()
{
	file.allTitans = GetVisibleItemsOfType( eItemTypes.TITAN )
	var dataTable = GetDataTable( $"datatable/titan_properties.rpak" )

	foreach ( titan in file.allTitans )
	{
		file.titanStatLoadout[ titan.ref ] <- []

		int row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "titanRef" ), titan.ref )
		file.titanStatLoadout[ titan.ref ].append( GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "primary" ) ) )
		file.titanStatLoadout[ titan.ref ].append( GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "ordnance" ) ) )
		file.titanStatLoadout[ titan.ref ].append( GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "special" ) ) )
		file.titanStatLoadout[ titan.ref ].append( GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "antirodeo" ) ) )
		file.titanStatLoadout[ titan.ref ].append( GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "coreAbility" ) ) )
		file.titanStatLoadout[ titan.ref ].append( GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "melee" ) ) )
	}

	foreach ( titan in file.allTitans)
	{
		foreach ( weaponRef in file.titanStatLoadout[ titan.ref ])
		{
			titanKillData[weaponRef] <- pulseParse("weaponsLocal", weaponRef, "kills")
		}
	}
}

void function GetAllPilotWeapons()
{
	file.allPilotWeapons = GetVisibleItemsOfType( eItemTypes.PILOT_PRIMARY)
	file.allPilotWeapons.extend(GetVisibleItemsOfType( eItemTypes.PILOT_SECONDARY) )
	file.allPilotWeapons.extend(GetVisibleItemsOfType( eItemTypes.PILOT_ORDNANCE) )
	file.allPilotWeapons.extend( GetVisibleItemsOfType( eItemTypes.PILOT_SPECIAL ) )
}


void function OnStatsOverview_Open()
{
	UI_SetPresentationType( ePresentationType.NO_MODELS )
	GetTitanKills()
	UpdateViewStatsOverviewMenu()
}

function UpdateViewStatsOverviewMenu()
{
	entity player = GetUIPlayer()
	if ( player == null )
		return

	//#########################
	// 		  Games
	//#########################

	string timePlayed = StatToTimeString( "time_stats", "hours_total" )
	int gamesPlayed = GetPlayerStat_AllCompetitiveModesAndMapsInt( player, "game_stats", "game_completed" )
	int gamesWon = GetPlayerStat_AllCompetitiveModesAndMapsInt( player, "game_stats", "game_won" )
	string winPercent = GetPercent( float( gamesWon ), float( gamesPlayed ), 0 )
	int timesMVP = GetPlayerStatInt( player, "game_stats", "mvp_total" )
	int timesTop3 = GetPlayerStat_AllCompetitiveModesAndMapsInt( player, "game_stats", "top3OnTeam" )

	//SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat0" ), Localize( "#STATS_HEADER_TIME_PLAYED" ), timePlayed )
	//SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat1" ), Localize( "#STATS_GAMES_PLAYED" ), 		string( gamesPlayed ) )
	//SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat2" ), Localize( "#STATS_GAMES_WON" ), 			string( gamesWon ) )
	//SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat3" ), Localize( "#STATS_GAMES_WIN_PERCENT" ), 	Localize( "#STATS_PERCENTAGE", winPercent ) )
	//SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat4" ), Localize( "#STATS_GAMES_MVP" ), 			string( timesMVP ) )
	//SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat5" ), Localize( "#STATS_GAMES_TOP3" ), 		string( timesTop3 ) )

	SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat0" ), Localize( "#STATS_HEADER_TIME_PLAYED" ), string( 0 ))
	SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat1" ), Localize( "#STATS_GAMES_PLAYED" ), 		string( 0 ) )
	SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat2" ), Localize( "#STATS_GAMES_WON" ), 			string( 0 ) )
	SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat3" ), Localize( "#STATS_GAMES_WIN_PERCENT" ), 	string( 0 ) )
	SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat4" ), Localize( "#STATS_GAMES_MVP" ), 			string( 0 ) )
	SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat5" ), Localize( "#STATS_GAMES_TOP3" ), 		string( 0 ) )

	//#########################
	// 		   Modes
	//#########################

	/*local gameModePlayedVar = GetStatVar( "game_stats", "mode_played" )
	local basicModes = [ "tdm", "cp", "at", "lts", "ctf" ]

	local timesPlayedArray = []
	local gameModeNamesArray = []
	local otherGameModesPlayed = 0
	array<string> gameModesArray = GetPersistenceEnumAsArray( "gameModes" )

	foreach ( modeName in gameModesArray )
	{
		local gameModePlaysVar = StringReplace( expect string( gameModePlayedVar ), "%gamemode%", modeName )
		local timesPlayed = player.GetPersistentVar( gameModePlaysVar )

		if ( basicModes.contains( modeName ) )  //Don't really like doing ArrayContains, but Chad prefers not storing a separate enum in persistence that contains the "other" gamemodes
		{
			timesPlayedArray.append( timesPlayed )
			gameModeNamesArray.append( GAMETYPE_TEXT[ modeName] )
		}
		else
		{
			otherGameModesPlayed += timesPlayed
		}
	}

	//Add Other game modes' data to the end of the arrays
	gameModeNamesArray.append( "#GAMEMODE_OTHER"  )
	timesPlayedArray.append( otherGameModesPlayed )

	local data = {}
	data.names <- gameModeNamesArray
	data.values <- timesPlayedArray

	SetPieChartData( menu, "ModesPieChart", "#GAME_MODES_PLAYED", data )*/

	//#########################
	// 		Completion
	//#########################

	// Challenges complete
	//local challengeData = GetChallengeCompleteData()
	//SetStatsBarValues( menu, "CompletionBar0", "#STATS_COMPLETION_CHALLENGES", 		0, challengeData.total, challengeData.complete )

	// Item unlocks
	//local itemUnlockData = GetItemUnlockCountData()
	//SetStatsBarValues( menu, "CompletionBar1", "#STATS_COMPLETION_WEAPONS", 	0, itemUnlockData["weapons"].total, 	itemUnlockData["weapons"].unlocked )
	//SetStatsBarValues( menu, "CompletionBar2", "#STATS_COMPLETION_ATTACHMENTS", 0, itemUnlockData["attachments"].total, itemUnlockData["attachments"].unlocked )
	//SetStatsBarValues( menu, "CompletionBar3", "#STATS_COMPLETION_MODS", 		0, itemUnlockData["mods"].total, 		itemUnlockData["mods"].unlocked )
	//SetStatsBarValues( menu, "CompletionBar4", "#STATS_COMPLETION_ABILITIES", 	0, itemUnlockData["abilities"].total, 	itemUnlockData["abilities"].unlocked )
	//SetStatsBarValues( menu, "CompletionBar5", "#STATS_COMPLETION_GEAR", 		0, itemUnlockData["gear"].total, 		itemUnlockData["gear"].unlocked )

	//#########################
	// 		  Weapons
	//#########################

	table<string, table> weaponData = GetOverviewWeaponData()
	table mostKillsData = weaponData[ "most_kills" ]
	table nemesisWeapon = weaponData[ "nemesis_weapon" ]
	table highestKPMData = weaponData[ "highest_kpm" ]

	var weaponImageElem
	var weaponRui
	var weaponNameElem
	var weaponDescElem
	var noDataElem

	// Weapon with most kills
	weaponImageElem = Hud_GetChild( file.menu, "WeaponImage0" )
	weaponRui = Hud_GetRui( weaponImageElem )
	weaponNameElem = Hud_GetChild( file.menu, "WeaponName0" )
	weaponDescElem = Hud_GetChild( file.menu, "WeaponDesc0" )
	noDataElem = Hud_GetChild( file.menu, "WeaponImageTextOverlay0" )
	if ( mostKillsData.ref != "" )
	{
		SetItemImageWidth( weaponImageElem, expect string( mostKillsData.ref ) )
		RuiSetImage( weaponRui, "buttonImage", GetItemImage( expect string( mostKillsData.ref ) ) )
		Hud_Show( weaponImageElem )
		Hud_SetText( weaponNameElem, mostKillsData.printName )
		Hud_Show( weaponNameElem )
		Hud_SetText( weaponDescElem, "#STATS_MOST_KILLS_VALUE", mostKillsData.val )
		Hud_Show( weaponDescElem )
		Hud_Hide( noDataElem )
	}
	else
	{
		Hud_Hide( weaponImageElem )
		Hud_Hide( weaponNameElem )
		Hud_Hide( weaponDescElem )
		Hud_Show( noDataElem )
	}

	// Most Used Weapon
	weaponImageElem = Hud_GetChild( file.menu, "WeaponImage1" )
	weaponRui = Hud_GetRui( weaponImageElem )
	weaponNameElem = Hud_GetChild( file.menu, "WeaponName1" )
	weaponDescElem = Hud_GetChild( file.menu, "WeaponDesc1" )
	noDataElem = Hud_GetChild( file.menu, "WeaponImageTextOverlay1" )
	if ( nemesisWeapon.ref != "" )
	{
		SetItemImageWidth( weaponImageElem, expect string( nemesisWeapon.ref ) )
		RuiSetImage( weaponRui, "buttonImage", GetItemImage( expect string( nemesisWeapon.ref ) ) )
		Hud_Show( weaponImageElem )
		Hud_SetText( weaponNameElem, nemesisWeapon.printName )
		Hud_Show( weaponNameElem )
		Hud_SetText( weaponDescElem, Localize("#NEMESIS_WEAPON_VALUE"), nemesisWeapon.val)
		Hud_Show( weaponDescElem )
		Hud_Hide( noDataElem )
	}
	else
	{
		Hud_Hide( weaponImageElem )
		Hud_Hide( weaponNameElem )
		Hud_Hide( weaponDescElem )
		Hud_Show( noDataElem )
	}

	// Weapon with highest KPM
	weaponImageElem = Hud_GetChild( file.menu, "WeaponImage2" )
	weaponRui = Hud_GetRui( weaponImageElem )
	weaponNameElem = Hud_GetChild( file.menu, "WeaponName2" )
	weaponDescElem = Hud_GetChild( file.menu, "WeaponDesc2" )
	noDataElem = Hud_GetChild( file.menu, "WeaponImageTextOverlay2" )
	if ( highestKPMData.ref != "" )
	{
		SetItemImageWidth( weaponImageElem, expect string( highestKPMData.ref ) )
		RuiSetImage( weaponRui, "buttonImage", GetItemImage( expect string( highestKPMData.ref ) ) )
		Hud_Show( weaponImageElem )
		Hud_SetText( weaponNameElem, highestKPMData.printName )
		Hud_Show( weaponNameElem )
		Hud_SetText( weaponDescElem, "%s1 K/D", highestKPMData.val)
		Hud_Show( weaponDescElem )
		Hud_Hide( noDataElem )
	}
	else
	{
		Hud_Hide( weaponImageElem )
		Hud_Hide( weaponNameElem )
		Hud_Hide( weaponDescElem )
		Hud_Show( noDataElem )
	}

	//#########################
	// 		Titan Unlocks
	//#########################

	Assert( player == GetUIPlayer() )
	Assert( player != null )

	int unlockedCount = 0

	//var imageLabel = GetElem( menu, "TitanUnlockImage0" )
	//if ( !IsItemLocked( player, "titan_stryder" ) )
	//{
	//	imageLabel.SetImage( IMAGE_TITAN_STRYDER )
	//	unlockedCount++
	//}
	//else
	//	imageLabel.SetImage( $"ui/menu/personal_stats/ps_titan_icon_locked" )
	//
	//imageLabel = GetElem( menu, "TitanUnlockImage1" )
	//if ( !IsItemLocked( player, "titan_atlas" ) )
	//{
	//	imageLabel.SetImage( IMAGE_TITAN_ATLAS )
	//	unlockedCount++
	//}
	//else
	//	imageLabel.SetImage( $"ui/menu/personal_stats/ps_titan_icon_locked" )
	//
	//imageLabel = GetElem( menu, "TitanUnlockImage2" )
	//if ( !IsItemLocked( player, "titan_ogre" ) )
	//{
	//	imageLabel.SetImage( IMAGE_TITAN_OGRE )
	//	unlockedCount++
	//}
	//else
	//	imageLabel.SetImage( $"ui/menu/personal_stats/ps_titan_icon_locked" )
	//
	//var unlockCountLabel = GetElem( menu, "TitanUnlocksCount" )
	//Hud_SetText( unlockCountLabel, "#STATS_CHASSIS_UNLOCK_COUNT", string( unlockedCount ) )

	//#########################
	// 	   K/D Ratios
	//#########################

	// Lifetime
	table playerweaponData = expect table(pulseData["weaponsLocal"])
	table globalweaponData = expect table(pulseData["weaponsGlobal"])


	var totalPilotKills = 0
	var totalPilotDeaths = 0
	foreach (var key, var value in playerweaponData) {
		table values = expect table(value)
		totalPilotKills += values["kills"]
		totalPilotDeaths += values["deaths"]
	}

	var totalGlobalKills = 0
	var totalGlobalDeaths = 0
	foreach (var key, var value in globalweaponData) {
		table values = expect table(value)
		totalGlobalKills += values["kills"]
		totalGlobalDeaths += values["deaths"]
	}


	var killsAsTitan = 0
	var killsAsPilot = 0
	foreach (var key, var value in playerweaponData) {
		if (key in titanKillData) {
			killsAsTitan += titanKillData[string(key)]
		} else {
			killsAsPilot += pulseParse("weaponsLocal", string(key), "kills")
		}
	}

	float kval = float(totalPilotKills)
	float dval = float(totalPilotDeaths)
	float kdval = float(int((kval / dval)*100))/100

	float gkval = float(totalGlobalKills)
	float gdval = float(totalGlobalDeaths)
	float gkdval = float(int((gkval / gdval)*100))/100

	SetStatsLabelValue( file.menu, "LifetimeAverageValue", [ "#STATS_KD_VALUE", kdval ] )

	SetStatsLabelValue( file.menu, "LifetimePVPAverageValue", [ "#STATS_KD_VALUE", gkdval ] )

	bool last10GamesStatsVisible = gamesPlayed >= NUM_GAMES_TRACK_KDRATIO ? true : false
	SetLast10GamesStatVisibility( file.menu, last10GamesStatsVisible )

	// Last 10 Matches
	local kdratio_match = []
	local kdratiopvp_match = []
	for ( int i = NUM_GAMES_TRACK_KDRATIO - 1 ; i >= 0 ; i-- )
	{
		kdratio_match.append( player.GetPersistentVar( "kdratio_match[" + i + "]" ) )
		kdratiopvp_match.append( player.GetPersistentVar( "kdratiopvp_match[" + i + "]" ) )
	}

	// Last 10
	local kdratio_match_sum = 0
	local count = 0
	foreach( value in kdratio_match )
	{
		if ( value == 0 )
			continue
		kdratio_match_sum += value
		count++
	}
	local kdratio_match_average = count > 0 ? kdratio_match_sum / count : kdratio_match_sum
	if ( kdratio_match_average % 1 == 0 )
		kdratio_match_average = format( "%.0f", kdratio_match_average )
	else
		kdratio_match_average = format( "%.1f", kdratio_match_average )
	SetStatsLabelValue( file.menu, "Last10GamesValue", [ "#STATS_KD_VALUE", kdratio_match_average ] )
	PlotKDPointsOnGraph( file.menu, 0, kdratio_match, kdval )

	// Last 10 (PVP)
	local kdratiopvp_match_sum = 0
	count = 0
	foreach( value in kdratiopvp_match )
	{
		if ( value == 0 )
			continue
		kdratiopvp_match_sum += value
		count++
	}
	local kdratiopvp_match_average = count > 0 ? kdratiopvp_match_sum / count : kdratiopvp_match_sum
	if ( kdratiopvp_match_average % 1 == 0 )
		kdratiopvp_match_average = format( "%.0f", kdratiopvp_match_average )
	else
		kdratiopvp_match_average = format( "%.1f", kdratiopvp_match_average )
	SetStatsLabelValue( file.menu, "Last10GamesPVPValue", [ "#STATS_KD_VALUE", kdratiopvp_match_average ] )
	PlotKDPointsOnGraph( file.menu, 1, kdratiopvp_match, gkdval )

	/////////////////////////
	Hud_SetText( GetElem( file.menu, "KillsAsPilotValue0" ), string( killsAsPilot ) )
	Hud_SetText( GetElem( file.menu, "KillsAsPilotValue1" ), string( GetPlayerStatInt( player, "kills_stats", "titanKillsAsPilot" ) ) )
	Hud_SetText( GetElem( file.menu, "KillsAsPilotValue2" ), string( GetPlayerStatInt( player, "kills_stats", "totalNPC" ) ) )
	Hud_SetText( GetElem( file.menu, "KillsAsPilotValue3" ), string( pulseParse("weaponsLocal", "pilot_emptyhanded", "kills") + pulseParse("weaponsLocal", "melee_pilot_kunai", "kills") ) )
	Hud_SetText( GetElem( file.menu, "KillsAsPilotValue4" ), string( pulseParse("weaponsLocal", "human_execution", "kills") ) )
//	Hud_SetText( GetElem( file.menu, "KillsAsPilotValue5" ), string( GetPlayerStatInt( player, "kills_stats", "titanFallKill" ) ) )

	var titanMeleeKills = 0
	titanMeleeKills += pulseParse("weaponsLocal", "titan_punch_ion", "kills")
	titanMeleeKills += pulseParse("weaponsLocal", "titan_punch_scorch", "kills")
	titanMeleeKills += pulseParse("weaponsLocal", "titan_punch_northstar", "kills")
	titanMeleeKills += pulseParse("weaponsLocal", "titan_sword", "kills")
	titanMeleeKills += pulseParse("weaponsLocal", "titan_punch_tone", "kills")
	titanMeleeKills += pulseParse("weaponsLocal", "titan_punch_legion", "kills")
	titanMeleeKills += pulseParse("weaponsLocal", "titan_punch_vanguard", "kills")
	titanMeleeKills += pulseParse("weaponsLocal", "auto_titan_melee", "kills")

	var titanExecutions = pulseParse("weaponsLocal", "titan_execution", "kills")

	Hud_SetText( GetElem( file.menu, "KillsAsTitanValue0" ), string( killsAsTitan ) )
	Hud_SetText( GetElem( file.menu, "KillsAsTitanValue1" ), string( GetPlayerStatInt( player, "kills_stats", "titanKillsAsTitan" ) ) )
	Hud_SetText( GetElem( file.menu, "KillsAsTitanValue2" ), string( titanExecutions ) )
	Hud_SetText( GetElem( file.menu, "KillsAsTitanValue3" ), string( titanMeleeKills ) )
	Hud_SetText( GetElem( file.menu, "KillsAsTitanValue4" ), string( pulseParse("weaponsLocal", "damagedef_titan_step", "kills") ) )
}

function PlotKDPointsOnGraph( menu, graphIndex, values, dottedAverage )
{
	//printt( "values:" )
	//PrintTable( values )

	var background = GetElem( menu, "KDRatioLast10Graph" + graphIndex )
	local graphHeight = Hud_GetBaseHeight( background )
	local graphOrigin = Hud_GetAbsPos( background )
	graphOrigin[1] += graphHeight
	local dotSpacing = Hud_GetBaseWidth( background ) / 9.0
	local dotPositions = []

	// Calculate min/max for the graph
	local graphMin = 0.0
	local graphMax = max( dottedAverage, 1.0 )
	foreach( value in values )
	{
		if ( value > graphMax )
			graphMax = value
	}
	graphMax += graphMax * 0.1

	var maxLabel = GetElem( menu, "Graph" + graphIndex + "ValueMax" )
	local maxValueString = format( "%.1f", graphMax )
	Hud_SetText( maxLabel, maxValueString )

	// Plot the dots
	for ( int i = 0; i < MAX_DOTS_ON_GRAPH; i++ )
	{
		var dot = GetElem( menu, "Graph" + graphIndex + "Dot" + i )

		if ( i >= values.len() )
		{
			Hud_Hide( dot )
			continue
		}

		float dotOffset = GraphCapped( values[i], graphMin, graphMax, 0, graphHeight )

		local posX = graphOrigin[0] - ( Hud_GetBaseWidth( dot ) * 0.5 ) + ( dotSpacing * i )
		local posY = graphOrigin[1] - ( Hud_GetBaseHeight( dot ) * 0.5 ) - dotOffset
		Hud_SetPos( dot, posX, posY )
		Hud_Show( dot )

		dotPositions.append( [ posX + ( Hud_GetBaseWidth( dot ) * 0.5 ), posY + ( Hud_GetBaseHeight( dot ) * 0.5 ) ] )
	}

	{
		// Place the dotted lifetime average line
		var dottedLine = GetElem( menu, "KDRatioLast10Graph" + graphIndex + "DottedLine0" )
		float dottedLineOffset = GraphCapped( dottedAverage, graphMin, graphMax, 0, graphHeight )
		local posX = graphOrigin[0]
		local posY = graphOrigin[1] - ( Hud_GetBaseHeight( dottedLine ) * 0.5 ) - dottedLineOffset
		Hud_SetPos( dottedLine, posX, posY )
		Hud_Show( dottedLine )
	}

	{
		// Place the dotted zero line
		var dottedLine = GetElem( menu, "KDRatioLast10Graph" + graphIndex + "DottedLine1" )
		float dottedLineOffset = GraphCapped( 0.0, graphMin, graphMax, 0, graphHeight )
		local posX = graphOrigin[0]
		local posY = graphOrigin[1] - ( Hud_GetBaseHeight( dottedLine ) * 0.5 ) - dottedLineOffset
		Hud_SetPos( dottedLine, posX, posY )
		Hud_Show( dottedLine )
	}

	// Connect the dots with lines
	for ( int i = 1; i < MAX_DOTS_ON_GRAPH; i++ )
	{
		var line = GetElem( menu, "Graph" + graphIndex + "Line" + i )

		if ( i >= values.len() )
		{
			Hud_Hide( line )
			continue
		}

		// Get angle from previous dot to this dot
		local startPos = dotPositions[i-1]
		local endPos = dotPositions[i]
		local offsetX = endPos[0] - startPos[0]
		local offsetY = endPos[1] - startPos[1]
		local angle = ( atan( offsetX / offsetY ) * ( 180 / PI ) )

		// Get line length
		local length = sqrt( offsetX * offsetX + offsetY * offsetY )

		// Calculate where the line should be positioned
		local posX = endPos[0] - ( offsetX / 2.0 ) - ( length / 2.0 )
		local posY = endPos[1] - ( offsetY / 2.0 ) - ( Hud_GetBaseHeight( line ) / 2.0 )

		//line.SetHeight( 2.0 )
		Hud_SetWidth( line, length )
		Hud_SetRotation( line, angle + 90.0 )
		Hud_SetPos( line, posX, posY )
		Hud_Show( line )
	}
}

void function SetLast10GamesStatVisibility( var menu, bool visible )
{
	Hud_SetVisible( Hud_GetChild( menu, "Last10GamesLabel" ), visible )
	Hud_SetVisible( Hud_GetChild( menu, "Last10GamesValue" ), visible )
	Hud_SetVisible( Hud_GetChild( menu, "Last10GamesPVPLabel" ), visible )
	Hud_SetVisible( Hud_GetChild( menu, "Last10GamesPVPValue" ), visible )
}

void function SetItemImageWidth( var imageElem, string ref )
{
	vector vec = GetItemImageAspect( ref )
	float aspectRatio = vec.x / vec.y
	int imageWidth = int( Hud_GetHeight( imageElem ) * aspectRatio )
	Hud_SetWidth( imageElem, imageWidth )
}