
/proc/scan_health(var/mob/M as mob, var/verbose_reagent_info = 0, var/disease_detection = 1, var/organ_scan = 0)
	if (!M)
		return "<span style='color:red'>ERROR: NO SUBJECT DETECTED</span>"

	if (isghostdrone(M))
		return "<span style='color:red'>ERROR: INVALID DATA FROM SUBJECT</span>"

	var/death_state = M.stat
	if (M.bioHolder && M.bioHolder.HasEffect("dead_scan"))
		death_state = 2

	var/health_percent = round(100 * M.health / M.max_health)

	var/colored_health
	if (health_percent >= 51 && health_percent <= 100)
		colored_health = "<span style='color:#138015'>[health_percent]</span>"
	else if (health_percent >= 1 && health_percent <= 50)
		colored_health = "<span style='color:#CC7A1D'>[health_percent]</span>"
	else colored_health = "<span style='color:red'>[health_percent]</span>"

	var/optimal_temp = M.base_body_temp
	var/body_temp = "[M.bodytemperature - T0C]&deg;C ([M.bodytemperature * 1.8-459.67]&deg;F)"
	var/colored_temp = ""
	if (M.bodytemperature >= (optimal_temp + 60))
		colored_temp = "<span style='color:red'>[body_temp]</span>"
	else if (M.bodytemperature >= (optimal_temp + 30))
		colored_temp = "<span style='color:#CC7A1D'>[body_temp]</span>"
	else if (M.bodytemperature <= (optimal_temp - 60))
		colored_temp = "<span style='color:blue'>[body_temp]</span>"
	else if (M.bodytemperature <= (optimal_temp - 30))
		colored_temp = "<span style='color:#1F75D1'>[body_temp]</span>"
	else
		colored_temp = "[body_temp]"

	var/oxy = M.get_oxygen_deprivation()
	var/tox = M.get_toxin_damage()
	var/burn = M.get_burn_damage()
	var/brute = M.get_brute_damage()

	// contained here in order to change them easier
	var/oxy_font = "<span style='color:#1F75D1'>"
	var/tox_font = "<span style='color:#138015'>"
	var/burn_font = "<span style='color:#CC7A1D'>"
	var/brute_font = "<span style='color:#E60E4E'>"

	var/oxy_data = "[oxy > 50 ? "<span style='color:red'>" : "[oxy_font]"][oxy]</span>"
	var/tox_data = "[tox > 50 ? "<span style='color:red'>" : "[tox_font]"][tox]</span>"
	var/burn_data = "[burn > 50 ? "<span style='color:red'>" : "[burn_font]"][burn]</span>"
	var/brute_data = "[brute > 50 ? "<span style='color:red'>" : "[brute_font]"][brute]</span>"

	var/rad_data = null
	var/nrad_data = null
	var/blood_data = null
	var/brain_data = null
	// var/heart_data = null		//Moving this to organ_data for now. -kyle
	var/reagent_data = null
	var/pathogen_data = null
	var/disease_data = null
	var/organ_data = null
	var/interesting_data = null

	if (ishuman(M))
		var/mob/living/carbon/human/H = M

		if (blood_system)
			H.ensure_bp_list()
			var/bp_col
			switch (H.blood_pressure["total"])
				if (-INFINITY to 374) // very low (90/60)
					bp_col = "red"
				if (375 to 414) // low (100/65)
					bp_col = "#CC7A1D"
				if (415 to 584) // normal (120/80)
					bp_col = "#138015"
				if (585 to 665) // high (140/90)
					bp_col = "#CC7A1D"
				if (666 to INFINITY) // very high (160/100)
					bp_col = "red"
			if (isdead(H))
				blood_data = "Blood Pressure: <span style='color:red'>NO PULSE</span>"
			else
				blood_data = "Blood Pressure: <span style='color:[bp_col]'>[H.blood_pressure["rendered"]] ([H.blood_pressure["status"]])</span>"
			if (verbose_reagent_info)
				if (isvampire(H)) // Added a pair of vampire checks here (Convair880).
					blood_data += " | Blood level: <span style='color:#138015'>500 units</span>"
				else
					blood_data += " | Blood level: <span style='color:[bp_col]'>[H.blood_pressure["total"]] unit[s_es(H.blood_pressure["total"])]</span>"
					if (H.bleeding)
						blood_data += " | Blood loss: <span style='color:red'>[H.bleeding] unit[s_es(H.bleeding)]</span>"
			else if (!isvampire(H))
				switch (H.bleeding)
					if (1 to 3)
						blood_data += " | <span style='color:red'><B>Minor bleeding wounds detected</B></span>"
					if (4 to 6)
						blood_data += " | <span style='color:red'><B>Bleeding wounds detected</B></span>"
					if (7 to INFINITY)
						blood_data += " | <span style='color:red'><B>Major bleeding wounds detected</B></span>"
			if ((H.implant && H.implant.len > 0) || H.chest_item != null)
				var/bad_stuff = 0
				for (var/obj/item/implant/I in H)
					if (istype(I, /obj/item/implant/projectile))
						bad_stuff ++
				if(H.chest_item != null) // If item is in chest, add one
					bad_stuff ++
				if (bad_stuff)
					blood_data += " | <span style='color:red'><B>Foreign object[s_es(bad_stuff)] detected</B></span>"
				if(H.chest_item != null) // State that large foreign object is located in chest
					blood_data += " | <span style=\"color:red\"><B>Sizable foreign object located below sternum</B></span>"

		if (H.pathogens.len)
			pathogen_data = "<span style='color:red'>Scans indicate the presence of [H.pathogens.len > 1 ? "[H.pathogens.len] " : null]pathogenic bodies.</span>"
			var/list/therapy = list()
			var/remissive = 0
			for (var/uid in H.pathogens)
				var/datum/pathogen/P = H.pathogens[uid]
				if (P.in_remission)
					remissive ++
				if (!(P.suppressant.therapy in therapy))
					therapy += P.suppressant.therapy
			var/count_part
			if (!remissive)
				count_part = "None of them appear"
			else if (remissive == 1)
				count_part = "One pathogen appears"
			else
				count_part = "[remissive] of them appear"
			pathogen_data += "<br>&emsp;<span style='color:red'>[count_part] to be in a remissive state.</span>"
			pathogen_data += "<br><span style='font-weight:bold'>Suggested pathogen suppression therapies: [jointext(therapy, ", ")]."

		if (H.get_organ("brain"))
			if (H.get_brain_damage() >= 100)
				brain_data = "<span style='color:red'>Subject is braindead.</span>"
			else if (H.get_brain_damage() >= 60)
				brain_data = "<span style='color:red'>Severe brain damage detected. Subject likely unable to function well.</span>"
			else if (H.get_brain_damage() >= 10)
				brain_data = "<span style='color:red'>Significant brain damage detected. Subject may have had a concussion.</span>"
		else
			brain_data = "<span style='color:red'>Subject has no brain.</span>"

		// if (!H.get_organ("heart"))
		// 	heart_data = "<span style='color:red'>Subject has no heart.</span>"
		if (organ_scan)
			var/organ_data1 = null
			var/obfuscate = (disease_detection != 255 ? 1 : 0)		//this is so admin check_health verb see exact numbs, scanners don't. Can remove, not exactly necessary, but thought they might want it.

			organ_data1 += organ_health_scan("heart", H, obfuscate)
			// organ_data1 += organ_health_scan("brain", H, obfuscate) //Might want, might not. will be slightly more accurate than current brain damage scan

			organ_data1 += organ_health_scan("left_lung", H, obfuscate)
			organ_data1 += organ_health_scan("right_lung", H, obfuscate)

			organ_data1 += organ_health_scan("left_kidney", H, obfuscate)
			organ_data1 += organ_health_scan("right_kidney", H, obfuscate)
			organ_data1 += organ_health_scan("liver", H, obfuscate)
			organ_data1 += organ_health_scan("stomach", H, obfuscate)
			organ_data1 += organ_health_scan("intestines", H, obfuscate)
			organ_data1 += organ_health_scan("spleen", H, obfuscate)
			organ_data1 += organ_health_scan("pancreas", H, obfuscate)
			organ_data1 += organ_health_scan("appendix", H, obfuscate)

			//Don't give organ readings for Vamps.
			if (organ_data1 && !isvampire(H))
				organ_data = "<span style='color:purple'><b>Internal Injuries:</b></span>"
				organ_data += organ_data1
			else
				organ_data = "<span style='color:purple'><b>Scans indicate organs are in perfect health.</b></span>"
			//Joke in case there is no organHolder
			if (!H.organHolder)
				organ_data = "<span style='color:red'>Subject has no organs. Veeeerrrry curious.</span>"


	var/datum/statusEffect/simpledot/radiation/R = M.hasStatus("radiation")
	var/datum/statusEffect/simpledot/radiation/NR = M.hasStatus("n_radiation")
	if (R)
		rad_data = "&emsp;<span style='color:red'>Radiation poisoning: Lv [R.stage]</span>"
	if (NR)
		nrad_data = "&emsp;<span style='color:blue'>Neutron Radiation poisoning: Lv [NR.stage]</span>"
	for (var/datum/ailment_data/A in M.ailments)
		if (disease_detection >= A.detectability)
			disease_data += "<br>[A.scan_info()]"

	if (M.reagents)
		if (verbose_reagent_info)
			reagent_data = scan_reagents(M, 0)
		else
			var/ephe_amt = M.reagents:get_reagent_amount("ephedrine")
			var/epi_amt = M.reagents:get_reagent_amount("epinephrine")
			var/atro_amt = M.reagents:get_reagent_amount("atropine")
			var/total_amt = ephe_amt + epi_amt + atro_amt
			if (total_amt)
				reagent_data = "<span style='color:blue'>Bloodstream Analysis located [total_amt] units of rejuvenation chemicals.</span>"

	if (!ishuman(M)) // vOv
		if (M.get_brain_damage() >= 100)
			brain_data = "<span style='color:red'>Subject is braindead.</span>"
		else if (M.get_brain_damage() >= 60)
			brain_data = "<span style='color:red'>Severe brain damage detected. Subject likely unable to function well.</span>"
		else if (M.get_brain_damage() >= 10)
			brain_data = "<span style='color:red'>Significant brain damage detected. Subject may have had a concussion.</span>"

	if (M.interesting)
		interesting_data += "<br><span style='color:blue'>[M.interesting]</span>"

	var/data = "--------------------------------<br>\
	Analyzing Results for <span style='color:blue'>[M]</span>:<br>\
	&emsp; Overall Status: [death_state > 1 ? "<span style='color:red'>DEAD</span>" : "[colored_health]% healthy"]<br>\
	&emsp; Damage Specifics: [oxy_data] - [tox_data] - [burn_data] - [brute_data]<br>\
	&emsp; Key: [oxy_font]Suffocation</span>/[tox_font]Toxin</span>/[burn_font]Burns</span>/[brute_font]Brute</span><br>\
	Body Temperature: [colored_temp]\
	[rad_data ? "<br>[rad_data]" : null]\
	[nrad_data ? "<br>[nrad_data]" : null]\
	[blood_data ? "<br>[blood_data]" : null]\
	[brain_data ? "<br>[brain_data]" : null]\
	[organ_data ? "<br>[organ_data]" : null]\
	[reagent_data ? "<br>[reagent_data]" : null]\
	[pathogen_data ? "<br>[pathogen_data]" : null]\
	[disease_data ? "[disease_data]" : null]\
	[interesting_data ? "<br><i>Historical analysis:</i><span style='color:blue'> [interesting_data]</span>" : null]\
	"

	return data

	//KYLE-NOTE- Maybe use get_organ here. Didn't exist in 2016 when I wrote this.
