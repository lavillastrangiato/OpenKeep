/obj/machinery/light/roguestreet
	icon = 'icons/roguetown/misc/tallstructure.dmi'
	icon_state = "slamp1"
	base_state = "slamp"
	brightness = 10
	nightshift_allowed = FALSE
	fueluse = 0
	bulb_colour = "#f9e080"
	bulb_power = 0.85
	max_integrity = 0
	use_power = NO_POWER_USE
	var/datum/looping_sound/soundloop
	pass_flags = LETPASSTHROW

/obj/machinery/light/roguestreet/midlamp
	icon = 'icons/roguetown/misc/64x64.dmi'
	icon_state = "midlamp1"
	base_state = "midlamp"
	pixel_x = -16
	density = TRUE

/obj/machinery/light/roguestreet/proc/lights_out()
	if(soundloop)
		soundloop.stop()
	on = FALSE
	set_light(0)
	update_icon()
	addtimer(CALLBACK(src, PROC_REF(lights_on)), 5 MINUTES)

/obj/machinery/light/roguestreet/proc/lights_on()
	on = TRUE
	update()
	update_icon()
	if(soundloop)
		soundloop.start()

/obj/machinery/light/roguestreet/update_icon()
	if(on)
		icon_state = "[base_state]1"
	else
		icon_state = "[base_state]0"

/obj/machinery/light/roguestreet/update()
	. = ..()
	if(on)
		GLOB.fires_list |= src
	else
		GLOB.fires_list -= src

/obj/machinery/light/roguestreet/Initialize()
	soundloop = pick(/datum/looping_sound/streetlamp1,/datum/looping_sound/streetlamp2,/datum/looping_sound/streetlamp3)
	if(soundloop)
		soundloop = new soundloop(src, FALSE)
		soundloop.start()
	GLOB.streetlamp_list += src
	update_icon()
	. = ..()

/obj/machinery/light/roguestreet/update_icon()
	if(on)
		icon_state = "[base_state]1"
	else
		icon_state = "[base_state]0"

//fires
/obj/machinery/light/rogue
	icon = 'icons/roguetown/misc/lighting.dmi'
	brightness = 8
	nightshift_allowed = FALSE
	fueluse = 60 MINUTES
	bulb_colour = "#f9ad80"
	bulb_power = 1
	use_power = NO_POWER_USE
	var/datum/looping_sound/soundloop = /datum/looping_sound/fireloop
	pass_flags = LETPASSTHROW
	var/cookonme = FALSE
	var/crossfire = TRUE

/obj/machinery/light/rogue/Initialize()
	if(soundloop)
		soundloop = new soundloop(src, FALSE)
		soundloop.start()
	GLOB.fires_list += src
	if(fueluse)
		fueluse = fueluse - (rand(fueluse*0.1,fueluse*0.3))
	update_icon()
	seton(TRUE)
	. = ..()

/obj/machinery/light/rogue/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)


/obj/machinery/light/rogue/examine(mob/user)
	. = ..()
	if(Adjacent(user))
		if(fueluse > 0)
			var/minsleft = fueluse / 600
			minsleft = round(minsleft)
			if(minsleft <= 1)
				minsleft = "less than a minute"
			else
				minsleft = "[round(minsleft)] minutes"
			. += "<span class='info'>The fire will last for [minsleft].</span>"
		else
			if(initial(fueluse) > 0)
				. += "<span class='warning'>The fire is burned out and hungry...</span>"


/obj/machinery/light/rogue/extinguish()
	if(on)
		burn_out()
		new /obj/effect/temp_visual/small_smoke(src.loc)
	..()



/obj/machinery/light/rogue/burn_out()
	if(soundloop)
		soundloop.stop()
	if(on)
		playsound(src.loc, 'sound/items/firesnuff.ogg', 100)
	..()
	update_icon()

/obj/machinery/light/rogue/update_icon()
	if(on)
		icon_state = "[base_state]1"
	else
		icon_state = "[base_state]0"

/obj/machinery/light/rogue/update()
	. = ..()
	if(on)
		GLOB.fires_list |= src
	else
		GLOB.fires_list -= src

/obj/machinery/light/rogue/Destroy()
	QDEL_NULL(soundloop)
	GLOB.fires_list -= src
	. = ..()

/obj/machinery/light/rogue/fire_act(added, maxstacks)
	if(!on && ((fueluse > 0) || (initial(fueluse) == 0)))
		playsound(src.loc, 'sound/items/firelight.ogg', 100)
		on = TRUE
		update()
		update_icon()
		if(soundloop)
			soundloop.start()
		addtimer(CALLBACK(src, PROC_REF(trigger_weather)), rand(5,20))
		return TRUE

/obj/proc/trigger_weather()
	if(!QDELETED(src))
		if(isturf(loc))
			var/turf/T = loc
			T.trigger_weather(src)

