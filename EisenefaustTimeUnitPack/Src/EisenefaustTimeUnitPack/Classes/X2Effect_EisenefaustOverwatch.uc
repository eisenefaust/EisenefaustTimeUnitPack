//--------------------------------------------------------------------------------------- 
//  FILE:    X2Effect_EisenefaustOverwatch
//  AUTHOR:  Eisenefaust
//  PURPOSE: Sets up overwatch to take extra shots based on WeaponType, ActionPoints, and Soldier Class
//--------------------------------------------------------------------------------------- 

Class X2Effect_EisenefaustOverwatch extends X2Effect_Persistent config (XComEisenefaustTUPack);

var int OVERWATCH_USES_PER_TURN;
var config array<name> OVERWATCH_ABILITY_NAMES;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Effect_EffectCounter	EisenefaustOverwatch_EffectState;
	local X2EventManager						EventMgr;
	local Object								ListenerObj, EffectObj;
	local XComGameState_Unit					UnitState;

	EventMgr = `XEVENTMGR;
	EffectObj = NewEffectState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(NewEffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	if (GetEisenefaustOverwatchCounter(NewEffectState) == none)
	{
		EisenefaustOverwatch_EffectState = XComGameState_Effect_EffectCounter(NewGameState.CreateStateObject(class'XComGameState_Effect_EffectCounter'));
		EisenefaustOverwatch_EffectState.InitComponent();
		NewEffectState.AddComponentObject(EisenefaustOverwatch_EffectState);
		NewGameState.AddStateObject(EisenefaustOverwatch_EffectState);
	}
	ListenerObj = EisenefaustOverwatch_EffectState;
	if (ListenerObj == none)
	{
		`Redscreen("EisenefaustOverwatch: Failed to find EisenefaustOverwatch Component when registering listener");
		return;
	}
    //EventMgr.RegisterForEvent(ListenerObj, 'PlayerTurnBegun', EisenefaustOverwatch_EffectState.ResetUses, ELD_OnStateSubmitted);
	EventMgr.RegisterForEvent(EffectObj, 'EisenefaustOverwatchTriggered', NewEffectState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local X2EventManager EventMgr;
	local XComGameState_Ability AbilityState;       //  used for looking up our source ability (EisenefaustOverwatch), not the incoming one that was activated
	local XComGameState_Effect_EffectCounter	CurrentOverwatchCounter, UpdatedOverwatchCounter;

	CurrentOverwatchCounter = GetEisenefaustOverwatchCounter(EffectState);
	If (CurrentOverwatchCounter != none)	 
	{
		if (CurrentOverwatchCounter.uses >= OVERWATCH_USES_PER_TURN)		
			return false;
	}
	if (XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID)) == none)
		return false;
	//if (!AbilityContext.IsResultContextHit())
	//	return false;
	if (SourceUnit.ReserveActionPoints.Length != PreCostReservePoints.Length && default.OVERWATCH_ABILITY_NAMES.Find(kAbility.GetMyTemplateName()) != -1)
	{
		AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
		if (AbilityState != none)
		{
			SourceUnit.ReserveActionPoints = PreCostReservePoints;
			UpdatedOverwatchCounter = XComGameState_Effect_EffectCounter(NewGameState.CreateStateObject(class'XComGameState_Effect_EffectCounter', CurrentOverwatchCounter.ObjectID));
			UpdatedOverwatchCounter.uses += 1;
			NewGameState.AddStateObject(UpdatedOverwatchCounter);
			NewGameState.AddStateObject(SourceUnit);
			EventMgr = `XEVENTMGR;
			EventMgr.TriggerEvent('OverwatchTriggered', AbilityState, SourceUnit, NewGameState);
			return true;	
		}
	}
	return false;
}

static function XComGameState_Effect_EffectCounter GetEisenefaustOverwatchCounter(XComGameState_Effect Effect)
{
	if (Effect != none) 
		return XComGameState_Effect_EffectCounter(Effect.FindComponentObject(class'XComGameState_Effect_EffectCounter'));
	return none;
}

defaultproperties
{
	DuplicateResponse=eDupe_Ignore
	EffectName="Effect_EisenefaustOverwatch"
}