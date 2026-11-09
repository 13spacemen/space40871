/obj/manifest
	icon_state = "x"
	icon = 'screen1.dmi'
/obj/manifest/New()
	invisibility = 100
/obj/manifest/proc/manifest()
	var/dat = "<B>Crew Manifest</B>:<BR>"
	for(var/mob/human/M in world)
		dat += "    <B>[M:name]</B>  -  [istype(M:wear_id, /obj/item/weapon/card/id) ? "[M:wear_id:assignment]" : "Unknown Position"]<BR>"
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(loc)
	P:info = dat
	P:name = "paper- 'Crew Manifest'"
	del(src)


/obj/screen/close/DblClick()
	if(master) master:close(usr)
/obj/screen/close
	var/obj/item/weapon/storage/master
/obj/screen/storage/attackby(W, mob/user)
	master:attackby(W, user)

/atom/proc/MouseDrop_T()
/atom/MouseDrop(over_object as mob|obj|turf|area)
	spawn(0) if(istype(over_object, /atom)) over_object:MouseDrop_T(src, usr)
	..()

/proc/text2dir(direction)
	switch(uppertext(direction))
		if("NORTH")
			return 1
		if("SOUTH")
			return 2
		if("EAST")
			return 4
		if("WEST")
			return 8
		if("NORTHEAST")
			return 5
		if("NORTHWEST")
			return 9
		if("SOUTHEAST")
			return 6
		if("SOUTHWEST")
			return 10
/proc/get_turf(turf/T)
	while(!istype(T, /turf) && T)
		T = T:loc
	return T
/proc/dir2text(direction)
	switch(direction)
		if(1)
			return "north"
		if(2)
			return "south"
		if(4)
			return "east"
		if(8)
			return "west"
		if(5)
			return "northeast"
		if(6)
			return "southeast"
		if(9)
			return "northwest"
		if(10)
			return "southwest"

/obj/proc/hear_talk(mob/M, text)
/obj/item/weapon/table_parts
	icon_state = "table_parts"
	flags = 322

/obj/item/weapon/table_parts/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		new /obj/item/weapon/sheet/metal(loc)
		del(src)
		return

/obj/item/weapon/table_parts/attack_self(mob/user)
	var/state = input(user, "What type of table?", "Assembling Table") in list("sides", "corners", "alone")
	var/direct = SOUTH
	if(state == "corners")
		direct = input(user, "Direction?", "Assembling Table") in list("northwest", "northeast", "southwest", "southeast")
	else if(state == "sides")
		direct = input(user, "Direction?", "Assembling Table") in list("north", "east", "south", "west")
	var/T = new /obj/table(user:loc)
	T:icon_state = state
	T:dir = text2dir(direct)
	T:add_fingerprint(user)
	del(src)
/obj/item/weapon/rack_parts
	icon_state = "rack_parts"
	flags = 322
/obj/item/weapon/rack_parts/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		new /obj/item/weapon/sheet/metal(loc)
		del(src)
		return
/obj/item/weapon/rack_parts/attack_self(mob/user)
	var/R = new /obj/rack(user:loc)
	R:add_fingerprint(user)
	del(src)
/obj/bedsheetbin
	name = "Linen Bin"
	icon_state = "bedbin"
	icon = 'Icons.dmi'
	anchored = 1
	var/amount = 23
/obj/bedsheetbin/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/bedsheet))
		del(W)
		amount++
/obj/bedsheetbin/attack_paw(mob/user)
	return attack_hand(user)
/obj/bedsheetbin/attack_hand(mob/user)
	if(amount >= 1)
		amount--
		new /obj/item/weapon/bedsheet(loc)
		add_fingerprint(user)
/obj/bedsheetbin/examine()
	set src in oview(1)
	amount = round(amount)
	if(amount <= 0)
		amount = 0
		usr << "There are no bed sheets in the bin."
	else if(amount == 1)
		usr << "There is one bed sheet in the bin."
	else
		usr << "There are [amount] bed sheets in the bin."
/obj/item/weapon/paper_bin
	icon = 'stationobjs.dmi'
	name = "Paper Bin"
	icon_state = "paper_bin1"
	s_istate = "sheet-metal"
	w_class = 5
	var/amount = 30
/obj/item/weapon/paper_bin/proc/update()
	icon_state = "paper_bin[amount || (locate(/obj/item/weapon/paper) in src) ? "1" : null]"
/obj/item/weapon/paper_bin/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/paper))
		user:drop_item()
		W:loc = src
	else if(istype(W, /obj/item/weapon/weldingtool))
		var/T = W
		if(T:welding && T:weldfuel > 0)
			view(user) << "[user] burns the paper with the welding tool!"
			spawn(0) burn(4000000)
	else if(istype(W, /obj/item/weapon/igniter))
		view(user) << "[user] burns the paper with the igniter!"
		spawn(0) burn(4000000)
	update()
/obj/item/weapon/paper_bin/burn(fi_amount)
	flick("paper_binb", src)
	for(var/atom/movable/A in src)
		A:burn(fi_amount)
	if(fi_amount >= 2000000)
		amount = 0
	update()
/obj/item/weapon/paper_bin/MouseDrop(mob/user)
	if(user == usr && (!usr.restrained() && (!usr.stat && (usr.contents:Find(src) || get_dist(src, usr) <= 1))))
		spawn(0) attack_hand(usr, usr.hand, 1)
/obj/item/weapon/paper_bin/attack_paw(mob/user)
	return attack_hand(user)
/obj/item/weapon/paper_bin/attack_hand(mob/user, unused, flag)
	if(flag) return ..()
	add_fingerprint(user)
	if(locate(/obj/item/weapon/paper) in src)
		for(var/obj/item/weapon/paper/P in src)
			if(usr.hand && !usr.l_hand)
				usr.l_hand = P
				P:loc = usr
				P:layer = 20
				P = null
				usr.UpdateClothing()
			else if(!usr.r_hand)
				usr.r_hand = P
				P:loc = usr
				P:layer = 20
				P = null
				usr.UpdateClothing()
			break
	else if(amount >= 1)
		amount--
		new /obj/item/weapon/paper(loc)
	update()
/obj/item/weapon/paper_bin/examine()
	set src in oview(1)
	amount = round(amount)
	var/n = amount
	for(var/obj/item/weapon/paper/P in src)
		n++
	if(n <= 0)
		n = 0
		usr << "There are no papers in the bin."
	else if(n == 1)
		usr << "There is one paper in the bin."
	else
		usr << "There are [n] papers in the bin."
/obj/screen/storage
	var/master
/obj/table/icon_state = "alone"
/obj/table/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			if(prob(50)) del(src)
		if(3)
			if(prob(25))
				icon_state = "Table2broken"
				density = 0


/obj/table/attack_paw(mob/user)
	if(!(locate(/obj/table) in user:loc))
		step(user, get_dir(user, src))
		if(user:loc == loc)
			user:layer = TURF_LAYER
			for(var/mob/M in view(user))
				if(!M:blinded)
					M << "The monkey hides under the table!"
/obj/table/CheckPass(O as mob|obj, turf/target)
	if(O:flags & 2 || istype(O, /obj/meteor)) return 1
	else return 0
/obj/table/MouseDrop_T(obj/O, mob/user)
	if(!istype(O, /obj/item/weapon) || user:equipped() != O) return
	user:drop_item()
	if(O:loc != loc) step(O, get_dir(O, src))
/obj/table/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench))

		new /obj/item/weapon/table_parts(loc)
		del(src)
		return
	user:drop_item()
	if(W:loc != loc) step(W, get_dir(W, src))


/obj/table
	icon = 'table.dmi'
	density = 1
	anchored = 1






/obj/rack/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			if(prob(50)) del(src)
		if(3)
			if(prob(25))
				icon_state = "rackbroken"
				density = 0




/obj/rack/CheckPass(O as mob|obj, turf/target)
	if(O:flags & 2) return 1
	else return 0
/obj/rack/MouseDrop_T(obj/O, mob/user)
	if(!istype(O, /obj/item/weapon) || user:equipped() != O) return
	user:drop_item()
	if(O:loc != loc) step(O, get_dir(O, src))
/obj/rack/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench))

		new /obj/item/weapon/rack_parts(loc)
		del(src)
		return
	user:drop_item()
	if(W:loc != loc) step(W, get_dir(W, src))
/obj/rack
	icon_state = "rack"
	icon = 'Icons.dmi'
	density = 1
	flags = 320
	anchored = 1
/obj/rack/meteorhit(obj/O)
	if(O:icon_state == "flaming")
		icon_state = "rackbroken"
		density = 0

/mob/attackby(obj/W, mob/user)
	var/shielded = 0
	for(var/obj/item/weapon/shield/S in src)
		if(S:active)
			shielded = 1
			break
	if(locate(/obj/item/weapon/grab) in src)
		var/safe
		if(istype(l_hand, /obj/item/weapon/grab))
			var/G = l_hand
			if(G:state == 3 && get_dir(src, user) == dir)
				safe = G:affecting
		if(istype(r_hand, /obj/item/weapon/grab))
			var/G = r_hand
			if(G:state == 3 && get_dir(src, user) == dir)
				safe = G:affecting
		if(safe)
			return safe:attackby(W, user)
	if(!shielded || !W:flags & 32)
		spawn(0)
			W:attack(src, user)

/atom/proc/attack_hand(mob/user)
/atom/proc/attack_paw(mob/user)
/atom/proc/hand_h(mob/user)
/atom/proc/hand_p(mob/user)
/atom/proc/attack_to(mob/attacker, target as mob|obj|turf|area)
	return 1
/atom/proc/attack_from(mob/attacker, target as mob|obj|turf|area)
	return 1
/atom/proc/hitby(obj/W)
/atom/movable/layer = 3
/atom/proc/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/f_print_scanner))
		for(var/mob/O in view(src))
			if(O:client && !O:blinded)
				O << "\red[src] has been scanned by [user] with the [W]"
	else if(!istype(W, /obj/item/weapon/grab))
		for(var/mob/O in view(src))
			if(O:client && !O:blinded)
				O << "\red<B>[src] has been hit by [user] with [W]</B>"
/atom/DblClick()
	..()
	var/obj/item/weapon/W = usr.equipped()
	if(W == src && usr.stat == 0)
		spawn(0) W:attack_self(usr)
		return
	if(!usr.canmove || usr.stat != 0) return
	if(!usr.contents:Find(src) && ((!isturf(src) && (!isturf(loc) && (loc && !isturf(loc:loc))) || !isturf(usr.loc)) && (loc != usr.loc && (!istype(src, /obj/screen) && !usr.contents:Find(loc))))) return
	var/t5 = get_dist(src, usr) <= 1 || loc == usr
	if((t5 || W && W:flags & 16) && !istype(src, /obj/screen))










		if(usr.next_move < world.time)
			usr.next_move = world.time + 10
		else return

		if(loc)
			for(var/atom/A in usr.loc)
				if(!A:attack_from(usr, loc))
					usr << "\red[A] blocked your attack!"
					return 0
			var/L
			if(istype(src, /turf))
				L = contents
			else L = loc:contents
			for(var/atom/A in L - src)
				if(!A:attack_to(usr, loc))
					usr << "\red[A] blocked your attack!"
					return 0

		if(!usr.restrained())
			if(W)
				if(t5)
					attackby(W, usr)
				if(W)
					W:afterattack(src, usr, t5 ? 1 : 0)
			else if(istype(usr, /mob/human))
				attack_hand(usr, usr.hand)
			else if(istype(usr, /mob/monkey))
				attack_paw(usr, usr.hand)
		else
			if(istype(usr, /mob/human))
				hand_h(usr, usr.hand)
			else if(istype(usr, /mob/monkey))
				hand_p(usr, usr.hand)
	else if(istype(src, /obj/screen))
		if(usr.next_move < world.time)
			usr.next_move = world.time + 10
		else
			return
		if(!usr.restrained())
			if(W && !istype(src, /obj/screen))
				attackby(W, usr)
				if(W)
					W:afterattack(src, usr)
			else if(istype(usr, /mob/human))
				attack_hand(usr, usr.hand)
			else if(istype(usr, /mob/monkey))
				attack_paw(usr, usr.hand)
		else
			if(istype(usr, /mob/human))
				hand_h(usr, usr.hand)
			else if(istype(usr, /mob/monkey))
				hand_p(usr, usr.hand)


/obj/weldfueltank
	icon_state = "weldtank"
	icon = 'items.dmi'
	density = 1
	flags = 320
	weight = 5e+06
/obj/weldfueltank/attackby(obj/W, mob/user)
	if(!istype(W, /obj/item/weapon/weldingtool)) return
	W:weldfuel = 20
	W:suffix = "[W == src ? "equipped " : ""][W:weldfuel]"
	user << "\blue Welder refueled"
/obj/weldfueltank/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			if(prob(50)) del(src)
		if(3)
			if(prob(5)) del(src)
/obj/watertank
	icon_state = "watertank"
	icon = 'stationobjs.dmi'
	density = 1
	flags = 320
	weight = 5e+06
/obj/watertank/attackby(obj/W, mob/user)
	if(!istype(W, /obj/item/weapon/extinguisher)) return
	W:waterleft = 20
	W:suffix = "[user:equipped() == src ? "equipped " : ""][W:waterleft]"
	user << "\blue Extinguisher refueled"
/obj/watertank/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			if(prob(50)) del(src)
		if(3)
			if(prob(5)) del(src)
/obj/d_girders
	icon_state = "d_girders"
	name = "Displaced girders"
	icon = 'stationobjs.dmi'
	density = 1
	anchored = 0
	weight = 1e+08
/obj/d_girders/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/sheet/metal))
		if(W:amount < 1)
			del(W)
			return
		new /obj/machinery/door/false_wall(loc)
		W:amount--
		if(W:amount < 1) del(W)
		user << "\blue Keep in mind when you open it that it MAY be difficult to sldie at first so keep trying."
		del(src)
	else if(istype(W, /obj/item/weapon/screwdriver))
		new /obj/item/weapon/sheet/metal(loc)
		del(src)

/obj/machinery/recharger
	icon_state = "recharger0"
	var/charging
	icon = 'stationobjs.dmi'
	anchored = 1
/obj/machinery/recharger/process()
	if(charging)
		if(charging:charges < 25)
			charging:charges++
			icon_state = "recharger1"
		else
			icon_state = "recharger2"
	else
		icon_state = "recharger0"
/obj/machinery/recharger/attack_paw(mob/user)
	if(ticker && ticker:mode == "monkey")
		return attack_hand(user)
/obj/machinery/recharger/attack_hand(mob/user)
	add_fingerprint(user)
	if(charging)
		charging:loc = loc
		charging = null
/obj/machinery/recharger/attackby(obj/G, mob/user)
	if(istype(G, /obj/item/weapon/gun))
		user:drop_item()
		G:loc = src
		charging = G
		return
/obj/barrier
	icon_state = "barrier"
	icon = 'stationobjs.dmi'
	opacity = 1
	density = 1
	anchored = 1

/obj/barrier/New()
	var/t = 1800
	if(ctf)
		t = round(ctf:barriertime * 600)
	spawn(t)
		del(src)
/obj/portal
	icon_state = "portal"

/obj/portal/Bumped(M as mob|obj)
	spawn(0)
		teleport(M)
/obj/portal/HasEntered(AM as mob|obj)
	spawn(0) teleport(AM)
/obj/portal/New()
	spawn(300)
		del(src)



/obj/portal/proc/teleport(M as mob|obj)
	if(M:anchored) return
	if(icon_state == "portal1") return
	if(!target)
		del(src)
	var/obj/effects/sparks/O = new /obj/effects/sparks(target)
	O:dir = pick(1, 2, 4, 8)
	spawn(0) O:Life()
	if(istype(M, /atom/movable))
		var/tx = target:x + rand(-5, 5)
		var/ty = target:y + rand(-5, 5)
		if(prob(10))
			icon_state = "portal1"
			if(ismob(M))
				M:ex_act(2)
			else
				M:ex_act(1)
		M:loc = locate(tx, ty, target:z)

/obj/portal
	var/obj/target
	icon = 'stationobjs.dmi'
	density = 1
	anchored = 1
/obj/effects/water/New()
	..()
	var/T = loc
	if(istype(T, /turf)) T:firelevel = 0
	spawn(70)
		del(src)
/obj/effects/water/Del()
	var/T = loc
	if(istype(T, /turf)) T:firelevel = 0
	..()
/obj/effects/water/Move()
	..()
	var/T = loc
	if(istype(T, /turf)) T:firelevel = 0
	if(--life < 1) del(src)



/atom/proc/add_fingerprint(mob/M)
	if(!istype(M, /mob/human) || !istype(M:primary, /obj/dna))
		return 0
	if(!flags & 256) return
	if(M:gloves)
		return 0
	if(!fingerprints)
		fingerprints = "[md5(M:primary:uni_identity)]"
	else
		var/L = params2list(fingerprints)
		L -= md5(M:primary:uni_identity)
		while(L:len >= 3)
			L -= L[1]
		L += md5(M:primary:uni_identity)
		fingerprints = list2params(L)
/obj/item
	var/w_class = 3
/obj/item/weapon/game_kit
	s_istate = "sheet-metal"
	name = "Gaming Kit"
	icon_state = "game_kit"
	var/selected
	var/board_stat
	w_class = 5
	var/data = ""
/obj/effects/water
	icon_state = "extinguish"
	var/life = 15
	icon = 'water.dmi'
	flags = 2




/obj/item/weapon/game_kit/New()
	board_stat = "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"
	selected = "CR"
/obj/item/weapon/game_kit/attack_paw(mob/user)
	return attack_hand(user)
/obj/item/weapon/game_kit/MouseDrop(mob/user)
	if(user == usr && (!usr.restrained() && (!usr.stat && (usr.contents:Find(src) || get_dist(src, usr) <= 1))))
		spawn(0) attack_hand(usr, usr.hand, 1)
/obj/item/weapon/game_kit
	var/internet = 1
