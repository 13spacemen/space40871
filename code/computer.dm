/obj/datacore
	var/datum/data/record/medical = list()
	var/datum/data/record/general = list()
	var/datum/data/record/security = list()
/obj/datacore/proc/manifest()
	for(var/mob/human/H in world)
		if(H:start)
			var/G = new /datum/data/record()
			var/M = new /datum/data/record()
			var/S = new /datum/data/record()
			var/C = H:wear_id
			if(C) G:fields["rank"] = C:assignment
			else G:fields["rank"] = "Unassigned"
			G:fields["name"] = H:rname
			G:fields["id"] = "[add_zero(num2hex(rand(1, 16777215)), 6)]"
			M:fields["name"] = G:fields["name"]
			M:fields["id"] = G:fields["id"]
			S:fields["name"] = G:fields["name"]
			S:fields["id"] = G:fields["id"]
			if(H:gender == "female")
				G:fields["sex"] = "Female"
			else G:fields["sex"] = "Male"
			G:fields["age"] = "[H:age]"
			G:fields["fingerprint"] = "[md5(H:primary:uni_identity)]"
			G:fields["p_stat"] = "Active"
			G:fields["m_stat"] = "Stable"
			M:fields["b_type"] = "[H:b_type]"
			M:fields["mi_dis"] = "None"
			M:fields["mi_dis_d"] = "No minor disabilities have been declared."
			M:fields["ma_dis"] = "None"
			M:fields["ma_dis_d"] = "No major disabilities have been diagnosed."
			M:fields["alg"] = "None"
			M:fields["alg_d"] = "No allergies have been detected in this patient."
			M:fields["cdi"] = "None"
			M:fields["cdi_d"] = "No diseases have been diagnosed at the moment."
			M:fields["notes"] = "No notes."
			S:fields["criminal"] = "None"
			S:fields["mi_crim"] = "None"
			S:fields["mi_crim_d"] = "No minor crime convictions."
			S:fields["ma_crim"] = "None"
			S:fields["ma_crim_d"] = "No minor crime convictions."
			S:fields["notes"] = "No notes."
			general += G
			medical += M
			security += S
/turf{var/updatecell}

/turf/space/attack_paw(mob/user)
	return attack_hand(user)
/turf/space/attack_hand(mob/user)
	if(user:restrained() || !user:pulling) return
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
/turf/space/attackby(obj/T, mob/user)
	if(istype(T, /obj/item/weapon/tile))
		T:build(src)
		T:amount--
		add_fingerprint(user)
	if(T:amount < 1)
		user:u_equip(src)
		del(src)



/turf/space
	icon_state = "space"
	updatecell = 1
	oxygen = 0
	oldoxy = 0
	oldpoison = 0
/turf/space/updatecell()
	return
/turf/space/Entered(A as mob|obj)
	..()
	if(!A || (src != A:loc || istype(, /obj/beam))) return
	if(!A:last_move) return
	if(locate(/obj/move) in src) return 1
	if(ismob(A) && (x > 2 && x < world.maxx - 2))
		var/M = A
		if(!M:restrained() && M:canmove)
			var/t1 = 5
			if(locate(/obj/grille) in oview(1, M))
				if(!M:l_hand)
					t1 -= 2
				else if(M:l_hand:w_class <= 2)
					t1 -= 1
				if(!M:r_hand)
					t1 -= 2
				else if(M:r_hand:w_class <= 2)
					t1 -= 1
			else if(locate(/turf/station) in oview(1, M))
				if(!M:l_hand)
					t1 -= 1
				else if(M:l_hand:w_class <= 2)
					t1 -= 0.5
				if(!M:r_hand)
					t1 -= 1
				else if(M:r_hand:w_class <= 2)
					t1 -= 0.5
			t1 = round(t1)
			if(t1 < 5)
				if(prob(t1))
					M << "\blue<B>You slipped!</B>"
				else
					spawn(5)
						if(src == A:loc) spawn(0) Entered(A)
					return 0















	if(x <= 2)
		if(z >= 10)
			if(world.maxz < 10)
				world.maxz++
				A:z++
			else
				A:z = 9
		else
			A:z++
		A:x = world.maxx - 2
		spawn(0) if(A && A:loc) A:loc:Entered(A)
	else if(x >= world.maxx - 1)
		if(A:z > 3)
			A:z--
		else
			A:z = 1
		A:x = 3
		spawn(0) if(A && A:loc) A:loc:Entered(A)
	else
		spawn(5)
			if(A && (!A:anchored && A:loc == src))
				if(step(A, A:last_move))
				else spawn(0) Entered(A)




