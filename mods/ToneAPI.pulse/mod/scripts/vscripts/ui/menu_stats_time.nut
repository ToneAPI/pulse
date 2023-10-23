
global function InitViewStatsTimeMenu
global function AddPieChartEntry

const MAX_MODE_ROWS = 8

struct
{
	var menu
	array<ItemDisplayData> allTitans
	table<string, array<string> > titanStatLoadout
} file

void function InitViewStatsTimeMenu()
{
	var menu = GetMenu( "ViewStats_Time_Menu" )
	file.menu = menu

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnStatsTime_Open )

	AddMenuFooterOption( menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

void function OnStatsTime_Open()
{
	UI_SetPresentationType( ePresentationType.NO_MODELS )

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

	UpdateViewStatsTimeMenu()
}

float function GetTitanKills( string titanName)
{
	float weaponKills = 0
	foreach ( weaponRef in file.titanStatLoadout[ titanName ])
	{
		weaponKills += float(pulseParse("weaponsLocal", weaponRef, "kills"))
	}
	return weaponKills
}

void function UpdateViewStatsTimeMenu()
{
	entity player = GetUIPlayer()
	if ( player == null )
		return

	//#########################################
	float killsAsTitan = 0
	float killsAsIon = GetTitanKills( "ion" )
	killsAsTitan += killsAsIon
	float killsAsScorch = GetTitanKills( "scorch" )
	killsAsTitan += killsAsScorch
	float killsAsNorthstar = GetTitanKills( "northstar" )
	killsAsTitan += killsAsNorthstar
	float killsAsRonin = GetTitanKills( "ronin" )
	killsAsTitan += killsAsRonin
	float killsAsTone = GetTitanKills( "tone" )
	killsAsTitan += killsAsTone
	float killsAsLegion = GetTitanKills( "legion" )
	killsAsTitan += killsAsLegion
	float killsAsMonarch = GetTitanKills( "vanguard" )
	killsAsTitan += killsAsMonarch
	//#########################################
	// 		  Time By Class Pie Chart
	//#########################################

	var totalPilotKills = 0
	table playerweaponData = expect table(pulseData["weaponsLocal"])

	foreach (var key, var value in playerweaponData) {
		table values = expect table(value)
		totalPilotKills += values["kills"]
	}
	float hoursAsPilot = float(totalPilotKills)
	float hoursAsTitan = killsAsTitan

	array<PieChartEntry> classes

	if ( hoursAsPilot > 0 )
		AddPieChartEntry( classes, "#STATS_HEADER_PILOT", hoursAsPilot, [61, 117, 193, 255] )

	if ( hoursAsTitan > 0 )
		AddPieChartEntry( classes, "#STATS_HEADER_TITAN", hoursAsTitan, [223, 94, 0, 255] )

	classes.sort( ComparePieChartEntryValues )

	PieChartData classTimeData
	classTimeData.entries = classes
	classTimeData.labelColor = [ 255, 255, 255, 255 ]
	SetPieChartData( file.menu, "ClassPieChart", Localize("#TIME_KILLS_CLASS"), classTimeData )

	//#########################################
	// 		 Time By Chassis Pie Chart
	//#########################################

	array<PieChartEntry> titans

	if ( killsAsIon > 0 )
		AddPieChartEntry( titans, "#TITAN_ION", killsAsIon, [200, 40, 40, 255] )

	if ( killsAsScorch > 0 )
		AddPieChartEntry( titans, "#TITAN_SCORCH", killsAsScorch, [223, 94, 0, 255] )

	if ( killsAsNorthstar > 0 )
		AddPieChartEntry( titans, "#TITAN_NORTHSTAR", killsAsNorthstar, [61, 117, 193, 255] )

	if ( killsAsRonin > 0 )
		AddPieChartEntry( titans, "#TITAN_RONIN", killsAsRonin, [207, 191, 59, 255] )

	if ( killsAsTone > 0 )
		AddPieChartEntry( titans, "#TITAN_TONE", killsAsTone, [88, 172, 67, 255] )

	if ( killsAsLegion > 0 )
		AddPieChartEntry( titans, "#TITAN_LEGION", killsAsLegion, [46, 188, 180, 255] )

	if ( killsAsMonarch > 0 )
		AddPieChartEntry( titans, "#TITAN_VANGUARD", killsAsMonarch, [151, 71, 175, 255] )

	titans.sort( ComparePieChartEntryValues )

	PieChartData chassisTimeData
	chassisTimeData.entries = titans
	chassisTimeData.labelColor = [ 255, 255, 255, 255 ]
	SetPieChartData( file.menu, "ChassisPieChart", Localize("#TIME_KILLS_TITAN"), chassisTimeData )

	//#########################################
	// 		  Time By Mode Pie Chart
	//#########################################

	array<string> gameModesArray = GetPersistenceEnumAsArray( "gameModes" )

	array<PieChartEntry> modes
	int enumCount = PersistenceGetEnumCount( "gameModes" )
	table< string, array<int> > customGamemodeList = {
		sns = [255, 178, 102, 255],
		fw = [147, 204, 57, 255],
		gg = [14, 87, 132, 255]
	}
	table< string, string > customGamemodeNames = {
		sns = Localize("#GAMEMODE_sns")
		fw = Localize("#GAMEMODE_fw")
		gg = Localize("#GAMEMODE_gg")
	}
	for ( int modeId = 0; modeId < enumCount; modeId++ )
	{
		string modeName = PersistenceGetEnumItemNameForIndex( "gameModes", modeId )
		if ( pulseParse("gamemodesAll", modeName, "kills") != 0 )
		{
			float modePlayedTime = 0
			modePlayedTime = float(pulseParse("gamemodesAll", modeName, "kills"))
			if ( modePlayedTime > 0 ) {
				AddPieChartEntry( modes, GameMode_GetName( modeName ), modePlayedTime, GetGameModeDisplayColor( modeName ) )
			}
		}
	}
	foreach (string key, array<int> value in customGamemodeList)
	{
		if ( pulseParse("gamemodesAll", key, "kills") != 0 )
		{
			float modePlayedTime = 0
			modePlayedTime = float(pulseParse("gamemodesAll", key, "kills"))
			if ( modePlayedTime > 0 ) {
				AddPieChartEntry( modes, customGamemodeNames[key], modePlayedTime, value)
			}
		}
	}

	PieChartData modesPlayedData
	modesPlayedData.entries = modes
	modesPlayedData.labelColor = [ 255, 255, 255, 255 ]
	SetPieChartData( file.menu, "ModesPieChart", Localize("#KILLS_GAMEMODE"), modesPlayedData )

	//#########################################
	// 				Time Stats
	//#########################################

	SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat0" ), Localize( "#STATS_HEADER_TIME_PLAYED" ), 		StatToTimeString( "time_stats", "hours_total" ) )
	SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat1" ), Localize( "#STATS_HEADER_TIME_IN_AIR" ), 		StatToTimeString( "time_stats", "hours_inAir" ) )
	SetStatBoxDisplay( Hud_GetChild( file.menu, "Stat2" ), Localize( "#STATS_HEADER_TIME_WALLRUNNING" ), 	StatToTimeString( "time_stats", "hours_wallrunning" ) )
}

void function AddPieChartEntry( array<PieChartEntry> entries, string displayName, float numValue, array<int> color )
{
	PieChartEntry newEntry
	newEntry.displayName = displayName
	newEntry.numValue = numValue
	newEntry.color = color

	entries.append( newEntry )
}