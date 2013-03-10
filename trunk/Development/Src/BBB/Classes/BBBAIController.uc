class  BBBAIController extends AIController;

var Actor Target;
var() Vector TempDest;
 
event Possess(Pawn inPawn, bool bVehicleTransition)
{
	local BBBPawn BBBPawn;
    super.Possess(inPawn, bVehicleTransition); 
    Pawn.SetMovementPhysics();

	BBBPawn=BBBPawn(inPawn);
	if(BBBPawn != none)
	{
		BBBPawn.SetMeshVisibility(true);
		BBBPawn.SetWeaponMeshVisibility(true);
	}
} 

//I'm adding an default idle state so the Pawn doesn't try to follow a player that doesn' exist yet.
auto state Idle
{
    event SeePlayer (Pawn Seen)
    {
        super.SeePlayer(Seen);
        Target = Seen;
 
        GotoState('Follow');
    }
Begin:
}
 
state Follow
{
    ignores SeePlayer;
    function bool FindNavMeshPath()
    {
        // Clear cache and constraints (ignore recycling for the moment)
        NavigationHandle.PathConstraintList = none;
        NavigationHandle.PathGoalList = none;
 
        // Create constraints
        class'NavMeshPath_Toward'.static.TowardGoal(NavigationHandle,Target);
        class'NavMeshGoal_At'.static.AtActor(NavigationHandle, Target,32);
 
        // Find path
        return NavigationHandle.FindPath();
    }
Begin:
 
    if(NavigationHandle.ActorReachable(Target))
    {
        FlushPersistentDebugLines();
 
        //Direct move
        MoveToward(Target,Target);
    }
    else if(FindNavMeshPath())
    {
        NavigationHandle.SetFinalDestination(Target.Location);
        FlushPersistentDebugLines();
        NavigationHandle.DrawPathCache(,TRUE);
 
        // move to the first node on the path
        if(NavigationHandle.GetNextMoveLocation(TempDest, Pawn.GetCollisionRadius()))
        {
			if(bDebug)
			{
				DrawDebugLine(Pawn.Location,TempDest,255,0,0,true);
				DrawDebugSphere(TempDest,16,20,255,0,0,true);
			}

            MoveTo(TempDest, Target);
        }
    }
    else
    {
        //We can't follow, so get the hell out of this state, otherwise we'll enter an infinite loop.
        GotoState('Idle');
    }
 
	if (VSize(Pawn.Location - target.Location) <= 256)
	{
		GotoState('Shoot'); //Start shooting when close enough to the player.
	}
	else
	{
		goto 'Begin';
	}
}
 
state Shoot
{
    function Aim()
    {
        local Rotator final_rot;
        final_rot = Rotator(vect(0,0,1)); //Look straight up
        Pawn.SetViewRotation(final_rot);
    }

Begin:
    Pawn.ZeroMovementVariables();
    Sleep(1); //Give the pawn the time to stop.
 
    Aim();
    Pawn.StartFire(1);
    Pawn.StopFire(1);
 
    GotoState('Idle');
}

DefaultProperties
{
	bDebug=true
}