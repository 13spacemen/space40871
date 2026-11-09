





















































/atom/proc/ex_act()
/atom/proc/las_act()
/turf/Entered(A as mob|obj)
	..()
	if(A && (A:density && !istype(A, /obj/beam)))
		for(var/obj/beam/i_beam/I in src)
			spawn(0) if(I) I:hit()

/obj/beam/a_laser
	icon_state = "laser"
	var/yo
	var/xo
	icon = 'weap_sat.dmi'
	density = 1
	anchored = 1
	flags = 2
	var/current
/obj/beam/a_laser/Bump(A as mob|obj|turf|area)
	A:las_act(null, src)
	del(src)
/obj/beam/a_laser/proc/process()
	if(!current || loc == current)
		current = locate(min(max(x + xo, 1), world.maxx), min(max(y + yo, 1), world.maxy), z)
	if(x == 1 || (x == world.maxx || (y == 1 || y == world.maxy))) del(src)
	step_towards(src, current)
	spawn(2) process()
/obj/beam/a_laser/s_laser
	icon_state = "spark"
/obj/beam/a_laser/s_laser/Bump(A as mob|obj|turf|area)
	A:las_act(1)
	del(src)
/obj/beam/i_beam
	icon_state = "laser"
	var/next
	var/obj/item/weapon/infra/master
	var/limit
	icon = 'weap_sat.dmi'
	anchored = 1
	flags = 2
	var/visible = 0
/obj/beam/i_beam/proc/hit()
	if(master)
		master:hit()
	del(src)
/obj/beam/i_beam/Bump()
	del(src)
/obj/beam/i_beam/Bumped()
	hit()
/obj/beam/i_beam/HasEntered(AM as mob|obj)
	if(istype(AM, /obj/beam)) return
	spawn(0) hit()
/obj/beam/i_beam/Del()
	del(src.next)
	..()

/obj/beam/i_beam/proc/vis_spread(v)
	src.visible = v
	spawn(0) if(src.next) next:vis_spread(v)

/obj/beam/i_beam/proc/process()
	if(loc:density || !master)
		del(src)

	if(left > 0) left--
	if(left < 1)
		if(!visible)
			invisibility = 100
		else invisibility = 0
	else invisibility = 0


	var/obj/beam/i_beam/I = new /obj/beam/i_beam(loc)
	I:master = master
	I:density = 1
	I:dir = dir
	step(I, I:dir)
	if(I)
		if(!next)
			I:density = 0
			I:vis_spread(visible)
			next = I
			spawn(0)
				if(I && limit > 0)
					I:limit = limit - 1
					I:process()
		else del(I)
	else del(next)
	spawn(10) process()



/obj/item/weapon/infra_sensor
	icon_state = "infra_sensor"
	name = "Infrared Sensor"
	var/passive = 1
	flags = 322
	s_istate = "electronic"
/obj/item/weapon/infra_sensor/New()
	..()
	spawn(0) process()
/obj/item/weapon/infra_sensor/proc/process()
	if(passive)
		for(var/obj/beam/i_beam/I in range(2, src.loc))
			I:left = 2
	spawn(10) process()
/obj/item/weapon/infra_sensor/proc/burst()
	for(var/obj/beam/i_beam/I in range(loc))
		I:left = 10
	for(var/obj/item/weapon/infra/I in range(loc))
		I:visible = 1
		spawn(0) if(I && I:first) I:first:vis_spread(1)
	for(var/obj/item/weapon/assembly/rad_infra/I in range(loc))
		I:part2:visible = 1
		spawn(0) if(I:part2 && I:part2:first) I:part2:first:vis_spread(1)