//takes string input, for name in organholder.organ_list and checks if the organholder has anything
//obfuscate, if true then don't show the exact organ health amount. Minor damage, moderate damage, severe damage, critical damage
/proc/organ_health_scan(var/input, var/mob/living/carbon/human/H, var/obfuscate = 0)
	var/obj/item/organ/O = H.organHolder.organ_list[input]
	if (istype(O))
		var/damage = O.get_damage()
		if (obfuscate)
			return obfuscate_organ_health(O)
		else
			if (damage > 0)
				return "<br><span style='color:[damage >= 65 ? "red" : "purple"]'><b>[input]</b> - [O.get_damage()]</span>"
			else
				return null

	else
		return "<br><span style='color:purple'><b>[input]</b> - missing!</span>"

//Using input here because it get's the organs name in an easy and clear way. using name or organ_name in obj/item/organ is not any better really
/proc/obfuscate_organ_health(var/obj/item/organ/O)
	if (!O)
		return null
	var/damage = O.get_damage()

	if (damage >= O.MAX_DAMAGE)
		return "<br><span style='color:red'><b>[O.name]</b> - Dead</span>"
	else if (damage >= O.MAX_DAMAGE*0.9)
		return "<br><span style='color:red'><b>[O.name]</b> - Critical</span>"
	else if (damage >= O.MAX_DAMAGE*0.65)
		return "<br><span style='color:red'><b>[O.name]</b> - Significant</span>"
	else if (damage >= O.MAX_DAMAGE*0.30)
		return "<br><span style='color:purple'><b>[O.name]</b> - Moderate</span>"
	else if (damage > 0)
		return "<br><span style='color:purple'><b>[O.name]</b> - Minor</span>"

	return null

