/obj/shut_controller
	var/parts = list()
	var/moving
/obj/machinery/shuttle
	icon = 'shuttle.dmi'
/obj/machinery/shuttle/engine
	density = 1
	anchored = 1
/obj/shut_controller/proc/rotate(direct)
	lbl1
	var/SE_X = 1
	var/SE_Y = 1
	var/SW_X = 1
	var/SW_Y = 1
	var/NE_X = 1
	var/NE_Y = 1
	var/NW_X = 1
	var/NW_Y = 1

	for(var/obj/move/M in parts)








		if(M:x < SW_X)
			SW_X = M:x
		if(M:x > SE_X)
			SE_X = M:x

		if(M:y < SW_Y)
			SW_Y = M:y
		if(M:y > NW_Y)
			NW_Y = M:y

		if(M:y > NE_Y)
			NE_Y = M:y
		if(M:y < SE_Y)
			SE_Y = M:y

		if(M:x > NE_X)
			NE_X = M:x
		if(M:x < NW_X)
			NW_X = M:y
	var/length = abs(NE_X - NW_X)
	var/width = abs(NE_Y - SE_Y)
	var/random = pick(parts)

	var/s_direct
	switch(s_direct)
		if(1)
			switch(direct)
				if(90)
					var/tx = SE_X
					var/ty = SE_Y
					var/t_z = random:z

					for(var/obj/move/M in parts)

						M:ty = -(M:x - tx)
						M:tx = -(M:y - ty)
						var/turf/T = locate(M:x, M:y, 11)
						M:relocate(T)
						M:ty = -M:ty
						M:tx += length
					for(var/obj/move/M in parts)
						M:tx += tx
						M:ty += ty
						var/turf/T = locate(M:tx, M:ty, t_z)
						M:relocate(T, 90)
				if(-90)
					var/tx = SE_X
					var/ty = SE_Y
					var/t_z = random:z

					for(var/obj/move/M in parts)
						M:ty = M:x - tx
						M:tx = M:y - ty
						var/turf/T = locate(M:x, M:y, 11)
						M:relocate(T)
						M:ty = -M:ty
						M:ty += width
					for(var/obj/move/M in parts)
						M:tx += tx
						M:ty += ty
						var/turf/T = locate(M:tx, M:ty, t_z)
						M:relocate(T, -90)






























































/obj/machinery/computer/prison_shuttle
	icon_state = "shuttlecom"
	icon = 'shuttle.dmi'
/obj/machinery/shuttle/engine/propulsion
	icon_state = "propulsion"
	opacity = 1
/obj/machinery/shuttle/engine/propulsion/burst
/obj/machinery/shuttle/engine/propulsion/burst/left
	icon_state = "burst_l"
/obj/machinery/shuttle/engine/propulsion/burst/right
	icon_state = "burst_r"
/obj/machinery/shuttle/engine/router
	icon_state = "router"
/obj/machinery/shuttle/engine/platform
	icon_state = "platform"
/obj/machinery/shuttle/engine/heater
	icon_state = "heater"
/area/shuttle
/area/shuttle_prison
/obj/machinery/computer/prison_shuttle/ex_act(severity)
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


/obj/machinery/computer/prison_shuttle/verb/take_off()
	set src in oview(1)
	if(usr.stat || usr.restrained()) return
	add_fingerprint(usr)
	if(prison_entered)
		var/A = locate(/area/shuttle)
		for(var/turf/T as turf in A)
			if(T:z == 1)
				for(var/atom/movable/AM in T)
					AM:z = 12
				var/turf/U = locate(T:x, T:y, 12)
				U:oxygen = T:oxygen
				U:oldoxy = T:oldoxy
				U:tmpoxy = T:tmpoxy

				U:poison = T:poison
				U:oldpoison = T:oldpoison
				U:tmppoison = T:tmppoison

				U:co2 = T:co2
				U:oldco2 = T:oldco2
				U:tmpco2 = T:tmpco2

				del(T)
		prison_entered = null
	else if(!prison_entered)
		if(!ticker:shuttle_entered)
			var/A = locate(/area/shuttle_prison)
			for(var/turf/T as turf in A)
				if(T:z == 12)
					for(var/atom/movable/AM in T)
						AM:z = 1
					var/turf/U = locate(T:x, T:y, 1)
					U:oxygen = T:oxygen
					U:oldoxy = T:oldoxy
					U:tmpoxy = T:tmpoxy

					U:poison = T:poison
					U:oldpoison = T:oldpoison
					U:tmppoison = T:tmppoison

					U:co2 = T:co2
					U:oldco2 = T:oldco2
					U:tmpco2 = T:tmpco2

					del(T)
			prison_entered = 1
		else
			usr << "\blue There is an obstructing shuttle!"
			return
