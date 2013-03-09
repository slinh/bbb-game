/**
 * Copyright 2011 BBB Game, Inc. All Rights Reserved.
 */
class BBBWeaponMeleeBase extends BBBWeapon;
simulated event PostBeginPlay()
{
    super.PostBeginPlay();
	`log("BBBWeap_MeleeBase");
}
defaultproperties
{
	InstantHitDamage(0)=100.0
	InstantHitDamage(1)=100.0

	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_InstantHit

	bMeleeWeapon=true
	WeaponRange=20
}