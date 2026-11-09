/turf/station
	intact = 1
/turf/station/airtunnel
	var/activated = 1
/turf/station/airtunnel/attack_paw(mob/user)
	return attack_hand(user)
/turf/station/airtunnel/attack_hand(mob/user)
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
/turf/station/airtunnel/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			if(prob(50))
				del(src)
/turf/station/airtunnel
	icon = 'airtunnel.dmi'

/turf/station/airtunnel/floor/activate()
	icon_state = "floor"
	name = "floor"
	oxygen = 756000
	activated = 1
	if(istype(S, /obj/machinery/atmoalter/siphs))
		S:loc = src
		S = null
	..()
/turf/station/airtunnel/floor/var/S
/turf/station/airtunnel/floor/deactivate()
	S = locate(/obj/machinery/atmoalter/siphs/fullairsiphon/air_vent) in src
	if(!S) S = locate(/obj/machinery/atmoalter/siphs/scrubbers/air_filter) in src
	if(S)
		S:loc = null
	..()
/turf/station/airtunnel/floor
	icon_state = "floor"
	updatecell = 1
/turf/station/airtunnel/wall
	icon_state = "wall"
/turf/station/airtunnel/wall/activate()
	icon_state = "wall"
	name = "wall"
	density = 1
	opacity = 1
	updatecell = 0
	activated = 1
	oxygen = 100
/turf/station/airtunnel/wall/opacity = 1
/turf/station/airtunnel/proc/deactivate()
	updatecell = 1
	activated = 0
	icon_state = "space"
	name = "space"
	oxygen = 0
	poison = 0
	co2 = 0
	density = 0
	opacity = 0
/turf/station/airtunnel/proc/activate()
/turf/station/airtunnel/updatecell()
	if(activated)
		..()
	else return
/turf/station/airtunnel/Entered(A as mob|obj)
	if(activated)
		..()
	else
		spawn(3)
			if(A && A:loc == src)
				step(A, WEST)
/obj/machinery/camera
	name = "Security Camera"
	icon_state = "camera"
	var/c_tag
	icon = 'stationobjs.dmi'
	anchored = 1
	var/status = 1
/turf/station/airtunnel/wall/density = 1
/turf/station/airtunnel/wall/updatecell = 0
/obj/machinery/camera/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/wirecutters))
		status = !status
		if(!status)
			for(var/mob/O in view(user))
				O:show_message("\red[user] has deactivated [src]!", 1)
			icon_state = "camera1"
		else
			for(var/mob/O in view(user))
				O:show_message("\red[user] has reactivated [src]!", 1)
			icon_state = "camera"
/obj/machinery/sec_lock
	name = "Security Pad"
	icon_state = "sec_lock"
	var/obj/item/weapon/card/id/scan
	var/a_type = 0
	icon = 'stationobjs.dmi'
	anchored = 1
/obj/machinery/sec_lock/attack_paw(mob/user)
	return attack_hand(user)
