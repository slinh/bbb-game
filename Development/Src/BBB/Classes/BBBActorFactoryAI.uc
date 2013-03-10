class BBBActorFactoryAI extends ActorFactoryAI;

/** 
  * Initialize factory created bot 
  */
simulated event PostCreateActor(Actor NewActor, optional SeqAct_ActorFactory ActorFactoryData)
{
	local BBBAIController Bot;
	local Pawn NewPawn;
	local int idx;

	NewPawn = Pawn(NewActor);
	
	if ( NewPawn != None )
	{
		// give the pawn a controller here, since we don't define a ControllerClass
		Bot = NewPawn.Spawn(class'BBBAIController',,, NewPawn.Location, NewPawn.Rotation);
		if ( Bot != None )
		{
			// handle the team assignment
			Bot.SetTeam(TeamIndex);
			// force the cont           roller to possess, etc
			Bot.Possess(NewPawn, false);
	
			if (Bot.PlayerReplicationInfo != None && PawnName != "" )
				Bot.PlayerReplicationInfo.SetPlayerName(PawnName);
		}

		// create any inventory
		if (bGiveDefaultInventory && NewPawn.WorldInfo.Game != None)
		{
			NewPawn.WorldInfo.Game.AddDefaultInventory(NewPawn);
		}
		for ( idx=0; idx<InventoryList.Length; idx++ )
		{
			NewPawn.CreateInventory( InventoryList[idx], false  );
		}
	}
}

defaultproperties
{
	ControllerClass=None
}