/proc/update_medical_record(var/mob/living/carbon/human/M)
	if (!M || !ishuman(M))
		return

	var/patientname = M.name
	if (M:wear_id && M:wear_id:registered)
		patientname = M.wear_id:registered

	for (var/datum/data/record/E in data_core.general)
		if (E.fields["name"] == patientname)
			switch (M.stat)
				if (0)
					if (M.bioHolder && M.bioHolder.HasEffect("fat"))
						E.fields["p_stat"] = "Physically Unfit"
					else
						E.fields["p_stat"] = "Active"
				if (1)
					E.fields["p_stat"] = "*Unconscious*"
				if (2)
					E.fields["p_stat"] = "*Deceased*"
			for (var/datum/data/record/R in data_core.medical)
				if ((R.fields["id"] == E.fields["id"]))
					R.fields["bioHolder.bloodType"] = M.bioHolder.bloodType
					R.fields["cdi"] = english_list(M.ailments, "No diseases have been diagnosed at the moment.")
					if (M.ailments.len)
						R.fields["cdi_d"] = "Diseases detected at [time2text(world.realtime,"hh:mm")]."
					else
						R.fields["cdi_d"] = "No notes."
					break
			break
	return

/proc/scan_reagents(var/atom/A as turf|obj|mob, var/show_temp = 1, var/single_line = 0)
	if (!A)
		return "<span style='color:red'>ERROR: NO SUBJECT DETECTED</span>"

	var/data = null
	var/reagent_data = null

	if (A.reagents)
		if (A.reagents.reagent_list.len > 0)
			var/reagents_length = A.reagents.reagent_list.len
			data = "<span style='color:blue'>[reagents_length] chemical agent[reagents_length > 1 ? "s" : ""] found in [A].</span>"

			for (var/current_id in A.reagents.reagent_list)
				var/datum/reagent/current_reagent = A.reagents.reagent_list[current_id]
				if (single_line)
					reagent_data += " [current_reagent] ([current_reagent.volume]),"
				else
					reagent_data += "<br>&emsp;[current_reagent.name] - [current_reagent.volume]"

			if (single_line)
				data += "<span style='color:blue'>[copytext(reagent_data, 1, -1)]</span>"
			else
				data += "<span style='color:blue'>[reagent_data]</span>"

			if (show_temp)
				data += "<br><span style='color:blue'>Overall temperature: [A.reagents.total_temperature - T0C]&deg;C ([A.reagents.total_temperature * 1.8-459.67]&deg;F)</span>"
		else
			data = "<span style='color:blue'>No active chemical agents found in [A].</span>"
	else
		data = "<span style='color:blue'>No significant chemical agents found in [A].</span>"

	return data