/obj/item/weapon/game_kit/proc/update()
	if(!internet)
		var/dat = "<CENTER><B>Game Board</B></CENTER><BR><a href='?src=\
\ref[src];mode=hia'>[selected ? "Selected: [selected]" : "Nothing Selected"]</a> <a href='?src=\ref[src];mode=remove'>remove</a><HR><table width= 256  border= 0  height= 256  cellspacing= 0  cellpadding= 0 >"
		for(var/counter = 1, counter <= 8, counter++)
			dat += {"<tr>
\t<td><a href='?src=\ref[src];s_board=1 [counter]'><img src='board_[copytext(board_stat, ((counter - 1) * 8 + 1) * 2 - 1, ((counter - 1) * 8 + 1) * 2 + 1)][(counter + 1) % 2 ? "W" : "B"].png' width= 32 height= 32 ></td>
\t<td><a href='?src=\ref[src];s_board=2 [counter]'><img src='board_[copytext(board_stat, ((counter - 1) * 8 + 2) * 2 - 1, ((counter - 1) * 8 + 2) * 2 + 1)][(counter + 2) % 2 ? "W" : "B"].png' width= 32 height= 32 ></td>
\t<td><a href='?src=\ref[src];s_board=3 [counter]'><img src='board_[copytext(board_stat, ((counter - 1) * 8 + 3) * 2 - 1, ((counter - 1) * 8 + 3) * 2 + 1)][(counter + 3) % 2 ? "W" : "B"].png' width= 32 height= 32 ></td>
\t<td><a href='?src=\ref[src];s_board=4 [counter]'><img src='board_[copytext(board_stat, ((counter - 1) * 8 + 4) * 2 - 1, ((counter - 1) * 8 + 4) * 2 + 1)][(counter + 4) % 2 ? "W" : "B"].png' width= 32 height= 32 ></td>
\t<td><a href='?src=\ref[src];s_board=5 [counter]'><img src='board_[copytext(board_stat, ((counter - 1) * 8 + 5) * 2 - 1, ((counter - 1) * 8 + 5) * 2 + 1)][(counter + 5) % 2 ? "W" : "B"].png' width= 32 height= 32 ></td>
\t<td><a href='?src=\ref[src];s_board=6 [counter]'><img src='board_[copytext(board_stat, ((counter - 1) * 8 + 6) * 2 - 1, ((counter - 1) * 8 + 6) * 2 + 1)][(counter + 6) % 2 ? "W" : "B"].png' width= 32 height= 32 ></td>
\t<td><a href='?src=\ref[src];s_board=7 [counter]'><img src='board_[copytext(board_stat, ((counter - 1) * 8 + 7) * 2 - 1, ((counter - 1) * 8 + 7) * 2 + 1)][(counter + 7) % 2 ? "W" : "B"].png' width= 32 height= 32 ></td>
\t<td><a href='?src=\ref[src];s_board=8 [counter]'><img src='board_[copytext(board_stat, ((counter - 1) * 8 + 8) * 2 - 1, ((counter - 1) * 8 + 8) * 2 + 1)][(counter + 8) % 2 ? "W" : "B"].png' width= 32 height= 32 ></td>
\t</tr>"}
		dat += "</table><HR><B>Chips:</B> "
		dat += "<a href='?src=\ref[src];s_piece=CB'><img src='board_CB.png' width= 32 height= 32 ></A>"
		dat += "<a href='?src=\ref[src];s_piece=CR'><img src='board_CR.png' width= 32 height= 32 ></A>"
		dat += "<HR><B>Chess pieces:</B><BR>"
		dat += "<a href='?src=\ref[src];s_piece=WP'><img src='board_WP.png'></A>"
		dat += "<a href='?src=\ref[src];s_piece=WK'><img src='board_WK.png'></A>"
		dat += "<a href='?src=\ref[src];s_piece=WQ'><img src='board_WQ.png'></A>"
		dat += "<a href='?src=\ref[src];s_piece=WI'><img src='board_WI.png'></A>"
		dat += "<a href='?src=\ref[src];s_piece=WN'><img src='board_WN.png'></A>"
		dat += "<a href='?src=\ref[src];s_piece=WR'><img src='board_WR.png'></A><BR>"
		dat += "<a href='?src=\ref[src];s_piece=BP'><img src='board_BP.png'></A>"
		dat += "<a href='?src=\ref[src];s_piece=BK'><img src='board_BK.png'></A>"
		dat += "<a href='?src=\ref[src];s_piece=BQ'><img src='board_BQ.png'></A>"
		dat += "<a href='?src=\ref[src];s_piece=BI'><img src='board_BI.png'></A>"
		dat += "<a href='?src=\ref[src];s_piece=BN'><img src='board_BN.png'></A>"
		dat += "<a href='?src=\ref[src];s_piece=BR'><img src='board_BR.png'></A><HR>"
		dat += "<a href='?src=\ref[src];sw_pic=1'>Using cache for pictures</A>"
		data = dat
	else
		var/dat = "<CENTER><B>Game Board</B></CENTER><BR><a href='?src=\
\ref[src];mode=hia'>[selected ? "Selected: [selected]" : "Nothing Selected"]</a> <a href='?src=\ref[src];mode=remove'>remove</a><HR><table width= 256  border= 0  height= 256  cellspacing= 0  cellpadding= 0 >"
		for(var/counter = 1, counter <= 8, counter++)
			dat += {"<tr>
\t<td><a href='?src=\ref[src];s_board=1 [counter]'><img src='http://www.jozefboer.nl/ss13/cache/board_[copytext(board_stat, ((counter - 1) * 8 + 1) * 2 - 1, ((counter - 1) * 8 + 1) * 2 + 1)][(counter + 1) % 2 ? "W" : "B"].png' width= 32 height= 32 ></td>
\t<td><a href='?src=\ref[src];s_board=2 [counter]'><img src='http://www.jozefboer.nl/ss13/cache/board_[copytext(board_stat, ((counter - 1) * 8 + 2) * 2 - 1, ((counter - 1) * 8 + 2) * 2 + 1)][(counter + 2) % 2 ? "W" : "B"].png' width= 32 height= 32 ></td>
\t<td><a href='?src=\ref[src];s_board=3 [counter]'><img src='http://www.jozefboer.nl/ss13/cache/board_[copytext(board_stat, ((counter - 1) * 8 + 3) * 2 - 1, ((counter - 1) * 8 + 3) * 2 + 1)][(counter + 3) % 2 ? "W" : "B"].png' width= 32 height= 32 ></td>
\t<td><a href='?src=\ref[src];s_board=4 [counter]'><img src='http://www.jozefboer.nl/ss13/cache/board_[copytext(board_stat, ((counter - 1) * 8 + 4) * 2 - 1, ((counter - 1) * 8 + 4) * 2 + 1)][(counter + 4) % 2 ? "W" : "B"].png' width= 32 height= 32 ></td>
\t<td><a href='?src=\ref[src];s_board=5 [counter]'><img src='http://www.jozefboer.nl/ss13/cache/board_[copytext(board_stat, ((counter - 1) * 8 + 5) * 2 - 1, ((counter - 1) * 8 + 5) * 2 + 1)][(counter + 5) % 2 ? "W" : "B"].png' width= 32 height= 32 ></td>
\t<td><a href='?src=\ref[src];s_board=6 [counter]'><img src='http://www.jozefboer.nl/ss13/cache/board_[copytext(board_stat, ((counter - 1) * 8 + 6) * 2 - 1, ((counter - 1) * 8 + 6) * 2 + 1)][(counter + 6) % 2 ? "W" : "B"].png' width= 32 height= 32 ></td>
\t<td><a href='?src=\ref[src];s_board=7 [counter]'><img src='http://www.jozefboer.nl/ss13/cache/board_[copytext(board_stat, ((counter - 1) * 8 + 7) * 2 - 1, ((counter - 1) * 8 + 7) * 2 + 1)][(counter + 7) % 2 ? "W" : "B"].png' width= 32 height= 32 ></td>
\t<td><a href='?src=\ref[src];s_board=8 [counter]'><img src='http://www.jozefboer.nl/ss13/cache/board_[copytext(board_stat, ((counter - 1) * 8 + 8) * 2 - 1, ((counter - 1) * 8 + 8) * 2 + 1)][(counter + 8) % 2 ? "W" : "B"].png' width= 32 height= 32 ></td>
\t</tr>"}
		dat += "</table><HR><B>Chips:</B> "
		dat += "<a href='?src=\ref[src];s_piece=CB'><img src='http://www.jozefboer.nl/ss13/cache/board_CB.png' width= 32 height= 32 ></A>"
		dat += "<a href='?src=\ref[src];s_piece=CR'><img src='http://www.jozefboer.nl/ss13/cache/board_CR.png' width= 32 height= 32 ></A>"
		dat += "<HR><B>Chess pieces:</B><BR>"
		dat += "<a href='?src=\ref[src];s_piece=WP'><img src='http://www.jozefboer.nl/ss13/cache/board_WP.png'></A>"
		dat += "<a href='?src=\ref[src];s_piece=WK'><img src='http://www.jozefboer.nl/ss13/cache/board_WK.png'></A>"
		dat += "<a href='?src=\ref[src];s_piece=WQ'><img src='http://www.jozefboer.nl/ss13/cache/board_WQ.png'></A>"
		dat += "<a href='?src=\ref[src];s_piece=WI'><img src='http://www.jozefboer.nl/ss13/cache/board_WI.png'></A>"
		dat += "<a href='?src=\ref[src];s_piece=WN'><img src='http://www.jozefboer.nl/ss13/cache/board_WN.png'></A>"
		dat += "<a href='?src=\ref[src];s_piece=WR'><img src='http://www.jozefboer.nl/ss13/cache/board_WR.png'></A><BR>"
		dat += "<a href='?src=\ref[src];s_piece=BP'><img src='http://www.jozefboer.nl/ss13/cache/board_BP.png'></A>"
		dat += "<a href='?src=\ref[src];s_piece=BK'><img src='http://www.jozefboer.nl/ss13/cache/board_BK.png'></A>"
		dat += "<a href='?src=\ref[src];s_piece=BQ'><img src='http://www.jozefboer.nl/ss13/cache/board_BQ.png'></A>"
		dat += "<a href='?src=\ref[src];s_piece=BI'><img src='http://www.jozefboer.nl/ss13/cache/board_BI.png'></A>"
		dat += "<a href='?src=\ref[src];s_piece=BN'><img src='http://www.jozefboer.nl/ss13/cache/board_BN.png'></A>"
		dat += "<a href='?src=\ref[src];s_piece=BR'><img src='http://www.jozefboer.nl/ss13/cache/board_BR.png'></A><HR>"
		dat += "<a href='?src=\ref[src];sw_pic=1'>Using Internet for pictures</A>"
		data = dat

/obj/item/weapon/game_kit/attack_hand(mob/user, unused, flag)
	if(flag) return ..()
	else
		user:machine = src
		if(!data) update()
		user << browse(data, "window=game_kit")
		return
/obj/item/weapon/game_kit/Topic(href, href_list)
	if(usr.stat || usr.restrained()) return
	if(usr.contents:Find(src) || get_dist(src, usr) <= 1 && istype(loc, /turf))
		if(href_list["s_piece"])
			selected = href_list["s_piece"]
		else if(href_list["mode"])
			if(href_list["mode"] == "remove")
				selected = "remove"
			else selected = null
		else if(href_list["sw_pic"])
			internet = !internet
		else if(href_list["s_board"])
			if(!selected)
				selected = href_list["s_board"]
			else
				var/tx
				var/ty
				tx = text2num(copytext(href_list["s_board"], 1, 2))
				ty = text2num(copytext(href_list["s_board"], 3, 4))
				if(copytext(selected, 2, 3) == " " && length(selected) == 3)
					var/sx = text2num(copytext(selected, 1, 2))
					var/sy = text2num(copytext(selected, 3, 4))
					var/place = ((sy - 1) * 8 + sx) * 2 - 1
					selected = copytext(board_stat, place, place + 2)
					if(place == 1)
						board_stat = "BB[copytext(board_stat, 3, 129)]"
					else if(place == 127)
						board_stat = "[copytext(board_stat, 1, 127)]BB"
					else if(place)
						board_stat = "[copytext(board_stat, 1, place)]BB[copytext(board_stat, place + 2, 129)]"
					place = ((ty - 1) * 8 + tx) * 2 - 1
					if(place == 1)
						board_stat = "[selected][copytext(board_stat, 3, 129)]"
					else if(place == 127)
						board_stat = "[copytext(board_stat, 1, 127)][selected]"
					else if(place)
						board_stat = "[copytext(board_stat, 1, place)][selected][copytext(board_stat, place + 2, 129)]"
					selected = null
				else if(selected == "remove")
					var/place = ((ty - 1) * 8 + tx) * 2 - 1
					if(place == 1)
						board_stat = "BB[copytext(board_stat, 3, 129)]"
					else if(place == 127)
						board_stat = "[copytext(board_stat, 1, 127)]BB"
					else if(place)
						board_stat = "[copytext(board_stat, 1, place)]BB[copytext(board_stat, place + 2, 129)]"
				else if(length(selected) == 2)
					var/place = ((ty - 1) * 8 + tx) * 2 - 1
					if(place == 1)
						board_stat = "[selected][copytext(board_stat, 3, 129)]"
					else if(place == 127)
						board_stat = "[copytext(board_stat, 1, 127)][selected]"
					else if(place)
						board_stat = "[copytext(board_stat, 1, place)][selected][copytext(board_stat, place + 2, 129)]"

		add_fingerprint(usr)
		update()
		for(var/mob/M in view(1, src))
			if(M:client && M:machine == src) attack_hand(M)
/obj/item/weapon/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			if(prob(50)) del(src)
		if(3)
			if(prob(5)) del(src)





/obj/item/weapon
	var/force
	var/s_istate
	var/damtype = "brute"
	var/throwforce
	var/r_speed = 1
/obj/item/weapon/proc/attack_self()
/obj/item/weapon/proc/talk_into(mob/M, text)
/obj/item/weapon/bedsheet/layer = 4


/obj/item/weapon/bedsheet/ex_act(severity)
	if(severity <= 2) del(src)
/obj/item/weapon/wrapping_paper
	icon_state = "wrap_paper"
	name = "Wrapping paper"; var/amount = 20
/obj/item/weapon/bedsheet/attack_self(mob/user)
	user:drop_item()
	layer = 5
	add_fingerprint(user)
/obj/item/weapon/bedsheet/burn(fi_amount)
	if(fi_amount > 3e7)
		spawn(0)
			var/t = icon_state
			icon_state = ""
			icon = 'b_items.dmi'
			flick("[t]", src)
			spawn(14)
				del(src)
/obj/item/weapon/bedsheet
	icon_state = "sheet"
	icon = 'Icons.dmi'

/obj/item/weapon/wrapping_paper/examine()
	..()
	usr << "There is about [amount] square units of paper left!"
/obj/item/weapon/wrapping_paper/attackby(obj/W, mob/user)
	if(!(locate(/obj/table) in loc))
		user << "\blue You MUST put the paper on a table!"
	if(W:w_class < 4)
		if(istype(user:l_hand, /obj/item/weapon/wirecutters) || istype(user:r_hand, /obj/item/weapon/wirecutters))
			var/a_used = 2 ** (w_class - 1)
			if(amount < a_used)
				user << "\blue You need more paper!"
				return
			else
				amount -= a_used
				user:drop_item()
				var/G = new /obj/item/weapon/gift(loc)
				G:size = W:w_class
				G:w_class = G:size + 1
				G:icon_state = "gift[G:size]"
				G:gift = W
				W:loc = G
				G:add_fingerprint(user)
				W:add_fingerprint(user)
				add_fingerprint(user)
			if(amount <= 0)
				new /obj/item/weapon/c_tube(loc)
				del(src)
		else
			user << "\blue You need scissors!"
	else
		user << "\blue The object is FAR too large!"
/obj/item/weapon/c_tube
	icon_state = "c_tube"
	name = "Cardboard tube"
/obj/item/weapon/gift
	var/size = 3
	icon_state = "gift3"
	s_istate = "gift"
	var/gift
	w_class = 4
/obj/item/weapon/gift/attack_self(mob/user)
	gift:loc = user
	if(user:hand)
		user:l_hand = gift
	else
		user:r_hand = gift
	gift:layer = 20
	gift:add_fingerprint(user)
	del(src)
/obj/item/weapon/a_gift
	name = "Gift"
/obj/item/weapon/bedsheet/s_istate = "w_suit"
/obj/item/weapon/a_gift/ex_act()
	del(src)
/obj/item/weapon/a_gift/burn(fi_amount)
	if(fi_amount > 2000000) del(src)


/obj/item/weapon/a_gift/attack_self(mob/M)
	switch(pick("pill", "flash", "t_gun", "l_gun", "shield", "sword"))
		if("pill")
			var/W = new /obj/item/weapon/m_pill/superpill(M)
			if(M:hand)
				M:l_hand = W
			else
				M:r_hand = W
			W:layer = 20
			W:add_fingerprint(M)
			del(src)
		if("flash")
			var/W = new /obj/item/weapon/flash(M)
			if(M:hand)
				M:l_hand = W
			else
				M:r_hand = W
			W:layer = 20
			W:add_fingerprint(M)
			del(src)
		if("l_gun")
			var/W = new /obj/item/weapon/gun/laser_gun(M)
			if(M:hand)
				M:l_hand = W
			else
				M:r_hand = W
			W:layer = 20
			W:add_fingerprint(M)
			del(src)
		if("t_gun")
			var/W = new /obj/item/weapon/gun/taser_gun(M)
			if(M:hand)
				M:l_hand = W
			else
				M:r_hand = W
			W:layer = 20
			W:add_fingerprint(M)
			del(src)
		if("shield")
			var/W = new /obj/item/weapon/shield(M)
			if(M:hand)
				M:l_hand = W
			else
				M:r_hand = W
			W:layer = 20
			W:add_fingerprint(M)
			del(src)
		if("sword")
			var/W = new /obj/item/weapon/sword(M)
			if(M:hand)
				M:l_hand = W
			else
				M:r_hand = W
			W:layer = 20
			W:add_fingerprint(M)
			del(src)
/obj/item/weapon/a_gift
	icon_state = "gift"
	s_istate = "gift"
	weight = 1e+07
/obj/item/weapon/flashbang
	icon_state = "flashbang"
	var/state
	var/det_time = 30; desc = "It is set to detonate in 3 seconds."

/obj/item/weapon/flashbang/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/screwdriver))
		if(det_time == 30)
			det_time = 30
			user:show_message("\blue You set the flashbang for 3 second detonation time.")
			desc = "It is set to detonate in 3 seconds."
		else
			det_time = 100
			user:show_message("\blue You set the flashbang for 10 second detonation time.")
			desc = "It is set to detonate in 10 seconds."
		add_fingerprint(user)
/obj/item/weapon/flashbang/afterattack(target as mob|obj|turf|area, mob/user)
	if(user:equipped() == src)
		if(!state)
			user << "\red You prime the flashbang! 10 seconds!"
			state = 1
			icon_state = "flashbang1"
			spawn(det_time)
				prime()
		user:dir = get_dir(user, target)
		user:drop_item()
		var/t = isturf(target) ? target : target:loc
		walk_towards(src, t, 3)
		add_fingerprint(user)
/obj/item/weapon/flashbang/attack_paw(mob/user)
	return attack_hand(user)
/obj/item/weapon/flashbang/attack_hand()
	walk(src, null)
	throwspeed = 20
	..()
/obj/item/weapon/flashbang/proc/prime()
	var/T = get_turf(src)
	T:firelevel = T:poison
	for(var/mob/M in view(T))
		if(get_dist(M, T) <= 2 || (loc == M:loc || loc == M))
			flick("e_flash", M:flash)
			M:stunned = 10
			M:weakened = 3
			M << "\red<B>BANG</B>"
			if(prob(14) || M == loc && prob(70))


				M:ear_damage += rand(10, 20)
			else if(prob(30))
				M:ear_damage += rand(7, 14)
			if(!M:paralysis)
				M:eye_stat += rand(10, 15)
			if(prob(10)) M:eye_stat += 7
			M:ear_deaf += 30
			if(M == loc)
				M:eye_stat += 10
				if(prob(60))
					if(istype(M, /mob/human))
						var/H = M
						if(!istype(H:ears, /obj/item/weapon/clothing/ears/earmuffs))
							M:ear_damage += 15
							M:ear_deaf += 60
					else
						M:ear_damage += 15
						M:ear_deaf += 60
		else if(get_dist(M, T) <= 5)
			flick("e_flash", M:flash)
			if(!istype(M, /mob/human))
				M:stunned = 7
				M:weakened = 2
			else
				var/H = M
				M:ear_deaf += 10
				if(prob(20)) M:ear_damage += 10
				if(!istype(H:glasses, /obj/item/weapon/clothing/glasses/sunglasses) || M:paralysis)
					M:stunned = 7
					M:weakened = 2
				else if(!M:paralysis)
					M:eye_stat += rand(1, 3)
			M << "\red<B>BANG</B>"
		else
			if(!istype(M, /mob/human))
				flick("flash", M:flash)
			else
				var/H = M
				if(!istype(H:glasses, /obj/item/weapon/clothing/glasses/sunglasses))
					flick("flash", M:flash)
			M:eye_stat += rand(1, 2)
			M:ear_deaf += 5
			M << "\red<B>BANG</B>"
		if(M:eye_stat >= 20)
			M << "\red Your eyes start to burn badly!"
			M:disabilities |= 1
			if(prob(M:eye_stat - 20 + 1))
				M << "\red You go blind!"
				M:sdisabilities |= 1
		if(M:ear_damage >= 15)
			M << "\red Your ears start to ring badly!"

			if(prob(M:ear_damage - 10 + 5))
				M << "\red You go deaf!"
				M:sdisabilities |= 4
		else if(M:ear_damage >= 5)
			M << "\red Your ears start to ring!"
	del(src)
