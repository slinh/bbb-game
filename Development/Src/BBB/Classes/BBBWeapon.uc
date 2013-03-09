/**
 * Copyright 2011 BBB Game, Inc. All Rights Reserved.
 */
class BBBWeapon extends UDKWeapon;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();
	`log("BBBWeapon");
}
defaultproperties
{
}