/obj/machinery/light/rogue/Crossed(atom/movable/AM, oldLoc)
	..()
	if(crossfire)
		if(on)
			AM.fire_act(1,5)

/obj/machinery/light/rogue/spark_act()
	fire_act()

/obj/machinery/light/rogue/attackby(obj/item/W, mob/living/user, params)
	if(cookonme)
		if(istype(W, /obj/item/reagent_containers/food/snacks))
			if(istype(W, /obj/item/reagent_containers/food/snacks/egg))
				to_chat(user, "<span class='warning'>I wouldn't be able to cook this over the fire...</span>")
				return FALSE
			var/obj/item/A = user.get_inactive_held_item()
			if(A)
				var/foundstab = FALSE
				for(var/X in A.possible_item_intents)
					var/datum/intent/D = new X
					if(D.blade_class == BCLASS_STAB)
						foundstab = TRUE
						break
				if(foundstab)
					var/prob2spoil = 33
					if(user.mind.get_skill_level(/datum/skill/craft/cooking))
						prob2spoil = 1
					user.visible_message("<span class='notice'>[user] starts to cook [W] over [src].</span>")
					for(var/i in 1 to 6)
						if(do_after(user, 30, target = src))
							var/obj/item/reagent_containers/food/snacks/S = W
							var/obj/item/C
							if(prob(prob2spoil))
								user.visible_message("<span class='warning'>[user] burns [S].</span>")
								if(user.client?.prefs.showrolls)
									to_chat(user, "<span class='warning'>Critfail... [prob2spoil]%.</span>")
								C = S.cooking(1000, null)
							else
								C = S.cooking(S.cooktime/4, src)
							if(C)
								user.dropItemToGround(S, TRUE)
								qdel(S)
								C.forceMove(get_turf(user))
								user.put_in_hands(C)
								break
						else
							break
					return
	if(W.firefuel)
		if(initial(fueluse))
			if(fueluse > initial(fueluse) - 5 SECONDS)
				to_chat(user, "<span class='warning'>Full.</span>")
				return
		else
			if(!on)
				return
		if (alert(usr, "Feed [W] to the fire?", "ROGUETOWN", "Yes", "No") != "Yes")
			return
		qdel(W)
		user.visible_message("<span class='warning'>[user] feeds [W] to [src].</span>")
		if(initial(fueluse))
			fueluse = fueluse + W.firefuel
			if(fueluse > initial(fueluse)) //keep it at the max
				fueluse = initial(fueluse)
		return
	else
		if(on)
			if(istype(W, /obj/item/natural/dirtclod))
				if(!user.temporarilyRemoveItemFromInventory(W))
					return
				on = FALSE
				set_light(0)
				update_icon()
				qdel(W)
				src.visible_message("<span class='warning'>[user] snuffs the fire.</span>")
				return
			if(user.used_intent?.type != INTENT_SPLASH)
				W.spark_act()
	..()

/obj/machinery/light/rogue/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	return

/obj/machinery/light/rogue/firebowl
	name = "brazier"
	icon = 'icons/roguetown/misc/lighting.dmi'
	icon_state = "stonefire1"
	density = TRUE
//	pixel_y = 10
	base_state = "stonefire"
	climbable = TRUE
	pass_flags = LETPASSTHROW
	cookonme = TRUE
	dir = SOUTH
	crossfire = TRUE
	fueluse = 0
	light_outer_range = 9

/obj/machinery/light/rogue/firebowl/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSTABLE))
		return 1
	if(mover.throwing)
		return 1
	if(locate(/obj/structure/table) in get_turf(mover))
		return 1
	return !density

/obj/machinery/light/rogue/firebowl/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(on)
		var/mob/living/carbon/human/H = user

		if(istype(H))
			H.visible_message("<span class='info'>[H] warms \his hand over the fire.</span>")

			if(do_after(H, 15, target = src))
				var/obj/item/bodypart/affecting = H.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
				to_chat(H, "<span class='warning'>HOT!</span>")
				if(affecting && affecting.receive_damage( 0, 5 ))		// 5 burn damage
					H.update_damage_overlays()
		return TRUE //fires that are on always have this interaction with lmb unless its a torch

	else
		if(icon_state == "[base_state]over")
			user.visible_message("<span class='notice'>[user] starts to pick up [src]...</span>", \
				"<span class='notice'>I start to pick up [src]...</span>")
			if(do_after(user, 30, target = src))
				icon_state = "[base_state]0"
			return

/obj/machinery/light/rogue/firebowl/stump
	icon_state = "stumpfire1"
	base_state = "stumpfire"

/obj/machinery/light/rogue/firebowl/church
	icon_state = "churchfire1"
	base_state = "churchfire"


/obj/machinery/light/rogue/firebowl/standing
	name = "standing fire"
	icon_state = "standing1"
	base_state = "standing"
	bulb_colour = "#ff9648"
	cookonme = FALSE
	crossfire = FALSE