/obj/item/weapon/flashbang/attack_self(mob/user)
	if(!state)
		user << "\red You prime the flashbang! 10 seconds!"
		state = 1
		icon_state = "flashbang1"
		add_fingerprint(user)
		spawn(det_time)
			prime()


/obj/item/weapon/flashbang
	w_class = 2; s_istate = "flashbang"; throwspeed = 20; flags = 402


/obj/item/weapon/flash{w_class = 1; flags = 322; icon_state = "flash"; s_istate = "electronic"}
/obj/item/weapon/flash{var/l_time = 1; var/shots = 5}
/obj/item/weapon/flash/attack(mob/M, mob/user)
	if(shots > 0)
		var/safety = null
		if(istype(M, /mob/human))
			var/H = M
			if(istype(H:glasses, /obj/item/weapon/clothing/glasses/sunglasses)) safety = 1
		if(!safety)
			M:weakened = 10
			if(M:client)
				if(!safety)
					if(M:eye_stat > 15 && prob(M:eye_stat + 50))
						flick("e_flash", M:flash)
						M:eye_stat += rand(1, 2)
					else
						flick("flash", M:flash)
						M:eye_stat += rand(0, 2)
					if(M:eye_stat >= 20)
						M << "\red You eyes start to burn badly!"
						M:disabilities |= 1
						if(prob(M:eye_stat - 20 + 1))
							M << "\red You go blind!"
							M:sdisabilities |= 1
		for(var/mob/O in view(user))
			O:show_message("\red[user] blinds [M] with the flash!")
	attack_self(user, 1)
/obj/item/weapon/flash/attack_self(mob/user, flag)
	if(world.time + 600 > l_time)
		shots = 5
	if(shots < 1)
		user:show_message("\red*click* *click*", 2)
		return
	if(!istype(user, /mob/human) && (!ticker || ticker && ticker:mode != "monkey"))
		user << "\red You don't have the dexterity to do this!"
		return
	l_time = world.time
	add_fingerprint(user)
	shots--
	flick("flash2", src)
	if(!flag)
		for(var/mob/M in oview(3))
			if(M:client)
				var/safety = null
				if(istype(M, /mob/human))
					var/H = M
					if(istype(H:glasses, /obj/item/weapon/clothing/glasses/sunglasses)) safety = 1
				if(!safety) flick("flash", M:flash)





/obj/item/weapon/locator/icon_state = "locator"
/obj/item/weapon/locator/attack_self(mob/user)
	user:show_message("\blue<B>Located Beacons:</B>", 1)
	var/turf/sr = get_turf(src)
	if(sr)
		for(var/obj/item/weapon/radio/beacon/W in world)
			var/tr = get_turf(W)
			if(tr:z == sr:z && tr)
				var/direct = get_dist(sr, tr)
				if(direct < 5)
					direct = "very strong"
				else if(direct < 10)
					direct = "strong"
				else if(direct < 20)
					direct = "weak"
				else
					direct = "very weak"
				user:show_message("\t\blue[W:code]-[dir2text(get_dir(sr, tr))]-[direct]", 1)
		user:show_message("\blue<B>You are at \[[sr:x],[sr:y],[sr:z]\]</B> in orbital coordinates.", 1)
	else
		user:show_message("\blue Processing Error: Unable to locate orbital position.", 1)
	add_fingerprint(user)

/obj/item/weapon/locator
	flags = 322
	w_class = 1
	s_istate = "electronic"
	throwspeed = 20
/obj/item/weapon/sword/icon_state = "sword0"
/obj/item/weapon/flash/throwspeed = 20
/obj/item/weapon/sword/attack(mob/target, mob/user)
	..()
	if(user:key == "Exadv1") user:next_move = 1
/obj/item/weapon/sword/attack_self(mob/user)
	active = !active
	if(active)
		user << "\blue The sword is now active."
		force = 40
		icon_state = "sword1"
		w_class = 4
	else
		user << "\blue The sword can now be concealed."
		force = 3
		icon_state = "sword0"
		w_class = 2
	add_fingerprint(user)
/obj/item/weapon/sword
	var/active = 0
	force = 3
	throwforce = 5
	throwspeed = 5
	w_class = 2
	flags = 290
/obj/item/weapon/shield/icon_state = "shield0"
/obj/item/weapon/shield/attack_self(mob/user)
	active = !active
	if(active)
		user << "\blue The shield is now active."
		force = 40
		icon_state = "shield1"
	else
		user << "\blue The sword can now be concealed."
		force = 3
		icon_state = "shield0"
	add_fingerprint(user)
/obj/item/weapon/shield
	flags = 322
	var/active = 0
	s_istate = "electronic"
	throwforce = 5
	throwspeed = 5
/obj/item/weapon/gun/var/charges = 25
/obj/item/weapon/gun/laser_gun/icon_state = "gun"
/obj/item/weapon/gun/laser_gun/afterattack(target as mob|obj|turf|area, mob/user, flag)
	if(flag) return
	if(!istype(user, /mob/human) && (!ticker || ticker && ticker:mode != "monkey"))
		user << "\red You don't have the dexterity to do this!"
		return
	add_fingerprint(user)
	if(charges < 1)
		user:show_message("\red*click* *click*", 2)
		return
	charges--
	var/turf/T = user:loc
	var/turf/U = istype(target, /atom/movable) ? target:loc : target
	if(!U || !T) return
	while(!istype(U, /turf))
		U = U:loc
	if(!istype(T, /turf)) return
	if(U == T)
		user:las_act()
		return
	var/obj/beam/a_laser/A = new /obj/beam/a_laser(user:loc)
	if(!istype(U, /turf))
		del(A)
		return
	A:current = U
	A:yo = U:y - T:y
	A:xo = U:x - T:x
	user:next_move = world.time + 4
	spawn(0) A:process()
/obj/item/weapon/gun/laser_gun/attack(mob/M, mob/user)
	..()
	add_fingerprint(user)
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
			if(M:weakened < time)
				M:weakened = time
		M:stat = 1
		for(var/mob/O in view(M))
			O:show_message("\red<B>[M] has been knocked unconscious!</B>", 1, "\red You hear someone fall", 2)
		M:show_message("\red<B>This was a [time * 100 / 120]% hit. Roleplay it! (personality/memory change if the hit was severe enough)</B>")
/obj/item/weapon/gun/laser_gun
	w_class = 3
	throwspeed = 10
	force = 7
/obj/item/weapon/shield/w_class = 2

/obj/item/weapon/gun/taser_gun/afterattack(target as mob|obj|turf|area, mob/user, flag)
	if(flag) return
	if(!istype(user, /mob/human) && (!ticker || ticker && ticker:mode != "monkey"))
		user << "\red You don't have the dexterity to do this!"
		return
	add_fingerprint(user)
	if(charges < 1)
		user:show_message("\red*click* *click*", 2)
		return
	charges--
	var/turf/T = user:loc
	var/turf/U = istype(target, /atom/movable) ? target:loc : target
	if(!U || !T) return
	while(!istype(U, /turf) && U)
		U = U:loc
	if(!istype(T, /turf)) return
	if(U == T)
		user:las_act(1)
		return
	var/obj/beam/a_laser/s_laser/A = new /obj/beam/a_laser/s_laser(user:loc)
	if(!istype(U, /turf))
		del(A)
		return
	A:current = U
	A:yo = U:y - T:y
	A:xo = U:x - T:x

	spawn(0) A:process()
/obj/item/weapon/gun/taser_gun/attack(mob/M, mob/user)
	add_fingerprint(user)
	var/mob/human/H = M
	if(istype(H, /mob/human) && (istype(H, /obj/item/weapon/clothing/head) && (H:flags & 8 && prob(80))))
		M << "\red The helmet protects you from being hit hard in the head!"
		return
	if(user:a_intent == "harm")
		if(prob(20))
			if(M:paralysis < 10)
				M:paralysis = 10
		else
			if(M:weakened < 10)
				M:weakened = 10
		..()
		M:stat = 1
		for(var/mob/O in view(M))
			O:show_message("\red<B>[M] has been knocked unconscious!</B>", 1, "\red You hear someone fall", 2)
	else
		if(prob(50))
			if(M:paralysis < 60)
				M:paralysis = 60
		else
			if(M:weakened < 60)
				M:weakened = 60
		M:stat = 1
		for(var/mob/O in view(M))
			if(O:client && !O:blinded)
				O:show_message("\red<B>[M] has been stunned with the taser gun by [user]!</B>", 1, "\red You hear someone fall", 2)
/obj/item/weapon/pill_canister
	w_class = 2
	name = "Pill Canister"
	icon_state = "pill_canister"
	s_istate = "brutepack"


/obj/item/weapon/pill_canister/New()
	..()
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)

/obj/item/weapon/pill_canister/placebo
	name = "Pill Canister- 'Placebos'"
	desc = "<B>Placebos</B>\nThese pills do nothing phsyiologically."
/obj/item/weapon/pill_canister/placebo/New()
	..()
	spawn(2)
		var/P = new /obj/item/weapon/m_pill(src)
		P:amount = 30




/obj/item/weapon/pill_canister/antitoxin
	name = "Pill Canister- 'Antitoxin Supplements'"
	desc = "<B>Anti-toxins</B>\nAdminister as required to relieve of plasma burns.\nAdminister only once every 5 minutes.\n<B>Warning</B>: May cause drowsyness.\nIf drowsyness persists for over 5 minutes contact medical professional."
/obj/item/weapon/pill_canister/antitoxin/New()
	..()
	spawn(2)
		var/P = new /obj/item/weapon/m_pill/antitoxin(src)
		P:amount = 30





/obj/item/weapon/pill_canister/Tourette
	name = "Pill Canister- 'Tourette's Syndrome Remedy'"
	desc = "<B>Tourette's Syndrome Remedy</B>\nAdminister as required to surpress Tourette syndrome induced twitching.\nAdminister only once every 15 minutes. Active for 20 at most.\n<B>WARNING</B>: Neurodepressant! Rebalances chemical alignment!\n<B>Warning</B>: May cause drowsyness.\nIf drowsyness persists for over 5 minutes contact medical professional."
/obj/item/weapon/pill_canister/Tourette/New()
	..()
	spawn(2)
		var/P = new /obj/item/weapon/m_pill/Tourette(src)
		P:amount = 30




/obj/item/weapon/pill_canister/sleep
	name = "Pill Canister- 'Sleeping Pills'"
	desc = "<B>Sleeping Pills</B>\nAdminister as required to calm person.\nCauses 10 minutes of drowsyness. MAY induce immediate sleep.\n<B>WARNING</B>: Neurodepressant! Do not overdose!\n<B>Warning</B>: Causes drowsiness!If drowsyness persists for over 15 minutes contact medical professional."
/obj/item/weapon/pill_canister/sleep/New()
	..()
	spawn(2)
		var/P = new /obj/item/weapon/m_pill/sleep(src)
		P:amount = 30





/obj/item/weapon/pill_canister/epilepsy
	name = "Pill Canister- 'Epilepsy Remedy'"
	desc = "<B>Epilepsy Remedy</B>\nAdminister as required to surpress excessive coughs.\nAdminister only once every 15 minutes. Active for 20 at most.\n<B>WARNING</B>: Neurodepressant! Rebalances chemcial alignment!\n<B>Warning</B>: May cause drowsyness.\nIf drowsyness persists for over 5 minutes contact medical professional."
/obj/item/weapon/pill_canister/epilepsy/New()
	..()
	spawn(2)
		var/P = new /obj/item/weapon/m_pill/epilepsy(src)
		P:amount = 30




/obj/item/weapon/pill_canister/cough
	name = "Pill Canister- 'CCS Remedy'"
	desc = "<B>Chronic Cough Syndrome Remedy</B>\nAdminister as required to surpress excessive coughs.\nAdminister only once every 15 minutes. Active for 20 at most.\n<B>Warning</B>: May cause drowsyness.\nIf drowsyness persists for over 5 minutes contact medical professional."
/obj/item/weapon/pill_canister/cough/New()
	..()
	spawn(2)
		var/P = new /obj/item/weapon/m_pill/cough(src)
		P:amount = 30
/obj/item/weapon/pill_canister/examine()
	set src in view(1)
	..()
	if(contents:len)
		var/pills = 0
		for(var/obj/item/weapon/m_pill/M in src)
			pills += M:amount
		usr << "\blue There are [pills] pills inside!"
	else
		usr << "\blue It looks empty!"
/obj/item/weapon/pill_canister/attack_paw(mob/user)
	if(ticker && ticker:mode == "monkey")
		return attack_hand(user)
/obj/item/weapon/pill_canister/attack_hand(mob/user)
	if(user:r_hand == src || user:l_hand == src)
		var/P = pick(contents)
		if(P)
			P:amount--
			var/W = new P:type(user)
			if(user:hand)
				user:l_hand = W
			else
				user:r_hand = W
			W:layer = 20
			if(P:amount <= 0) del(P)
			W:add_fingerprint(user)
			add_fingerprint(user)
	else return ..()
/obj/item/weapon/pill_canister/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/m_pill))
		var/pills = 0
		for(var/obj/item/weapon/m_pill/M in src)
			pills += M:amount
		if(pills > 30)
			usr << "\blue There are too many pills inside!"
			return
		for(var/obj/item/weapon/m_pill/M in src)
			if(M:type == W:type)
				M:amount += W:amount
				del(W)
				return
		if(W)
			user:drop_item()
			W:loc = src
			add_fingerprint(user)
			W:add_fingerprint(user)
	if(istype(W, /obj/item/weapon/pen))
		var/t = input(user, "What would you like the label to be?", "[name]") as text
		if(user:equipped() != W) return
		if(loc != user) return
		t = html_encode(t)
		if(t)
			name = "Pill Canister- '[t]'"
		else
			name = "Pill Canister"


/obj/item/weapon/m_pill
	w_class = 1
	var/amount = 1
	name = "pill"
	icon_state = "pill"
	s_istate = "pill"

	throwspeed = 20
/obj/item/weapon/m_pill/proc/ingest(mob/M)
	amount--
	if(amount <= 0)
		del(src)
/obj/item/weapon/m_pill/attack_hand(mob/user)
	if(user:r_hand == src || user:l_hand == src)
		add_fingerprint(user)
		var/F = new type(user)
		F:amount = 1
		amount--
		if(user:hand)
			user:l_hand = F
		else
			user:r_hand = F
		F:layer = 20
		F:add_fingerprint(user)
		if(amount < 1) del(src)
	else ..()
/obj/item/weapon/m_pill/attack(mob/M, mob/user)
	if(M:stat == 2) return
	if(user != M && istype(M, /mob/human))
		for(var/mob/O in view(M))
			O:show_message("\red[user] is forcing [M] to swallow the [src]", 1)
		var/obj/equip_e/human/O = new /obj/equip_e/human()
		O:source = user
		O:target = M
		O:item = src
		O:s_loc = user:loc
		O:t_loc = M:loc
		O:place = "pill"
		M:requests += O
		spawn(0) O:process()
	else
		add_fingerprint(user)
		ingest(M)

/obj/item/weapon/m_pill/superpill
	name = "red/blue pill"
/obj/item/weapon/m_pill/superpill/ingest(mob/M)
	M:fireloss = 0
	M:toxloss = 0
	M:bruteloss = 0
	M:oxyloss = 0
	M:paralysis = 5
	M:stunned = 15
	M:weakened = 10
	M:health = 100 - M:oxyloss - M:toxloss - M:fireloss - M:bruteloss
	..()
/obj/item/weapon/m_pill{var/s_time = 1}
/obj/item/weapon/m_pill/sleep
	name = "red/blue pill"
/obj/item/weapon/m_pill/sleep/ingest(mob/M)
	if(M:drowsyness < 600)
		M:drowsyness += 600
		M:drowsyness = min(M:drowsyness, 1800)
	if(prob(25))
		M:paralysis += 60
	else if(prob(50))
		M:paralysis += 30
	..()

/obj/item/weapon/m_pill/antitoxin
	name = "red/blue pill"
/obj/item/weapon/m_pill/antitoxin/ingest(mob/M)
	if(prob(50) && M:drowsyness < 600)
		M:drowsyness += 60
		M:drowsyness = min(M:drowsyness, 600)
	if(M:health >= 0)
		if(M:toxloss <= 20)
			M:toxloss = 0
		else
			M:toxloss -= 20
	M:antitoxs += 600
	M:health = 100 - M:oxyloss - M:toxloss - M:fireloss - M:bruteloss
	..()
/obj/item/weapon/m_pill/cough
	name = "red pill"
	icon_state = "pill4"
/obj/item/weapon/m_pill/cough/ingest(mob/M)
	if(prob(75) && M:drowsyness < 600)
		M:drowsyness += 60
		M:drowsyness = min(M:drowsyness, 600)
	M:r_ch_cou += 1200
	..()
/obj/item/weapon/m_pill/epilepsy
	name = "blue pill"
	icon_state = "pill3"
/obj/item/weapon/m_pill/epilepsy/ingest(mob/M)
	if(M:drowsyness < 600)
		M:drowsyness += rand(2, 3) * 60
		M:drowsyness = min(M:drowsyness, 600)
	M:r_epil += 1200
	..()
/obj/item/weapon/m_pill/Tourette
	name = "green pill"
	icon_state = "pill2"
/obj/item/weapon/m_pill/Tourette/ingest(mob/M)
	if(M:drowsyness < 600)
		M:drowsyness += rand(3, 5) * 60
		M:drowsyness = min(M:drowsyness, 600)
	M:r_Tourette += 1200
	..()
/obj/item/weapon/m_pill/examine()
	set src in view(1)
	..()
	usr << "\blue There are [amount] pills left on the stack!"
/obj/item/weapon/m_pill/attackby(obj/W, mob/user)
	if(!istype(W, type)) return
	if(W:amount == 5) return
	if(W:amount + amount > 5)
		amount = W:amount + amount - 5
		W:amount = 5
	else
		W:amount += amount
		del(src)





/obj/item/weapon/handcuffs/attack(mob/M, mob/user)
	if(!istype(user, /mob/human) && (!ticker || ticker && ticker:mode != "monkey"))
		user << "\red You don't have the dexterity to do this!"
		return
	if(istype(M, /mob/human))
		var/obj/equip_e/human/O = new /obj/equip_e/human()
		O:source = user
		O:target = M
		O:item = user:equipped()
		O:s_loc = user:loc
		O:t_loc = M:loc
		O:place = "handcuff"
		M:requests += O
		spawn(0) O:process()
	else
		var/obj/equip_e/monkey/O = new /obj/equip_e/monkey()
		O:source = user
		O:target = M
		O:item = user:equipped()
		O:s_loc = user:loc
		O:t_loc = M:loc
		O:place = "handcuff"
		M:requests += O
		spawn(0) O:process()




/obj/item/weapon/gun
	flags = 402
/obj/item/weapon/handcuffs
	icon_state = "handcuff"
	flags = 450
	w_class = 2
/obj/item/weapon/throwing(t_dir, rs)
	if(!rs) rs = r_speed
	..(t_dir, rs)
/obj/item/weapon/proc/moved(mob/user, turf/old_loc)
/obj/item/weapon/examine()
	set src in view()
	var/t
	switch(w_class)
		if(1)
			t = "tiny"
		if(2)
			t = "small"
		if(3)
			t = "normal-sized"
		if(4)
			t = "bulky"
		if(5)
			t = "huge"
	usr << "This is a \icon[src][name]. It is a [t] item."
	..()





/obj/item/weapon/gun/taser_gun
	w_class = 3
	icon_state = "t_gun"
	s_istate = "gun"
	force = 10
	throwspeed = 10

/obj/item/weapon/attack_hand(mob/user)
	if(istype(loc, /obj/item/weapon/storage))
		for(var/mob/M in range(1, src.loc))
			if(M:s_active == loc)
				if(M:client) M:client:screen -= src
	throwing = 0
	if(loc == user)
		user:u_equip(src)
	if(user:hand)
		user:l_hand = src
	else user:r_hand = src
	loc = user
	layer = 20
	add_fingerprint(user)
	user:UpdateClothing()




