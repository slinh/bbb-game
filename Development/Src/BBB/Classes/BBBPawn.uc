class BBBPawn extends UTPawn;

var float CamOffsetDistance; //Position on Y-axis to lock camera to

//override to make player mesh visible by default
simulated event BecomeViewTarget( PlayerController PC )
{
	local UTPlayerController UTPC;

	Super.BecomeViewTarget(PC);

	if (LocalPlayer(PC.Player) != None)
	{
		UTPC = UTPlayerController(PC);
		if (UTPC != None)
		{
			//set player controller to behind view and make mesh visible
			UTPC.SetBehindView(true);
			SetMeshVisibility(UTPC.bBehindView);
			UTPC.bNoCrosshair = true;
		}
	}
}

simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	local float tempYaw;

	out_CamLoc = Location;
	out_CamLoc.Y += CamOffsetDistance;
	out_CamLoc.Z += 128;
   
	out_CamLoc.X += 0; //decalage de la camera lorsque le player regarde a Gauche/Droite
   
	// if( (Rotation.Yaw % 65535 > 16384 && Rotation.Yaw % 65535 < 49560) ||
	//   (Rotation.Yaw % 65535 < -16384 && Rotation.Yaw % 65535 > -49560) )
	//{
	//    out_CamLoc.X +=-96;
	//}
	//else
	//{
	//    out_CamLoc.X += 96;
	//}


	out_CamRot.Pitch = -3000;
	out_CamRot.Roll = 0;

	//out_CamRot.Yaw = 16384; decalage en rotation de la camera lorsque le player regarde a Gauche/Droite

	if( (Rotation.Yaw % 65535 > 16384 && Rotation.Yaw % 65535 < 49560) ||
		(Rotation.Yaw % 65535 < -16384 && Rotation.Yaw % 65535 > -49560) )
	{
		tempYaw = FInterpEaseIn(14336.f, 18432.f, fDeltaTime, 0.001f);
		`log("tempYaw1"@tempYaw);
		out_CamRot.Yaw = tempYaw/*18432*/;
	}
	else
	{
		tempYaw = FInterpEaseIn(18432.f, 14336.f, fDeltaTime, 0.001f);
		`log("tempYaw2"@tempYaw);
		out_CamRot.Yaw = tempYaw/*14336.f*/;
	}

	return true;
}


//rotation du gun du joueur
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
	CamOffsetDistance=-384
}
