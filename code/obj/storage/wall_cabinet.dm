
/obj/item/storage/wall
	name = "cabinet"
	desc = "It's basically a big box attached to the wall."
	icon = 'icons/obj/storage.dmi'
	icon_state = "wall"
	plane = PLANE_DEFAULT+1
	flags = FPRINT | TABLEPASS
	force = 8.0
	w_class = 4.0
	anchored = 1.0
	density = 0
	mats = 8
	max_wclass = 4
	slots = 13 // these can't move so I guess we may as well let them store more stuff?
	mechanics_type_override = /obj/item/storage/wall

	attack_hand(mob/user as mob)
		return MouseDrop(user)

	New()
		..()
		lockers_and_crates.Add(src)

/obj/item/storage/wall/emergency
	name = "emergency supplies"
	desc = "A wall-mounted storage container that has a few emergency supplies in it."
	icon_state = "miniO2"

	make_my_stuff()
		..()
		if (prob(40))
			new /obj/item/storage/toolbox/emergency(src)
		if (prob(33))
			new /obj/item/clothing/suit/space/emerg(src)
			new /obj/item/clothing/head/emerg(src)
		if (prob(10))
			new /obj/item/storage/firstaid/oxygen(src)
		if (prob(10))
			new /obj/item/tank/air(src)
		if (prob(2))
			new /obj/item/tank/oxygen(src)
		if (prob(2))
			new /obj/item/clothing/mask/gas/emergency(src)
		for (var/i=rand(2,3), i>0, i--)
			if (prob(40))
				new /obj/item/tank/emergency_oxygen(src)
			if (prob(40))
				new /obj/item/clothing/mask/breath(src)

/obj/item/storage/wall/fire
	name = "firefighting supplies"
	desc = "A wall-mounted storage container that has a few firefighting supplies in it."
	icon_state = "minifire"

	make_my_stuff()
		..()
		if (prob(80))
			new /obj/item/extinguisher(src)
		if (prob(30))
			new /obj/item/clothing/suit/fire(src)
			new /obj/item/clothing/mask/gas/emergency(src)
		if (prob(10))
			new /obj/item/storage/firstaid/fire(src)
		if (prob(5))
			new /obj/item/storage/toolbox/emergency(src)

/obj/item/storage/wall/random
	pixel_y = 32
	make_my_stuff()
		..()
		var/thing1 = pick(10;/obj/item/screwdriver, 10;/obj/item/wrench, 5;/obj/item/crowbar, 3;/obj/item/wirecutters)
		if (ispath(thing1))
			new thing1(src)
		var/thing2 = pick(10;/obj/item/device/radio, 4;/obj/item/device/radio/signaler, 30;/obj/item/device/light/glowstick, 15;/obj/item/device/light/flashlight, 1;/obj/item/device/multitool)
		if (ispath(thing2))
			new thing2(src)
		var/thing3 = pick(10;/obj/item/cigpacket/propuffs, 15;/obj/item/reagent_containers/food/snacks/chips, 5;/obj/item/reagent_containers/food/drinks/bottle/hobo_wine, 2;/obj/item/reagent_containers/pill/cyberpunk)
		if (ispath(thing3))
			new thing3(src)
		return

/obj/item/storage/wall/office // basically the same as the office supply closet but in wall cabinet form!!
	name = "office supplies"
	pixel_y = 32
	spawn_contents = list(/obj/item/paper_bin = 2,
	/obj/item/hand_labeler,
	/obj/item/postit_stack,
	/obj/item/pen,
	/obj/item/staple_gun/red,
	/obj/item/scissors,
	/obj/item/stamp)

	make_my_stuff()
		..()
		var/markers = pick(66;/obj/item/storage/box/marker/basic, 34;/obj/item/storage/box/marker)
		if (ispath(markers))
			new markers(src)
		var/crayons = pick(66;/obj/item/storage/box/crayon/basic, 34;/obj/item/storage/box/crayon)
		if (ispath(crayons))
			new crayons(src)
		return

/obj/item/storage/wall/medical_wear
	name = "medical supplies"
	pixel_y = 32
	spawn_contents = list(/obj/item/storage/box/stma_kit = 2,
	/obj/item/storage/box/lglo_kit/random = 2,
	/obj/item/storage/box/clothing/patient_gowns = 2)

/obj/item/storage/wall/research_supplies
	name = "research supplies"
	pixel_y = 32
	spawn_contents = list(/obj/item/storage/box/stma_kit,
	/obj/item/storage/box/lglo_kit/random,
	/obj/item/storage/box/clothing/patient_gowns,
	/obj/item/storage/box/syringes,
	/obj/item/storage/box/patchbox,
	/obj/item/storage/box/vialbox,
	/obj/item/clothing/glasses/spectro = 2,
	/obj/item/reagent_containers/dropper/mechanical = 2,
	/obj/item/storage/box/biohazard_bags)