/obj/item/weapon/attack_paw(mob/user)
	if(istype(loc, /obj/item/weapon/storage))
		for(var/mob/M in range(1, src.loc))
			if(M:s_active == loc)
				if(M:client) M:client:screen -= src
	throwing = 0
	if(loc == user)
		user:u_equip(src)
	if(user:hand)
		user:l_hand = src
	else user:r_hand = src
	loc = user
	layer = 20
	user:UpdateClothing()
/obj/item/weapon/wire
	var/amount = 1
	icon_state = "item_wire"
	desc = "This is just a simple piece of regular insulated wire."
	var/laying = 0
	var/old_lay
/obj/item/weapon/wire/proc/update()
	if(amount > 1)
		icon_state = "spool_wire"
		desc = "This is just spool of regular insulated wire. It consists of about [amount] unit\s of wire."
	else
		icon_state = "item_wire"
		desc = "This is just a simple piece of regular insulated wire."













/obj/item/weapon/wire/attack_self(mob/user)
	if(laying)
		laying = 0
		user << "\blue Your done laying wire!"
	else user << "\blue You are not using this to lay wire..."




















/obj/item/weapon/card
	var/datum/data/files = list()
/obj/item/weapon/card/data
	icon_state = "card-data"
	s_istate = "card-id"
	var/function = "storage"
	var/data = "null"
	name = "Data Disk"
	w_class = 1
	var/special
/obj/item/weapon/card/data/verb/label(t as text)
	set src in usr
	if(t)
		src.name = "Data Disk- '[t]'"
	else
		name = "Data Disk"
	add_fingerprint(usr)

/obj/item/weapon/card/id
	icon_state = "card-id"
	name = "Identification Card"
	var/access_level
	var/lab_access
	var/engine_access
	var/air_access
	var/registered
	var/assignment
	w_class = 1
/obj/item/weapon/card/id/verb/show()
	set src in usr
	for(var/mob/O in view(usr))
		O:show_message("[usr] shows you: \icon[src] [name]: assignment: [assignment]", 1)
	add_fingerprint(usr)
/obj/item/weapon/card/id/verb/read()
	set src in usr
	usr << "\icon[src] [name]: The current assignment on the card is [assignment]."
	usr << "\blue The rubric for the 4 access numbers is: general>lab-engine-air"







/obj/item/weapon/rods
	icon_state = "rods"
	flags = 322
	w_class = 4
	force = 9
	throwforce = 20
	throwspeed = 10
	var/amount = 1
/obj/item/weapon/sheet/r_metal
	name = "reinforced metal"
	icon_state = "sheet-r_metal"
	force = 5
	throwforce = 14
	s_istate = "sheet-metal"
/obj/item/weapon/rods/attack_hand(mob/user)
	if(user:r_hand == src || user:l_hand == src)
		add_fingerprint(user)
		var/F = new /obj/item/weapon/rods(user)
		F:amount = 1
		amount--
		if(user:hand)
			user:l_hand = F
		else
			user:r_hand = F
		F:layer = 20
		F:add_fingerprint(user)
		if(amount < 1) del(src)
	else ..()
/obj/item/weapon/rods/attackby(obj/W, mob/user)
	if(!istype(W, /obj/item/weapon/rods)) return
	if(W:amount == 6) return
	if(W:amount + amount > 6)
		amount = W:amount + amount - 6
		W:amount = 6
	else
		W:amount += amount
		del(src)
/obj/item/weapon/rods/examine()
	set src in view(1)
	..()
	usr << "There are [amount] rod\s left on the stack."
/obj/item/weapon/rods/attack_self(mob/user)
	if(locate(/obj/grille) in usr.loc)
		for(var/obj/grille/G in usr.loc)
			if(G:destroyed)
				G:health = 10
				G:density = 1
				G:destroyed = 0
				G:icon_state = "grille"
				amount--
				break
	else
		if(amount < 2) return
		amount -= 2
		new /obj/grille(usr.loc)
	if(amount < 1)
		del(src)
	add_fingerprint(user)
/obj/item/weapon/sheet
	var/amount = 1
	var/length = 2.5
	var/width = 1.5
	var/height = 0.01
	flags = 322
	throwforce = 7
	throwspeed = 10
	w_class = 4
/obj/item/weapon/sheet/metal
	icon_state = "sheet-metal"
	throwforce = 14




/obj/item/weapon/sheet/metal/attack_hand(mob/user)
	if(user:r_hand == src || user:l_hand == src)
		add_fingerprint(user)
		var/F = new /obj/item/weapon/sheet/metal(user)
		F:amount = 1
		amount--
		if(user:hand)
			user:l_hand = F
		else
			user:r_hand = F
		F:layer = 20
		F:add_fingerprint(user)
		if(amount < 1) del(src)
	else ..()
	force = 5


/obj/item/weapon/sheet/metal/attackby(obj/W, mob/user)
	if(!istype(W, /obj/item/weapon/sheet/metal)) return
	if(W:amount == 5) return
	if(W:amount + amount > 5)
		amount = W:amount + amount - 5
		W:amount = 5
	else
		W:amount += amount
		del(src)
/obj/item/weapon/sheet/metal/examine()
	set src in view(1)
	..()
	usr << "There are [amount] metal sheet\s on the stack."
/obj/item/weapon/sheet/metal/attack_self(mob/user)
	var/t1 = "<HTML><HEAD></HEAD><TT>Amount Left: [amount] <BR>"
	var/counter = 1
	var/L = list()
	L["rods"] = "metal rods (makes 2)"
	L["stool"] = "stool"
	L["chair"] = "chair"
	L["table"] = "table parts (2)"
	L["rack"] = "rack parts"
	L["o2can"] = "o2 canister (2)"
	L["plcan"] = "pl canister (2)"
	L["closet"] = "closet (2)"
	L["fl_tiles"] = "floor tiles (makes 4)"
	L["reinforced"] = "reinforced sheet (2) (Doesn't stack)"
	L["repair"] = "repair wall"
	L["construct"] = "construct wall"
	for(var/t in L)
		counter++
		t1 += "<A href='?src=\ref[src];make=[t]'>[L[t]]</A>  "
		if(counter > 2)
			counter = 1
			t1 += "<BR>"
	t1 += "</TT></HTML>"
	user << browse(t1, "window=met_sheet")
/obj/item/weapon/sheet/metal/Topic(href, href_list)
	if(usr.restrained() || (usr.stat || usr.equipped() != src))
		return
	if(href_list["make"])
		if(amount < 1) del(src)
		switch(href_list["make"])
			if("rods")
				amount--
				var/R = new /obj/item/weapon/rods(usr.loc)
				R:amount = 2
			if("table")
				if(amount < 2) return
				amount -= 2
				new /obj/item/weapon/table_parts(usr.loc)
			if("stool")
				amount--
				new /obj/stool(usr.loc)
			if("chair")
				amount--
				var/C = new /obj/stool/chair(usr.loc)
				C:dir = usr.dir
				if(C:dir == NORTH)
					C:layer = 5
			if("rack")
				amount--
				new /obj/item/weapon/rack_parts(usr.loc)
			if("o2can")
				if(amount < 2) return
				amount -= 2
				var/C = new /obj/machinery/atmoalter/canister/oxygencanister(usr.loc)
				C:gas:oxygen = 0
			if("plcan")
				if(amount < 2) return
				amount -= 2
				var/C = new /obj/machinery/atmoalter/canister/poisoncanister(usr.loc)
				C:gas:plasma = 0
			if("reinforced")
				if(amount < 2) return
				amount -= 2
				var/C = new /obj/item/weapon/sheet/r_metal(usr.loc)
				C:amount = 1
			if("closet")
				if(amount < 2) return
				amount -= 2

				new /obj/closet(usr.loc)
			if("fl_tiles")
				amount--
				var/R = new /obj/item/weapon/tile(usr.loc)
				R:amount = 4
			if("construct")
				if(amount < 2) return
				amount -= 2
				var/turf/F = get_step(usr, usr.dir)
				if(!istype(F, /turf/station/floor)) return
				var/W = new /turf/station/wall(locate(F:x, F:y, F:z))
				W:icon_state = "girder"
				W:updatecell = 1
				W:opacity = 0
				W:state = 1
				W:density = 1
			else if(1)
				if(amount < 2) return
				var/W = get_step(usr, usr.dir)
				if(!istype(W, /turf/station/wall)) return
				amount -= 2
				W:icon_state = ""
				W:state = 2
				W:density = 1
				W:opacity = 1
				W:updatecell = 0
		if(amount <= 0)
			del(src)
	spawn(0) attack_self(usr)




























































































/obj/item/weapon/sheet/glass
	icon_state = "sheet-glass"
	force = 5
/obj/item/weapon/sheet/glass/attack_hand(mob/user)
	if(user:r_hand == src || user:l_hand == src)
		add_fingerprint(user)
		var/F = new /obj/item/weapon/sheet/glass(user)
		F:amount = 1
		amount--
		if(user:hand)
			user:l_hand = F
		else
			user:r_hand = F
		F:layer = 20
		F:add_fingerprint(user)
		if(amount < 1) del(src)
	else ..()
	force = 5
/obj/item/weapon/sheet/glass/attackby(obj/W, mob/user)
	if(!istype(W, /obj/item/weapon/sheet/glass)) return
	if(W:amount == 5) return
	if(W:amount + amount > 5)
		amount = W:amount + amount - 5
		W:amount = 5
	else
		W:amount += amount
		del(src)
/obj/item/weapon/sheet/glass/examine()
	set src in view(1)
	..()
	usr << "There are [amount] glass sheet\s on the stack."
/obj/item/weapon/sheet/glass/attack_self(mob/user)
	if(!istype(usr.loc, /turf/station)) return
	if(!istype(user, /mob/human) && (!ticker || ticker && ticker:mode != "monkey"))
		user << "\red You don't have the dexterity to do this!"
		return
	switch(alert("Sheet-Glass", "Would you like full tile glass or one direction?", "one direct", "full (2 sheets)"))
		if("one direct")
			var/W = new /obj/window(usr.loc)
			W:anchored = 0
			if(amount < 1) return
			amount--
		if("full (2 sheets)")
			if(amount < 2) return
			amount -= 2
			var/W = new /obj/window(usr.loc)
			W:dir = SOUTHWEST
			W:ini_dir = SOUTHWEST
			W:anchored = 0
	if(amount <= 0)
		user:u_equip(src)
		del(src)


/obj/item/weapon/wirecutters
	icon_state = "cutters"
	flags = 322
	force = 6
	throwspeed = 9
	w_class = 2
/obj/item/weapon/clipboard
	icon_state = "clipboard00"
	s_istate = "clipboard"
	var/pen
/obj/item/weapon/clipboard/attack_self(mob/user)
	var/dat = "<B>Clipboard</B><BR>"
	if(pen)
		dat += "<A href='?src=\ref[src];pen=1'>Remove Pen</A><BR><HR>"
	for(var/obj/item/weapon/paper/P in src)
		dat += "<A href='?src=\ref[src];read=\ref[P]'>[P:name]</A> <A href='?src=\ref[src];write=\ref[P]'>Write</A> <A href='?src=\ref[src];remove=\ref[P]'>Remove</A><BR>"
	user << browse(dat, "window=clipboard")
/obj/item/weapon/clipboard/Topic(href, href_list)
	if(usr.stat || usr.restrained()) return
	if(usr.contents:Find(src))
		usr.machine = src
		if(href_list["pen"])
			if(pen)
				if(usr.hand && !usr.l_hand)
					usr.l_hand = pen
					pen:loc = usr
					pen:layer = 20
					pen = null
					usr.UpdateClothing()
				else if(!usr.r_hand)
					usr.r_hand = pen
					pen:loc = usr
					pen:layer = 20
					pen = null
					usr.UpdateClothing()
				pen:add_fingerprint(usr)
				add_fingerprint(usr)
		if(href_list["remove"])
			var/P = locate(href_list["remove"])
			if(P && P:loc == src)
				if(usr.hand && !usr.l_hand)
					usr.l_hand = P
					P:loc = usr
					P:layer = 20
					usr.UpdateClothing()
				else if(!usr.r_hand)
					usr.r_hand = P
					P:loc = usr
					P:layer = 20
					usr.UpdateClothing()
				P:add_fingerprint(usr)
				add_fingerprint(usr)
		if(href_list["write"])
			var/P = locate(href_list["write"])
			if(P && P:loc == src)
				if(istype(usr.r_hand, /obj/item/weapon/pen))
					P:attackby(usr.r_hand, usr)
				else if(istype(usr.l_hand, /obj/item/weapon/pen))
					P:attackby(usr.l_hand, usr)
				else if(istype(pen, /obj/item/weapon/pen))
					P:attackby(pen, usr)
			add_fingerprint(usr)
		if(href_list["read"])
			var/obj/item/weapon/paper/P = locate(href_list["read"])
			if(P && P:loc == src)
				if(!istype(usr, /mob/human))
					usr << browse("<HTML><HEAD><TITLE>[P:name]</TITLE></HEAD><BODY><TT>[stars(P:info)]</TT></BODY></HTML>", "window=[P:name]")
				else
					usr << browse("<HTML><HEAD><TITLE>[P:name]</TITLE></HEAD><BODY><TT>[P:info]</TT></BODY></HTML>", "window=[P:name]")
		if(ismob(loc))
			var/M = loc
			if(M:machine == src)
				spawn(0) attack_self(M)
/obj/item/weapon/clipboard/attack_paw(mob/user)
	return attack_hand(user)
/obj/item/weapon/clipboard/attack_hand(mob/user)
	if((locate(/obj/item/weapon/paper) in src) && (!user:equipped() && (user:l_hand == src || user:r_hand == src)))
		var/obj/item/weapon/paper/P
		for(P in src) break
		if(P)
			if(user:hand)
				user:l_hand = P
			else user:r_hand = P
			P:loc = user
			P:layer = 20
			P:add_fingerprint(user)
			user:UpdateClothing()
		add_fingerprint(user)
	else if(user:contents:Find(src))
		spawn(0) attack_self(user)
	else
		return ..()
/obj/item/weapon/clipboard/attackby(obj/P, mob/user)
	if(istype(P, /obj/item/weapon/paper))
		if(contents:len < 15)
			user:drop_item()
			P:loc = src
			if(istype(P, /obj/item/weapon/paper/flag))
				if(ctf) ctf:check_win(src)
		else
			user << "\blue Not enough space!!!"
	else if(istype(P, /obj/item/weapon/pen))
		if(!pen)
			user:drop_item()
			P:loc = src
			pen = P
	else return
	update()
	spawn(0) attack_self(user)
/obj/item/weapon/clipboard/proc/update()
	icon_state = "clipboard[(locate(/obj/item/weapon/paper) in src) ? "1" : "0"][(locate(/obj/item/weapon/pen) in src) ? "1" : "0"]"
/obj/item/weapon/fcardholder
	name = "Finger Print Case"
	icon_state = "fcardholder0"
	s_istate = "clipboard"
	w_class = 3
/obj/item/weapon/fcardholder/attack_self(mob/user)
	var/dat = "<B>Clipboard</B><BR>"
	for(var/obj/item/weapon/f_card/P in src)
		dat += "<A href='?src=\ref[src];read=\ref[P]'>[P:name]</A> <A href='?src=\ref[src];remove=\ref[P]'>Remove</A><BR>"
	user << browse(dat, "window=fcardholder")
/obj/item/weapon/fcardholder/Topic(href, href_list)
	if(usr.stat || usr.restrained()) return
	if(usr.contents:Find(src))
		usr.machine = src
		if(href_list["remove"])
			var/P = locate(href_list["remove"])
			if(P && P:loc == src)
				if(usr.hand && !usr.l_hand)
					usr.l_hand = P
					P:loc = usr
					P:layer = 20
					usr.UpdateClothing()
				else if(!usr.r_hand)
					usr.r_hand = P
					P:loc = usr
					P:layer = 20
					usr.UpdateClothing()
				add_fingerprint(usr)
				P:add_fingerprint(usr)
			update()
		if(href_list["read"])
			var/obj/item/weapon/f_card/P = locate(href_list["read"])
			if(P && P:loc == src)
				if(!istype(usr, /mob/human))
					usr << browse("<HTML><HEAD><TITLE>[P:name]</TITLE></HEAD><BODY><TT>[P:display()]</TT></BODY></HTML>", "window=[P:name]")
				else
					usr << browse("<HTML><HEAD><TITLE>[P:name]</TITLE></HEAD><BODY><TT>[P:display()]</TT></BODY></HTML>", "window=[P:name]")
			add_fingerprint(usr)
		if(ismob(loc))
			var/M = loc
			if(M:machine == src)
				spawn(0) attack_self(M)
/obj/item/weapon/fcardholder/attack_paw(mob/user)
	return attack_hand(user)
/obj/item/weapon/fcardholder/attack_hand(mob/user)
	if(user:contents:Find(src))
		spawn(0) attack_self(user)
		add_fingerprint(user)
	else
		return ..()
/obj/item/weapon/fcardholder/attackby(obj/P, mob/user)
	if(istype(P, /obj/item/weapon/f_card))
		if(contents:len < 30)
			user:drop_item()
			P:loc = src
			P:add_fingerprint(user)
			add_fingerprint(user)
		else
			user << "\blue Not enough space!!!"
	else if(istype(P, /obj/item/weapon/pen))
		var/t = input(user, "Holder Label:", "[name]") as text
		if(user:equipped() != P) return
		if(get_dist(src, usr) > 1 && loc != user) return
		t = html_encode(t)
		if(t)
			name = "FPCase- '[t]'"
		else
			name = "Finger Print Case"
	else return
	update()
	spawn(0) attack_self(user)
/obj/item/weapon/fcardholder/proc/update()
	var/i = 0
	for(var/obj/item/weapon/f_card/F in src)
		i = 1
		break
	icon_state = "fcardholder[i ? "1" : "0"]"
/obj/item/weapon/extinguisher
	flags = 274
	w_class = 2
	force = 17
	name = "Fire Extinguisher"
	var/waterleft = 20
	var/last_use = 1
	icon_state = "fire_extinguisher0"
	s_istate = "fire_extinguisher"
	desc = "The safety is on."
/obj/item/weapon/extinguisher/examine()
	set src in usr
	usr << "\icon[src] [name] contains [waterleft] units of water left!"
	..()
/obj/item/weapon/extinguisher/afterattack(atom/target, mob/user, flag)
	if(icon_state == "fire_extinguisher1")
		if(waterleft < 1) return
		if(world.time < last_use + 20) return
		last_use = world.time
		if(istype(target, /area)) return
		var/cur_loc = get_turf(user)
		var/tar_loc = isturf(target) ? target : get_turf(target)
		if(get_dist(tar_loc, cur_loc) > 1)
			var/mob/close = list()
			var/mob/far = list()
			for(var/T as turf in oview(2, tar_loc))
				if(get_dist(T, tar_loc) <= 1)
					close += T
				else
					far += T
			close += tar_loc
			for(var/t = 1, t <= 14, t++)
				var/W = new /obj/effects/water(cur_loc)
				if(rand(1, 3) != 1)
					walk_towards(W, pick(close))
				else
					walk_towards(W, pick(far))
				sleep(1)
			waterleft--
			last_use = world.time
		else if(cur_loc == tar_loc)
			new /obj/effects/water(cur_loc)
			waterleft -= 0.25
			last_use = 1
		else
			var/mob/possible = list()
			for(var/T as turf in oview(1, tar_loc))
				possible += T
			possible += tar_loc
			for(var/t = 1, t <= 7, t++)
				var/W = new /obj/effects/water(cur_loc)
				walk_towards(W, pick(possible))
				sleep(1)
			waterleft -= 0.5
			last_use = world.time
	else return ..()
