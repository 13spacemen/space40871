
/obj/machinery/proc/process()
/obj/machinery/proc/receive_gas(obj/gas, obj/machinery)
/obj/machinery/meter
	icon_state = "meter"
	icon = 'pipes.dmi'
	anchored = 1
	var/target
/obj/machinery/meter/New()
	..()
	target = locate(/obj/machinery/pipes) in loc
/obj/machinery/meter/Click()
	if(get_dist(usr, src) <= 3)
		if(target)
			usr << "\green<B>[target:gas:tot_gas()] / [target:gas:maximum]</B>"
		else
			usr << "\green<B>Results: Connection Error!</B>"
	else
		usr << "\green<B>You are too far away.</B>"
/obj/machinery/connector
	icon_state = "connector"
	icon = 'pipes.dmi'
	anchored = 1
/obj/machinery/connector/receive_gas(obj/t_gas)
	var/C = locate(/obj/machinery/atmoalter/canister) in loc
	if(C:destroyed)
		var/T = loc
		if(!istype(T, /turf)) return
		t_gas:turf_add(T, -1)
		return
	var/amount = C:gas:maximum - (C:gas:oxygen + C:gas:co2 + C:gas:plasma)
	if(t_gas:co2 + t_gas:plasma + t_gas:oxygen < amount)
		amount = t_gas:co2 + t_gas:plasma + t_gas:oxygen
	C:gas:transfer_from(t_gas, amount)
/obj/machinery/mass_driver
	var/power = 1
	icon_state = "mass_driver"
	var/code = 1
	icon = 'stationobjs.dmi'
	dir = 8
	anchored = 1
	var/id = 1
/obj/machinery/mass_driver/proc/drive(amount)
	for(var/obj/O in loc)
		if(O:flags & 64)
			O:throwing = 1
			O:throwspeed = 100
			spawn(0) O:throwing(dir, power)
	flick("mass_driver1", src)
/obj/machinery/var/p_dir = 0
/obj/machinery/proc/orient_pipe(obj/source)
/obj/machinery/proc/cut_pipes()
/obj/machinery/proc/disc_pipe(obj/target)
/obj/machinery/pipes
	icon = 'reg_pipe.dmi'
	icon_state = "12"
	var/gas
	regular
		desc = "A stretch of pipe... How exciting."
		name = "Normal pipe"
	var/capacity = 6000000
	anchored = 1
/obj/machinery/pipes/orient_pipe(obj/P)
	if(!node1) node1 = P
	else if(!node2) node2 = P
	else
		return 0
	return 1
/obj/machinery/pipes/proc/update()
	var/T = loc
	if(level == 1 && (isturf(loc) && T:intact))
		invisibility = 100
	else invisibility = null
	if(node1 && node2)
		icon_state = "[get_dir(src, node1) | get_dir(src, node2)]"
	else
		var/con = 0
		var/dis = 0
		var/n1d = node1 ? get_dir(src, node1) : null
		var/n2d = node2 ? get_dir(src, node2) : null
		if(p_dir & 1)
			if(n1d == 1 || n2d == 1)
				con |= 1
			else
				dis |= 1
		if(p_dir & 2)
			if(n1d == 2 || n2d == 2)
				con |= 2
			else
				dis |= 2
		if(p_dir & 4)
			if(n1d == 4 || n2d == 4)
				con |= 4
			else
				dis |= 4
		if(p_dir & 8)
			if(n1d == 8 || n2d == 8)
				con |= 8
			else
				dis |= 8
		if(con == 0)
			con = null
		icon_state = "[con]-[dis]"
