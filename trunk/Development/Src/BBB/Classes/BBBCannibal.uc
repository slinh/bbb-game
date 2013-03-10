class BBBCannibal extends BBBPawn
    placeable;


simulated event PostBeginPlay()
{
    super.PostBeginPlay();
    AddDefaultInventory();
}
DefaultProperties
{
    ControllerClass=class'BBB.BBBAIController'

    Begin Object Name=CollisionCylinder
        CollisionHeight=+44.000000
    End Object
 
    Begin Object Name=WPawnSkeletalMeshComponent
        SkeletalMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
        AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
        AnimTreeTemplate=AnimTree'AT_CH_Human'
        HiddenGame=FALSE
        HiddenEditor=FALSE
    End Object
 
    bJumpCapable=false
    bCanJump=false
 
	WeaponSocketName="WeaponPoint"

    GroundSpeed=100.0 //Making the bot slower than the player
}