/obj/item/weapon/extinguisher/attack_self(mob/user)
	if(icon_state == "fire_extinguisher0")
		icon_state = "fire_extinguisher1"
		desc = "The safety is off."
	else
		icon_state = "fire_extinguisher0"
		desc = "The safety is on."

/obj/item/weapon/pen
	icon_state = "pen"
	flags = 386
	w_class = 1
	throwspeed = 15
/obj/item/weapon/paint
	icon_state = "paint_neutral"
	s_istate = "paintcan"
	name = "Paint Can"
	w_class = 3
	var/color = "neutral"
/obj/item/weapon/paint/attack_self(mob/user)
	var/t1 = input(user, "Please select a color:", "Locking Computer") in list("red", "blue", "green", "yellow", "black", "white", "neutral")

	if(user:equipped() != src || (user:stat || user:restrained())) return
	color = t1
	icon_state = "paint_[t1]"
	add_fingerprint(user)
/obj/item/weapon/camera
	icon_state = "camera"
	s_istate = "wrench"
	w_class = 2
	var/last_pic = 1
/obj/item/weapon/camera/attack_self(mob/user)
	if(last_pic > world.time) return
	last_pic = world.time + 30
	var/turf/T = get_turf(src)
	var/P = new /obj/item/weapon/paper/photograph(src)
	P:photo_id = createphoto(T:z, 32, 32, list(/obj/screen), T:x - 5, T:x + 5, T:y - 5, T:y + 5, T)
	if(isnum(P:photo_id))
		P:loc = user:loc
	else
		del(P)
/obj/item/weapon/paper
	icon_state = "paper"
	name = "Paper"
	var/info
	w_class = 1
	throwspeed = 15
/obj/item/weapon/paper/burn(fi_amount)
	spawn(0)
		var/t = icon_state
		icon_state = ""
		icon = 'b_items.dmi'
		flick("[t]", src)
		spawn(14)
			del(src)
/obj/item/weapon/paper/photograph
	s_istate = "paper"
	name = "photo"
	icon_state = "photo"
	var/photo_id = 0
/obj/item/weapon/paper/photograph/New()
	..()
	pixel_y = 0
	pixel_x = 0
/obj/item/weapon/paper/photograph/attack_self(mob/user)
	var/n_name = input(user, "What would you like to label the photo?", "Paper Labelling") as text
	n_name = copytext(n_name, 1, 32)
	if(loc == user && user:stat == 0)
		name = "photo[n_name ? "- '[n_name]'" : null]"
	add_fingerprint(user)
/obj/item/weapon/paper/photograph/examine()
	set src in view()
	..()
	usr << browse("<body bgcolor=black text=white><p align=center><font size=5 face='Verdana'>Please wait... <p><center>Loading photo ...</center></font><br>This could take 5 minutes depending on prechached files and transfer rates. The other (usually blank) popup will show 'notes' written on the pic</body>", "window=photo,size=\
\
[min(world.maxx * 16 + 50, 630)]x[min(world.maxy * 16 + 150, 450)]")
	for(var/obj/photoshot/two/X in photos) usr << browse_rsc(X:photo, "[X:imgstring].dmi")
	if(photo_id > photoid) return 0
	var/filename = "photos/[photo_id].tmp"
	if(fexists(filename))
		spawn(20)
			usr << browse(file(filename), "window=photo;size=500x500")
	else usr << "The photo is blank!"
/obj/item/weapon/paper/flag
	icon_state = "flag_neutral"
	s_istate = "paper"
	anchored = 1
/obj/item/weapon/paper/flag/burn()
	return
/obj/item/weapon/paper/flag/New()
	..()
	pixel_y = 0
	pixel_x = 0
	name = "flag- 'FLAG'"
/obj/item/weapon/paper/flag/attack_hand()
	if(ctf && ctf:immobile)
		return 0
	else
		. = ..()
/obj/item/weapon/paper/flag/attack_self(mob/user)
	var/n_name = input(user, "What would you like to label the paper?", "Paper Labelling") as text
	n_name = copytext(n_name, 1, 32)
	if(loc == user && user:stat == 0)
		name = "flag[n_name ? "- '[n_name]'" : null]"
	add_fingerprint(user)
/obj/item/weapon/paper/flag/attackby(obj/P, mob/user)
	if(istype(P, /obj/item/weapon/pen))
		..()
	else if(istype(P, /obj/item/weapon/paint))
		var/C = P
		icon_state = "flag_[C:color]"
		if(ctf) ctf:check_win()
	else return
/obj/item/weapon/paper/New()
	..()
	pixel_y = rand(1, 16)
	pixel_x = rand(1, 16)



/obj/item/weapon/paper/attack_self(mob/user)
	var/n_name = input(user, "What would you like to label the paper?", "Paper Labelling") as text
	n_name = copytext(n_name, 1, 32)
	if(loc == user && user:stat == 0)
		name = "paper[n_name ? "- '[n_name]'" : null]"
	add_fingerprint(user)
/obj/item/weapon/paper/attackby(obj/P, mob/user)
	if(istype(P, /obj/item/weapon/pen))
		var/t = input(user, "What text do you wish to add?", "[name]") as message
		if(get_dist(src, usr) > 1 && (loc != user && (!istype(loc, /obj/item/weapon/clipboard) && (loc:loc != user && user:equipped() != P)))) return
		t = html_encode(t)
		t = dd_replacetext(t, "\n", "<BR>")
		t = dd_replacetext(t, "\[b\]", "<B>")
		t = dd_replacetext(t, "\[/b\]", "</B>")
		t = dd_replacetext(t, "\[i\]", "<I>")
		t = dd_replacetext(t, "\[/i\]", "</I>")
		t = dd_replacetext(t, "\[u\]", "<U>")
		t = dd_replacetext(t, "\[/u\]", "</U>")
		t = dd_replacetext(t, "\[sign\]", "<font face=vivaldi>[user:rname]</font>")
		t = "<font face=calligrapher>[t]</font>"
		info += t
	else if(istype(P, /obj/item/weapon/weldingtool))
		var/W = P
		if(W:welding && W:weldfuel > 0)
			for(var/mob/O in view(user))
				O:show_message("\red[user] burns [src] with the welding tool!", 1, "\red You hear a small burning noise", 2)
			spawn(0) burn(4000000)
	else if(istype(P, /obj/item/weapon/igniter))
		for(var/mob/O in view(user))
			O:show_message("\red[user] burns [src] with the igniter!", 1, "\red You hear a small burning noise", 2)
		spawn(0) burn(4000000)
	else if(istype(P, /obj/item/weapon/wirecutters))
		for(var/mob/O in view(user))
			O:show_message("\red[user] starts cutting [src]!", 1)
		sleep(50)
		if((loc == src || get_dist(src, user) <= 1) && (!user:stat && !user:restrained()))
			for(var/mob/O in view(user))
				O:show_message("\red[user] cuts [src] to pieces!", 1)
			del(src)
	add_fingerprint(user)
/obj/item/weapon/paper/examine()
	set src in view()
	..()
	if(!istype(usr, /mob/human))
		usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY><TT>[stars(info)]</TT></BODY></HTML>", "window=[name]")
	else
		usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY><TT>[info]</TT></BODY></HTML>", "window=[name]")

/obj/item/weapon/paper/jobs
	name = "paper- 'Job Information'"
	info = {"Information on all formal jobs that can be assigned on Space Station 13 can be found on this document.<BR>
The data will be in the following form.<BR>
Generally lower ranking positions come first in this list.<BR>
<BR>
<B>Job Name</B>   general access>lab access-engine access-systems access (atmosphere control)<BR>
\tJob Description<BR>
Job Duties (in no particular order)<BR>
Tips (where applicable)<BR>
<BR>
<B>Research Assistant</B> 1>1-0-0<BR>
\tThis is probably the lowest level position. Anyone who enters the space station after the initial job
assignment will automatically receive this position. Access with this is restricted. Head of Personnel should
appropriate the correct level of assistance.<BR>
1. Assist the researchers.<BR>
2. Clean up the labs.<BR>
3. Prepare materials.<BR>
<BR>
<B>Staff Assistant</B> 2>0-0-0<BR>
\tThis position assists the security officer in his duties. The staff assisstants should primarily br
patrolling the ship waiting until they are needed to maintain ship safety.
(Addendum: Updated/Elevated Security Protocols admit issuing of low level weapons to security personnel)<BR>
1. Patrol ship/Guard key areas<BR>
2. Assist security officer<BR>
3. Perform other security duties.<BR>
<BR>
<B>Technical Assistant</B> 1>0-0-1<BR>
\tThis is yet another low level position. The technical assistant helps the engineer and the statian
technician with the upkeep and maintenance of the station. This job is very important because it usually
gets to be a heavy workload on station technician and these helpers will alleviate that.<BR>
1. Assist Station technician and Engineers.<BR>
2. Perform general maintenance of station.<BR>
3. Prepare materials.<BR>
<BR>
<B>Medical Assistant</B> 1>1-0-0<BR>
\tThis is the fourth position yet it is slightly less common. This position doesn't have much power
outside of the med bay. Consider this position like a nurse who helps to upkeep medical records and the
materials (filling syringes and checking vitals)<BR>
1. Assist the medical personnel.<BR>
2. Update medical files.<BR>
3. Prepare materials for medical operations.<BR>
<BR>
<B>Research Technician</B> 2>3-0-0<BR>
\tThis job is primarily a step up from research assistant. These people generally do not get their own lab
but are more hands on in the experimentation process. At this level they are permitted to work as consultants to
the others formally.<BR>
1. Inform superiors of research.<BR>
2. Perform research alongside of official researchers.<BR>
<BR>
<B>Forensic Technician</B> 3>2-0-0<BR>
\tThis job is in most cases slightly boring at best. Their sole duty is to
perform investigations of crine scenes and analysis of the crime scene. This
alleviates SOME of the burden from the security officer. This person's duty
is to draw conclusions as to what happened and testify in court. Said person
also should stroe the evidence safely.<BR>
1. Perform crime-scene investigations/draw conclusions.<BR>
2. Store and catalogue evidence properly.<BR>
3. Testify to superiors/inquieries on findings.<BR>
<BR>
<B>Station Technician</B> 2>0-2-3<BR>
\tPeople assigned to this position must work to make sure all the systems aboard Space Station 13 are operable.
They should primarily work in the computer lab and repairing faulty equipment. They should work with the
atmospheric technician.<BR>
1. Maintain SS13 systems.<BR>
2. Repair equipment.<BR>
<BR>
<B>Atmospheric Technician</B> 3>0-0-4<BR>
\tThese people should primarily work in the atmospheric control center and lab. They have the very important
job of maintaining the delicate atmosphere on SS13.<BR>
1. Maintain atmosphere on SS13<BR>
2. Research atmospheres on the space station. (safely please!)<BR>
<BR>
<B>Engineer</B> 2>1-2-0<BR>
\tPeople working as this should generally have detailed knowledge as to how the propulsion systems on SS13
work. They are one of the few classes that have unrestricted access to the engine area.<BR>
1. Upkeep the engine.<BR>
2. Prevent fires in the engine.<BR>
3. Maintain a safe orbit.<BR>
<BR>
<B>Medical Researcher</B> 2>5-0-0<BR>
\tThis position may need a little clarification. Their duty is to make sure that all experiments are safe and
to conduct experiments that may help to improve the station. They will be generally idle until a new laboratory
is constructed.<BR>
1. Make sure the station is kept safe.<BR>
2. Research medical properties of materials studied of Space Station 13.<BR>
<BR>
<B>Toxin Researcher</B> 2>5-0-0<BR>
\tThese people study the properties, particularly the toxic properties, of materials handled on SS13.
Technically they can also be called Plasma Technicians as plasma is the material they routinly handle.<BR>
1. Research plasma<BR>
2. Make sure all plasma is properly handled.<BR>
<BR>
<B>Medical Doctor (Officer)</B> 2>0-0-0<BR>
\tPeople working this job should primarily stay in the medical area. They should make sure everyone goes to
the medical bay for treatment and examination. Also they should make sure that medical supplies are kept in
order.<BR>
1. Heal wounded people.<BR>
2. Perform examinations of all personnel.<BR>
3. Moniter usage of medical equipment.<BR>
<BR>
<B>Security Officer</B> 3>0-0-0<BR>
\tThese people should attempt to keep the peace inside the station and make sure the station is kept safe. One
side duty is to assist in repairing the station. They also work like general maintenance personnel. They are not
given a weapon and must use their own resources.<BR>
(Addendum: Updated/Elevated Security Protocols admit issuing of weapons to security personnel)<BR>
1. Maintain order.<BR>
2. Assist others.<BR>
3. Repair structural problems.<BR>
<BR>
<B>Head of Research</B> 4>5-2-2<BR>
\tPeople assigned as head of research should make sure all experiments are conducted efficiently. They should
also carefully moderate the usage of all equipment. All experiment results should be reported to this person.<BR>
1. Moderate equipment.<BR>
2. Process research results.<BR>
3. Coordinate all research.<BR>
<BR>
<B>Head of Personnel</B> 4>4-2-2<BR>
\tPeople assigned as head of personnel will find themselves moderating all actions done by personnel. Security
should report to them. Also they have the ability to assign jobs and access levels.<BR>
1. Assign duties.<BR>
2. Moderate personnel.<BR>
3. Command Security.<BR>
<BR>
<B>Captain</B> 5>5-5-5 (unrestricted station wide access)<BR>
\tThis is the highest position youi can aquire on Space Station 13. They are allowed anywhere inside the
space station and therefore should protect their ID card. They also have the ability to assign positions
and access levels. They should not abuse their power.<BR>
1. Assign all positions on SS13<BR>
2. Inspect the station for any problems.<BR>
3. Perform administrative duties.<BR>
"}
/obj/item/weapon/paper/sop
	name = "paper- 'Standard Operating Procedure'"
	info = {"Alert Levels:<BR>
Blue- Emergency<BR>
\t1. Caused by fire<BR>
\t2. Caused by manual interaction<BR>
\tAction:<BR>
\t\tClose all fire doors. These can only be opened by reseting the alarm<BR>
Red- Ejection/Self Destruct<BR>
\t1. Caused by module operating computer.<BR>
\tAction:<BR>
\t\tAfter the specified time the module will eject completely.<BR>
<BR>
Engine Maintenance Instructions:<BR>
\tShut off ignition systems:<BR>
\tActivate internal power<BR>
\tActivate orbital balance matrix<BR>
\tRemove volatile liquids from area<BR>
\tWear a fire suit<BR>
<BR>
\tAfter<BR>
\t\tDecontaminate<BR>
\t\tVisit medical examiner<BR>
<BR>
Toxin Laboratory Procedure:<BR>
\tWear a gas mask regardless<BR>
\tGet an oxygen tank.<BR>
\tActivate internal atmosphere<BR>
<BR>
\tAfter<BR>
\t\tDecontaminate<BR>
\t\tVisit medical examiner<BR>
<BR>
Disaster Procedure:<BR>
\tFire:<BR>
\t\tActivate sector fire alarm.<BR>
\t\tMove to a safe area.<BR>
\t\tGet a fire suit<BR>
\t\tAfter:<BR>
\t\t\tAssess Damage<BR>
\t\t\tRepair damages<BR>
\t\t\tIf needed, Evacuate<BR>
\tMeteor Shower:<BR>
\t\tActivate fire alarm<BR>
\t\tMove to the back of ship<BR>
\t\tAfter<BR>
\t\t\tRepair damage<BR>
\t\t\tIf needed, Evacuate<BR>
\tAccidental Reentry:<BR>
\t\tActivate fire alrms in front of ship.<BR>
\t\tMove volatile matter to a fire proof area!<BR>
\t\tGet a fire suit.<BR>
\t\tStay secure until an emergency ship arrives.<BR>
<BR>
\t\tIf ship does not arrive-<BR>
\t\t\tEvacuate to a nearby safe area!"}
/obj/item/weapon/paper/Toxin
	name = "paper- 'Chemical Information'"
	info = {"Known Onboard Toxins:<BR>
\tGrade A Semi-Liquid Plasma:<BR>
\t\tHighly poisonous. You cannot sustain concentrations above 15 units.<BR>
\t\tA gas mask fails to filter plasma after 50 units.<BR>
\t\tWill attempt to diffuse like a gas.<BR>
\t\tFiltered by scrubbers.<BR>
\t\tThere is a bottled version which is very different<BR>
\t\t\tfrom the version found in canisters!<BR>
<BR>
\t\tWARNING: Highly Flammable. Keep away from heat sources<BR>
\t\texcept in a enclosed fire area!<BR>
\t\tWARNING: It is a crime to use this without authorization.<BR>
Known Onboard Anti-Toxin:<BR>
\tAnti-Toxin Type 01P: Works against Grade A Plasma.<BR>
\t\tBest if injected directly into bloodstream.<BR>
\t\tA full injection is in every regular Med-Kit.<BR>
\t\tSpecial toxin Kits hold around 7.<BR>
<BR>
Known Onboard Chemicals (other):<BR>
\tRejuvenation T#001:<BR>
\t\tEven 1 unit injected directly into the bloodstream<BR>
\t\t\twill cure paralysis and sleep toxins.<BR>
\t\tIf administered to a dying patient it will prevent<BR>
\t\t\tfurther damage for about units*3 seconds.<BR>
\t\t\tit will not cure them or allow them to be cured.<BR>
\t\tIt can be administeredd to a non-dying patient<BR>
\t\t\tbut the chemicals disappear just as fast.<BR>
\tSleep Toxin T#054:<BR>
\t\t5 units wilkl induce precisely 1 minute of sleep.<BR>
\t\t\tThe effects are cumulative.<BR>
\t\tWARNING: It is a crime to use this without authorization"}
/obj/item/weapon/paper/Internal
	name = "paper- 'Internal Atmosphere Operating Instructions'"
	info = {"Equipment:<BR>
\t1+ Tank(s) with appropriate atmosphere<BR>
\t1 Gas Mask w regulator (standard issue)<BR>
<BR>
Procedure:<BR>
\t1. Wear mask<BR>
\t2. Attach oxygen tank pipe to regulater (automatic))<BR>
\t3. Set internal!<BR>
<BR>
Notes:<BR>
\tDon't forget to stop internal when tank is low by<BR>
\tremoving internal!<BR>
<BR>
\tDo not use a tank that has a high concentration of toxins.<BR>
\tThe filters shut down on internal mode!<BR>
<BR>
\tWhen exiting a high danger environment it is advised<BR>
\tthat you exit through a decontamination zone!<BR>
<BR>
\tRefill a tank at a oxygen canister by equiping the tank (Double Click)<BR>
\tthen 'attacking' the canister (Double Click the canister)."}
/obj/item/weapon/paper/Map
	name = "paper- 'Station Blueprint'"
	info = {"First Blueprint<BR>
Note: Alterations have been made since this was drafted!<BR>
<PRE>
 /==========EA
         SA+|
ENG     MS CR
      /---/
     /--D TL
     +----+
M T\\ |S   |
|----+| OS+
L AC-/\\-/A</PRE>
<BR>
L: Lounge<BR>
ENG: Engine Area<BR>
M: Medical Bay<BR>
T: Toxin Laboratory<BR>
AC: Air Control<BR>
A: Shuttle Airlock<BR>
OS: Oxygen Storage<BR>
S: Storage<BR>
D: Decontamination<BR>
TL: Test Lab<BR>
MS: Medical Storage<BR>
CR: Control Room<BR>
SA: Staging Area<BR>
EA: Engine Airlock<BR>
ENG: Engine"}
/obj/item/weapon/f_card
	name = "Finger Print Card"
	icon_state = "f_print_card0"
	s_istate = "paper"
	w_class = 1
	var/amount = 10
/obj/item/weapon/f_card/examine()
	set src in view(2)
	..()
	usr << "\blue There are [amount] on the stack!"
	usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY><TT>[display()]</TT></BODY></HTML>", "window=[name]")
/obj/item/weapon/f_card/proc/display()
	if(fingerprints)
		var/dat = "<B>Fingerprints on Card</B><HR>"
		var/L = params2list(fingerprints)
		for(var/i in L)
			dat += "[i]<BR>"
		return dat
	else return "<B>There are no fingerprints on this card.</B>"
/obj/item/weapon/f_card/attack_hand(mob/user)
	if(user:r_hand == src || user:l_hand == src)
		add_fingerprint(user)
		var/F = new /obj/item/weapon/f_card(user)
		F:amount = 1
		amount--
		if(user:hand)
			user:l_hand = F
		else
			user:r_hand = F
		F:layer = 20
		F:add_fingerprint(user)
		if(amount < 1) del(src)
	else ..()
/obj/item/weapon/f_card/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/f_card))
		if(fingerprints || W:fingerprints) return
		if(amount == 10) return
		if(W:amount + amount > 10)
			amount = 10
			W:amount = W:amount + amount - 10
		else
			amount += W:amount
			del(W)
		add_fingerprint(user)
		if(W) W:add_fingerprint(user)
	else if(istype(W, /obj/item/weapon/pen))
		var/t = input(user, "Card Label:", "[name]") as text
		if(user:equipped() != W) return
		if(get_dist(src, usr) > 1 && loc != user) return
		t = html_encode(t)
		if(t)
			name = "FPrintC- '[t]'"
		else
			name = "Finger Print Card"
		W:add_fingerprint(user)
		add_fingerprint(user)
/obj/item/weapon/f_card/add_fingerprint()
	..()
	if(fingerprints)
		if(amount > 1)
			var/F = new /obj/item/weapon/f_card(ismob(loc) ? loc:loc : loc)
			F:amount = --amount
			amount = 1
		icon_state = "f_print_card1"
/obj/item/weapon/f_print_scanner
	name = "Finger Print Scanner"
	icon_state = "f_print_scanner0"
	w_class = 3
	s_istate = "electronic"
	flags = 450
	var/amount = 20
	var/printing = 0
/obj/item/weapon/f_print_scanner/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/f_card))
		if(W:fingerprints) return
		if(amount == 20) return
		if(W:amount + amount > 20)
			amount = 20
			W:amount = W:amount + amount - 20
		else
			amount += W:amount
			del(W)
		add_fingerprint(user)
		if(W) W:add_fingerprint(user)
