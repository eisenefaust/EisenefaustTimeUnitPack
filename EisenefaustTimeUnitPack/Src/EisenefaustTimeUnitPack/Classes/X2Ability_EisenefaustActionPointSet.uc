//---------------------------------------------------------------------------------------
//  FILE:    X2Ability_EisenefaustActionPointSet
//  AUTHOR:  Eisenefaust
//  PURPOSE: Defines ActionPoints ability template
//--------------------------------------------------------------------------------------- 

class X2Ability_EisenefaustActionPointSet extends X2Ability config (EisenefaustTUPack);
//  dependson

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(AddEisenefaustOverwatchAbility());
	Templates.AddItem(AddEisenefaustActionPointsAbility());
	 
	return Templates;
}

static function X2AbilityTemplate AddEisenefaustOverwatchAbility()
{
	local X2AbilityTemplate                 Template;	
	local X2Effect_EisenefaustOverwatch			PersistentEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'EisenefaustOverwatch');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_aethershift";
	Template.Hostility = eHostility_Neutral;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	PersistentEffect = new class'X2Effect_EisenefaustOverwatch';
	PersistentEffect.BuildPersistentEffect(1, true, false);
	//PersistentEffect.OVERWATCH_USES_THIS_TURN = 6;
	PersistentEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(PersistentEffect);
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.bCrossClassEligible = false;
	return Template;
}

static function X2AbilityTemplate AddEisenefaustActionPointsAbility()
{
	local X2AbilityTemplate			Template;
	local X2Effect_EisenefaustTurnStartActionPoints	StartAP;
	//local X2Effect_EisenefaustOverwatch				Overwatch;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'EisenefaustActionPoints');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_timeshift";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow; //Don't show in the Tactical Ability HUD
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);	
	Template.bIsPassive = true;
	
	StartAP = new class 'X2Effect_EisenefaustTurnStartActionPoints';
	StartAP.BuildPersistentEffect (1, true, true); // exist forever
	StartAP.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect (StartAP); // adds to target of the ability as defined above: SelfTarget
	
	Template.bCrossClassEligible = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