/obj/machinery/light/rogue/firebowl/standing/blue
	bulb_colour = "#b9bcff"
	icon_state = "standingb1"
	base_state = "standingb"

/obj/machinery/light/rogue/firebowl/standing/proc/knock_over() //use this later for jump impacts and shit
	icon_state = "[base_state]over"

/obj/machinery/light/rogue/firebowl/standing/fire_act(added, maxstacks)
	if(icon_state != "[base_state]over")
		..()

/obj/machinery/light/rogue/firebowl/standing/onkick(mob/user)
	if(isliving(user))
		var/mob/living/L = user
		if(icon_state == "[base_state]over")
			playsound(src, 'sound/combat/hits/onwood/woodimpact (1).ogg', 100)
			user.visible_message("<span class='warning'>[user] kicks [src]!</span>", \
				"<span class='warning'>I kick [src]!</span>")
			return
		if(prob(L.STASTR * 8))
			playsound(src, 'sound/combat/hits/onwood/woodimpact (1).ogg', 100)
			user.visible_message("<span class='warning'>[user] kicks over [src]!</span>", \
				"<span class='warning'>I kick over [src]!</span>")
			burn_out()
			knock_over()
		else
			playsound(src, 'sound/combat/hits/onwood/woodimpact (1).ogg', 100)
			user.visible_message("<span class='warning'>[user] kicks [src]!</span>", \
				"<span class='warning'>I kick [src]!</span>")

/obj/machinery/light/rogue/wallfire
	name = "fireplace"
	icon_state = "wallfire1"
	base_state = "wallfire"
	density = FALSE
	fueluse = 0
	crossfire = FALSE
	cookonme = TRUE

/obj/machinery/light/rogue/wallfire/candle
	name = "candles"
	icon_state = "wallcandle1"
	base_state = "wallcandle"
	crossfire = FALSE
	cookonme = FALSE
	pixel_y = 32
	soundloop = null

/obj/machinery/light/rogue/wallfire/candle/attack_hand(mob/user)
	if(isliving(user) && on)
		user.visible_message("<span class='warning'>[user] snuffs [src].</span>")
		burn_out()
		return TRUE //fires that are on always have this interaction with lmb unless its a torch
	. = ..()

/obj/machinery/light/rogue/wallfire/candle/r
	pixel_y = 0
	pixel_x = 32
/obj/machinery/light/rogue/wallfire/candle/l
	pixel_y = 0
	pixel_x = -32

/obj/machinery/light/rogue/wallfire/candle/blue
	bulb_colour = "#b9bcff"
	icon_state = "wallcandleb1"
	base_state = "wallcandleb"

/obj/machinery/light/rogue/wallfire/candle/blue/r
	pixel_y = 0
	pixel_x = 32
/obj/machinery/light/rogue/wallfire/candle/blue/l
	pixel_y = 0
	pixel_x = -32

/obj/machinery/light/rogue/wallfire/candle/weak
	light_power = 0.9
	light_outer_range =  6
/obj/machinery/light/rogue/wallfire/candle/weak/l
	pixel_x = -32
	pixel_y = 0
/obj/machinery/light/rogue/wallfire/candle/weak/r
	pixel_x = 32
	pixel_y = 0

/obj/machinery/light/rogue/torchholder
	name = "sconce"
	icon_state = "torchwall1"
	base_state = "torchwall"
	brightness = 5
	density = FALSE
	var/obj/item/flashlight/flare/torch/torchy
	fueluse = FALSE //we use the torch's fuel
	soundloop = null
	crossfire = FALSE
	plane = GAME_PLANE_UPPER
	cookonme = FALSE
	var/lacks_torch

/obj/machinery/light/rogue/torchholder/c
	pixel_y = 32

/obj/machinery/light/rogue/torchholder/r
	dir = WEST

/obj/machinery/light/rogue/torchholder/l
	dir = EAST

/obj/machinery/light/rogue/torchholder/fire_act(added, maxstacks)
	if(torchy)
		if(!on)
			if(torchy.fuel > 0)
				torchy.spark_act()
				playsound(src.loc, 'sound/items/firelight.ogg', 100)
				on = TRUE
				update()
				update_icon()
				if(soundloop)
					soundloop.start()
				addtimer(CALLBACK(src, PROC_REF(trigger_weather)), rand(5,20))
				return TRUE

/obj/machinery/light/rogue/torchholder/Initialize()
	if(!lacks_torch)
		torchy = new /obj/item/flashlight/flare/torch(src)
		torchy.spark_act()
	. = ..()

/obj/machinery/light/rogue/torchholder/process()
	if(on)
		if(torchy)
			if(torchy.fuel <= 0)
				burn_out()
			if(!torchy.on)
				burn_out()
		else
			return PROCESS_KILL

