//--------------------------------------------------------------------------------------- 
//  FILE:    X2Effect_EisenefaustOverwatch
//  AUTHOR:  Eisenefaust
//  PURPOSE: Sets up overwatch to take extra shots based on WeaponType, ActionPoints, and Soldier Class
//  Modified Long War Perk Pack Rapid Reaction implementation.
//--------------------------------------------------------------------------------------- 

Class X2Effect_EisenefaustOverwatch extends X2Effect_Persistent config (EisenefaustTUPack);

// default weapon types
// "rifle"		// overwatch capable
// "shotgun"	// overwatch capable
// "pistol"		// overwatch capable
// "melee"
// "grenade"
// "utility"
// "medikit"
// "cannon"		// overwatch capable
// "sword"
// "sniper_rifle"	// overwatch capable
// "heavy"
// "grenade_launcher"
// "gremlin"
// "baton"
// "psiamp"
// "shoulder_launcher"
// "skulljack"

struct EisenefaustOverwatchWeaponInfo
{
	var name WeaponType; // must match one of the entries in X2ItemTemplateManager's WeaponCategories.
	var float OverwatchActionsPerPoint; // number of overwatch actions awarded per action point spent.
};

struct EisenefaustOverwatchInfo
{
	var name SoldierClass;
	var array<name> OVERWATCH_ABILITY_NAMES;
	var array<name> OVERWATCHSHOT_ABILITY_NAMES;
	var array<EisenefaustOverwatchWeaponInfo> WeaponInfo;
};