/obj/item/weapon/infra_sensor/attack_self(mob/user)
	user:machine = src
	var/dat = {"<TT><B>Infrared Sensor</B><BR>
<B>Passive Emitter</B>: [passive ? "<A href='?src=\ref[src];passive=0'>On</A>" : "<A href='?src=\ref[src];passive=1'>Off</A>"]<BR>
<B>Active Emitter</B>: <A href='?src=\ref[src];active=0'>Burst Fire</A>
</TT>"}
	user << browse(dat, "window=infra_sensor")
/obj/item/weapon/infra_sensor/Topic(href, href_list)
	if(usr.stat) return
	if(usr.contents:Find(src) || (usr.contents:Find(master) || get_dist(src, usr) <= 1 && istype(loc, /turf)))
		usr.machine = src
		if(href_list["passive"])
			passive = !passive
		if(href_list["active"])
			spawn(0) burst()
		if(!master)
			if(istype(loc, /mob))
				attack_self(loc)
			else
				for(var/mob/M in view(1, src))
					if(M:client) attack_self(M)
		else
			if(istype(master:loc, /mob))
				attack_self(master:loc)
			else
				for(var/mob/M in view(1, master))
					if(M:client) attack_self(M)
		add_fingerprint(usr)
	else
		usr << browse(null, "window=infra_sensor")
		return
/obj/item/weapon/prox_sensor
	icon_state = "motion0"
	name = "Proximity Sensor"
	animate_movement = 2
	flags = 322
	w_class = 2
	s_istate = "electronic"
	var/state = 0
/obj/item/weapon/prox_sensor/dropped()
	spawn(0) sense()
/obj/item/weapon/prox_sensor/proc/sense()
	if(state)
		if(master)
			spawn(0) master:r_signal(1, src)
		else
			for(var/mob/O in view())
				O:show_message("\icon[src] *beep* *beep*", 3, "*beep* *beep*", 2)
/obj/item/weapon/prox_sensor/HasProximity(AM as mob|obj)
	if(istype(AM, /obj/beam)) return
	if(AM:move_speed < 12)
		sense()
/obj/item/weapon/prox_sensor/attackby(obj/S, mob/user)
	if(!istype(S, /obj/item/weapon/radio/signaler) || !S:b_stat) return
	var/R = new /obj/item/weapon/assembly/rad_prox(user)
	S:loc = R
	R:part1 = S

	S:layer = initial(S:layer)
	if(user:client) user:client:screen -= S

	if(user:r_hand == S)
		user:u_equip(S)
		user:r_hand = R
	else
		user:u_equip(S)
		user:l_hand = R
	S:master = R
	master = R
	layer = initial(layer)
	user:u_equip(src)
	if(user:client) user:client:screen -= src
	loc = R
	R:part2 = src
	R:layer = 20
	R:loc = user
	R:dir = dir
	add_fingerprint(user)

/obj/item/weapon/prox_sensor/attack_self(mob/user)
	user:machine = src
	var/dat = {"<TT><B>Proximity Sensor</B>
<B>Status</B>: [state ? "<A href='?src=\ref[src];state=0'>On</A>" : "<A href='?src=\ref[src];state=1'>Off</A>"]<BR>
[state ? "Time On (10)" : "<A href='?src=\ref[src];time=1'>Time On (10)</A>"]
</TT>"}
	user << browse(dat, "window=prox")
/obj/item/weapon/prox_sensor/Topic(href, href_list)
	if(usr.stat) return
	if(usr.contents:Find(src) || (usr.contents:Find(master) || get_dist(src, usr) <= 1 && istype(loc, /turf)))
		usr.machine = src
		if(href_list["state"])
			state = !state
			icon_state = "motion[state]"
			if(master) master:c_state(state, src)
		if(href_list["time"])
			spawn(100)
				if(state == 0)
					state = !state
					icon_state = "motion[state]"
					if(master) master:c_state(state, src)
		if(!master)
			if(istype(loc, /mob))
				attack_self(loc)
			else
				for(var/mob/M in view(1, src))
					if(M:client) attack_self(M)
		else
			if(istype(master:loc, /mob))
				attack_self(master:loc)
			else
				for(var/mob/M in view(1, master))
					if(M:client) attack_self(M)
	else
		usr << browse(null, "window=prox")
		return






/obj/item/weapon/prox_sensor/attack_paw(mob/user)
	return attack_hand(user)
/obj/item/weapon/prox_sensor/Move()
	..()
	sense()
/obj/item/weapon/infra
	icon_state = "infrared0"
	name = "Infrared Beam (Security)"
	var/first
	var/state = 0
	animate_movement = 2
	flags = 322
	w_class = 2; s_istate = "electronic"
	var/visible = 0
/obj/item/weapon/infra/proc/hit()
	if(master)
		spawn(0) master:r_signal(1, src)
	else
		for(var/mob/O in view())
			O:show_message("\icon[src] *beep* *beep*", 3, "*beep* *beep*", 2)
/obj/item/weapon/infra/attackby(obj/S, mob/user)
	if(!istype(S, /obj/item/weapon/radio/signaler) || !S:b_stat) return
	var/R = new /obj/item/weapon/assembly/rad_infra(user)
	S:loc = R
	R:part1 = S

	S:layer = initial(S:layer)
	if(user:client) user:client:screen -= S

	if(user:r_hand == S)
		user:u_equip(S)
		user:r_hand = R
	else
		user:u_equip(S)
		user:l_hand = R
	S:master = R
	master = R
	layer = initial(layer)
	user:u_equip(src)
	if(user:client) user:client:screen -= src
	loc = R
	R:part2 = src
	R:layer = 20
	R:loc = user
	R:dir = dir
	add_fingerprint(user)
/obj/item/weapon/infra/New()
	spawn(0) process()
	..()

/obj/item/weapon/infra/proc/process()
	if(!first && (state && (istype(loc, /turf) || master && istype(master:loc, /turf))))
		var/obj/beam/i_beam/I = new /obj/beam/i_beam(master ? master:loc : loc)
		I:master = src
		I:density = 1
		I:dir = dir
		step(I, I:dir)
		if(I)
			I:density = 0
			first = I
			I:vis_spread(visible)
			spawn(0)
				if(I)
					I:limit = 20
					I:process()
	if(!state) del(first)
	spawn(10) process()

/obj/item/weapon/infra/attack_self(mob/user)
	user:machine = src
	var/dat = {"<TT><B>Infrared Laser</B>
<B>Status</B>: [state ? "<A href='?src=\ref[src];state=0'>On</A>" : "<A href='?src=\ref[src];state=1'>Off</A>"]<BR>
<B>Visibility</B>: [visible ? "<A href='?src=\ref[src];visible=0'>Visible</A>" : "<A href='?src=\ref[src];visible=1'>Invisible</A>"]<BR>
</TT>"}
	user << browse(dat, "window=infra")
/obj/item/weapon/infra/Topic(href, href_list)
	if(usr.stat) return
	if(usr.contents:Find(src) || (usr.contents:Find(master) || get_dist(src, usr) <= 1 && istype(loc, /turf)))
		usr.machine = src
		if(href_list["state"])
			state = !state
			icon_state = "infrared[state]"
			if(master) master:c_state(state, src)
		if(href_list["visible"])
			visible = !visible
			spawn(0) if(first) first:vis_spread(visible)


		if(!master)
			if(istype(loc, /mob))
				attack_self(loc)
			else
				for(var/mob/M in view(1, src))
					if(M:client) attack_self(M)
		else
			if(istype(master:loc, /mob))
				attack_self(master:loc)
			else
				for(var/mob/M in view(1, master))
					if(M:client) attack_self(M)
	else
		usr << browse(null, "window=infra")
		return






/obj/item/weapon/infra/attack_paw(mob/user)
	return attack_hand(user)
/obj/item/weapon/infra/attack_hand()
	del(first)
	..()
/obj/item/weapon/infra/Move()
	var/t = src.dir
	..()
	src.dir = t
	del(src.first)
/obj/item/weapon/infra/verb/rotate()
	set src in usr
	dir = turn(dir, 90)
/obj/item/weapon/timer
	icon_state = "timer"
	flags = 322
	w_class = 2
	s_istate = "electronic"
	var/timing = 0
	var/time
/obj/item/weapon/timer/proc/time()
	if(master)
		spawn(0) master:r_signal(1, src)
	else
		for(var/mob/O in view())
			O:show_message("\icon[src] *beep* *beep*", 3, "*beep* *beep*", 2)
/obj/item/weapon/timer/attackby(obj/S, mob/user)
	if(!istype(S, /obj/item/weapon/radio/signaler) || !S:b_stat) return
	var/R = new /obj/item/weapon/assembly/rad_time(user)
	S:loc = R
	R:part1 = S

	S:layer = initial(S:layer)
	if(user:client) user:client:screen -= S

	if(user:r_hand == S)
		user:u_equip(S)
		user:r_hand = R
	else
		user:u_equip(S)
		user:l_hand = R
	S:master = R
	master = R
	layer = initial(layer)
	user:u_equip(src)
	if(user:client) user:client:screen -= src
	loc = R
	R:part2 = src
	R:layer = 20
	R:loc = user
	R:dir = dir
	add_fingerprint(user)
	R:add_fingerprint(user)
/obj/item/weapon/timer/New()
	spawn(0) process()
	..()

/obj/item/weapon/timer/proc/process()
	if(timing)
		if(time > 0)
			time = round(time) - 1
		else
			time()
			time = 0
			timing = 0
		if(!master)
			if(istype(loc, /mob))
				attack_self(loc)
			else
				for(var/mob/M in view(1, src))
					if(M:client) attack_self(M)
		else
			if(istype(master:loc, /mob))
				attack_self(master:loc)
			else
				for(var/mob/M in view(1, master))
					if(M:client) attack_self(M)
	spawn(10) process()
/obj/item/weapon/timer/attack_self(mob/user)
	user:machine = src
	var/second = time % 60
	var/minute = (time - second) / 60
	var/dat = {"<TT><B>Timing Unit</B>
[timing ? "<A href='?src=\ref[src];time=0'>Timing</A>" : "<A href='?src=\ref[src];time=1'>Not Timing</A>"] [minute]:[second]
<A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>
</TT>"}
	user << browse(dat, "window=timer")
/obj/item/weapon/timer/Topic(href, href_list)
	if(usr.stat) return
	if(usr.contents:Find(src) || (usr.contents:Find(master) || get_dist(src, usr) <= 1 && istype(loc, /turf)))
		usr.machine = src
		if(href_list["time"])
			timing = text2num(href_list["time"])
		if(href_list["tp"])
			var/tp = text2num(href_list["tp"])
			time += tp
			time = min(max(round(time), 0), 600)


		if(!master)
			if(istype(loc, /mob))
				attack_self(loc)
			else
				for(var/mob/M in view(1, src))
					if(M:client) attack_self(M)
		else
			if(istype(master:loc, /mob))
				attack_self(master:loc)
			else
				for(var/mob/M in view(1, master))
					if(M:client) attack_self(M)
		add_fingerprint(usr)
	else
		usr << browse(null, "window=timer")
		return

/obj/item/weapon/assembly/proc/r_signal(signal)
/obj/item/weapon/assembly
	icon = 'assemblies.dmi'
/obj/item/weapon/assembly/proc/c_state(n, obj/O)
/obj/item/weapon/assembly
	s_istate = "assembly"
	w_class = 3

/obj/item/weapon/assembly/shock_kit/Del()
	del(part1)
	del(part2)
	..()
/obj/item/weapon/assembly/shock_kit
	desc = "Emits a very strong pulse when triggered."; desc = null; name = "Shock Kit"
	icon_state = "shock_kit"
	var/part1
	var/part2
	var/status = 0
/obj/item/weapon/assembly/shock_kit/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench) && !status)
		var/T = loc
		if(ismob(T)) T = T:loc
		part1:loc = T
		part2:loc = T
		part1:master = null
		part2:master = null
		part1 = null
		part2 = null
		del(src)
	if(!istype(W, /obj/item/weapon/screwdriver)) return
	status = !status
	if(status)
		user:show_message("\blue The shock pack is now secured!", 1)
	else user:show_message("\blue The shock pack is now unsecured!", 1)
	add_fingerprint(user)
/obj/item/weapon/assembly/shock_kit/attack_self(mob/user)
	part1:attack_self(user, status)
	part2:attack_self(user, status)
	add_fingerprint(user)
/obj/item/weapon/assembly/shock_kit/r_signal(n, source)
	if(istype(loc, /obj/stool/chair/e_chair))
		var/C = loc
		C:shock()
/obj/item/weapon/assembly/shock_kit/w_class = 5
/obj/item/weapon/assembly/shock_kit/flags = 322
/obj/item/weapon/assembly/rad_time/Del()
	del(part1)
	del(part2)
	..()
/obj/item/weapon/assembly/rad_time
	desc = "Emits a signal after a specific time. Good for wake up calls or carefully timed experiments."; desc = null; name = "Signaler/Timer Assembly"
	icon_state = "time_sig"
	var/part1
	var/part2
	flags = 322
/obj/item/weapon/assembly/rad_time/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench) && !status)
		var/T = loc
		if(ismob(T)) T = T:loc
		part1:loc = T
		part2:loc = T
		part1:master = null
		part2:master = null
		part1 = null
		part2 = null
		del(src)
	if(!istype(W, /obj/item/weapon/screwdriver)) return
	status = !status
	if(status)
		user:show_message("\blue The signaler is now secured!", 1)
	else user:show_message("\blue The signaler is now unsecured!", 1)
	part1:b_stat = !status
	add_fingerprint(user)