/obj/item/weapon/f_print_scanner/attack_self(mob/user)
	printing = !printing
	icon_state = "f_print_scanner[printing]"
	add_fingerprint(user)
/obj/item/weapon/f_print_scanner/attack(mob/M, mob/user)
	if(!ismob(M) || (!istype(M:primary, /obj/dna) || (!istype(M, /mob/human) || M:gloves)))
		user << "\blue Unable to locate any fingerprints on [M]!"
		return 0
	else if(amount < 1 && printing)
		user << "\blue Fingerprints scanned on [M]. Need more cards to print."
		printing = 0
	icon_state = "f_print_scanner[printing]"
	if(printing)
		amount--
		var/obj/item/weapon/f_card/F = new /obj/item/weapon/f_card(user:loc)
		F:amount = 1
		F:fingerprints = md5(M:primary:uni_identity)
		F:icon_state = "f_print_card1"
		F:name = "FPrintC- '[M:name]'"
		user << "\blue Done printing."
	user << "\blue[M]'s Fingerprints: [md5(M:primary:uni_identity)]"
/obj/item/weapon/f_print_scanner/afterattack(A as mob|obj|turf|area, mob/user)
	add_fingerprint(user)
	if(!A:fingerprints)
		user << "\blue Unable to locate any fingerprints!"
		return 0
	else if(amount < 1 && printing)
		user << "\blue Fingerprints found. Need more cards to print."
		printing = 0
	icon_state = "f_print_scanner[printing]"
	if(printing)
		amount--
		var/F = new /obj/item/weapon/f_card(user:loc)
		F:amount = 1
		F:fingerprints = A:fingerprints
		F:icon_state = "f_print_card1"
		user << "\blue Done printing."
	var/L = params2list(A:fingerprints)
	user << "\blue Isolated [L:len] fingerprints."
	for(var/i in L)
		user << "\blue\t [i]"
/obj/item/weapon/healthanalyzer
	icon_state = "healthanalyzer"
	name = "Health Analyzer"
	flags = 450
	w_class = 1
/obj/item/weapon/healthanalyzer/attack(mob/M, mob/user)
	if(!istype(user, /mob/human) && (!ticker || ticker && ticker:mode != "monkey"))
		user << "\red You don't have the dexterity to do this!"
		return
	for(var/mob/O in view(M))
		O:show_message("\red[user] has analyzed [M]'s vitals!", 1)
	user:show_message("\blue Analyzing Results for [M]:\n\t Overall Status: [M:stat > 1 ? "dead" : "[M:health]% healthy"]", 1)
	user:show_message("\blue\t Damage Specifics: [M:oxyloss]-[M:toxloss]-[M:fireloss]-[M:bruteloss]", 1)
	user:show_message("\blue Key: Suffocation/Toxin/Burns/Brute", 1)
	if(M:rejuv) user:show_message("\blue Bloodstream Analysis located [M:rejuv] units of rejuvenation chemicals.", 1)
	add_fingerprint(user)
	return
/obj/item/weapon/analyzer
	desc = "Scans the environment gas levels."
	icon_state = "analyzer"
	w_class = 2
/obj/item/weapon/analyzer/attack_self(mob/user)
	if(user:stat) return
	if(!istype(user, /mob/human) && (!ticker || ticker && ticker:mode != "monkey"))
		user << "\red You don't have the dexterity to do this!"
		return
	var/T = user:loc
	if(!istype(T, /turf)) return
	if(locate(/obj/move) in T)
		T = locate(/obj/move) in T
	var/turf_total = T:co2 + T:oxygen + T:poison + T:sl_gas + T:n2
	turf_total = max(turf_total, 1)
	user:show_message("\blue<B>Results:</B>", 1)
	var/t = ""
	var/t1 = turf_total / 3600000 * 100
	if(90 < t1 < 110)
		user:show_message("\blue Air Pressure: [t1]%", 1)
	else
		user:show_message("\blue Air Pressure:\red[t1]%", 1)
	t1 = T:n2 / turf_total * 100
	t1 = round(t1, 0.001)
	if(60 < t1 < 80)
		t += "<font color=blue>Nitrogen: [t1]</font> "
	else
		t += "<font color=red>Nitrogen: [t1]</font> "
	t1 = T:oxygen / turf_total * 100
	t1 = round(t1, 0.001)
	if(20 < t1 < 24)
		t += "<font color=blue>Oxygen: [t1]</font> "
	else
		t += "<font color=red>Oxygen: [t1]</font> "
	t1 = T:poison / turf_total * 100
	t1 = round(t1, 0.001)
	if(t1 < 0.5)
		t += "<font color=blue>Plasma: [t1]</font> "
	else
		t += "<font color=red>Plasma: [t1]</font> "
	t1 = T:co2 / turf_total * 100
	t1 = round(t1, 0.001)
	if(t1 < 1)
		t += "<font color=blue>CO2: [t1]</font> "
	else
		t += "<font color=red>CO2: [t1]</font> "
	t1 = T:sl_gas / turf_total * 100
	t1 = round(t1, 0.001)
	if(t1 < 5)
		t += "<font color=blue>NO2: [t1]</font>"
	else
		t += "<font color=red>NO2: [t1]</font>"
	user:show_message(t, 1)

	user:show_message("\blue\t Temperature: [T:heat / turf_total + -254.7] C", 1)
	add_fingerprint(user)
/obj/item/weapon/analyzer/flags = 322
/obj/item/weapon/proc/dropped(mob/user)
/atom/movable/layer = 3

/obj/item/weapon/storage/proc/return_inv()
	var/L = list()
	for(var/obj/item/weapon/storage/S in src)
		L += S:return_inv()
	return L
/obj/item/weapon/storage/lglo_kit
	name = "Latex Gloves"
	icon_state = "lglo_kit"
	s_istate = "syringe_kit"
/obj/item/weapon/storage/lglo_kit/New()
	..()
	new /obj/item/weapon/clothing/gloves/latex(src)
	new /obj/item/weapon/clothing/gloves/latex(src)
	new /obj/item/weapon/clothing/gloves/latex(src)
	new /obj/item/weapon/clothing/gloves/latex(src)
	new /obj/item/weapon/clothing/gloves/latex(src)
	new /obj/item/weapon/clothing/gloves/latex(src)
	new /obj/item/weapon/clothing/gloves/latex(src)
/obj/item/weapon/storage/flashbang_kit
	icon_state = "flashbang_kit"
	name = "Flashbangs (WARNING)"
	desc = {"<FONT color=red><B>WARNING: Do not use without reading these preautions!</B></FONT>
<B>These devices are extremely dangerous and can cause blindness or deafness if used incorrectly.</B>
The chemicals contained in these devices have been tuned for maximal effectiveness and due to
extreme safety precuaiotn shave been incased in a tamper-proof pack. DO NOT ATTEMPT TO OPEN
FLASH WARNING: Do not use continually. Excercise extreme care when detonating in closed spaces.
	Make attemtps not to detonate withing range of 2 meters of the intended target. It is imperative
	that the targets visit a medical professional after usage. Damage to eyes increases extremely per
	use and according to range. Glasses with flash resistant filters DO NOT always work on high powered
	flash devices such as this. <B>EXERCISE CAUTION REGARDLESS OF CIRCUMSTANCES</B>
SOUND WARNING: Do not use continually. Visit a medical professional if hearing is lost.
	There is a slight chance per use of complete deafness. Exercise caution and restraint.
STUN WARNING: If the intended or unintended target is too close to detonation the resulting sound
	and flash have been known to cause extreme sensory overload resulting in temporary
	incapacitation.
<B>DO NOT USE CONTINUALLY</B>
Operating Directions:
	1. Pull detonnation pin. <B>ONCE THE PIN IS PULLED THE GRENADE CAN NOT BE DISARMED!</B>
	2. Throw grenade. <B>NEVER HOLD A LIVE FLASHBANG</B>
	3. The grenade will detonste 10 seconds hafter being primed. <B>EXCERCISE CAUTION</B>
	-<B>Never prime another grenade until after the first is detonated</B>
Note: Usage of this pyrotechnic device without authorization is an extreme offense and can
result in severe punishment upwards of <B>10 years in prison per use</B>.

Default 3 second wait till from prime to detonation. This can be switched with a screwdriver
to 10 seconds.

Copyright of Nanotrasen Industries- Military Armnaments Division
This device was created by Nanotrasen Labs a member of the Expert Advisor Corporation"}
	s_istate = "syringe_kit"
/obj/item/weapon/storage/flashbang_kit/New()
	..()
	new /obj/item/weapon/flashbang(src)
	new /obj/item/weapon/flashbang(src)
	new /obj/item/weapon/flashbang(src)
	new /obj/item/weapon/flashbang(src)
	new /obj/item/weapon/flashbang(src)
	new /obj/item/weapon/flashbang(src)
	new /obj/item/weapon/flashbang(src)
/obj/item/weapon/storage/stma_kit
	icon_state = "lglo_kit"
	s_istate = "syringe_kit"
	name = "Sterile Masks"
/obj/item/weapon/storage/stma_kit/New()
	..()
	new /obj/item/weapon/clothing/mask/surgical(src)
	new /obj/item/weapon/clothing/mask/surgical(src)
	new /obj/item/weapon/clothing/mask/surgical(src)
	new /obj/item/weapon/clothing/mask/surgical(src)
	new /obj/item/weapon/clothing/mask/surgical(src)
	new /obj/item/weapon/clothing/mask/surgical(src)
	new /obj/item/weapon/clothing/mask/surgical(src)
/obj/item/weapon/storage/gl_kit
	name = "Prescription Glasses"
	s_istate = "syringe_kit"
	icon_state = "id_kit"
/obj/item/weapon/storage/gl_kit/New()
	..()
	new /obj/item/weapon/clothing/glasses/regular(src)
	new /obj/item/weapon/clothing/glasses/regular(src)
	new /obj/item/weapon/clothing/glasses/regular(src)
	new /obj/item/weapon/clothing/glasses/regular(src)
	new /obj/item/weapon/clothing/glasses/regular(src)
	new /obj/item/weapon/clothing/glasses/regular(src)
	new /obj/item/weapon/clothing/glasses/regular(src)
/obj/item/weapon/storage/fcard_kit
	icon_state = "id_kit"
	name = "Fingerprint Cards"
	s_istate = "syringe_kit"
/obj/item/weapon/storage/fcard_kit/New()
	..()
	new /obj/item/weapon/f_card(src)
	new /obj/item/weapon/f_card(src)
	new /obj/item/weapon/f_card(src)
	new /obj/item/weapon/f_card(src)
	new /obj/item/weapon/f_card(src)
	new /obj/item/weapon/f_card(src)
	new /obj/item/weapon/f_card(src)
/obj/item/weapon/storage/id_kit
	s_istate = "syringe_kit"
	icon_state = "id_kit"
	name = "Spare IDs"
/obj/item/weapon/storage/id_kit/New()
	..()
	new /obj/item/weapon/card/id(src)
	new /obj/item/weapon/card/id(src)
	new /obj/item/weapon/card/id(src)
	new /obj/item/weapon/card/id(src)
	new /obj/item/weapon/card/id(src)
	new /obj/item/weapon/card/id(src)
	new /obj/item/weapon/card/id(src)
/obj/item/weapon/storage/box
	icon_state = "box"
	name = "Box"
	s_istate = "syringe_kit"
/obj/item/weapon/storage/handcuff_kit
	icon_state = "handcuff_kit"
	name = "Spare Handcuffs"
	s_istate = "syringe_kit"
/obj/item/weapon/storage/handcuff_kit/New()
	..()
	new /obj/item/weapon/handcuffs(src)
	new /obj/item/weapon/handcuffs(src)
	new /obj/item/weapon/handcuffs(src)
	new /obj/item/weapon/handcuffs(src)
	new /obj/item/weapon/handcuffs(src)
	new /obj/item/weapon/handcuffs(src)
	new /obj/item/weapon/handcuffs(src)

/obj/item/weapon/storage/disk_kit
	s_istate = "syringe_kit"
	icon_state = "id_kit"
	name = "Data Disks"
/obj/item/weapon/storage/disk_kit/disks/New()
	..()
	new /obj/item/weapon/card/data(src)
	new /obj/item/weapon/card/data(src)
	new /obj/item/weapon/card/data(src)
	new /obj/item/weapon/card/data(src)
	new /obj/item/weapon/card/data(src)
	new /obj/item/weapon/card/data(src)
	new /obj/item/weapon/card/data(src)

/obj/item/weapon/storage/disk_kit/disks2/New()
	..()
	spawn(2)
		for(var/obj/item/weapon/card/data/D in loc)
			D:loc = src
/obj/item/weapon/storage/backpack
	w_class = 4
/obj/item/weapon/storage/backpack/New()
	..()
	new /obj/item/weapon/storage/box(src)
/obj/item/weapon/storage/backpack/MouseDrop(obj/over_object)
	if(loc != usr) return
	if(istype(usr, /mob/human) || ticker && ticker:mode == "monkey")
		var/M = usr
		if(!istype(over_object, /obj/screen))
			return ..()
		if(!M:restrained() && (!M:stat && M:back == src))
			if(over_object:name == "r_hand")
				if(!M:r_hand)
					M:u_equip(src)
					M:r_hand = src
			else if(over_object:name == "l_hand")
				if(!M:l_hand)
					M:u_equip(src)
					M:l_hand = src
			M:UpdateClothing()
			add_fingerprint(usr)
/obj/item/weapon/storage/backpack
	icon_state = "backpack"
/obj/item/weapon/storage/backpack/attackby(obj/W, mob/user)
	if(contents:len >= 7) return
	if(W:w_class > 3) return
	var/t
	for(var/obj/item/weapon/O in src)
		t += O:w_class
	t += W:w_class
	if(t > 20)
		user << "You cannot fit the item inside. (Remove larger classed items)"
		return
	user:u_equip(W)
	W:loc = src
	if(user:client && user:s_active != src) user:client:screen -= W
	orient2hud(user)
	W:dropped()
	W:add_fingerprint(user)
	for(var/mob/O in view(user))
		O:show_message("\blue[user] has added [W] to [src]!", 1)
/obj/item/weapon/storage/attackby(obj/W, mob/user)
	if(contents:len >= 7) return
	if(W:w_class >= 3 || istype(W, /obj/item/weapon/storage)) return
	user:u_equip(W)
	W:loc = src
	if(user:client && user:s_active != src) user:client:screen -= W
	orient2hud(user)
	W:dropped()
	W:add_fingerprint(user)
	for(var/mob/O in view(user))
		O:show_message("\blue[user] has added [W] to [src]!", 1)
/obj/item/weapon/storage/proc/show_to(mob/user)
	user:client:screen -= boxes
	user:client:screen -= closer
	user:client:screen -= contents
	user:client:screen += boxes
	user:client:screen += closer
	user:client:screen += contents
	user:s_active = src
/obj/item/weapon/storage/proc/hide_from(mob/user)
	user:client:screen -= boxes
	user:client:screen -= closer
	user:client:screen -= contents
/obj/item/weapon/storage/proc/close(mob/user)
	hide_from(user)
	user:s_active = null
/obj/item/weapon/storage/proc/orient_objs(tx, ty, mx, my)
	var/cx = tx
	var/cy = ty
	boxes:screen_loc = "[tx],[ty] to [mx],[my]"
	for(var/obj/O in contents)
		O:screen_loc = "[cx],[cy]"
		O:layer = 20
		cx++
		if(cx > mx)
			cx = tx
			cy--
	closer:screen_loc = "[mx],[my]"
/obj/item/weapon/storage/dropped(mob/user)
	orient_objs(7, 8, 10, 7)
/obj/item/weapon/storage/proc/orient2hud(mob/user)
	if(src == user:l_hand)
		orient_objs(3, 11, 3, 4)
	else if(src == user:r_hand)
		orient_objs(1, 11, 1, 4)
	else if(src == user:back)
		orient_objs(4, 10, 4, 3)
	else orient_objs(7, 8, 10, 7)
/obj/item/weapon/storage/MouseDrop(over_object, src_location, over_location)
	..()
	if(over_object == usr && (get_dist(src, usr) <= 1 || usr.contents:Find(src)))
		if(usr.s_active)
			usr.s_active:close(usr)
		show_to(usr)
/obj/item/weapon/storage
	var/obj/screen/boxes
	var/obj/screen/closer
/obj/item/weapon/storage/attack_paw(mob/user)
	return attack_hand(user)
/obj/item/weapon/storage/attack_hand(mob/user)
	if(loc == user)
		if(user:s_active)
			user:s_active:close(user)
		show_to(user)
	else
		..()
		for(var/mob/M in range(1))
			if(M:s_active == src)
				close(M)
		orient2hud(user)
	add_fingerprint(user)
/obj/item/weapon/tile
	w_class = 3
/obj/item/weapon/storage/backpack/flags = 259
/obj/item/weapon/storage/New()
	boxes = new /obj/screen/storage()
	boxes:name = "storage"
	boxes:master = src
	boxes:icon_state = "block"
	boxes:screen_loc = "7,7 to 10,8"
	boxes:layer = 19
	closer = new /obj/screen/close()
	closer:master = src
	closer:icon_state = "x"
	closer:layer = 20
	spawn(5) orient_objs(7, 8, 10, 7)
/obj/item/weapon/storage/toolbox
	icon_state = "toolbox"
	flags = 322
	force = 8
	throwspeed = 4
	w_class = 4
/obj/item/weapon/storage/toolbox/New()
	..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/radio(src)
	new /obj/item/weapon/analyzer(src)
	new /obj/item/weapon/extinguisher(src)
	new /obj/item/weapon/wirecutters(src)
/obj/item/weapon/storage/toolbox/attack(mob/M, mob/user)
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
			O:show_message("\red<B>[M] has been knocked unconscious!</B>", 1, "\red You hear someone fall.", 2)
		M:show_message("\red<B>This was a [time * 100 / 120]% hit. Roleplay it! (personality/memory change if the hit was severe enough)</B>")



/obj/item/weapon/storage
	w_class = 3
/obj/item/weapon/tile
	icon_state = "tile"
	name = "steel floor tile"
	var/amount = 1
/obj/item/weapon/tile/New()
	pixel_x = rand(1, 14)
	pixel_y = rand(1, 14)
/obj/item/weapon/tile/attack_hand(mob/user)
	if(user:r_hand == src || user:l_hand == src)
		add_fingerprint(user)
		var/F = new /obj/item/weapon/tile(user)
		F:amount = 1
		amount--
		if(user:hand)
			user:l_hand = F
		else
			user:r_hand = F
		F:layer = 20
		F:add_fingerprint(user)
		if(amount < 1) del(src)
	else ..()
/obj/item/weapon/tile/proc/build(turf/S)
	var/A = S:loc
	var/W = new /turf/station/floor(locate(S:x, S:y, S:z))
	if(istype(A, /area))
		A:contents -= W
		A:contents += W
	W:oxygen = 0
/obj/item/weapon/tile/attack_self(mob/user)
	if(usr.stat) return
	var/T = user:loc
	if(!istype(T, /turf))
		user << "\blue You must be on the ground!"
		return
	else
		var/S = T
		if(!istype(S, /turf/space))
			user << "You cannot build on or repair this turf!"
			return
		else
			build(S)
			amount--
	if(amount < 1)
		user:u_equip(src)
		del(src)
	add_fingerprint(user)
/obj/item/weapon/tile/attackby(obj/W, mob/user)
	if(!istype(W, /obj/item/weapon/tile)) return
	if(W:amount == 10) return
	W:add_fingerprint(user)
	if(W:amount + amount > 10)
		amount = W:amount + amount - 10
		W:amount = 10
	else
		W:amount += amount
		del(src)
/obj/item/weapon/tile/examine()
	set src in view(1)
	..()
	usr << "There are [amount] tile\s left on the stack."
/obj/item/weapon/tile
/obj/item/weapon/igniter
	icon_state = "igniter"
	var/status = 1
/obj/item/weapon/igniter/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/radio/signaler) && !status)
		var/S = W
		if(!S:b_stat) return
		var/R = new /obj/item/weapon/assembly/rad_ignite(user)
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
		add_fingerprint(user)
	else if(istype(W, /obj/item/weapon/prox_sensor) && !status)
		var/R = new /obj/item/weapon/assembly/prox_ignite(user)
		W:loc = R
		R:part1 = W

		W:layer = initial(W:layer)
		if(user:client) user:client:screen -= W

		if(user:r_hand == W)
			user:u_equip(W)
			user:r_hand = R
		else
			user:u_equip(W)
			user:l_hand = R
		W:master = R
		master = R
		layer = initial(layer)
		user:u_equip(src)
		if(user:client) user:client:screen -= src
		loc = R
		R:part2 = src
		R:layer = 20
		R:loc = user
		add_fingerprint(user)
	if(!istype(W, /obj/item/weapon/screwdriver)) return
	status = !status
	if(status)
		user:show_message("\blue The igniter is ready!")
	else user:show_message("\blue The igniter can now be attached!")
	add_fingerprint(user)
