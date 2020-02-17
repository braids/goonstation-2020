// Note: Hard hat and engineering space helmet can be found in helments.dm, the cake hat in hats.dm.

/obj/item/device/light
	var/on = 0
	var/icon_on = "flight1"
	var/icon_off = "flight0"
	var/col_r = 0.5
	var/col_g = 0.5
	var/col_b = 0.5
	var/brightness = 1
	var/height = 1
	var/datum/light/light

	New()
		..()
		light = new /datum/light/point
		light.set_brightness(src.brightness)
		light.set_color(col_r, col_g, col_b)
		light.attach(src)

	pickup(mob/user)
		..()
		light.attach(user)

	dropped(mob/user)
		..()
		SPAWN_DBG(0)
			if (src.loc != user)
				light.attach(src)

/obj/item/device/light/flashlight
	name = "flashlight"
	desc = "A hand-held emergency light."
	icon_state = "flight0"
	item_state = "flight"
	icon_on = "flight1"
	icon_off = "flight0"
	w_class = 2
	flags = FPRINT | ONBELT | TABLEPASS | CONDUCT
	m_amt = 50
	g_amt = 20
	mats = 2
	var/emagged = 0
	var/broken = 0
	col_r = 0.9
	col_g = 0.8
	col_b = 0.7
	module_research = list("science" = 1, "devices" = 1)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.emagged)
			if (user)
				usr.show_text("You short out the voltage regulator in the lighting circuit.", "blue")
			src.emagged = 1
		else
			if (user)
				user.show_text("The regulator is already burned out.", "red")
			return 0

	demag(var/mob/user)
		if (!src.emagged)
			return 0
		if (user)
			user.show_text("You repair the voltage regulators.", "blue")
		src.emagged = 0
		return 1

	attack_self(mob/user)
		src.toggle(user)

	proc/toggle(var/mob/user)
		if (src.broken)
			name = "broken flashlight"
			return

		src.on = !src.on
		playsound(get_turf(src), "sound/items/penclick.ogg", 30, 1)
		if (src.on)
			set_icon_state(src.icon_on)
			if (src.emagged) // Burn them all!
				user.apply_flash(60, 2, 0, 0, rand(2, 8), rand(1, 15), 0, 25, 100, stamina_damage = 70, disorient_time = 10)
				for (var/mob/M in oviewers(2, get_turf(src)))
					if (in_cone_of_vision(user, M)) // If the mob is in the direction we're looking
						var/mob/living/target = M
						if (istype(target))
							target.apply_flash(60, 8, 0, 0, rand(2, 8), rand(1, 15), 0, 30, 100, stamina_damage = 190, disorient_time = 50)
							logTheThing("combat", user, target, "flashes %target% with an emagged flashlight.")
				user.visible_message("<span style=\"color:red\">The [src] in [user]'s hand bursts with a blinding flash!</span>", "<span style=\"color:red\">The bulb in your hand explodes with a blinding flash!</span>")
				on = 0
				light.disable()
				icon_state = "flightbroken"
				name = "broken flashlight"
				src.broken = 1
			else
				src.light.enable()
		else
			set_icon_state(src.icon_off)
			src.light.disable()

/obj/item/device/light/flashlight/abilities = list(/obj/ability_button/flashlight_toggle)