/obj/machinery/sec_lock/attack_hand(mob/user)
	if(loc == user:loc)
		var/dat = {"<B>Security Pad:</B><BR>
Keycard: [scan ? "<A href='?src=\ref[src];card=1'>[scan:name]</A>" : "<A href='?src=\ref[src];card=1'>-----</A>"]<BR>
<A href='?src=\ref[src];door1=1'>Toggle Outer Door</A><BR>
<A href='?src=\ref[src];door2=1'>Toggle Inner Door</A><BR>
<BR>
<A href='?src=\ref[src];em_cl=1'>Emergency Close</A><BR>
<A href='?src=\ref[src];em_op=1'>Emergency Open</A><BR>"}
		user << browse(dat, "window=sec_lock")
/obj/machinery/sec_lock/attackby(nothing, mob/user)
	return attack_hand(user)
/obj/machinery/sec_lock
	var/obj/machinery/door/d1; var/obj/machinery/door/d2
/obj/machinery/sec_lock/New()
	..()
	spawn(2)
		if(a_type == 1)
			d2 = locate(/obj/machinery/door) in locate(x - 2, y - 1, z)
			d1 = locate(/obj/machinery/door) in get_step(src, SOUTHWEST)
		else if(a_type == 2)
			d2 = locate(/obj/machinery/door) in locate(x - 2, y + 1, z)
			d1 = locate(/obj/machinery/door) in get_step(src, NORTHWEST)
		else
			d1 = locate(/obj/machinery/door) in get_step(src, SOUTH)
			d2 = locate(/obj/machinery/door) in get_step(src, SOUTHEAST)
/obj/machinery/sec_lock/Topic(href, href_list)
	if(!istype(usr, /mob/human) && (!ticker || ticker && ticker:mode != "monkey"))
		usr << "\red You don't have the dexterity to do this!"
		return
	if(usr.stat || usr.restrained()) return
	if(!d1 || !d2)
		usr << "\red Error: Cannot interface with door security!"
		return
	if(usr.contents:Find(src) || get_dist(src, usr) <= 1 && istype(loc, /turf))
		usr.machine = src
		if(href_list["card"])
			if(scan)
				scan:loc = loc
				scan = null
			else
				var/I = usr.equipped()
				if(istype(I, /obj/item/weapon/card/id))
					usr.drop_item()
					I:loc = src
					scan = I
		if(href_list["door1"])
			if(scan)
				var/L = list("Prison Security", "Prison Warden", "Security Officer", "Head of Personnel", "Captain")
				if(L:Find(scan:assignment) || scan:lab_access > 4 && scan:access_level > 4)
					if(d1:density) spawn(0) d1:open()
					else spawn(0) d1:close()
		if(href_list["door2"])
			if(scan)
				var/L = list("Prison Security", "Prison Warden", "Security Officer", "Head of Personnel", "Captain")
				if(L:Find(scan:assignment) || scan:lab_access > 4 && scan:access_level > 4)
					if(d2:density) spawn(0) d2:open()
					else spawn(0) d2:close()
		if(href_list["em_cl"])
			if(scan)
				var/L = list("Prison Security", "Prison Warden", "Security Officer", "Head of Personnel", "Captain")
				if(L:Find(scan:assignment) || scan:lab_access > 4 && scan:access_level > 4)
					spawn(0)
						if(!d1:density) d1:close()
					sleep(1)
					spawn(0)
						if(!d2:density) d2:close()
		if(href_list["em_op"])
			if(scan)
				var/L = list("Prison Security", "Prison Warden", "Security Officer", "Head of Personnel", "Captain")
				if(L:Find(scan:assignment) || scan:lab_access > 4 && scan:access_level > 4)
					spawn(0)
						if(d1:density) d1:open()
					sleep(1)
					spawn(0)
						if(d2:density) d2:open()
		add_fingerprint(usr)
		for(var/mob/M in src.loc)
			if(M:client && M:machine == src)
				spawn(0) attack_hand(M)
/obj/machinery/autolathe
	name = "Autolathe"
	icon_state = "autolathe"
	var/m_amount = 0
	var/g_amount = 0
	var/operating = 0
	var/opened = 0
	var/temp
	icon = 'stationobjs.dmi'
/obj/machinery/autolathe/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/weapon/sheet/metal))
		if(m_amount < 150000)
			m_amount += O:height * O:width * O:length * 1000000
			O:amount--
			if(O:amount < 1) del(O)
	else if(istype(O, /obj/item/weapon/sheet/glass))
		if(g_amount < 75000)
			g_amount += O:height * O:width * O:length * 1000000
			O:amount--
			if(O:amount < 1) del(O)
	else if(istype(O, /obj/item/weapon/screwdriver))
		if(!operating)
			opened = !opened
			icon_state = "autolathe[opened ? "f" : null]"
		else
			user << "\red The machine is in use. You can not maintain it now."
	else
		spawn(0) attack_hand(user)
/obj/machinery/autolathe/attack_paw(mob/user)
	return attack_hand(user)
