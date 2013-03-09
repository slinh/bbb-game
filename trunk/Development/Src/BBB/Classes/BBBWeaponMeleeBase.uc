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
	FiringStatesArray(0)=WeaponFiring
	FiringStatesArray(1)=WeaponFiring

	DefaultAnimSpeed=0.9

	AmmoCount=1

	bMeleeWeapon=true
	WeaponRange=20  
}