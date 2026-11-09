

/obj/machinery/atmoalter/heater
	var/maximum = 130000000.0
	var/t_status = 3
	icon_state = "heater1"
	var/h_status = 0
	var/t_per = 50
	var/h_tar = 20
	var/c_per = 50
	var/c_status = 0
	var/holding
	icon = 'stationobjs.dmi'
	density = 1

	anchored = 1
/obj/machinery/atmoalter/heater/proc/setstate()
	if(src.holding)
		src.icon_state = "heater1-h"
	else
		src.icon_state = "heater1"
/obj/machinery/atmoalter/heater/process()
	var/T = loc
	if(istype(T, /turf))
		if(locate(/obj/move) in T) T = locate(/obj/move) in T
	else T = null
	if(h_status)
		var/t1 = gas:tot_gas()
		if(t1 > 0 && gas:temperature < h_tar)
			var/increase = 1500000 / t1
			var/n_temp = gas:temperature + increase
			gas:temperature = min(n_temp, h_tar)
	switch(t_status)
		if(1)
			if(holding)
				var/t1 = gas:tot_gas()
				var/t2 = t1
				var/t = t_per
				if(t_per > t2)
					t = t2
				holding:gas:transfer_from(gas, t)
			else
				t_status = 3
		if(2)
			if(holding)
				var/t1 = gas:tot_gas()
				var/t2 = gas:maximum - t1
				var/t = t_per
				if(t_per > t2)
					t = t2
				gas:transfer_from(holding:gas, t)
			else
				t_status = 3
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
/obj/machinery/atmoalter/heater/New()
	..()
	gas = new /obj/substance/gas(src)
	gas:maximum = maximum
/obj/machinery/atmoalter/heater/attack_paw(mob/user)
	return attack_hand(user)
