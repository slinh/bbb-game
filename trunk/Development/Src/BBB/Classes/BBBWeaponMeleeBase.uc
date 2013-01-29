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
	// Weapon SkeletalMesh 3rdPersonMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=none
	End Object


	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	bCauseActorAnimEnd=true
	End Object

	// Weapon SkeletalMesh 1stPersonMesh
	Begin Object Name=FirstPersonMesh
	SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_Linkgun_1P'
	AnimSets(0)=AnimSet'WP_LinkGun.Anims.K_WP_LinkGun_1P_Base'
	Animations=MeshSequenceA
	End Object

	InstantHitDamage(0)=100.0
	InstantHitDamage(1)=100.0

	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_InstantHit
	FiringStatesArray(0)=WeaponFiring
	FiringStatesArray(1)=WeaponFiring

	DefaultAnimSpeed=0.9

	PivotTranslation=(Y=-10.0)

	ShotCost(0)=0
	ShotCost(1)=0

	MessageClass=class'UTPickupMessage'
	DroppedPickupClass=class'UTDroppedPickup'

	MaxAmmoCount=1
	AmmoCount=1

	bMeleeWeapon=true
	WeaponRange=20
    
	WeaponColor=(R=255,G=255,B=0,A=255)
	FireInterval(0)=+0.24
	FireInterval(1)=+0.35
	PlayerViewOffset=(X=0.0,Y=0,Z=0.0)       
}