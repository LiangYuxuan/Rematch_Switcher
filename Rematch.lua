---@alias RematchPetID string | number

---@class Rematch
---@field altInfo RematchPetInfo
---@field events RematchEvent
---@field interact RematchInteract
---@field loadouts RematchPetLoadouts
---@field petInfo RematchPetInfo
---@field petTags RematchPetTags
---@field roster RematchRoster
---@field savedTargets RematchSavedTargets
---@field savedTeams RematchSavedTeams
---@field settings RematchSettings
---@field targetInfo RematchTargetInfo

---@class RematchEvent: Frame
---@field Fire fun(self: RematchEvent, event: string, ...): nil
---@field Register fun(self: RematchEvent, module: any, event: string, func: function): nil
---@field Unregister fun(self: RematchEvent, module: any, event: string): nil

---@class RematchInteract
---@field Update fun(self: RematchInteract): nil
---@field ShouldInteract fun(self: RematchInteract, npcID: integer | string): boolean
---@field LoadTeamID fun(self: RematchInteract, teamID: string): nil
---@field AfterTeamLoaded fun(self: RematchInteract): nil
---@field REMATCH_TARGET_CHANGED fun(self: RematchInteract): nil
---@field UPDATE_MOUSEOVER_UNIT fun(self: RematchInteract): nil
---@field PLAYER_SOFT_INTERACT_CHANGED fun(self: RematchInteract): nil

---@class RematchPetLoadouts
---@field SlotPet fun(self: RematchPetLoadouts, slot: integer, petID: RematchPetID, specialPetID: RematchPetID?, stableSlots: boolean?): nil
---@field SetSlotPetID fun(self: RematchPetLoadouts, slot: integer, petID: RematchPetID): nil
---@field RestoreKeptCompanion fun(self: RematchPetLoadouts): nil
---@field IsSlotSpecial fun(self: RematchPetLoadouts, slot: integer): boolean
---@field IsPetIDSpecial fun(self: RematchPetLoadouts, petID: RematchPetID): boolean
---@field GetSlotInfo fun(self: RematchPetLoadouts, slot: integer): RematchPetID, number?, number?, number?, boolean?
---@field GetSpecialSlotType fun(self: RematchPetLoadouts, slot: integer): 'leveling' | 'random' | 'ignored' | nil
---@field GetSpecialPetIDType fun(self: RematchPetLoadouts, petID: RematchPetID): 'leveling' | 'random' | 'ignored' | nil
---@field GetLoadoutInfo fun(self: RematchPetLoadouts, slot: integer): string?, number?, number?, number?, boolean?
---@field GetOtherPetIDs fun(self: RematchPetLoadouts, slot: integer): RematchPetID?, RematchPetID?
---@field CantSwapPets fun(self: RematchPetLoadouts): boolean
---@field NotAllMaxLevel fun(self: RematchPetLoadouts): boolean

---@class RematchPetTags
---@field Create fun(self: RematchPetTags, petID: RematchPetID, ability1: number | string, ability2: number, ability3: number): string
---@field GetAbilities fun(self: RematchPetTags, tag: string): number?, number?, number?
---@field GetSpecies fun(self: RematchPetTags, tag: string): integer?
---@field FindPetID fun(self: RematchPetTags, tag: string, excludePetIDs: table<RematchPetID, boolean>): RematchPetID?

---@class RematchRoster
---@field AllPets fun(self: RematchRoster): fun(): RematchPetID
---@field AllOwnedPets fun(self: RematchRoster): fun(): string
---@field AllSpecies fun(self: RematchRoster): fun(): string
---@field AllSpeciesPetIDs fun(self: RematchRoster, speciesID: integer): fun(): string
---@field GetNumPets fun(self: RematchRoster): number
---@field GetNumSpecies fun(self: RematchRoster): number
---@field GetNumOwned fun(self: RematchRoster): number
---@field GetNumUniqueOwned fun(self: RematchRoster): number
---@field GetSpeciesPetIDs fun(self: RematchRoster, speciesID: integer): string[]?

