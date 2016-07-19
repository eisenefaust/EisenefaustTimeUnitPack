//---------------------------------------------------------------------------------------
//  FILE:    X2Ability_EisenfaustActionPointSet
//  AUTHOR:  Eisenefaust
//  PURPOSE: Defines ActionPoints ability template
//--------------------------------------------------------------------------------------- 

class X2Ability_EisenfaustActionPointSet extends X2Ability config (EisenefaustTUPack);
//  dependson

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(AddEisenfaustActionPointsAbility());
	 
	return Templates;
}

static function X2AbilityTemplate AddEisenfaustActionPointsAbility()
{
	local X2AbilityTemplate			Template;
	local X2Effect_EisenfaustTurnStartActionPoints	StartAP;
	local X2Effect_EisenefaustOverwatch				Overwatch;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'EisenfaustActionPoints');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_timeshift";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow; //Don't show in the Tactical Ability HUD
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);	
	Template.bIsPassive = true;
	
	StartAP = new class 'X2Effect_EisenfaustTurnStartActionPoints';
	StartAP.BuildPersistentEffect (1, true, true); // exist forever
	StartAP.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect (StartAP); // adds to target of the ability as defined above: SelfTarget

	Overwatch = new class'X2Effect_EisenefaustOverwatch';
	Overwatch.BuildPersistentEffect (1, true, true);
	Overwatch.SetDisplayInfo(ePerkBuff_Passive,,, Template.IconImage, false,,Template.AbilitySourceName); // the false is to not show it in the passive HUD list
	Overwatch.OVERWATCH_USES_PER_TURN = 6;
	Template.AddTargetEffect (Overwatch);
	
	Template.bCrossClassEligible = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}