/obj/machinery/atmoalter/heater/attack_hand(mob/user)
	user:machine = src
	var/tt
	switch(t_status)
		if(1)
			tt = "Releasing <A href='?src=\ref[src];t=2'>Siphon</A> <A href='?src=\ref[src];t=3'>Stop</A>"
		if(2)
			tt = "<A href='?src=\ref[src];t=1'>Release</A> Siphoning<A href='?src=\ref[src];t=3'>Stop</A>"
		if(3)
			tt = "<A href='?src=\ref[src];t=1'>Release</A> <A href='?src=\ref[src];t=2'>Siphon</A> Stopped"
	var/ht
	if(h_status)
		ht = "Heating <A href='?src=\ref[src];h=2'>Stop</A>"
	else
		ht = "<A href='?src=\ref[src];h=1'>Heat</A> Stopped"
	var/ct
	switch(c_status)
		if(1)
			ct = "Releasing <A href='?src=\ref[src];c=2'>Accept</A> <A href='?src=\ref[src];ct=3'>Stop</A>"
		if(2)
			ct = "<A href='?src=\ref[src];c=1'>Release</A> Accepting <A href='?src=\ref[src];c=3'>Stop</A>"
		if(3)
			ct = "<A href='?src=\ref[src];c=1'>Release</A> <A href='?src=\ref[src];c=2'>Accept</A> Stopped"
		else ct = "Disconnected"
	var/dat = {"<TT><B>Canister Valves</B><BR>
<FONT color = 'blue'><B>Contains/Capacity</B> [gas:tot_gas()] / [maximum]</FONT><BR>
Upper Valve Status: [tt][holding ? "<BR><A href='?src=\ref[src];tank=1'>Tank ([holding:gas:tot_gas()]</A>)" : null]<BR>
\t<A href='?src=\ref[src];tp=-[num2text(1000000, 7)]'>M</A> <A href='?src=\ref[src];tp=-10000'>-</A> <A href='?src=\ref[src];tp=-1000'>-</A> <A href='?src=\ref[src];tp=-100'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> [t_per] <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=100'>+</A> <A href='?src=\ref[src];tp=1000'>+</A> <A href='?src=\ref[src];tp=10000'>+</A> <A href='?src=\ref[src];tp=[num2text(1000000, 7)]'>M</A><BR>
Heater Status: [ht] - [gas:tot_gas() ? gas:temperature : 20]<BR>
\tTrg Tmp: <A href='?src=\ref[src];ht=-50'>-</A> <A href='?src=\ref[src];ht=-5'>-</A> <A href='?src=\ref[src];ht=-1'>-</A> [h_tar] <A href='?src=\ref[src];ht=1'>+</A> <A href='?src=\ref[src];ht=5'>+</A> <A href='?src=\ref[src];ht=50'>+</A><BR>
<BR>
Pipe Valve Status: [ct]<BR>
\t<A href='?src=\ref[src];cp=-[num2text(1000000, 7)]'>M</A> <A href='?src=\ref[src];cp=-10000'>-</A> <A href='?src=\ref[src];cp=-1000'>-</A> <A href='?src=\ref[src];cp=-100'>-</A> <A href='?src=\ref[src];cp=-1'>-</A> [c_per] <A href='?src=\ref[src];cp=1'>+</A> <A href='?src=\ref[src];cp=100'>+</A> <A href='?src=\ref[src];cp=1000'>+</A> <A href='?src=\ref[src];cp=10000'>+</A> <A href='?src=\ref[src];cp=[num2text(1000000, 7)]'>M</A><BR>
<BR>
<A href='?src=\ref[user];mach_close=canister'>Close</A><BR>
</TT>"}
	user << browse(dat, "window=canister;size=600x300")



/obj/machinery/atmoalter/heater/Topic(href, href_list)
	if(usr.stat) return
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
		else if(href_list["h"])
			var/h = text2num(href_list["h"])
			if(h == 1) h_status = 1
			else h_status = null
		else if(href_list["tp"])
			var/tp = text2num(href_list["tp"])
			t_per += tp
			t_per = min(max(round(t_per), 0), 1000000)
		else if(href_list["cp"])
			var/cp = text2num(href_list["cp"])
			c_per += cp
			c_per = min(max(round(c_per), 0), 1000000)
		else if(href_list["ht"])
			var/cp = text2num(href_list["ht"])
			h_tar += cp
			h_tar = min(max(round(h_tar), 0), 500)
		else if(href_list["tank"])
			var/cp = text2num(href_list["tank"])
			if(cp == 1 && holding)
				holding:loc = loc
				holding = null
				if(t_status == 2) t_status = 3
		for(var/mob/M in view(1, src))
			if(M:client && M:machine == src) attack_hand(M)
		add_fingerprint(usr)
	else
		usr << browse(null, "window=canister")
		return
/obj/machinery/atmoalter/heater/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/tank))
		if(holding) return
		var/T = W
		user:drop_item()
		T:loc = src
		holding = T
	else




		if(istype(W, /obj/item/weapon/screwdriver))
			if(c_status)
				anchored = 0
				c_status = 0
			else if(locate(/obj/machinery/connector) in loc)
				anchored = 1
				c_status = 3


/obj/machinery/atmoalter/canister
	var/maximum = 130000000.0
	var/t_status = 3
	var/t_per = 50
	var/c_per = 50
	var/c_status = 0
	var/obj/item/weapon/tank/holding
	icon = 'turfs2.dmi'
	density = 1
	flags = 320
	weight = 1e+07
/obj/machinery/atmoalter/canister/proc/setstate()
/obj/machinery/atmoalter/canister/process()
	if(destroyed) return
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
			else
				t_status = 3
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
/obj/machinery/atmoalter/canister/New()
	..()
	gas = new /obj/substance/gas(src)
	gas:maximum = maximum
/obj/machinery/atmoalter/canister
	var/health = 20
	var/destroyed
/obj/machinery/atmoalter/canister/proc/setdestroystate()
/obj/machinery/atmoalter/canister/burn(fi_amount)
	health -= 1
	healthcheck()
/obj/machinery/atmoalter/canister/meteorhit(obj/O)
	health = 0
	healthcheck()
/obj/machinery/atmoalter/canister/attack_paw(mob/user)
	return attack_hand(user)