/obj/machinery/pipes/New()
	..()
	gas = new /obj/substance/gas(src)
	gas:maximum = capacity
	if(world.time > 100) return
	spawn(50)
		var/b1
		var/b2
		if(p_dir & 1)
			if(!b1)
				b1 = 1
			else if(!b2)
				b2 = 1
		if(p_dir & 2)
			if(!b1)
				b1 = 2
			else if(!b2)
				b2 = 2
		if(p_dir & 4)
			if(!b1)
				b1 = 4
			else if(!b2)
				b2 = 4
		if(p_dir & 8)
			if(!b1)
				b1 = 8
			else if(!b2)
				b2 = 8
		for(var/obj/machinery/M in orange(src, 1))
			var/ob1
			var/ob2
			if(M:p_dir & 1)
				if(!ob1)
					ob1 = 1
				else if(!ob2)
					ob2 = 1
			if(M:p_dir & 2)
				if(!ob1)
					ob1 = 2
				else if(!ob2)
					ob2 = 2
			if(M:p_dir & 4)
				if(!ob1)
					ob1 = 4
				else if(!ob2)
					ob2 = 4
			if(M:p_dir & 8)
				if(!ob1)
					ob1 = 8
				else if(!ob2)
					ob2 = 8
			lbl1
			var/t1 = get_dir(src, M)
			var/t2 = get_dir(M, src)
			if(M:level == level && ((b1 == t1 || b2 == t1) && (ob1 == t2 || ob2 == t2)))
				if(node1)
					if(!node2)
						node2 = M
				else
					node1 = M
		update()

/obj/machinery/pipes
	var/node1
	var/node2
/obj/machinery/pipes/high_capacity
	desc = "O look this one is bigger than the others. Let's cheer... yaaaaaaaa."
	icon = 'hi_pipe.dmi'
	density = 1
	capacity = 1.8e+07
/obj/machinery/pipes/proc/explode()
	gas:turf_add(loc, -1)









/obj/machinery/pipes/receive_gas(obj/t_gas, obj/from)
	if(t_gas:tot_gas() > gas:maximum)
		gas:merge_into(t_gas)
		explode()
		return
	spawn(1)
		if(from == node1)
			spawn(0) node2:receive_gas(t_gas, src)
		else

			spawn(0) node1:receive_gas(t_gas, src)

	return
/obj/machinery/pipes/flexipipe
	desc = "This piping acts like a wire."
	icon = 'wire.dmi'
	capacity = 10
/obj/machinery/atmoalter
	var/obj/substance/gas/gas
/obj/machinery/atmoalter/siphs/var/alterable = 1
/obj/machinery/atmoalter/siphs/var/f_time = 1
/obj/machinery/atmoalter/siphs/New()
	..()
	gas = new /obj/substance/gas(src)
	gas:maximum = maximum

/obj/machinery/atmoalter/siphs
	var/location
	var/maximum = 130000000.0
/obj/machinery/pipes/flexipipe/p_dir = 12
/obj/machinery/atmoalter/siphs/proc/releaseall()
	t_status = 1
	t_per = 1000000

/obj/machinery/atmoalter/siphs/proc/reset(valve, auto)
	if(valve < 0)
		t_per = -valve
		t_status = 1
	else if(valve > 0)
		t_per = valve
		t_status = 2
	else t_status = 3
	if(auto) t_status = 4
	icon_state = "siphon:[t_status != 3 ? "1" : "0"]"


/obj/machinery/atmoalter/siphs/proc/release(amount, flag)
	var/T = loc
	if(!istype(T, /turf)) return
	if(locate(/obj/move) in T)
		T = locate(/obj/move) in T
	if(!amount) return
	if(!flag) amount = min(amount, 1000000)
	gas:turf_add(T, amount)

/obj/machinery/atmoalter/siphs/proc/siphon(amount, flag)
	var/T = loc
	if(!istype(T, /turf)) return
	if(locate(/obj/move) in T)
		T = locate(/obj/move) in T
	if(!amount) return
	if(!flag) amount = min(amount, 900000)
	gas:turf_take(T, amount)

/obj/machinery/atmoalter/siphs/fullairsiphon
	icon_state = "siphon:0"
	name = "Air siphon"
	icon = 'turfs.dmi'
/obj/machinery/atmoalter/siphs/fullairsiphon/New()
	..()
	gas:oxygen = 2.73e7
	gas:n2 = 1.027e8











/obj/machinery/atmoalter/siphs/fullairsiphon/port
	name = "Portable Siphon"
	icon = 'stationobjs.dmi'
	flags = 320
	anchored = 0
