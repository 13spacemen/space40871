


/turf/station/command/floor
	name = "floor"; icon_state = "Floor2"
	icon = 'Icons.dmi'
	updatecell = 1
/turf/station/command/floor/other
	icon_state = "Floor"
/turf/station/command/floor/updatecell()
	oxygen = 756000
	firelevel = 0
	co2 = 0
	poison = 0
	sl_gas = 0
	n2 = 0
/turf/station/command/floor/attack_paw(mob/user)
	return attack_hand(user)
/turf/station/command/floor/attack_hand(mob/user)
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






















/obj/begin
	icon_state = "begin"
	icon = 'stationobjs.dmi'
	anchored = 1
/turf/station/command/wall
	name = "wall"
	icon_state = "Wall2"
	icon = 'Icons.dmi'
	opacity = 1
	density = 1
	updatecell = 0
/turf/station/command/wall/other
	icon = 'wall.dmi'
	icon_state = "r_wall"





/obj/begin/verb/ready()
	set src in usr.loc
	if(!istype(usr, /mob/human) || usr.start)
		usr << "You have already started!"
		return
	var/mob/M = usr
	get_dna_ready(M)
	if(!M:w_uniform && !ticker)
		if(M:gender == "female")
			M:w_uniform = new /obj/item/weapon/clothing/under/pink(M)
		else
			M:w_uniform = new /obj/item/weapon/clothing/under/blue(M)
		M:w_uniform:layer = 20
		M:shoes = new /obj/item/weapon/clothing/shoes/brown(M)
		M:shoes:layer = 20
	else
		M << "You will have to find clothes from the station."
	if(ticker && !M:l_hand)
		var/obj/item/weapon/card/id/I = new /obj/item/weapon/card/id(M)
		var/choose
		var/L = list("Technical Assistant", "Research Assistant", "Staff Assistant", "Medical Assistant")
		if(L:Find(M:occupation1))
			choose = M:occupation1
		else
			choose = pick(L)
		switch(choose)
			if("Research Assistant")
				I:assignment = "Research Assistant"
				I:registered = M:rname
				I:access_level = 0
				I:lab_access = 0
				I:engine_access = 0
				I:air_access = 0
			if("Technical Assistant")
				I:assignment = "Technical Assistant"
				I:registered = M:rname
				I:access_level = 0
				I:lab_access = 0
				I:engine_access = 0
				I:air_access = 0
			if("Medical Assistant")
				I:assignment = "Medical Assistant"
				I:registered = M:rname
				I:access_level = 0
				I:lab_access = 0
				I:engine_access = 0
				I:air_access = 0
			if("Staff Assistant")
				I:assignment = "Staff Assistant"
				I:registered = M:rname
				I:access_level = 0
				I:lab_access = 0
				I:engine_access = 0
				I:air_access = 0
		I:name = "[I:registered]'s ID Card ([I:access_level]>[I:lab_access]-[I:engine_access]-[I:air_access])"
		I:layer = 20
		M:l_hand = I
	M:start = 1
	M:update_face()
