

/atom/movable/overlay
	var/atom/master
	anchored = 1
/atom/movable/overlay/attackby(a, b)
	if(master)
		return master:attackby(a, b)
/atom/movable/overlay/attack_paw(a, b, c)
	if(master)
		return master:attack_paw(a, b, c)
/atom/movable/overlay/attack_hand(a, b, c)
	if(master)
		return master:attack_hand(a, b, c)
/atom/movable/overlay/New()
	for(var/x in verbs) verbs -= x
/atom/proc/meteorhit(obj/meteor)
	return
/atom/proc/allow_drop() return 1
var/shuttles = list()

/area/New()
	..()
	icon = 'alert.dmi'
	layer = 10
/area/escapezone
/area/dummy
/area/vehicles/New()
	..()
	sleep(1)
	var/S = new /obj/shut_controller()
	shuttles += S
	for(var/obj/move/O in src)
		S:parts += O
		O:master = S
	spawn(5) world << "Vehicle loaded!"










/area/vehicles/shuttle1
/area/vehicles/shuttle2
/area/vehicles/shuttle3
/area/security
/area/aircontrol
/area/shuttle_airlock
/area/toxinlab
/area/proc/firealert()
	if(!fire)
		if(icon_state == "red" || icon_state == "blue-red") icon_state = "blue-red"
		else icon_state = "blue"
		fire = 1
		for(var/obj/machinery/door/firedoor/D in src)
			if(!D:density)
				spawn(0) D:closefire()


































































/atom/proc/CheckPass(O as mob|obj|turf|area)
	return !O:density || !src.density
/atom/proc/CheckExit()
	return 1
/atom/proc/HasEntered(AM as mob|obj)
/atom/proc/HasProximity(AM as mob|obj)
/atom/movable/layer = 3
/turf/New()
	..()
	for(var/atom/movable/AM in src)
		spawn(0) Entered(AM)
/turf/Enter(O as mob|obj)
	if(density)
		spawn(0) if(O) O:Bump(src, 1)
		return 0
	if(!isturf(O:loc)) return 1
	for(var/atom/A in O:loc)
		if(!A:CheckExit(O, src) && O != A)
			spawn(0) if(O) O:Bump(A, 1)
			return 0
	for(var/atom/A in src)
		if(!A:CheckPass(O, src) && A != src)
			spawn(0) if(O) O:Bump(A, 1)
			return 0
	return 1
/turf/Entered(M as mob|obj)
	..()
	for(var/atom/A in src)
		spawn(0) if(A && M) A:HasEntered(M, 1)
	for(var/atom/A in view(1))
		spawn(0) if(A && M) A:HasProximity(M, 1)


/obj/meteor/small
	icon_state = "small"
/obj/meteor/small/Move()
	if(steps < 7)
		steps++
		if(steps >= 7)
			icon_state = "smallf"
	else
		var/T = loc
		if(istype(T, /turf))
			T:firelevel = T:poison + 5
	..()
	if(z != 1) del(src)
	spawn(3)
		step(src, WEST)
		if(prob(30))
			step(src, pick(NORTH, SOUTH))
/obj/meteor/var/steps
/obj/meteor/icon = 'meteor.dmi'
/obj/meteor/var/hits = 3
/obj/meteor/New()
	..()
	sleep(1)
	step(src, WEST)


/obj/meteor/Move()
	if(steps < 7)
		steps++
		if(steps >= 7)
			icon_state = "flaming"
	else
		var/T = loc
		if(istype(T, /turf))
			T:firelevel = T:poison + 5
	..()
	if(z != 1) del(src)
	spawn(3)
		step(src, WEST)
		if(prob(30))
			step(src, pick(NORTH, SOUTH))

/obj/meteor/Bump(A as mob|obj|turf|area)
	if(A) A:meteorhit(src)
	if(--hits <= 0) del(src)
/obj/meteor/ex_act(severity)
	if(severity < 4)
		del(src)
/obj/secloset/desc = "An immobile card-locked storage container. Works by position ... not access levels"
/obj/secloset/name = "Security closet"
/obj/meteor
	density = 1
	anchored = 1
/obj/secloset/CheckPass(O as mob|obj, turf/target)
	if(!opened) return 0
	else return 1
/obj/secloset/personal
	icon_state = "0secloset0"
	name = "Personal Closet"
	desc = "The first card swiped gains control."
/obj/secloset/personal/New()
	..()
	sleep(2)
	new /obj/item/weapon/storage/backpack(src)
	new /obj/item/weapon/radio/headset(src)
	new /obj/item/weapon/radio/signaler(src)
	new /obj/item/weapon/pen(src)
/obj/secloset/personal/attackby(W as obj, mob/user)
	if(opened)
		user:drop_item()
		W:loc = loc
	else if(istype(W, /obj/item/weapon/card/id))
		var/L = list()
		if(W:assignment == "Systems")
			allowed = null
			icon_state = "0secloset0"
			locked = 1
			desc = "The first card swiped gains control."
			return
		if(allowed) L = dd_text2list(allowed, ",")
		if(L:Find(W:assignment) || (!allowed || L:Find("m[W:registered]")))
			locked = !locked
			for(var/mob/O in view(user, 3))
				if(O:client && !O:blinded)
					O << "\blue The locker has been [locked ? null : "un"]locked by [user]."
			icon_state = "[locked ? "1" : null]secloset0"
			if(!allowed)
				allowed = "m[W:registered],Captain,Head of Personnel"
				desc = "Owned by [W:registered], Clear by using a card of rank 'Systems'"
		else
			user << "\red Access Denied"
	else
		user << "\red It's closed..."
/obj/secloset/security2
	name = "Forensics Locker"
	allowed = "Prison Security,Prison Warden,Forensic Technician,Security Officer,Captain,Head of Personnel,Head of Research"
/obj/secloset/security2/New()
	..()
	sleep(2)
	new /obj/item/weapon/clothing/under/red(src)
	new /obj/item/weapon/storage/fcard_kit(src)
	new /obj/item/weapon/storage/fcard_kit(src)
	new /obj/item/weapon/storage/fcard_kit(src)
	new /obj/item/weapon/storage/lglo_kit(src)
	new /obj/item/weapon/storage/lglo_kit(src)
	new /obj/item/weapon/fcardholder(src)
	new /obj/item/weapon/fcardholder(src)
	new /obj/item/weapon/fcardholder(src)
	new /obj/item/weapon/fcardholder(src)
	new /obj/item/weapon/camera(src)
	new /obj/item/weapon/f_print_scanner(src)
	new /obj/item/weapon/f_print_scanner(src)
	new /obj/item/weapon/f_print_scanner(src)
/obj/secloset/security1
	name = "Security Equipment"
	allowed = "Prison Security,Prison Warden,Security Officer,Captain,Head of Personnel,Head of Research"