/obj/machinery/light/rogue/torchholder/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(torchy)
		if(!istype(user) || !Adjacent(user) || !user.put_in_active_hand(torchy))
			torchy.forceMove(loc)
		torchy = null
		on = FALSE
		set_light(0)
		update_icon()
		playsound(src.loc, 'sound/foley/torchfixturetake.ogg', 70)

/obj/machinery/light/rogue/torchholder/update_icon()
	if(torchy)
		if(on)
			icon_state = "[base_state]1"
		else
			icon_state = "[base_state]0"
	else
		icon_state = "torchwall"

/obj/machinery/light/rogue/torchholder/burn_out()
	if(torchy.on)
		torchy.turn_off()
	..()

/obj/machinery/light/rogue/torchholder/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/flashlight/flare/torch))
		var/obj/item/flashlight/flare/torch/LR = W
		if(torchy)
			if(LR.on && !on)
				if(torchy.fuel <= 0)
					to_chat(user, "<span class='warning'>The mounted torch is burned out.</span>")
					return
				else
					torchy.spark_act()
					user.visible_message("<span class='info'>[user] lights [src].</span>")
					playsound(src.loc, 'sound/items/firelight.ogg', 100)
					on = TRUE
					update()
					update_icon()
					addtimer(CALLBACK(src, PROC_REF(trigger_weather)), rand(5,20))
					return
			if(!LR.on && on)
				if(LR.fuel > 0)
					LR.spark_act()
					user.visible_message("<span class='info'>[user] lights [LR] in [src].</span>")
					user.update_inv_hands()
		else
			if(LR.on)
				LR.forceMove(src)
				torchy = LR
				on = TRUE
				update()
				update_icon()
				addtimer(CALLBACK(src, PROC_REF(trigger_weather)), rand(5,20))
			else
				LR.forceMove(src)
				torchy = LR
				update_icon()
			playsound(src.loc, 'sound/foley/torchfixtureput.ogg', 70)
		return
	. = ..()

/obj/machinery/light/rogue/torchholder/cold
	lacks_torch = TRUE
	pixel_y = 32

/obj/machinery/light/rogue/chand
	name = "chandelier"
	icon_state = "chand1"
	base_state = "chand"
	icon = 'icons/roguetown/misc/tallwide.dmi'
	density = FALSE
	brightness = 10
	pixel_x = -10
	pixel_y = -10
	layer = 2.0
	fueluse = 0
	soundloop = null
	crossfire = FALSE
	obj_flags = CAN_BE_HIT | BLOCK_Z_OUT_DOWN | BLOCK_Z_IN_UP

/obj/machinery/light/rogue/chand/attack_hand(mob/user)
	if(isliving(user) && on)
		user.visible_message("<span class='warning'>[user] snuffs [src].</span>")
		burn_out()
		return TRUE //fires that are on always have this interaction with lmb unless its a torch
	. = ..()


/obj/machinery/light/rogue/hearth
	name = "hearth"
	icon_state = "hearth1"
	base_state = "hearth"
	density = TRUE
	anchored = TRUE
	climbable = TRUE
	climb_time = 3 SECONDS
	layer = TABLE_LAYER
	climb_offset = 14
	on = FALSE
	cookonme = TRUE
	var/obj/item/attachment = null
	var/obj/item/reagent_containers/food/snacks/food = null
	var/datum/looping_sound/boilloop/boilloop
	var/rawegg = FALSE

/obj/machinery/light/rogue/hearth/Initialize()
	boilloop = new(src, FALSE)
	. = ..()

/obj/machinery/light/rogue/hearth/attackby(obj/item/W, mob/living/user, params)
	if(!attachment)
		if(istype(W, /obj/item/cooking/pan) || istype(W, /obj/item/reagent_containers/glass/bucket/pot))
			playsound(get_turf(user), 'sound/foley/dropsound/shovel_drop.ogg', 40, TRUE, -1)
			attachment = W
			W.forceMove(src)
			update_icon()
			return
	else
		if(istype(W, /obj/item/reagent_containers/glass/bowl))
			to_chat(user, "<span class='notice'>Remove the pot from the hearth first.</span>")
			return
		if(istype(attachment, /obj/item/cooking/pan))
			if(W.type in subtypesof(/obj/item/reagent_containers/food/snacks))
				var/obj/item/reagent_containers/food/snacks/S = W
				if(istype(W, /obj/item/reagent_containers/food/snacks/egg)) // added
					playsound(get_turf(user), 'modular/Neu_Food/sound/eggbreak.ogg', 100, TRUE, 0)
					sleep(25) // to get egg crack before frying hiss
					W.icon_state = "rawegg" // added
					rawegg = TRUE
				if(!food)
					S.forceMove(src)
					food = S
					update_icon()
					if(on)
						playsound(src.loc, 'sound/misc/frying.ogg', 80, FALSE, extrarange = 5)
					return