/obj/machinery/computer/prison_shuttle/verb/restabalize()
	set src in oview(1)
	view() << "\red<B>Restabalizing prison shuttle atmosphere!</B>"
	var/A = locate(/area/shuttle_prison)
	for(var/obj/move/T in A)
		T:firelevel = 0

		T:oxygen = 756000
		T:oldoxy = 756000
		T:tmpoxy = 756000

		T:poison = 0
		T:oldpoison = 0
		T:tmppoison = 0

		T:co2 = 0
		T:oldco2 = 0
		T:tmpco2 = 0

		T:sl_gas = 0
		T:osl_gas = 0
		T:tsl_gas = 0

		T:n2 = 2844000
		T:on2 = 2844000
		T:tn2 = 2844000

		T:heat = 9.8892006e8
		T:oheat = 9.8892006e8
		T:theat = 9.8892006e8
	view() << "\red<B>Prison shuttle Restabalized!</B>"
	add_fingerprint(usr)

/obj/machinery/computer/shuttle
	icon_state = "shuttlecom"
	icon = 'shuttle.dmi'
/obj/machinery/computer/shuttle/ex_act(severity)
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
/obj/machinery/computer/shuttle
	var/mob/authorized = list()

/obj/machinery/computer/shuttle/var/auth_need = 3
/obj/machinery/computer/shuttle/verb/restabalize()
	set src in oview(1)
	world << "\red<B>Restabalizing shuttle atmosphere!</B>"
	var/A = locate(/area/shuttle)
	for(var/obj/move/T in A)
		T:firelevel = 0

		T:oxygen = 756000
		T:oldoxy = 756000
		T:tmpoxy = 756000

		T:poison = 0
		T:oldpoison = 0
		T:tmppoison = 0

		T:co2 = 0
		T:oldco2 = 0
		T:tmpco2 = 0

		T:sl_gas = 0
		T:osl_gas = 0
		T:tsl_gas = 0

		T:n2 = 2844000
		T:on2 = 2844000
		T:tn2 = 2844000

		T:heat = 9.8892006e8
		T:oheat = 9.8892006e8
		T:theat = 9.8892006e8
	world << "\red<B>Shuttle Restabalized!</B>"
	add_fingerprint(usr)
/obj/machinery/computer/shuttle/verb/hijack()
	set src in oview(1)
	if(!ticker || ticker:shuttle_entered)
		return
	if(usr != ticker:killer) return
	world << "\blue<B>Alert: The shuttle is has been hijacked prematurely by the traitor!</B>"
	ticker:timing = 1
	ticker:timeleft = 10
	ticker:shuttle_entered = 1
	add_fingerprint(usr)
/obj/machinery/computer/shuttle/attackby(obj/W, mob/user)
	if(!istype(W, /obj/item/weapon/card/id) || (!ticker || (!ticker:shuttle_entered || !user)))
		return
	if(W:access_level < 1)
		user << "The access level ([W:access_level]) of [W:registered] card is not high enough. (It must be at least level 1.)"
		return
	var/choice = alert(user, "Would you like to (un)authorize a shortened launch time? [auth_need - authorized:len] authorization\s are still needed. Use abort to cancel all authorizations.", "Shuttle Launch", "Authorize", "Repeal", "Abort")
	switch(choice)
		if("Authorize")
			authorized -= W:registered
			authorized += W:registered
			if(auth_need - authorized:len > 0)
				world << "\blue<B>Alert: [auth_need - authorized:len] authorizations needed until shuttle is launched early</B>"
			else
				world << "\blue<B>Alert: Shuttle launch time shortened to 10 seconds!</B>"
				ticker:timeleft = 100
				del(authorized)
				authorized = list()
		if("Repeal")
			authorized -= W:registered
			world << "\blue<B>Alert: [auth_need - authorized:len] authorizations needed until shuttle is launched early</B>"
		if("Abort")
			world << "\blue<B>All authorizations to shorting time for shuttle launch have been revoked!</B>"
			authorized:len = 0
			authorized = list()
/turf/station/shuttle
	icon = 'shuttle.dmi'
/turf/station/shuttle/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			if(prob(50))
				del(src)














/obj/shuttle/door
	icon_state = "door1"
	var/visible = 1
	var/operating
	icon = 'shuttle.dmi'
	opacity = 1
	density = 1
	anchored = 1
/turf/station/shuttle/wall
	icon_state = "wall"
	opacity = 1
	density = 1
	updatecell = 0
/turf/station/shuttle/floor
	icon_state = "floor"
	updatecell = 1
/obj/shuttle/door/verb/open()
	set src in oview(1)
	add_fingerprint(usr)
	if(operating) return
	operating = 1
	flick("doorc0", src)
	icon_state = "door0"
	sleep(15)
	density = 0
	opacity = 0



	verbs -= /obj/shuttle/door/verb/open
	verbs += /obj/shuttle/door/proc/close
	operating = 0
/obj/shuttle/door/proc/close()
	set src in oview(1)
	add_fingerprint(usr)
	if(operating) return
	operating = 1
	flick("doorc1", src)
	icon_state = "door1"
	density = 1
	if(visible) opacity = 1



	sleep(15)
	verbs += /obj/shuttle/door/verb/open
	verbs -= /obj/shuttle/door/proc/close
	operating = 0