// Should make it easier to maintain the detective's scanner and PDA program (Convair880).
/proc/scan_forensic(var/atom/A as turf|obj|mob)
	if (istype(A, /obj/ability_button)) // STOP THAT
		return
	var/fingerprint_data = null
	var/blood_data = null
	var/forensic_data = null
	var/glove_data = null
	var/contraband_data = null
	var/interesting_data = null

	if (!A)
		return "<span style='color:red'>ERROR: NO SUBJECT DETECTED</span>"

	if (ishuman(A))
		var/mob/living/carbon/human/H = A

		if (!isnull(H.gloves))
			var/obj/item/clothing/gloves/WG = H.gloves
			if (WG.glove_ID)
				glove_data += "[WG.glove_ID] (<span style='color:blue'>[H]'s worn [WG.name]</span>)"
			if (!WG.hide_prints)
				fingerprint_data += "<br><span style='color:blue'>[H]'s fingerprints:</span> [md5(H.bioHolder.Uid)]"
			else
				fingerprint_data += "<br><span style='color:blue'>Unable to scan [H]'s fingerprints.</span>"
		else
			fingerprint_data += "<br><span style='color:blue'>[H]'s fingerprints:</span> [md5(H.bioHolder.Uid)]"

		if (H.gunshot_residue) // Left by firing a kinetic gun.
			forensic_data += "<br><span style='color:blue'>Gunshot residue found.</span>"

		if (H.implant && H.implant.len > 0)
			var/wounds = null
			for (var/obj/item/implant/I in H)
				if (istype(I, /obj/item/implant/projectile))
					wounds ++
			if (wounds)
				forensic_data += "<br><span style='color:blue'>[wounds] gunshot [wounds == 1 ? "wound" : "wounds"] detected.</span>"

		if (H.fingerprints) // Left by grabbing or pulling people.
			var/list/FFP = params2list(H:fingerprints)
			for(var/i in FFP)
				fingerprint_data += "<br><span style='color:blue'>Foreign fingerprint on [H]:</span> [i]"

		if (H.bioHolder.Uid) // For quick reference. Also, attacking somebody only makes their clothes bloody, not the mob (think naked dudes).
			blood_data += "<br><span style='color:blue'>[H]'s blood DNA:</span> [H.bioHolder.Uid]"

		if (H.blood_DNA && isnull(H.gloves)) // Don't magically detect blood through worn gloves.
			var/list/BH = params2list(H:blood_DNA)
			for(var/i in BH)
				blood_data += "<br><span style='color:blue'>Blood on [H]'s hands:</span> [i]"

		var/list/gear_to_check = list(H.head, H.wear_mask, H.w_uniform, H.wear_suit, H.belt, H.gloves, H.back)
		for (var/obj/item/check in gear_to_check)
			if (check)
				var/list/BC
				if (check.blood_DNA)
					BC = params2list(check.blood_DNA)
					for(var/i in BC)
						blood_data += "<br><span style='color:blue'>Blood on worn [check.name]:</span> [i]"
				/*var/trace_blood = check.get_forensic_trace("bDNA")
				if (trace_blood)
					BC = params2list(trace_blood)
					for (var/i in BC)
						blood_data += "<br><span style='color:blue'>Blood trace on worn [check.name]:</span> [i]"
				*/

		if (H.r_hand && H.r_hand.blood_DNA)
			var/list/BIR = params2list(H.r_hand.blood_DNA)
			for(var/i in BIR)
				blood_data += "<br><span style='color:blue'>Blood on held [H.r_hand.name]:</span> [i]"

		if (H.l_hand && H.l_hand.blood_DNA)
			var/list/BIL = params2list(H.l_hand.blood_DNA)
			for(var/i in BIL)
				blood_data += "<br><span style='color:blue'>Blood on held [H.l_hand.name]:</span> [i]"

	else

		if (istype(A, /obj/item/parts/human_parts))
			var/obj/item/parts/human_parts/H = A
			if (H.original_DNA)
				blood_data += "<br><span style='color:blue'>[H]'s blood DNA:</span> [H.original_DNA]"
			if (istype(H, /obj/item/parts/human_parts/arm)) // has fringerpints
				fingerprint_data += "<br><span style='color:blue'>[H]'s fingerprints:</span> [H.original_fprints]"

		else if (istype(A, /obj/item/organ))
			var/obj/item/organ/O = A
			if (O.donor_DNA)
				blood_data += "<br><span style='color:blue'>[O]'s blood DNA:</span> [O.donor_DNA]"

		else if (istype(A, /obj/item/clothing/head/butt))
			var/obj/item/clothing/head/butt/B = A
			if (B.donor_DNA)
				blood_data += "<br><span style='color:blue'>[B]'s blood DNA:</span> [B.donor_DNA]"

		else if (isobj(A) && A.reagents && A.is_open_container() && A.reagents.has_reagent("blood"))
			var/datum/reagent/blood/B = A.reagents.reagent_list["blood"]
			if (B && istype(B.data, /datum/bioHolder))
				var/datum/bioHolder/BH = B.data
				if (BH.Uid)
					blood_data += "<br><span style='color:blue'>Blood DNA inside [A]:</span> [BH.Uid]"

		if (A.interesting)
			if (istype(A, /obj))
				interesting_data += "<br><span style='color:blue'>[A.interesting]</span>"
			if (istype(A, /turf))
				interesting_data += "<br><span style='color:blue'>There seems to be more to [A] than meets the eye.</span>"