/obj/begin/proc/get_dna_ready(mob/user)
	var/M = user
	if(!M:primary)
		M:r_hair = M:nr_hair
		M:b_hair = M:nb_hair
		M:g_hair = M:ng_hair
		M:ns_tone = rand(1, 100)
		M:s_tone = M:ns_tone

		var/t1 = rand(1000, 1500)
		dna_ident += t1
		if(dna_ident > 65536)
			dna_ident = rand(1, 1500)
		M:primary = new /obj/dna(null)
		M:primary:uni_identity = "[add_zero(num2hex(dna_ident), 4)]"






		var/t2 = add_zero(num2hex(M:nr_hair), 2)
		M:primary:uni_identity = "[M:primary:uni_identity][t2]"
		t2 = add_zero(num2hex(M:ng_hair), 2)
		M:primary:uni_identity = "[M:primary:uni_identity][t2]"
		t2 = add_zero(num2hex(M:nb_hair), 2)
		M:primary:uni_identity = "[M:primary:uni_identity][t2]"

		t2 = add_zero(num2hex(M:r_eyes), 2)
		M:primary:uni_identity = "[M:primary:uni_identity][t2]"
		t2 = add_zero(num2hex(M:g_eyes), 2)
		M:primary:uni_identity = "[M:primary:uni_identity][t2]"
		t2 = add_zero(num2hex(M:b_eyes), 2)
		M:primary:uni_identity = "[M:primary:uni_identity][t2]"

		t2 = add_zero(num2hex(M:s_tone), 2)
		M:primary:uni_identity = "[M:primary:uni_identity][t2]"
		t2 = M:gender == "male" ? "[num2hex(rand(1, 124))]" : "[num2hex(rand(127, 250))]"
		if(length(t2) < 2)
			M:primary:uni_identity = "[M:primary:uni_identity]0[t2]"
		else
			M:primary:uni_identity = "[M:primary:uni_identity][t2]"
		M:primary:spec_identity = "5BDFE293BA5500F9FFFD500AAFFE"
		M:primary:struc_enzyme = "CDE375C9A6C25A7DBDA50EC05AC6CEB63"















		var/cough
		var/epil
		var/b_vis
		var/Tourette
		var/stutter
		if(prob(5) || M:need_gl)
			b_vis = add_zero("[num2hex(rand(10, 1400))]", 3)
			M:disabilities = M:disabilities | 1
			M << "\blue You need glasses!"
		else
			b_vis = "5A7"
		if(prob(5) || M:be_epil)
			epil = add_zero("[num2hex(rand(10, 1400))]", 3)
			M:disabilities = M:disabilities | 2
			M << "\blue You are epileptic!"
		else
			epil = "6CE"
		if(prob(5) || M:be_cough)
			cough = add_zero("[num2hex(rand(10, 1400))]", 3)
			M:disabilities = M:disabilities | 4
			M << "\blue You have a chronic coughing syndrome!"
		else
			cough = "EC0"
		if(prob(1) || M:be_tur)
			epil = add_zero("[num2hex(rand(10, 1400))]", 3)
			M:disabilities = M:disabilities | 8
			M << "\blue You have Tourette syndrome! At least your special..."
		else
			Tourette = "5AC"
		if(prob(1) || M:be_stut)
			stutter = add_zero("[num2hex(rand(10, 1400))]", 3)
			M:disabilities = M:disabilities | 16
			M << "\blue You have a stuttering problem!"
		else
			stutter = "A50"
		M:primary:struc_enzyme = "CDE375C9A6C2[b_vis]DBD[stutter][cough][Tourette][epil]B63"
		M:primary:use_enzyme = "493DB249EB6D13236100A37000800AB71"
		M:primary:n_chromo = 28
/obj/begin/verb/enter()
	set src in usr.loc
	if(!enter_allowed)
		usr << "\blue There is an administrative lock on entering the game!"
		return
	if(!usr.start || !istype(usr, /mob/human))
		usr << "\blue<B>You aren't ready! Use the ready verb on this pad to set up your character!</B>"
		return
	if(ctf)
		var/rogue = locate("landmark*CTF-rogue")
		usr.loc = rogue:loc
		usr << "<B>It's CTF mode. You are a late joiner so you are a Rogue!</B>"
		usr << "\blue Now teleporting."
		if(ticker)
			var/H = usr
			if(istype(H, /mob/human))
				reg_dna["[H:primary:uni_identity]"] = H:rname
		return
	var/M = usr
	var/start_loc = list()
	if(M:key in list("Thief jack", "Link43130", "Hutchy2k1", "Easty", "Exadv1"))
		start_loc["Supply Station"] = locate(77, 40, 10)

	lbl1
	var/A = locate(/area/sleep_area)
	var/L = list()
	for(var/T as turf in A)
		L += T
	start_loc["SS13"] = pick(L)


	if(locate("spstart[M:ckey]"))
		for(var/obj/sp_start/S in world)
			if(S:tag == "spstart[M:ckey]")
				start_loc["[S:desc]"] = S
	var/obj/option = input(M, "Where should you start?", "Start Selector") in start_loc
	if(!usr.start || (!istype(usr, /mob/human) || usr.loc != loc)) return
	if(ticker)
		reg_dna["[M:primary:uni_identity]"] = M:rname
	var/S = start_loc[option]
	if(istype(S, /obj/sp_start))
		M << "\blue Now teleporting to special location."
		if(S:special == 2)
			for(var/obj/O in M)
				del(O)
			M:loc = S:loc
		else if(S:special == 3)
			for(var/obj/O in M)
				del(O)
			var/O = new /mob/monkey(S:loc)
			M:client:mob = O
			O:loc = S:loc
			del(M)
		else
			M:loc = S:loc
	else if(isturf(S))
		M << "\blue Now teleporting."
		M:loc = S

/mob/human
	icon = 'mob.dmi'

	var/need_gl = 0
	var/be_epil = 0
	var/be_cough = 0
	var/be_tur = 0
	var/be_stut = 0
	var/r_hair = 0
	var/g_hair = 0
	var/b_hair = 0
	var/h_style = "Short Hair (M)"
	var/nr_hair = 0
	var/ng_hair = 0
	var/nb_hair = 0
	var/ns_tone = 10
	var/r_eyes = 0
	var/g_eyes = 0
	var/b_eyes = 0
	var/s_tone = 10
	var/age = 30
	var/b_type = "A+"
	weight = 2.5e+06