/obj/machinery/computer
	density = 1
	anchored = 1
	anchored = 1
/obj/machinery/door/poddoor
	var/id = 1
	icon = 'Door1.dmi'
/obj/machinery/door/poddoor/open()
	usr << "This is a remote pod door!"
/obj/machinery/door/poddoor/close()
	usr << "This is a remote pod door!"
/obj/machinery/door/poddoor/proc/openpod()
	set src in oview(1)
	if(operating) return
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
/obj/machinery/door/poddoor/proc/closepod()
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
	sleep(15)
	operating = 0
/obj/machinery/computer/security
	icon_state = "sec_computer"
	var/current
	var/last_pic = 1
	icon = 'stationobjs.dmi'
	density = 1
/obj/machinery/computer/security/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/computer/security/attack_hand(mob/user)
	var/L = list()
	user:machine = src
	if(istype(current, /obj/machinery/camera))
		L["*Take Photo*"] = "*Take Photo*"
	for(var/obj/machinery/camera/C in world)
		L["[C:c_tag][C:status ? null : " (Deactivated)"]"] = C
	L["Cancel"] = "Cancel"
	var/t = input(user, "Which camera should you change to?") in L
	var/C = L[t]
	if(get_dist(user, src) > 1 || (user:machine != src || (user:blinded || (!user:canmove || !C:status))))
		return 0
	if(t == "*Take Photo*")
		if(last_pic > world.time)
			spawn(0) attack_hand(user)
			return
		last_pic = world.time + 30
		var/turf/T = get_turf(current)
		var/P = new /obj/item/weapon/paper/photograph(src)
		P:photo_id = createphoto(T:z, 32, 32, list(/obj/screen), T:x - 5, T:x + 5, T:y - 5, T:y + 5, T)
		if(isnum(P:photo_id))
			P:loc = loc
		else
			del(P)
		spawn(0) attack_hand(user)
	else if(t != "Cancel")
		current = C
		spawn(0) attack_hand(user)
	else
		user:machine = null

/obj/machinery/computer/security/check_eye(mob/user)
	if(get_dist(user, src) > 1 || (!user:canmove || (user:blinded || (!current || !current:status)))) return null
	user:reset_view(current)
	return 1

/obj/machinery/computer/meteorhit(obj/O)
	for(var/x in verbs)
		verbs -= x
	icon_state = "broken"

/obj/machinery/computer/communications/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			if(prob(50))
				for(var/x in verbs)
					verbs -= x
				icon_state = "broken"
		if(3)
			if(prob(25))
				for(var/x in verbs)
					verbs -= x
				icon_state = "broken"
/obj/machinery/computer/communications
	icon_state = "comm_computer"
	density = 1
/obj/machinery/computer/communications/verb/call_shuttle()
	set src in oview(1)
	if(!ticker || ticker:shuttle_entered)
		return
	world << "\blue<B>Alert: The emergency shuttle has been called. It will arrive in T-10:00 minutes.</B>"
	if(!ticker:timeleft)
		ticker:timeleft = 6000
	ticker:timing = 1
	add_fingerprint(usr)
/obj/machinery/computer/communications/verb/cancel_call()
	set src in oview(1)
	if(!ticker || (ticker:shuttle_entered || (ticker:timing == 0 || ticker:timeleft < 300)))
		return
	world << "\blue<B>Alert: The shuttle is going back!</B>"
	ticker:timing = -1
	add_fingerprint(usr)
/obj/machinery/computer/card/var/obj/item/weapon/card/id/scan
/obj/machinery/computer/card/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			if(prob(50))
				for(var/x in verbs)
					verbs -= x
				icon_state = "broken"
		if(3)
			if(prob(25))
				for(var/x in verbs)
					verbs -= x
				icon_state = "broken"
/obj/machinery/computer/communications
	icon = 'stationobjs.dmi'
/obj/machinery/computer/card
	icon_state = "id_computer"
	name = "Identification Computer"
	var/obj/item/weapon/card/id/modify
	var/authenticated = 0
	var/mode = 0
	var/printing
