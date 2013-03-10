class BBBGrolard extends BBBPawn;

/** Position on Y-axis to lock camera to */
var(Camera) float CamOffsetDistance; 

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
}

//override to make player mesh visible by default
simulated event BecomeViewTarget( PlayerController PC )
{
	Super.BecomeViewTarget(PC);

	SetMeshVisibility(true);
	SetWeaponMeshVisibility(true);
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
}