// New concept = boil at least 33 water, add item, it turns into food reagent volume 33 of the appropriate type
		else if(istype(attachment, /obj/item/reagent_containers/glass/bucket/pot))
			var/obj/item/reagent_containers/glass/bucket/pot = attachment
			if(!pot.reagents.has_reagent(/datum/reagent/water, 33))
				to_chat(user, "<span class='notice'>Not enough water.</span>")
				return TRUE
			if(pot.reagents.chem_temp < 374)
				to_chat(user, "<span class='warning'>[pot] isn't boiling!</span>")
				return
			if(istype(W, /obj/item/reagent_containers/food/snacks/produce/oat))
				if(do_after(user,2 SECONDS, target = src))
					user.visible_message("<span class='info'>[user] places [W] into the pot.</span>")
					qdel(W)
					playsound(src.loc, 'sound/items/Fish_out.ogg', 20, TRUE)
					pot.reagents.remove_reagent(/datum/reagent/water, 32)
					sleep(300)
					playsound(src, "bubbles", 30, TRUE)
					pot.reagents.add_reagent(/datum/reagent/consumable/soup/oatmeal, 32)
					pot.reagents.remove_reagent(/datum/reagent/water, 1)
				return

			if(W.type in subtypesof(/obj/item/reagent_containers/food/snacks/rogue/veg))
				if(do_after(user,2 SECONDS, target = src))
					user.visible_message("<span class='info'>[user] places [W] into the pot.</span>")
					playsound(src.loc, 'sound/items/Fish_out.ogg', 20, TRUE)
					pot.reagents.remove_reagent(/datum/reagent/water, 32)
					if(istype(W, /obj/item/reagent_containers/food/snacks/rogue/veg/potato_sliced))
						qdel(W)
						sleep(800)
						playsound(src, "bubbles", 30, TRUE)
						pot.reagents.add_reagent(/datum/reagent/consumable/soup/veggie/potato, 32)
						pot.reagents.remove_reagent(/datum/reagent/water, 1)
					if(istype(W, /obj/item/reagent_containers/food/snacks/rogue/veg/onion_sliced))
						qdel(W)
						sleep(600)
						playsound(src, "bubbles", 30, TRUE)
						pot.reagents.add_reagent(/datum/reagent/consumable/soup/veggie/onion, 32)
						pot.reagents.remove_reagent(/datum/reagent/water, 1)
					if(istype(W, /obj/item/reagent_containers/food/snacks/rogue/veg/cabbage_sliced))
						qdel(W)
						sleep(700)
						playsound(src, "bubbles", 30, TRUE)
						pot.reagents.add_reagent(/datum/reagent/consumable/soup/veggie/cabbage, 32)
						pot.reagents.remove_reagent(/datum/reagent/water, 1)
					if(istype(W, /obj/item/reagent_containers/food/snacks/rogue/veg/turnip_sliced))
						qdel(W)
						sleep(700)
						playsound(src, "bubbles", 30, TRUE)
						pot.reagents.add_reagent(/datum/reagent/consumable/soup/veggie/turnip, 32)
						pot.reagents.remove_reagent(/datum/reagent/water, 1)
				return

			if(W.type in subtypesof(/obj/item/reagent_containers/food/snacks/rogue/meat))
				if(do_after(user,2 SECONDS, target = src))
					user.visible_message("<span class='info'>[user] places [W] into the pot.</span>")
					playsound(src.loc, 'sound/items/Fish_out.ogg', 20, TRUE)
					pot.reagents.remove_reagent(/datum/reagent/water, 32)
					if(istype(W, /obj/item/reagent_containers/food/snacks/rogue/meat/mince/fish))
						qdel(W)
						sleep(800)
						playsound(src, "bubbles", 30, TRUE)
						pot.reagents.add_reagent(/datum/reagent/consumable/soup/stew/fish, 32)
						pot.reagents.remove_reagent(/datum/reagent/water, 1)
					if(istype(W, /obj/item/reagent_containers/food/snacks/rogue/meat/poultry/cutlet) || istype(W, /obj/item/reagent_containers/food/snacks/rogue/meat/mince/poultry))
						qdel(W)
						sleep(900)
						playsound(src, "bubbles", 30, TRUE)
						pot.reagents.add_reagent(/datum/reagent/consumable/soup/stew/chicken, 32)
						pot.reagents.remove_reagent(/datum/reagent/water, 1)
					if(istype(W, /obj/item/reagent_containers/food/snacks/rogue/meat/spider))
						qdel(W)
						sleep(1000)
						playsound(src, "bubbles", 30, TRUE)
						pot.reagents.add_reagent(/datum/reagent/consumable/soup/stew/gross, 32)
						pot.reagents.remove_reagent(/datum/reagent/water, 1)
					else
						qdel(W)
						sleep(900)
						playsound(src, "bubbles", 30, TRUE)
						pot.reagents.add_reagent(/datum/reagent/consumable/soup/stew/meat, 32)
						pot.reagents.remove_reagent(/datum/reagent/water, 1)

			if(istype(W, /obj/item/reagent_containers/food/snacks/egg))
				if(do_after(user,2 SECONDS, target = src))
					user.visible_message("<span class='info'>[user] places the [W] into the pot.</span>")
					playsound(src.loc, 'sound/items/Fish_out.ogg', 20, TRUE)
					pot.reagents.remove_reagent(/datum/reagent/water, 32)
					qdel(W)
					sleep(800)
					playsound(src, "bubbles", 30, TRUE)
					pot.reagents.add_reagent(/datum/reagent/consumable/soup/egg, 32)
					pot.reagents.remove_reagent(/datum/reagent/water, 1)

			if(istype(W, /obj/item/reagent_containers/food/snacks/rogue/truffles))
				if(do_after(user,2 SECONDS, target = src))
					user.visible_message("<span class='info'>[user] places the [W] into the pot.</span>")
					playsound(src.loc, 'sound/items/Fish_out.ogg', 20, TRUE)
					pot.reagents.remove_reagent(/datum/reagent/water, 32)
					qdel(W)
					sleep(800)
					playsound(src, "bubbles", 30, TRUE)
					pot.reagents.add_reagent(/datum/reagent/consumable/soup/stew/truffle, 32)
					pot.reagents.remove_reagent(/datum/reagent/water, 1)

			if(istype(W, /obj/item/reagent_containers/food/snacks/rogue/cheese) || istype(W, /obj/item/reagent_containers/food/snacks/rogue/cheddarwedge))
				if(do_after(user,2 SECONDS, target = src))
					user.visible_message("<span class='info'>[user] places the [W] into the pot.</span>")
					playsound(src.loc, 'sound/items/Fish_out.ogg', 20, TRUE)
					pot.reagents.remove_reagent(/datum/reagent/water, 32)
					qdel(W)
					sleep(800)
					playsound(src, "bubbles", 30, TRUE)
					pot.reagents.add_reagent(/datum/reagent/consumable/soup/cheese, 32)
					pot.reagents.remove_reagent(/datum/reagent/water, 1)

			// drugs and such
			if(istype(W, /obj/item/reagent_containers/powder/spice))
				if(do_after(user,2 SECONDS, target = src))
					user.visible_message("<span class='info'>[user] places the [W] into the pot.</span>")
					playsound(src.loc, 'sound/items/Fish_out.ogg', 20, TRUE)
					pot.reagents.remove_reagent(/datum/reagent/water, 32)
					qdel(W)
					sleep(500)
					playsound(src, "bubbles", 30, TRUE)
					pot.reagents.add_reagent(/datum/reagent/druqks = 15)
					pot.reagents.add_reagent(/datum/reagent/water/spicy = 17)
					pot.reagents.remove_reagent(/datum/reagent/water, 1)

			// Bad and rotten and toxic stuff below. Less lethal due to boiling, but really disgusting. Graggars inhumen followers love this stuff, get some healing from it too.
			if(istype(W, /obj/item/reagent_containers/food/snacks/produce/jacksberry/poison) || istype(W, /obj/item/natural/poo)|| istype(W, /obj/item/reagent_containers/food/snacks/rogue/toxicshrooms) || istype(W, /obj/item/natural/worms))
				if(do_after(user,2 SECONDS, target = src))
					user.visible_message("<span class='info'>[user] places [W] into the pot.</span>")
					playsound(src.loc, 'sound/items/Fish_out.ogg', 20, TRUE)
					pot.reagents.remove_reagent(/datum/reagent/water, 32)
					qdel(W)
					sleep(600)
					playsound(src, "bubbles", 30, TRUE)
					pot.reagents.add_reagent(/datum/reagent/yuck/cursed_soup, 32)
					pot.reagents.remove_reagent(/datum/reagent/water, 1)

			if(W.type in subtypesof(/obj/item/reagent_containers/food/snacks/rotten)) // Graggar likes rotten food I guess
				if(do_after(user,2 SECONDS, target = src))
					user.visible_message("<span class='info'>[user] places [W] into the pot.</span>")
					playsound(src.loc, 'sound/items/Fish_out.ogg', 20, TRUE)
					pot.reagents.remove_reagent(/datum/reagent/water, 32)
					qdel(W)
					sleep(600)
					playsound(src, "bubbles", 30, TRUE)
					pot.reagents.add_reagent(/datum/reagent/yuck/cursed_soup, 32)
					pot.reagents.remove_reagent(/datum/reagent/water, 1)

			if(W.type in subtypesof(/obj/item/organ)) // ....and leeches and such....andd organs more MORE MORE if()!!! GIVE ME MOOORE
				if(do_after(user,2 SECONDS, target = src))
					user.visible_message("<span class='info'>[user] places [W] into the pot.</span>")
					playsound(src.loc, 'sound/items/Fish_out.ogg', 20, TRUE)
					pot.reagents.remove_reagent(/datum/reagent/water, 32)
					qdel(W)
					sleep(600)
					playsound(src, "bubbles", 30, TRUE)
					pot.reagents.add_reagent(/datum/reagent/yuck/cursed_soup, 32)
					pot.reagents.remove_reagent(/datum/reagent/water, 1)

			if(W.type in subtypesof(/obj/item/natural/worms)) // ....and leeches and such....andd organs more MORE MORE if()!!! GIVE ME MOOORE
				if(do_after(user,2 SECONDS, target = src))
					user.visible_message("<span class='info'>[user] places [W] into the pot.</span>")
					playsound(src.loc, 'sound/items/Fish_out.ogg', 20, TRUE)
					pot.reagents.remove_reagent(/datum/reagent/water, 32)
					qdel(W)
					sleep(600)
					playsound(src, "bubbles", 30, TRUE)
					pot.reagents.add_reagent(/datum/reagent/yuck/cursed_soup, 32)
					pot.reagents.remove_reagent(/datum/reagent/water, 1)

			if(istype(W, /obj/item/reagent_containers/food/snacks/smallrat/dead) || istype(W, /obj/item/reagent_containers/food/snacks/badrecipe))  // every beggar loves ratsoup
				if(do_after(user,2 SECONDS, target = src))
					user.visible_message("<span class='info'>[user] places the [W] into the pot.</span>")
					playsound(src.loc, 'sound/items/Fish_out.ogg', 20, TRUE)
					pot.reagents.remove_reagent(/datum/reagent/water, 32)
					qdel(W)
					sleep(600)
					playsound(src, "bubbles", 30, TRUE)
					pot.reagents.add_reagent(/datum/reagent/consumable/soup/stew/gross, 32)
					pot.reagents.remove_reagent(/datum/reagent/water, 1)

			else if(istype(W, /obj/item/reagent_containers/food/snacks/smallrat))  // a step to far for most beggars, paying tribute to Graggar
				if(do_after(user,2 SECONDS, target = src))
					user.visible_message("<span class='info'>[user] throws [W] into the boiling water.</span>")
					playsound(src.loc, 'sound/items/Fish_out.ogg', 60, TRUE)
					sleep(3)
					playsound(src, 'sound/vo/mobs/rat/rat_death.ogg', 100, FALSE, -1)
					pot.reagents.remove_reagent(/datum/reagent/water, 32)
					qdel(W)
					sleep(600)
					playsound(src, "bubbles", 30, TRUE)
					pot.reagents.add_reagent(/datum/reagent/yuck/cursed_soup, 32)
					pot.reagents.remove_reagent(/datum/reagent/water, 1)
	. = ..()