---@class RematchSavedTargets
---@field AllTargets fun(self: RematchSavedTargets): fun(data: table<integer, string[]>, k: integer?): (integer, string[]), table<integer, string[]>
---@field Update fun(self: RematchSavedTargets): nil
---@field Set fun(self: RematchSavedTargets, targetID: integer | string, newTeams: string[]): nil
---@field GetTeams fun(self: RematchSavedTargets, targetID: integer | string | nil): string[]?, string
---@field [integer] string[]

---@class RematchSavedTeams
---@field AllTeams fun(self: RematchSavedTeams): fun(data: table<string, RematchTeam>, k: string?): (string, RematchTeam), table<string, RematchTeam>
---@field Reset fun(self: RematchSavedTeams, teamID: string): nil
---@field Create fun(self: RematchSavedTeams): RematchTeam
---@field DeleteTeam fun(self: RematchSavedTeams, teamID: string): nil
---@field GetUniqueName fun(self: RematchSavedTeams, name: string): string
---@field GetNumTeamsWithPet fun(self: RematchSavedTeams, petID: RematchPetID): integer
---@field GetTeamIDByName fun(self: RematchSavedTeams, name: string): string?
---@field IsUserTeam fun(self: RematchSavedTeams, teamID: string): boolean
---@field GetNumTeams fun(self: RematchSavedTeams): integer
---@field Wipe fun(self: RematchSavedTeams): nil
---@field TeamsChanged fun(self: RematchSavedTeams, now: boolean?): nil
---@field [string] RematchTeam

---@class RematchTargetInfo
---@field SetRecentTarget fun(self: RematchTargetInfo, npcID: integer | string): nil
---@field GetTargetHistory fun(self: RematchTargetInfo): integer[]
---@field GetUnitNpcID fun(self: RematchTargetInfo, unit: string): integer?
---@field GetNpcName fun(self: RematchTargetInfo, npcID: integer | string, noDisplay: boolean?): string?
---@field GetNpcDisplayID fun(self: RematchTargetInfo, npcID: integer): integer?
---@field AllTargets fun(self: RematchTargetInfo): fun(): integer
---@field IsNotable fun(self: RematchTargetInfo, npcID: integer | string): boolean
---@field IsWildPet fun(self: RematchTargetInfo, npcID: integer): boolean
---@field GetNpcInfo fun(self: RematchTargetInfo, npcID: integer | string): string?, integer?, integer?, integer?
---@field GetNpcID fun(self: RematchTargetInfo, targetID: string): integer?
---@field GetNpcPets fun(self: RematchTargetInfo, npcID: integer | string): RematchPetInfo[]
---@field GetNumPets fun(self: RematchTargetInfo, npcID: integer | string): integer
---@field GetHeaderID fun(self: RematchTargetInfo, npcID: integer | string): string?
---@field GetHeaderName fun(self: RematchTargetInfo, headerID: string): string?
---@field GetHeaderExpansionID fun(self: RematchTargetInfo, headerID: string): integer?
---@field GetExpansionName fun(self: RematchTargetInfo, npcID: integer | string): string?
---@field GetQuestName fun(self: RematchTargetInfo, npcID: integer | string): string?
---@field GetExpansionID fun(self: RematchTargetInfo, npcID: integer | string): integer?
---@field GetLocations fun(self: RematchTargetInfo, npcID: integer | string): string

---@class RematchTeam
---@field teamID string unique identifier of the team (required and persistent)
---@field name string unique name of the team (required, case insensitive)
---@field pets { [1]: RematchPetID, [2]: RematchPetID, [3]: RematchPetID } list of petIDs (or speciesIDs/"leveling"/"random:0"/"ignored") (required)
---@field tags { [1]: string, [2]: string, [3]: string } list of petTags of petIDs (required)
---@field favorite boolean whether team is favorited
---@field groupID string group for team (defaults to group:none)
---@field homeID string groupID the team belongs to when it's not favorited (or potential future group)
---@field notes string notes for team
---@field targets number[] ordered list of targets
---@field preferences { minHP: integer, maxHP: integer, minXP: integer, maxXP: integer, allowMM: boolean, expectedDD: integer }
---@field winrecord { wins: integer, losses: integer, draws: integer, battles: integer }

