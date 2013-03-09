class BBBPawn extends UDKPawn;

/* Position on Y-axis to lock camera to */
var(Camera) float CamOffsetDistance; 

//override to make player mesh visible by default
simulated event BecomeViewTarget( PlayerController PC )
{
	local int i;

	Super.BecomeViewTarget(PC);

	if(!Mesh.bAttached)
	{
		AttachComponent(Mesh);
	}

	// Set 3P Mesh
	Mesh.SetSkeletalMesh(Mesh.SkeletalMesh);
	Mesh.SetOwnerNoSee(false);

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

defaultproperties
{
	CamOffsetDistance=-284
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
		Scale=1.075
		// Nice lighting for hair
		bUseOnePassLightingOnTranslucency=TRUE
		bPerBoneMotionBlur=true
	End Object
	Mesh=WPawnSkeletalMeshComponent
	Components.Add(WPawnSkeletalMeshComponent)
}