/obj/item/storage/wall/orange
	name = "orange wardrobe"
	icon_state = "miniorange"
	pixel_y = 32
	spawn_contents = list(/obj/item/clothing/under/color/orange = 2,
	/obj/item/clothing/under/misc = 2,
	/obj/item/clothing/shoes/orange = 3)

/obj/item/storage/wall/blue
	name = "blue wardrobe"
	icon_state = "miniblue"
	pixel_y = 32
	spawn_contents = list(/obj/item/clothing/under/color/blue = 4,
	/obj/item/clothing/shoes/brown = 4,
	/obj/item/clothing/head/blue = 2)

/obj/item/storage/wall/red
	name = "red wardrobe"
	icon_state = "minired"
	pixel_y = 32
	spawn_contents = list(/obj/item/clothing/under/color/red = 4,
	/obj/item/clothing/shoes/brown = 4,
	/obj/item/clothing/head/red = 2)

/obj/item/storage/wall/purple
	name = "purple wardrobe"
	icon_state = "minipurple"
	pixel_y = 32
	spawn_contents = list(/obj/item/clothing/under/color/pink = 4,
	/obj/item/clothing/shoes/brown = 4)

/obj/item/storage/wall/green
	name = "green wardrobe"
	icon_state = "minigreen"
	pixel_y = 32
	spawn_contents = list(/obj/item/clothing/under/color/green = 4,
	/obj/item/clothing/shoes/black = 4,
	/obj/item/clothing/head/green = 2)

/obj/item/storage/wall/mining
	name = "mining equipment"
	icon_state = "minimining"
	pixel_y = 32
	spawn_contents = list(/obj/item/clothing/shoes/orange,
	/obj/item/storage/box/clothing/miner,
	/obj/item/clothing/suit/wintercoat/engineering,
	/obj/item/breaching_charge/mining/light = 3,
	/obj/item/satchel/mining = 2,
	/obj/item/oreprospector,
	/obj/item/ore_scoop,
	/obj/item/mining_tool/power_pick,
	/obj/item/clothing/glasses/meson,
	/obj/item/storage/belt/mining)

/obj/item/storage/wall/clothingrack
	name = "clothing rack"
	icon = 'icons/obj/large_storage.dmi'
	density = 1
	slots = 7
	anchored = 1
	icon_state = "clothingrack" //They start full so might as well
	can_hold = list(/obj/item/clothing/under,/obj/item/clothing/suit)

	New()
		hud = new(src)
		..()
		SPAWN_DBG(1)
			update_icon()

	update_icon()
		var/list/my_contents = src.get_contents()
		if (my_contents.len <= 0)
			src.icon_state = "clothingrack-empty"
		else
			src.icon_state = "clothingrack"

	attackby(obj/item/W as obj, mob/user as mob, params, obj/item/storage/T as obj) // T for transfer - transferring items from one storage obj to another
		if (W.cant_drop)
			return
		if (islist(src.can_hold) && src.can_hold.len)
			var/ok = 0
			if (src.in_list_or_max && W.w_class <= src.max_wclass)
				ok = 1
			else
				for (var/A in src.can_hold)
					if (ispath(A) && istype(W, A))
						ok = 1
			if (!ok)
				boutput(user, "<span style='color:red'>[src] cannot hold [W].</span>")
				return

		else if (W.w_class > src.max_wclass)
			boutput(user, "<span style='color:red'>[W] won't fit into [src]!</span>")
			return

		var/list/my_contents = src.get_contents()
		if (my_contents.len >= slots)
			boutput(user, "<span style='color:red'>[src] is full!</span>")
			return 0

		var/atom/checkloc = src.loc // no infinite loops for you
		while (checkloc && !isturf(src.loc))
			if (checkloc == W) // nope
				//Hi hello this used to gib the user and create an actual 5x5 explosion on their tile
				//Turns out this condition can be met and reliably reproduced by players!
				//Lets not give players the ability to fucking explode at will eh
				return
			checkloc = checkloc.loc

		if (T && istype(T, /obj/item/storage))
			src.add_contents(W)
			T.hud.remove_item(W)
			update_icon()
		else
			user.u_equip(W)
			W.dropped(user)
			src.add_contents(W)
		hud.add_item(W)
		update_icon()
		add_fingerprint(user)
		animate_storage_rustle(src)
		if (!src.sneaky && !istype(W, /obj/item/gun/energy/crossbow))
			user.visible_message("<span style='color:blue'>[user] has added [W] to [src]!</span>", "<span style='color:blue'>You have added [W] to [src].</span>")
		playsound(src.loc, "rustle", 50, 1, -5)
		return



