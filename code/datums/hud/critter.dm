// Highly modular HUD for critters.
/datum/hud/critter
	var/list/hands = list()
	var/list/equipment = list()
	var/obj/screen/hud/health
	var/obj/screen/hud/oxygen
	var/obj/screen/hud/fire
	var/obj/screen/hud/intent
	var/obj/screen/hud/mintent
	var/obj/screen/hud/throwing
	var/obj/screen/hud/pulling
	var/mob/living/critter/master
	var/icon/icon_hud = 'icons/mob/hud_human.dmi'
	var/list/statusUiElements = list() //Assoc. List  STATUS EFFECT INSTANCE : UI ELEMENT add_screen(obj/screen/S). Used to hold the ui elements since they shouldnt be on the status effects themselves.

	var/nr = 0
	var/nl = 0
	var/rl = 0
	var/rr = 0
	var/tre = 0

	New(M)
		master = M

		var/hand_s = -round((master.hands.len - 1) / 2)
		nl = hand_s - 1
		for (var/i = 1, i <= master.hands.len, i++)
			var/curr = hand_s + i - 1
			var/datum/handHolder/HH = master.hands[i]
			var/SL = "CENTER[curr < 0 ? curr : (curr > 0 ? "+[curr]" : null)],SOUTH"
			var/obj/screen/hud/H = create_screen("hand[i]", HH.name, HH.icon, "[HH.icon_state][i == master.active_hand ? 1 : 0]", SL, HUD_LAYER+1)
			HH.screenObj = H
			hands += H
		nr = hand_s + master.hands.len
		health = create_screen("health", "health", src.icon_hud, "health0", "EAST[next_topright()],NORTH", HUD_LAYER+1)
		if (master.get_health_holder("oxy"))
			oxygen = create_screen("oxygen", "Suffocation Warning", src.icon_hud, "oxy0", "EAST[next_topright()], NORTH", HUD_LAYER)
			fire = create_screen("fire","Fire Warning", src.icon_hud, "fire0", "EAST[next_topright()], NORTH", HUD_LAYER)

		if (master.can_throw)
			throwing = create_screen("throw", "throw mode", src.icon_hud, "throw0", "CENTER+[nr], SOUTH", HUD_LAYER+1)
			nr++

		intent = create_screen("intent", "action intent", src.icon_hud, "intent-help", "CENTER+[nr],SOUTH", HUD_LAYER+1)
		nr++
		pulling = create_screen("pull", "pulling", 'icons/mob/critter_ui.dmi', "pull0", "CENTER+[nr], SOUTH", HUD_LAYER+1)
		mintent = create_screen("mintent", "movement mode", 'icons/mob/critter_ui.dmi', "move-run", "CENTER+[nr], SOUTH", HUD_LAYER+1)
		nr++

		for (var/i = 1, i <= master.equipment.len, i++)
			var/datum/equipmentHolder/EH = master.equipment[i]
			var/SL = loc_left()
			var/obj/screen/hud/H = create_screen("equipment[i]", EH.name, EH.icon, EH.icon_state, SL, HUD_LAYER+1)
			EH.screenObj = H
			equipment += EH
			if (EH.item)
				add_object(EH.item)

	clear_master()
		master = null
		..()

	proc/loc_left()
		if (nl < -6)
			rl++
			nl = rr < rl ? 0 : -1
		var/e = nl
		nl--
		var/col = "CENTER[e < 0 ? e : (e > 0 ? "+[e]" : null)]"
		var/row = "SOUTH[rl > 0 ? "+[rl]" : null]"
		return "[col],[row]"

	proc/loc_right()
		if (nr > 6)
			rr++
			nr = rl < rr ? 0 : 1
		var/e = nr
		nr++
		var/col = "CENTER[e < 0 ? e : (e > 0 ? "+[e]" : null)]"
		var/row = "SOUTH[rr > 0 ? "+[rr]" : null]"
		return "[col],[row]"

	proc/next_right()
		nr += 1
		return "+[nr - 1]"

	proc/next_left()
		nl -= 1
		return nl + 1

	proc/next_topright()
		tre -= 1
		return tre + 1 == 0 ? "" : tre

	proc/set_suffocating(var/status)
		if (!oxygen)
			return
		oxygen.icon_state = "oxy[status]"

	proc/set_breathing_fire(var/status)
		if (!fire)
			return
		fire.icon_state = "fire[status]"

	proc/update_hands()
		for (var/i = 1, i <= master.hands.len, i++)
			var/datum/handHolder/HH = master.hands[i]
			var/obj/screen/hud/H = HH.screenObj
			if (master.active_hand == i)
				H.icon_state = "[HH.icon_state]1"
			else
				H.icon_state = "[HH.icon_state]0"

	proc/update_throwing()
		if (!master.can_throw || !throwing)
			return
		throwing.icon_state = "throw[master.in_throw_mode]"

	clicked(id, mob/user, list/params)
		if (copytext(id, 1, 5) == "hand")
			var/handid = text2num(copytext(id, 5))
			master.active_hand = handid
			master.hand = handid
			update_hands()
		else if (copytext(id, 1, 10) == "equipment")
			var/eid = text2num(copytext(id, 10))
			master.equip_click(master.equipment[eid])
		else
			switch(id)
				if ("oxygen")
					boutput(master, "<span style=\"color:red\">This indicator warns that you are currently suffocating. You will take oxygen damage until the situation is remedied.</span>")

				if ("intent")
					var/icon_x = text2num(params["icon-x"])
					var/icon_y = text2num(params["icon-y"])
					if (icon_x > 16)
						if (icon_y > 16)
							master.a_intent = INTENT_DISARM
						else
							master.a_intent = INTENT_HARM
					else
						if (icon_y > 16)
							master.a_intent = INTENT_HELP
						else
							master.a_intent = INTENT_GRAB
					src.update_intent()

				if ("mintent")
					if (master.m_intent == "run")
						master.m_intent = "walk"
					else
						master.m_intent = "run"
					out(master, "You are now [master.m_intent == "walk" ? "walking" : "running"]")
					src.update_mintent()

				if ("pull")
					master.pulling = null
					src.update_pulling()

				if ("throw")
					var/icon_y = text2num(params["icon-y"])
					if (icon_y > 16 || master.in_throw_mode)
						master.toggle_throw_mode()
					else
						master.drop_item()

				if ("health")
					boutput(master, "<span style='color:blue'>Your health: [master.health]/[master.max_health]</span>")

	proc/update_health()
		if (!isdead(master))
			if (!health) //Runtime fix: Cannot modify null.icon_state
				return
			var/h_ratio = master.health / master.max_health * 100
			switch(h_ratio)
				if(90 to INFINITY)
					health.icon_state = "health0" // green with green marker
				if(75 to 90)
					health.icon_state = "health1" // green
				if(60 to 75)
					health.icon_state = "health2" // yellow
				if(45 to 60)
					health.icon_state = "health3" // orange
				if(20 to 45)
					health.icon_state = "health4" // dark orange
				if(10 to 20)
					health.icon_state = "health5" // red
				else
					health.icon_state = "health6" // crit
		else
			health.icon_state = "health7"         // dead

	proc/update_intent()
		intent.icon_state = "intent-[master.a_intent]"

	proc/update_mintent()
		if (!mintent) return 0
		mintent.icon_state = "move-[master.m_intent]"

	proc/update_pulling()
		if (!pulling) return 0
		pulling.icon_state = "pull[!!master.pulling]"

	proc/update_status_effects()
		for(var/obj/screen/statusEffect/G in src.objects)
			remove_screen(G)

		for(var/datum/statusEffect/S in src.statusUiElements) //Remove stray effects.
			if(!master.statusEffects || !(S in master.statusEffects) || !S.visible)
				pool(statusUiElements[S])
				src.statusUiElements.Remove(S)
				qdel(S)

		var/spacing = 0.6
		var/pos_x = spacing - 0.2 - 1

		if(master.statusEffects)
			for(var/datum/statusEffect/S in master.statusEffects) //Add new ones, update old ones.
				if(!S.visible) continue
				if((S in statusUiElements) && statusUiElements[S])
					var/obj/screen/statusEffect/U = statusUiElements[S]
					U.icon = icon_hud
					U.screen_loc = "EAST[pos_x < 0 ? "":"+"][pos_x],NORTH+0.3"
					U.update_value()
					add_screen(U)
					pos_x -= spacing
				else
					if(S.visible)
						var/obj/screen/statusEffect/U = new/obj/screen/statusEffect(master, S)
						U.init(master,S)
						U.icon = icon_hud
						statusUiElements.Add(S)
						statusUiElements[S] = U
						U.screen_loc = "EAST[pos_x < 0 ? "":"+"][pos_x],NORTH+0.3"
						U.update_value()
						add_screen(U)
						pos_x -= spacing
						animate_buff_in(U)
		return

/mob/living/critter/updateStatusUi()
	if(src.hud && istype(src.hud, /datum/hud/critter))
		var/datum/hud/critter/H = src.hud
		H.update_status_effects()
	return