/obj/machinery/computer/card/attack_paw(mob/user)
	return attack_hand(user)
/obj/machinery/computer/card/attack_hand(mob/user)
	user:machine = src
	if(!ticker) return
	var/dat
	if(mode)
		var/d2 = {"Confirm Identity: <A href='?src=\ref[src];scan=1'>[scan ? "[scan:name]" : "----------"]</A>
[authenticated ? "You are logged in!" : "<A href='?src=\ref[src];auth=1'>{Log in}</A>"]"}
		var/d1 = "[authenticated ? "Click to modify" : "Please log in to modify records."]<BR>"
		for(var/datum/data/record/t in data_core:general)
			d1 += "[t:fields["name"]] - [t:fields["rank"]]<BR>"
		dat = {"<HTML><HEAD></HEAD><BODY><TT>[d2]<BR>
<BR>
<B>Crew Manifest:</B><BR>
[d1]
<BR>
<A href='?src=\ref[src];print=1'>Print</A><BR>
<BR>
<A href='?src=\ref[src];mode=0'>Access ID modification console.</A><BR>
</TT></BODY></HTML>"}
	else
		var/d1 = "<A href='?src=\ref[src];auth=1'>{Log in}</A>"
		if(authenticated && modify)
			var/vo, va, vl, ve

			switch(modify:access_level)
				if(1)
					vo = "<A href='?src=\ref[src];vo=-1'>0</A> 1 <A href='?src=\ref[src];vo=2'>2</A> <A href='?src=\ref[src];vo=3'>3</A> <A href='?src=\ref[src];vo=4'>4</A> <A href='?src=\ref[src];vo=5'>5</A>"
				if(2)
					vo = "<A href='?src=\ref[src];vo=-1'>0</A> <A href='?src=\ref[src];vo=1'>1</A> 2 <A href='?src=\ref[src];vo=3'>3</A> <A href='?src=\ref[src];vo=4'>4</A> <A href='?src=\ref[src];vo=5'>5</A>"
				if(3)
					vo = "<A href='?src=\ref[src];vo=-1'>0</A> <A href='?src=\ref[src];vo=1'>1</A> <A href='?src=\ref[src];vo=2'>2</A> 3 <A href='?src=\ref[src];vo=4'>4</A> <A href='?src=\ref[src];vo=5'>5</A>"
				if(4)
					vo = "<A href='?src=\ref[src];vo=-1'>0</A> <A href='?src=\ref[src];vo=1'>1</A> <A href='?src=\ref[src];vo=2'>2</A> <A href='?src=\ref[src];vo=3'>3</A> 4 <A href='?src=\ref[src];vo=5'>5</A>"
				if(5)
					vo = "<A href='?src=\ref[src];vo=-1'>0</A> <A href='?src=\ref[src];vo=1'>1</A> <A href='?src=\ref[src];vo=2'>2</A> <A href='?src=\ref[src];vo=3'>3</A> <A href='?src=\ref[src];vo=4'>4</A> 5"
				else
					vo = "0 <A href='?src=\ref[src];vo=1'>1</A> <A href='?src=\ref[src];vo=2'>2</A> <A href='?src=\ref[src];vo=3'>3</A> <A href='?src=\ref[src];vo=4'>4</A> <A href='?src=\ref[src];vo=5'>5</A>"
			switch(modify:lab_access)
				if(1)
					vl = "<A href='?src=\ref[src];vl=-1'>0</A> 1 <A href='?src=\ref[src];vl=2'>2</A> <A href='?src=\ref[src];vl=3'>3</A> <A href='?src=\ref[src];vl=4'>4</A> <A href='?src=\ref[src];vl=5'>5</A>"
				if(2)
					vl = "<A href='?src=\ref[src];vl=-1'>0</A> <A href='?src=\ref[src];vl=1'>1</A> 2 <A href='?src=\ref[src];vl=3'>3</A> <A href='?src=\ref[src];vl=4'>4</A> <A href='?src=\ref[src];vl=5'>5</A>"
				if(3)
					vl = "<A href='?src=\ref[src];vl=-1'>0</A> <A href='?src=\ref[src];vl=1'>1</A> <A href='?src=\ref[src];vl=2'>2</A> 3 <A href='?src=\ref[src];vl=4'>4</A> <A href='?src=\ref[src];vl=5'>5</A>"
				if(4)
					vl = "<A href='?src=\ref[src];vl=-1'>0</A> <A href='?src=\ref[src];vl=1'>1</A> <A href='?src=\ref[src];vl=2'>2</A> <A href='?src=\ref[src];vl=3'>3</A> 4 <A href='?src=\ref[src];vl=5'>5</A>"
				if(5)
					vl = "<A href='?src=\ref[src];vl=-1'>0</A> <A href='?src=\ref[src];vl=1'>1</A> <A href='?src=\ref[src];vl=2'>2</A> <A href='?src=\ref[src];vl=3'>3</A> <A href='?src=\ref[src];vl=4'>4</A> 5"
				else
					vl = "0 <A href='?src=\ref[src];vl=1'>1</A> <A href='?src=\ref[src];vl=2'>2</A> <A href='?src=\ref[src];vl=3'>3</A> <A href='?src=\ref[src];vl=4'>4</A> <A href='?src=\ref[src];vl=5'>5</A>"
			switch(modify:engine_access)
				if(1)
					ve = "<A href='?src=\ref[src];ve=-1'>0</A> 1 <A href='?src=\ref[src];ve=2'>2</A> <A href='?src=\ref[src];ve=3'>3</A> <A href='?src=\ref[src];ve=4'>4</A> <A href='?src=\ref[src];ve=5'>5</A>"
				if(2)
					ve = "<A href='?src=\ref[src];ve=-1'>0</A> <A href='?src=\ref[src];ve=1'>1</A> 2 <A href='?src=\ref[src];ve=3'>3</A> <A href='?src=\ref[src];ve=4'>4</A> <A href='?src=\ref[src];ve=5'>5</A>"
				if(3)
					ve = "<A href='?src=\ref[src];ve=-1'>0</A> <A href='?src=\ref[src];ve=1'>1</A> <A href='?src=\ref[src];ve=2'>2</A> 3 <A href='?src=\ref[src];ve=4'>4</A> <A href='?src=\ref[src];ve=5'>5</A>"
				if(4)
					ve = "<A href='?src=\ref[src];ve=-1'>0</A> <A href='?src=\ref[src];ve=1'>1</A> <A href='?src=\ref[src];ve=2'>2</A> <A href='?src=\ref[src];ve=3'>3</A> 4 <A href='?src=\ref[src];ve=5'>5</A>"
				if(5)
					ve = "<A href='?src=\ref[src];ve=-1'>0</A> <A href='?src=\ref[src];ve=1'>1</A> <A href='?src=\ref[src];ve=2'>2</A> <A href='?src=\ref[src];ve=3'>3</A> <A href='?src=\ref[src];ve=4'>4</A> 5"
				else
					ve = "0 <A href='?src=\ref[src];ve=1'>1</A> <A href='?src=\ref[src];ve=2'>2</A> <A href='?src=\ref[src];ve=3'>3</A> <A href='?src=\ref[src];ve=4'>4</A> <A href='?src=\ref[src];ve=5'>5</A>"
			switch(modify:air_access)
				if(1)
					va = "<A href='?src=\ref[src];va=-1'>0</A> 1 <A href='?src=\ref[src];va=2'>2</A> <A href='?src=\ref[src];va=3'>3</A> <A href='?src=\ref[src];va=4'>4</A> <A href='?src=\ref[src];va=5'>5</A>"
				if(2)
					va = "<A href='?src=\ref[src];va=-1'>0</A> <A href='?src=\ref[src];va=1'>1</A> 2 <A href='?src=\ref[src];va=3'>3</A> <A href='?src=\ref[src];va=4'>4</A> <A href='?src=\ref[src];va=5'>5</A>"
				if(3)
					va = "<A href='?src=\ref[src];va=-1'>0</A> <A href='?src=\ref[src];va=1'>1</A> <A href='?src=\ref[src];va=2'>2</A> 3 <A href='?src=\ref[src];va=4'>4</A> <A href='?src=\ref[src];va=5'>5</A>"
				if(4)
					va = "<A href='?src=\ref[src];va=-1'>0</A> <A href='?src=\ref[src];va=1'>1</A> <A href='?src=\ref[src];va=2'>2</A> <A href='?src=\ref[src];va=3'>3</A> 4 <A href='?src=\ref[src];va=5'>5</A>"
				if(5)
					va = "<A href='?src=\ref[src];va=-1'>0</A> <A href='?src=\ref[src];va=1'>1</A> <A href='?src=\ref[src];va=2'>2</A> <A href='?src=\ref[src];va=3'>3</A> <A href='?src=\ref[src];va=4'>4</A> 5"
				else
					va = "0 <A href='?src=\ref[src];va=1'>1</A> <A href='?src=\ref[src];va=2'>2</A> <A href='?src=\ref[src];va=3'>3</A> <A href='?src=\ref[src];va=4'>4</A> <A href='?src=\ref[src];va=5'>5</A>"
			var/L = list("Research Assistant", "Staff Assistant", "Medical Assistant", "Technical Assistant", "Engineer", "Forensic Technician", "Research Technician", "Medical Doctor", "Captain", "Security Officer", "Medical Researcher", "Toxin Researcher", "Head of Research", "Head of Personnel", "Station Technician", "Atmospheric Technician", "Unassigned", "Systems")
			var/assign = ""
			if(istype(user, /mob/human))
				var/counter = 1
				for(var/t in L)
					assign += "<A href='?src=\ref[src];assign=[t]'>[t]</A>  "
					counter++
					if(counter >= 4)
						assign += "<BR>"
						counter = 1
				d1 = {"[modify:name] :<BR>
General Access Level: [vo]<BR>
Laboratory Access: [vl]<BR>
Reactor/Engine Access: [ve]<BR>
Main Systems Access: [va]<BR>
Registered: <A href='?src=\ref[src];reg=1'>[modify:registered ? "[modify:registered]" : "{None: Click to modify}"]</A><BR>
Assignment: [modify:assignment ? "[modify:assignment]" : "None"]<BR>
[assign]<BR>"}
			else
				var/counter = 1
				for(var/t in L)
					assign += "<A href='?src=\ref[src];assign=[t]'>[stars(t)]</A>  "
					counter++
					if(counter >= 4)
						assign += "<BR>"
						counter = 1
				d1 = {"[stars("modify.name")] :<BR>
[stars("General Access Level:")] [vo]<BR>
[stars("Laboratory Access:")] [vl]<BR>
[stars("Reactor/Engine Access:")] [ve]<BR>
[stars("Main Systems Access:")] [va]<BR>
[stars("Registered:")] <A href='?src=\ref[src];reg=1'>[modify:registered ? "[stars(modify:registered)]" : "[stars("{None: Click to modify}")]"]</A><BR>
[stars("Assignment:")] [modify:assignment ? "[stars(modify:assignment)]" : "None"]<BR>
[assign]<BR>"}
		if(istype(user, /mob/human))
			dat = {"<TT><B>Identification Card Modifier</B><BR>
<I>Please Insert the cards into the slots</I><BR>
Target: <A href='?src=\ref[src];modify=1'>[modify ? "[modify:name]" : "----------"]</A><BR>
Confirm Identity: <A href='?src=\ref[src];scan=1'>[scan ? "[scan:name]" : "----------"]</A><BR>
-----------------<BR>
[d1]<BR>
<BR>
<BR>
<A href='?src=\ref[src];mode=1'>Access Crew Manifest</A><BR>
</TT>"}
		else
			dat = {"<TT><B>[stars("Identification Card Modifier")]</B><BR>
<I>[stars("Please Insert the cards into the slots")]</I><BR>
[stars("Target:")] <A href='?src=\ref[src];modify=1'>[modify ? "[stars(modify:name)]" : "----------"]</A><BR>
[stars("Confirm Identity:")] <A href='?src=\ref[src];scan=1'>[scan ? "[stars(scan:name)]" : "----------"]</A><BR>
-----------------<BR>
[d1]<BR>
<BR>
<BR>
<A href='?src=\ref[src];mode=1'>[stars("Access Crew Manifest")]</A><BR>
</TT>"}
	user << browse(dat, "window=id_com;size=400x500")
/obj/machinery/computer/card/Topic(href, href_list)
	if(!istype(usr, /mob/human) && (!ticker || ticker && ticker:mode != "monkey"))
		usr << "\red You don't have the dexterity to do this!"
		return
	if(usr.stat || usr.restrained()) return
	if(get_dist(src, usr) <= 1 && istype(loc, /turf))
		usr.machine = src
		if(href_list["modify"])
			if(modify)
				modify:name = "[modify:registered]'s ID Card ([modify:access_level]>[modify:lab_access]-[modify:engine_access]-[modify:air_access])"
				modify:loc = loc
				modify = null
			else
				var/obj/item/I = usr.equipped()
				if(istype(I, /obj/item/weapon/card/id))
					usr.drop_item()
					I:loc = src
					modify = I
			authenticated = 0
		if(href_list["scan"])
			if(scan)
				scan:loc = loc
				scan = null
			else
				var/obj/item/I = usr.equipped()
				if(istype(I, /obj/item/weapon/card/id))
					usr.drop_item()
					I:loc = src
					scan = I
			authenticated = 0
		if(href_list["auth"])
			if(!authenticated && (scan && (modify || mode)))
				if(scan:assignment == "Captain" || scan:assignment == "Head of Personnel")
					authenticated = 1
		if(href_list["vo"])
			if(authenticated)
				var/t1 = text2num(href_list["vo"])
				if(t1 == -1) t1 = 0
				modify:access_level = t1
		if(href_list["vl"])
			if(authenticated)
				var/t1 = text2num(href_list["vl"])
				if(t1 == -1) t1 = 0
				modify:lab_access = t1
		if(href_list["ve"])
			if(authenticated)
				var/t1 = text2num(href_list["ve"])
				if(t1 == -1) t1 = 0
				modify:engine_access = t1
		if(href_list["va"])
			if(authenticated)
				var/t1 = text2num(href_list["va"])
				if(t1 == -1) t1 = 0
				modify:air_access = t1
		if(href_list["assign"])
			if(authenticated)
				var/t1 = href_list["assign"]
				modify:assignment = t1
		if(href_list["reg"])
			if(authenticated)
				var/obj/item/weapon/card/id/t2 = modify
				var/t1 = input(usr, "What name?", "ID computer") as text
				if(authenticated && (modify == t2 && (get_dist(src, usr) <= 1 && istype(src.loc, /turf))))
					modify:registered = t1
		if(href_list["mode"])
			mode = text2num(href_list["mode"])
		if(href_list["print"])
			if(!printing)
				printing = 1
				sleep(50)
				var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(loc)
				var/t1 = "<B>Crew Manifest:</B><BR>"
				for(var/datum/data/record/t in data_core:general)
					t1 += "<B>[t:fields["name"]]</B> - [t:fields["rank"]]<BR>"
				P:info = "[t1]"
				P:name = "paper- 'Crew Manifest'"
				printing = null
		if(href_list["mode"])
			authenticated = 0
			mode = text2num(href_list["mode"])
		if(modify)
			modify:name = "[modify:registered]'s ID Card ([modify:access_level]>[modify:lab_access]-[modify:engine_access]-[modify:air_access])"

		for(var/mob/M in view(1, src))
			if(M:client && M:machine == src) attack_hand(M)
		add_fingerprint(usr)
	else
		usr << browse(null, "window=id_com")
		return
/obj/machinery/computer/card/attackby(obj/I, mob/user)
	attack_hand(user)



















/obj/machinery/computer/card
	icon = 'stationobjs.dmi'
	density = 1
/obj/machinery/computer/pod
	icon_state = "computer"
	name = "Pod Launch Control"
	var/id = 1
	var/connected
	var/timing = 0
	icon = 'escapepod.dmi'
	density = 1
	var/time = 30
/obj/machinery/computer/pod/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			if(prob(50))
				for(var/x in verbs)
					verbs -= x
				icon_state = "broken"
		if(3)
			if(prob(25))
				for(var/x in verbs)
					verbs -= x
				icon_state = "broken"









/obj/machinery/computer/pod/proc/alarm()
	if(!src.connected)
		view() << "Cannot locate mass driver connector. Cancelling firing sequence!"
		return
	for(var/obj/machinery/door/poddoor/M in world)
		if(M:id == id)
			spawn(0) M:openpod()
	sleep(20)
	connected:drive()
	sleep(50)
	for(var/obj/machinery/door/poddoor/M in world)
		if(M:id == id)
			spawn(0) M:closepod()
/obj/machinery/computer/pod/New()
	..()
	spawn(5)
		for(var/obj/machinery/mass_driver/M in world)
			if(M:id == id)
				connected = M
				break
/obj/machinery/computer/pod/attack_paw(mob/user)
	return attack_hand(user)
/obj/machinery/computer/pod/attack_hand(mob/user)
	var/dat = "<HTML><BODY><TT><B>Mass Driver Controls</B>"
	user:machine = src
	var/d2
	if(timing) d2 = "<A href='?src=\ref[src];time=0'>Stop Time Launch</A>"
	else d2 = "<A href='?src=\ref[src];time=1'>Initiate Time Launch</A>"
	var/second = time % 60
	var/minute = (time - second) / 60
	dat += {"<HR>
Timer System: [d2]
Time Left: [minute ? "[minute]:" : null][second] <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>"}
	if(connected)
		var/temp = ""
		var/L = list(0.25, 0.5, 1, 2, 4, 8, 16)
		for(var/t in L)
			if(t == connected:power)
				temp += "[t] "
			else
				temp += "<A href = '?src=\ref[src];power=[t]'>[t]</A> "
		dat += {"<HR>
Power Level: [temp]<BR>
<A href = '?src=\ref[src];alarm=1'>Firing Sequence</A><BR>
<A href = '?src=\ref[src];drive=1'>Test Fire Driver</A><BR>
<A href = '?src=\ref[src];door=1'>Toggle Outer Door</A><BR>"}
	dat += "<BR><BR><A href='?src=\ref[user];mach_close=computer'>Close</A></TT></BODY></HTML>"
	user << browse(dat, "window=computer;size=400x500")
/obj/machinery/computer/pod/process()
	if(timing)
		if(time > 0)
			time = round(time) - 1
		else
			alarm()
			time = 0
			timing = 0
		for(var/mob/M in view(1, src))
			if(M:client && M:machine == src) attack_hand(M)
/obj/machinery/computer/pod/Topic(href, href_list)
	if(!istype(usr, /mob/human) && (!ticker || ticker && ticker:mode != "monkey"))
		usr << "\red You don't have the dexterity to do this!"
		return
	if(usr.stat || usr.restrained()) return
	if(usr.contents:Find(src) || get_dist(src, usr) <= 1 && istype(loc, /turf))
		usr.machine = src
		if(href_list["power"])
			var/t = text2num(href_list["power"])
			t = min(max(0.25, t), 16)
			if(connected)
				connected:power = t
		else if(href_list["alarm"])
			alarm()
		else if(href_list["time"])
			timing = text2num(href_list["time"])
		else if(href_list["tp"])
			var/tp = text2num(href_list["tp"])
			time += tp
			time = min(max(round(time), 0), 120)
		else if(href_list["door"])
			for(var/obj/machinery/door/poddoor/M in world)
				if(M:id == id)
					if(M:density)
						spawn(0) M:openpod()
					else spawn(0) M:closepod()
		add_fingerprint(usr)
		for(var/mob/M in view(1, src))
			if(M:client && M:machine == src) attack_hand(M)

































/obj/machinery/pod
	var/id = 1
/obj/machinery/recon
	icon_state = "recon"
	name = "1-Person Reconaissance Pod"
/obj/machinery/pod/process()
	if(speed)
		if(speed <= 10)
			var/t1 = 10 - speed
			while(t1 > 0)
				step(src, dir)
				sleep(1)
				t1--
		else
			var/t1 = round(speed / 5)
			while(t1 > 0)
				step(src, dir)
				t1--
/obj/machinery/pod/icon = 'escapepod.dmi'
/obj/machinery/pod/ex_act(severity)
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
/obj/machinery/pod/Bump()
	..()
	src.speed = 0
/obj/machinery/pod/relaymove(mob/user, direction)
	if(user in src)
		if(direction & 1)
			speed = max(speed - 1, 1)
		else if(direction & 2)
			speed++
			if(speed > 10)
				speed = 10
		if(direction & 4)
			dir = turn(dir, -90)
		else if(direction & 8)
			dir = turn(dir, 90)
/obj/machinery/pod
	var/speed = 10
	name = "Escape Pod"
	icon_state = "pod"
	dir = 8
	density = 1
	flags = 320
	anchored = 1
	var/capacity
/obj/machinery/pod/verb/eject()
	set src = usr.loc
	if(usr.stat) return
	var/M = usr
	M:loc = loc
	if(M:client)
		M:client:eye = M:client:mob
		M:client:perspective = MOB_PERSPECTIVE
	step(M, turn(dir, 180))
/obj/machinery/pod/verb/board()
	set src in oview(1)
	if(usr.stat) return



	var/M = usr
	if(M:client)
		M:client:perspective = EYE_PERSPECTIVE
		M:client:eye = src
	M:loc = src
/obj/machinery/pod/verb/load()
	set src in oview(1)
	if(istype(usr, /mob/human) && (!ticker || ticker && ticker:mode != "monkey"))
		var/H = usr
		if(H:pulling && !H:pulling:anchored)
			H:pulling:loc = src
			if(ismob(H:pulling))
				var/M = H:pulling
				if(M:client)
					M:client:perspective = EYE_PERSPECTIVE
					M:client:eye = src
			for(var/mob/O in view(src))
				if(O:client && !O:blinded)
					O << "\blue<B> [H] loads [H:pulling] into [src]!</B>"
			H:pulling = null
/obj/machinery/pod/verb/unload(A as mob|obj in src)
	set src in oview(1)
	if(istype(A, /atom/movable))
		A:loc = loc
		for(var/mob/O in view(src))
			if(O:client && !O:blinded)
				O << "\blue<B> [usr] unloads [A] from [src]!</B>"
		if(ismob(A))
			var/M = A
			if(M:client)
				M:client:perspective = MOB_PERSPECTIVE
				M:client:eye = M
		step(A, turn(dir, 180))

/obj/machinery/recon/process()
	if(speed)
		if(speed <= 10)
			var/t1 = 10 - speed
			while(t1 > 0)
				step(src, dir)
				sleep(1)
				t1--
		else
			var/t1 = round(speed / 5)
			while(t1 > 0)
				step(src, dir)
				t1--


/obj/machinery/recon/ex_act(severity)
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
/obj/machinery/recon/Bump()
	..()
	speed = 0





/obj/machinery/recon/var/speed = 1
/obj/machinery/recon/verb/eject()
	set src = usr.loc
	if(usr.stat) return
	var/M = usr
	M:loc = loc
	if(M:client)
		M:client:eye = M:client:mob
		M:client:perspective = MOB_PERSPECTIVE
/obj/machinery/recon/verb/board()
	set src in oview(1)
	if(usr.stat) return
	if(locate(/mob) in src)
		usr << "There is no room! You can only fit one person."
		return
	var/M = usr
	if(M:client)
		M:client:perspective = EYE_PERSPECTIVE
		M:client:eye = src
	M:loc = src
/obj/machinery/recon/verb/load()
	set src in oview(1)
	if(istype(usr, /mob/human) && (!ticker || ticker && ticker:mode != "monkey"))
		var/H = usr
		if(H:pulling && !H:pulling:anchored)
			if(!istype(H:pulling, /obj/item/weapon))
				usr << "You may only place items in."
			else if((locate(/mob) in src) && ismob(H:pulling))
				usr << "There is no room! You can only fit one person."
			else
				H:pulling:loc = src
				if(ismob(H:pulling))
					var/M = H:pulling
					if(M:client)
						M:client:perspective = EYE_PERSPECTIVE
						M:client:eye = src
				for(var/mob/O in view(src))
					if(O:client && !O:blinded)
						O << "\blue<B> [H] loads [H:pulling] into [src]!</B>"
				H:pulling = null
/obj/machinery/recon/verb/unload(A as mob|obj in src)
	set src in oview(1)
	if(istype(A, /atom/movable))
		A:loc = loc
		for(var/mob/O in view(src))
			if(O:client && !O:blinded)
				O << "\blue<B> [usr] unloads [A] from [src]!</B>"
		if(ismob(A))
			var/M = A
			if(M:client)
				M:client:perspective = MOB_PERSPECTIVE
				M:client:eye = M
/obj/machinery/recon/Bump()
	..()
	speed = 0
/obj/machinery/recon/relaymove(mob/user, direction)
	if(user in src)
		if(direction & 1)
			speed = max(speed - 1, 1)
		else if(direction & 2)
			speed++
		if(direction & 4)
			dir = turn(dir, -90)
		else if(direction & 8)
			dir = turn(dir, 90)
		if(direction & 16)
			speed = 30
		else
			speed = min(speed, 10)

/obj/machinery/recon
	icon = 'escapepod.dmi'
	density = 1
	flags = 320
	anchored = 1
