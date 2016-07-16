//--------------------------------------------------------------------------------------- 
//  FILE:    X2Effect_EisenfaustActionPoints
//  AUTHOR:  Eisenefaust
//  PURPOSE: Sets up rank-based Action Point modifier perk effect
//--------------------------------------------------------------------------------------- 

class X2Effect_EisenfaustTurnStartActionPoints extends X2Effect_TurnStartActionPoints config (EisenefaustTUPack);

var config array<config int> POINTS_AT_RANK;
var config bool bOneAdditionalRunAndGun;

function ModifyTurnStartActionPoints(XComGameState_Unit UnitState, out array<name> ActionPoints, XComGameState_Effect EffectState)
{
    local int i;
	local int iPoints;

    ActionPoints.Length = 0; // reset AP 

	if(default.POINTS_AT_RANK.Length > 0)
	{
		if( UnitState.GetRank() < default.POINTS_AT_RANK.Length)
		{
			iPoints = default.POINTS_AT_RANK[UnitState.GetRank()];
			
		}
		else // Use last value in array
		{
			iPoints = default.POINTS_AT_RANK[default.POINTS_AT_RANK.Length - 1];
		}
	}
	else
	{
		// If there is something wrong with the config, add at least 1 standard action point
		ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
	}

	for(i = 0; i < iPoints; i++) 
	{
		ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
	}

	if(default.bOneAdditionalRunAndGun)
	{
		//allow the last action to be used for a non-move action
		ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.RunAndGunActionPoint);
	}
}

defaultproperties
{
	DuplicateResponse=eDupe_Ignore
	EffectName="Effect_EisenfaustActionPoints"
}