/obj/item/weapon/igniter/attack_self(mob/user)
	add_fingerprint(user)
	spawn(5) ignite()
/obj/item/weapon/igniter/proc/ignite()
	if(status)
		var/T = loc
		if(master) T = master:loc
		if(!istype(T, /turf)) T = T:loc
		if(!istype(T, /turf)) T = T:loc
		if(locate(/obj/move) in T) T = locate(/obj/move) in T
		else if(!istype(T, /turf)) return
		if(T:firelevel < 2000000) T:firelevel = T:poison
/obj/item/weapon/igniter/examine()
	set src in view()
	..()
	if(get_dist(src, usr) <= 1 || loc == usr)
		if(status)
			usr.show_message("The igniter is ready!")
		else usr.show_message("The igniter can be attached!")
/obj/item/weapon/storage/firstaid
	name = "First-Aid"
/obj/item/weapon/radio
	icon_state = "radio"
	name = "Station Bounced Radio"
	suffix = "\[3\]"
	text = "R"
	var/freq = 145.9
	flags = 450
	throwspeed = 9
	w_class = 2
/obj/item/weapon/radio/electropack
	icon_state = "electropack0"
	var/code = 2
	var/on = 0
	freq = 144.9
	flags = 323
	s_istate = "electropack"
	name = "Electropack"
	var/e_pads = 0
/obj/item/weapon/radio/electropack/examine()
	set src in view()
	..()
	if(get_dist(src, usr) <= 1 || loc == usr)
		if(e_pads) usr << "\blue The electric pads are exposed!"
/obj/item/weapon/radio/electropack/attack_paw(mob/user)
	return attack_hand(user)
/obj/item/weapon/radio/electropack/attack_hand(mob/user)
	if(src == user:back)
		user << "\blue You need help taking this off!"
		return
	else ..()
/obj/item/weapon/radio/electropack/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/screwdriver))
		e_pads = !e_pads
		if(e_pads) user:show_message("\blue The electric pads have been exposed!")
		else
			user:show_message("\blue The electric pads have been reinserted!")
		add_fingerprint(user)
	else if(istype(W, /obj/item/weapon/clothing/head/helmet))
		var/A = new /obj/item/weapon/assembly/shock_kit(user)
		W:loc = A
		A:part1 = W

		W:layer = initial(W:layer)
		if(user:client) user:client:screen -= W

		if(user:r_hand == W)
			user:u_equip(W)
			user:r_hand = A
		else
			user:u_equip(W)
			user:l_hand = A
		W:master = A
		master = A
		layer = initial(layer)
		user:u_equip(src)
		if(user:client) user:client:screen -= src
		loc = A
		A:part2 = src
		A:layer = 20
		add_fingerprint(user)
		A:add_fingerprint(user)
/obj/item/weapon/radio/electropack/Topic(href, href_list)
	if(usr.stat) return
	if(istype(usr, /mob/human) && ((!ticker || ticker && ticker:mode != "monkey") && usr.contents:Find(src)) || (usr.contents:Find(master) || get_dist(src, usr) <= 1 && istype(loc, /turf)))
		usr.machine = src
		if(href_list["freq"])
			freq += text2num(href_list["freq"])
			if(freq * 10 % 2 == 0) freq += 0.1
			freq = min(148.9, freq)
			freq = max(144.1, freq)
		else if(href_list["code"])
			code += text2num(href_list["code"])
			code = round(code)
			code = min(100, code)
			code = max(1, code)
		else if(href_list["power"])
			on = !on
			icon_state = "electropack[on]"
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
		usr << browse(null, "window=radio")
		return
/obj/item/weapon/radio/electropack/accept_rad(obj/R, message)
	if(istype(R, /obj/item/weapon/radio/signaler) && (R:freq == freq && R:code == code))
		return 1
	else return null
/obj/item/weapon/radio/electropack/r_signal()
	if(ismob(loc) && on)
		var/M = loc
		var/T = M:loc
		if(istype(T, /turf) || istype(T, /obj/move))
			if(M:last_move) step(M, M:last_move)
		M:show_message("\red<B>You feel a sharp shock!</B>")
		if(M:weakened < 10) M:weakened = 10
	if(master && wires & 1)
		master:r_signal(1)
