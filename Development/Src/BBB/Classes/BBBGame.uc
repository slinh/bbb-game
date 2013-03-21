class BBBGame extends UDKGame;

// Variable which references the default pawn archetype stored within a package
var transient BBBPawn DefaultPawnArchetype;
// Variable which references the default weapon archetype stored within a package
var transient BBBWeapon DefaultWeaponArchetype;


function Pawn SpawnDefaultPawnFor(Controller NewPlayer, NavigationPoint StartSpot)
{
	local class<Pawn> DefaultPlayerClass;
	local Rotator StartRotation;
	local Pawn ResultPawn;

	DefaultPlayerClass = GetDefaultPlayerClass(NewPlayer);

	// don't allow pawn to be spawned with any pitch or roll
	StartRotation.Yaw = StartSpot.Rotation.Yaw;

	ResultPawn = Spawn(DefaultPlayerClass,,,StartSpot.Location,StartRotation,DefaultPawnArchetype);
	if ( ResultPawn == None )
	{
		`log("Couldn't spawn player of type "$DefaultPlayerClass$" at "$StartSpot);
	}
	return ResultPawn;
}

/**
 * Adds the default inventory to the pawn
 *
 * @param		P	Pawn to give default inventory to
 * @network			Server
 */
event AddDefaultInventory(Pawn P)
{
	local BBBInventoryManager BBBInvManager;

	Super.AddDefaultInventory(P);

	// Ensure that we have a valid default weapon archetype
	if (DefaultWeaponArchetype != None)
	{
		// Get the inventory manager
		BBBInvManager = BBBInventoryManager(P.InvManager);
		if (BBBInvManager != None)
		{
			// Create the inventory from the archetype
			BBBInvManager.CreateInventoryArchetype(DefaultWeaponArchetype, false);
		}
	}
}

defaultproperties
{
	DefaultPawnArchetype=BBBGrolard'Gameplay.Characters.Grolard'
	DefaultPawnClass=class'BBB.BBBGrolard'
	DefaultWeaponArchetype=BBBWeaponMeleeBase'Melee.Melee'
	PlayerControllerClass=class'BBB.BBBPlayerController'	
	HUDType=class'BBB.BBBHUD'
}