//////////////////////////////////

/obj/machinery/light/rogue/hearth/fire_act(added, maxstacks)
	. = ..()
	if(food)
		playsound(src.loc, 'sound/misc/frying.ogg', 80, FALSE, extrarange = 2)

/obj/machinery/light/rogue/hearth/update_icon()
	cut_overlays()
	icon_state = "[base_state][on]"
	if(attachment)
		if(istype(attachment, /obj/item/cooking/pan) || istype(attachment, /obj/item/reagent_containers/glass/bucket/pot))
			var/obj/item/I = attachment
			I.pixel_x = 0
			I.pixel_y = 0
			add_overlay(new /mutable_appearance(I))
			if(food)
				I = food
				I.pixel_x = 0
				I.pixel_y = 0
				add_overlay(new /mutable_appearance(I))

/obj/machinery/light/rogue/hearth/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(attachment)
		if(istype(attachment, /obj/item/cooking/pan))
			if(food)
				if(rawegg)
					to_chat(user, "<span class='notice'>Throws away the raw egg.</span>")
					rawegg = FALSE
					qdel(food)
					update_icon()
				if(!user.put_in_active_hand(food))
					food.forceMove(user.loc)
				food = null
				update_icon()
			else
				if(!user.put_in_active_hand(attachment))
					attachment.forceMove(user.loc)
				attachment = null
				update_icon()
		if(istype(attachment, /obj/item/reagent_containers/glass/bucket/pot))
			if(!user.put_in_active_hand(attachment))
				attachment.forceMove(user.loc)
			attachment = null
			update_icon()
			boilloop.stop()
	else
		if(on)
			var/mob/living/carbon/human/H = user
			if(istype(H))
				H.visible_message("<span class='info'>[H] warms \his hand over the embers.</span>")
				if(do_after(H, 50, target = src))
					var/obj/item/bodypart/affecting = H.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
					to_chat(H, "<span class='warning'>HOT!</span>")
					if(affecting && affecting.receive_damage( 0, 5 ))		// 5 burn damage
						H.update_damage_overlays()
			return TRUE