var config array<EisenefaustOverwatchInfo> OverwatchInfo;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Effect_EisenefaustEffectCounter	EisenefaustOverwatch_EffectState;
	local X2EventManager						EventMgr;
	local Object								ListenerObj, EffectObj;
	local XComGameState_Unit					UnitState;

	EventMgr = `XEVENTMGR;
	EffectObj = NewEffectState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(NewEffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	if (GetEisenefaustOverwatchCounter(NewEffectState) == none)
	{
		EisenefaustOverwatch_EffectState = XComGameState_Effect_EisenefaustEffectCounter(NewGameState.CreateStateObject(class'XComGameState_Effect_EisenefaustEffectCounter'));
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

static function XComGameState_Effect_EisenefaustEffectCounter GetEisenefaustOverwatchCounter(XComGameState_Effect Effect)
{
	if (Effect != none) 
		return XComGameState_Effect_EisenefaustEffectCounter(Effect.FindComponentObject(class'XComGameState_Effect_EisenefaustEffectCounter'));
	return none;
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local X2EventManager EventMgr;
	local XComGameState_Ability AbilityState;	//  used for looking up our source ability (EisenefaustOverwatch), not the incoming one that was activated
	local XComGameState_Effect_EisenefaustEffectCounter	CurrentOverwatchCounter, UpdatedOverwatchCounter;
	local XComGameState_Unit HistoricalUnit;
	local EisenefaustOverwatchInfo OInfo;
	local EisenefaustOverwatchWeaponInfo OWInfo;

	CurrentOverwatchCounter = GetEisenefaustOverwatchCounter(EffectState);
	if (CurrentOverwatchCounter == none)
		return false;

	if (CurrentOverwatchCounter.uses >= CurrentOverwatchCounter.total)
	{
		`LOG("EisenefaustTimeUnitPack : EisenefaustOverwatch 'PostAbilityCostPaid' no more uses available of " @ kAbility.GetMyTemplateName() @ ". uses(" @ CurrentOverwatchCounter.uses @ ") >= total(" @ CurrentOverwatchCounter.total @ ").");
		return false;
	}

	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	if (AbilityState == none)
		return false;

	foreach default.OverwatchInfo(OInfo)
	{
		// make sure that the unit that activated the ability and the sourceunit both match and are both the correct soldier class
		if(OInfo.SoldierClass == SourceUnit.GetSoldierClassTemplateName())
		{
			// if an overwatch ability is used
			if (OInfo.OVERWATCH_ABILITY_NAMES.Find(kAbility.GetMyTemplateName()) != -1)
			{
				`LOG("EisenefaustTimeUnitPack : EisenefaustOverwatch 'PostAbilityCostPaid' override called for overwatch ability " @ kAbility.GetMyTemplateName() @ " by SourceUnit " @ SourceUnit.GetFullName() @ ".");
				foreach OInfo.WeaponInfo(OWInfo)
				{
					if(OWInfo.WeaponType == AffectWeapon.GetWeaponCategory())
					{
						`LOG("EisenefaustTimeUnitPack : EisenefaustOverwatch WeaponType is " @ OWInfo.WeaponType @ " and has " @ OWInfo.OverwatchActionsPerPoint @ " overwatch actions per point.");

						// get unit from the history that activated the ability
						HistoricalUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
						if(HistoricalUnit == none)
							return false;
						
						// make sure the unit that activated the ability and the sourceunit both match soldierclass
						`LOG("EisenefaustTimeUnitPack : EisenefaustOverwatch HistoricalUnit Class is " @ HistoricalUnit.GetSoldierClassTemplateName() @ " and SourceUnit Class is " @ SourceUnit.GetSoldierClassTemplateName() @ ".");
						`assert(HistoricalUnit.GetSoldierClassTemplateName() == SourceUnit.GetSoldierClassTemplateName());
						
						`LOG("EisenefaustTimeUnitPack : EisenefaustOverwatch HistoricalUnit " @ HistoricalUnit.GetFullName() @ " has " @ HistoricalUnit.ActionPoints.Length @ " action points.");

						// determine how many uses for this turn
						UpdatedOverwatchCounter = XComGameState_Effect_EisenefaustEffectCounter(NewGameState.CreateStateObject(class'XComGameState_Effect_EisenefaustEffectCounter', CurrentOverwatchCounter.ObjectID));
						UpdatedOverwatchCounter.total = int(HistoricalUnit.ActionPoints.Length * OWInfo.OverwatchActionsPerPoint); // Adjust total shots to take based on action points and weapon type
						NewGameState.AddStateObject(UpdatedOverwatchCounter);
						break;
					}
				}
				break;
			} 

			// if an overwatchshot ability is used
			if (OInfo.OVERWATCHSHOT_ABILITY_NAMES.Find(kAbility.GetMyTemplateName()) != -1) 
			{
				`LOG("EisenefaustTimeUnitPack : EisenefaustOverwatch 'PostAbilityCostPaid' override called for overwatch shot ability " @ kAbility.GetMyTemplateName() @ " by SourceUnit " @ SourceUnit.GetFullName() @ ".");
				
				// check if action points were spent
				if(SourceUnit.ReserveActionPoints.Length != PreCostReservePoints.Length)
				{
					`LOG("EisenefaustTimeUnitPack : EisenefaustOverwatch SourceUnit " @ SourceUnit.GetFullName() @ " has used " @ kAbility.GetMyTemplateName() @ " " @ CurrentOverwatchCounter.uses + 1 @ " times.");
					SourceUnit.ReserveActionPoints = PreCostReservePoints;
					UpdatedOverwatchCounter = XComGameState_Effect_EisenefaustEffectCounter(NewGameState.CreateStateObject(class'XComGameState_Effect_EisenefaustEffectCounter', CurrentOverwatchCounter.ObjectID));
					UpdatedOverwatchCounter.uses += 1;
					NewGameState.AddStateObject(UpdatedOverwatchCounter);
					NewGameState.AddStateObject(SourceUnit);
					EventMgr = `XEVENTMGR;
					EventMgr.TriggerEvent('EisenefaustOverwatchTriggered', AbilityState, SourceUnit, NewGameState);
					return true;
				}
			}
			
			break; // only one soldier class per soldier, found the class of the soldier but ability is not handled by this overwatch handler

		}
	}
	return false;
}

defaultproperties
{
	DuplicateResponse=eDupe_Ignore
	EffectName="Effect_EisenefaustOverwatch"
}

