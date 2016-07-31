//---------------------------------------------------------------------------------------
//  FILE:    XComGameState_Effect_EisenefaustEffectCounter.uc
//  AUTHOR:  John Lumpkin / Amineri (Long War Studios)
//  PURPOSE: This is a component extension for Effect GameStates, counting the number of
//		times an effect is triggered. Can be used to restrict passive abilities to once 
//		per turn.
//  MODIFIED by: Eisenefaust
//  MODIFICATION PURPOSE: Track totals for comparing uses >= max for determining end conditions
//---------------------------------------------------------------------------------------

class XComGameState_Effect_EisenefaustEffectCounter extends XComGameState_BaseObject;

var int uses;
var int total;

function XComGameState_Effect_EisenefaustEffectCounter InitComponent()
{
	uses = 0;
	total = 0;
	return self;
}

function XComGameState_Effect GetOwningEffect()
{
	return XComGameState_Effect(`XCOMHISTORY.GetGameStateForObjectID(OwningObjectId));
}

simulated function EventListenerReturn ResetUses(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    local XComGameState								NewGameState;
	local XComGameState_Effect_EisenefaustEffectCounter		ThisEffect;
	
	if(uses != 0)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Update: Reset Effect Counter");
		ThisEffect=XComGameState_Effect_EisenefaustEffectCounter(NewGameState.CreateStateObject(Class,ObjectID));
		ThisEffect.uses = 0;
		NewGameState.AddStateObject(ThisEffect);
		`TACTICALRULES.SubmitGameState(NewGameState);    
	}
	return ELR_NoInterrupt;
}

simulated function EventListenerReturn IncrementUses(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
    local XComGameState								NewGameState;
	local XComGameState_Effect_EisenefaustEffectCounter		ThisEffect;
	
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Update: Increment Effect Counter");
	ThisEffect=XComGameState_Effect_EisenefaustEffectCounter(NewGameState.CreateStateObject(Class,ObjectID));
	ThisEffect.uses += 1;
	NewGameState.AddStateObject(ThisEffect);
	`TACTICALRULES.SubmitGameState(NewGameState);    	
	return ELR_NoInterrupt;
}