/obj/machinery/light/rogue/hearth/process()
	if(isopenturf(loc))
		var/turf/open/O = loc
		if(IS_WET_OPEN_TURF(O))
			extinguish()
	if(on)
		if(initial(fueluse) > 0)
			if(fueluse > 0)
				fueluse = max(fueluse - 10, 0)
			if(fueluse == 0)
				burn_out()
		if(attachment)
			if(istype(attachment, /obj/item/cooking/pan))
				if(food)
					var/obj/item/C = food.cooking(20, src)
					if(C)
						if(rawegg)
							rawegg = FALSE
						qdel(food)
						food = C
			if(istype(attachment, /obj/item/reagent_containers/glass/bucket/pot))
				if(attachment.reagents)
					attachment.reagents.expose_temperature(400, 0.033)
					if(attachment.reagents.chem_temp > 374)
						boilloop.start()
					else
						boilloop.stop()
		update_icon()


/obj/machinery/light/rogue/hearth/onkick(mob/user)
	if(isliving(user) && on)
		user.visible_message("<span class='warning'>[user] snuffs [src].</span>")
		burn_out()

/obj/machinery/light/rogue/hearth/Destroy()
	QDEL_NULL(boilloop)
	. = ..()

/obj/machinery/light/rogue/campfire
	name = "campfire"
	icon_state = "badfire1"
	base_state = "badfire"
	density = FALSE
	layer = 2.8
	brightness = 5
	on = FALSE
	fueluse = 15 MINUTES
	bulb_colour = "#da5e21"
	cookonme = TRUE
	light_outer_range = 7

