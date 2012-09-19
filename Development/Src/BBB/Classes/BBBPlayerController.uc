class BBBPlayerController extends UTPlayerController;

state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		local Rotator tempRot;

		if( Pawn == None )
		{
			return;
		}

		if (Role == ROLE_Authority)
		{
			// Update ViewPitch for remote clients
			Pawn.SetRemoteViewPitch( Rotation.Pitch );
		}

		Pawn.Acceleration.X = -1 * PlayerInput.aStrafe * DeltaTime * 100 * PlayerInput.MoveForwardSpeed;
		Pawn.Acceleration.Y = 1 * PlayerInput.aForward * DeltaTime * 100 * PlayerInput.MoveForwardSpeed;
		Pawn.Acceleration.Z = 0;

		tempRot.Pitch = Pawn.Rotation.Pitch;
		tempRot.Roll = 0;

		// orientation du player depend du deplacement Gauche/Droite
		//if(Normal(Pawn.Acceleration) Dot Vect(1,0,0) > 0)
		//{
		//   tempRot.Yaw = 0;
		//   Pawn.SetRotation(tempRot);
		//}
		// else if(Normal(Pawn.Acceleration) Dot Vect(1,0,0) < 0)
		//{
		//   tempRot.Yaw = 32768;   
		//   Pawn.SetRotation(tempRot);
		// }


		// viser gauche droite avec le stick droite
		if ((PlayerInput.aturn) == 00)
		{
			tempRot.Yaw = Pawn.Rotation.yaw;
			Pawn.SetRotation(tempRot);
		}

		else if ((PlayerInput.aturn) < -32)
		{
			tempRot.Yaw = 0;
			Pawn.SetRotation(tempRot);
		}

		else if((PlayerInput.aturn) > 32)
		{
			tempRot.Yaw = 32768;
			Pawn.SetRotation(tempRot);
		}

		CheckJumpOrDuck();
	}
}


function UpdateRotation( float DeltaTime )
{
	local Rotator   DeltaRot, ViewRotation;

	ViewRotation = Rotation;

	// Calculate Delta to be applied on ViewRotation
	DeltaRot.Yaw = Pawn.Rotation.Yaw;

	//bloque up down aim
	//DeltaRot.Pitch   = PlayerInput.aLookUp;

	// teste pour la visé haut et bas
	if((PlayerInput.aLookUp) == 0)
	{
		ViewRotation.Pitch = 0;
	}
      
	// Diagonal 45
	else if((PlayerInput.aLookUp) > 48 && (PlayerInput.aLookUp) < 108 )
	{
	ViewRotation.Pitch = 6144;
	}
	else if((PlayerInput.aLookUp) < -48 && (PlayerInput.aLookUp) > -108)
	{
		ViewRotation.Pitch = -6144;
	}


	// Haut et Bas
	else if((PlayerInput.aLookUp) > 112)
	{
		ViewRotation.Pitch = 16384;
	}
	else if((PlayerInput.aLookUp) < -112)
	{
		ViewRotation.Pitch = -16384;
	}

	ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
	SetRotation(ViewRotation);
}

defaultproperties
{
	CameraClass=class'BBB.BBBCamera'
}

