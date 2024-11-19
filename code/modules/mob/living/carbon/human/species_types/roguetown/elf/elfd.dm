	/*==============*
	*				*
	*	Dark Elf	*
	*				*
	*===============*/

//	( + Night Vision Plus )

/mob/living/carbon/human/species/elf/dark
	race = /datum/species/elf/dark

/datum/species/elf/dark
	name = "Dark Elf"
	id = "elf"
	desc = "<b>Dark Elf</b><br>\
	Descending from a perversion of false immortality, Dark Elves are a unique and young species \
	that have only recently found themselves a staple of daily life. \
	They boast a proud, beauty-centric culture that compensates their cursed that ranges \
	from skin tints to extreme deformations, with anyone falling behind their cripplingly high standards \
	refered to as a Homonculus. While less graceful terms such as \
	stitchface, zombie or corpsewalker are most commonly thrown out by the elder races \
	Dark Elves tend to be extremely arrogant of others plights, with selfishness \
	being seen as a massive boon in their societies, leading to storng rivalries among their enclaves. \
	They are academic and usually well taught through are noted to suffer from their anatomy, which tends to be weak and brittle."

	skin_tone_wording = "Curse Affliction"

	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,OLDGREY)
	inherent_traits = list(TRAIT_NOMOBSWAP)
	default_features = list("mcolor" = "FFF", "ears" = "ElfW", "wings" = "None")
	use_skintones = 1
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = NONE
	liked_food = NONE
	possible_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | SLIME_EXTRACT
	limbs_icon_m = 'icons/roguetown/mob/bodies/m/mem.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/ft.dmi'
	dam_icon = 'icons/roguetown/mob/bodies/dam/dam_male.dmi'
	dam_icon_f = 'icons/roguetown/mob/bodies/dam/dam_female.dmi'
	hairyness = "t3"
	mutant_bodyparts = list("ears")
	mutanteyes = /obj/item/organ/eyes/elf
	use_f = TRUE
	soundpack_m = /datum/voicepack/male/elf
	soundpack_f = /datum/voicepack/female/elf
	offset_features = list(	OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,1), OFFSET_WRISTS = list(0,1), OFFSET_HANDS = list(0,0), \
	OFFSET_CLOAK = list(0,1), OFFSET_FACEMASK = list(0,0), OFFSET_HEAD = list(0,0), \
	OFFSET_FACE = list(0,0), OFFSET_BELT_F = list(0,1), OFFSET_BACK = list(0,0), \
	OFFSET_NECK = list(0,0), OFFSET_MOUTH = list(0,0), OFFSET_PANTS = list(0,1), \
	OFFSET_SHIRT = list(0,1), OFFSET_ARMOR = list(0,1), OFFSET_UNDIES = list(0,1),\
	OFFSET_ID_F = list(0,0), OFFSET_GLOVES_F = list(0,1), OFFSET_WRISTS_F = list(0,1), OFFSET_HANDS_F = list(0,1), \
	OFFSET_CLOAK_F = list(0,1), OFFSET_FACEMASK_F = list(0,0), OFFSET_HEAD_F = list(0,0), \
	OFFSET_FACE_F = list(0,0), OFFSET_BELT_F = list(0,0), OFFSET_BACK_F = list(0,0), \
	OFFSET_NECK_F = list(0,0), OFFSET_MOUTH_F = list(0,0), OFFSET_PANTS_F = list(0,1), \
	OFFSET_SHIRT_F = list(0,1), OFFSET_ARMOR_F = list(0,1), OFFSET_UNDIES_F = list(0,1))
	specstats = list("strength" = -1, "perception" = -1, "intelligence" = 1, "constitution" = 0, "endurance" = 1, "speed" = 2, "fortune" = 0)
	specstats_f = list("strength" = 0, "perception" = -1, "intelligence" = 1, "constitution" = 1, "endurance" = 0, "speed" = 1, "fortune" = 0)
	enflamed_icon = "widefire"
	patreon_req = 0

	customizers = list(
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid,
		/datum/customizer/bodypart_feature/hair/facial/humanoid,
		/datum/customizer/bodypart_feature/accessory,
	)
	body_markings = list(
		/datum/body_marking/tonage,
	)

/datum/species/elf/dark/get_span_language(datum/language/message_language)
	if(!message_language)
		return
	if(message_language.type == /datum/language/elvish)
		return list(SPAN_DELF)
	return message_language.spans
/*
/datum/species/elf/dark/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.remove_language(/datum/language/common)

/datum/species/elf/dark/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.grant_language(/datum/language/common)
*/
/datum/species/elf/dark/check_roundstart_eligible()
	return TRUE

/datum/species/elf/dark/get_skin_list()
	return sortList(list(
		"Maggot" = SKIN_COLOR_MAGGOT,
		"Cocoon" = SKIN_COLOR_COCOON,
		"Ashen" = SKIN_COLOR_ASHEN,
		"Spider Venom" = SKIN_COLOR_SPIDER_VENOM,
		"Jackpoison" = SKIN_COLOR_JACKPOISON,
		"Homunculus" = SKIN_COLOR_HOMUNCULUS,
		"Arachnid Ichor" = SKIN_COLOR_ARACHNID_ICHOR,
		"Scorpion" = SKIN_COLOR_SCORPION,
	))

/datum/species/elf/dark/get_hairc_list()
	return sortList(list(
	"black - oil" = "181a1d",
	"black - cave" = "201616",
	"black - rogue" = "2b201b",
	"black - midnight" = "1d1b2b",

	"white - cavedew" = "dee9ed",
	"white - spiderweb" = "f4f4f4"

	))

/datum/species/elf/dark/random_name(gender,unique,lastname)
	var/randname
	if(unique)
		if(gender == MALE)
			for(var/i in 1 to 10)
				randname = pick( world.file2list("strings/rt/names/elf/elfdm.txt") )
				if(!findname(randname))
					break
		if(gender == FEMALE)
			for(var/i in 1 to 10)
				randname = pick( world.file2list("strings/rt/names/elf/elfdf.txt") )
				if(!findname(randname))
					break
	else
		if(gender == MALE)
			randname = pick( world.file2list("strings/rt/names/elf/elfdm.txt") )
		if(gender == FEMALE)
			randname = pick( world.file2list("strings/rt/names/elf/elfdf.txt") )
	return randname

/datum/species/elf/dark/random_surname()
	return " [pick(world.file2list("strings/rt/names/elf/elfsnf.txt"))]"

/datum/species/elf/dark/get_accent_list()
	return strings("french_replacement.json", "french")