//		if (!A.fingerprints)
			/*var/list/FP = params2list(A.get_forensic_trace("fprints"))
			if (FP)
				for (var/i in FP)
					fingerprint_data += "<br><span style='color:blue'>[i]</span>"
			else
				*///fingerprint_data += "<br><span style='color:blue'>Unable to locate any fingerprints.</span>"
//		else
		if (A.fingerprints)
			var/list/FP = params2list(A:fingerprints)
			for(var/i in FP)
				fingerprint_data += "<br><span style='color:blue'>[i]</span>"

//		if (!A.blood_DNA)
			/*var/list/DNA = params2list(A.get_forensic_trace("bDNA"))
			if (DNA)
				for (var/i in DNA)
					blood_data += "<br><span style='color:blue'>[i]</span>"
			else
				*///blood_data += "<br><span style='color:blue'>Unable to locate any blood traces.</span>"
//		else
		if (A.blood_DNA)
			var/list/DNA = params2list(A:blood_DNA)
			for(var/i in DNA)
				blood_data += "<br><span style='color:blue'>[i]</span>"

		if (isitem(A))
			var/obj/item/I = A
			if(I.contraband)
				contraband_data = "<span style='color:red'>(CONTRABAND: LEVEL [I.contraband])</span>"

		if (istype(A, /obj/item/clothing/gloves))
			var/obj/item/clothing/gloves/G = A
			if (G.glove_ID)
				glove_data += "[G.glove_ID] [G.material_prints ? "([G.material_prints])" : null]"

		if (istype(A, /obj/item/casing/))
			var/obj/item/casing/C = A
			if(C.forensic_ID)
				forensic_data += "<br><span style='color:blue'>Forensic profile of [C]:</span> [C.forensic_ID]"

		if (istype(A, /obj/item/implant/projectile))
			var/obj/item/implant/projectile/P = A
			if(P.forensic_ID)
				forensic_data += "<br><span style='color:blue'>Forensic profile of [P]:</span> [P.forensic_ID]"

		if (istype(A, /obj/item/gun))
			var/obj/item/gun/G = A
			if(G.forensic_ID)
				forensic_data += "<br><span style='color:blue'>Forensic profile of [G]:</span> [G.forensic_ID]"

		if (istype(A, /turf/simulated/wall))
			var/turf/simulated/wall/W = A
			if (W.forensic_impacts && islist(W.forensic_impacts) && W.forensic_impacts.len)
				for(var/i in W.forensic_impacts)
					forensic_data += "<br><span style='color:blue'>Forensic signature found:</span> [i]"

	if (!fingerprint_data) // Just in case, we'd always want to have a readout for these.
		fingerprint_data = "<br><span style='color:blue'>Unable to locate any fingerprints.</span>"

	if (!blood_data)
		blood_data = "<br><span style='color:blue'>Unable to locate any blood traces.</span>"

	// This was the least enjoyable part of the entire exercise. Formatting is nothing but a chore.
	var/data = "--------------------------------<br>\
	<span style='color:blue'>Forensic analysis of <b>[A]</b></span> [contraband_data ? "[contraband_data]" : null]<br>\
	<br>\
	<i>Isolated fingerprints:</i>[fingerprint_data]<br>\
	<br>\
	<i>Isolated blood samples:</i>[blood_data]<br>\
	[forensic_data ? "<br><i>Additional forensic data:</i>[forensic_data]<br>" : null]\
	[glove_data ? "<br><i>Material analysis:</i><span style='color:blue'> [glove_data]</span>" : null]\
	[interesting_data ? "<br><i>Energy signature analysis:</i><span style='color:blue'> [interesting_data]</span>" : null]\
	"

	return data

