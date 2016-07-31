//--------------------------------------------------------------------------------------- 
//  FILE:    X2Effect_EisenefaustActionPoints
//  AUTHOR:  Eisenefaust
//  PURPOSE: Sets up rank-based Action Point modifier perk effect
//--------------------------------------------------------------------------------------- 

class X2Effect_EisenefaustTurnStartActionPoints extends X2Effect_TurnStartActionPoints config (EisenefaustTUPack);

struct EisenefaustTurnStartActionPointsInfo
{
	var name SoldierClass;
	var bool bOneAdditionalRunAndGun;
	var array<int> POINTS_AT_RANK;
};

var config array<EisenefaustTurnStartActionPointsInfo> TurnStartAPInfo;

function ModifyTurnStartActionPoints(XComGameState_Unit UnitState, out array<name> ActionPoints, XComGameState_Effect EffectState)
{
    local int i;
	local int iPoints;
	local EisenefaustTurnStartActionPointsInfo APInfo;

	foreach default.TurnStartAPInfo(APInfo)
	{
		if (APInfo.SoldierClass == UnitState.GetSoldierClassTemplateName())
		{
			ActionPoints.Length = 0; // reset AP 
			if(APInfo.POINTS_AT_RANK.Length > 0)
			{
				if( UnitState.GetRank() < APInfo.POINTS_AT_RANK.Length)
				{
					iPoints = APInfo.POINTS_AT_RANK[UnitState.GetRank()];
			
				}
				else // Use last value in array
				{
					iPoints = APInfo.POINTS_AT_RANK[APInfo.POINTS_AT_RANK.Length - 1];
				}
				
				for(i = 0; i < iPoints; i++) 
				{
					ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
				}
			}
			else
			{
				// If there is something wrong with the config, add at least 1 standard action point
				ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
			}

			if(APInfo.bOneAdditionalRunAndGun)
			{
				// allows one action to be used for a non-move action
				ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.RunAndGunActionPoint);
			}
		}
	}
}

defaultproperties
{
	DuplicateResponse=eDupe_Ignore
	EffectName="Effect_EisenefaustTurnStartActionPoints"
}

