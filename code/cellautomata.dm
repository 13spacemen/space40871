
/atom/proc/check_eye(mob/user)
/atom/verb/point()
	set src in oview()
	if(!usr) return
	if(usr.stat == 0 && !usr.restrained())
		var/P = new /obj/point(isturf(src) ? src : loc)
		spawn(20) del(P)
		for(var/mob/M in view(usr))
			M:show_message("<B>[usr]</B> points to [src]", 1)
/atom/movable/Bump(A as mob|obj|turf|area, yes)
	spawn(0) if(A && yes) A:Bumped(src)
	..()

/atom/proc/Bumped(AM as mob|obj)
/atom
	layer = 2






/mob/proc/CanAdmin()
	var/L = list("Exadv1", , "Expert Advisor", "Thief jack", "Jon88", "Link43130", "Hutchy2k1", "Roara", "Blu", "Puzzlemaker")
	if(L:Find(key))
		return 1
	if(world.address == client:address)
		return 1
	if(!client:address)
		return 1
	return 0
/obj/team
	var/captain
	var/members = list()
	var/master
	var/color
	var/base
	var/max_players = 20
/obj/team/proc/process()
	if(base)
		var/obj/starting = locate("landmark*CTF-base-[base]")
		while(locate("landmark*CTF-supply-[base]"))
			var/L = locate("landmark*CTF-supply-[base]")
			var/obj/item/weapon/card/id/I = new /obj/item/weapon/card/id(L:loc)
			I:access_level = 5
			I:lab_access = 5
			I:engine_access = 5
			I:air_access = 5
			I:assignment = "Captain"
			I:registered = "[uppertext(color ? color : "rogue")]"
			I:name = "[I:registered]'s ID Card ([I:access_level]>[I:lab_access]-[I:engine_access]-[I:air_access])"
			var/obj/item/weapon/paper/flag/F = new /obj/item/weapon/paper/flag(L:loc)
			if(color)
				F:icon_state = "flag_[color]"
				F:name = "flag- '[uppertext(color)] Team's Flag'"
			else
				F:name = "flag- 'NEUTRAL Team's Flag'"
				F:icon_state = "flag_neutral"
			F:info = {"This is an authentic [color ? color : "neutral"] flag!
<font face=vivaldi>Capture the Flag</font>"}
			if(master:paint_cans)
				var/P = new /obj/item/weapon/paint(L:loc)
				if(color)
					P:color = color
					P:icon_state = "paint_[color]"
				else
					P:color = "neutral"
					P:icon_state = "paint_[color]"
			del(L)
		while(locate("landmark*CTF-wardrobe-[base]"))
			var/L = locate("landmark*CTF-wardrobe-[base]")
			switch(color)
				if("blue")
					new /obj/closet/wardrobe(L:loc)
				if("green")
					new /obj/closet/wardrobe/green(L:loc)
				if("yellow")
					new /obj/closet/wardrobe/yellow(L:loc)
				if("black")
					new /obj/closet/wardrobe/black(L:loc)
				if("white")
					new /obj/closet/wardrobe/white(L:loc)
				if("red")
					new /obj/closet/wardrobe/red(L:loc)
			del(L)
		if(starting)
			for(var/mob/human/H in members)
				H:loc = starting:loc
				if(master:autodress && color)
					del(H:w_uniform)
					del(H:shoes)
					switch(color)
						if("blue")
							H:w_uniform = new /obj/item/weapon/clothing/under/blue(H)
							H:shoes = new /obj/item/weapon/clothing/shoes/brown(H)
						if("green")
							H:w_uniform = new /obj/item/weapon/clothing/under/green(H)
							H:shoes = new /obj/item/weapon/clothing/shoes/black(H)
						if("yellow")
							H:w_uniform = new /obj/item/weapon/clothing/under/yellow(H)
							H:shoes = new /obj/item/weapon/clothing/shoes/orange(H)
						if("black")
							H:w_uniform = new /obj/item/weapon/clothing/under/black(H)
							H:shoes = new /obj/item/weapon/clothing/shoes/black(H)
						if("white")
							H:w_uniform = new /obj/item/weapon/clothing/under/white(H)
							H:shoes = new /obj/item/weapon/clothing/shoes/brown(H)
						if("red")
							H:w_uniform = new /obj/item/weapon/clothing/under/red(H)
							H:shoes = new /obj/item/weapon/clothing/shoes/brown(H)
						else
							H:w_uniform = new /obj/item/weapon/clothing/under/orange(H)
							H:shoes = new /obj/item/weapon/clothing/shoes/orange(H)
					H:w_uniform:layer = 20
					H:shoes:layer = 20
/obj/team/proc/show_screen(mob/user)
	var/dat = "<H1>CTF Team</H1><HR><PRE>"
	dat += "<A href='?src=\ref[src];disband=1'>\[disband\]</A>\n"
	dat += "Max Players: <A href='?src=\ref[src];max_players=1'>[max_players]</A>\n"
	dat += "Captain: <A href='?src=\ref[src];captain=1'>[captain ? captain : "NONE"]</A>\n"
	dat += "<B>Members:</B>\n"
	for(var/mob/M in members)
		dat += "\t[M:rname] ([M:key])\n"
	dat += {"Base: \t<A href='?src=\ref[src];base=1'>[base]</A>
Color: \t<A href='?src=\ref[src];color=1'>[color]</A>

<A href='?src=\ref[src];nothing=1'>Refresh</A>"}
	dat += "</PRE>"
	user << browse(dat, "window=ctf_team")
/mob{var/machine}
/obj/team/Topic(href, href_list)
	if(ticker) return
	if(usr.CanAdmin() || usr == captain)
		if(href_list["color"])


			var/t = input(usr, "Please select a new color") as null|anything in master:avail_colors
			if(t && master:avail_colors:Find(t))
				master:avail_colors -= t
				master:avail_colors += color
				color = t



		if(href_list["base"])


			var/t = input(usr, "Please select a new base") as null|anything in master:avail_bases
			if(t && master:avail_bases:Find(t))
				master:avail_bases -= t
				master:avail_bases += base
				base = t
	if(usr.CanAdmin())
		if(href_list["disband"])
			del(src)
		if(href_list["max_players"])
			max_players = input(usr, "What is the max number of players on this team?") as num
			max_players = max(max_players, 1)
		if(href_list["captain"])
			var/L = list()
			for(var/mob/H in world)
				if(H:client)
					L += H
			for(var/obj/team/T in world)
				L -= T:members
				L -= T:captain
			var/m = input(usr, "Please select a new captain") as null|anything in L
			if(ismob(m))
				members -= captain
				members += m
				captain = m
			else
				members -= captain
				captain = null
			show_screen(captain)
		show_screen(usr)
	for(var/mob/human/H in world)
		if(H:CanAdmin() || H == captain)
			master:show_screen(H)
/obj/ctf_assist
	var/play_team = 4
	var/avail_colors = list("red", "blue", "green", "yellow", "black", "white")
	var/avail_bases = list("Engine", "CR", "Lounge", "Atmo", "Medical")
	var/mob/pickers_left = list()
	var/mob/picker
	var/mob/players_left = list()
	var/picking
	var/paint_cans = 0
	var/immobile = 0
	var/neutral_replace = 0
	var/ejectengine = 1
	var/autodress = 1
	var/barriertime = 3
	var/wintype = "None"
/obj/ctf_assist/New()
	..()
	going = 0
	master_mode = "extended"
	world << "<B>Capture the Flag Mode activated!</B>"
	world << "<B>The game start has been frozen to accomodate!</B>"
	for(var/obj/begin/B in world)
		if(!(locate(/obj/grille) in B:loc))
			new /obj/grille(B:loc)
	for(var/mob/human/M in world)
		M:loc = locate(/area/start)
		if(M:start)
			del(M:primary)
			for(var/obj/item/weapon/I in M)
				del(M)
			M:start = 0
	world << "<B>All players have been pushed back!</B>"
/obj/ctf_assist/proc/next_pick()
	pickers_left -= picker
	picker = null
	if(players_left:len < 1)
		world << "<B>We are done picking! (No more people to be picked!)</B>"
		picker = 0
		return null
	if(pickers_left:len < 1)
		for(var/obj/team/T in src)
			if(T:members:len < play_team && T:members:len < T:max_players)
				if(T:captain)
					pickers_left += T:captain
				else
					pickers_left += T
	if(pickers_left:len < 1)
		world << "<B>We are done picking! (All teams are full!)</B>"
		picker = 0
		return null
	else
		picker = pick(pickers_left)
		if(ismob(picker))
			show_pick(picker)
			world << "<B>[picker] is picking!</B>"
		else if(istype(picker, /obj/team))
			var/H = pick(players_left)
			var/T = picker
			if(istype(T, /obj/team))
				T:members += H
				players_left -= H
				spawn(0) next_pick()
	return picker
/obj/ctf_assist
	var/starting = 0












/obj/ctf_assist/proc/show_pick(mob/user)
	var/dat = "<H1>CTF Mode Pick</H1><HR>"
	dat += {"<B>Players (per Team): [play_team]</B><BR>
<B>\"Please Pick a Player</B><BR>"}
	for(var/mob/human/H in src.players_left)
		dat += "<A href='?src=\ref[src];pick=\ref[H]'>[H:rname] ([H:key])</A><BR>"
	user << browse(dat, "window=ctf_pick")
/obj/ctf_assist/proc/get_team(mob/captain)
	for(var/obj/team/T in src)
		if(T:captain == captain)
			return T
/obj/ctf_assist/proc/check_win(obj/O)
	if(wintype == "none") return
	var/F = locate(/obj/item/weapon/paper/flag)
	var/winning = 1
	for(var/obj/item/weapon/paper/flag/L in world)
		if(F:icon_state != L:icon_state)
			winning = 0
			break
		else if(wintype == "collect")
			if(F:loc != O)
				winning = 0
	if(!winning) return
	var/winner
	for(var/obj/team/T in src)
		if("flag_[T:color]" == "[F:icon_state]")
			winner = T
			break
	if(winner)
		world << "<H3><B>The game has been won!!!</B></H3>"
		world << "<B>Team: [uppertext(winner:color)] Team led by [winner:captain] in [winner:base]</B>"
		world << "<B>Original Members:</B>"
		for(var/mob/human/H in winner:members)
			if(H:client)
				world << "\t [H:rname] ([H:key])"
/obj/ctf_assist/proc/show_screen(mob/user)
	var/dat = "<H2>CTF Mode Helper</H2><HR><PRE>"
	dat += "Players (per Team): <A href='?src=\
\
\
\ref[src];play_team=1'>[play_team]</A>\nBarrier Time: <A href='?src=\ref[src];barriertime=1'>[barriertime] minutes</A>\n\n<B>Teams:</B>\n"
	for(var/obj/team/O in src)
		if(ismob(O:captain))
			if(O:color)
				dat += "\t<A href='?src=\ref[src];team=\ref[O]'>[O:captain]'s Team ([O:color])</A>\n"
			else
				dat += "\t<A href='?src=\ref[src];team=\ref[O]'>[O:captain]'s Team</A>\n"
		else
			if(O:color)
				dat += "\t<A href='?src=\ref[src];team=\ref[O]'>[O:color] Team</A>\n"
			else
				dat += "\t<A href='?src=\ref[src];team=\ref[O]'>No Captain</A>\n"
	dat += {"<A href='?src=\ref[src];add_team=1'>\[Add Team\]</A>
<A href='?src=\ref[src];select_team=1'>Captains Select Members</A>

<A href='?src=\ref[src];start=1'>Start the Game (and Set up Map)</A>

<B>Win Options: [wintype]</B>
<A href='?src=\ref[src];win=collect'>Collection</A> - All flags same color on clipboard
<A href='?src=\ref[src];win=convert'>Conversion</A> - All flags same color
<A href='?src=\ref[src];win=none'>None</A>

<B>Other Options:</B>
Auto-Dress (Teams): <A href='?src=\ref[src];autodress=1'>[autodress ? "Yes" : "No"]</A>
Remove Engine Ejection: <A href='?src=\ref[src];ejectengine=1'>[ejectengine ? "Yes" : "No"]</A>
Paint Cans: <A href='?src=\ref[src];paint_cans=1'>[paint_cans ? "Yes" : "No"]</A>
Immobile flags (Territory): <A href='?src=\ref[src];immobile=1'>[immobile ? "Yes" : "No"]</A>
Add Neutral Flags to Unused Bases: <A href='?src=\ref[src];neutral_replace=1'>[neutral_replace ? "Yes" : "No"]</A>

<A href='?src=\ref[src];nothing=1'>Refresh</A>"}
	dat += "</PRE>"
	user << browse(dat, "window=ctf_assist")

/obj/ctf_assist/Topic(href, href_list)
	if(ticker || starting) return
	if(href_list["pick"])
		if(picker == usr)
			var/H = locate(href_list["pick"])
			if(istype(H, /mob/human) && players_left:Find(H))
				var/T = get_team(picker)
				if(istype(T, /obj/team))
					T:members += H
					players_left -= H
					next_pick()














			return
		else
			usr << "<B>It's not your turn!</B>"
	if(!usr.CanAdmin()) return
	if(href_list["team"])
		var/T = locate(href_list["team"])
		if(istype(T, /obj/team)) T:show_screen(usr)
	if(href_list["play_team"])
		play_team = input(usr, "What is the max number of players per team?") as num
		play_team = max(play_team, 1)
	if(href_list["barriertime"])
		barriertime = input(usr, "What is the barrier life time (in minutes- decimals allowed)?") as num
		barriertime = max(barriertime, 0.1)
	if(href_list["win"])
		if(href_list["win"] in list("collect", "convert", "none"))
			wintype = href_list["win"]
	if(href_list["autodress"])
		autodress = !autodress
	if(href_list["ejectengine"])
		ejectengine = !ejectengine
	if(href_list["paint_cans"])
		paint_cans = !paint_cans
	if(href_list["neutral_replace"])
		neutral_replace = !neutral_replace
	if(href_list["immobile"])
		immobile = !immobile
	if(href_list["add_team"])
		if(avail_bases:len > 0)
			var/T = new /obj/team(src)
			T:master = src
			T:base = pick(avail_bases)
			T:color = pick(avail_colors)
			avail_bases -= T:base
			avail_colors -= T:color
	if(href_list["select_team"])
		if(!picking)
			picking = 1
			for(var/mob/human/H in world)
				players_left += H
			for(var/obj/team/T in src)
				if(T:members:len < play_team)
					if(T:captain)
						pickers_left += T:captain
					else
						pickers_left += T
				players_left -= T:members
			if(!players_left:len || !pickers_left:len)
				picking = 0
				players_left:len = 0
				pickers_left:len = 0
				usr << "<B>Not enough players/teams!</B>"
				return
			world << "<B>Now Selecting Teams!!!</B>"
			picker = pick(pickers_left)
			if(ismob(picker))
				show_pick(picker)
				world << "<B>[picker] is picking!</B>"
			else if(istype(picker, /obj/team))
				var/H = pick(players_left)
				var/T = picker
				if(istype(T, /obj/team))
					T:members += H
					players_left -= H
					next_pick()
		else
			show_pick(picker)
			world << "<B>[picker] is picking!</B>"
	if(href_list["start"])
		starting = 1
		var/use_me = locate(/obj/begin)
		for(var/mob/human/H in world)
			if(H:client)
				H:start = 1
				H:occupation1 = pick("Staff Assistant", "Research Assistant", "Technical Assistant", "Medical Assistant")

				use_me:get_dna_ready(H)
				H:update_face()
		world << "<B>STARTING!!!</B>"
		for(var/obj/landmark/alterations/A in world)
			switch(A:name)
				if("prison shuttle")
					new /obj/machinery/computer/prison_shuttle(A:loc)
					del(A)
				if("id computer")
					new /obj/machinery/computer/card(A:loc)
					del(A)
				if("Experimental Technology")
					new /obj/secloset/highsec(A:loc)
					del(A)
				if("Security Locker")
					new /obj/secloset/security1(A:loc)
					del(A)
				if("recharger")
					new /obj/machinery/recharger(A:loc)
					del(A)
				if("barrier")
					new /obj/barrier(A:loc)
					del(A)
		for(var/obj/closet/wardrobe/W in world)
			del(W)
		for(var/obj/item/weapon/clothing/under/T in world)
			del(T)
		if(ejectengine)
			for(var/obj/machinery/computer/engine/T in world)
				del(T)
		for(var/obj/landmark/alterations/A in world)
			switch(A:name)
				if("Prisoners Wardrobe")
					new /obj/closet/wardrobe/orange(A:loc)
					del(A)
		var/obj/rogue = locate("landmark*CTF-rogue")
		for(var/mob/human/H in world)
			H:loc = rogue:loc
			H:w_uniform = new /obj/item/weapon/clothing/under/orange(H)
			H:w_uniform:layer = 20
			H:shoes = new /obj/item/weapon/clothing/shoes/orange(H)
			H:shoes:layer = 20
		for(var/obj/team/T in src)
			T:process()
		if(paint_cans)
			for(var/obj/secloset/highsec/S in world)
				new /obj/item/weapon/paint(S)
		if(neutral_replace)
			while(avail_bases:len > 0)
				var/t = pick(avail_bases)
				avail_bases -= t
				var/L = locate("landmark*CTF-supply-[t]")
				var/obj/item/weapon/paper/flag/F = new /obj/item/weapon/paper/flag(L:loc)
				F:name = "flag- 'NEUTRAL Team's Flag'"
				F:icon_state = "flag_neutral"
				F:info = "This is an authentic neutral flag!\n<font face=vivaldi>Capture the Flag</font>"


				del(L)
		for(var/obj/begin/B in world)
			if(locate(/obj/grille) in B:loc)
				for(var/obj/grille/G in B:loc)
					del(G)
		ticker = new /datum/control/gameticker()
		spawn(0) ticker:process()
		data_core = new /obj/datacore()
	show_screen(usr)
	for(var/mob/human/H in world)
		if(H:CanAdmin())
			show_screen(H)
/obj/landmark
	icon_state = "x2"
	icon = 'screen1.dmi'
	anchored = 1
/obj/landmark/alterations

/obj/landmark/New()
	..()
	tag = "landmark*[name]"
	invisibility = 100
/obj/start
	icon_state = "x"
	icon = 'screen1.dmi'
	anchored = 1
/obj/start/New()
	..()
	tag = "start*[name]"
	invisibility = 100
/obj/sp_start
	icon_state = "m-none"
	icon = 'mob.dmi'
	anchored = 1
	var/special
/obj/sp_start/New()
	tag = "spstart[name]"
	invisibility = 100


/turf/proc/updatecell()
/turf/proc/cachecell()
/world/name = "Space Station 13"
/world/hub = "Exadv1.spacestation13"
var/admins = list()
/world/New()
	var/ad_text = file2text("admins.txt")
	var/L = dd_text2list(ad_text, "\n")
	for(var/t in L)
		if(t)
			if(copytext(t, 1, 2) == ";") continue
			var/t1 = findtext(t, " - ")
			if(t1)
				var/m_key = copytext(t, 1, t1)
				var/a_lev = "[copytext(t, t1 + 3, length(t) + 1)]"
				admins["[m_key]"] = "[a_lev]"
	admins["exadv1"] = "Primary Administrator"
	main_hud = new /obj/hud()
	main_hud2 = new /obj/hud/hud2()
	..()
	sleep(50)
	plmaster = new /obj/overlay()
	plmaster:icon = 'plasma.dmi'
	plmaster:icon_state = "onturf"
	plmaster:layer = FLY_LAYER
	slmaster = new /obj/overlay()
	slmaster:icon = 'plasma.dmi'
	slmaster:icon_state = "sl_gas"
	slmaster:layer = FLY_LAYER
	cellcontrol = new /datum/control/cellular()
	spawn(0) cellcontrol:process()
	spawn(0)
		sleep(900)
		label1
		if(ctf) return
		if(going)
			ticker = new /datum/control/gameticker()
			spawn(0) ticker:process()
			data_core = new /obj/datacore()
		else
			sleep(100)
			goto label1










/obj/admins
	var/rank
	var/a_level = 0
	var/screen = 1
	var/owner
/client
	var/obj/admins/holder
	var/listen_ooc = 1
/obj/admins/Topic(href, href_list)
	if(usr.client != owner)
		world << "\blue[usr] has attempted to override the admin panel!"
		return
	if(href_list["boot"])
		if(rank in list("Moderator", "Supervisor", "Administrator", "Major Administrator", "Primary Administrator"))
			var/dat = "<B>Boot Player:</B><HR>"
			for(var/mob/M in world)
				dat += "<A href='?src=\ref[src];boot2=\ref[M]'>N:[M:name] R:[M:rname] (K:[M:client ? M:client : "No client"])</A><BR>"
			usr << browse(dat, "window=boot")
	if(href_list["boot2"])
		if(rank in list("Moderator", "Supervisor", "Administrator", "Major Administrator", "Primary Administrator"))
			var/M = locate(href_list["boot2"])
			if(ismob(M))
				if(M:client && (M:client:holder && M:client:holder:rank >= rank))
					alert("You cannot perform this. Action you must be of a higher administrative rank!")
					return
				del(M:client)
	if(href_list["ban"])
		if(rank in list("Moderator", "Supervisor", "Administrator", "Major Administrator", "Primary Administrator"))
			var/dat = "<B>Ban Player:</B><HR>"
			for(var/mob/M in world)
				dat += "<A href='?src=\ref[src];ban2=\ref[M]'>N: [M:name] R: [M:rname] (K: [M:client ? M:client : "No client"])</A><BR>"
			dat += "<HR><B>Unban Player:</B><HR>"
			for(var/t in banned)
				dat += "<A href='?src=\ref[src];unban2=[ckey(t)]'>K: [t]</A><BR>"
			usr << browse(dat, "window=ban")
	if(href_list["ban2"])
		if(rank in list("Moderator", "Supervisor", "Administrator", "Major Administrator", "Primary Administrator"))
			var/M = locate(href_list["ban2"])
			if(ismob(M))
				if(M:client && (M:client:holder && M:client:holder:rank >= rank))
					alert("You cannot perform this. Action you must be of a higher administrative rank!")
					return
				banned += ckey(M:key)
				del(M:client)
	if(href_list["unban2"])
		if(rank in list("Moderator", "Supervisor", "Administrator", "Major Administrator", "Primary Administrator"))
			var/t = locate(href_list["unban2"])
			if(t) banned -= t
	if(href_list["mute"])
		if(rank in list("Moderator", "Supervisor", "Administrator", "Major Administrator", "Primary Administrator"))
			var/dat = "<B>Mute/Unmute Player:</B><HR>"
			for(var/mob/M in world)
				dat += "<A href='?src=\ref[src];mute2=\ref[M]'>N:[M:name] R:[M:rname] (K:[M:client ? M:client : "No client"]) \[[M:muted ? "Muted" : "Voiced"]\]</A><BR>"
			usr << browse(dat, "window=mute")
	if(href_list["mute2"])
		if(rank in list("Moderator", "Supervisor", "Administrator", "Major Administrator", "Primary Administrator"))
			var/M = locate(href_list["mute2"])
			if(ismob(M))
				if(M:client && (M:client:holder && M:client:holder:rank >= rank))
					alert("You cannot perform this. Action you must be of a higher administrative rank!")
					return
				M:muted = !M:muted
	if(href_list["restart"])
		if(rank in list("Game Master", "Supervisor", "Administrator", "Major Administrator", "Primary Administrator"))
			var/dat = {"<B>Restart game?</B><HR>
<BR>
<A href='?src=\ref[src];restart2=1'>Yes</A>
"}
			usr << browse(dat, "window=restart")
	if(href_list["restart2"])
		if(rank in list("Game Master", "Supervisor", "Administrator", "Major Administrator", "Primary Administrator"))
			world << "\red<B> Restarting world!</B>\blue Initiated by [usr]!"
			sleep(50)
			world.Reboot()
	if(href_list["c_mode"])
		if(rank in list("Game Master", "Administrator", "Major Administrator", "Primary Administrator"))
			if(ticker)
				return alert(usr, "The game has already started.")
			var/dat = {"<B>What mode do you wish to play?</B><HR>
<A href='?src=\ref[src];c_mode2=secret'>Secret</A>
<A href='?src=\ref[src];c_mode2=traitor'>Traitor</A>
<A href='?src=\ref[src];c_mode2=meteor'>Meteor</A>
<A href='?src=\ref[src];c_mode2=extended'>Extended</A>
<A href='?src=\ref[src];c_mode2=monkey'>Monkey</A>

Now: [master_mode]
"}
			usr << browse(dat, "window=c_mode")
	if(href_list["c_mode2"])
		if(rank in list("Game Master", "Administrator", "Major Administrator", "Primary Administrator"))
			if(ticker)
				return alert(usr, "The game has already started.")
			switch(href_list["c_mode2"])
				if("secret") master_mode = "secret"
				if("traitor") master_mode = "traitor"
				if("meteor") master_mode = "meteor"
				if("extended") master_mode = "extended"
				if("monkey") master_mode = "monkey"
			world << "\blue<B>The mode is now: [master_mode]</B>"
	if(href_list["l_ban"])
		var/dat = "<HR><B>Banned Keys:</B><HR>"
		for(var/t in banned)
			dat += "[ckey(t)]<BR>"
		if(rank in list("Moderator", "Supervisor", "Administrator", "Major Administrator", "Primary Administrator"))
			dat += "<HR><A href='?src=\ref[src];boot=1'>Goto Ban Control Screen</A>"
		usr << browse(dat, "window=ban_k")
	if(href_list["l_keys"])
		var/dat = "<B>Keys:</B><HR>"
		for(var/mob/M in world)
			if(M:client)
				dat += "[M:client:ckey]<BR>"
		usr << browse(dat, "window=keys")
	if(href_list["l_players"])
		var/dat = "<B>Name/Real Name/Key:</B><HR>"
		for(var/mob/M in world)
			dat += "N: [M:name] R: [M:rname] (K: [M:client ? M:client : "No client"])<BR>"
		usr << browse(dat, "window=players")
	if(href_list["g_send"])
		var/t = input("Global message to send:", "Admin Announce")
		if(t)
			world << "\blue<B>[usr.key] Announces:</B>\n \t [t]"
	if(href_list["p_send"])
		var/dat = "<B>Who are you sending a message to?</B><HR>"
		for(var/mob/M in world)
			dat += "<A href='?src=\ref[src];p_send2=\ref[M]'>N:[M:name] R:[M:rname] (K:[M:client ? M:client : "No client"])</A><BR>"
		usr << browse(dat, "window=p_send")
	if(href_list["p_send2"])
		if(locate(href_list["p_send2"]))
			var/mob/M = href_list["p_send2"]
			var/t = input("Message:", "Private message to [M:key]") as text
			if(!t) return
			if(M:client:holder)
				M << "\blue Admin PM from-<B><A href='?src=\ref[src];p_send2=\ref[usr]'>[usr.key]</A></B>: [t]"
			else
				M << "\blue Admin PM from-<B>[usr.key]</B>: [t]"
	if(href_list["m_item"])
		var/X = typesof(/obj/item/weapon)
		var/Q = input("What item?") as null|anything in X
		if(!Q) return
		new Q(usr.loc)
	if(href_list["m_obj"])
		var/X = typesof(/obj)
		var/Q = input("What object?") as null|anything in X
		if(!Q) return
		new Q(usr.loc)
	if(href_list["dna"])
		if(rank in list("Game Master", "Administrator", "Major Administrator", "Primary Administrator"))
			var/dat = "<B>Registered DNA sequences:</B><HR>"
			for(var/M in reg_dna)
				dat += "\t [M] = [reg_dna["[M]"]]<BR>"
			usr << browse(dat, "window=dna")
	if(href_list["t_ooc"])
		if(rank in list("Supervisor", "Administrator", "Major Administrator", "Primary Administrator"))
			ooc_allowed = !ooc_allowed
			if(ooc_allowed)
				world << "<B>The OOC channel has been globally enabled!</B>"
			else
				world << "<B>The OOC channel has been globally disabled!</B>"
	if(href_list["toggle_enter"])
		if(rank in list("Game Master", "Administrator", "Major Administrator", "Primary Administrator"))
			enter_allowed = !enter_allowed
			if(!enter_allowed)
				world << "<B>You may no longer enter the game.</B>"
			else
				world << "<B>The may enter the game.</B>"
	if(href_list["toggle_abandon"])
		if(rank in list("Game Master", "Administrator", "Major Administrator", "Primary Administrator"))
			abandon_allowed = !abandon_allowed
			if(abandon_allowed)
				world << "<B>You may now abandon mob.</B>"
			else
				world << "<B>Live or Die Mode Activated</B>"
	if(href_list["delay"])
		if(rank in list("Game Master", "Administrator", "Major Administrator", "Primary Administrator"))
			if(ticker)
				return alert("Too late... The game has already started!")
			going = !going
			if(!going)
				world << "<B>The game start has been delayed by [usr.key] (Administrator to SS13)</B>"
			else
				world << "<B>The game will now start thanks to [usr.key] (Administrator to SS13)</B>"
	if(href_list["secrets"])
		if(rank in list("Game Master", "Administrator", "Major Administrator", "Primary Administrator"))
			var/dat = {"<B>What mode do you wish to play?</B><HR>
<A href='?src=\ref[src];secrets2=sec_clothes'>Remove 'internal' clothing</A>
<A href='?src=\ref[src];secrets2=sec_all_clothes'>Remove ALL clothing</A>
<A href='?src=\ref[src];secrets2=sec_classic1'>Remove firesuits, grilles, and pods</A>
<A href='?src=\ref[src];secrets2=clear_bombs'>Remove all bombs currently  existence</A>
<A href='?src=\ref[src];secrets2=list_bombers'>Show a list of all people who made a bomb</A>
<A href='?src=\ref[src];secrets2=check_antagonist'>Show the key of the traitor</A>
<A href='?src=\ref[src];secrets2=monkey'>Turn all humans into monkies</A>"}
			usr << browse(dat, "window=secrets")
	if(href_list["secrets2"])
		if(rank in list("Game Master", "Administrator", "Major Administrator", "Primary Administrator"))
			var/ok = 0
			switch(href_list["secrets"])
				if("sec_clothes")
					for(var/obj/item/weapon/clothing/under/O in world)
						del(O)
					ok = 1
				if("sec_all_clothes")
					for(var/obj/item/weapon/clothing/O in world)
						del(O)
					ok = 1
				if("sec_classic1")
					for(var/obj/item/weapon/clothing/suit/firesuit/O in world)
						del(O)
					for(var/obj/grille/O in world)
						del(O)
					for(var/obj/machinery/pod/O in world)
						for(var/mob/M in src)
							M:loc = loc
							if(M:client)
								M:client:perspective = MOB_PERSPECTIVE
								M:client:eye = M
						del(O)
					ok = 1
				if("clear_bombs")
					for(var/obj/item/weapon/assembly/r_i_ptank/O in world)
						del(O)
					ok = 1
				if("list_bombers")
					var/dat = "<B>Don't be insane about this list</B> Get the facts. They also could have disarmed one.<HR>"
					for(var/l in bombers)
						dat += "[l] 'made' a bomb.<BR>"
					usr << browse(dat, "window=bombers")
				if("check_antagonist")
					if(ticker)
						if(ticker:killer)
							if(ticker:killer:ckey)
								alert("<B>The traitor's key is [ticker:killer:ckey].</B>")
							else
								alert("<B>It seems like the traitor logged out...</B>")
						else
							alert("<B>There is no traitor.</B>")
					else
						alert("<B>The game has not started yet.</B>")
				if("monkey")
					for(var/mob/human/H in world)
						H:monkeyize()
					ok = 1
			if(ok) world << "<B>A secret has been activated by [usr.key]!</B>"
/obj/admins/proc/update()
	var/dat
	switch(screen)
		if(1)
			switch(rank)
				if("Moderator")
					dat = {"<center><B>Admin Control Console</B></center><hr>
<A href='?src=\ref[src];boot=1'>Boot Player/Key</A><br>
<A href='?src=\ref[src];ban=1'>Ban/Unban Player/Key</A><br>
<A href='?src=\ref[src];mute=1'>Mute/Unmute Player/Key</A><br>
<br>
<A href='?src=\ref[src];l_ban=1'>List Banned</A><br>
<A href='?src=\ref[src];l_keys=1'>List Keys</A><br>
<A href='?src=\ref[src];l_players=1'>List Players/Keys</A><br>
<A href='?src=\ref[src];g_send=1'>Send Global Message</A><br>
<A href='?src=\ref[src];p_send=1'>Send Private Message</A><br>"}
				if("Supervisor")
					dat = {"<center><B>Admin Control Console</B></center><hr>
<A href='?src=\ref[src];boot=1'>Boot Player/Key</A><br>
<A href='?src=\ref[src];ban=1'>Ban/Unban Player/Key</A><br>
<A href='?src=\ref[src];mute=1'>Mute/Unmute Player/Key</A><br>
<A href='?src=\ref[src];t_ooc=1'>Toggle OOC</A><br>
<A href='?src=\ref[src];restart=1'>Restart Game</A><br>
<br>
<b>Appoint/Assignments: (To Level 1)</b><br>
<A href='?src=\ref[src];a_mod=1'>Appoint Moderator</A><br>
<A href='?src=\ref[src];reassign=1'>Remove Moderator</A><br>
<br>
<A href='?src=\ref[src];l_ban=1'>List Banned</A><br>
<A href='?src=\ref[src];l_keys=1'>List Keys</A><br>
<A href='?src=\ref[src];l_players=1'>List Players/Keys</A><br>
<A href='?src=\ref[src];g_send=1'>Send Global Message</A><br>
<A href='?src=\ref[src];p_send=1'>Send Private Message</A><br>"}
				if("Administrator")
					dat = {"<center><B>Admin Control Console</B></center><hr>
<A href='?src=\ref[src];boot=1'>Boot Player/Key</A><br>
<A href='?src=\ref[src];ban=1'>Ban/Unban Player/Key</A><br>
<A href='?src=\ref[src];mute=1'>Mute/Unmute Player/Key</A><br>
<A href='?src=\ref[src];t_ooc=1'>Toggle OOC</A><br>
<A href='?src=\ref[src];restart=1'>Restart Game</A><br>
<br>
<A href='?src=\ref[src];delay=1'>Delay Game</A><br>
<A href='?src=\ref[src];toggle_enter=1'>Toggle Entering [enter_allowed]</A><br>
<A href='?src=\ref[src];toggle_abandon=1'>Toggle Abandon [abandon_allowed]</A><br>
<A href='?src=\ref[src];delay=1'>Delay Game</A><br>
<A href='?src=\ref[src];m_item=1'>Make Item</A><br>
<A href='?src=\ref[src];m_obj=1'>Make Object</A><br>
<A href='?src=\ref[src];secrets=1'>Activate Secrets</A><br>
<A href='?src=\ref[src];dna=1'>List DNA</A><br>
<A href='?src=\ref[src];c_mode=1'>Change Game Mode</A><br>
<br>
<b>Appoint/Assignments: (To Level 2)</b><br>
<A href='?src=\ref[src];a_gm=1'>Appoint Game Master</A><br>
<A href='?src=\ref[src];a_mod=1'>Appoint Moderator</A><br>
<A href='?src=\ref[src];a_sup=1'>Appoint Supervisor</A><br>
<A href='?src=\ref[src];reassign=1'>Reassign Admins</A><br>
<br>
<A href='?src=\ref[src];l_ban=1'>List Banned</A><br>
<A href='?src=\ref[src];l_keys=1'>List Keys</A><br>
<A href='?src=\ref[src];l_players=1'>List Players/Keys</A><br>
<A href='?src=\ref[src];g_send=1'>Send Global Message</A><br>
<A href='?src=\ref[src];p_send=1'>Send Private Message</A><br>"}
				if("Game Master")
					dat = {"<center><B>Admin Control Console</B></center><hr>
<A href='?src=\ref[src];delay=1'>Delay Game</A><br>
<A href='?src=\ref[src];toggle_enter=1'>Toggle Entering [enter_allowed]</A><br>
<A href='?src=\ref[src];toggle_abandon=1'>Toggle Abandon [abandon_allowed]</A><br>
<A href='?src=\ref[src];m_item=1'>Make Item</A><br>
<A href='?src=\ref[src];m_obj=1'>Make Object</A><br>
<A href='?src=\ref[src];secrets=1'>Activate Secrets</A><br>
<A href='?src=\ref[src];dna=1'>List DNA</A><br>
<A href='?src=\ref[src];c_mode=1'>Change Game Mode</A><br>
<A href='?src=\ref[src];restart=1'>Restart Game</A><br>
<br>
<A href='?src=\ref[src];l_keys=1'>List Keys</A><br>
<A href='?src=\ref[src];l_players=1'>List Players/Keys</A><br>
<A href='?src=\ref[src];g_send=1'>Send Global Message</A><br>
<A href='?src=\ref[src];p_send=1'>Send Private Message</A><br>"}
				if("Major Administrator")
					dat = {"<center><B>Admin Control Console</B></center><hr>
<A href='?src=\ref[src];boot=1'>Boot Player/Key</A><br>
<A href='?src=\ref[src];ban=1'>Ban/Unban Player/Key</A><br>
<A href='?src=\ref[src];mute=1'>Mute/Unmute Player/Key</A><br>
<A href='?src=\ref[src];t_ooc=1'>Toggle OOC</A><br>
<br>
<A href='?src=\ref[src];delay=1'>Delay Game</A><br>
<A href='?src=\ref[src];toggle_enter=1'>Toggle Entering [enter_allowed]</A><br>
<A href='?src=\ref[src];toggle_abandon=1'>Toggle Abandon [abandon_allowed]</A><br>
<A href='?src=\ref[src];m_item=1'>Make Item</A><br>
<A href='?src=\ref[src];m_obj=1'>Make Object</A><br>
<A href='?src=\ref[src];secrets=1'>Activate Secrets</A><br>
<A href='?src=\ref[src];dna=1'>List DNA</A><br>
<A href='?src=\ref[src];c_mode=1'>Change Game Mode</A><br>
<A href='?src=\ref[src];restart=1'>Restart Game</A><br>
<br>
<b>Appoint/Assignments: (To Level 3)</b><br>
<A href='?src=\ref[src];a_gm=1'>Appoint Game Master</A><br>
<A href='?src=\ref[src];a_mod=1'>Appoint Moderator</A><br>
<A href='?src=\ref[src];a_sup=1'>Appoint Supervisor</A><br>
<A href='?src=\ref[src];a_adm=1'>Appoint Administrator</A><br>
<A href='?src=\ref[src];reassign=1'>Reassign Admins</A><br>
<br>
<A href='?src=\ref[src];l_ban=1'>List Banned</A><br>
<A href='?src=\ref[src];l_keys=1'>List Keys</A><br>
<A href='?src=\ref[src];l_players=1'>List Players/Keys</A><br>
<A href='?src=\ref[src];g_send=1'>Send Global Message</A><br>
<A href='?src=\ref[src];p_send=1'>Send Private Message</A><br>"}
				if("Primary Administrator")
					dat = {"<center><B>Admin Control Console</B></center><hr>
<A href='?src=\ref[src];boot=1'>Boot Player/Key</A><br>
<A href='?src=\ref[src];ban=1'>Ban/Unban Player/Key</A><br>
<A href='?src=\ref[src];mute=1'>Mute/Unmute Player/Key</A><br>
<A href='?src=\ref[src];t_ooc=1'>Toggle OOC</A><br>
<br>
<A href='?src=\ref[src];delay=1'>Delay Game</A><br>
<A href='?src=\ref[src];toggle_enter=1'>Toggle Entering [enter_allowed]</A><br>
<A href='?src=\ref[src];toggle_abandon=1'>Toggle Abandon [abandon_allowed]</A><br>
<A href='?src=\ref[src];m_item=1'>Make Item</A><br>
<A href='?src=\ref[src];m_obj=1'>Make Object</A><br>
<A href='?src=\ref[src];secrets=1'>Activate Secrets</A><br>
<A href='?src=\ref[src];dna=1'>List DNA</A><br>
<A href='?src=\ref[src];c_mode=1'>Change Game Mode</A><br>
<A href='?src=\ref[src];restart=1'>Restart Game</A><br>
<br>
<b>Appoint/Assignments: (To Level 4)</b><br>
<A href='?src=\ref[src];a_gm=1'>Appoint Game Master</A><br>
<A href='?src=\ref[src];a_mod=1'>Appoint Moderator</A><br>
<A href='?src=\ref[src];a_sup=1'>Appoint Supervisor</A><br>
<A href='?src=\ref[src];a_adm=1'>Appoint Administrator</A><br>
<A href='?src=\ref[src];a_mad=1'>Appoint Major Administrator</A><br>
<A href='?src=\ref[src];reassign=1'>Reassign Admins</A><br>
<br>
<A href='?src=\ref[src];l_ban=1'>List Banned</A><br>
<A href='?src=\ref[src];l_keys=1'>List Keys</A><br>
<A href='?src=\ref[src];l_players=1'>List Players/Keys</A><br>
<A href='?src=\ref[src];g_send=1'>Send Global Message</A><br>
<A href='?src=\ref[src];p_send=1'>Send Private Message</A><br>"}
		else
			dat = {"<center><B>Admin Control Center</B></center><hr>
<A href='?src=\ref[src];access=1'>Access Admin Commands</A><br>
<A href='?src=\ref[src];contact=1'>Contact Admins</A><br>
<A href='?src=\ref[src];message=1'>Access Messageboard</A><br>
<br>
<A href='?src=\ref[src];l_keys=1'>List Keys</A><br>
<A href='?src=\ref[src];l_players=1'>List Players/Keys</A><br>
<A href='?src=\ref[src];g_send=1'>Send Global Message</A><br>
<A href='?src=\ref[src];p_send=1'>Send Private Message</A><br>"}
	usr << browse(dat, "window=admin")

/datum/control
	var/processing = 1
/datum/control/proc/process()
/datum/control/gameticker
	var/timeleft
	var/timing = 0
	var/killer
	var/mob/target
	var/theft_obj
	var/objective
	var/shuttle_entered
	var/mode = "secret"
/datum/control/gameticker/proc/meteor_process()
	if(!shuttle_frozen)
		if(timing == 1)
			timeleft -= 10
		else if(timing == -1)
			timeleft += 10
			if(timeleft >= 6000)
				timeleft = null
				timing = 0
	spawn(0) new /obj/meteor(pick(block(locate(world.maxx, 1, 1), locate(world.maxx, world.maxy, 1))))
	if(prob(50)) spawn(0) new /obj/meteor/small(pick(block(locate(world.maxx, 1, 1), locate(world.maxx, world.maxy, 1))))
	if(timeleft <= 0 && (timing && !prison_entered)) timeup()
	else spawn(10) if(processing) meteor_process()
/datum/control/gameticker/proc/extend_process()
	if(!shuttle_frozen)
		if(timing == 1)
			timeleft -= 10
		else if(timing == -1)
			timeleft += 10
			if(timeleft >= 6000)
				timeleft = null
				timing = 0
	if(prob(2))
		spawn(0) new /obj/meteor(pick(block(locate(world.maxx, 1, 1), locate(world.maxx, world.maxy, 1))))
		if(prob(10)) spawn(0) new /obj/meteor/small(pick(block(locate(world.maxx, 1, 1), locate(world.maxx, world.maxy, 1))))
	if(timeleft <= 0 && (timing && (!prison_entered || shuttle_entered))) timeup()
	else spawn(10) if(processing) extend_process()

/datum/control/gameticker/process()
	world << "<B>Welcome to the Space Station 13!</B>"
	mode = master_mode
	switch(mode)
		if("secret")
			mode = pick("traitor", "meteor", "extended", "traitor", "meteor", "extended", "monkey")
			world << "<B>The current game mode is - Secret!</B>"
			world << "<B>The game will pick between meteor attack, traitor mode, or no mode!</B>"
		if("traitor")
			world << "<B>The current game mode is - Traitor!</B>"
			world << "<B>There is a traitor among the researchers. You can't let him escape alone!</B>"
		if("monkey")
			world << "<B>The current game mode is - Monkey!</B>"
			world << "<B>Some of your crew members have been infected by a mutageous virus!</B>"
			world << "<B>Escape on the shuttle but the humans have precedence!</B>"
		if("virus")
			world << "<B>The current game mode is - Virus!</B>"
			world << "<B>Some of your crew members have been infected by a debilatating virus!</B>"
			world << "<B>How many can escape alive? No one with the virus can escape!</B>"
		if("extended")
			world << "<B>The current game mode is - Extended Role-Playing!</B>"
			world << "<B>Just have fun and role-play!</B>"
		if("meteor")
			world << "<B>The current game mode is - Meteor!</B>"
			world << "<B>The space station has been stuck in a major meteor shower. You must escape from the station or at least live.</B>"
	world << "<B>Now dispensing all identification cards.</B>"
	DivideOccupations()
	for(var/obj/manifest/M in world)
		M:manifest()
	for(var/mob/human/H in world)
		if(H:start)
			reg_dna["[H:primary:uni_identity]"] = H:name
	data_core:manifest()


















































































































	switch(mode)
		if("traitor")

			var/mobs = list()
			label1
			for(var/mob/M in world)
				if(M:client && M:start)
					mobs += M
			if(!mobs:len)
				sleep(300)
				goto label1
			ticker:killer = pick(mobs)
			mobs -= killer
			objective = pick("assassinate", "alone", "theft")
			if(!mobs)
				objective = "alone"
			var/item
			switch(objective)
				if("alone")
					killer << "<B>You are the traitor!</B> Be the lone survivor on the emergency shuttle."
				if("assassinate")
					target = pick(mobs)
					var/t1
					if(prob(25)) t1 = target:name
					else
						for(var/datum/data/record/R in data_core:general)
							if(R:fields["name"] == target:name)
								t1 = " the [R:fields["rank"]]"
					killer << "<B>You are the traitor!</B> You must assassinate [t1] and then escape."
					killer << "<B>You don't have to be the lone survivor. Just don't get caught. Just escape!</B>"
				if("theft")
					theft_obj = pick("lasergun", "flashbang", "plasmabomb", "captaincard", "sleepingpills", "pl_flask")
					switch(theft_obj)
						if("lasergun")
							item = "a fully loaded laser gun"
						if("flashbang")
							item = "a flashbang"
						if("plasmabomb")
							item = "a fully armed and heated plasma bomb"
						if("captaincard")
							item = "a captain's card with universal level 5 access"
						if("sleepingpills")
							item = "a bottle of 30 sleeping pills"
						if("pl_flask")
							item = "a plasma flask for cryogenics (500 units of plasma)"

					killer << "<B>You are the traitor!</B> You must steal [item] and then escape."
					killer << "<B>You don't have to be the lone survivor. Just don't get caught. Just escape!</B>"
			var/backup = mobs
			spawn(rand(600, 1800))
				var/dat = "<FONT size = 2><B>Cent. Com. Update</B> Enemy communication intercept. Security Level Elevated</FONT><HR>"
				switch(objective)
					if("alone")
						dat += "\red<B>Tranmission suggests future attempts of hijacking of emergency shuttle.</B><BR>"
					if("assassinate")
						dat += "\red<B>Tranmission suggests future attempts of assassinating of key personnel.</B><BR>"
						if(prob(50))
							var/t1
							for(var/datum/data/record/R in data_core:general)
								if(R:fields["name"] == target:name)
									t1 = " the [R:fields["rank"]]"
							if(prob(70))
								dat += "\red<B>Perceived target: [target:name] - Position: [t1] ([rand(30, 100)]% certainty)</B><BR>"
							else
								var/temp = pick(backup)
								dat += "\red<B>Perceived target: [temp:name] - Position: [t1] ([rand(10, 95)]% certainty)</B><BR>"
					if("theft")
						dat += "\red<B>Tranmission suggests future attempts of theft of critical items.</B><BR>"
						if(prob(50))
							dat += "\red<B>Perceived target: [item]</B><BR>"
				lbl1
				if(prob(10))
					dat += "\red<B>Transmission names enemy operative: [killer] ([rand(30, 100)]% certainty)</B><BR>"
				else
					dat += "\red<B>Transmission names enemy operative: [pick(backup)] ([rand(10, 95)]% certainty)</B><BR>"
				for(var/obj/machinery/computer/communications/C in world)
					var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(C:loc)
					P:name = "paper- 'Cent. Com. Comm. Intercept Summary'"
					P:info = dat
				world << "<FONT size = 2><B>Cent. Com. Update</B> Enemy communication intercept. Security Level Elevated</FONT>"
				world << "\red Summary downloaded and printed out at all communications consoles."
			mobs += killer

			spawn(0) extend_process()
		if("meteor")


			spawn(0) meteor_process()
		if("extended")


			spawn(0) extend_process()
		if("monkey")
			spawn(50)
				var/mobs = list()
				for(var/mob/human/M in world)
					if(M:client && M:start)
						mobs += M
				if(mobs:len > 3)
					var/amount = round(mobs:len / 3)
					amount = min(3, amount)
					while(amount > 0)
						var/H = pick(mobs)
						H:monkeyize()
						mobs -= H
						amount--
			spawn(0) extend_process()
		if("virus")
			spawn(50)
				var/mobs = list()
				for(var/mob/human/M in world)
					if(M:client && M:start)
						mobs += M
				if(mobs:len > 3)
					var/amount = round(mobs:len / 3)
					amount = min(3, amount)
					while(amount > 0)
						var/H = pick(mobs)
						H:virus = 1
						mobs -= H
						amount--
			spawn(0) extend_process()
	for(var/obj/start/S in world)
		del(S)
/datum/control/gameticker/proc/timeup()
	var/A = locate(/area/shuttle)
	if(!shuttle_entered)
		world << "<B>The emergency shuttle has entered the station! You have 3 minutes to enter the shuttle.</B>"
		for(var/turf/T as turf in A)
			if(T:z == 10)
				for(var/atom/movable/AM in T)
					AM:z = 1
				var/U = locate(T:x, T:y, 10)
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
		timeleft = 1800
		shuttle_entered = 1
		switch(mode)
			if("traitor")
				spawn(0) extend_process()
			if("meteor")
				spawn(0) meteor_process()
			else
				spawn(0) extend_process()
	else
		if(mode == "traitor")
			var/item
			var/traitorwin = 1
			if(objective == "alone")
				for(var/mob/M in world)
					if(M != killer && M:client)
						if(M:stat != 2)
							var/T = M:loc
							if(!istype(T, /turf))
							else
								if(T in A)
									traitorwin = 0
			else if(mode == "assassinate")
				if(target:stat != 2) traitorwin = 0
			else if(mode == "theft")
				var/L = list()
				if(killer)
					L += killer:contents
					for(var/obj/item/weapon/storage/S in killer)
						L += S:return_inv()
					for(var/obj/item/weapon/gift/G in src)
						L += G:gift
				traitorwin = 0
				switch(theft_obj)
					if("lasergun")
						for(var/obj/item/weapon/gun/laser_gun/O in L)
							if(O:charges == 25)
								traitorwin = 1
								break
						item = "a fully loaded laser gun"
					if("plasmabomb")
						for(var/obj/item/weapon/assembly/r_i_ptank/O in L)
							var/P = O:part3
							if(P:gas:plasma >= 1600000 && P:gas:temperature >= 500)
								traitorwin = 1
								break
						item = "a fully armed and heated plasma bomb"
					if("flashbang")
						for(var/obj/item/weapon/flashbang/O in L)
							traitorwin = 1
							break
						item = "a flashbang"
					if("captaincard")
						for(var/obj/item/weapon/card/id/O in L)
							if(O:access_level == 5 && (O:air_access == 5 && (O:engine_access == 5 && (O:lab_access == 5 && O:assignment == "Captain"))))
								traitorwin = 1
								break
						item = "a captain's card with universal level 5 access"
					if("sleepingpills")
						for(var/obj/item/weapon/pill_canister/O in L)
							for(var/obj/item/weapon/m_pill/sleep/P in O)
								if(P:amount == 30)
									traitorwin = 1
									break
						item = "a bottle of 30 sleeping pills"
					if("pl_flask")
						for(var/obj/item/weapon/flasks/O in L)
							if(O:plasma == 500)
								traitorwin = 1
								break
						item = "a plasma flask for cryogenics (500 units of plasma)"
			if(killer)
				var/T = killer:loc
				if(!istype(T, /turf)) traitorwin = 0
				else
					if(T in A)
						if(killer:stat == 2)
							traitorwin = 0
					else traitorwin = 0
			if(traitorwin)
				world << "<B>The traitor ([killer:rname]) wins!</B>"
			else
				world << "<B>The Research Staff has stopped the traitor ([killer:rname]) !</B>"
			switch(objective)
				if("alone")
					world << "<B>The objective was to escape alone on the shuttle.</B>"
				if("assassinate")
					world << "<B>The objective was to assassinate [target] and escape.</B>"
				if("theft")
					world << "<B>The objective was to steal [item] and escape.</B>"
		else if(mode == "monkey")
			var/monkeywin = 1
			for(var/mob/human/M in world)
				if(M:stat != 2)
					var/T = M:loc
					if(istype(T, /turf))
						if(T in A)
							monkeywin = 0
			if(monkeywin)
				monkeywin = 0
				for(var/mob/monkey/M in world)
					if(M:stat != 2)
						var/T = M:loc
						if(istype(T, /turf))
							if(T in A)
								monkeywin = 1
			if(monkeywin)
				world << "<FONT size = 3><B>The monkies have won!</B></FONT>"
				for(var/mob/monkey/M in world)
					if(M:client)
						world << "<B>[M:key] was a monkey.</B>"
			else
				world << "<FONT size = 3><B>The Research Staff has stopped he monkey invasion!</B></FONT>"
				for(var/mob/human/M in world)
					if(M:client)
						world << "<B>[M:key] was [M].</B>"
		else if(mode == "virus")
			var/humanwin = 1
			var/shuttle = list()
			for(var/mob/human/M in world)
				var/T = M:loc
				if(istype(T, /turf))
					if(T in A)
						shuttle += M
						if(M:virus > 0)
							humanwin = 0
			lbl1
			var/dead = list()
			var/alive = list()
			var/escapees = list()
			for(var/mob/M in world)
				if(M:stat == 2)
					if(M:client)
						if(M:virus > 0)
							dead += "<B>[M:rname]</B> died. \red(Had Stage [round(M:virus)] Infection)"
						else
							dead += "<B>[M:rname]</B> died."
				else
					if(shuttle:Find(M))
						if(M:virus > 0)
							escapees += "<B>[M:rname] escaped on the shuttle. \red(Has Stage [round(M:virus)] Infection)</B>"
						else
							escapees += "<B>[M:rname] escaped on the shuttle.</B>"
					else
						if(M:virus > 0)
							alive += "<B>[M:rname]</B> was left infected. \red(Has Stage [round(M:virus)] Infection)"
						else
							alive += "<B>[M:rname]</B> was left to be infected on Space Station 13."
			if(humanwin)
				world << "<FONT size = 3><B>The Research Staff have won!</B></FONT>"
			else
				world << "<FONT size = 3><B>The Virus has won!</B></FONT>"
			for(var/I in escapees)
				world << "<FONT size = 2>[I]</FONT>"
			for(var/I in alive)
				world << "<FONT size = 2>[I]</FONT>"
			for(var/I in dead)
				world << "<FONT size = 1>[I]</FONT>"
		else if(mode == "extended")
			var/L = list()
			for(var/mob/M in world)
				if(M:client)
					if(M:stat != 2)
						var/T = M:loc
						if(T in A)
							L["[M:rname]"] = "shuttle"
						else if(istype(T, /obj/machinery/pod))
							L["[M:rname]"] = "pod"
						else
							L["[M:rname]"] = "alive"
			if(L:len)
				world << "\blue<B>The game has ended!</B>"
				for(var/I in L)
					var/tem = L["[I]"]
					switch(tem)
						if("shuttle")
							world << "\t <B><FONT size = 2>[I] has left on the shuttle!</FONT></B>"
						if("pod")
							world << "\t <FONT size = 2>[I] has fled on an escape pod!</FONT>"
						if("alive")
							world << "\t <FONT size = 1>[I] decided to stay on the station.</FONT>"
			else
				world << "\blue<B>No one lived!</B>"
		else
			var/L = list()
			for(var/mob/M in world)
				if(M:client)
					if(M:stat != 2)
						var/T = M:loc
						if(T in A)
							L["[M:rname]"] = "shuttle"
						else if(istype(T, /obj/machinery/pod))
							L["[M:rname]"] = "pod"
						else
							L["[M:rname]"] = "alive"
			if(L:len)
				world << "\blue<B>The following survived the meteor attack!</B>"
				for(var/I in L)
					var/tem = L["[I]"]
					switch(tem)
						if("shuttle")
							world << "\t <B><FONT size = 2>[I] made it to the shuttle!</FONT></B>"
						if("pod")
							world << "\t <FONT size = 2>[I] at least made it to an escape pod!</FONT>"
						if("alive")
							world << "\t <FONT size = 1>[I] at least is alive.</FONT>"
			else
				world << "\blue<B>No one survived the meteor attack!</B>"
		for(var/turf/T as turf in A)
			if(T:z == 1)
				for(var/atom/movable/AM in T)
					AM:z = 10
				var/U = locate(T:x, T:y, 10)
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
		sleep(300)
		world.Reboot()
/datum/control/cellular
	var/checkfire = 0
	var/var_swap = 1
/datum/control/cellular/process()
	set background = 1
	label1
	if(!ticker)
		for(var/mob/M in world)
			spawn(0) M:UpdateClothing()
		sleep(10)
		goto label1
	for(var/turf/station/T in world)
		if(T:updatecell)
			T:updatecell()
	sleep(3)
	for(var/mob/M in world)
		spawn(0) M:Life()
	sleep(3)
	for(var/obj/move/S in world)
		S:process()
	sleep(2)
	for(var/obj/machinery/M in world)
		M:process()
	var_swap = !var_swap
	if(processing)
		sleep(2)

		goto label1

world
	mob = /mob/human
	turf = /turf/space
	tick_lag = 2
	view = "15x15"

