/obj/item/natural/snowful
	name = "snow handful"
	desc = "A handful of snow."
	icon_state = "snow1"
	dropshrink = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY

/obj/item/natural/snowful/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/rogueweapon/shovel))
		var/obj/item/rogueweapon/shovel/S = W
		if(!S.heldsnow && user.used_intent.type == /datum/intent/shovelscoop)
			playsound(loc,'sound/items/dig_shovel.ogg', 100, TRUE)
			src.forceMove(S)
			S.heldsnow = src
			W.update_icon()
			return
	..()

/obj/item/natural/snowful/Moved(oldLoc, dir)
	..()
	if(isturf(loc))
		var/turf/T = loc
		for(var/obj/structure/fluff/snowpile/C in T)
			C.snowamt = min(C.snowamt+1, 5)
			qdel(src)
			return
		var/snowcount = 1
		var/list/snows = list()
		for(var/obj/item/natural/snowful/D in T)
			snowcount++
			snows += D
		if(snowcount >=5)
			for(var/obj/item/I in snows)
				qdel(I)
			qdel(src)
			new /obj/structure/fluff/snowpile(T)

/obj/item/natural/snowful/attack_self(mob/living/user)
	user.visible_message("<span class='warning'>[user] scatters [src].</span>")
	qdel(src)

/obj/item/natural/snowful/Initialize()
	icon_state = "snow[rand(1,2)]"
	..()

/obj/structure/fluff/snowpile
	name = "snow pile"
	desc = "A collection of snow, amalgamated into a structure colder than Necra's heart."
	icon_state = "snowpile"
	var/snowamt = 5
	icon = 'icons/roguetown/items/natural.dmi'
	climbable = FALSE
	density = FALSE
	climb_offset = 10

/obj/structure/fluff/snowpile/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/rogueweapon/shovel))
		var/obj/item/rogueweapon/shovel/S = W
		if(user.used_intent.type == /datum/intent/shovelscoop)
			if(!S.heldsnow)
				playsound(loc,'sound/items/dig_shovel.ogg', 100, TRUE)
				var/obj/item/J = new /obj/item/natural/snowful(S)
				S.heldsnow = J
				W.update_icon()
				snowamt--
				if(snowamt <= 0)
					qdel(src)
				return
			else
				playsound(loc,'sound/items/empty_shovel.ogg', 100, TRUE)
				var/obj/item/I = S.heldsnow
				S.heldsnow = null
				qdel(I)
				W.update_icon()
				snowamt++
				if(snowamt > 5)
					snowamt = 5
				return
	..()

/obj/structure/fluff/snowpile/Initialize()
	dir = pick(GLOB.cardinals)
	..()