/obj/item/weapon/assembly/rad_time/attack_self(mob/user)
	part1:attack_self(user, status)
	part2:attack_self(user, status)
	add_fingerprint(user)
/obj/item/weapon/assembly/rad_time/r_signal(n, source)
	if(source == part2)
		part1:s_signal(1)
/obj/item/weapon/assembly/rad_prox
	desc = "A proximity sensor that emits a beep when triggered."; desc = null; icon_state = "motion0"

/obj/item/weapon/assembly/rad_prox/c_state(n)
	icon_state = "motion[n]"
/obj/item/weapon/assembly/rad_prox/Del()
	del(part1)
	del(part2)
	..()
/obj/item/weapon/assembly/rad_prox/HasProximity(AM as mob|obj)
	if(istype(AM, /obj/beam)) return
	if(AM:move_speed < 12)
		part2:sense()
/obj/item/weapon/assembly/rad_prox
	name = "Signaler/Prox Sensor Assembly"
	var/part1
	var/part2
	var/status
/obj/item/weapon/assembly/rad_prox/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench) && !status)
		var/T = loc
		if(ismob(T)) T = T:loc
		part1:loc = T
		part2:loc = T
		part1:master = null
		part2:master = null
		part1 = null
		part2 = null
		del(src)
	if(!istype(W, /obj/item/weapon/screwdriver)) return
	status = !status
	if(status)
		user:show_message("\blue The proximity sensor is now secured!", 1)
	else user:show_message("\blue The proximity sensor is now unsecured!", 1)
	part1:b_stat = !status
	add_fingerprint(user)