---@class RematchFilter
---@field Search table
---@field Stats table
---@field Collected table
---@field Favorite table
---@field Types table
---@field Strong table
---@field Tough table
---@field Sources table
---@field Rarity table
---@field Breed table
---@field Level table
---@field Marker table
---@field Other table
---@field Similar table
---@field Script table
---@field Moveset table
---@field Expansion table
---@field Sort table

---@class RematchSettings
---@field LockPosition boolean Lock button in topleft
---@field CurrentLayout string initial layout is standalone
---@field StandaloneLayout string default layout for standalone window
---@field MaximizedLayout string the last non-minimized standalone layout used
---@field JournalLayout string default layout for journal window
---@field LastOpenLayout string the last non-minimized layout used
---@field LastOpenJournal boolean whether the journal was open when rematch last on screen
---@field PetSatchelIndex integer which set of toolbar buttons are shown from pet satchel
---@field UseTypeBar boolean whether the typebar in the petspanel is open
---@field TypeBarTab integer which typebar tab user is on
---@field Filters RematchFilter filters used in pet panel (setup in filters.lua)
---@field FavoriteFilters { [1]: string, [2]: RematchFilter }[] the filters saved from the Favorite Filters in the pet panel filter
---@field HiddenPets table<integer, boolean> indexed by speciesID, true if speciesIDs should hide in the pet list
---@field ScriptFilters { [1]: string, [2]: string }[] script filters saved from Script Filters in the pet panel filter
---@field PetMarkers table<integer, string> pet markers for pet panel filter
---@field PetMarkerNames table<integer, string> names for pet markers
---@field GroupOrder string[] ordered list of team groupIDs in the order to display
---@field ExpandedGroups table<string, boolean> expanded groupIDs in teams panel
---@field ExpandedTargets table<string, boolean> expanded headerIDs in targets panel
---@field SpecialSlots table<number, RematchPetID> for marking loadout slots as leveling, random or ignored
---@field LockNotesPosition boolean whether notes can be moved or resized
---@field NotesLeft boolean x position of notes relative to bottomleft of UIParent
---@field NotesBottom boolean y position of notes relative to bottomleft of UIParent
---@field NotesWidth boolean width of notes
---@field NotesHeight boolean height of notes
---@field PetNotes table<integer, string> indexed by speciesID, notes for pets
---@field LevelingQueue { petID: string, petTag: string, preferred: boolean, added: integer }[] ordered list of {petID,petTag} for leveling queue pets
---@field DefaultPreferences {} default leveling preferences that are always active
---@field PreferencesPaused boolean whether the preferences are paused for the leveling queue
---@field QueueActiveSort boolean whether leveling queue is actively sorted
---@field QueueSortOrder integer order queue is actively sorted
---@field QueueSortInTeamsFirst boolean whether pets in teams sorted to top of queue
---@field QueueSortFavoritesFirst boolean whether favorites sorted to top of queue
---@field QueueSortRaresFirst boolean whether rares sorted to top of queue
---@field QueueSortAlpha boolean whether queue sorted alphabetically
---@field LastToastedPetID boolean petID of leveling pet that was last toasted for being slotted
---@field ExportIncludePreferences boolean whether to include preferences when exporting teams
---@field ExportIncludeNotes boolean whether to include notes when exporting teams
---@field ImportConflictOverwrite boolean whether to overwrite existing teams when teams share the same name
---@field LastSelectedGroup string group last chosen in the import/save dialog
---@field MinimapButtonPosition integer position of minimap button in degrees
---@field BarChartCategory integer which barchart category to show for pet collection
---@field ConvertedTeams table<RematchPetID, string> indexed by Rematch 4 team key, the Rematch 5 teamID that the key was converted into
---@field BackupCount integer number of teams created since a backup was last offered
---@field WasShownOnLogout boolean true if the rematch window was on screen during logout
---@field InteractOnTarget integer On Target (dropdown)
---@field InteractOnSoftInteract integer On Soft Target (dropdown)
---@field InteractOnMouseover integer On Mouseover (dropdown)
---@field InteractAlways boolean Always Interact
---@field InteractPreferUninjured boolean Prefer Uninjured Teams
---@field InteractShowAfterLoad boolean Show Window After Loading
---@field InteractOnlyWhenInjured boolean Only When Any Pets Injured
---@field Anchor string
---@field PanelTabAnchor string
---@field LockWindow boolean Keep Window On Screen
---@field StayForBattle boolean Even For Pet Battles
---@field StayOnLogout boolean Even Across Sessions
---@field LockDrawer boolean Don't Minimize With ESC Key
---@field DontMinTabToggle boolean Don't Minimize With Panel Tabs
---@field PreferPetsTab boolean Show Pets Tab While Minimized
---@field LowerStrata boolean Lower Window Behind UI
---@field CustomScale boolean Use Custom Scale
---@field CustomScaleValue integer Use Custom Scale Value (in the grey button in options)
---@field ShowAfterBattle boolean Show Window After Battle
---@field ShowAfterPVEOnly boolean But Not After PVP Battle
---@field PreferMinimized boolean Prefer Minimized Window
---@field CompactPetList boolean Compact Pet List
---@field CompactTeamList boolean Compact Team List
---@field CompactTargetList boolean Compact Target List
---@field CompactQueueList boolean Compact Queue List
---@field HideLevelBubbles boolean Hide Level At Max Level
---@field HideRarityBorders boolean Hide Rarity Borders
---@field ColorPetNames boolean Color Pet Names By Rarity
---@field ColorTeamNames boolean Color Team Names By Group
---@field ColorTargetNames boolean Color Targets By Expansion
---@field DisplayUniqueTotal boolean Display Unique Pets Total
---@field ShowAbilityNumbers boolean Show Abiltiy Numbers
---@field ShowAbilityNumbersLoaded boolean On Loaded Abilities Too
---@field CardBehavior string Card Speed (dropdown)
---@field TooltipBehavior string Tooltip Speed (dropdown)
---@field CollapseOnEsc boolean Collapse Lists With ESC Key
---@field AlwaysUsePetSatchel boolean Always Use Pet Satchel
---@field ReverseToolbar boolean Reverse Toolbar Buttons
---@field ToolbarDismiss boolean Hide Toolbar On Right Click
---@field SafariHatShine boolean Safari Hat Reminder
---@field UseDefaultJournal boolean Use Default Journal
---@field KeepCompanion boolean Keep Companion
---@field UseMinimapButton boolean Use Minimap Button
---@field NoSummonOnDblClick boolean No Summon On Double Click
---@field DisableShare boolean Disable Sharing
---@field StrongVsLevel boolean Use Level In Strong Vs Filter
---@field ResetFilters boolean Reset Filters On Login
---@field ResetSortWithFilters boolean Reset Sort With Filters
---@field ResetExceptSearch boolean Don't Reset Search With Filters
---@field SortByNickname boolean Sort By Chosen Name
---@field StickyNewPets boolean Sort New Pets To Top
---@field HideNonBattlePets boolean Hide Non-Battle Pets
---@field AllowHiddenPets boolean Allow Hidden Pets
---@field DontSortByRelevance boolean Don't Sort By Relevance
---@field ExportSimplePetList boolean Export Simple Pet List
---@field BreedSource boolean Breed Source (dropdown)
---@field BreedFormat integer Breed Format (dropdown)
---@field HideBreedsLists boolean Hide Breed In Lists
---@field HideBreedsLoadouts boolean Hide Breed In Pet Slots
---@field PetCardFlipKey string Flip Modifier Key
---@field PetCardCanPin boolean Allow Pet Cards To Be Pinned
---@field PetCardNoMouseoverFlip boolean Don't Flip On Mouseover
---@field PetCardBackground string Card Background
---@field PetCardShowExpansionStat boolean Show Expansion On Front
---@field ShowSpeciesID boolean Show Species ID
---@field PetCardCompactCollected boolean Always Use Collected Stat
---@field PetCardHidePossibleBreeds boolean Always Hide Possible Breeds
---@field PetCardAlwaysShowHPXPText boolean Always Show HP/XP Bar Text
---@field PetCardAlwaysShowHPBar boolean Always Show Health Bar
---@field BoringLoreFont boolean Alternate Lore Font
---@field PetCardInBattle boolean Use Pet Cards In Battle
---@field PetCardForLinks boolean Use Pet Cards For Links
---@field LoadHealthiest boolean Load Healthiest Pets
---@field LoadHealthiestAny boolean Ally Any Version
---@field LoadHealthiestAfterBattle boolean After Pet Battles Too
---@field ShowNewGroupTab boolean Show Create New Group Tab
---@field AlwaysTeamTabs boolean Always Show Team Tabs
---@field NeverTeamTabs boolean Never Show Team Tabs
---@field EchoTeamDrag boolean Display Where Teams Dragged
---@field EnableDrag boolean Enable Drag To Move Teams
---@field ClickToDrag boolean Require Click To Drag
---@field ImportRememberOverride boolean Remember Override Import Option
---@field PrioritizeBreedOnImport boolean Prioritize Breed On Import
---@field RandomPetRules integer Random Pet Rules
---@field PickAggressiveCounters boolean Pick Aggressive Counters
---@field RandomAbilitiesToo boolean Random Abilities Too
---@field WarnWhenRandomNot25 boolean Warn For Pets Below Max Level
---@field KeepNotesOnScreen boolean Keep Notes On Screen
---@field NotesNoEsc boolean Even When Escape Pressed
---@field ShowNotesOnLoad boolean Show Notes When Teams Load
---@field ShowNotesInBattle boolean Show Notes In Battle
---@field ShowNotesOnce boolean Only Once Per Team
---@field NotesFont string Notes Size
---@field HideNotesButtonInBattle boolean Hide Notes Button In Battle
---@field HideWinRecord boolean Hide Win Record Text
---@field AutoWinRecord boolean Auto Track Win Record
---@field AutoWinRecordPVPOnly boolean For PVP Battles Only
---@field AlternateWinRecord boolean Display Total Wins Instead
---@field AbilityBackground string Ability Background
---@field ShowAbilityID boolean Show Ability IDs
---@field DontConfirmHidePets boolean Don't Ask When Hiding Pets
---@field DontConfirmCaging boolean Don't Ask When Caging Pets
---@field DontConfirmDeleteTeams boolean Don't Ask When Deleting Teams
---@field DontConfirmDeleteNotes boolean Don't Ask When Deleting Notes
---@field DontConfirmFillQueue boolean Don't Ask When Filling Queue
---@field DontConfirmActiveSort boolean Don't Ask To Stop Active Sort
---@field DontConfirmRemoveQueue boolean Don't Ask For Queue Removal
---@field DontWarnMissing boolean Don't Warn About Missing Pets
---@field NoBackupReminder boolean Don't Remind About Backups
---@field HideMenuHelp boolean Hide Extra Help
---@field HideTooltips boolean Hide Descriptive Tooltips
---@field HideToolbarTooltips boolean Hide Toolbar Tooltips
---@field HideOptionTooltips boolean Hide Option Tooltips
---@field HideTruncatedTooltips boolean Hide Truncated Tooltips
---@field ShowLoadedTeamPreferences boolean Show Extra Preferences Button
---@field QueueSortByNameToo boolean Sort Queue By Pet Name Too
---@field HidePetToast boolean Hide Leveling Pet Toast
---@field ShowFillQueueMore boolean Show Fill Queue More Option
---@field QueueSkipDead boolean Prefer Living Pets
---@field QueuePreferFullHP boolean And At Full Health
---@field QueueDoubleClick boolean Double Click To Send To Top
---@field QueueAutoLearn boolean Automatically Level New Pets
---@field QueueAutoLearnOnly boolean Only Pets Without One At 25
---@field QueueAutoLearnRare boolean Only Rare Pets
---@field QueueRandomWhenEmpty boolean Random Pet When Queue Empty
---@field QueueRandomMaxLevel boolean Pick Random Max Level
---@field QueueAutoImport boolean Add Imported Pets To Queue
---@field currentTeamID string?

