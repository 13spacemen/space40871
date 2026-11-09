/atom/proc/laserhit(obj/L)
	return 1
/obj/effects/smoke
	icon_state = "smoke"
	icon = 'water.dmi'
	opacity = 1
	anchored = 0
	var/amount = 6







/obj/effects/smoke/proc/Life()
	if(amount > 1)
		var/obj/effects/smoke/W = new type(loc)
		W:amount = amount - 1
		W:dir = dir
		spawn(0) W:Life()
	amount--
	if(amount <= 0)
		sleep(50)
		del(src)
	var/T = get_step(src, turn(dir, pick(90, 0, 0, -90)))
	if(T && T:density)
		dir = turn(dir, pick(-90, 90))
	else
		step_to(src, T)
		T = loc
		if(istype(T, /turf))
			T:firelevel = T:poison
	spawn(3) Life()


/obj/effects/sparks
	var/amount = 6
	icon = 'water.dmi'
	anchored = 0
/obj/effects/sparks/ion_trails
	icon_state = "ion_trails"
	anchored = 1
/obj/effects/sparks
	icon_state = "sparks"
/obj/effects/sparks/proc/Life()
	if(amount > 1)
		var/obj/effects/sparks/W = new type(loc)
		W:amount = amount - 1
		W:dir = dir
		spawn(0) W:Life()
	amount--
	if(amount <= 0)
		sleep(50)
		del(src)
	var/T = get_step(src, turn(dir, pick(90, 0, 0, -90)))
	if(T && T:density)
		dir = turn(dir, pick(-90, 90))
	else
		step_to(src, T)
		T = loc
		if(istype(T, /turf))
			T:firelevel = T:poison
	spawn(3) Life()
/obj/effects/sparks/New()
	..()
	var/T = loc
	if(istype(T, /turf))
		T:firelevel = T:poison
/obj/effects/sparks/Del()
	var/T = loc
	if(istype(T, /turf))
		T:firelevel = T:poison
	..()
/obj/effects/sparks/Move()
	..()
	var/T = loc
	if(istype(T, /turf))
		T:firelevel = T:poison
/obj/machinery/teleport
	icon = 'stationobjs.dmi'
	density = 1
	anchored = 1
/obj/machinery/teleport/hub
	icon_state = "tele0"
/obj/machinery/teleport/hub/Bumped(M as mob|obj)
	spawn(0)
		if(icon_state == "tele1") teleport(M)
/obj/machinery/teleport/hub/proc/teleport(M as mob|obj)
	var/obj/target
	var/turf/l = loc
	var/com = locate(/obj/machinery/computer/teleporter) in locate(l:x - 2, l:y, l:z)
	if(!com) return
	target = com:locked
	if(!com:locked)
		for(var/mob/O in oview(src))
			O:show_message("\red Failure: Cannot authenticate locked on coordinates. Please reinstantiat coordinate matrix.", 1, "\red Error!", 2)
		return
	var/obj/effects/sparks/O = new /obj/effects/sparks(target)
	O:dir = pick(1, 2, 4, 8)
	spawn(0) O:Life()
	if(istype(M, /atom/movable))
		var/tx = target:x + rand(-2, 2)
		var/ty = target:y + rand(-2, 2)
		M:loc = locate(tx, ty, target:z)
	else
		for(var/mob/B in oview(src))
			B:show_message("\blue Test fire completed.", 2)
/obj/machinery/teleport/station
	icon_state = "controller"
/obj/machinery/teleport/station/verb/engage()
	set src in oview(1)
	var/turf/l = loc
	var/com = locate(/obj/machinery/teleport/hub) in locate(l:x + 1, l:y, l:z)
	if(com)
		com:icon_state = "tele1"
		for(var/mob/O in oview(src))
			O:show_message("\blue Teleporter engaged!", 2)
	add_fingerprint(usr)
/obj/machinery/teleport/station/verb/disengage()
	set src in oview(1)
	var/turf/l = loc
	var/com = locate(/obj/machinery/teleport/hub) in locate(l:x + 1, l:y, l:z)
	if(com)
		com:icon_state = "tele0"
		for(var/mob/O in oview(src))
			O:show_message("\blue Teleporter disengaged!", 2)
	add_fingerprint(usr)
/obj/machinery/teleport/station/verb/testfire()
	set src in oview(1)
	var/turf/l = loc
	var/obj/machinery/teleport/hub/com = locate(/obj/machinery/teleport/hub) in locate(l:x + 1, l:y, l:z)
	if(com)
		for(var/mob/O in oview(src))
			O:show_message("\blue Test firing!", 2)
		com:teleport()
	add_fingerprint(usr)


/obj/machinery/computer/teleporter
	icon_state = "tele_computer"
	var/locked
	icon = 'stationobjs.dmi'
	var/id
	density = 1
/obj/machinery/computer/teleporter/New()
	id = "[rand(1000, 9999)]"
	..()