/obj/item/weapon/assembly/rad_prox/attack_self(mob/user)
	part1:attack_self(user, status)
	part2:attack_self(user, status)
	add_fingerprint(user)
/obj/item/weapon/assembly/rad_prox/r_signal(n, source)
	if(source == part2)
		part1:s_signal(1)
/obj/item/weapon/assembly/rad_prox/Move()
	..()
	part2:sense()
/obj/item/weapon/assembly/rad_prox/attack_paw(mob/user)
	return attack_hand(user)
/obj/item/weapon/assembly/rad_prox/dropped()
	spawn(0) part2:sense()
/obj/item/weapon/assembly/rad_time
	var/status
/obj/item/weapon/assembly/rad_infra/desc = "A security beam that emits a beep when triggered."
/obj/item/weapon/assembly/rad_infra/c_state(n)
	icon_state = "infrared[n]"
/obj/item/weapon/assembly/rad_infra/Del()
	del(part1)
	del(part2)
	..()
/obj/item/weapon/assembly/rad_infra
	desc = null; name = "Signaler/Infrared Assembly"
	var/part1
	var/part2
	var/status
/obj/item/weapon/assembly/rad_infra/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench) && !status)
		var/T = loc
		if(ismob(T)) T = T:loc
		part1:loc = T
		part2:loc = T
		part1:master = null
		part2:master = null
		part1 = null
		part2 = null
		del(src)
	if(!istype(W, /obj/item/weapon/screwdriver)) return
	status = !status
	if(status)
		user:show_message("\blue The infrared laser is now secured!", 1)
	else user:show_message("\blue The infrared laser is now unsecured!", 1)
	part1:b_stat = !status
	add_fingerprint(user)
