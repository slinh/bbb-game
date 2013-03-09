/**
 * Copyright 2011 BBB Game, Inc. All Rights Reserved.
 */
class BBBWeapon extends UDKWeapon;

/** Projectile classes that this weapon fires. DisplayName lets the editor show this as WeaponProjectiles */ 
var(Weapon) const array< class<Projectile> > Projectiles<DisplayName=Weapon Projectiles>;

/** Name of the socket which represents the muzzle socket */
var(Effects) const Name MuzzleSocketName;

/** Particle system representing the muzzle flash */
var(Effects) const ParticleSystemComponent MuzzleFlash;

/** Sounds to play back when the weapon is fired */
var(Sound) const array<SoundCue> WeaponFireSounds;

simulated event PostBeginPlay()
{
	local SkeletalMeshComponent SkeletalMeshComponent;

    super.PostBeginPlay();

	if (MuzzleFlash != None)
	{
		SkeletalMeshComponent = SkeletalMeshComponent(Mesh);
		if (SkeletalMeshComponent != None && SkeletalMeshComponent.GetSocketByName(MuzzleSocketName) != None)
		{
			SkeletalMeshComponent.AttachComponentToSocket(MuzzleFlash, MuzzleSocketName);
		}
	}
	`log("BBBWeapon");
}

simulated event ChangeVisibility(bool bVisible)
{
	local SkeletalMeshComponent SkelMesh;
	local PrimitiveComponent Primitive;

	if (Mesh != None)
	{
		if (!Mesh.bAttached)
		{
			AttachComponent(Mesh);
		}

		SetHidden(!bVisible);
		SkelMesh = SkeletalMeshComponent(Mesh);
		if (SkelMesh != None)
		{
			foreach SkelMesh.AttachedComponents(class'PrimitiveComponent', Primitive)
			{
				Primitive.SetHidden(!bVisible);
			}
		}
	}
}

/**
 * Called when the weapon has been given to a pawn
 *
 * @param	NewOwner		Pawn that this weapon has been given to
 * @param	bDoNoActivate	Flag to indicate that this weapon should not be activated
 * @network					Client
 */
reliable client function ClientGivenTo(Pawn NewOwner, bool bDoNotActivate)
{
	local BBBPawn BBBPawn;

	Super.ClientGivenTo(NewOwner, bDoNotActivate);

	// Check that we have a new owner and the new owner has a mesh
	if (NewOwner != None && NewOwner.Mesh != None)
	{
		// Cast the new owner into a SPG_PlayerPawn as we need the weapon socket name
		// If the cast succeeds, we check that the new owner's mesh has a socket by that name
		BBBPawn = BBBPawn(NewOwner);
		if (BBBPawn != None && NewOwner.Mesh.GetSocketByName(BBBPawn.WeaponSocketName) != None)
		{
			// Set the shadow parent of the weapon mesh to the new owner's skeletal mesh. This prevents doubling up
			// of shadows and also allows improves rendering performance
			Mesh.SetShadowParent(NewOwner.Mesh);
			// Set the light environment of the weapon mesh to the new owner's light environment. This improves
			// rendering performance
			Mesh.SetLightEnvironment(BBBPawn.LightEnvironment);
			// Attach the weapon mesh to the new owner's skeletal meshes socket
			NewOwner.Mesh.AttachComponentToSocket(Mesh, BBBPawn.WeaponSocketName);
		}
	}
}

/**
 * Plays all firing effects
 *
 * @param	FireModeNum		Fire mode
 * @param	HitLocation		Where in the world the trace hit
 * @network					Server and client
 */
simulated function PlayFireEffects(byte FireModeNum, optional vector HitLocation)
{
	if(bDebug)
	{
		DrawDebugSphere(HitLocation, 10, 8, 255, 0, 0, true);
	}

	if (MuzzleFlash != None)
	{
		// Activate the muzzle flash
		MuzzleFlash.ActivateSystem();
	}

	// Play back weapon fire sound if FireModeNum is within the array bounds and if the 
	// weapon fire sound in that array index is not none
	if (FireModeNum < WeaponFireSounds.Length && WeaponFireSounds[FireModeNum] != None && Instigator != None)
	{
		Instigator.PlaySound(WeaponFireSounds[FireModeNum]);
	}
}

/**
 * Stops all firing effects
 *
 * @param	FireModeNum		Fire mode
 * @network					Server and client
 */
simulated function StopFireEffects(byte FireModeNum)
{
	if (MuzzleFlash != None)
	{
		// Deactivate the muzzle flash
		MuzzleFlash.DeactivateSystem();
	}
}

defaultproperties
{
	FiringStatesArray(0)=WeaponFiring
	FiringStatesArray(1)=WeaponFiring

	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_InstantHit

	DefaultAnimSpeed=0.9

	AmmoCount=50

	WeaponProjectiles(0)=none
	WeaponProjectiles(1)=none

	FireInterval(0)=+1.0
	FireInterval(1)=+1.0

	Spread(0)=0.0
	Spread(1)=0.0

	InstantHitDamage(0)=0.0
	InstantHitDamage(1)=0.0
	InstantHitMomentum(0)=0.0
	InstantHitMomentum(1)=0.0
	InstantHitDamageTypes(0)=class'DamageType'
	InstantHitDamageTypes(1)=class'DamageType'
	WeaponRange=22000	
	
	EquipTime=+0.45
	PutDownTime=+0.33

	WeaponFireSounds(0)=none
	WeaponFireSounds(1)=none
}