/obj/machinery/atmoalter/siphs/fullairsiphon/air_vent
	name = "Air regulator"
	icon_state = "vent"
	icon = 'aircontrol.dmi'
	density = 0
	t_status = 4; alterable = 0
/obj/machinery/atmoalter/siphs/fullairsiphon/port/reset(valve, auto)
	if(valve < 0)
		t_per = -valve
		t_status = 1
	else if(valve > 0)
		t_per = valve
		t_status = 2
	else t_status = 3
	if(auto) t_status = 4
	icon_state = "siphon:[t_status != 3 ? "1" : "0"]"



/obj/machinery/atmoalter/siphs/fullairsiphon/air_vent/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/screwdriver))
		if(c_status)
			anchored = 0
			c_status = 0
		else if(locate(/obj/machinery/connector) in loc)
			anchored = 1
			c_status = 3
	else if(istype(W, /obj/item/weapon/wrench))
		alterable = !alterable




/obj/machinery/atmoalter/siphs/fullairsiphon/air_vent/setstate()
/obj/machinery/atmoalter/siphs/fullairsiphon/air_vent/reset(valve, auto)
	if(auto) t_status = 4
/obj/machinery/atmoalter/siphs/scrubbers
	icon_state = "siphon:0"
	icon = 'turfs2.dmi'
/obj/machinery/atmoalter/siphs/scrubbers/process()
	if(t_status != 3)
		var/T = loc
		if(istype(T, /turf))
			if(locate(/obj/move) in T) T = locate(/obj/move) in T
			if(T:firelevel < 2000000)
				T:oxygen += gas:oxygen
				gas:oxygen = 0
		else T = null
		switch(t_status)
			if(1)
				if(holding)
					var/t1 = gas:tot_gas()
					var/t2 = t1
					var/t = t_per
					if(t_per > t2)
						t = t2
					holding:gas:transfer_from(gas, t)
				else if(T)
					var/t1 = gas:tot_gas()
					var/t2 = t1
					var/t = t_per
					if(t_per > t2)
						t = t2
					gas:turf_add(T, t)
			if(2)
				if(holding)
					var/t1 = gas:tot_gas()
					var/t2 = gas:maximum - t1
					var/t = t_per
					if(t_per > t2)
						t = t2
					gas:transfer_from(holding:gas, t)
				else if(T)
					var/t1 = gas:tot_gas()
					var/t2 = gas:maximum - t1
					var/t = t_per
					if(t > t2)
						t = t2
					gas:turf_take(T, t)
			if(4)
				if(T)
					if(T:firelevel > 2000000)
						f_time = world.time + 400
					else if(world.time > f_time)


						gas:extract_toxs(T)
						var/contain = gas:tot_gas()
						if(contain > 1.3e8)
							gas:turf_add(T, 1.3e8 - contain)
	if(c_status == 1)
		var/C = locate(/obj/machinery/connector) in loc
		if(C)
			var/obj/substance/gas/G = new /obj/substance/gas()
			G:transfer_from(gas, c_per)
			spawn(0) C:receive_gas(G, null)
		else c_status = 0
	for(var/mob/M in view(1, src))
		if(M:client && M:machine == src) attack_hand(M)
	setstate()



/obj/machinery/atmoalter/siphs/scrubbers/air_filter/setstate()
/obj/machinery/atmoalter/siphs/scrubbers/air_filter/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/screwdriver))
		if(c_status)
			anchored = 0
			c_status = 0
		else if(locate(/obj/machinery/connector) in loc)
			anchored = 1
			c_status = 3
	else if(istype(W, /obj/item/weapon/wrench))
		alterable = !alterable



/obj/machinery/atmoalter/siphs/scrubbers/air_filter/reset(valve, auto)
	if(auto) t_status = 4
/obj/machinery/atmoalter/siphs/scrubbers/port
	name = "Portable Siphon"
	icon_state = "scrubber:0"
	icon = 'stationobjs.dmi'
	flags = 320
	anchored = 0
/obj/machinery/atmoalter/siphs/scrubbers/port/setstate()
	if(holding) icon_state = "scrubber:T"
	else if(t_status != 3) icon_state = "scrubber:1"
	else icon_state = "scrubber:0"
