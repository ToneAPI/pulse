global function InitViewStatsMapsMenu
global function setit

struct
{
	var menu
	GridMenuData gridData
	bool isGridInitialized = false
	array<string> allMaps
} file

void function InitViewStatsMapsMenu()
{
	var menu = GetMenu( "ViewStats_Maps_Menu" )
	file.menu = menu

	Hud_SetText( Hud_GetChild( file.menu, "MenuTitle" ), "#STATS_MAPS" )

	file.gridData.rows = 5
	file.gridData.columns = 1
	//file.gridData.numElements // Set in OnViewStatsWeapons_Open after itemdata exists
	file.gridData.pageType = eGridPageType.VERTICAL
	file.gridData.tileWidth = 224
	file.gridData.tileHeight = 112
	file.gridData.paddingVert = 6
	file.gridData.paddingHorz = 6

	Grid_AutoAspectSettings( menu, file.gridData )

	file.gridData.initCallback = MapButton_Init
	file.gridData.getFocusCallback = MapButton_GetFocus
	file.gridData.clickCallback = MapButton_Activate

	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnViewStatsWeapons_Open )

	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

void function OnViewStatsWeapons_Open()
{
	UI_SetPresentationType( ePresentationType.NO_MODELS )

	file.allMaps = GetPrivateMatchMaps()

	file.gridData.numElements = file.allMaps.len()

	if ( !file.isGridInitialized )
	{
		GridMenuInit( file.menu, file.gridData )
		file.isGridInitialized = true
	}

	file.gridData.currentPage = 0

	Grid_InitPage( file.menu, file.gridData )
	Hud_SetFocused( Grid_GetButtonForElementNumber( file.menu, 0 ) )
}

bool function MapButton_Init( var button, int elemNum )
{
	string mapName = file.allMaps[ elemNum ]
	UpdateStatsForMap( mapName )
	asset mapImage = GetMapImageForMapName( mapName )

	var rui = Hud_GetRui( button )
	RuiSetImage( rui, "buttonImage", mapImage )

	Hud_SetEnabled( button, true )
	Hud_SetVisible( button, true )

	return true
}

void function MapButton_GetFocus( var button, int elemNum )
{
	if ( IsControllerModeActive() )
		UpdateStatsForMap( file.allMaps[ elemNum ] )
}

void function MapButton_Activate( var button, int elemNum )
{
	if ( !IsControllerModeActive() )
		UpdateStatsForMap( file.allMaps[ elemNum ] )
}

int function GetGameStatForMapInt( string gameStat, string mapName )
{
	array<string> privateMatchModes = GetPrivateMatchModes()

	int totalStat = 0
	int enumCount = PersistenceGetEnumCount( "gameModes" )
	for ( int modeId = 0; modeId < enumCount; modeId++ )
	{
		string modeName = PersistenceGetEnumItemNameForIndex( "gameModes", modeId )

		totalStat += GetGameStatForMapAndModeInt( gameStat, mapName, modeName )
	}

	return totalStat
}

int function GetGameStatForMapAndModeInt( string gameStat, string mapName, string modeName, string difficulty = "1" )
{
	string statString = GetStatVar( "game_stats", gameStat, "" )
	string persistentVar = Stats_GetFixedSaveVar( statString, mapName, modeName, difficulty )

	return GetUIPlayer().GetPersistentVarAsInt( persistentVar )
}

float function GetGameStatForMapFloat( string gameStat, string mapName )
{
	array<string> privateMatchModes = GetPrivateMatchModes()

	float totalStat = 0
	int enumCount = PersistenceGetEnumCount( "gameModes" )
	for ( int modeId = 0; modeId < enumCount; modeId++ )
	{
		string modeName = PersistenceGetEnumItemNameForIndex( "gameModes", modeId )

		totalStat += GetGameStatForMapAndModeFloat( gameStat, mapName, modeName )
	}

	return totalStat
}

float function GetGameStatForMapAndModeFloat( string gameStat, string mapName, string modeName )
{
	string statString = GetStatVar( "game_stats", gameStat, "" )
	string persistentVar = Stats_GetFixedSaveVar( statString, mapName, modeName, "1" )

	return expect float( GetUIPlayer().GetPersistentVar( persistentVar ) )
}