/obj/item/weapon/assembly/rad_infra/attack_self(mob/user)
	part1:attack_self(user, status)
	part2:attack_self(user, status)
	add_fingerprint(user)
/obj/item/weapon/assembly/rad_infra/r_signal(n, source)
	if(source == part2)
		part1:s_signal(1)
/obj/item/weapon/assembly/rad_infra/verb/rotate()
	set src in usr
	src.dir = turn(src.dir, 90)
	part2:dir = src.dir
	add_fingerprint(usr)
/obj/item/weapon/assembly/rad_infra/Move()
	var/t = src.dir
	..()
	src.dir = t
	del(part2:first)
/obj/item/weapon/assembly/rad_infra/attack_paw(mob/user)
	return attack_hand(user)
/obj/item/weapon/assembly/rad_infra/attack_hand(M)
	del(part2:first)
	..()
/obj/item/weapon/assembly/rad_prox{animate_movement = 2; flags = 322}
/obj/item/weapon/assembly/rad_infra{animate_movement = 2; flags = 322}
/obj/item/weapon/assembly/prox_ignite{desc = "A proximity fire starter"; desc = null; name = "Proximity/Igniter Assembly"}
/obj/item/weapon/assembly/prox_ignite/HasProximity(AM as mob|obj)
	if(istype(AM, /obj/beam)) return
	if(AM:move_speed < 12)
		part1:sense()
