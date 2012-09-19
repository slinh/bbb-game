class  BBBAIController extends AIController;

var  Actor target;
var() Vector TempDest;


event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);
	Pawn.SetMovementPhysics();
}



auto state Follow
{
Begin:
    //Target = GetALocalPlayerController().Pawn;
    ////Target is an Actor variable defined in my custom AI Controller.
 
    //MoveToward(Target, Target, 10);
 
    //goto 'Begin';
}




 

DefaultProperties
{
}