/obj/machinery/atmoalter/canister/attack_hand(mob/user)
	if(destroyed) return
	user:machine = src
	var/tt
	switch(t_status)
		if(1)
			tt = "Releasing <A href='?src=\ref[src];t=2'>Siphon (only tank)</A> <A href='?src=\ref[src];t=3'>Stop</A>"
		if(2)
			tt = "<A href='?src=\ref[src];t=1'>Release</A> Siphoning (only tank) <A href='?src=\ref[src];t=3'>Stop</A>"
		if(3)
			tt = "<A href='?src=\ref[src];t=1'>Release</A> <A href='?src=\ref[src];t=2'>Siphon (only tank)</A> Stopped"
	var/ct
	switch(c_status)
		if(1)
			ct = "Releasing <A href='?src=\ref[src];c=2'>Accept</A> <A href='?src=\ref[src];ct=3'>Stop</A>"
		if(2)
			ct = "<A href='?src=\ref[src];c=1'>Release</A> Accepting <A href='?src=\ref[src];c=3'>Stop</A>"
		if(3)
			ct = "<A href='?src=\ref[src];c=1'>Release</A> <A href='?src=\ref[src];c=2'>Accept</A> Stopped"
		else ct = "Disconnected"
	var/dat = {"<TT><B>Canister Valves</B><BR>
<FONT color = 'blue'><B>Contains/Capacity</B> [num2text(gas:tot_gas(), 20)] / [num2text(maximum, 20)]</FONT><BR>
Upper Valve Status: [tt]<BR>
\t[holding ? "<A href='?src=\ref[src];tank=1'>Tank ([holding:gas:tot_gas()]</A>)" : null]<BR>
\t<A href='?src=\ref[src];tp=-[num2text(1000000, 7)]'>M</A> <A href='?src=\ref[src];tp=-10000'>-</A> <A href='?src=\ref[src];tp=-1000'>-</A> <A href='?src=\ref[src];tp=-100'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> [t_per] <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=100'>+</A> <A href='?src=\ref[src];tp=1000'>+</A> <A href='?src=\ref[src];tp=10000'>+</A> <A href='?src=\ref[src];tp=[num2text(1000000, 7)]'>M</A><BR>
Pipe Valve Status: [ct]<BR>
\t<A href='?src=\ref[src];cp=-[num2text(1000000, 7)]'>M</A> <A href='?src=\ref[src];cp=-10000'>-</A> <A href='?src=\ref[src];cp=-1000'>-</A> <A href='?src=\ref[src];cp=-100'>-</A> <A href='?src=\ref[src];cp=-1'>-</A> [c_per] <A href='?src=\ref[src];cp=1'>+</A> <A href='?src=\ref[src];cp=100'>+</A> <A href='?src=\ref[src];cp=1000'>+</A> <A href='?src=\ref[src];cp=10000'>+</A> <A href='?src=\ref[src];cp=[num2text(1000000, 7)]'>M</A><BR>
<BR>
<A href='?src=\ref[user];mach_close=canister'>Close</A><BR>
</TT>"}
	user << browse(dat, "window=canister;size=600x300")



/obj/machinery/atmoalter/canister/Topic(href, href_list)
	if(usr.stat) return
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
					if(holding) t_status = 2
					else t_status = 3
				if(3)
					t_status = 3
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
			if(cp == 1 && holding)
				holding:loc = loc
				holding = null
				if(t_status == 2) t_status = 3
		for(var/mob/M in view(1, src))
			if(M:client && M:machine == src) attack_hand(M)
		add_fingerprint(usr)
	else
		usr << browse(null, "window=canister")
		return
/obj/machinery/atmoalter/canister/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/tank) && !destroyed)
		if(holding) return
		var/T = W
		user:drop_item()
		T:loc = src
		holding = T
	else




		if(istype(W, /obj/item/weapon/screwdriver) && !destroyed)
			if(c_status)
				anchored = 0
				c_status = 0
			else if(locate(/obj/machinery/connector) in loc)
				anchored = 1
				c_status = 3
		else
			switch(W:damtype)
				if("fire")
					health -= W:force
				if("brute")
					health -= W:force * 0.5
			healthcheck()
			..()
/obj/machinery/atmoalter/canister/las_act(flag)
	if(flag)
		var/T = loc
		if(!istype(T, /turf)) return
		else
			T:firelevel = T:poison
	else
		health = 0
		spawn(0) healthcheck()
/obj/machinery/atmoalter/canister/proc/healthcheck()
	if(health <= 10)
		var/T = loc
		if(!istype(T, /turf)) return
		gas:turf_add(T, -1)
		destroyed = 1
		density = 0
		setdestroystate()
		if(holding)
			holding:loc = loc
			holding = null
		if(t_status == 2) t_status = 3















/obj/machinery/atmoalter/canister/poisoncanister
	name = "Canister \[Plasma (Bio)\]"
	icon_state = "poisoncanister"
