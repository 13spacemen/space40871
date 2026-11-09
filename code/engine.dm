/turf/station/engine
	icon = 'engine.dmi'
/area/engine
/area/decontamination
/area/medical
/area/airintake
/area/engine_access
/area/oxygen_storage
/turf/station/engine/attack_paw(mob/user)
	return attack_hand(user)
/turf/station/engine/attack_hand(mob/user)
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
/area/testlab1
/area/testlab2
/turf/station/engine/floor/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			if(prob(50))
				del(src)
/turf/station/engine/floor
	icon_state = "floor"
	updatecell = 1
/datum/engine_eject
	var/status = 0
	var/resetting
	var/timeleft
/datum/engine_eject/proc/ejectstart()
	if(!status)
		if(timeleft <= 0) timeleft = 60
		world << "\red<B>Alert: Ejection Sequence for Engine Module has been engaged.</B>"
		world << "\red<B>Ejection Time in T-[timeleft] seconds!</B>"
		resetting = 0
		var/engine = locate(/area/engine)
		engine:icon = 'alert.dmi'
		if(!engine:icon_state) engine:icon_state = "red"
		else engine:icon_state = "blue-red"
		status = 1
		for(var/obj/machinery/computer/engine/E in world)
			E:icon_state = "engaging"
		spawn(0) countdown()
/datum/engine_eject/proc/resetcount()
	if(!status)
		resetting = 1
	sleep(50)
	if(resetting)
		timeleft = 60
		world << "\red<B>Alert: Ejection Sequence Countdown for Engine Module has been reset.</B>"
/datum/engine_eject/proc/countdone()
	status = -1
	var/area/engine = locate(/area/engine)
	engine:icon = 'alert.dmi'
	engine:icon_state = null
	var/A = locate(/area/engine)
	for(var/turf/T as turf in A)
		var/S = new T:type(locate(T:x, T:y, 8))
		for(var/atom/movable/AM in T)
			AM:loc = S
			S:oxygen = T:oxygen
			S:oldoxy = T:oldoxy
			S:tmpoxy = T:tmpoxy

			S:poison = T:poison
			S:oldpoison = T:oldpoison
			S:tmppoison = T:tmppoison

			S:co2 = T:co2
			S:oldco2 = T:oldco2
			S:tmpco2 = T:tmpco2

			S:sl_gas = T:sl_gas
			S:osl_gas = T:osl_gas
			S:tsl_gas = T:tsl_gas

			S:n2 = T:n2
			S:on2 = T:on2
			S:tn2 = T:tn2
		A:contents += S
		var/P = new T:type(locate(T:x, T:y, T:z))
		var/D = locate(/area/dummy)
		D:contents += P
		del(T)
	world << "\red<B>Engine Ejected!</B>"
	for(var/obj/machinery/computer/engine/E in world)
		E:icon_state = "engaged"
/datum/engine_eject/proc/stopcount()
	if(status > 0)
		status = 0
		world << "\red<B>Alert: Ejection Sequence for Engine Module has been disengaged!</B>"
		var/area/engine = locate(/area/engine)
		engine:icon = 'alert.dmi'
		if(engine:icon_state == "blue-red") engine:icon_state = "blue"
		else engine:icon_state = null
		for(var/obj/machinery/computer/engine/E in world)
			E:icon_state = null
/datum/engine_eject/proc/countdown()
	if(src.timeleft <= 0)
		spawn(0) src.countdone()
		return
	if(status > 0)
		timeleft--
		if(timeleft < 15 || timeleft == 30)
			world << "\red<B>[timeleft] seconds until engine ejection.</B>"
		spawn(10) countdown()
/obj/machinery/computer/engine
	icon = 'enginecomputer.dmi'
	density = 1
/area/testlab3
/obj/machinery/computer/engine/ex_act(severity)
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
/area/testlab4
/area/toolstorage
/obj/machinery/computer/engine/New()
	if(!engine_eject_control)
		engine_eject_control = new /datum/engine_eject()
	..()
/area/medicalstorage
/obj/machinery/computer/engine/verb/eject()
	set name = "Engine Eject Control"
	set desc = "Toggle Eject Status"
	set src in oview(1)
	if(usr.stat) return
	if(engine_eject_control:status == 0)
		if(alert("Eject Engine Module?", "Eject Confirm", "Confirm", "Deny") != "Confirm") return
		engine_eject_control:ejectstart()
	else if(engine_eject_control:status > 0)
		if(alert("Stop Ejection of Engine Module?", "Eject Confirm", "Confirm", "Deny") != "Confirm") return
		engine_eject_control:stopcount()
	add_fingerprint(usr)
/obj/machinery/computer/engine/verb/resetcount()
	set src in oview(1)
	if(usr.stat) return
	engine_eject_control:resetcount()
	add_fingerprint(usr)

/area/control_room
/area/controlaccess
/area/sleep_area
/area/crew_quarters
/area/lounge
/area/hallways
/area/hallways/loungehall
/area/hallways/eastairlock
/area/hallways/labaccess
/area/hallways/centralhall
/area/start
/area/supply_station