/obj/item/storage/wall/clothingrack/dresses
	spawn_contents = list(/obj/item/clothing/under/suit/red/dress = 1,
	/obj/item/clothing/under/suit/purple/dress = 1,
	/obj/item/clothing/under/gimmick/wedding_dress = 1,
	/obj/item/clothing/under/gimmick/sailormoon = 1,
	/obj/item/clothing/under/gimmick/princess = 1,
	/obj/item/clothing/under/gimmick/maid = 1,
	/obj/item/clothing/under/gimmick/kilt = 1)

/obj/item/storage/wall/clothingrack/clothes1
	spawn_contents = list(/obj/item/clothing/under/gimmick/hakama/random = 1,
	/obj/item/clothing/under/misc/syndicate = 1,
	/obj/item/clothing/under/gimmick/mario = 1,
	/obj/item/clothing/under/gimmick/odlaw = 1,
	/obj/item/clothing/under/gimmick/sealab = 1,
	/obj/item/clothing/under/misc/hitman = 1,
	/obj/item/clothing/under/misc/america = 1)

/obj/item/storage/wall/clothingrack/dresses2
	spawn_contents = list(/obj/item/clothing/under/misc/dress/hawaiian = 1,
	/obj/item/clothing/under/misc/dress/red = 1,
	/obj/item/clothing/suit/dressb = 1,
	/obj/item/clothing/suit/dressb/dressr = 1,
	/obj/item/clothing/suit/dressb/dressg = 1,
	/obj/item/clothing/suit/dressb/dressbl = 1,
	/obj/item/clothing/under/gimmick/anthy = 1)

/obj/item/storage/wall/clothingrack/clothes2
	spawn_contents = list(/obj/item/clothing/under/gimmick/hakama/random = 1,
	/obj/item/clothing/under/gimmick/toga = 1,
	/obj/item/clothing/suit/mj_suit = 1,
	/obj/item/clothing/under/gimmick/mj_clothes = 1,
	/obj/item/clothing/under/gimmick/sealab = 1,
	/obj/item/clothing/suit/scarf = 1,
	/obj/item/clothing/suit/greek = 1)

/obj/item/storage/wall/clothingrack/clothes3
	spawn_contents = list(/obj/item/clothing/suit/suspenders = 1,
	/obj/item/clothing/suit/hoodie = 1,
	/obj/item/clothing/under/misc/barber = 1,
	/obj/item/clothing/under/misc/serpico = 1,
	/obj/item/clothing/under/misc/tourist/max_payne = 1,
	/obj/item/clothing/under/referee = 1,
	/obj/item/clothing/under/misc/mail = 1)

/obj/item/storage/wall/clothingrack/clothes4
	spawn_contents = list(/obj/item/clothing/under/gimmick/utena = 1,
	/obj/item/clothing/suit/hoodie = 1,
	/obj/item/clothing/under/gimmick/dolan = 1,
	/obj/item/clothing/under/gimmick/butler = 1,
	/obj/item/clothing/under/gimmick/hunter = 1,
	/obj/item/clothing/under/gimmick/chaps= 1,
	/obj/item/clothing/under/gimmick/shirtnjeans = 1)

obj/item/storage/wall/clothingrack/hatrack
	name = "hat shelf"
	desc = "It's a shelf designed for many hats."
	icon = 'icons/obj/large_storage.dmi'
	icon_state = "hatrack"
	density = 0
	can_hold = list(/obj/item/clothing/head)


	New()
		hud = new(src)
		..()
		SPAWN_DBG(1)
			update_icon()


	update_icon()
		var/list/my_contents = src.get_contents()
		if (my_contents.len <= 0)
			src.icon_state = "hatrack-empty"
		else
			src.icon_state = "hatrack"

	hatrack_1
		spawn_contents = list(/obj/item/clothing/head/pinkwizard = 1,
		/obj/item/clothing/head/snake = 1,
		/obj/item/clothing/head/helmet/greek = 1,
		/obj/item/clothing/head/laurels = 1,
		/obj/item/clothing/head/laurels/gold = 1,
		/obj/item/clothing/head/formal_turban = 1)

	hatrack_2
		spawn_contents = list(/obj/item/clothing/head/beret/random_color = 1,
		/obj/item/clothing/head/beret/random_color = 1,
		/obj/item/clothing/head/beret/random_color = 1,
		/obj/item/clothing/head/beret/random_color = 1,
		/obj/item/clothing/head/veil = 1,
		/obj/item/clothing/head/serpico = 1,
		/obj/item/clothing/head/sailormoon = 1)

	hatrack_3
		spawn_contents = list(/obj/item/clothing/head/raccoon = 1,
		/obj/item/clothing/head/mj_hat = 1,
		/obj/item/clothing/head/sunhat = 1,
		/obj/item/clothing/head/sunhat/sunhatr = 1,
		/obj/item/clothing/head/sunhat/sunhatg = 1,
		/obj/item/clothing/head/aviator = 1,
		/obj/item/clothing/head/cowboy = 1)