/obj/item/weapon/radio/electropack/attack_self(mob/user, flag1)
	if(!istype(user, /mob/human)) return
	user:machine = src
	var/dat = {"<TT><A href='?src=\ref[src];power=1'>[on ? "Turn Off" : "Turn On"]</A><BR>
<B>Frequency/Code</B> for electropack:<BR>
Frequency: <A href='?src=\ref[src];freq=-1'>-</A><A href='?src=\ref[src];freq=-0.2'>-</A> [freq] <A href='?src=\ref[src];freq=0.2'>+</A><A href='?src=\ref[src];freq=1'>+</A><BR>
Code: <A href='?src=\ref[src];code=-5'>-</A><A href='?src=\ref[src];code=-1'>-</A> [code] <A href='?src=\ref[src];code=1'>+</A><A href='?src=\ref[src];code=5'>+</A><BR>
</TT>"}
	user << browse(dat, "window=radio")
/obj/item/weapon/igniter/flags = 322
/obj/item/weapon/radio/proc/accept_rad(obj/R, message)
	if(R:freq == freq && message)
		return 1
	else return null
/obj/item/weapon/radio/proc/r_signal()
/obj/item/weapon/radio/proc/send_crackle()
	if(listening && wires & 2) return view(3, loc)
/obj/item/weapon/radio/proc/sendm(msg)
	if(listening && wires & 2) return view(1, loc)
/obj/item/weapon/radio{var/wires = 7; var/b_stat = 0}
/obj/item/weapon/igniter/s_istate = "electronic"
/obj/item/weapon/tile/throwspeed = 5
/obj/item/weapon/tile/force = 6
/obj/item/weapon/tile/throwforce = 7
/obj/item/weapon/radio/examine()
	set src in view()
	..()
	if(get_dist(src, usr) <= 1 || loc == usr)
		if(b_stat) usr.show_message("\blue The radio can be attached and modified!")
		else
			usr.show_message("\blue The radio can not be modified or attached!")
/obj/item/weapon/radio/s_istate = "electronic"
/obj/item/weapon/radio/attackby(obj/W, mob/user)
	user:machine = src
	if(!istype(W, /obj/item/weapon/screwdriver)) return
	b_stat = !b_stat
	if(b_stat) user:show_message("\blue The radio can now be attached and modified!")
	else
		user:show_message("\blue The radio can no longer be modified or attached!")
	for(var/mob/M in view(1, src))
		if(M:client) attack_self(M)
	add_fingerprint(user)
/obj/item/weapon/radio/headset
	text = "RH"; icon_state = "headset"
	name = "Radio Headset"
/obj/item/weapon/radio/beacon
	name = "Tracking Beacon"
	icon_state = "beacon"
	var/code = "beacon"
/obj/item/weapon/radio/beacon/hear_talk()
	return
/obj/item/weapon/radio/beacon/sendm() return null
/obj/item/weapon/radio/beacon/send_crackle() return null
/obj/item/weapon/radio/beacon/text = "B"
/obj/item/weapon/radio/beacon/verb/alter_signal(t as text)
	set src in usr
	if(usr.canmove && !usr.restrained())
		code = t
	if(!code) code = "beacon"
	add_fingerprint(usr)

/obj/item/weapon/radio/signaler
	name = "Remote Signaling Device"
	icon_state = "signaler"
	text = "S"
	w_class = 1
	freq = 145.7
	var/code = 30
/obj/item/weapon/radio/signaler/accept_rad(obj/R, message)
	if(istype(R, /obj/item/weapon/radio/signaler) && (R:freq == freq && R:code == code))
		return 1
	else return null
/obj/item/weapon/radio/signaler/examine()
	set src in view()
	..()
	if(get_dist(src, usr) <= 1 || loc == usr)
		if(b_stat) usr.show_message("\blue The signaler can be attached and modified!")
		else
			usr.show_message("\blue The signaler can not be modified or attached!")
/obj/item/weapon/radio/signaler/attack_self(mob/user, flag1)
	user:machine = src
	var/t1
	if(b_stat && !flag1)
		t1 = {"-------<BR>
Green Wire: [wires & 4 ? "<A href='?src=\ref[src];wires=4'>Cut Wire</A>" : "<A href='?src=\ref[src];wires=4'>Mend Wire</A>"]<BR>
Red Wire:   [wires & 2 ? "<A href='?src=\ref[src];wires=2'>Cut Wire</A>" : "<A href='?src=\ref[src];wires=2'>Mend Wire</A>"]<BR>
Blue Wire:  [wires & 1 ? "<A href='?src=\ref[src];wires=1'>Cut Wire</A>" : "<A href='?src=\ref[src];wires=1'>Mend Wire</A>"]<BR>
"}
	else
		t1 = "-------"
	var/dat = {"<TT>Speaker: [listening ? "<A href='?src=\ref[src];listen=0'>Engaged</A>" : "<A href='?src=\ref[src];listen=1'>Disengaged</A>"]<BR>
<A href='?src=\ref[src];send=1'>Send Signal</A><BR>
<B>Frequency/Code</B> for signaler:<BR>
Frequency: <A href='?src=\ref[src];freq=-1'>-</A><A href='?src=\ref[src];freq=-0.2'>-</A> [freq] <A href='?src=\ref[src];freq=0.2'>+</A><A href='?src=\ref[src];freq=1'>+</A><BR>
Code: <A href='?src=\ref[src];code=-5'>-</A><A href='?src=\ref[src];code=-1'>-</A> [code] <A href='?src=\ref[src];code=1'>+</A><A href='?src=\ref[src];code=5'>+</A><BR>
[t1]</TT>"}
	user << browse(dat, "window=radio")
/obj/item/weapon/radio/signaler/hear_talk() return
/obj/item/weapon/radio/signaler/sendm() return
/obj/item/weapon/radio/signaler/send_crackle() return
/obj/item/weapon/radio/signaler/r_signal(signal)
	if(!(wires & 2)) return
	if(master && wires & 1)
		master:r_signal(signal)
	for(var/mob/O in view(1, loc))
		O:show_message("\icon[src] *beep* *beep*", 3, "*beep* *beep*", 2)
/obj/item/weapon/radio/signaler/proc/s_signal(signal = 1)
	if(!(wires & 4)) return
	for(var/obj/item/weapon/radio/R in world)
		if(R:accept_rad(src))
			spawn(0) if(R) R:r_signal(signal)
/obj/item/weapon/radio/signaler/Topic(href, href_list)
	if(usr.stat) return
	if(usr.contents:Find(src) || (usr.contents:Find(master) || get_dist(src, usr) <= 1 && istype(loc, /turf)))
		usr.machine = src
		if(href_list["freq"])
			freq += text2num(href_list["freq"])
			if(freq * 10 % 2 == 0) freq += 0.1
			freq = min(148.9, freq)
			freq = max(144.1, freq)
		else if(href_list["code"])
			code += text2num(href_list["code"])
			code = round(code)
			code = min(100, code)
			code = max(1, code)
		else if(href_list["send"])
			var/t1 = round(text2num(href_list["send"]))
			spawn(0) s_signal(t1)
		else if(href_list["listen"])
			listening = text2num(href_list["listen"])
		else if(href_list["wires"])
			var/t1 = text2num(href_list["wires"])
			if(!istype(usr.equipped(), /obj/item/weapon/wirecutters)) return
			if(!b_stat && !master) return
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
		add_fingerprint(usr)
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
		usr << browse(null, "window=radio")
		return

/obj/item/weapon/radio/intercom
	icon_state = "intercom"
	name = "Station Intercom (Radio)"
	density = 1
	text = "I"
	anchored = 1
/obj/item/weapon/radio/intercom/attack_paw(mob/user)
	if(ticker && ticker:mode == "monkey")
		return attack_hand(user)
/obj/item/weapon/radio/intercom/attack_hand(mob/user)
	add_fingerprint(user)
	spawn(0) attack_self(user)
/obj/item/weapon/radio/intercom/send_crackle()
	if(listening) return list()
/obj/item/weapon/radio/intercom/sendm(msg)
	if(listening) return view(7, loc)










/obj/item/weapon/radio/attack_self(mob/user)
	user:machine = src
	var/t1
	if(b_stat)
		t1 = {"-------<BR>
Green Wire: [wires & 4 ? "<A href='?src=\ref[src];wires=4'>Cut Wire</A>" : "<A href='?src=\ref[src];wires=4'>Mend Wire</A>"]<BR>
Red Wire:   [wires & 2 ? "<A href='?src=\ref[src];wires=2'>Cut Wire</A>" : "<A href='?src=\ref[src];wires=2'>Mend Wire</A>"]<BR>
Blue Wire:  [wires & 1 ? "<A href='?src=\ref[src];wires=1'>Cut Wire</A>" : "<A href='?src=\ref[src];wires=1'>Mend Wire</A>"]<BR>
"}
	else
		t1 = "-------"
	var/dat = {"<TT>Microphone: [broadcasting ? "<A href='?src=\ref[src];talk=0'>Engaged</A>" : "<A href='?src=\ref[src];talk=1'>Disengaged</A>"]<BR>
Speaker: [listening ? "<A href='?src=\ref[src];listen=0'>Engaged</A>" : "<A href='?src=\ref[src];listen=1'>Disengaged</A>"]<BR>
Frequency: <A href='?src=\ref[src];freq=-1'>-</A><A href='?src=\ref[src];freq=-0.2'>-</A> [freq] <A href='?src=\ref[src];freq=0.2'>+</A><A href='?src=\ref[src];freq=1'>+</A><BR>
[t1]</TT>"}







	user << browse(dat, "window=radio")

/obj/item/weapon/radio{var/broadcasting; var/listening = 1}
/obj/item/weapon/radio/Topic(href, href_list)
	if(usr.stat) return
	if(usr.contents:Find(src) || get_dist(src, usr) <= 1 && istype(loc, /turf))
		usr.machine = src
		if(href_list["freq"])
			freq += text2num(href_list["freq"])
			if(freq * 10 % 2 == 0) freq += 0.1
			freq = min(148.9, freq)
			freq = max(144.1, freq)
		else if(href_list["talk"])
			broadcasting = text2num(href_list["talk"])
		else if(href_list["listen"])
			listening = text2num(href_list["listen"])
		else if(href_list["wires"])
			var/t1 = text2num(href_list["wires"])
			if(!istype(usr.equipped(), /obj/item/weapon/wirecutters)) return
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
		usr << browse(null, "window=radio")
		return
/obj/item/weapon/radio/talk_into(mob/M, msg)
	if(!(wires & 4)) return
	var/receive = list()
	var/crackle = list()
	for(var/obj/item/weapon/radio/R in world)
		if((freq == 0 || R:accept_rad(src, msg)) && freq != 5)
			for(var/mob/i in R:sendm(msg))
				receive -= i
				receive += i
			for(var/mob/i in R:send_crackle())
				crackle -= i
				crackle += i
	for(var/mob/i in receive)
		crackle -= i
	for(var/mob/O in crackle)
		O:show_message("\icon[src] <I>Crackle,Crackle</I>", 2)
	if(istype(M, /mob/human))
		for(var/mob/O in receive)
			if(istype(O, /mob/human))
				O:show_message("<B>[M:rname]-\icon[src]\[[freq]\]-broadcasts</B>: <I>[msg]</I>", 2)
			else
				O:show_message("<B>[M:rname]-\icon[src]\[[freq]\]-broadcasts</B>: <I>[stars(msg)]</I>", 2)
		if(freq == 5)
			for(var/mob/O in receive)
				if(istype(O, /mob/human))
					O:show_message("<B>[M:rname]-\icon[src]\[[freq]\]-broadcasts (over PA)</B>: <I>[msg]</I>", 2)
				else
					O:show_message("<B>[M:rname]-\icon[src]\[[freq]\]-broadcasts (over PA)</B>: <I>[stars(msg)]</I>", 2)
	else
		for(var/mob/O in receive)
			if(istype(O, M))
				O:show_message("<B>The monkey-\icon[src]\[[freq]\]-broadcasts</B>: <I>[msg]</I>", 2)
			else
				O:show_message("<B>The monkey-\icon[src]\[[freq]\]-broadcasts</B>: chimpering", 2)
		if(freq == 5)
			for(var/mob/O in receive)
				if(istype(O, M))
					O:show_message("<B>The monkey-\icon[src]\[[freq]\]-broadcasts (over PA)</B>: <I>[msg]</I>", 2)
				else
					O:show_message("<B>The monkey-\icon[src]\[[freq]\]-broadcasts (over PA)</B>: chimpering", 2)
/obj/item/weapon/radio/hear_talk(mob/M, msg)
	if(broadcasting) talk_into(M, msg)

/obj/item/weapon/shard
	icon = 'shards.dmi'
	w_class = 4
	force = 7
	damtype = "brute"
	throwforce = 10
	icon_state = "large"
	s_istate = "shard-glass"
/obj/item/weapon/shard/Bump()
	if(prob(20)) force = 15
	else force = 4
	..()
/obj/item/weapon/shard/New()
	icon_state = pick("large", "medium", "small")
	switch(icon_state)
		if("small")
			pixel_x = rand(1, 18)
			pixel_y = rand(1, 18)
		if("medium")
			pixel_x = rand(1, 16)
			pixel_y = rand(1, 16)
		if("large")
			pixel_x = rand(1, 10)
			pixel_y = rand(1, 5)
/obj/item/weapon/shard/attackby(obj/W, mob/user)
	..()
	if(!istype(W, /obj/item/weapon/weldingtool)) return
	new /obj/item/weapon/sheet/glass(user:loc)
	del(src)
/obj/item/weapon/proc/afterattack()
	return
/obj/item/weapon/proc/attack(mob/M, mob/user)
	for(var/mob/O in view(M))
		O:show_message("\red<B>[M] has been attacked with [src][user ? " by [user]." : "."] </B>", 1)
	var/power = force
	if(istype(M, /mob/human))
		var/H = M
		if(istype(H:wear_suit, /obj/item/weapon/clothing/suit/armor))
			if(prob(40))
				H:show_message("\red Your armor deflects the blow!", 4)
				return
			else if(prob(40) && damtype == "brute")
				H:show_message("\red Your armor only softens the blow!", 4)
				if(prob(20)) power = power / 2
				power = power / 2
		else if(istype(H:wear_suit, /obj/item/weapon/clothing/suit/swat_suit))
			if(prob(70))
				H:show_message("\red Your armor deflects the blow!", 4)
				return
			else if(prob(20) && damtype == "brute")
				H:show_message("\red Your armor only softens the blow!", 4)
				if(prob(20)) power = power / 2
				power = power / 2
	if(M:health >= -10)
		switch(damtype)
			if("brute")
				M:bruteloss += power
			if("toxin")
				M:toxloss += power
			if("fire")
				M:fireloss += power
		M:health = 100 - M:oxyloss - M:toxloss - M:fireloss - M:bruteloss
	add_fingerprint(user)








/obj/item/weapon
	var/health
	var/burn_point
	var/burning
	var/master
	icon = 'items.dmi'
	flags = 258
	throwspeed = 7
	flags = 258
	weight = 500000
/obj/item/weapon/Bump(mob/M)
	..()
	if(throwing)
		throwing = 0
		density = 0
		if(istype(M, /obj))
			var/O = M
			for(var/mob/B in view(M))
				B:show_message("\red[M] has been hit by [src].", 1)
			O:hitby(src)
		if(!istype(M, /mob)) return
		for(var/mob/O in view(M))
			O:show_message("\red[M] has been hit by [src].", 1)
		if(M:health > -100)
			M:bruteloss += throwforce
			M:health = 100 - M:oxyloss - M:toxloss - M:fireloss - M:bruteloss
/obj/item/weapon/crowbar
	flags = 322
	force = 5
	throwforce = 7
	icon_state = "crowbar"
	s_istate = "wrench"
	w_class = 2
/obj/item/weapon/crowbar/attack(mob/M, mob/user)
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
			O:show_message("\red<B>[M] has been knocked unconscious!</B>", 1, "\red You hear someone fall.", 2)
		M:show_message("\red<B>This was a [time * 100 / 120]% hit. Roleplay it! (personality/memory change if the hit was severe enough)</B>")
/obj/item/weapon/wrench
	icon_state = "wrench"
	flags = 322
	force = 5
	throwforce = 7
	w_class = 2
/obj/item/weapon/wrench/New()
	if(prob(75))
		pixel_x = rand(0, 16)
/obj/item/weapon/wrench/attack(mob/M, mob/user)
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
			O:show_message("\red<B>[M] has been knocked unconscious!</B>", 1, "\red You hear someone fall.", 2)
		M:show_message("\red<B>This was a [time * 100 / 120]% hit. Roleplay it! (personality/memory change if the hit was severe enough)</B>")
/obj/item/weapon/screwdriver
	icon_state = "screwdriver"
	flags = 322
	force = 5
	w_class = 2
	throwforce = 5
	throwspeed = 15
/obj/item/weapon/screwdriver/New()
	if(prob(75))
		pixel_y = rand(0, 16)



/obj/item/weapon/dropper
	icon_state = "dropper_0"; var/obj/substance/chemical/chem; var/mode = "inject"
/obj/item/weapon/dropper/attack_paw(mob/user)
	return attack_hand(user)
/obj/item/weapon/dropper/attack_hand()
	..()
	update_is()
/obj/item/weapon/dropper/proc/update_is()
	var/t1 = round(chem:contains())
	if(istype(loc, /mob))
		if(mode == "inject")
			icon_state = "dropper_[t1]_I"
		else
			icon_state = "dropper_[t1]_d"
	else icon_state = "dropper_[t1]"
	s_istate = "dropper"
/obj/item/weapon/dropper/dropped()
	..()
	update_is()

/obj/item/weapon/dropper/attack_self()
	if(mode == "inject")
		mode = "draw"
	else
		mode = "inject"
	update_is()
/obj/item/weapon/dropper/New()
	chem = new /obj/substance/chemical()
	chem:maximum = 5
	..()
/obj/item/weapon/dropper/attack(mob/M, mob/user)
	if(!istype(M, /mob)) return
	if(!istype(user, /mob/human) && (!ticker || ticker && ticker:mode != "monkey"))
		user << "\red You don't have the dexterity to do this!"
		return
	if(user)
		for(var/mob/O in view(M))
			O:show_message("\red[M] has been eyedropped with [src] by [user].", 1)
		var/amount = chem:dropper_mob(M, 1)
		update_is()
		user:show_message("\red You drop [amount] units into [M]'s eyes. The droper contains [chem:contains()] units.")
		add_fingerprint(user)
/obj/item/weapon/dropper
	throwspeed = 5
	w_class = 1
/obj/item/weapon/syringe/icon_state = "syringe_0"
/obj/item/weapon/syringe{var/chem; var/mode = "inject"}
/obj/item/weapon/syringe/attack_paw(mob/user)
	return attack_hand(user)
/obj/item/weapon/syringe/attack_hand()
	..()
	update_is()
/obj/item/weapon/syringe/proc/update_is()
	var/t1 = round(chem:contains(), 5)
	if(istype(loc, /mob))
		if(mode == "inject")
			icon_state = "syringe_[t1]_I"
		else
			icon_state = "syringe_[t1]_d"
	else icon_state = "syringe_[t1]"
	s_istate = "syringe_[t1]"
/obj/item/weapon/syringe/dropped()
	..()
	update_is()

/obj/item/weapon/syringe/attack_self()
	if(mode == "inject")
		mode = "draw"
	else
		mode = "inject"
	update_is()
/obj/item/weapon/syringe/New()
	chem = new /obj/substance/chemical()
	chem:maximum = 15
	..()




















/obj/item/weapon/syringe
	var/s_time = 1
	throwspeed = 5
	w_class = 1
/obj/item/weapon/brutepack
	icon_state = "brutepack"
	name = "Bruise Pack"
/obj/item/weapon/syringe/proc/inject(mob/M)
	var/amount = chem:transfer_mob(M, 5)
	update_is()
	return amount

/obj/item/weapon/syringe/attack(mob/M, mob/user)
	if(!istype(M, /mob)) return
	if(!istype(user, /mob/human) && (!ticker || ticker && ticker:mode != "monkey"))
		user << "\red You don't have the dexterity to do this!"
		return
	if(user)
		if(istype(M, /mob/human))
			var/obj/equip_e/human/O = new /obj/equip_e/human()
			O:source = user
			O:target = M
			O:item = src
			O:s_loc = user:loc
			O:t_loc = M:loc
			O:place = "syringe"
			M:requests += O
			spawn(0) O:process()
		else
			for(var/mob/O in view(M))
				O:show_message("\red[M] has been injected with [src] by [user].", 1)
			var/amount = chem:transfer_mob(M, 5)
			update_is()
			user:show_message("\red You inject [amount] units into the [M]. The syringe contains [chem:contains()] units.")




/obj/item/weapon/storage/firstaid/fire
	icon_state = "firstaid-ointment"
	name = "Fire First Aid"
/obj/item/weapon/storage/firstaid/fire/New()
	..()
	new /obj/item/weapon/ointment(src)
	new /obj/item/weapon/ointment(src)
	new /obj/item/weapon/ointment(src)
	new /obj/item/weapon/ointment(src)
	new /obj/item/weapon/healthanalyzer(src)
	var/S = new /obj/item/weapon/syringe(src)
	S:chem:rejuv = 15
	S:icon_state = "syringe_15"
/obj/item/weapon/storage/firstaid/syringes
	icon_state = "syringe_kit"
	name = "Syringes (Biohazard Alert)"
/obj/item/weapon/storage/firstaid/syringes/New()
	..()
	new /obj/item/weapon/syringe(src)
	new /obj/item/weapon/syringe(src)
	new /obj/item/weapon/syringe(src)
	new /obj/item/weapon/syringe(src)
	new /obj/item/weapon/syringe(src)
	new /obj/item/weapon/syringe(src)
	new /obj/item/weapon/syringe(src)
/obj/item/weapon/storage/firstaid/regular
	icon_state = "firstaid"
/obj/item/weapon/storage/firstaid/regular/New()
	..()
	new /obj/item/weapon/brutepack(src)
	new /obj/item/weapon/brutepack(src)
	new /obj/item/weapon/brutepack(src)
	new /obj/item/weapon/ointment(src)
	new /obj/item/weapon/ointment(src)
	new /obj/item/weapon/healthanalyzer(src)
	var/S = new /obj/item/weapon/syringe(src)
	S:chem:rejuv = 15
	S:icon_state = "syringe_15"
/obj/item/weapon/storage/firstaid/toxin
	icon_state = "firstaid-toxin"
	name = "Toxin First Aid"
/obj/item/weapon/storage/firstaid/toxin/New()
	..()
	new /obj/item/weapon/pill_canister/antitoxin(src)
	new /obj/item/weapon/pill_canister/antitoxin(src)
	for(var/t = 1, t <= 4, t++)
		var/S = new /obj/item/weapon/syringe(src)
		S:chem:pl_coag = 15
		S:icon_state = "syringe_15"
	new /obj/item/weapon/healthanalyzer(src)
/obj/item/weapon/storage/firstaid/attackby(obj/W, mob/user)
	if(contents:len >= 7) return
	if(W:w_class >= 2 || istype(W, /obj/item/weapon/storage)) return
	..()


/obj/item/weapon/storage/firstaid
	throwspeed = 8
/obj/item/weapon/brutepack
	var/amount = 5
/obj/item/weapon/brutepack/attack_hand(mob/user)
	if(user:r_hand == src || user:l_hand == src)
		add_fingerprint(user)
		var/F = new /obj/item/weapon/brutepack(user)
		F:amount = 1
		amount--
		if(user:hand)
			user:l_hand = F
		else
			user:r_hand = F
		F:layer = 20
		F:add_fingerprint(user)
		if(amount < 1) del(src)
	else ..()
/obj/item/weapon/brutepack/attack(mob/M, mob/user)
	if(M:health < 0) return
	if(!istype(user, /mob/human) && (!ticker || ticker && ticker:mode != "monkey"))
		user << "\red You don't have the dexterity to do this!"
		return
	if(user)
		for(var/mob/O in view(M))
			O:show_message("\red[M] has been applied with [src] by [user]", 1)
	if(60 >= M:bruteloss)
		M:bruteloss = 0
	else
		M:bruteloss -= 60
	M:health = 100 - M:oxyloss - M:toxloss - M:fireloss - M:bruteloss
	amount--
/obj/item/weapon/brutepack/examine()
	set src in view(1)
	..()
	usr << "\blue there are [amount] bruise pack\s left on the stack!"
	if(amount <= 0) del(src)
/obj/item/weapon/brutepack/attackby(obj/W, mob/user)
	if(!istype(W, /obj/item/weapon/brutepack)) return
	if(amount == 5) return
	if(W:amount + amount > 5)
		amount = 5
		W:amount = W:amount + amount - 5
	else
		amount += W:amount
		del(W)

/obj/item/weapon/hand_tele{icon_state = "hand_tele"; s_istate = "electronic"; w_class = 2}


/obj/item/weapon/hand_tele/attack_self(mob/user)
	var/L = list()
	for(var/obj/machinery/computer/teleporter/R in world)
		L["[R:id][R:locked ? " (Active)" : " (Inactive)"]"] = R:locked
	var/t1 = input(user, "Please select a location to lock in.", "Locking Computer") in L
	if(user:equipped() != src || (user:stat || user:restrained())) return
	var/T = L[t1]
	for(var/mob/O in oview(user))
		O:show_message("\blue Locked In", 2)
	var/P = new /obj/portal(get_turf(src))
	P:target = T
	add_fingerprint(user)
/obj/item/weapon/brutepack
	w_class = 1
/obj/item/weapon/ointment
	icon_state = "ointment"
	var/amount = 5

/obj/item/weapon/ointment/attack_hand(mob/user)
	if(user:r_hand == src || user:l_hand == src)
		add_fingerprint(user)
		var/F = new /obj/item/weapon/ointment(user)
		F:amount = 1
		amount--
		if(user:hand)
			user:l_hand = F
		else
			user:r_hand = F
		F:layer = 20
		F:add_fingerprint(user)
		if(amount < 1) del(src)
	else ..()
/obj/item/weapon/ointment/attack(mob/M, mob/user)
	if(M:health < 0) return
	if(!istype(user, /mob/human) && (!ticker || ticker && ticker:mode != "monkey"))
		user << "\red You don't have the dexterity to do this!"
		return
	if(user)
		for(var/mob/O in view(M))
			if(O:client && !O:blinded)
				O:show_message("\red[M] has been applied with [src] by [user]", 1)
	if(40 >= M:fireloss)
		M:fireloss = 0
	else
		M:fireloss -= 40
	M:health = 100 - M:oxyloss - M:toxloss - M:fireloss - M:bruteloss
	amount--
	if(amount <= 0) del(src)
/obj/item/weapon/ointment/examine()
	set src in view(1)
	usr << "\blue there are [amount] ointment pack\s left on the stack!"
/obj/item/weapon/ointment/attackby(obj/W, mob/user)
	if(!istype(W, /obj/item/weapon/ointment)) return
	if(W:amount == 5) return
	if(W:amount + amount > 5)
		amount = W:amount + amount - 5
		W:amount = 5
	else
		W:amount += amount
		del(src)
/obj/item/weapon/bottle
	var/chem
	throwspeed = 20
/obj/item/weapon/bottle/examine()
	set src in usr
	usr << "\blue The bottle \icon[src] contains [chem:contains()] units of chemicals"
/obj/item/weapon/ointment/throwspeed = 20
/obj/item/weapon/bottle/New()
	chem = new /obj/substance/chemical()
	..()
/obj/item/weapon/bottle/attackby(obj/item/weapon/syringe/B, mob/user)
	if(istype(B, /obj/item/weapon/bottle))
		var/t1 = B:chem:transfer_from(chem, chem:maximum)
		if(t1) user:show_message("\blue You pour [t1] unit\s into the bottle. The bottle now contains [chem:contains()] units.")
	if(istype(B, /obj/item/weapon/syringe))
		if(B:mode == "inject")
			var/obj/t1 = B:chem:transfer_from(chem, 5)
			B:update_is()
			if(t1) user:show_message("\blue You inject [t1] unit\s into the bottle. The syringe contains [B:chem:contains()] units.")
		else
			var/t1 = chem:transfer_from(B:chem, 5)
			B:update_is()
			if(t1) user:show_message("\blue You draw [t1] unit\s from the bottle. The syringe contains [B:chem:contains()] units.")
		add_fingerprint(user)
	else if(istype(B, /obj/item/weapon/dropper))
		if(B:mode == "inject")
			var/obj/t1 = B:chem:transfer_from(chem, 1)
			B:update_is()
			if(t1) user:show_message("\blue You deposit [t1] unit\s into the bottle. The dropper contains [B:chem:contains()] units.")
		else
			var/t1 = chem:transfer_from(B:chem, 1)
			B:update_is()
			if(t1) user:show_message("\blue You extract [t1] unit\s from the bottle. The dropper contains [B:chem:contains()] units.")
/obj/item/weapon/ointment/w_class = 1
/obj/item/weapon/bottle/toxins/New()
	..()
	chem:maximum = 60
	chem:l_plas = 50
/obj/item/weapon/bottle/toxins
	icon_state = "toxinbottle"
/obj/item/weapon/bottle/antitoxins/New()
	..()
	chem:maximum = 60
	chem:pl_coag = 50
/obj/item/weapon/bottle/antitoxins
	icon_state = "atoxinbottle"
/obj/item/weapon/bottle/r_epil/name = "Epileptic Remedy"
/obj/item/weapon/bottle/r_epil/New()
	..()
	chem:maximum = 60
	chem:epil = 50
/obj/item/weapon/bottle/r_epil
	icon_state = "medibottle"
/obj/item/weapon/bottle/r_ch_cough/name = "Cough remedy"
/obj/item/weapon/bottle/r_ch_cough/New()
	..()
	chem:maximum = 60
	chem:ch_cou = 50
/obj/item/weapon/bottle/r_ch_cough
	icon_state = "medibottle"
/obj/item/weapon/bottle/rejuvenators/icon_state = "rejuvbottle"
/obj/item/weapon/bottle/rejuvenators/New()
	..()
	chem:maximum = 60
	chem:rejuv = 50
/obj/item/weapon/bottle/s_tox
	icon_state = "toxinbottle"
	name = "sleep toxins"
/obj/item/weapon/bottle/s_tox/New()
	..()
	chem:maximum = 60
	chem:s_tox = 50
/obj/item/weapon/bottle/New()
	..()
	pixel_y = rand(-8, 8)
	pixel_x = rand(-8, 8)
/obj/item/weapon/weldingtool
	icon_state = "welder"
	var/welding = 0
	var/weldfuel = 20
	flags = 322
	force = 3
	throwforce = 5
	throwspeed = 5
	w_class = 2
/obj/item/weapon/weldingtool/examine()
	set src in usr
	usr << "\icon[src] [name] contains [weldfuel] units of fuel left!"
/obj/item/weapon/weldingtool/afterattack(obj/O, mob/user)
	if(welding)
		weldfuel--
		if(weldfuel <= 0)
			usr << "\blue Need more fuel!"
			welding = 0
			force = 3
			damtype = "brute"
			icon_state = "welder"

		var/location = user:loc
		if(!istype(location, /turf)) return
		location:firelevel = location:poison + 1
/obj/item/weapon/weldingtool/attack(mob/M, mob/user)
	..()
	if(prob(30) && (!welding && M:stat < 2))
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
			O:show_message("\red<B>[M] has been knocked unconscious!</B>", 1, "\red You hear someone fall.", 2)
		M:show_message("\red<B>This was a [time * 100 / 120]% hit. Roleplay it! (personality/memory change if the hit was severe enough)</B>")
/obj/item/weapon/brutepack/throwspeed = 20
/obj/item/weapon/weldingtool/attack_self(mob/user)
	welding = !welding
	if(welding)
		if(weldfuel <= 0)
			user << "\blue Need more fuel!"
			welding = 0
			return 0
		user << "\blue You will now weld when you attack."
		force = 15
		damtype = "fire"
		icon_state = "welder1"
	else
		user << "\blue Not welding anymore."
		force = 3
		damtype = "brute"
		icon_state = "welder"

/obj/item/weapon/bottle/w_class = 1
