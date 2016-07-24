//--------------------------------------------------------------------------------------- 
//  FILE:    X2Effect_EisenefaustOverwatch
//  AUTHOR:  Eisenefaust
//  PURPOSE: Sets up overwatch to take extra shots based on WeaponType, ActionPoints, and Soldier Class
//  Modified Long War Perk Pack Rapid Reaction implementation.
//--------------------------------------------------------------------------------------- 

Class X2Effect_EisenefaustOverwatch extends X2Effect_Persistent config (EisenefaustTUPack);

var int OVERWATCH_USES_THIS_TURN;
var config array<name> OVERWATCH_ABILITY_NAMES;
var config array<name> OVERWATCHSHOT_ABILITY_NAMES;

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
		`Redscreen("X2Effect_EisenefaustOverwatch.OnEffectAdded(...): Failed to find EisenefaustOverwatch Component when registering listener");
		return;
	}
	EventMgr.RegisterForEvent(ListenerObj, 'PlayerTurnBegun', EisenefaustOverwatch_EffectState.ResetUses, ELD_OnStateSubmitted);
	EventMgr.RegisterForEvent(EffectObj, 'EisenefaustOverwatchTriggered', NewEffectState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}

static function XComGameState_Effect_EffectCounter GetEisenefaustOverwatchCounter(XComGameState_Effect Effect)
{
	if (Effect != none) 
		return XComGameState_Effect_EffectCounter(Effect.FindComponentObject(class'XComGameState_Effect_EffectCounter'));
	return none;
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local X2EventManager EventMgr;
	local XComGameState_Ability AbilityState;       //  used for looking up our source ability (EisenefaustOverwatch), not the incoming one that was activated
	local XComGameState_Effect_EffectCounter	CurrentOverwatchCounter, UpdatedOverwatchCounter;
	local XComGameState_Unit HistoricalUnit;

	CurrentOverwatchCounter = GetEisenefaustOverwatchCounter(EffectState);
	if (CurrentOverwatchCounter != none)	 
	{
		// if just activated one of the overwatch abilities
		if (default.OVERWATCH_ABILITY_NAMES.Find(kAbility.GetMyTemplateName()) != -1)
		{
			// determine how many uses for this turn
			HistoricalUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
			if (HistoricalUnit != none)
			{
				OVERWATCH_USES_THIS_TURN = HistoricalUnit.ActionPoints.Length;
			}
		}

		if (CurrentOverwatchCounter.uses >= OVERWATCH_USES_THIS_TURN) // Essentially a modified PreCostActionPoints.Length
		{
			return false;
		}
	}

	if (XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID)) == none)
		return false;

	// if an overwatchshot ability is used
	if (SourceUnit.ReserveActionPoints.Length != PreCostReservePoints.Length && default.OVERWATCHSHOT_ABILITY_NAMES.Find(kAbility.GetMyTemplateName()) != -1)
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
			EventMgr.TriggerEvent('EisenefaustOverwatchTriggered', AbilityState, SourceUnit, NewGameState);
			return true;	
		}
	}
	return false;
}

defaultproperties
{
	DuplicateResponse=eDupe_Ignore
	EffectName="Effect_EisenefaustOverwatch"
}