/obj/machinery/computer/teleporter/ex_act(severity)
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
/obj/machinery/computer/teleporter/verb/lock_in(freq as num)
	set desc = "Frequency to check"
	set src in oview(1)
	var/L = list()
	for(var/obj/item/weapon/radio/R in world)
		if(R:freq != freq) continue
		var/turf/T = find_loc(R)
		if(!T) continue
		var/t1 = "-[T:x],[T:y],[T:z]"
		t1 = "[R:text][t1]"
		L[t1] = R
	var/t1 = input("Please select a location to lock in.", "Locking Computer") in L
	var/R = L[t1]
	if(prob(30) || istype(R, /obj/item/weapon/radio/beacon) && prob(50))
		locked = find_loc(R)
	else
		if(L:len)
			R = L["[pick(L)]"]
			locked = find_loc(R)
		else locked = null
	for(var/mob/O in oview(src))
		O:show_message("\blue Locked In", 2)
	add_fingerprint(usr)
/obj/machinery/computer/teleporter/verb/set_id(t as text)
	set desc = "ID Tag:"
	set src in oview(1)
	if(t)
		id = t
/obj/machinery/computer/teleporter/proc/find_loc(obj/R)
	if(!R) return null
	var/T = R:loc
	while(!istype(T, /turf))
		T = T:loc
		if(istype(T, /area))
			return null
	return T

/obj/machinery/computer/data/ex_act(severity)
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
/obj/machinery/computer/data
	icon_state = "computer"
	icon = 'weap_sat.dmi'
	density = 1
/obj/machinery/computer/data/weapon/log/New()
	..()
	topics["Super-heater"] = "This turns a can of semi-liquid plasma into a super-heated ball of plasma."
	topics["Amplifier"] = "This increases the intensity of a laser."
	topics["Class 11 Laser"] = "This creates a very slow laser that is capable of penetrating most objects."
	topics["Plasma Energizer"] = "This combines super-heated plasma with a laser beam."
	topics["Generator"] = "This controls the entire power grid."
	topics["Mirror"] = "this can reflect LOW power lasers. HIGH power goes through it!"
	topics["Targetting Prism"] = "This focuses a laser coming from any direction forward."
/obj/machinery/computer/data/weapon/log/name = "Log Computer"
/obj/machinery/computer/data/weapon/log/display()
	usr << "<B>Research Log:</B>"
	..()

/obj/machinery/computer/data/weapon/info/New()
	..()
	topics["LOG(001)"] = "System: Deployment successful"
	topics["LOG(002)"] = "System: Safe orbit at inclination .003 established"
	topics["LOG(003)"] = "CenCom: Attempting test fire...ALERT(001)"
	topics["ALERT(001)"] = "System: Cannot attempt test fire"
	topics["LOG(004)"] = "System: Airlock accessed..."
	topics["LOG(005)"] = "System: System successfully reset...Generator engaged"
	topics["LOG(006)"] = "Physical: Super-heater (W005) added to power grid"
	topics["LOG(007)"] = "Physical: Amplifier (W007) added to power grid"
	topics["LOG(008)"] = "Physical: Plasma Energizer (W006) added to power grid"
	topics["LOG(009)"] = "Physical: Laser (W004) added to power grid"
	topics["LOG(010)"] = "Physical: Laser test firing"
	topics["LOG(011)"] = "Physical: Plasma added to Super-heater"
	topics["LOG(012)"] = "Physical: Orient N12.525,E22.124"
	topics["LOG(013)"] = "System: Location N12.525,E22.124"
	topics["LOG(014)"] = "Physical: Test fire...successful"
	topics["LOG(015)"] = "Physical: Airlock accessed..."
	topics["LOG(016)"] = "******: Disable locater systems"
	topics["LOG(017)"] = "System: Locater Beacon-Disengaged,CenCom link-Cut...ALERT(002)"
	topics["ALERT(002)"] = "System: Cannot seem to establish contact with Central Command"
	topics["LOG(018)"] = "******: Shutting down all systems...ALERT(003)"
	topics["ALERT(003)"] = "System: Power grid failure-Activating back-up power...ALERT(004)"
	topics["ALERT(004)"] = "System: Engine failure...All systems deactivated."
/obj/machinery/computer/data/weapon/info/name = "Research Computer"
/obj/machinery/computer/data/weapon/info/display()
	usr << "<B>Research Information:</B>"
	..()
/obj/machinery/computer/data/var/topics = list()

/obj/machinery/computer/data/verb/display()
	set src in oview(1)
	for(var/x in topics)
		usr << "[x], \..."
	usr << ""
	add_fingerprint(usr)
/obj/machinery/computer/data/verb/read(topic as text)
	set src in oview(1)
	if(topics["[topic]"])
		usr << "<B>[topic]</B>\n\t [topics["[topic]"]]"
	else
		usr << "Unable to find- [topic]"
	add_fingerprint(usr)
/obj/laser
	var/damage = 0
	var/range = 10
	icon = 'weap_sat.dmi'
/obj/laser/Bump()
	range--
/obj/laser/Move()
	range--