/obj/item/weapon/assembly/prox_ignite/dropped()
	spawn(0) part1:sense()
/obj/item/weapon/assembly/prox_ignite/Del()
	del(part1)
	del(part2)
	..()
/obj/item/weapon/assembly/prox_ignite/c_state(n)
	icon_state = "prox_igniter[n]"
/obj/item/weapon/assembly/prox_ignite

	icon_state = "prox_igniter0"; var/part1; var/part2
	var/status
/obj/item/weapon/assembly/prox_ignite/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench) && !status)
		var/T = loc
		if(ismob(T)) T = T:loc
		part1:loc = T
		part2:loc = T
		part1:master = null
		part2:master = null
		part1 = null
		part2 = null
		del(src)
	if(!istype(W, /obj/item/weapon/screwdriver)) return
	status = !status
	if(status)
		user:show_message("\blue The proximity sensor is now secured! The igniter now works!", 1)
	else user:show_message("\blue The proximity sensor is now unsecured! The igniter will not work.", 1)
	part2:status = status
	add_fingerprint(user)
/obj/item/weapon/assembly/prox_ignite/attack_self(mob/user)
	part1:attack_self(user, status)
	add_fingerprint(user)
/obj/item/weapon/assembly/prox_ignite/r_signal()
	for(var/mob/O in view(1, loc))
		O:show_message("\icon[src] *beep* *beep*", 3, "*beep* *beep*", 2)
	part2:ignite()
/obj/item/weapon/assembly/prox_ignite/flags = 322
/obj/item/weapon/assembly/rad_ignite/flags = 322
/obj/item/weapon/assembly/rad_infra/icon_state = "infrared0"
/obj/item/weapon/assembly/rad_ignite/Del()
	del(part1)
	del(part2)
	..()
/obj/item/weapon/assembly/rad_ignite
	desc = "A remote controlled fire starter"; desc = null; name = "Radio/Igniter Assembly"
	icon_state = "rad_igniter"
	var/part1; var/part2
	var/status
/obj/item/weapon/assembly/rad_ignite/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench) && !status)
		var/T = loc
		if(ismob(T)) T = T:loc
		part1:loc = T
		part2:loc = T
		part1:master = null
		part2:master = null
		part1 = null
		part2 = null
		del(src)
	if(!istype(W, /obj/item/weapon/screwdriver)) return
	status = !status
	if(status)
		user:show_message("\blue The radio is now secured! The igniter now works!", 1)
	else user:show_message("\blue The radio is now unsecured! The igniter will not work.", 1)
	part2:status = status
	part1:b_stat = !status
	add_fingerprint(user)
/obj/item/weapon/assembly/rad_ignite/attack_self(mob/user)
	part1:attack_self(user, status)
	add_fingerprint(user)
/obj/item/weapon/assembly/rad_ignite/r_signal()
	for(var/mob/O in view(1, loc))
		O:show_message("\icon[src] *beep* *beep*", 3, "*beep* *beep*", 2)
	part2:ignite()
/obj/item/weapon/assembly/m_i_ptank
	desc = "A very intricate igniter and proximity sensor electrical assembly mounted onto top of a plasma tank."
	name = "Radio/Igniter/Plasma Tank Assembly"; icon_state = "m_i_ptank"
/obj/item/weapon/assembly/m_i_ptank/c_state(n)
	icon_state = "m_i_ptank[n]"