/obj/item/device/light/glowstick // fuck yeah space rave
	icon = 'icons/obj/lighting.dmi'
	icon_state = "glowstick-off"
	name = "emergency glowstick"
	desc = "For emergency use only. Not for use in illegal lightswitch raves."
	w_class = 2
	flags = ONBELT | TABLEPASS
	var/heated = 0
	col_r = 0.0
	col_g = 0.9
	col_b = 0.1
	brightness = 0.5
	height = 0.75

	proc/burst()
		var/turf/T = get_turf(src.loc)
		make_cleanable( /obj/decal/cleanable/generic,T)
		make_cleanable( /obj/decal/cleanable/greenglow,T)
		qdel(src)

	//Can be heated. Has chance to explode when heated. After heating, can explode when thrown or fussed with!
	attackby(obj/item/W as obj, mob/user as mob)
		if ((istype(W, /obj/item/weldingtool) && W:welding) || istype(W, /obj/item/device/igniter) || ((istype(W, /obj/item/device/light/zippo) || istype(W, /obj/item/match) || istype(W, /obj/item/device/light/candle) || istype(W, /obj/item/clothing/mask/cigarette)) && W:on) || W.burning)
			user.visible_message("<span style=\"color:red\"><b>[user]</b> heats [src] with [W].</span>")
			src.heated += 1
			if (src.heated >= 3 || prob(5 + (heated * 20)))
				user.visible_message("<span style=\"color:red\">[src] bursts open, spraying hot liquid all over <b>[user]</b>! What a [pick("moron", "dummy", "chump", "doofus", "punk", "jerk", "bad idea")]!</span>")
				if (user.reagents)
					user.reagents.add_reagent("radium", 8, null, T0C + heated * 200)
				burst()
		else
			return ..()
	temperature_expose(datum/gas_mixture/air, temperature, volume)
		if((temperature > T0C+400) && on)
			if(iscarbon(src.loc))
				if (src.loc.reagents)
					src.loc.reagents.add_reagent("radium", 5, null, T0C + heated * 200)
			src.visible_message("<span style=\"color:red\">[src] bursts open, spraying hot liquid on [src.loc]!</span>")
			burst()

	throw_impact(atom/A)
		..()
		if (heated > 0 && on && prob(30 + (heated * 20)))
			if(iscarbon(A))
				if (A.reagents)
					A.reagents.add_reagent("radium", 5, null, T0C + heated * 200)
			A.visible_message("<span style=\"color:red\">[src] bursts open, spraying hot liquid on [A]!</span>")
			burst()

	attack_self(mob/user as mob)
		if (!on)
			boutput(user, "<span style=\"color:blue\">You crack [src].</span>")
			on = 1
			icon_state = "glowstick-on"
			playsound(user.loc, "sound/impact_sounds/Generic_Snap_1.ogg", 50, 1)
			light.enable()
		else
			if (prob(10) || (heated > 0 && prob(20 + heated * 20)))
				user.visible_message("<span style=\"color:blue\"><b>[user]</b> breaks [src]! What [pick("a clutz", "a putz", "a chump", "a doofus", "an oaf", "a jerk")]!</span>")
				playsound(user.loc, "sound/impact_sounds/Generic_Snap_1.ogg", 50, 1)
				if (user.reagents)
					if (heated > 0)
						user.reagents.add_reagent("radium", 10, null, T0C + heated * 200)
					else
						user.reagents.add_reagent("radium", 10)
				burst()
			else
				user.visible_message("<span style=\"color:blue\"><b>[user]</b> [pick("fiddles", "faffs around", "goofs around", "fusses", "messes")] with [src].</span>")