/obj/machinery/autolathe/attack_hand(mob/user)
	var/dat
	if(temp)
		dat = "<TT>[temp]</TT><BR><BR><A href='?src=\ref[src];temp=1'>Clear Screen</A>"
	else
		dat = {"<B>Metal Amount:</B> [m_amount] cubic centimeters (MAX: 150,000)<BR>
<FONT color = blue><B>Glass Amount:</B></FONT> [g_amount] cubic centimeters (MAX: 75,000)<HR>"}
		var/L = list()
		L["screwdriver"] = "Make Screwdriver {40 cc}"
		L["wirecutters"] = "Make Wirecutters {80 cc}"
		L["wrench"] = "Make Wrench {150 cc}"
		L["crowbar"] = "Make Crowbar {150 cc}"
		L["screw"] = "Make Screw (1) {3 cc}"
		L["5screws"] = "Make Screws (5) {14 cc}"
		L["rod_t"] = "Make Rod (1x20) {20 cc}"
		L["rod_l"] = "Make Rod (5x250) {1250 cc}"
		L["grille_1"] = "Make Grille (250x250x1) {27345 cc}"
		L["sheet_1"] = "Make Sheet (20x10x.01) {2 cc}"
		L["sheet_2"] = "Make Sheet (30x10x.01) {3 cc}"
		L["sheet_3"] = "Make Sheet (30x20x.01) {6 cc}"
		L["sheet_4"] = "Make Sheet (30x30x.01) {9 cc}"
		L["sheet_5"] = "Make Sheet (62.5x62.5x4) {15625 cc}"
		for(var/t in L)
			dat += "<A href='?src=\ref[src];make=[t]'>[L["[t]"]]<BR>"
	user << browse("<HEAD><TITLE>Autolathe Control Panel</TITLE></HEAD><TT>[dat]</TT>", "window=autolathe")
/obj/machinery/autolathe/Topic(href, href_list)
	if(usr.stat || usr.restrained()) return
	if(usr.contents:Find(src) || get_dist(src, usr) <= 1 && istype(loc, /turf))
		usr.machine = src
		if(href_list["temp"])
			temp = null
		add_fingerprint(usr)
	for(var/mob/M in view(1, src))
		if(M:client && M:machine == src) attack_hand(M)

/obj/machinery/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			if(prob(50)) del(src)
		if(3)
			if(prob(25)) del(src)
/obj/move
	var/master
	var/tx
	var/ty
/obj/machinery/wire
/obj/machinery/injector/attackby(obj/W, mob/user)
	var/ptank = W
	if(!istype(ptank, /obj/item/weapon/tank)) return
	var/T = get_step(loc, get_dir(user, src))
	ptank:gas:turf_add(T, -1)
	add_fingerprint(user)




/obj/machinery/alarm/process()
	..()
	var/T = loc
	if(locate(/obj/move) in T) T = locate(/obj/move) in T
/obj/machinery/alarm
	icon_state = "alarm:0"
	icon = 'stationobjs.dmi'
	anchored = 1


/obj/machinery/computer/airtunnel/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			if(prob(50))
				del(src)
/obj/machinery/computer/airtunnel
	name = "Air Tunnel Alert"
	icon_state = "console1"
	icon = 'airtunnel.dmi'
	density = 0
	var/status = 1

/obj/machinery/computer/airtunnel/primary/ex_act(severity)
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
/obj/machinery/computer/airtunnel/primary
	name = "Air Tunnel Controller"
	icon = 'airtunnelcomputer.dmi'
	density = 1
/obj/machinery/computer/airtunnel/primary/verb/toggletunnel()
	set src in oview(1)
	if(usr.stat || (usr.restrained() || (usr.stunned || usr.weakened))) return
	status = !status
	if(status)
		for(var/turf/station/airtunnel/at in world)
			at:activate()
	else
		for(var/turf/station/airtunnel/at in world)
			at:deactivate()
	for(var/obj/machinery/computer/airtunnel/atc in world)
		atc:icon_state = "console[status]"
		atc:status = status
	add_fingerprint(usr)

/obj/machinery/injector
	icon_state = "injector"
	icon = 'stationobjs.dmi'
	density = 1
	anchored = 1
