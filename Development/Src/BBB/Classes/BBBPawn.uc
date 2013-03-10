class BBBPawn extends UDKPawn;

/** Dynamic light environment component to help speed up lighting calculations for the pawn */
var(Pawn) const DynamicLightEnvironmentComponent LightEnvironment;

/** How fast a pawn turns */
var(Pawn) const float TurnRate;

/** How high the pawn jumps */
var(Pawn) const float JumpHeight;

/** Socket to use for attaching weapons */
var(Pawn) const Name WeaponSocketName;

var(Sound) const SoundCue DyingSound;
var(Sound) const SoundCue HitSounds[3];

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
		
	JumpZ = JumpHeight;
}

simulated State Dying
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		LifeSpan = 2.f;
	}
}

simulated event SetMeshVisibility(bool bVisible)
{
	local int i;

	if (Mesh != None)
	{
		if (!Mesh.bAttached)
		{
			AttachComponent(Mesh);
		}

		SetHidden(!bVisible);

		// Set 3P Mesh
		Mesh.SetSkeletalMesh(Mesh.SkeletalMesh);
		Mesh.SetOwnerNoSee(!bVisible);

		// Make sure bEnableFullAnimWeightBodies is only TRUE if it needs to be (PhysicsAsset has flappy bits)
		Mesh.bEnableFullAnimWeightBodies = FALSE; 
		for(i=0; i<Mesh.PhysicsAsset.BodySetup.length && !Mesh.bEnableFullAnimWeightBodies; i++)
		{
			// See if a bone has bAlwaysFullAnimWeight set and also
			if( Mesh.PhysicsAsset.BodySetup[i].bAlwaysFullAnimWeight &&
				Mesh.MatchRefBone(Mesh.PhysicsAsset.BodySetup[i].BoneName) != INDEX_NONE)
			{
				Mesh.bEnableFullAnimWeightBodies = TRUE;
			}
		}
	}
}

simulated event SetWeaponMeshVisibility(bool bVisible)
{
	local BBBWeapon Weap;

	Weap=BBBWeapon(Weapon);
	if(Weap != none)
	{
		Weap.ChangeVisibility(true);
	}
}

/**
 * Adjusts weapon aiming direction.
 * Gives Pawn a chance to modify its aiming. For example aim error, auto aiming, adhesion, AI help...
 * Requested by weapon prior to firing.
 *
 * @param	W				Weapon about to fire
 * @param	StartFireLoc	World location of weapon fire start trace, or projectile spawn loc.
 * @return					Rotation to fire from
 * @network					Server and client
 */
simulated function Rotator GetAdjustedAimFor(Weapon W, vector StartFireLoc)
{
	local Vector SocketLocation;
	local Rotator SocketRotation;
	local BBBWeapon BBBWeapon;
	local SkeletalMeshComponent WeaponSkeletalMeshComponent;

	BBBWeapon = BBBWeapon(Weapon);
	if (BBBWeapon != None)
	{
		WeaponSkeletalMeshComponent = SkeletalMeshComponent(BBBWeapon.Mesh);
		if (WeaponSkeletalMeshComponent != None && WeaponSkeletalMeshComponent.GetSocketByName(BBBWeapon.MuzzleSocketName) != None)
		{			
			WeaponSkeletalMeshComponent.GetSocketWorldLocationAndRotation(BBBWeapon.MuzzleSocketName, SocketLocation, SocketRotation);
			return SocketRotation;
		}
	}

	return Rotation;
}

/**
 * Return world location to start a weapon fire trace from.
 *
 * @param	CurrentWeapon		Weapon about to fire
 * @return						World location where to start weapon fire traces from
 * @network						Server and client
 */
simulated event Vector GetWeaponStartTraceLocation(optional Weapon CurrentWeapon)
{
	local Vector SocketLocation;
	local Rotator SocketRotation;
	local BBBWeapon BBBWeapon;
	local SkeletalMeshComponent WeaponSkeletalMeshComponent;

	BBBWeapon = BBBWeapon(Weapon);
	if (BBBWeapon != None)
	{
		WeaponSkeletalMeshComponent = SkeletalMeshComponent(BBBWeapon.Mesh);
		if (WeaponSkeletalMeshComponent != None && WeaponSkeletalMeshComponent.GetSocketByName(BBBWeapon.MuzzleSocketName) != None)
		{
			WeaponSkeletalMeshComponent.GetSocketWorldLocationAndRotation(BBBWeapon.MuzzleSocketName, SocketLocation, SocketRotation);
			return SocketLocation;
		}
	}

	return Super.GetWeaponStartTraceLocation(CurrentWeapon);
}

function PlayDyingSound()
{
	PlaySound(DyingSound);
}

function PlayHit(float Damage, Controller InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, TraceHitInfo HitInfo)
{
	super.PlayHit(Damage, InstigatedBy, HitLocation, damageType, Momentum, HitInfo);
	PlaySound(HitSounds[0]);
}

defaultproperties
{
	InventoryManagerClass=class'BBB.BBBinventoryManager'

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bSynthesizeSHLight=TRUE
		bIsCharacterLightEnvironment=TRUE
		bUseBooleanEnvironmentShadowing=FALSE
		InvisibleUpdateTime=1
		MinTimeBetweenFullUpdates=.2
	End Object
	Components.Add(MyLightEnvironment)

	Begin Object Class=SkeletalMeshComponent Name=WPawnSkeletalMeshComponent
		bCacheAnimSequenceNodes=FALSE
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		bOwnerNoSee=true
		CastShadow=true
		BlockRigidBody=TRUE
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=TRUE
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true
		Translation=(Z=8.0)
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		LightEnvironment=MyLightEnvironment
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		MinDistFactorForKinematicUpdate=0.2
		bChartDistanceFactor=true
		//bSkipAllUpdateWhenPhysicsAsleep=TRUE
		RBDominanceGroup=20
		Scale=1.0
		// Nice lighting for hair
		bUseOnePassLightingOnTranslucency=TRUE
		bPerBoneMotionBlur=true
	End Object
	Mesh=WPawnSkeletalMeshComponent
	Components.Add(WPawnSkeletalMeshComponent)

	WeaponSocketName="WeaponSocket"

	//placeholder
	DyingSound=SoundCue'A_Character_CorruptEnigma_Cue.Mean_Efforts.A_Effort_EnigmaMean_Death_Cue'
	HitSounds[0]=SoundCue'A_Character_CorruptEnigma_Cue.Mean_Efforts.A_Effort_EnigmaMean_PainSmall_Cue'
	HitSounds[1]=SoundCue'A_Character_CorruptEnigma_Cue.Mean_Efforts.A_Effort_EnigmaMean_PainMedium_Cue'
	HitSounds[2]=SoundCue'A_Character_CorruptEnigma_Cue.Mean_Efforts.A_Effort_EnigmaMean_PainLarge_Cue'
}