/obj/machinery/atmoalter/siphs/scrubbers/port/reset(valve, auto)
	if(valve < 0)
		t_per = -valve
		t_status = 1
	else if(valve > 0)
		t_per = valve
		t_status = 2
	else t_status = 3
	if(auto) t_status = 4
	icon_state = "scrubber:[t_status != 3 ? "1" : "0"]"



















/obj/machinery/atmoalter/siphs
	var/holding
	var/t_status = 3
	var/t_per = 50
	var/c_per = 50
	var/c_status = 0
	density = 1
	weight = 1e+07
	anchored = 1
/obj/machinery/atmoalter/siphs/scrubbers/air_filter
	icon_state = "vent"
	icon = 'aircontrol.dmi'
	density = 0
	t_status = 4; alterable = 0
/obj/machinery/atmoalter/siphs/proc/setstate()
	if(holding) icon_state = "siphon:T"
	else if(t_status != 3) icon_state = "siphon:1"
	else icon_state = "siphon:0"
/obj/machinery/atmoalter/siphs/process()
	if(t_status != 3)
		var/T = loc
		if(istype(T, /turf))
			if(locate(/obj/move) in T) T = locate(/obj/move) in T
		else T = null
		switch(t_status)
			if(1)
				if(holding)
					var/t1 = gas:tot_gas()
					var/t2 = t1
					var/t = t_per
					if(t_per > t2)
						t = t2
					holding:gas:transfer_from(gas, t)
				else if(T)
					var/t1 = gas:tot_gas()
					var/t2 = t1
					var/t = t_per
					if(t_per > t2)
						t = t2
					gas:turf_add(T, t)
			if(2)
				if(holding)
					var/t1 = gas:tot_gas()
					var/t2 = gas:maximum - t1
					var/t = t_per
					if(t_per > t2)
						t = t2
					gas:transfer_from(holding:gas, t)
				else if(T)
					var/t1 = gas:tot_gas()
					var/t2 = gas:maximum - t1
					var/t = t_per
					if(t > t2)
						t = t2
					gas:turf_take(T, t)
			if(4)
				if(T)
					if(T:firelevel > 2000000)
						f_time = world.time + 300
					else if(world.time > f_time)
						var/difference = 3600000 - (T:oxygen + T:n2)
						if(difference > 0)
							var/t1 = gas:tot_gas()
							if(difference > t1)
								difference = t1
							gas:turf_add(T, difference)
	if(c_status == 1)
		var/C = locate(/obj/machinery/connector) in loc
		if(C)
			var/obj/substance/gas/G = new /obj/substance/gas()
			G:transfer_from(gas, c_per)
			spawn(0) C:receive_gas(G, null)
		else c_status = 0
	for(var/mob/M in view(1, src))
		if(M:client && M:machine == src) attack_hand(M)
	setstate()