/obj/machinery/atmoalter/canister/poisoncanister/New()
	..()
	gas:plasma = 9e7
/obj/machinery/atmoalter/canister/poisoncanister/setdestroystate()
	icon_state = "poisoncanister-1"
/obj/machinery/atmoalter/canister/poisoncanister/setstate()
	if(src.holding) src.icon_state = "poisoncanister-T"
	else src.icon_state = "poisoncanister"


/obj/machinery/atmoalter/canister/oxygencanister
	name = "Canister: \[O2\]"
	icon_state = "oxygencanister"
/obj/machinery/atmoalter/canister/oxygencanister/New()
	..()
	gas:oxygen = 1e8
/obj/machinery/atmoalter/canister/oxygencanister/setdestroystate()
	icon_state = "oxygencanister-1"
/obj/machinery/atmoalter/canister/oxygencanister/setstate()
	if(src.holding) src.icon_state = "oxygencanister-T"
	else src.icon_state = "oxygencanister"
/obj/machinery/atmoalter/canister/anesthcanister
	name = "Canister: \[N2O\]"
	icon_state = "anesthcanister"
/obj/machinery/atmoalter/canister/anesthcanister/New()
	..()
	gas:sl_gas = 1e8
/obj/machinery/atmoalter/canister/anesthcanister/setdestroystate()
	icon_state = "anesthcanister-1"
/obj/machinery/atmoalter/canister/anesthcanister/setstate()
	if(src.holding) src.icon_state = "anesthcanister-T"
	else src.icon_state = "anesthcanister"
/obj/machinery/atmoalter/canister/n2canister
	name = "Canister: \[N2\]"
	icon_state = "anesthcanister"
/obj/machinery/atmoalter/canister/n2canister/New()
	..()
	src.gas:n2 = 1e8
/obj/machinery/atmoalter/canister/n2canister/setdestroystate()
	icon_state = "anesthcanister-1"
/obj/machinery/atmoalter/canister/n2canister/setstate()
	if(holding) icon_state = "anesthcanister-T"
	else icon_state = "anesthcanister"














/obj/machinery/computer/atmosphere
	icon = 'turfs.dmi'
	density = 1
	anchored = 1
/obj/machinery/computer/atmosphere/proc/returnarea()
/obj/machinery/computer/atmosphere/ex_act(severity)
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


/obj/machinery/computer/atmosphere/siphonswitch/returnarea()
	var/T = loc
	if(!istype(T, /turf)) return
	return T:loc:contents
























/obj/machinery/computer/atmosphere/siphonswitch
	name = "Area Air Control"
	icon_state = "switch"
/obj/machinery/computer/atmosphere/siphonswitch/verb/siphon_all()
	set src in oview(1)
	if(usr.stat) return
	usr << "Starting siphon systems."
	for(var/obj/machinery/atmoalter/siphs/S in returnarea())
		S:reset(1, 0)
	add_fingerprint(usr)
/obj/machinery/computer/atmosphere/siphonswitch/verb/stop_all()
	set src in oview(1)
	if(usr.stat) return
	usr << "Starting siphon systems."
	for(var/obj/machinery/atmoalter/siphs/S in returnarea())
		S:reset(0, 0)
	add_fingerprint(usr)
/obj/machinery/computer/atmosphere/siphonswitch/verb/auto_on()
	set src in oview(1)
	if(usr.stat) return
	usr << "Starting siphon systems."
	for(var/obj/machinery/atmoalter/siphs/S in returnarea())
		S:reset(0, 1)
	add_fingerprint(usr)
/obj/machinery/computer/atmosphere/siphonswitch/verb/release_scrubbers()
	set src in oview(1)
	if(usr.stat) return
	usr << "Starting siphon systems."
	for(var/obj/machinery/atmoalter/siphs/scrubbers/S in returnarea())
		S:reset(-1, 0)
	add_fingerprint(usr)
/obj/machinery/computer/atmosphere/siphonswitch/verb/release_all()
	if(usr.stat) return
	usr << "Starting siphon systems."
	for(var/obj/machinery/atmoalter/siphs/S in returnarea())
		S:reset(-1, 0)
	add_fingerprint(usr)

/obj/machinery/computer/atmosphere/siphonswitch/mastersiphonswitch
	name = "Master Air Control"
/obj/machinery/computer/atmosphere/siphonswitch/mastersiphonswitch/returnarea()
	return world