// Made this a global proc instead of 10 or so instances of duplicate code spread across the codebase (Convair880).
/proc/scan_atmospheric(var/atom/A as turf|obj, var/pda_readout = 0, var/simple_output = 0)
	if (!A)
		if (pda_readout == 1)
			return "Unable to obtain a reading."
		else if (simple_output == 1)
			return "(<b>Error:</b> <i>no source provided</i>)"
		else
			return "<span style='color:red'>Unable to obtain a reading.</span>"

	var/datum/gas_mixture/check_me = null
	var/pressure = null
	var/total_moles = null

	if (hasvar(A, "air_contents"))
		check_me = A:air_contents // Not pretty, but should be okay here.
	if (isturf(A))
		check_me = A.return_air()
	if (istype(A, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/P = A
		check_me = P.parent.air
	if (istype(A, /obj/item/assembly/time_bomb))
		var/obj/item/assembly/time_bomb/TB = A
		if (TB.part3)
			check_me = TB.part3.air_contents
	if (istype(A, /obj/item/assembly/radio_bomb))
		var/obj/item/assembly/radio_bomb/RB = A
		if (RB.part3)
			check_me = RB.part3.air_contents
	if (istype(A, /obj/item/assembly/proximity_bomb))
		var/obj/item/assembly/proximity_bomb/PB = A
		if (PB.part3)
			check_me = PB.part3.air_contents
	if (istype(A, /obj/item/flamethrower/))
		var/obj/item/flamethrower/FT = A
		if (FT.part4)
			check_me = FT.part4.air_contents

	if (!check_me || !istype(check_me, /datum/gas_mixture/))
		if (pda_readout == 1)
			return "[A] does not contain any gas."
		else if (simple_output == 1)
			return "(<i>[A] has no gas holder</i>)"
		else
			return "<span style='color:red'>[A] does not contain any gas.</span>"

	pressure = check_me.return_pressure()
	total_moles = check_me.total_moles()

	//DEBUG_MESSAGE("[A] contains: [pressure] kPa, [total_moles] moles.")

	var/data = ""

	if (total_moles > 0)
		var/o2_concentration = check_me.oxygen/total_moles
		var/n2_concentration = check_me.nitrogen/total_moles
		var/co2_concentration = check_me.carbon_dioxide/total_moles
		var/plasma_concentration = check_me.toxins/total_moles
		var/unknown_concentration = 1 - (o2_concentration + n2_concentration + co2_concentration + plasma_concentration)

		if (pda_readout == 1) // Output goes into PDA interface, not the user's chatbox.
			data = "Air Pressure: [round(pressure, 0.1)] kPa<br>\
			Nitrogen: [round(n2_concentration * 100)]%<br>\
			Oxygen: [round(o2_concentration * 100)]%<br>\
			CO2: [round(co2_concentration * 100)]%<br>\
			Plasma: [round(plasma_concentration * 100)]%<br>\
			[unknown_concentration > 0.01 ? "Unknown: [round(unknown_concentration * 100)]%<br>" : ""]\
			Temperature: [round(check_me.temperature - T0C)]&deg;C<br>"

		else if (simple_output == 1) // For the log_atmos() proc.
			data = "(<b>Pressure:</b> <i>[round(pressure, 0.1)] kPa</i>, <b>Temp:</b> <i>[round(check_me.temperature - T0C)]&deg;C</i>\
			, <b>Contents:</b> <i>[round(n2_concentration * 100)]% N2 / [round(o2_concentration * 100)]% O2 / [round(co2_concentration * 100)]% CO2 / [round(plasma_concentration * 100)]% PL</i>\
			  [unknown_concentration > 0.01 ? "<i> / [round(unknown_concentration * 100)]% other</i>)" : ")"]"

		else
			data = "--------------------------------<br>\
			<span style='color:blue'>Atmospheric analysis of <b>[A]</b></span><br>\
			<br>\
			Pressure: [round(pressure, 0.1)] kPa<br>\
			Nitrogen: [round(n2_concentration * 100)]%<br>\
			Oxygen: [round(o2_concentration * 100)]%<br>\
			CO2: [round(co2_concentration * 100)]%<br>\
			Plasma: [round(plasma_concentration * 100)]%<br>\
			[unknown_concentration > 0.01 ? "</span><span style='color:red'>Unknown: [round(unknown_concentration * 100)]%</span><span style='color:blue'><br>" : ""]\
			Temperature: [round(check_me.temperature - T0C)]&deg;C<br>"

	else
		// Only used for "Atmospheric Scan" accessible through the PDA interface, which targets the turf
		// the PDA user is standing on. Everything else (i.e. clicking with the PDA on objects) goes in the chatbox.
		if (pda_readout == 1)
			data = "This area does not contain any gas."
		else if (simple_output == 1)
			data = "(<b>Contents:</b> <i>empty</i></b>)"
		else
			data = "<span style='color:red'>[A] does not contain any gas.</span>"

	return data