/obj/machinery/light/rogue/campfire/process()
	..()
	if(isopenturf(loc))
		var/turf/open/O = loc
		if(IS_WET_OPEN_TURF(O))
			extinguish()

/obj/machinery/light/rogue/campfire/onkick(mob/user)
	if(isliving(user) && on)
		var/mob/living/L = user
		L.visible_message("<span class='info'>[L] snuffs [src].</span>")
		burn_out()

/obj/machinery/light/rogue/campfire/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(on)
		var/mob/living/carbon/human/H = user

		if(istype(H))
			H.visible_message("<span class='info'>[H] warms \his hand near the fire.</span>")

			if(do_after(H, 100, target = src))
				var/obj/item/bodypart/affecting = H.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
				to_chat(H, "<span class='warning'>HOT!</span>")
				if(affecting && affecting.receive_damage( 0, 5 ))		// 5 burn damage
					H.update_damage_overlays()
		return TRUE //fires that are on always have this interaction with lmb unless its a torch

/obj/machinery/light/rogue/campfire/densefire
	icon_state = "densefire1"
	base_state = "densefire"
	density = TRUE
	layer = 2.8
	brightness = 5
	climbable = TRUE
	on = FALSE
	fueluse = 30 MINUTES
	pass_flags = LETPASSTHROW
	bulb_colour = "#eea96a"

/obj/machinery/light/rogue/campfire/densefire/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSTABLE))
		return 1
	if(mover.throwing)
		return 1
	if(locate(/obj/structure/table) in get_turf(mover))
		return 1
	if(locate(/obj/machinery/light/rogue/firebowl) in get_turf(mover))
		return 1
	return !density


/obj/machinery/light/rogue/campfire/pyre
	name = "Pyre"
	icon = 'icons/roguetown/misc/tallstructure.dmi'
	icon_state = "pyre1"
	base_state = "pyre"
	brightness = 10
	fueluse = 30 MINUTES
	layer = BELOW_MOB_LAYER
	buckleverb = "crucifie"
	can_buckle = 1
	buckle_lying = 0
	dir = NORTH
	buckle_requires_restraints = 1
	buckle_prevents_pull = 1


/obj/machinery/light/rogue/campfire/pyre/post_buckle_mob(mob/living/M)
	..()
	M.set_mob_offsets("bed_buckle", _x = 0, _y = 10)
	M.setDir(SOUTH)

/obj/machinery/light/rogue/campfire/pyre/post_unbuckle_mob(mob/living/M)
	..()
	M.reset_offsets("bed_buckle")

/obj/machinery/light/rogue/campfire/longlived
	fueluse = 180 MINUTES

// ======================================================================
/obj/machinery/light/rogue/wallfire/candle/lamp // cant get them to start unlit but they work as is
	name = "candle lamp"
	icon = 'icons/roguetown/misc/decoration.dmi'
	icon_state = "candle"
	base_state = "candle"
	layer = WALL_OBJ_LAYER+0.1
	light_power = 0.9
	light_outer_range =  6

/obj/machinery/light/rogue/wallfire/big_fireplace
	icon_state = "fireplace1"
	base_state = "fireplace"
	icon = 'icons/roguetown/misc/fireplace64.dmi'

/obj/machinery/light/rogue/hearth/big_fireplace
	name = "fireplace"
	icon_state = "fireplace1"
	base_state = "fireplace"
	icon = 'icons/roguetown/misc/fireplace64.dmi'
	fueluse = -1
	pixel_x = -16
	climb_offset = 4