/obj/machinery/atmoalter/siphs/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/atmoalter/siphs/attack_hand(mob/user)
	user:machine = src
	var/tt
	switch(t_status)
		if(1)
			tt = "Releasing <A href='?src=\ref[src];t=2'>Siphon</A> <A href='?src=\ref[src];t=3'>Stop</A>"
		if(2)
			tt = "<A href='?src=\ref[src];t=1'>Release</A> Siphoning <A href='?src=\ref[src];t=3'>Stop</A>"
		if(3)
			tt = "<A href='?src=\ref[src];t=1'>Release</A> <A href='?src=\ref[src];t=2'>Siphon</A> Stopped <A href='?src=\ref[src];t=4'>Automatic</A>"
		else tt = "Automatic equalizers are on!"
	var/ct
	switch(c_status)
		if(1)
			ct = "Releasing <A href='?src=\ref[src];c=2'>Accept</A> <A href='?src=\ref[src];ct=3'>Stop</A>"
		if(2)
			ct = "<A href='?src=\ref[src];c=1'>Release</A> Accepting <A href='?src=\ref[src];c=3'>Stop</A>"
		if(3)
			ct = "<A href='?src=\ref[src];c=1'>Release</A> <A href='?src=\ref[src];c=2'>Accept</A> Stopped"
		else ct = "Disconnected"
	var/at
	if(t_status == 4)
		at = "Automatic On <A href='?src=\ref[src];t=3'>Stop</A>"
	var/dat = {"<TT><B>Canister Valves</B> [!alterable ? "<B>Valves are locked. Unlock with wrench!</B>" : "You can lock this interface with a wrench."]<BR>
\t<FONT color = 'blue'><B>Contains/Capacity</B> [num2text(gas:tot_gas(), 10)] / [num2text(maximum, 10)]</FONT><BR>
\tUpper Valve Status: [t_status == 4 ? "[at]" : "[tt]"] [holding ? "<BR>(<A href='?src=\ref[src];tank=1'>Tank ([holding:gas:tot_gas()]</A>)" : null]<BR>
\t\t<A href='?src=\ref[src];tp=-[num2text(1000000, 7)]'>M</A> <A href='?src=\ref[src];tp=-10000'>-</A> <A href='?src=\ref[src];tp=-1000'>-</A> <A href='?src=\ref[src];tp=-100'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> [t_per] <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=100'>+</A> <A href='?src=\ref[src];tp=1000'>+</A> <A href='?src=\ref[src];tp=10000'>+</A> <A href='?src=\ref[src];tp=[num2text(1000000, 7)]'>M</A><BR>
\tPipe Valve Status: [ct]<BR>
\t\t<A href='?src=\ref[src];cp=-[num2text(1000000, 7)]'>M</A> <A href='?src=\ref[src];cp=-10000'>-</A> <A href='?src=\ref[src];cp=-1000'>-</A> <A href='?src=\ref[src];cp=-100'>-</A> <A href='?src=\ref[src];cp=-1'>-</A> [c_per] <A href='?src=\ref[src];cp=1'>+</A> <A href='?src=\ref[src];cp=100'>+</A> <A href='?src=\ref[src];cp=1000'>+</A> <A href='?src=\ref[src];cp=10000'>+</A> <A href='?src=\ref[src];cp=[num2text(1000000, 7)]'>M</A><BR>
<BR>

<A href='?src=\ref[user];mach_close=siphon'>Close</A><BR>
\t</TT>"}
	user << browse(dat, "window=siphon;size=600x300")



/obj/machinery/atmoalter/siphs/Topic(href, href_list)
	if(usr.stat) return
	if(!alterable) return
	if(get_dist(src, usr) <= 1 && istype(loc, /turf))
		usr.machine = src
		if(href_list["c"])
			var/c = text2num(href_list["c"])
			switch(c)
				if(1)
					c_status = 1
				if(2)
					c_status = 2
				if(3)
					c_status = 3
		else if(href_list["t"])
			var/t = text2num(href_list["t"])
			if(t_status == 0) return
			switch(t)
				if(1)
					t_status = 1
				if(2)
					t_status = 2
				if(3)
					t_status = 3
				if(4)
					t_status = 4
					f_time = 1
		else if(href_list["tp"])
			var/tp = text2num(href_list["tp"])
			t_per += tp
			t_per = min(max(round(t_per), 0), 1000000)
		else if(href_list["cp"])
			var/cp = text2num(href_list["cp"])
			c_per += cp
			c_per = min(max(round(c_per), 0), 1000000)
		else if(href_list["tank"])
			var/cp = text2num(href_list["tank"])
			if(cp == 1)
				holding:loc = loc
				holding = null
				if(t_status == 2) t_status = 3
		for(var/mob/M in view(1, src))
			if(M:client && M:machine == src) attack_hand(M)
		add_fingerprint(usr)
	else
		usr << browse(null, "window=canister")
		return
/obj/machinery/atmoalter/siphs/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/tank))
		if(holding) return
		var/T = W
		user:drop_item()
		T:loc = src
		holding = T
	else if(istype(W, /obj/item/weapon/screwdriver))
		if(c_status)
			anchored = 0
			c_status = 0
		else if(locate(/obj/machinery/connector) in loc)
			anchored = 1
			c_status = 3
	else if(istype(W, /obj/item/weapon/wrench))
		alterable = !alterable
		if(alterable)
			user << "\blue You unlock the interface!"
		else
			user << "\blue You lock the interface!"