---@class RematchPetInfo
---@field Create fun(): RematchPetInfo
---@field Fetch fun(self: RematchPetInfo, petID: RematchPetID, fromJournal: boolean?): self
---@field Reset fun(self: RematchPetInfo)
---@field petID RematchPetID this is the pet reference Fetched
---@field idType 'pet' | 'species' | 'leveling' | 'ignored' | 'link' | 'battle' | 'random' | 'unknown'
---@field speciesID integer numeric speciesID of the pet
---@field customName string user-renamed pet name
---@field speciesName string name of the species
---@field name string customName if defined, speciesName otherwise
---@field level integer whole level 1-25
---@field xp integer amount of xp in current level
---@field maxXp integer total xp to reach next level
---@field fullLevel number level+xp/maxXp
---@field displayID integer id of the pet's skin
---@field isFavorite boolean whether pet is favorited
---@field icon integer | string fileID of pet's icon or specific filename
---@field petType integer numeric type of pet 1-10
---@field creatureID integer npcID of summoned pet
---@field sourceText string formatted text about where pet is from
---@field loreText string "back of the card" lore
---@field isWild boolean whether the pet is found in the wild
---@field canBattle boolean whether pet can battle
---@field isTradable boolean whether pet can be caged
---@field isUnique boolean whether only one of pet can be learned
---@field isObtainable boolean whether this pet is in the journal
---@field health integer current health of the pet
---@field maxHealth integer maximum health of the pet
---@field power integer power stat of the pet
---@field speed integer speed stat of the pet
---@field rarity integer rarity 1-4 of pet
---@field isDead boolean whether the pet is dead
---@field isInjured boolean whether the pet has less than max health
---@field isSummonable boolean whether the pet can be summoned
---@field summonError string the error ID why a pet can't be summoned
---@field summonErrorText string the error text why a pet can't be summoned
---@field summonShortError string shortened text of why a pet can't be summoned (for pet card stat)
---@field isRevoked boolean whether the pet is revoked
---@field abilityList number[] table of pet's abilities
---@field levelList number[] table of pet's ability levels
---@field valid boolean whether the petID is valid and petID is not missing
---@field owned boolean whether the petID is a valid pet owned by the player
---@field count integer number of pet the player owns
---@field maxCount integer maximum number of this pet the player can own
---@field countColor string hex color code for pet count (white for 0, green for count<max, red for count=max)
---@field hasBreed boolean whether pet can battle and there's a breed source
---@field breedID integer 3-12 for known breeds, 0 for unknown breed, nil for n/a
---@field breedName string text version of breed like P/P or S/B
---@field possibleBreedIDs number[] list of breedIDs possible for the pet's species
---@field possibleBreedNames string[] list of breedNames possible for the pet's species
---@field numPossibleBreeds integer number of known breeds for the pet
---@field needsFanfare boolean whether a pet is wrapped
---@field battleOwner integer whether ally(1) or enemy(2) pet in battle
---@field battleIndex integer 1-3 index of pet in battle
---@field isSlotted boolean whether pet is slotted
---@field inTeams boolean whether pet is in any teams (pet and species idTypes only)
---@field numTeams integer number of teams the pet belongs to (pet and species only)
---@field sourceID integer the source index (1=Drop, 2=Quest, 3=Vendor, etc) of the pet
---@field moveset string the exact moveset of the pet ("123,456,etc")
---@field speciesAt25 boolean whether the pet has a version at level 25
---@field hasNotes boolean whether the pet has notes
---@field notes string the text of the pet's notes
---@field isLeveling boolean whether the pet is in the queue
---@field isSummoned boolean whether the pet is currently summoned
---@field expansionID integer the numeric index of the expansion the pet is from: 0=classic, 1=BC, 2=WotLK, etc.
---@field expansionName string the name of the expansion the pet is from
---@field isSpecialType boolean whether the petid is a leveling, random or ignored
---@field passive string the "racial" or passive text of the pet type
---@field shortHealthStatus integer | number | 'DEAD' the numeric health at max health, or percent if injured, or DEAD if dead
---@field longHealthStatus string a hp/maxHp (percent%) description of pet health
---@field npcID integer the npcID of the target for an unnotable petID
---@field tint 'red' | 'grey' | nil either "red" for revoked/wrong-faction pets, "grey" for otherwise unsummonable, nil for no tint
---@field strongVs table<number, number> a table of [ability]=petType of attacks that do increased damage
---@field toughVs integer the petType of attack that this pet takes reduced damage from
---@field vulnerableVs integer the petType of attack that this pet takes increased damage from
---@field formattedName string name of pet with color codes for its rarity
---@field isStickied boolean whether the pet is temporarily stickied to top of pet list (wrapped)