/obj/item/weapon/assembly/m_i_ptank
	icon_state = "m_i_ptank0"
	var/part1; var/part2; var/part3

/obj/item/weapon/assembly/m_i_ptank/HasProximity(AM as mob|obj)
	if(istype(AM, /obj/beam)) return
	if(AM:move_speed < 12)
		part1:sense()
/obj/item/weapon/assembly/m_i_ptank/dropped()
	spawn(0) part1:sense()
/obj/item/weapon/assembly/m_i_ptank/Del()
	del(part1)
	del(part2)
	del(part3)
	..()


/obj/item/weapon/assembly/m_i_ptank/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench) && !status)
		var/R = new /obj/item/weapon/assembly/prox_ignite()
		R:part1 = part1
		R:part2 = part2
		R:loc = loc

		if(user:r_hand == src)
			user:r_hand = R
			R:layer = 20
		else if(user:l_hand == src)
			user:l_hand = R
			R:layer = 20

		part1:loc = R
		part2:loc = R
		part1:master = R
		part2:master = R
		var/T = loc
		if(!istype(T, /turf)) T = T:loc
		if(!istype(T, /turf)) T = T:loc
		part3:loc = T

		part1 = null
		part2 = null
		part3 = null

		del(src)
	if(!istype(W, /obj/item/weapon/weldingtool)) return
	if(!status)
		status = 1
		bombers -= user:ckey
		bombers += user:ckey
		user:show_message("\blue A pressure hole has been bored to the plasma tank valve. The plasma tank can now be ignited.", 1)
	else
		status = 0
		user << "\blue The hole has been closed."
	part2:status = status
	add_fingerprint(user)
/obj/item/weapon/assembly/m_i_ptank/attack_self(mob/user)
	part1:attack_self(user, 1)
	add_fingerprint(user)
/obj/item/weapon/assembly/m_i_ptank/r_signal()
	for(var/mob/O in view(1))
		O:show_message("\icon[src] *beep* *beep*", 3, "*beep* *beep*", 2)
	if(status && prob(90)) part3:ignite()
/obj/item/weapon/assembly/m_i_ptank
	var/status = 0; flags = 322
/obj/item/weapon/assembly/r_i_ptank
	desc = "A very intricate igniter and signaller electrical assembly mounted onto top of a plasma tank."
	name = "Radio/Igniter/Plasma Tank Assembly"
	icon_state = "r_i_ptank"; flags = 322
	var/part1; var/part2; var/obj/item/weapon/tank/plasmatank/part3; var/status = 0
/obj/item/weapon/assembly/r_i_ptank/Del()
	del(part1)
	del(part2)
	del(part3)
	..()


/obj/item/weapon/assembly/r_i_ptank/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench) && !status)
		var/R = new /obj/item/weapon/assembly/rad_ignite()
		R:part1 = part1
		R:part2 = part2
		R:loc = loc

		if(user:r_hand == src)
			user:r_hand = R
			R:layer = 20
		else if(user:l_hand == src)
			user:l_hand = R
			R:layer = 20

		part1:loc = R
		part2:loc = R
		part1:master = R
		part2:master = R
		var/T = loc
		if(!istype(T, /turf)) T = T:loc
		if(!istype(T, /turf)) T = T:loc
		part3:loc = T

		part1 = null
		part2 = null
		part3 = null

		del(src)
	if(!istype(W, /obj/item/weapon/weldingtool)) return
	if(!status)
		status = 1
		bombers -= user:ckey
		bombers += user:ckey
		user:show_message("\blue A pressure hole has been bored to the plasma tank valve. The plasma tank can now be ignited.", 1)
	else
		status = 0
		user << "\blue The hole has been closed."
	part2:status = status
	part1:b_stat = !status
	add_fingerprint(user)
/obj/item/weapon/assembly/r_i_ptank/attack_self(mob/user)
	part1:attack_self(user, 1)
	add_fingerprint(user)
/obj/item/weapon/assembly/r_i_ptank/r_signal()
	for(var/mob/O in view(1))
		O:show_message("\icon[src] *beep* *beep*", 3, "*beep* *beep*", 2)
	if(status && prob(90)) part3:ignite()

/obj/beam/i_beam
	var/left
