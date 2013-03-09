class BBBCannibal extends UDKPawn
    placeable;
 
 
simulated event PostBeginPlay()
{
    super.PostBeginPlay();
    AddDefaultInventory(); 
}
 
DefaultProperties
{
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
    ControllerClass=class'BBB.BBBAIController'
 
    bJumpCapable=false
    bCanJump=false
 
    GroundSpeed=100.0 //Making the bot slower than the player
}