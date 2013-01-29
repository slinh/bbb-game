/**
 * Copyright 2011 BBB Game, Inc. All Rights Reserved.
 */
class BBBWeapon extends UTWeapon;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();
	`log("BBBWeapon");
}
defaultproperties
{
}