void function UpdateStatsForMap( string mapName )
{
	entity player = GetUIPlayer()
	if ( player == null )
		return

	Hud_SetText( Hud_GetChild( file.menu, "WeaponName" ), GetMapDisplayName( mapName ) )

	fetchGamemodeStatsFromToneAPI(mapName)

	// Image
	var imageElem = Hud_GetRui( Hud_GetChild( file.menu, "WeaponImageLarge" ) )
	RuiSetImage( imageElem, "basicImage", GetMapImageForMapName( mapName ) )

	string timePlayed = "null"
	string gamesPlayed = "null"

	SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat0" ), Localize( "#STATS_HEADER_TIME_PLAYED" ), 		timePlayed )
	SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat1" ), Localize( "#STATS_GAMES_PLAYED" ), 				gamesPlayed )
	//SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat2" ), Localize( "#STATS_GAMES_PLAYED" ), 				gamesPlayed )
	//SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat3" ), Localize( "#STATS_GAMES_PLAYED" ), 				gamesPlayed )

	SetStatsLabelValue( file.menu, "KillsLabel0", 				"KILLS ON MAP" )
	SetStatsLabelValue( file.menu, "KillsValue0", 				getFromToneAPI(mapName, "maps", "kills") )

	SetStatsLabelValue( file.menu, "KillsLabel1", 				"DEATHS ON MAP" )
	SetStatsLabelValue( file.menu, "KillsValue1", 				getFromToneAPI(mapName, "maps", "deaths") )

	SetStatsLabelValue( file.menu, "KillsLabel2", 				"TOTAL SHOT DISTANCE" )
	SetStatsLabelValue( file.menu, "KillsValue2", 				string(int((1.905 * float(getFromToneAPI(mapName, "maps", "total_distance") ) ) )/100) + "m" )

	SetStatsLabelValue( file.menu, "KillsLabel3", 				"MAXIMUM SHOT DISTANCE" )
	SetStatsLabelValue( file.menu, "KillsValue3", 				string(int((1.905 * float(getFromToneAPI(mapName, "maps", "max_distance") ) ) )/100) + "m" )

	SetStatsLabelValue( file.menu, "KillsLabel4", 				"--" )
	SetStatsLabelValue( file.menu, "KillsValue4", 				"--" )

	//var anchorElem = Hud_GetChild( file.menu, "WeaponStatsBackground" )
	//printt( Hud_GetX( anchorElem ) )
	//printt( Hud_GetX( anchorElem ) )
	//printt( Hud_GetX( anchorElem ) )
	//printt( Hud_GetX( anchorElem ) )
	//Hud_SetX( anchorElem, 0 )
	//
	array<string> gameModesArray = GetPersistenceEnumAsArray( "gameModes" )

	array<PieChartEntry> modes
	int enumCount = PersistenceGetEnumCount( "gameModes" )
	table< string, array<int> > customGamemodeList = {
		sns = [255, 178, 102, 255],
		fw = [147, 204, 57, 255],
		gg = [14, 87, 132, 255]
	}
	for ( int modeId = 0; modeId < enumCount; modeId++ )
	{
		string modeName = PersistenceGetEnumItemNameForIndex( "gameModes", modeId )
		if ( mapName in globalToneAPIGamemodeMapData && modeName in globalToneAPIGamemodeMapData[mapName] )
		{
			float modePlayedTime = 0
			modePlayedTime = float(globalToneAPIGamemodeMapData[mapName][modeName])
			if ( modePlayedTime > 0 ) {
				AddPieChartEntry( modes, GameMode_GetName( modeName ), modePlayedTime, GetGameModeDisplayColor( modeName ) )
			}
		}
	}
	foreach (string key, array<int> value in customGamemodeList)
	{
		if ( mapName in globalToneAPIGamemodeMapData && key in globalToneAPIGamemodeMapData[mapName])
		{
			float modePlayedTime = 0
			modePlayedTime = float(globalToneAPIGamemodeMapData[mapName][key])
			if ( modePlayedTime > 0 ) {
				AddPieChartEntry( modes, key, modePlayedTime, value)
			}
		}
	}
	const MAX_MODE_ROWS = 8

	if ( modes.len() > 0 )
	{
		modes.sort( ComparePieChartEntryValues )

		if ( modes.len() > MAX_MODE_ROWS )
		{
			float otherValue
			for ( int i = MAX_MODE_ROWS-1; i < modes.len() ; i++ )
				otherValue += modes[i].numValue

			modes.resize( MAX_MODE_ROWS-1 )
			AddPieChartEntry( modes, "#GAMEMODE_OTHER", otherValue, [127, 127, 127, 255] )
		}
	}

	PieChartData modesPlayedData
	modesPlayedData.entries = modes
	modesPlayedData.labelColor = [ 255, 255, 255, 255 ]
	SetPieChartData( file.menu, "ModesPieChart", "KILLS BY GAMEMODE", modesPlayedData )

	array<string> fdMaps = GetPlaylistMaps( "fd" )

	if ( 0 == 1 )  // maybe work later on some FD servers
	{
		array<var> pveElems = GetElementsByClassname( file.menu, "PvEGroup" )
		foreach ( elem in pveElems )
		{
			Hud_Show( elem )
		}

		vector perfectColor = TEAM_COLOR_FRIENDLY / 219.0

		var iconLegendRui = Hud_GetRui( Hud_GetChild( file.menu, "PvEIconLegend" ) )
		RuiSetImage( iconLegendRui, "basicImage", $"rui/menu/gametype_select/playlist_fd_normal" )
		RuiSetFloat3( iconLegendRui, "basicImageColor", perfectColor )

		var icon0Rui = Hud_GetRui( Hud_GetChild( file.menu, "PvEIcon0" ) )
		RuiSetImage( icon0Rui, "basicImage", $"rui/menu/gametype_select/playlist_fd_easy" )
		int easyWins = GetGameStatForMapAndModeInt( "games_completed_fd", mapName, "fd", "0" )
		SetStatsLabelValue( file.menu, "PvELabel0", 				"#FD_DIFFICULTY_EASY" )
		SetStatsLabelValue( file.menu, "PvEValueA0", 				easyWins )
		if ( GetGameStatForMapAndModeInt( "perfectMatches", mapName, "fd", "0" ) )
			RuiSetFloat3( icon0Rui, "basicImageColor", perfectColor )
		else
			RuiSetFloat3( icon0Rui, "basicImageColor", easyWins > 0 ? <1, 1, 1> : <0.15, 0.15, 0.15> )

		var icon1Rui = Hud_GetRui( Hud_GetChild( file.menu, "PvEIcon1" ) )
		RuiSetImage( icon1Rui, "basicImage", $"rui/menu/gametype_select/playlist_fd_normal" )
		int normalWins = GetGameStatForMapAndModeInt( "games_completed_fd", mapName, "fd", "1" )
		SetStatsLabelValue( file.menu, "PvELabel1", 				"#FD_DIFFICULTY_NORMAL" )
		SetStatsLabelValue( file.menu, "PvEValueA1", 				normalWins )
		if ( GetGameStatForMapAndModeInt( "perfectMatches", mapName, "fd", "1" ) )
			RuiSetFloat3( icon1Rui, "basicImageColor", perfectColor )
		else
			RuiSetFloat3( icon1Rui, "basicImageColor", normalWins > 0 ? <1, 1, 1> : <0.15, 0.15, 0.15> )

		var icon2Rui = Hud_GetRui( Hud_GetChild( file.menu, "PvEIcon2" ) )
		RuiSetImage( icon2Rui, "basicImage", $"rui/menu/gametype_select/playlist_fd_hard" )
		int hardWins = GetGameStatForMapAndModeInt( "games_completed_fd", mapName, "fd", "2" )
		SetStatsLabelValue( file.menu, "PvELabel2", 				"#FD_DIFFICULTY_HARD" )
		SetStatsLabelValue( file.menu, "PvEValueA2", 				hardWins )
		if ( GetGameStatForMapAndModeInt( "perfectMatches", mapName, "fd", "2" ) )
			RuiSetFloat3( icon2Rui, "basicImageColor", perfectColor )
		else
			RuiSetFloat3( icon2Rui, "basicImageColor", hardWins > 0 ? <1, 1, 1> : <0.15, 0.15, 0.15> )

		var icon3Rui = Hud_GetRui( Hud_GetChild( file.menu, "PvEIcon3" ) )
		RuiSetImage( icon3Rui, "basicImage", $"rui/menu/gametype_select/playlist_fd_master" )
		int masterWins = GetGameStatForMapAndModeInt( "games_completed_fd", mapName, "fd", "3" )
		SetStatsLabelValue( file.menu, "PvELabel3", 				"#FD_DIFFICULTY_MASTER" )
		SetStatsLabelValue( file.menu, "PvEValueA3", 				masterWins )
		if ( GetGameStatForMapAndModeInt( "perfectMatches", mapName, "fd", "3" ) )
			RuiSetFloat3( icon3Rui, "basicImageColor", perfectColor )
		else
			RuiSetFloat3( icon3Rui, "basicImageColor", masterWins > 0 ? <1, 1, 1> : <0.15, 0.15, 0.15> )

		var icon4Rui = Hud_GetRui( Hud_GetChild( file.menu, "PvEIcon4" ) )
		RuiSetImage( icon4Rui, "basicImage", $"rui/menu/gametype_select/playlist_fd_insane" )
		int insaneWins = GetGameStatForMapAndModeInt( "games_completed_fd", mapName, "fd", "4" )
		SetStatsLabelValue( file.menu, "PvELabel4", 				"#FD_DIFFICULTY_INSANE" )
		SetStatsLabelValue( file.menu, "PvEValueA4", 				insaneWins )
		if ( GetGameStatForMapAndModeInt( "perfectMatches", mapName, "fd", "4" ) )
			RuiSetFloat3( icon4Rui, "basicImageColor", perfectColor )
		else
			RuiSetFloat3( icon4Rui, "basicImageColor", insaneWins > 0 ? <1, 1, 1> : <0.15, 0.15, 0.15> )
	}
	else
	{
		array<var> pveElems = GetElementsByClassname( file.menu, "PvEGroup" )
		foreach ( elem in pveElems )
		{
			Hud_Hide( elem )
		}
	}
}


var function setit( vector color )
{
	var iconLegendRui = Hud_GetRui( Hud_GetChild( file.menu, "PvEIconLegend" ) )
	RuiSetImage( iconLegendRui, "basicImage", $"rui/menu/gametype_select/playlist_fd_normal" )
	RuiSetFloat3( iconLegendRui, "basicImageColor", color )
}