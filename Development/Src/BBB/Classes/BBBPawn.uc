class BBBPawn extends UDKPawn;

/** Position on Y-axis to lock camera to */
var(Camera) float CamOffsetDistance; 

/** Dynamic light environment component to help speed up lighting calculations for the pawn */
var(Pawn) const DynamicLightEnvironmentComponent LightEnvironment;

/** How fast a pawn turns */
var(Pawn) const float TurnRate;

/** How high the pawn jumps */
var(Pawn) const float JumpHeight;

/** Socket to use for attaching weapons */
var(Pawn) const Name WeaponSocketName;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
		
	JumpZ = JumpHeight;
}

//override to make player mesh visible by default
simulated event BecomeViewTarget( PlayerController PC )
{
	Super.BecomeViewTarget(PC);

	SetMeshVisibility(true);
	SetWeaponMeshVisibility(true);
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

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	if (SkelComp == Mesh)
	{
		LeftLegControl = SkelControlFootPlacement(Mesh.FindSkelControl(LeftFootControlName));
		RightLegControl = SkelControlFootPlacement(Mesh.FindSkelControl(RightFootControlName));
		//FeignDeathBlend = AnimNodeBlend(Mesh.FindAnimNode('FeignDeathBlend'));
		//FullBodyAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('FullBodySlot'));
		//TopHalfAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('TopHalfSlot'));

		LeftHandIK = SkelControlLimb( mesh.FindSkelControl('LeftHandIK') );

		RightHandIK = SkelControlLimb( mesh.FindSkelControl('RightHandIK') );

		RootRotControl = SkelControlSingleBone( mesh.FindSkelControl('RootRot') );
		AimNode = AnimNodeAimOffset( mesh.FindAnimNode('AimNode') );
		GunRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('GunRecoilNode') );
		LeftRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('LeftRecoilNode') );
		RightRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('RightRecoilNode') );

		//DrivingNode = UTAnimBlendByDriving( mesh.FindAnimNode('DrivingNode') );
		//VehicleNode = UTAnimBlendByVehicle( mesh.FindAnimNode('VehicleNode') );
		//HoverboardingNode = UTAnimBlendByHoverboarding( mesh.FindAnimNode('Hoverboarding') );

		FlyingDirOffset = AnimNodeAimOffset( mesh.FindAnimNode('FlyingDirOffset') );
	}
}

simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	out_CamLoc = Location;
	out_CamLoc.Y += CamOffsetDistance;
	out_CamLoc.Z += 128;
 
	out_CamRot.Pitch = 0;
	out_CamRot.Yaw = 16384;
	out_CamRot.Roll = 0;
	
	return true;
}
 
simulated singular event Rotator GetBaseAimRotation()
{
   local rotator   POVRot;
 
   POVRot = Rotation;
   if( (Rotation.Yaw % 65535 > 16384 && Rotation.Yaw % 65535 < 49560) ||
      (Rotation.Yaw % 65535 < -16384 && Rotation.Yaw % 65535 > -49560) )
   {
      POVRot.Yaw = 32768;
   }
   else
   {
      POVRot.Yaw = 0;
   }
 
   if( POVRot.Pitch == 0 )
   {
      POVRot.Pitch = RemoteViewPitch << 8;
   }
 
   return POVRot;
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

defaultproperties
{
	CamOffsetDistance=-284
	InventoryManagerClass=class'BBB.BBBinventoryManager'

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0034.000000
		CollisionHeight=+0034.000000
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=false
		CollideActors=true
	End Object

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
}