// Yeah, another scan I made into a global proc (Convair880).
/proc/scan_plant(var/atom/A as turf|obj, var/mob/user as mob)
	if (!A || !user || !ismob(user))
		return

	var/datum/plant/P = null
	var/datum/plantgenes/DNA = null

	if (istype(A, /obj/machinery/plantpot))
		var/obj/machinery/plantpot/PP = A
		if (!PP.current || PP.dead)
			return "<span style=\"color:red\">Cannot scan.</span>"

		P = PP.current
		DNA = PP.plantgenes

	else if (istype(A, /obj/item/seed/))
		var/obj/item/seed/S = A
		if (S.isstrange || !S.planttype)
			return "<span style=\"color:red\">This seed has non-standard DNA and thus cannot be scanned.</span>"

		P = S.planttype
		DNA = S.plantgenes

	else if (istype(A, /obj/item/reagent_containers/food/snacks/plant/))
		var/obj/item/reagent_containers/food/snacks/plant/F = A

		P = F.planttype
		DNA = F.plantgenes

	else
		return

	if (!P || !istype(P, /datum/plant/) || !DNA || !istype(DNA, /datum/plantgenes/))
		return "<span style=\"color:red\">Cannot scan.</span>"

	HYPgeneticanalysis(user, A, P, DNA) // Just use the existing proc.
	return