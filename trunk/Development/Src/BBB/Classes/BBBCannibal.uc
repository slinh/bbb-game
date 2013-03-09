class BBBCannibal extends UDKPawn
    placeable;

var(Sound) const SoundCue DyingSound;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();
    AddDefaultInventory(); 
}

simulated State Dying
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		LifeSpan = 2.f;
	}
}

function PlayDyingSound()
{
	PlaySound(DyingSound);
}

DefaultProperties
{
    ControllerClass=class'BBB.BBBAIController'

    Begin Object Name=CollisionCylinder
        CollisionHeight=+44.000000
    End Object
 
    Begin Object Class=SkeletalMeshComponent Name=CannibalSkeletalMesh
        SkeletalMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
        AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
        AnimTreeTemplate=AnimTree'AT_CH_Human'
        HiddenGame=FALSE
        HiddenEditor=FALSE
    End Object
    Mesh=CannibalSkeletalMesh 
    Components.Add(CannibalSkeletalMesh)
 
    bJumpCapable=false
    bCanJump=false
 
    GroundSpeed=100.0 //Making the bot slower than the player

	//placeholder
	DyingSound=SoundCue'A_Character_CorruptEnigma_Cue.Mean_Efforts.A_Effort_EnigmaMean_Death_Cue'
}