/obj/secloset/security1/New()
	..()
	sleep(2)
	new /obj/item/weapon/storage/flashbang_kit(src)
	new /obj/item/weapon/storage/handcuff_kit(src)
	new /obj/item/weapon/gun/taser_gun(src)
	new /obj/item/weapon/flash(src)
	new /obj/item/weapon/clothing/under/red(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
	new /obj/item/weapon/clothing/suit/armor(src)
	new /obj/item/weapon/clothing/head/helmet(src)
	new /obj/item/weapon/clothing/glasses/sunglasses(src)
/obj/secloset/highsec
	allowed = "Captain,Head of Personnel,Head of Research"
	name = "Experimental Technology"
/obj/secloset/highsec/New()
	..()
	sleep(2)
	new /obj/item/weapon/gun/laser_gun(src)
	new /obj/item/weapon/gun/taser_gun(src)

	new /obj/item/weapon/flash(src)
	new /obj/item/weapon/storage/id_kit(src)
	new /obj/item/weapon/clothing/under/green(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
	new /obj/item/weapon/clothing/glasses/sunglasses(src)
	new /obj/item/weapon/clothing/suit/armor(src)
	new /obj/item/weapon/clothing/head/helmet(src)
/obj/secloset/animal
	name = "Animal Control"
	allowed = null
/obj/secloset/animal/New()
	..()
	sleep(2)
	new /obj/item/weapon/radio/signaler(src)
	new /obj/item/weapon/radio/electropack(src)
	new /obj/item/weapon/radio/electropack(src)
	new /obj/item/weapon/radio/electropack(src)
	new /obj/item/weapon/radio/electropack(src)
	new /obj/item/weapon/radio/electropack(src)
/obj/secloset/medical1
	name = "Medicine Closet"
	allowed = "Medical Researcher,Prison Doctor,Medical Doctor,Captain,Head of Research"
/obj/secloset/medical1/New()
	..()
	sleep(2)
	new /obj/item/weapon/bottle/toxins(src)
	new /obj/item/weapon/bottle/rejuvenators(src)
	new /obj/item/weapon/bottle/s_tox(src)
	new /obj/item/weapon/bottle/s_tox(src)
	new /obj/item/weapon/bottle/toxins(src)
	new /obj/item/weapon/bottle/r_epil(src)
	new /obj/item/weapon/bottle/r_ch_cough(src)
	new /obj/item/weapon/pill_canister/Tourette(src)
	new /obj/item/weapon/pill_canister/cough(src)
	new /obj/item/weapon/pill_canister/epilepsy(src)
	new /obj/item/weapon/pill_canister/sleep(src)
	new /obj/item/weapon/pill_canister/antitoxin(src)
	new /obj/item/weapon/pill_canister/placebo(src)
	new /obj/item/weapon/storage/firstaid/syringes(src)
	new /obj/item/weapon/storage/gl_kit(src)
	new /obj/item/weapon/dropper(src)
/obj/secloset/medical2
	allowed = "Medical Researcher,Prison Doctor,Medical Doctor,Captain,Head of Research"
	name = "Anesthetic"
/obj/secloset/medical2/New()
	..()
	sleep(2)
	new /obj/item/weapon/tank/anesthetic(src)
	new /obj/item/weapon/tank/anesthetic(src)
	new /obj/item/weapon/tank/anesthetic(src)
	new /obj/item/weapon/tank/anesthetic(src)
	new /obj/item/weapon/tank/anesthetic(src)
	new /obj/item/weapon/clothing/mask/m_mask(src)
	new /obj/item/weapon/clothing/mask/m_mask(src)
	new /obj/item/weapon/clothing/mask/m_mask(src)
	new /obj/item/weapon/clothing/mask/m_mask(src)
/obj/secloset/ex_act(severity)
	switch(severity)
		if(1)
			for(var/atom/movable/A in src)
				A:loc = loc
				A:ex_act(severity)
			del(src)
		if(2)
			if(prob(50))
				for(var/atom/movable/A in src)
					A:loc = loc
					A:ex_act(severity)
				del(src)
		if(3)
			if(prob(5))
				for(var/atom/movable/A in src)
					A:loc = loc
					A:ex_act(severity)
				del(src)
/obj/secloset/meteorhit(obj/O)
	if(O:icon_state == "flaming")
		for(var/obj/item/I in src)
			I:loc = loc
		for(var/mob/M in src)
			M:loc = loc
			if(M:client)
				M:client:eye = M:client:mob
				M:client:perspective = MOB_PERSPECTIVE
		icon_state = "secloset1"
		del(src)
/obj/secloset
	name = "Security Locker"
	icon_state = "1secloset0"
	var/opened = 0
	var/locked = 1
	var/allowed
	icon = 'stationobjs.dmi'
/obj/secloset/attackby(obj/W, mob/user)
	if(opened)
		user:drop_item()
		W:loc = loc
	else if(istype(W, /obj/item/weapon/card/id))
		var/L = list()
		if(allowed) L = dd_text2list(allowed, ",")
		if(L:Find(W:assignment) || !allowed)
			locked = !locked
			for(var/mob/O in view(user, 3))
				if(O:client && !O:blinded)
					O << "\blue The locker has been [locked ? null : "un"]locked by [user]."
			icon_state = "[locked ? "1" : null]secloset0"
		else
			user << "\red Access Denied"
	else
		user << "\red It's closed..."
/obj/secloset/relaymove(mob/user)
	if(!locked)
		for(var/obj/item/I in src)
			I:loc = loc
		for(var/mob/M in src)
			M:loc = loc
			if(M:client)
				M:client:eye = M:client:mob
				M:client:perspective = MOB_PERSPECTIVE
		icon_state = "secloset1"
		opened = 1
	else
		user << "\blue It's welded shut!"
		for(var/mob/M in oview(src))
			M << "<FONT size=[max(0, 5 - get_dist(src, M))]>BANG, bang!</FONT>"
/obj/secloset/MouseDrop_T(O as mob|obj, mob/user)
	if(user:restrained() || user:stat) return
	if(!istype(O, /atom/movable) || (O:anchored || (get_dist(user, src) > 1 || (get_dist(user, O) > 1 || user:contents:Find(src))))) return
	step_towards(O, loc)
	if(user != O)
		for(var/mob/B in view(user, 3))
			if(B:client && !B:blinded)
				B << "\red[user] stuffs [O] into [src]!"
	add_fingerprint(user)
/obj/secloset/attack_paw(mob/user)
	return attack_hand(user)
/obj/secloset/attack_hand(mob/user)
	add_fingerprint(user)
	if(!opened)
		if(!locked)
			for(var/obj/item/I in src)
				I:loc = loc
			for(var/mob/M in src)
				M:loc = loc
				if(M:client)
					M:client:eye = M:client:mob
					M:client:perspective = MOB_PERSPECTIVE
			icon_state = "secloset1"
			opened = 1
		else
			usr << "\blue It's locked tight!"
	else
		for(var/obj/item/I in src.loc)
			if(!I:anchored)
				I:loc = src
		for(var/mob/M in loc)
			if(M:client)
				M:client:perspective = EYE_PERSPECTIVE
				M:client:eye = src
			M:loc = src
		icon_state = "secloset0"
		opened = 0
/obj/morgue
	icon_state = "morgue1"
	icon = 'stationobjs.dmi'
	density = 1
	anchored = 1
	var/connected
/obj/morgue/proc/update()
	if(src.connected)
		src.icon_state = "morgue0"
	else
		if(contents:len)
			icon_state = "morgue2"
		else
			icon_state = "morgue1"
/obj/morgue/attack_paw(mob/user)
	return attack_hand(user)
/obj/morgue/attack_hand(mob/user)
	if(connected)
		for(var/atom/movable/A in connected:loc)
			if(!A:anchored)
				A:loc = src
		del(connected)
	else
		connected = new /obj/m_tray(loc)
		step(connected, EAST)
		connected:layer = OBJ_LAYER
		var/T = get_step(src, EAST)
		if(T:contents:Find(connected))
			connected:connected = src
			icon_state = "morgue0"
			for(var/atom/movable/A in src)
				A:loc = connected:loc
			connected:icon_state = "morguet"
		else del(connected)
	add_fingerprint(user)
	update()
/obj/morgue/attackby(obj/P, mob/user)
	if(istype(P, /obj/item/weapon/pen))
		var/t = input(user, "What would you like the label to be?", "[name]") as text
		if(user:equipped() != P) return
		if(get_dist(src, usr) > 1 && loc != user) return
		t = html_encode(t)
		if(t)
			name = "Morgue- '[t]'"
		else
			name = "Morgue"
	add_fingerprint(user)
/obj/morgue/relaymove(mob/user)
	connected = new /obj/m_tray(loc)
	step(connected, EAST)
	connected:layer = OBJ_LAYER
	var/T = get_step(src, EAST)
	if(T:contents:Find(connected))
		connected:connected = src
		icon_state = "morgue0"
		for(var/atom/movable/A in src)
			A:loc = connected:loc
		connected:icon_state = "morguet"
	else del(connected)
/obj/m_tray
	icon_state = "morguet"
	icon = 'stationobjs.dmi'
	density = 1
	layer = 2
	anchored = 1
	var/obj/morgue/connected
/obj/m_tray/attack_paw(mob/user)
	return attack_hand(user)
/obj/m_tray/attack_hand(mob/user)
	if(connected)
		for(var/atom/movable/A in src.loc)
			if(!A:anchored)
				A:loc = connected
		connected:connected = null
		connected:update()
		connected:add_fingerprint(user)
		del(src)
/obj/m_tray/MouseDrop_T(O as mob|obj, mob/user)
	if(!istype(O, /atom/movable) || (O:anchored || (get_dist(user, src) > 1 || (get_dist(user, O) > 1 || user:contents:Find(src))))) return
	O:loc = loc
	if(user != O)
		for(var/mob/B in view(user, 3))
			if(B:client && !B:blinded)
				B << "\red[user] stuffs [O] into [src]!"
/obj/closet/flags = 320
/obj/closet/CheckPass(O as mob|obj, turf/target)
	if(!opened) return 0
	else return 1

/obj/closet
	icon_state = "closet"
	var/original = "closet"
	var/orig_closed = "emcloset1"
	var/opened = 0
	name = "Closet"
	density = 1
/obj/closet/emcloset
	name = "Emergency Closets"; icon_state = "emcloset0"
	original = "emcloset0"
	desc = "A bulky (yet mobile) closet. Comes prestocked with a gasmask and o2 tank for emergencies"
/obj/closet/emcloset/New()
	..()
	sleep(2)
	new /obj/item/weapon/tank/oxygentank(src)
	new /obj/item/weapon/clothing/mask/gasmask(src)

/obj/closet/l3closet
	name = "Level 3 Biohazard Suit"
	icon_state = "l3closet0"
	original = "l3closet0"; orig_closed = "l3closet1"
	desc = "A bulky (yet mobile) closet. Comes prestocked with level 3 biohazard gear for emergencies."
/obj/closet/l3closet/New()
	..()
	sleep(2)
	new /obj/item/weapon/tank/oxygentank(src)
	new /obj/item/weapon/clothing/mask/gasmask(src)
	new /obj/item/weapon/clothing/suit/bio_suit(src)
	new /obj/item/weapon/clothing/under/white(src)
	new /obj/item/weapon/clothing/shoes/white(src)
	new /obj/item/weapon/clothing/gloves/latex(src)
	new /obj/item/weapon/clothing/head/bio_hood(src)
/obj/closet/wardrobe
	name = "Wardrobe"
	icon_state = "wardrobe-b"
	original = "wardrobe-b"
/obj/closet/wardrobe/New()
	new /obj/item/weapon/clothing/under/blue(src)
	new /obj/item/weapon/clothing/under/blue(src)
	new /obj/item/weapon/clothing/under/blue(src)
	new /obj/item/weapon/clothing/under/blue(src)
	new /obj/item/weapon/clothing/under/blue(src)
	new /obj/item/weapon/clothing/under/blue(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
/obj/closet/wardrobe/red
	name = "Red Wardrobe"
	icon_state = "wardrobe-r"
	original = "wardrobe-r"
/obj/closet/wardrobe/red/New()
	new /obj/item/weapon/clothing/under/red(src)
	new /obj/item/weapon/clothing/under/red(src)
	new /obj/item/weapon/clothing/under/red(src)
	new /obj/item/weapon/clothing/under/red(src)
	new /obj/item/weapon/clothing/under/red(src)
	new /obj/item/weapon/clothing/under/red(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
/obj/closet/wardrobe/pink
	name = "Pink Wardrobe"
	icon_state = "wardrobe-p"
	original = "wardrobe-p"
/obj/closet/wardrobe/pink/New()
	new /obj/item/weapon/clothing/under/pink(src)
	new /obj/item/weapon/clothing/under/pink(src)
	new /obj/item/weapon/clothing/under/pink(src)
	new /obj/item/weapon/clothing/under/pink(src)
	new /obj/item/weapon/clothing/under/pink(src)
	new /obj/item/weapon/clothing/under/pink(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
/obj/closet/wardrobe/black
	name = "Black Wardrobe"
	icon_state = "wardrobe-bl"
	original = "wardrobe-bl"
/obj/closet/wardrobe/black/New()
	new /obj/item/weapon/clothing/under/black(src)
	new /obj/item/weapon/clothing/under/black(src)
	new /obj/item/weapon/clothing/under/black(src)
	new /obj/item/weapon/clothing/under/black(src)
	new /obj/item/weapon/clothing/under/black(src)
	new /obj/item/weapon/clothing/under/black(src)
	new /obj/item/weapon/clothing/shoes/black(src)
	new /obj/item/weapon/clothing/shoes/black(src)
	new /obj/item/weapon/clothing/shoes/black(src)
	new /obj/item/weapon/clothing/shoes/black(src)
	new /obj/item/weapon/clothing/shoes/black(src)
	new /obj/item/weapon/clothing/shoes/black(src)
/obj/closet/wardrobe/green
	name = "Green Wardrobe"
	icon_state = "wardrobe-g"
	original = "wardrobe-g"
/obj/closet/wardrobe/green/New()
	new /obj/item/weapon/clothing/under/green(src)
	new /obj/item/weapon/clothing/under/green(src)
	new /obj/item/weapon/clothing/under/green(src)
	new /obj/item/weapon/clothing/under/green(src)
	new /obj/item/weapon/clothing/under/green(src)
	new /obj/item/weapon/clothing/under/green(src)
	new /obj/item/weapon/clothing/shoes/black(src)
	new /obj/item/weapon/clothing/shoes/black(src)
	new /obj/item/weapon/clothing/shoes/black(src)
	new /obj/item/weapon/clothing/shoes/black(src)
	new /obj/item/weapon/clothing/shoes/black(src)
	new /obj/item/weapon/clothing/shoes/black(src)
/obj/closet/wardrobe/orange
	name = "Prisoners Wardrobe"
	icon_state = "wardrobe-o"
	original = "wardrobe-o"
/obj/closet/wardrobe/orange/New()
	new /obj/item/weapon/clothing/under/orange(src)
	new /obj/item/weapon/clothing/under/orange(src)
	new /obj/item/weapon/clothing/under/orange(src)
	new /obj/item/weapon/clothing/under/orange(src)
	new /obj/item/weapon/clothing/under/orange(src)
	new /obj/item/weapon/clothing/under/orange(src)
	new /obj/item/weapon/clothing/shoes/orange(src)
	new /obj/item/weapon/clothing/shoes/orange(src)
	new /obj/item/weapon/clothing/shoes/orange(src)
	new /obj/item/weapon/clothing/shoes/orange(src)
	new /obj/item/weapon/clothing/shoes/orange(src)
	new /obj/item/weapon/clothing/shoes/orange(src)
/obj/closet/wardrobe/yellow
	name = "Technician Wardrobe"
	icon_state = "wardrobe-y"
	original = "wardrobe-y"
/obj/closet/wardrobe/yellow/New()
	new /obj/item/weapon/clothing/under/yellow(src)
	new /obj/item/weapon/clothing/under/yellow(src)
	new /obj/item/weapon/clothing/under/yellow(src)
	new /obj/item/weapon/clothing/under/yellow(src)
	new /obj/item/weapon/clothing/under/yellow(src)
	new /obj/item/weapon/clothing/under/yellow(src)
	new /obj/item/weapon/clothing/shoes/orange(src)
	new /obj/item/weapon/clothing/shoes/orange(src)
	new /obj/item/weapon/clothing/shoes/orange(src)
	new /obj/item/weapon/clothing/shoes/orange(src)
	new /obj/item/weapon/clothing/shoes/orange(src)
	new /obj/item/weapon/clothing/shoes/orange(src)
/obj/closet/wardrobe/mixed
	name = "Mixed Wardrobe"
	icon_state = "wardrobe-bp"
	original = "wardrobe-bp"
/obj/closet/wardrobe/mixed/New()
	new /obj/item/weapon/clothing/under/blue(src)
	new /obj/item/weapon/clothing/under/blue(src)
	new /obj/item/weapon/clothing/under/blue(src)
	new /obj/item/weapon/clothing/under/pink(src)
	new /obj/item/weapon/clothing/under/pink(src)
	new /obj/item/weapon/clothing/under/pink(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
	new /obj/item/weapon/clothing/shoes/brown(src)
/obj/closet/wardrobe/white
	name = "Medical Wardrobe"
	icon_state = "wardrobe-w"
	original = "wardrobe-w"
/obj/closet/wardrobe/white/New()
	new /obj/item/weapon/clothing/under/white(src)
	new /obj/item/weapon/clothing/under/white(src)
	new /obj/item/weapon/clothing/under/white(src)
	new /obj/item/weapon/clothing/under/white(src)
	new /obj/item/weapon/clothing/under/white(src)
	new /obj/item/weapon/clothing/shoes/white(src)
	new /obj/item/weapon/clothing/shoes/white(src)
	new /obj/item/weapon/clothing/shoes/white(src)
	new /obj/item/weapon/clothing/shoes/white(src)
	new /obj/item/weapon/clothing/shoes/white(src)
	new /obj/item/weapon/storage/lglo_kit(src)
	new /obj/item/weapon/storage/stma_kit(src)
/obj/closet/wardrobe/desc = "A bulky (yet mobile) wardrobe closet. Comes prestocked with 6 changes of clothes."
/obj/closet/desc = "It's a closet!"
/obj/closet/ex_act(severity)
	switch(severity)
		if(1)
			for(var/atom/movable/A in src)
				A:loc = loc
				A:ex_act(severity)
			del(src)
		if(2)
			if(prob(50))
				for(var/atom/movable/A in src)
					A:loc = loc
					A:ex_act(severity)
				del(src)
		if(3)
			if(prob(5))
				for(var/atom/movable/A in src)
					A:loc = loc
					A:ex_act(severity)
				del(src)
/obj/closet/meteorhit(obj/O)
	if(O:icon_state == "flaming")
		for(var/obj/item/I in src)
			I:loc = loc
		for(var/mob/M in src)
			M:loc = loc
			if(M:client)
				M:client:eye = M:client:mob
				M:client:perspective = MOB_PERSPECTIVE
		icon_state = "emcloset1"
		del(src)
/obj/closet
	var/welded = 0
	icon = 'stationobjs.dmi'
/obj/closet/attackby(obj/W, mob/user)
	if(opened || (W:damtype != "fire" || !istype(W, /obj/item/weapon/weldingtool)))
		user:drop_item()
		W:loc = loc
	else
		welded = !welded
		for(var/mob/M in view(user))
			if(M:client)
				M:show_message("\red[src] has been [welded ? "welded shut" : "unwelded"] by [user].", 3, "\red You hear welding.", 2)
/obj/closet/relaymove(mob/user)
	if(!welded)
		for(var/obj/item/I in src)
			I:loc = loc
		for(var/mob/M in src)
			M:loc = loc
			if(M:client)
				M:client:eye = M:client:mob
				M:client:perspective = MOB_PERSPECTIVE
		icon_state = "emcloset1"
		opened = 1
	else
		user << "\blue It's welded shut!"
		for(var/mob/M in oview(src))
			M << "<FONT size=[max(0, 5 - get_dist(src, M))]>BANG, bang!</FONT>"
/obj/closet/MouseDrop_T(O as mob|obj, mob/user)
	if(user:restrained() || user:stat) return
	if(!istype(O, /atom/movable) || (O:anchored || (get_dist(user, src) > 1 || (get_dist(user, O) > 1 || user:contents:Find(src))))) return
	step_towards(O, loc)
	for(var/mob/M in view(user))
		if(M:client && !M:blinded)
			M << "\red[user] stuffs [O] into [src]!"
	add_fingerprint(user)
/obj/closet/attack_paw(mob/user)
	return attack_hand(user)
/obj/closet/attack_hand(mob/user)
	add_fingerprint(user)
	if(!opened)
		if(!welded)
			for(var/obj/item/I in src)
				I:loc = loc
			for(var/mob/M in src)
				if(!M:buckled)
					M:loc = loc
					if(M:client)
						M:client:eye = M:client:mob
						M:client:perspective = MOB_PERSPECTIVE
			icon_state = "emcloset1"
			opened = 1
		else
			usr << "\blue It's welded shut!"
	else
		for(var/obj/item/I in src.loc)
			if(!I:anchored)
				I:loc = src
		for(var/mob/M in loc)
			if(M:client)
				M:client:perspective = EYE_PERSPECTIVE
				M:client:eye = src
			M:loc = src
		icon_state = original
		opened = 0
/obj/closet/CheckPass(O as mob|obj, turf/target)
	if(!opened) return 0
	else return 1
/obj/closet/weight = 1e+08
/obj/secloset{density = 1; anchored = 1}
/obj/stool{icon_state = "stool"; icon = 'Icons.dmi'; flags = 320}
/obj/stool/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			if(prob(50)) del(src)
		if(3)
			if(prob(5)) del(src)


/obj/stool/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		new /obj/item/weapon/sheet/metal(loc)
		del(src)
		return
/obj/stool/bed
	icon_state = "bed"
	anchored = 1
/obj/stool/bed/attackby(obj/W, mob/user)
/atom/movable/layer = 3


/obj/stool/chair/attackby(obj/W, mob/user)
	..()
	if(istype(W, /obj/item/weapon/assembly/shock_kit))
		var/E = new /obj/stool/chair/e_chair(loc)
		E:dir = dir
		E:part1 = W
		W:loc = E
		W:master = E
		user:u_equip(W)
		W:layer = initial(W:layer)
		del(src)
/obj/stool/chair/e_chair
	icon_state = "e_chair0"
	var/atom/movable/overlay/overl
	name = "electrified chair"
	var/on = 0
/obj/stool/chair/e_chair/New()
	overl = new /atom/movable/overlay(loc)
	overl:icon = 'Icons.dmi'
	overl:icon_state = "e_chairo0"
	overl:layer = 5
	overl:name = "electrified chair"
	overl:master = src
/obj/stool
	icon = 'Icons.dmi'
/obj/stool/chair/e_chair/Del()
	del(overl)
	..()

/obj/stool/chair
	icon_state = "chair"
	var/status = 0
	anchored = 1
/obj/stool/chair/e_chair/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		var/C = new /obj/stool/chair(loc)
		C:dir = dir
		part1:loc = loc
		part1:master = null
		part1 = null
		del(src)
/obj/stool/chair/e_chair/verb/toggle_power()
	set src in oview(1)
	if(usr.stat || (usr.restrained() || (!usr.canmove || usr.lying))) return
	on = !on
	icon_state = "e_chair[on]"
	overl:icon_state = "e_chairo[on]"
/obj/stool/chair/e_chair{var/part1; var/last_time = 1}
/obj/stool/chair/e_chair/proc/shock()
	if(!on) return
	if(last_time + 50 > world.time) return
	last_time = world.time
	flick("e_chairs", src)
	flick("e_chairos", overl)
	for(var/mob/M in src.loc)
		var/d = min(120, M:health + 120)
		M:fireloss += d
		M:health = 100 - M:oxyloss - M:toxloss - M:fireloss - M:bruteloss
		M:stunned = 600
		M << "\red<B>You feel a deep shock curse through your body!</B>"
	for(var/mob/M in view(src))
		if(!M:blinded)
			M << "\red The electric chair went off!"
		else
			M << "\red You hear a deep sharp shock."

/obj/stool/chair/ex_act(severity)
	if(severity < 4)
		for(var/mob/M in loc)
			M:buckled = null
	switch(severity)
		if(1)
			del(src)
		if(2)
			if(prob(50)) del(src)
		if(3)
			if(prob(5)) del(src)
/obj/stool/chair/New()
	verbs -= /atom/movable/verb/pull
	if(dir == NORTH)
		layer = FLY_LAYER
	..()
/obj/stool/chair/Del()
	for(var/mob/M in loc)
		if(M:buckled == src) M:buckled = null
	..()

/obj/stool/chair/verb/rotate()
	set src in oview(1)
	dir = turn(dir, 90)
	if(dir == NORTH)
		layer = FLY_LAYER
	else layer = OBJ_LAYER








/obj/stool/chair/MouseDrop_T(mob/M, mob/user)
	if(!istype(M, /mob) || (get_dist(src, user) > 1 || (M:loc != loc || (user:restrained() || usr.stat)))) return
	if(M == usr)
		for(var/mob/O in view(user))
			if(O:client && !O:blinded)
				O << "\blue[user] buckles in!"
	else
		for(var/mob/O in view(user))
			if(O:client && !O:blinded)
				O << "\blue[M] is buckled in by [user]!"
	M:anchored = 1
	M:buckled = src
	M:loc = loc
	add_fingerprint(user)
/obj/stool/chair/attack_paw(mob/user)
	if(ticker && ticker:mode == "monkey")
		return attack_hand(user)
/obj/stool/chair/attack_hand(mob/user)
	for(var/mob/M in loc)
		if(M:buckled)
			if(M != user)
				for(var/mob/O in view(user))
					if(O:client && !O:blinded)
						O << "\blue[M] is unbuckled by [user]."
			else
				for(var/mob/O in view(user))
					if(O:client && !O:blinded)
						O << "\blue[M] unbuckles."
			M:anchored = 0
			M:buckled = null
			add_fingerprint(user)








/obj/item/weapon/clothing/burn(fi_amount)
	if(fi_amount > s_fire)
		spawn(0)
			var/t = icon_state
			icon_state = ""
			icon = 'b_items.dmi'
			flick("[t]", src)
			spawn(14)
				del(src)







/obj/item/weapon/clothing
	var/a_filter = 0
	var/fb_filter = 0
	var/h_filter = 0
	var/s_fire = 0
	var/see_face = 1
/obj/item/weapon/clothing/head/helmet
	flags = 266
	icon_state = "helmet"
	s_istate = "helmet"
	s_fire = 67500000.0
/obj/item/weapon/clothing/head/wig
/obj/item/weapon/clothing/head/bio_hood
	icon_state = "bio_hood"
	fb_filter = 9
	flags = 262
	see_face = 0
	s_fire = 18750000.0
/obj/item/weapon/clothing/head/swat_hel
	flags = 270
	see_face = 0
	icon_state = "swat_hel"
	s_istate = "swat_hel"
	s_fire = 67500000.0
/obj/item/weapon/clothing/head/s_helmet
	icon_state = "s_helmet"
	flags = 262
	see_face = 0
	s_istate = "s_helmet"
	s_fire = 5.625e+07
/obj/item/weapon/clothing/gloves/w_class = 2
/obj/item/weapon/clothing/gloves/s_fire = 18750000.0
/obj/item/weapon/clothing/gloves/examine()
	set src in usr
	..()

/obj/item/weapon/clothing/gloves/latex
	name = "Latex Gloves"
	icon_state = "lgloves"
	s_istate = "lgloves"
	h_filter = 5
/obj/item/weapon/clothing/gloves/robot
	name = "Robot Gloves"
	icon_state = "r_hands"
	s_istate = "r_hands"
	desc = "These gloves are somewhat fire-resistant."
	h_filter = 4
/obj/item/weapon/clothing/gloves/swat
	desc = "These gloves are somewhat fire-resistant."
	name = "SWAT Gloves"
	icon_state = "swat_gl"
	s_istate = "swat_gl"
	h_filter = 4
/obj/item/weapon/clothing/gloves/black
	desc = "These gloves are somewhat fire-resistant."
	name = "Black Gloves"
	icon_state = "bgloves"
	s_istate = "bgloves"
	h_filter = 4
	s_fire = 75000000.0
/obj/item/weapon/clothing/ears
	w_class = 2
/obj/item/weapon/clothing/ears/earmuffs
	s_fire = 18750000.0
	icon_state = "earmuffs"
	s_istate = "earmuffs"
/obj/item/weapon/clothing/glasses
	w_class = 2
	s_fire = 75000000.0
/obj/item/weapon/clothing/glasses/meson
	name = "Optical Meson Scanner"
	icon_state = "m_glasses"
	s_istate = "glasses"
/obj/item/weapon/clothing/glasses/thermal
	s_istate = "glasses"
	name = "Optical Thermal/Meson Scanner"
	icon_state = "t_glasses"
/obj/item/weapon/clothing/glasses/sunglasses
	name = "Sunglasses"
	icon_state = "s_glasses"
	s_istate = "s_glasses"
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
/obj/item/weapon/clothing/glasses/regular
	s_istate = "glasses"
	name = "Prescription Glasses"
	icon_state = "p_glasses"
/obj/item/weapon/clothing/glasses/blindfold
	icon_state = "blindfold"
	s_istate = "blindfold"

/obj/item/weapon/clothing/glasses/blindfold/burn(fi_amount)
	if(fi_amount > 3e7)
		spawn(0)
			var/t = icon_state
			icon_state = ""
			icon = 'b_items.dmi'
			flick("[t]", src)
			spawn(14)
				del(src)
/obj/item/weapon/clothing
	var/color
/obj/item/weapon/clothing/shoes
	var/chained = 0
/obj/item/weapon/clothing/shoes/orange
	icon_state = "o_shoes"
	name = "Orange Shoes"

/obj/item/weapon/clothing/shoes/orange/attack_self(mob/user)
	if(chained)
		chained = null
		new /obj/item/weapon/handcuffs(user:loc)
		icon_state = "o_shoes"
/obj/item/weapon/clothing/shoes/orange/attackby(obj/H, loc)
	if(istype(H, /obj/item/weapon/handcuffs) && !chained)
		del(H)
		chained = 1
		icon_state = "o_shoes1"
/obj/item/weapon/clothing/shoes/black
	icon_state = "bl_shoes"
	name = "Black Shoes"
/obj/item/weapon/clothing/shoes/brown
	icon_state = "b_shoes"
	name = "Brown Shoes"
/obj/item/weapon/clothing/shoes/white
	icon_state = "w_shoes"
	name = "White Shoes"
	fb_filter = 5
/obj/item/weapon/clothing/under
	s_fire = 18750000.0
	fb_filter = 1
/obj/item/weapon/clothing/shoes/fb_filter = 1
/obj/item/weapon/clothing/shoes/s_fire = 37500000.0










/obj/item/weapon/clothing/shoes/robot
	icon_state = "r_feet"
	name = "Robot Shoes"
/obj/item/weapon/clothing/shoes/swat
	icon_state = "swat_sh"
	name = "SWAT shoes"
/obj/item/weapon/clothing/under/orange
	icon_state = "o_suit"
	name = "Orange Jumpsuit"
	color = "orange"
/obj/item/weapon/clothing/under/yellow
	icon_state = "y_suit"
	name = "Yellow Jumpsuit"
	color = "yellow"
/obj/item/weapon/clothing/under/blue
	icon_state = "b_suit"
	name = "Blue Jumpsuit"
	color = "blue"
/obj/item/weapon/clothing/under/red
	icon_state = "r_suit"
	name = "Red Jumpsuit"
	color = "red"
/obj/item/weapon/clothing/under/pink
	icon_state = "p_suit"
	name = "Pink Jumpsuit (F)"
	color = "pink"
/obj/item/weapon/clothing/under/black
	icon_state = "bl_suit"
	name = "Black Jumpsuit"
	color = "black"
/obj/item/weapon/clothing/under/white
	icon_state = "w_suit"
	name = "White Jumpsuit"
	desc = "Made of a special fiber that gives special protection against biohazards"
	color = "white"
	fb_filter = 5
/obj/item/weapon/clothing/under/green
	icon_state = "g_suit"
	name = "Green Jumpsuit"
	color = "green"
/obj/item/weapon/clothing/suit/firesuit
	fb_filter = 6
	h_filter = 6
	a_filter = 4
	s_istate = "fire_suit"
	icon_state = "firesuit"
	flags = 266
	s_fire = 7.5e+07
/obj/item/weapon/tank
	var/maximum
	var/obj/substance/gas/gas
	var/i_used = 350
	flags = 323
	weight = 1e+06
	force = 5
	throwforce = 10
	throwspeed = 4
/obj/item/weapon/clothing/suit/straight_jacket
	icon_state = "straight_jacket"
	s_istate = "straight_jacket"
	s_fire = 1.875e+07
/obj/item/weapon/clothing/suit/armor
	icon_state = "armor"
	s_istate = "armor"
	s_fire = 1.875e+07
/obj/item/weapon/clothing/suit/robot_suit
	fb_filter = 9
	a_filter = 9
	h_filter = 9
	icon_state = "ro_suit"
	s_istate = "ro_suit"
	flags = 266
	s_fire = 1.875e+07
/obj/item/weapon/clothing/suit/bio_suit
	fb_filter = 9
	a_filter = 9
	h_filter = 9
	icon_state = "bio_suit"
	s_istate = "bio_suit"
	flags = 266
	s_fire = 3e+06
/obj/item/weapon/clothing/suit/swat_suit
	fb_filter = 6; h_filter = 6; a_filter = 4
	icon_state = "swat_suit"
	s_istate = "swat_suit"
	flags = 266
	s_fire = 67500000.0
/obj/item/weapon/clothing/suit/sp_suit
	fb_filter = 6
	h_filter = 6
	a_filter = 4
	icon_state = "s_suit"
	s_istate = "s_suit"
	flags = 266
	s_fire = 6.75e+07
/obj/item/weapon/clothing/mask/robot/swat
	name = "SWAT Mask"














/obj/item/weapon/clothing/mask/robot
	flags = 266
	w_class = 3
	fb_filter = 5
	a_filter = 6
	see_face = 0
	name = "Robot Mask"
	icon_state = "r_head"
	s_istate = "r_head"
	s_fire = 75000000.0
/obj/item/weapon/clothing/mask/gasmask
	flags = 266
	w_class = 3
	fb_filter = 5
	a_filter = 6
	see_face = 0
	s_istate = "gas_mask"
	s_fire = 7.5e+07
	icon_state = "mask"

/obj/item/weapon/clothing/mask/gasmask/burn(fi_amount)
	if(fi_amount > 7.5e7)
		spawn(0)
			var/t = icon_state
			icon_state = ""
			icon = 'b_items.dmi'
			flick("[t]", src)
			spawn(14)
				del(src)
/obj/item/weapon/clothing/mask/m_mask
	flags = 270
	w_class = 3
	fb_filter = 4
	a_filter = 6
	name = "Medical Mask"
	icon_state = "m_mask"
	s_istate = "m_mask"
	desc = "This mask does not work very well in low pressure environments."
	s_fire = 18750000.0
/obj/item/weapon/clothing/mask/m_mask/burn(fi_amount)
	if(fi_amount > 5e7)
		spawn(0)
			var/t = icon_state
			icon_state = ""
			icon = 'b_items.dmi'
			flick("[t]", src)
			spawn(14)
				del(src)
/obj/item/weapon/clothing/mask/muzzle
	w_class = 2
	a_filter = 3
	icon_state = "muzzle"
	s_istate = "muzzle"; s_fire = 18750000.0
/obj/item/weapon/clothing/mask/muzzle/attack_paw(mob/user)
	if(src == user:wear_mask)
		return
	else ..()

/obj/item/weapon/clothing/mask/muzzle/burn(fi_amount)
	if(fi_amount > 3e7)
		spawn(0)
			var/t = icon_state
			icon_state = ""
			icon = 'b_items.dmi'
			flick("[t]", src)
			spawn(14)
				del(src)
/obj/item/weapon/clothing/mask/surgical
	w_class = 1
	flags = 262
	fb_filter = 5
	a_filter = 6
	icon_state = "s_mask"
	s_istate = "s_mask"
	name = "Sterile Mask"
	s_fire = 18750000.0
/obj/item/weapon/clothing/mask/surgical/burn(fi_amount)
	if(fi_amount > 5e7)
		spawn(0)
			var/t = icon_state
			icon_state = ""
			icon = 'b_items.dmi'
			flick("[t]", src)
			spawn(14)
				del(src)






/obj/item/weapon/tank/attack_self(mob/user)
	user:machine = src
	var/dat = {"<TT><B>Tank</B><BR>
<FONT color = 'blue'><B>Contains/Capacity</B> [gas:tot_gas()] / [maximum]</FONT><BR>
Interals Valve: <A href='?src=\ref[src];stat=1'>[loc == user && user:internal == src ? "Stop" : "Restore"] Gas Flow</A><BR>
\t<A href='?src=\ref[src];cp=-50'>-</A> <A href='?src=\ref[src];cp=-5'>-</A> <A href='?src=\ref[src];cp=-1'>-</A> [i_used] <A href='?src=\ref[src];cp=1'>+</A> <A href='?src=\ref[src];cp=5'>+</A> <A href='?src=\ref[src];cp=50'>+</A><BR>
<BR>
<A href='?src=\ref[user];mach_close=tank'>Close</A>
</TT>"}
	user << browse(dat, "window=tank;size=600x300")



/obj/item/weapon/tank/Topic(href, href_list)
	if(usr.stat) return
	if(loc == usr)
		usr.machine = src
		if(href_list["cp"])
			var/cp = text2num(href_list["cp"])
			i_used += cp
			i_used = min(max(round(i_used), 0), 10000)
		if(href_list["stat"] && loc == usr)
			if(usr.internal == src)
				usr.internal = null
				return
			if(usr.internal) usr.internal = null
			if(!usr.wear_mask || !(usr.wear_mask:flags & 8)) return
			usr.internal = src
			usr << "\blue Now running on internals!"
		add_fingerprint(usr)
		for(var/mob/M in view(1, src.loc))
			if(M:client && M:machine == src) attack_self(M)
	else
		usr << browse(null, "window=tank")
		return
/obj/item/weapon/tank/proc/process(mob/M, G as obj)
	var/amount = i_used
	var/total = gas:tot_gas()
	if(amount > total) amount = total
	if(total > 0)
		G:transfer_from(gas, amount)
	return G


































/obj/item/weapon/tank/attack(mob/M, mob/user)
	..()
	if(prob(30) && M:stat < 2)
		var/mob/human/H = M
		if(istype(H, /mob/human) && (istype(H, /obj/item/weapon/clothing/head) && (H:flags & 8 && prob(80))))
			M << "\red The helmet protects you from being hit hard in the head!"
			return
		var/time = rand(10, 120)
		if(prob(90))
			if(M:paralysis < time)
				M:paralysis = time
		else
			if(M:stunned < time)
				M:stunned = time

		M:stat = 1
		for(var/mob/O in view(M))
			if(O:client && !O:blinded)
				O << "\red<B>[M] has been knocked unconscious!</B>"
		M << "\red<B>This was a [time * 100 / 120]% hit. Roleplay it! (personality/memory change if the hit was severe enough)</B>"
/obj/item/weapon/tank/New()
	..()
	gas = new /obj/substance/gas(src)
	gas:maximum = maximum
/obj/item/weapon/tank/Del()
	del(gas)
	return




/obj/item/weapon/tank/examine()
	set src in view(1)
	usr << "\blue The \icon[src] contains [gas:tot_gas()] unit\s of gas."

/obj/item/weapon/tank/oxygentank
	icon_state = "oxygen"
	maximum = 1.75e+06
/obj/item/weapon/tank/oxygentank/New()
	..()
	gas:oxygen = maximum
/obj/item/weapon/tank/jetpack
	maximum = 3.5e+06
	w_class = 4
	icon_state = "jetpack0"
	s_istate = "jetpack"
	var/on = 0
/obj/item/weapon/tank/jetpack/New()
	..()
	gas:oxygen = maximum

/obj/item/weapon/tank/jetpack/verb/toggle()
	on = !on
	icon_state = "jetpack[on]"
/obj/item/weapon/tank/jetpack/proc/allow_thrust(num, mob/user)
	if(!on) return 0
	if(num < 1 || gas:tot_gas() < num) return 0
	var/obj/substance/gas/G = new /obj/substance/gas()
	G:transfer_from(gas, num)
	if(G:oxygen >= 100) return 1
	if(G:plasma > 10)
		if(user)
			var/d = G:plasma / 2
			d = min(abs(user:health + 100), d, 25)
			user:fireloss += d
			user:health = 100 - user:oxyloss - user:toxloss - user:fireloss - user:bruteloss
		return G:oxygen >= 75 ? 0.5 : 0
	else if(G:oxygen >= 75) return 0.5
	else return 0
	del(G)
/obj/item/weapon/tank/anesthetic
	icon_state = "an_tank"
	maximum = 1.75e+06
	i_used = 1
/obj/item/weapon/tank/anesthetic/New()
	..()
	gas:sl_gas = 1000
/obj/item/weapon/tank/plasmatank
	icon_state = "plasma"
	maximum = 1.6e+06
/obj/item/weapon/tank/plasmatank/proc/ignite()
	if(gas:plasma < 1600000 || gas:temperature < 500)
		var/turf/T = get_turf(loc)
		T:poison += gas:plasma
		T:firelevel = T:poison
		T:res_vars()
		if(gas:temperature > 450 && gas:plasma == 1600000)
			var/sw = locate(max(T:x - 4, 1), max(T:y - 4, 1), T:z)
			var/ne = locate(min(T:x + 4, world.maxx), min(T:y + 4, world.maxy), T:z)
			for(var/turf/U as turf in block(sw, ne))
				var/zone = 4
				if(U:y <= T:y + 1 && (U:y >= T:y - 1 && (U:x <= T:x + 2 && U:x >= T:x - 2))) zone = 3
				if(U:y <= T:y + 1 && (U:y >= T:y - 1 && (U:x <= T:x + 1 && U:x >= T:x - 1))) zone = 2
				for(var/atom/A in U)
					A:ex_act(zone)
				U:ex_act(zone)
		else if(gas:temperature > 300 && gas:plasma == 1600000)
			var/sw = locate(max(T:x - 4, 1), max(T:y - 4, 1), T:z)
			var/ne = locate(min(T:x + 4, world.maxx), min(T:y + 4, world.maxy), T:z)
			for(var/turf/U as turf in block(sw, ne))
				var/zone = 4
				if(U:y <= T:y + 2 && (U:y >= T:y - 2 && (U:x <= T:x + 2 && U:x >= T:x - 2))) zone = 3
				for(var/atom/A in U)
					A:ex_act(zone)
				U:ex_act(zone)
		del(master)
		del(src)
		return
	var/turf/T = loc
	while(!istype(T, /turf)) T = T:loc
	master:loc = null
	for(var/mob/M in range(T))
		flick("flash", M:flash)




	var/m_range = 2
	for(var/obj/machinery/atmoalter/canister/C in range(2, T))
		if(!C:destroyed)
			if(C:gas:plasma >= 35000)
				C:destroyed = 1
				m_range++
	var/min = m_range
	var/med = m_range * 2
	var/max = m_range * 3
	var/u_max = m_range * 4
	var/sw = locate(max(T:x - u_max, 1), max(T:y - u_max, 1), T:z)
	var/ne = locate(min(T:x + u_max, world.maxx), min(T:y + u_max, world.maxy), T:z)
	for(var/turf/U as turf in block(sw, ne))
		var/zone = 4
		if(U:y <= T:y + max && (U:y >= T:y - max && (U:x <= T:x + max && U:x >= T:x - max))) zone = 3
		if(U:y <= T:y + med && (U:y >= T:y - med && (U:x <= T:x + med && U:x >= T:x - med))) zone = 2
		if(U:y <= T:y + min && (U:y >= T:y - min && (U:x <= T:x + min && U:x >= T:x - min))) zone = 1
		for(var/atom/A in U)
			A:ex_act(zone)
		U:ex_act(zone)








	del(master)
	del(src)
/obj/item/weapon/tank/plasmatank/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/assembly/rad_ignite))
		var/S = W
		if(!S:status) return
		var/R = new /obj/item/weapon/assembly/r_i_ptank(user)
		R:part1 = S:part1
		S:part1:loc = R
		S:part1:master = R
		R:part2 = S:part2
		S:part2:loc = R
		S:part2:master = R

		S:layer = initial(S:layer)
		if(user:client) user:client:screen -= S

		if(user:r_hand == S)
			user:u_equip(S)
			user:r_hand = R
		else
			user:u_equip(S)
			user:l_hand = R

		master = R
		layer = initial(layer)
		user:u_equip(src)
		if(user:client) user:client:screen -= src
		loc = R

		R:part3 = src
		R:layer = 20
		R:loc = user

		S:part1 = null
		S:part2 = null

		del(S)
	if(istype(W, /obj/item/weapon/assembly/prox_ignite))
		var/S = W
		if(!S:status) return
		var/R = new /obj/item/weapon/assembly/m_i_ptank(user)
		R:part1 = S:part1
		S:part1:loc = R
		S:part1:master = R
		R:part2 = S:part2
		S:part2:loc = R
		S:part2:master = R

		S:layer = initial(S:layer)
		if(user:client) user:client:screen -= S

		if(user:r_hand == S)
			user:u_equip(S)
			user:r_hand = R
		else
			user:u_equip(S)
			user:l_hand = R

		master = R
		layer = initial(layer)
		user:u_equip(src)
		if(user:client) user:client:screen -= src
		loc = R

		R:part3 = src
		R:layer = 20
		R:loc = user

		S:part1 = null
		S:part2 = null

		del(S)
/obj/item/weapon/tank/plasmatank/New()
	..()
	gas:plasma = maximum




/obj/machinery/igniter
	icon_state = "igniter1"
	icon = 'stationobjs.dmi'
	anchored = 1
	var/on = 1
/obj/machinery/igniter/attack_paw(mob/user)
	if(ticker && ticker:mode == "monkey")
		return attack_hand(user)
/obj/machinery/igniter/attack_hand(mob/user)
	..()
	on = !on
	icon_state = "igniter[on]"
	add_fingerprint(user)
/obj/machinery/igniter/process()
	if(on)
		var/T = loc
		if(locate(/obj/move) in T) T = locate(/obj/move) in T
		if(T:firelevel < 2000000) T:firelevel = T:poison
/obj/machinery/firealarm
	icon_state = "firealarm"
	var/detecting = 1
	var/working = 1
	icon = 'items.dmi'
	anchored = 1
	var/time = 10
	var/timing = 0
/obj/machinery/firealarm/burn(fi_amount)
	alarm()
/obj/machinery/firealarm/attack_paw(mob/user)
	return attack_hand(user)
/obj/machinery/firealarm/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/wirecutters))
		detecting = !detecting
		if(detecting)
			view(user) << "\red[user] has reconnected [src]'s detecting unit!"
		else
			view(user) << "\red[user] has disconnected [src]'s detecting unit!"
	else
		alarm()
	add_fingerprint(user)
/obj/machinery/firealarm/process()
	if(timing)
		if(time > 0)
			time = round(time) - 1
		else
			alarm()
			time = 0
			timing = 0
		for(var/mob/M in view(1, src))
			if(M:client && M:machine == src) attack_hand(M)
/obj/machinery/firealarm/attack_hand(mob/user)
	user:machine = src
	var/d1
	var/d2
	var/A = loc
	if(istype(user, /mob/human))
		A = A:loc
		if(A:fire) d1 = "<A href='?src=\ref[src];reset=1'>Reset - Lockdown</A>"
		else d1 = "<A href='?src=\ref[src];alarm=1'>Alarm - Lockdown</A>"
		if(timing) d2 = "<A href='?src=\ref[src];time=0'>Stop Time Lock</A>"
		else d2 = "<A href='?src=\ref[src];time=1'>Initiate Time Lock</A>"
		var/second = time % 60
		var/minute = (time - second) / 60
		var/dat = {"<HTML><HEAD></HEAD><BODY><TT><B>Fire alarm</B> [d1]
<HR>
Timer System: [d2]<BR>
Time Left: [minute ? "[minute]:" : null][second] <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>
</TT></BODY></HTML>"}
		user << browse(dat, "window=firealarm")
	else
		A = A:loc
		if(A:fire) d1 = "<A href='?src=\ref[src];reset=1'>[stars("Reset - Lockdown")]</A>"
		else d1 = "<A href='?src=\ref[src];alarm=1'>[stars("Alarm - Lockdown")]</A>"
		if(timing) d2 = "<A href='?src=\ref[src];time=0'>[stars("Stop Time Lock")]</A>"
		else d2 = "<A href='?src=\ref[src];time=1'>[stars("Initiate Time Lock")]</A>"
		var/second = time % 60
		var/minute = (time - second) / 60
		var/dat = {"<HTML><HEAD></HEAD><BODY><TT><B>[stars("Fire alarm")]</B> [d1]
<HR>
Timer System: [d2]<BR>
Time Left: [minute ? "[minute]:" : null][second] <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>
</TT></BODY></HTML>"}
		user << browse(dat, "window=firealarm")
/obj/machinery/firealarm/Topic(href, href_list)
	if(usr.stat) return
	if(usr.contents:Find(src) || get_dist(src, usr) <= 1 && istype(loc, /turf))
		usr.machine = src
		if(href_list["reset"])
			reset()
		else if(href_list["alarm"])
			alarm()
		else if(href_list["time"])
			timing = text2num(href_list["time"])
		else if(href_list["tp"])
			var/tp = text2num(href_list["tp"])
			time += tp
			time = min(max(round(time), 0), 120)
		for(var/mob/M in view(1, src))
			if(M:client && M:machine == src) attack_hand(M)
		add_fingerprint(usr)
	else
		usr << browse(null, "window=firealarm")
		return
/obj/machinery/firealarm/proc/reset()
	if(!working) return
	var/A = loc
	A = A:loc
	if(!istype(A, /area)) return
	A:fire = 0
	if(A:icon_state == "blue-red") A:icon_state = "red"
	else A:icon_state = null
	for(var/obj/machinery/door/firedoor/D in A)
		if(D:density)
			spawn(0) D:openfire()
/obj/machinery/firealarm/proc/alarm()
	if(!working) return
	var/A = loc
	A = A:loc
	if(!istype(A, /area)) return
	A:firealert()
/obj/machinery/door
	icon_state = "door1"
	var/visible = 1
	var/r_air = 0
	var/r_engine = 0
	var/r_access = 0
	var/r_lab = 0
	var/p_open = 0
	opacity = 1
	density = 1
/obj/machinery/door/meteorhit(obj/M)
	open()
/obj/machinery/door/Move()
	..()
	if(density)
		var/location = loc
		if(istype(location, /turf))
			location:updatecell = 0
/obj/machinery/door/attackby(obj/I, mob/user)
	if(operating) return
	add_fingerprint(user)
	var/obj/item/weapon/card/id/card
	if(istype(usr, /mob/human))
		var/H = usr
		card = H:wear_id
	if(istype(I, /obj/item/weapon/card/id))
		card = I
	if(!istype(card, /obj/item/weapon/card/id))
		return 0
	if(card:air_access >= r_air && (card:lab_access >= r_lab && (card:engine_access >= r_engine && card:access_level >= r_access)))
		if(density) open()
		else close()
	else
		user << "\blue[card] does not have the sufficient access level."
/obj/machinery/door/anchored = 1
/obj/machinery/door/window/close()
	..()
	var/T = loc
	if(T) T:updatecell = 1
/obj/machinery/door/window/New()
	..()
	var/T = loc
	if(T) T:updatecell = 1
	if(r_air || (r_engine || (r_access || r_lab)))
		icon = 'security.dmi'
/obj/machinery/door/window
	name = "interior door"
	icon = 'windoor.dmi'
	opacity = 0
	visible = 0
/obj/machinery/door/window/Bumped(AM as mob|obj)
	if(!ismob(AM)) return
	if(!ticker) return
	if(operating) return
	if(r_air == 0 && (r_engine == 0 && (r_lab == 0 && r_access == 0)))
		open()
		sleep(50)
		close()
/obj/machinery/door/window/CheckPass(O as mob|obj, turf/target)
	if(density)
		var/direct = get_dir(O, target)
		if(direct == NORTH && dir & 12)
			return 0
		else if(direct == WEST && dir & 3) return 0
	return 1
/obj/machinery/door/window/CheckExit(O as mob|obj, turf/target)
	if(density)
		var/direct = get_dir(O, target)
		if(direct == SOUTH && dir & 12)
			return 0
		else if(direct == EAST && dir & 3) return 0
	return 1
/obj/machinery/door/window/attack_to(mob/attacker, target as mob|obj|turf|area)
	return CheckPass(attacker, target)
/obj/machinery/door/window/attack_from(mob/attacker, target as mob|obj|turf|area)
	return CheckExit(attacker, target)
/obj/machinery/door/false_wall
	name = "wall"
	icon = 'Doorf.dmi'
/obj/machinery/door/false_wall/New()
	verbs -= /atom/movable/verb/pull
/obj/machinery/door/false_wall/examine()
	usr << "It looks like a regular wall"
/obj/machinery/door/false_wall/attack_paw(mob/user)
	if(ticker && ticker:mode == "monkey")
		return attack_hand(user)
/obj/machinery/door/false_wall/attack_hand(mob/user)
	add_fingerprint(user)
	if(density)
		if(prob(25)) open()
		else user << "\blue You push the wall but nothing happens!"
	else close()
/obj/machinery/door/false_wall/attackby(obj/S, mob/user)
	add_fingerprint(user)
	if(istype(S, /obj/item/weapon/screwdriver))
		new /obj/item/weapon/sheet/metal(loc)
		new /obj/d_girders(loc)
		del(src)
	else ..()
/obj/machinery/door/airlock
	var/blocked
	var/powered = 1
	var/locked = 0
	var/wires = 511
	icon = 'Door1.dmi'
/obj/machinery/door/airlock/proc/update()
	if((!(wires & 2) || (!(wires & 8) || (!(wires & 32) || (!(wires & 64) || (!(wires & 128) || !(wires & 256)))))) && powered)
		locked = 1
	if(!(wires & 1) && (!(wires & 4) && !(wires & 16)))
		powered = 0
	else
		powered = 1
/obj/machinery/door/airlock/attack_paw(mob/user)
	return attack_hand(user)
/obj/machinery/door/airlock/attack_hand(mob/user)
	if(p_open)
		user:machine = src
		lbl1
		var/t1 = {"<B>Access Panel</B><br>
Orange Wire: [wires & 256 ? "<A href='?src=\ref[src];wires=256'>Cut Wire</A>" : "<A href='?src=\ref[src];wires=256'>Mend Wire</A>"]<br>
Dark Red Wire:   [wires & 128 ? "<A href='?src=\ref[src];wires=128'>Cut Wire</A>" : "<A href='?src=\ref[src];wires=128'>Mend Wire</A>"]<br>
White Wire:  [wires & 64 ? "<A href='?src=\ref[src];wires=64'>Cut Wire</A>" : "<A href='?src=\ref[src];wires=64'>Mend Wire</A>"]<br>
Yellow Wire: [wires & 32 ? "<A href='?src=\ref[src];wires=32'>Cut Wire</A>" : "<A href='?src=\ref[src];wires=32'>Mend Wire</A>"]<br>
Red Wire:   [wires & 16 ? "<A href='?src=\ref[src];wires=16'>Cut Wire</A>" : "<A href='?src=\ref[src];wires=16'>Mend Wire</A>"]<br>
Blue Wire:  [wires & 8 ? "<A href='?src=\ref[src];wires=8'>Cut Wire</A>" : "<A href='?src=\ref[src];wires=8'>Mend Wire</A>"]<br>
Green Wire: [wires & 4 ? "<A href='?src=\ref[src];wires=4'>Cut Wire</A>" : "<A href='?src=\ref[src];wires=4'>Mend Wire</A>"]<br>
Grey Wire:   [wires & 2 ? "<A href='?src=\ref[src];wires=2'>Cut Wire</A>" : "<A href='?src=\ref[src];wires=2'>Mend Wire</A>"]<br>
Black Wire:  [wires & 1 ? "<A href='?src=\ref[src];wires=1'>Cut Wire</A>" : "<A href='?src=\ref[src];wires=1'>Mend Wire</A>"]<br>
<br>
[locked ? "The door bolts have fallen!" : "The door bolts look up."]<br>
[powered ? "The test light is on." : "The test light is off!"]"}
		user << browse(t1, "window=airlock")
/obj/machinery/door/airlock/Topic(href, href_list)
	if(usr.stat) return
	if(get_dist(src, usr) <= 1 && istype(loc, /turf))
		usr.machine = src
		if(href_list["wires"])
			var/t1 = text2num(href_list["wires"])
			if(!istype(usr.equipped(), /obj/item/weapon/wirecutters)) return
			if(!p_open) return
			if(t1 & 1)
				if(wires & 1)
					wires &= 65534
				else
					wires |= 1
			else if(t1 & 2)
				if(wires & 2)
					wires &= 65533
				else
					wires |= 2
			else if(t1 & 4)
				if(wires & 4)
					wires &= 65531
				else
					wires |= 4
			else if(t1 & 8)
				if(wires & 8)
					wires &= 65527
				else
					wires |= 8
			else if(t1 & 16)
				if(wires & 16)
					wires &= 65519
				else
					wires |= 16
			else if(t1 & 32)
				if(wires & 32)
					wires &= 65503
				else
					wires |= 32
			else if(t1 & 64)
				if(wires & 64)
					wires &= 65471
				else
					wires |= 64
			else if(t1 & 128)
				if(wires & 128)
					wires &= 65407
				else
					wires |= 128
			else if(t1 & 256)
				if(wires & 256)
					wires &= 65279
				else
					wires |= 256
	update()
	add_fingerprint(usr)
	for(var/mob/M in view(1, src))
		if(M:client && M:machine == src) attack_hand(M)

/obj/machinery/door/airlock/attackby(obj/C, mob/user)
	add_fingerprint(user)
	if(istype(C, /obj/item/weapon/weldingtool) && (!operating && density))
		var/W = C
		if(W:weldfuel > 2)
			W:weldfuel -= 2
		if(!blocked)
			blocked = 1
			icon_state = "[p_open ? "o_" : null]doorl"
		else
			blocked = null
			icon_state = "[p_open ? "o_" : null]door1"
		return
	else if(istype(C, /obj/item/weapon/wrench))
		if(p_open)
			if(powered)
				locked = null
			else user << alert("You need power assist!")
		update()
	else if(istype(C, /obj/item/weapon/screwdriver))
		p_open = !p_open
		var/d
		d = density
		if(locked) d = "l"
		icon_state = "[p_open ? "o_" : null]door[d]"
		update()
	else if(istype(C, /obj/item/weapon/crowbar))
		if(density && (!blocked && (!operating && (!powered && !locked))))
			spawn(0)
				operating = 1
				flick("[p_open ? "o_" : null]doorc0", src)
				icon_state = "[p_open ? "o_" : null]door0"
				sleep(15)
				density = 0
				opacity = 0
				var/T = loc
				if(istype(T, /turf))
					T:updatecell = 1
				operating = 0
	else ..()
/obj/machinery/door/airlock/open()
	if(blocked || (locked || !powered))
		return
	..()
/obj/machinery/door/airlock/close()
	if(!powered) return
	..()
	var/T = loc
	if(T) T:firelevel = 0
/obj/machinery/door/icon = 'doors.dmi'
/obj/machinery/dispenser{desc = "A simple yet bulky one-way storage device for gas tanks. Holds 10 plasma and 10 oxygen tanks."; icon_state = "dispenser"; name = "Tank Storage Unit"; var/o2tanks = 10; var/pltanks = 10}
/obj/machinery/dna_scanner
	icon_state = "scanner_0"
	name = "DNA Scanner/Implanter"
/obj/machinery/door/firedoor/open()
	usr << "This is a remote firedoor!"
/obj/machinery/door/firedoor/close()
	usr << "This is a remote firedoor!"

/obj/machinery/door/firedoor/attackby(obj/C, mob/user)
	add_fingerprint(user)
	if(istype(C, /obj/item/weapon/weldingtool) && (!operating && density))
		var/W = C
		if(W:weldfuel > 2)
			W:weldfuel -= 2
		if(!blocked)
			blocked = 1
			icon_state = "doorl"
		else
			blocked = 0
			icon_state = "door1"
		return
	else if(!istype(C, /obj/item/weapon/crowbar)) return
	if(density && (!blocked && !operating))
		spawn(0)
			operating = 1
			flick("doorc0", src)
			icon_state = "door0"
			sleep(15)
			density = 0
			opacity = 0
			var/T = loc
			if(istype(T, /turf))
				T:updatecell = 1
			operating = 0
/obj/machinery/door/firedoor/proc/openfire()
	set src in oview(1)
	if(operating || blocked) return
	operating = 1
	flick("doorc0", src)
	icon_state = "door0"
	sleep(15)
	density = 0
	opacity = 0
	var/T = loc
	if(istype(T, /turf))
		T:updatecell = 1
	operating = 0
/obj/machinery/door/firedoor/proc/closefire()
	set src in oview(1)
	if(operating) return
	operating = 1
	flick("doorc1", src)
	icon_state = "door1"
	density = 1
	opacity = 1
	var/T = loc
	if(istype(T, /turf))
		T:updatecell = 0
		T:firelevel = 0
	sleep(15)
	operating = 0
/obj/machinery/door/firedoor
	icon_state = "door0"
	var/blocked
	icon = 'Door1.dmi'
	opacity = 0
/obj/machinery/door
	var/operating
/obj/machinery/door/New()
	..()
	var/T = loc
	if(istype(T, /turf))
		if(density) T:updatecell = 0
/obj/machinery/door/proc/open()
	if(operating) return
	operating = 1
	flick("[p_open ? "o_" : null]doorc0", src)
	icon_state = "[p_open ? "o_" : null]door0"
	sleep(15)
	density = 0
	opacity = 0
	var/T = loc
	if(istype(T, /turf))
		T:updatecell = 1
	operating = 0
/obj/machinery/door/proc/close()
	if(operating) return
	operating = 1
	flick("[p_open ? "o_" : null]doorc1", src)
	icon_state = "[p_open ? "o_" : null]door1"
	density = 1
	if(visible) opacity = 1
	var/T = loc
	if(istype(T, /turf))
		T:updatecell = 0
	sleep(15)
	operating = 0
/obj/grille
	icon_state = "grille"
	desc = "A piece of metal with evenly spaced gridlike holes in it. Blocks large projectile type object but lets small items or energy beams through."
	icon = 'turfs2.dmi'
	density = 1
	anchored = 1
	flags = 64
	var/health = 10
	var/destroyed = 0
/obj/grille/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			if(prob(50)) del(src)
		if(3)
			if(prob(25))
				health -= 11
				healthcheck()
/obj/grille/meteorhit()
	if(icon_state == "flaming")
		health -= 3
		healthcheck()
/obj/grille/CheckPass(obj/B)
	if(istype(B, /obj/effects) || (istype(B, /obj/beam) || istype(B, /obj/meteor/small))) return 1
	else return !density
/obj/grille/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/wirecutters))
		health = 0
	else if(istype(W, /obj/item/weapon/screwdriver) && (istype(loc, /turf/station) || anchored))
		anchored = !anchored
		user << (anchored ? "You have fastened the grille to the floor." : "You have unfastened the grill.")
	else
		switch(W:damtype)
			if("fire")
				health -= W:force
			if("brute")
				health -= W:force * 0.1
	healthcheck()
	..()
/obj/machinery/door/firedoor/density = 0
/obj/grille/proc/healthcheck()
	if(health <= 0)
		if(!destroyed)
			icon_state = "brokengrille"
			density = 0
			destroyed = 1
			new /obj/item/weapon/rods(loc)
		else
			if(health <= -10)
				new /obj/item/weapon/rods(loc)
				del(src)






/obj/window{icon_state = "window"; var/health = 14}
/obj/window/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			new /obj/item/weapon/shard(loc)
			del(src)
		if(3)
			if(prob(50))
				new /obj/item/weapon/shard(loc)
				del(src)
/obj/window/CheckPass(O as mob|obj, turf/target)
	if(istype(O, /obj/beam)) return 1
	if(dir == SOUTHWEST) return 0
	else if(get_dir(target, O:loc) == dir) return 0
	return 1
/obj/window/CheckExit(O as mob|obj, turf/target)
	if(istype(O, /obj/beam)) return 1
	if(get_dir(O:loc, target) == dir) return 0
	return 1
/obj/window/meteorhit()
	health = 0
	new /obj/item/weapon/shard(loc)
	del(src)
/obj/window/attack_to(mob/attacker, target as mob|obj|turf|area)
	return CheckPass(attacker, target)
/obj/window/attack_from(mob/attacker, target as mob|obj|turf|area)
	return CheckExit(attacker, target)
/obj/window/hitby(obj/W)
	..()
	health = max(0, health - W:throwforce)
	if(health <= 7)
		anchored = 0
		step(src, get_dir(W, src))
	if(health <= 0)
		new /obj/item/weapon/shard(loc)
		del(src)
	..()
/obj/window/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/screwdriver))
		anchored = !anchored
		user << (anchored ? "You have fastened the window to the floor." : "You have unfastened the window.")
	else
		health = max(0, health - W:force)
		if(health <= 7)
			anchored = 0
			step(src, get_dir(user, src))
		if(health <= 0)
			if(dir == SOUTHWEST)
				for(var/index = 0, index < 2, index++)
					new /obj/item/weapon/shard(loc)
			else
				new /obj/item/weapon/shard(loc)
			del(src)
		..()

/obj/window/verb/rotate()
	set src in oview(1)
	if(anchored)
		usr << "It is fastened to the floor; therefore, you can't rotate it!"
		return 0
	else if(dir == SOUTHWEST)
		usr << "You can't rotate this! "
		return 0
	dir = turn(dir, 90)
	ini_dir = dir
/obj/window{var/ini_dir}
/obj/window/New()
	..()
	ini_dir = dir
/obj/window/Move()
	..()
	dir = ini_dir


/obj/window
	icon = 'turfs2.dmi'
	density = 1
	weight = 2.5e+06
	anchored = 1




/turf/station/r_wall
	icon_state = "r_wall"
	var/state = 2; var/d_state = 0
/turf/station/r_wall/updatecell()
	if(state == 2) return
	else ..()
/turf/station/r_wall/proc/update()
	if(d_state > 6)
		d_state = 0
		state = 1
	if(state == 2)
		icon_state = "r_wall[d_state > 0 ? "-[d_state]" : null]"
		opacity = 1
		density = 1
		updatecell = 0
	else
		icon_state = "r_girder"
		opacity = 0
		density = 1
		updatecell = 1
/turf/station/r_wall/unburn()
	update()
/turf/station/r_wall/meteorhit(obj/M)
	if(M:icon_state == "flaming" && prob(30))
		if(state == 2)
			state = 1
			new /obj/item/weapon/sheet/metal(src)
			new /obj/item/weapon/sheet/metal(src)
		else if(prob(20) && state == 1)
			state = 0
			var/F = new /turf/station/floor(locate(x, y, z))
			F:oxygen = 756000
			new /obj/item/weapon/sheet/metal(F)
			new /obj/item/weapon/sheet/metal(F)
		update()
/turf/station/r_wall/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			if(prob(75))
				opacity = 0
				updatecell = 1
				state = 1
				intact = 0
				new /obj/item/weapon/sheet/metal(src)
				new /obj/item/weapon/sheet/metal(src)
			else
				state = 0
				var/F = new /turf/station/floor(locate(x, y, z))
				F:burnt = 1
				F:health = 30
				F:icon_state = "Floor1"
				new /obj/item/weapon/sheet/metal(F)
				new /obj/item/weapon/sheet/metal(F)
		if(3)
			if(prob(15))
				opacity = 0
				updatecell = 1
				intact = 0
				state = 1
				new /obj/item/weapon/sheet/metal(src)
				new /obj/item/weapon/sheet/metal(src)
				icon_state = "girder"
	update()



/turf/station/r_wall
	icon = 'wall.dmi'
	opacity = 1
	density = 1

	updatecell = 0
/turf/station/r_wall/attackby(obj/W, mob/user)
	if(!istype(user, /mob/human) && (!ticker || ticker && ticker:mode != "monkey"))
		user << "\red You don't have the dexterity to do this!"
		return
	if(state == 2)
		if(istype(W, /obj/item/weapon/wrench))
			if(d_state == 4)
				var/T = user:loc
				user << "\blue Cutting support rods."
				sleep(40)
				if(user:loc == T && (user:equipped() == W && !user:stat))
					d_state = 5
		else if(istype(W, /obj/item/weapon/wirecutters))
			if(d_state == 0)
				d_state = 1
				new /obj/item/weapon/rods(src)
		else if(istype(W, /obj/item/weapon/weldingtool))
			if(d_state == 2)
				var/T = user:loc
				user << "\blue Slicing metal cover."
				sleep(60)
				if(user:loc == T && (user:equipped() == W && !user:stat))
					d_state = 3
			else if(d_state == 5)
				var/T = user:loc
				user << "\blue Removing support rods."
				sleep(100)
				if(user:loc == T && (user:equipped() == W && !user:stat))
					d_state = 6
					new /obj/item/weapon/rods(src)
		else if(istype(W, /obj/item/weapon/screwdriver))
			if(d_state == 1)
				var/T = user:loc
				user << "\blue Removing support lines."
				sleep(40)
				if(user:loc == T && (user:equipped() == W && !user:stat))
					d_state = 2
		else if(istype(W, /obj/item/weapon/crowbar))
			if(d_state == 3)
				var/T = user:loc
				user << "\blue Prying cover off."
				sleep(100)
				if(user:loc == T && (user:equipped() == W && !user:stat))
					d_state = 4
			else if(d_state == 6)
				var/T = user:loc
				user << "\blue Prying outer sheath off."
				sleep(100)
				if(user:loc == T && (user:equipped() == W && !user:stat))
					d_state = 7
					new /obj/item/weapon/sheet/metal(src)
		else if(istype(W, /obj/item/weapon/sheet/metal))
			var/T = user:loc
			user << "\blue Repairing wall."
			sleep(100)
			if(user:loc == T && (user:equipped() == W && (!user:stat && state == 2)))
				d_state = 0
				if(W:amount > 1)
					W:amount--
				else del(W)
	if(state == 1)
		if(istype(W, /obj/item/weapon/wrench))
			user << "\blue Now dismantling girders."
			var/T = user:loc
			sleep(100)
			if(user:loc == T && (user:equipped() == W && !user:stat))
				state = 0
				var/F = new /turf/station/floor(locate(x, y, z))
				F:oxygen = 756000
				new /obj/item/weapon/sheet/metal(F)
				new /obj/item/weapon/sheet/metal(F)
				new /obj/item/weapon/sheet/metal(F)
				new /obj/item/weapon/sheet/metal(F)
		else if(istype(W, /obj/item/weapon/sheet/r_metal))
			state = 2
			d_state = 0
			del(W)
	update()
/turf/station/wall/var/state = 2
/turf/station/wall/examine()
	usr << "It looks like a regular wall."
/turf/station/wall
	icon = 'wall.dmi'
	opacity = 1
/turf/station/wall/updatecell()
	if(src.state == 2) return
	else ..()
/turf/station/wall/density = 1
/turf/station/wall/updatecell = 0
/turf/station/wall/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			if(prob(50))
				opacity = 0
				updatecell = 1
				state = 1
				intact = 0
				new /obj/item/weapon/sheet/metal(src)
				new /obj/item/weapon/sheet/metal(src)
				icon_state = "girder"
			else
				state = 0
				var/F = new /turf/station/floor(locate(x, y, z))
				F:burnt = 1
				F:health = 30
				F:icon_state = "Floor1"
				new /obj/item/weapon/sheet/metal(F)
				new /obj/item/weapon/sheet/metal(F)
		if(3)
			if(prob(25))
				opacity = 0
				updatecell = 1
				intact = 0
				state = 1
				new /obj/item/weapon/sheet/metal(src)
				new /obj/item/weapon/sheet/metal(src)
				icon_state = "girder"
/turf/station/wall/unburn()
	if(state == 1)
		icon_state = "girder"
	else icon_state = ""
/turf/station/wall/attack_paw(mob/user)
	if(ticker && ticker:mode == "monkey")
		return attack_hand(user)
/turf/station/wall/attack_hand(mob/user)
	user << "\blue You push the wall but nothing happens!"
	add_fingerprint(user)
/turf/station/wall/attackby(obj/W, mob/user)
	if(!istype(user, /mob/human) && (!ticker || ticker && ticker:mode != "monkey"))
		user << "\red You don't have the dexterity to do this!"
		return
	if(istype(W, /obj/item/weapon/wrench) && state == 1)
		var/T = user:loc
		if(!istype(T, /turf)) return
		user << "\blue Now dissembling the reinforced girders. Please stand still. This is a long process."
		sleep(100)
		if(!istype(src, /turf/station/wall)) return
		if(user:loc == T && (state == 1 && user:equipped() == W))
			state = 0
			var/F = new /turf/station/floor(locate(x, y, z))
			F:oxygen = 756000
			new /obj/item/weapon/sheet/metal(F)
			new /obj/item/weapon/sheet/metal(F)
	else if(istype(W, /obj/item/weapon/screwdriver) && state == 1)
		var/T = user:loc
		if(!istype(T, /turf)) return
		user << "\blue Now dislodging girders."
		sleep(100)
		if(!istype(src, /turf/station/wall)) return
		if(user:loc == T && (state == 1 && user:equipped() == W))
			state = 0
			var/F = new /turf/station/floor(locate(x, y, z))
			F:oxygen = 756000
			new /obj/d_girders(F)
			new /obj/item/weapon/sheet/metal(F)
	else if(istype(W, /obj/item/weapon/sheet/r_metal) && state == 1)
		var/T = user:loc
		if(!istype(T, /turf)) return
		user << "\blue Now reinforcing girders."
		sleep(100)
		if(!istype(src, /turf/station/wall)) return
		if(user:loc == T && (state == 1 && user:equipped() == W))
			state = 0
			var/F = new /turf/station/r_wall(locate(x, y, z))
			F:oxygen = 756000
			F:icon_state = "r_girder"
			F:state = 1
			F:opacity = 0
			F:updatecell = 1
	else if(istype(W, /obj/item/weapon/weldingtool) && state == 2)
		var/T = user:loc
		if(!istype(T, /turf)) return
		var/WT = W
		if(WT:weldfuel < 5)
			user << "\blue You need more welding fuel to complete this task."
			return
		WT:weldfuel -= 5
		user << "\blue Now dissembling the outer wall plating. Please stand still."
		sleep(50)
		if(user:loc == T && (state == 2 && user:equipped() == W))
			opacity = 0
			updatecell = 1
			state = 1
			intact = 0
			new /obj/item/weapon/sheet/metal(src)
			new /obj/item/weapon/sheet/metal(src)
			icon_state = "girder"

/turf/station/wall/meteorhit(obj/M)
	if(M:icon_state == "flaming")
		icon_state = "girder"
		if(state == 2)
			state = 1
			opacity = 0
			updatecell = 1
			firelevel = 11
			new /obj/item/weapon/sheet/metal(src)
			new /obj/item/weapon/sheet/metal(src)
		else if(prob(20) && state == 1)
			state = 0
			var/F = new /turf/station/floor(locate(x, y, z))
			F:oxygen = 756000
			new /obj/item/weapon/sheet/metal(F)
			new /obj/item/weapon/sheet/metal(F)


/turf/station/floor{var/health = 150; icon_state = "Floor"; var/burnt}
/turf/station/floor/CheckPass(O as mob|obj)
	if(istype(O, /obj/machinery/pod) && !burnt)
		if(!(locate(/obj/machinery/mass_driver) in src))
			return 0
	return 1
/turf/station/floor/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			if(prob(50))
				del(src)
			else
				icon_state = "burning"
				burnt = 1
				health = 30
				intact = 0
				firelevel = 4000000
		if(3)
			if(prob(50))
				burnt = 1
				health = 1
				intact = 0
				icon_state = "Floor1"





/turf/station/floor/attack_paw(mob/user)
	return attack_hand(user)
/turf/station/floor/attack_hand(mob/user)
	if(!user:canmove || (user:restrained() || !user:pulling)) return
	if(user:pulling:anchored) return
	if(user:pulling:loc != user:loc && get_dist(user, user:pulling) > 1) return



	if(ismob(user:pulling))
		var/M = user:pulling
		var/t = M:pulling
		M:pulling = null
		step(user:pulling, get_dir(user:pulling:loc, src))
		M:pulling = t
	else
		step(user:pulling, get_dir(user:pulling:loc, src))
/turf/station/floor/attackby(obj/C, mob/user)
	if(istype(C, /obj/item/weapon/crowbar))
		if(health > 100)
			health = 100
			burnt = 1
			intact = 0
			new /obj/item/weapon/tile(src)
			icon_state = "Floor[burnt ? "1" : ""]"
	else if(istype(C, /obj/item/weapon/tile))
		if(health <= 100)
			intact = 1
			health = 150
			burnt = 0
			if(firelevel >= 2000000)
				icon_state = "burning"
			else
				icon_state = "Floor"
			var/T = C
			T:amount--
			if(T:amount < 1) del(T)
/turf/station/floor/unburn()
	icon_state = "Floor[burnt ? "1" : ""]"
/turf/station/floor/updatecell()
	..()
	if(checkfire)
		if(firelevel >= 6000000)
			health--
		if(health <= 0)
			burnt = 1
			intact = 0
			del(src)
		else if(health <= 100)
			burnt = 1
			intact = 0



/obj/machinery/dispenser/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			if(prob(50)) del(src)
		if(3)
			if(prob(25))
				for(, o2tanks > 0, o2tanks--)
					new /obj/item/weapon/tank/oxygentank(loc)
				for(, pltanks > 0, pltanks--)
					new /obj/item/weapon/tank/plasmatank(loc)







/obj/machinery/dispenser/meteorhit()
	for(, o2tanks > 0, o2tanks--)
		new /obj/item/weapon/tank/oxygentank(loc)
	for(, pltanks > 0, pltanks--)
		new /obj/item/weapon/tank/plasmatank(loc)
	del(src)
/obj/machinery/dispenser/attack_paw(mob/user)
	return attack_hand(user)
/obj/machinery/dispenser/attack_hand(mob/user)
	user:machine = src
	var/dat = {"<TT><B>Loaded Tank Dispensing Unit</B><BR>
<FONT color = 'blue'><B>Oxygen</B>: [o2tanks]</FONT> [o2tanks ? "<A href='?src=\ref[src];oxygen=1'>Dispense</A>" : "empty"]<BR>
<FONT color = 'orange'><B>Plasma</B>: [pltanks]</FONT> [pltanks ? "<A href='?src=\ref[src];plasma=1'>Dispense</A>" : "empty"]<BR>
</TT>"}
	user << browse(dat, "window=dispenser")
/obj/machinery/dispenser/Topic(href, href_list)
	if(usr.stat) return
	if(!istype(usr, /mob/human) && (!ticker || ticker && ticker:mode != "monkey"))
		usr << "\red You don't have the dexterity to do this!"
		return
	if(usr.contents:Find(src) || get_dist(src, usr) <= 1 && istype(loc, /turf))
		usr.machine = src
		if(href_list["oxygen"])
			if(text2num(href_list["oxygen"]))
				if(o2tanks > 0)
					new /obj/item/weapon/tank/oxygentank(loc)
					o2tanks--
			if(istype(loc, /mob))
				attack_hand(loc)
		else if(href_list["plasma"])
			if(text2num(href_list["plasma"]))
				if(pltanks > 0)
					new /obj/item/weapon/tank/plasmatank(loc)
					pltanks--
			if(istype(loc, /mob))
				attack_hand(loc)
		add_fingerprint(usr)
		for(var/mob/M in view(1, src))
			if(M:client && M:machine == src) attack_hand(M)
	else
		usr << browse(null, "window=dispenser")
		return
/turf/station/floor/grid
	icon_state = "grid"
	icon = 'weap_sat.dmi'

/obj/machinery/dispenser
	icon = 'turfs2.dmi'
	density = 1
	anchored = 1
/turf/station/floor
	name = "floor"
	icon = 'Icons.dmi'
	updatecell = 1
