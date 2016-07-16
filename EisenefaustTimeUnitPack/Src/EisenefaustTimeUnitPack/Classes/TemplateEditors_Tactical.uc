//--------------------------------------------------------------------------------------- 
//  FILE:    TemplateEditors_Tactical
//  AUTHOR:  Eisenefaust with loads of design taken from Xylthixlm's Shadow Ops Class Pack (http://steamcommunity.com/sharedfiles/filedetails/?id=651343461)
//  PURPOSE: Sets up ScreenListener to change standard abilities to work with the TU Perk
//--------------------------------------------------------------------------------------- 

class TemplateEditors_Tactical extends Object config(EisenefaustTUPack);

var config array<name> DoesNotConsumeAllAbilityPoints;

// The following template types have per-difficulty variants:
// X2CharacterTemplate (except civilians and characters who never appear in tactical play)
// X2FacilityTemplate
// X2FacilityUpgradeTemplate
// X2MissionSourceTemplate
// X2SchematicTemplate
// X2SoldierClassTemplate
// X2SoldierUnlockTemplate
// X2SpecialRoomFeatureTemplate
// X2TechTemplate

static function EditTemplates()
{
    // Add Bullet Swarm to the standard shot ability
    /*
	AddDoNotConsumeAllAbility('StandardShot', 'EisenfaustActionPoints');
	AddDoNotConsumeAllAbility('StandardMelee', 'EisenfaustActionPoints');
	AddDoNotConsumeAllAbility('StandardMovingMelee', 'EisenfaustActionPoints');
	AddDoNotConsumeAllAbility('PistolStandardShot', 'EisenfaustActionPoints');
	AddDoNotConsumeAllAbility('SniperStandardFire', 'EisenfaustActionPoints');
	AddDoNotConsumeAllAbility('ThrowGrenade', 'EisenfaustActionPoints');
	AddDoNotConsumeAllAbility('LaunchGrenade', 'EisenfaustActionPoints');
	AddDoNotConsumeAllAbility('MedikitHeale', 'EisenfaustActionPoints');
	AddDoNotConsumeAllAbility('NanoMedikitHeal', 'EisenfaustActionPoints');
	AddDoNotConsumeAllAbility('GremlinHeal', 'EisenfaustActionPoints');
	AddDoNotConsumeAllAbility('SteadyWeapon', 'EisenfaustActionPoints');
	AddDoNotConsumeAllAbility('StandardMelee', 'EisenfaustActionPoints');
	AddDoNotConsumeAllAbility('StandardMelee', 'EisenfaustActionPoints');
	*/
	AddAllDoNotConsumeAllAbilities();
	//AddAllPostActivationEvents();
}

static function AddAllDoNotConsumeAllAbilities()
{
	local name DataName;

	// Get list of actions to change functionality to not consume all Ability Points if the TU Perk Passive is active on that unit
	foreach default.DoesNotConsumeAllAbilityPoints(DataName)
	{
		AddDoNotConsumeAllAbility(DataName, 'EisenfaustActionPoints');
	}
}

static function AddDoNotConsumeAllAbility(name AbilityName, name PassiveAbilityName)
{
	local X2AbilityTemplateManager		AbilityManager;
	local array<X2AbilityTemplate>		TemplateAllDifficulties;
	local X2AbilityTemplate				Template;
	local X2AbilityCost					AbilityCost;
	local X2AbilityCost_ActionPoints	ActionPointCost;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityManager.FindAbilityTemplateAllDifficulties(AbilityName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		foreach Template.AbilityCosts(AbilityCost)
		{
			ActionPointCost = X2AbilityCost_ActionPoints(AbilityCost);
			if (ActionPointCost != none && ActionPointCost.bConsumeAllPoints && ActionPointCost.DoNotConsumeAllSoldierAbilities.Find(PassiveAbilityName) == INDEX_NONE)
			{
				ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem(PassiveAbilityName);
			}
		}
	}
}