/obj/item/device/light/candle
	name = "candle"
	desc = "It's a big candle."
	icon = 'icons/effects/alch.dmi'
	icon_state = "candle-off"
	density = 0
	anchored = 0
	opacity = 0
	icon_off = "candle-off"
	icon_on = "candle"
	col_r = 0.5
	col_g = 0.3
	col_b = 0.0

	attack_self(mob/user as mob)
		if (src.on)
			var/fluff = pick("snuff", "blow")
			user.visible_message("<b>[user]</b> [fluff]s out [src].",\
			"You [fluff] out [src].")
			src.put_out(user)

	attackby(obj/item/W as obj, mob/user as mob)
		if (!src.on)
			if (istype(W, /obj/item/weldingtool) && W:welding)
				src.light(user, "<span style=\"color:red\"><b>[user]</b> casually lights [src] with [W], what a badass.</span>")

			else if (istype(W, /obj/item/clothing/head/cakehat) && W:on)
				src.light(user, "<span style=\"color:red\">Did [user] just light \his [src] with [W]? Holy Shit.</span>")

			else if (istype(W, /obj/item/device/igniter))
				src.light(user, "<span style=\"color:red\"><b>[user]</b> fumbles around with [W]; a small flame erupts from [src].</span>")

			else if (istype(W, /obj/item/device/light/zippo) && W:on)
				src.light(user, "<span style=\"color:red\">With a single flick of their wrist, [user] smoothly lights [src] with [W]. Damn they're cool.</span>")

			else if ((istype(W, /obj/item/match) || istype(W, /obj/item/device/light/candle)) && W:on)
				src.light(user, "<span style=\"color:red\"><b>[user] lights [src] with [W].</span>")

			else if (W.burning)
				src.light(user, "<span style=\"color:red\"><b>[user]</b> lights [src] with [W]. Goddamn.</span>")
		else
			return ..()

	process()
		if (src.on)
			var/turf/location = src.loc
			if (ismob(location))
				var/mob/M = location
				if (M.find_in_hand(src))
					location = M.loc
			var/turf/T = get_turf(src.loc)
			if (T)
				T.hotspot_expose(700,5)

	proc/light(var/mob/user as mob, var/message as text)
		if (!src) return
		if (!src.on)
			src.on = 1
			src.damtype = "fire"
			src.force = 3
			src.icon_state = src.icon_on
			light.enable()
			if (!(src in processing_items))
				processing_items.Add(src)
		return

	proc/put_out(var/mob/user as mob)
		if (!src) return
		if (src.on)
			src.on = 0
			src.damtype = "brute"
			src.force = 0
			src.icon_state = src.icon_off
			light.disable()
			if (src in processing_items)
				processing_items.Remove(src)
		return

/obj/item/device/light/candle/spooky
	name = "spooky candle"
	desc = "It's a big candle. It's also floating."
	anchored = 1

	New()
		..()
		var/spookydegrees = rand(5, 20)

		SPAWN_DBG(rand(1, 10))
			animate(src, pixel_y = 32, transform = matrix(spookydegrees, MATRIX_ROTATE), time = 20, loop = -1, easing = SINE_EASING)
			animate(pixel_y = 0, transform = matrix(spookydegrees * -1, MATRIX_ROTATE), time = 20, loop = -1, easing = SINE_EASING)

/obj/item/device/light/candle/spooky/summon
	New()
		flick("candle-summon", src)
		..()

/obj/item/device/light/candle/haunted
	name = "haunted candle"
	desc = "As opposed to your more standard spooky candle. It smells horrid."
	edible = 1 // eat a haunted goddamn candle every day
	var/did_thing = 0

	New()
		..()

		if (!src.reagents)
			var/datum/reagents/R = new /datum/reagents(50)
			src.reagents = R
			R.my_atom = src

	// yes this is dumb as hell but it makes me laugh a bunch
		src.reagents.add_reagent("wax", 20)
		src.reagents.add_reagent("black_goop", 10)
		src.reagents.add_reagent("yuck", 10)
		src.reagents.add_reagent("ectoplasm", 10)
		return

	light(var/mob/user as mob, var/message as text)
		..()
		if(src.on && !src.did_thing)
			src.did_thing = 1
			//what should it do, other than this sound?? i tried a particle system but it didn't work :{
			playsound(get_turf(src), pick('sound/ambience/station/Station_SpookyAtmosphere1.ogg','sound/ambience/station/Station_SpookyAtmosphere2.ogg'), 65, 0)

		return

/obj/item/device/light/candle/small
	name = "small candle"
	desc = "It's a little candle."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "lil_candle0"
	icon_off = "lil_candle0"
	icon_on = "lil_candle1"
	brightness = 0.8

// lava lamp
/obj/item/device/light/lava_lamp
	name = "lava lamp"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lava_lamp0"
	icon_on = "lava_lamp1"
	icon_off = "lava_lamp0"
	w_class = 4
	desc = "An ancient relic from a simpler, more funky time."
	col_r = 0.85
	col_g = 0.45
	col_b = 0.35
	brightness = 0.8

	attack_self(mob/user as mob)
		playsound(get_turf(src), "sound/items/penclick.ogg", 30, 1)
		user.visible_message("<b>[user]</b> flicks [src.on ? "on" : "off"] the [src].")
		src.on = !src.on
		if (src.on)
			set_icon_state(src.icon_on)
			src.light.enable()
		else
			set_icon_state(src.icon_off)
			src.light.disable()
