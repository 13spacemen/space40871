var/datum/engine_eject/engine_eject_control
var/main_hud
var/main_hud2
var/ooc_allowed = 1

var/banned = list()

var/dna_ident = 1
var/abandon_allowed = 1
var/enter_allowed = 1
var/shuttle_frozen = 0
var/prison_entered
/atom
	var/fingerprints




























/obj/point
	icon_state = "arrow"
	icon = 'screen1.dmi'
	layer = 16
/obj/point/point()
/proc/hsl2rgb(h, s, l)

/proc/stars(n, pr)
	var/te = n
	var/t = ""
	if(!pr)
		n = length(n)
		for(var/p = 1, p < n, p++)
			if(copytext(te, p, p + 1) == " " || prob(25))
				t = "[t][copytext(te, p, p + 1)]"
			else
				t = "[t]*"
	else
		n = length(n)
		for(var/p = 1, p < n, p++)
			if(copytext(te, p, p + 1) == " " || prob(pr))
				t = "[t][copytext(te, p, p + 1)]"
			else
				t = "[t]*"
	return t
/proc/stutter(n)
	var/te = n
	var/t = ""
	n = length(n)
	for(var/p = 1, p <= n, p++)
		var/n_letter = copytext(te, p, p + 1)
		if(prob(80))
			if(prob(10))
				n_letter = "[n_letter][n_letter][n_letter][n_letter]"
			else if(prob(20))
				n_letter = "[n_letter][n_letter][n_letter]"
			else if(prob(5))
				n_letter = null
			else
				n_letter = "[n_letter][n_letter]"
		t = "[t][n_letter]"
	return t
/proc/findname(msg)
	for(var/mob/M in world)
		if(M:rname == "[msg]")
			return 1
	return 0
/obj/item/weapon/grab
	name = "grab"; icon_state = "grabbed"
	var/obj/screen/grab/hud1
	var/mob/affecting
	var/mob/assailant
	var/state = 1
	var/killing = 0
	var/allow_upgrade = 1
	var/last_suffocate = 1
	icon = 'screen1.dmi'
	s_istate = "nothing"
	w_class = 5


/obj/item/weapon/grab/New()
	..()
	hud1 = new /obj/screen/grab(src)
	hud1:icon_state = "reinforce"
	hud1:name = "Reinforce Grab"
	hud1:id = 1
	hud1:master = src
/obj/item/weapon/grab/proc/synch()
	if(assailant:r_hand == src)
		hud1:screen_loc = "1,4"
	else
		hud1:screen_loc = "3,4"
/obj/item/weapon/grab/attack(mob/M, mob/user)
	if(M == affecting)
		if(state < 3)
			s_dbclick(hud1)
		else
			s_click(hud1)
	return 0
/obj/item/weapon/grab/proc/process()
	if(assailant:loc != affecting:loc && get_dist(assailant, affecting) > 1 || loc != assailant) del(src)
	if(assailant:client) assailant:client:screen -= hud1
	if(assailant:client) assailant:client:screen += hud1
	if(assailant:pulling == affecting) assailant:pulling = null
	if(state <= 2)
		allow_upgrade = 1
		if(assailant:l_hand && (assailant:l_hand != src && istype(assailant:l_hand, /obj/item/weapon/grab)))
			var/G = assailant:l_hand
			if(G:affecting != affecting)
				allow_upgrade = 0
		if(assailant:r_hand && (assailant:r_hand != src && istype(assailant:r_hand, /obj/item/weapon/grab)))
			var/G = assailant:r_hand
			if(G:affecting != affecting)
				allow_upgrade = 0
		if(state == 2)
			var/h = affecting:hand
			affecting:hand = 0
			affecting:drop_item()
			affecting:hand = 1
			affecting:drop_item()
			affecting:hand = h
			for(var/obj/item/weapon/grab/G in affecting:grabbed_by)
				if(G:state == 2)
					allow_upgrade = 0
		if(allow_upgrade)
			hud1:icon_state = "reinforce"
		else
			hud1:icon_state = "!reinforce"
	else
		affecting:loc = assailant:loc
	if(killing && state == 3)
		affecting:stunned = max(5, affecting:stunned)
		affecting:paralysis = max(3, affecting:paralysis)
		affecting:losebreath = min(affecting:losebreath + 2, 3)

/obj/item/weapon/grab/proc/s_click(obj/S)
	if(assailant:next_move > world.time) return
	if(!assailant:canmove || assailant:lying) del(src)
	switch(S:id)
		if(1)
			if(state >= 3)
				if(!killing)
					for(var/mob/O in view(src.assailant))
						O:show_message("\red[assailant] has temporarily tightened his grip on [affecting]!", 1)
					assailant:next_move = world.time + 10
					affecting:stunned = max(2, affecting:stunned)
					affecting:paralysis = max(1, affecting:paralysis)
					affecting:losebreath = min(affecting:losebreath + 1, 3)
					last_suffocate = world.time
					flick("disarm/killf", S)
/obj/item/weapon/grab/proc/s_dbclick(obj/S)
	if(assailant:next_move > world.time && !(last_suffocate < world.time + 2)) return
	if(!assailant:canmove || assailant:lying) del(src)
	switch(S:id)
		if(1)
			if(state < 2)
				if(!allow_upgrade) return
				if(prob(75))
					for(var/mob/O in view(assailant))
						O:show_message("\red[assailant] has grabbed [affecting] aggressively (now hands)!", 1)
					state = 2
					icon_state = "grabbed1"
				else
					for(var/mob/O in view(assailant))
						O:show_message("\red[assailant] has failed to grab [affecting] aggressively!", 1)
					del(src)
			else if(state < 3)
				for(var/mob/O in view(src.assailant))
					O:show_message("\red[assailant] has reinforced his grip on [affecting] (now neck)!", 1)
				state = 3
				icon_state = "grabbed+1"
				affecting:loc = assailant:loc
				hud1:icon_state = "disarm/kill"
				hud1:name = "disarm/kill"
			else if(state >= 3)
				killing = !killing
				if(killing)
					for(var/mob/O in view(src.assailant))
						O:show_message("\red[assailant] has tightened his grip on [affecting]'s neck!", 1)
					assailant:next_move = world.time + 10
					affecting:stunned = max(2, affecting:stunned)
					affecting:paralysis = max(1, affecting:paralysis)
					affecting:losebreath += 1
					hud1:icon_state = "disarm/kill1"
				else
					hud1:icon_state = "disarm/kill"
					for(var/mob/O in view(assailant))
						O:show_message("\red[assailant] has loosened the grip on [affecting]'s neck!", 1)
/obj/item/weapon/grab/dropped()
	del(src)
/obj/item/weapon/grab/Del()
	del(hud1)
	..()
/obj/dna
	var/spec_identity
	var/r_spec_identity
	var/use_enzyme
	var/struc_enzyme
	var/uni_identity
	var/n_chromo
/obj/dna/proc/cleanup()
	var/e1 = length(struc_enzyme) > 3 ? copytext(struc_enzyme, 1, 4) : null
	if(e1 == "AEC" && length(spec_identity) > n_chromo)
		r_spec_identity = spec_identity
	else if(e1 == "14A")
		var/t1 = rand(1, 3)
		for(var/t, t < t1, t++)
			var/t2 = rand(1, length(use_enzyme) + 1)
			use_enzyme = "[copytext(1, t2)]0[copytext(t2 + 1, length(use_enzyme) + 1)]"
	else if(e1 == "CDE")
		if(length(spec_identity) == length(r_spec_identity))
			spec_identity = r_spec_identity
		else
			r_spec_identity = spec_identity
	else
		spec_identity = r_spec_identity
	n_chromo = length(r_spec_identity)
























/obj/hud/hud2
	h_type = /obj/screen/screen2
/obj/hud
	var/adding
	var/other
	var/intents
	var/mov_int
	var/mon_blo
	var/m_ints
	var/vimpaired
	var/obj/screen/g_dither
	var/obj/screen/blurry
	var/h_type = /obj/screen
/obj/hud/New()
	instantiate()
	..()
/obj/hud/proc/instantiate()
	adding = list()
	other = list()
	intents = list()
	mon_blo = list()
	m_ints = list()
	mov_int = list()
	vimpaired = list()

	g_dither = new h_type(src)
	g_dither:screen_loc = "1,1 to 15,15"
	g_dither:name = "Mask"
	g_dither:icon_state = "dither12g"
	g_dither:layer = 18

	blurry = new h_type(src)
	blurry:screen_loc = "1,1 to 15,15"
	blurry:name = "Blurry"
	blurry:icon_state = "blurry"
	blurry:layer = 17

	var/obj/screen/using = new h_type(src)

	using:name = "vitals"
	using:dir = SOUTH
	using:screen_loc = "15,2 to 15,15"
	using:layer = 19
	adding += using

	using = new h_type(src)
	using:name = "actions"
	using:dir = EAST
	using:screen_loc = "4,1 to 14,1"
	using:layer = 19
	adding += using

	using = new h_type(src)
	using:dir = NORTHWEST
	using:screen_loc = "15,1"
	using:layer = 19
	adding += using

	using = new h_type(src)
	using:dir = WEST
	using:screen_loc = "1,3 to 2,3"
	using:layer = 19
	adding += using

	using = new h_type(src)
	using:dir = NORTHEAST
	using:screen_loc = "3,3"
	using:layer = 19
	adding += using

	using = new h_type(src)
	using:dir = NORTH
	using:screen_loc = "3,2"
	using:layer = 19
	adding += using

	using = new h_type(src)
	using:dir = SOUTHEAST
	using:screen_loc = "3,1"
	using:layer = 19
	adding += using

	using = new h_type(src)
	using:dir = SOUTHWEST
	using:screen_loc = "1,1 to 2,2"
	using:layer = 19
	adding += using

	using = new h_type(src)
	using:name = "drop"
	using:icon_state = "act_drop"
	using:screen_loc = "7,1"
	using:layer = 19
	adding += using

	using = new h_type(src)
	using:name = "throw"
	using:icon_state = "act_throw"
	using:screen_loc = "9,1"
	using:layer = 19
	adding += using

	using = new h_type(src)
	using:name = "swap"
	using:icon_state = "act_hand"
	using:screen_loc = "11,1"
	using:layer = 19
	adding += using

	using = new h_type(src)
	using:name = "i_clothing"
	using:dir = SOUTH
	using:icon_state = "center"
	using:screen_loc = "2,2"
	using:layer = 19
	adding += using

	using = new h_type(src)
	using:name = "o_clothing"
	using:dir = SOUTH
	using:icon_state = "equip"
	using:screen_loc = "2,1"
	using:layer = 19
	adding += using

	using = new h_type(src)
	using:name = "headset"
	using:dir = SOUTHEAST
	using:icon_state = "equip"
	using:screen_loc = "3,1"
	using:layer = 19
	adding += using

	using = new h_type(src)
	using:name = "r_hand"
	using:dir = WEST
	using:icon_state = "equip"
	using:screen_loc = "1,2"
	using:layer = 19
	adding += using

	using = new h_type(src)
	using:name = "l_hand"
	using:dir = EAST
	using:icon_state = "equip"
	using:screen_loc = "3,2"
	using:layer = 19
	adding += using

	using = new h_type(src)
	using:name = "id"
	using:dir = SOUTHWEST
	using:icon_state = "equip"
	using:screen_loc = "1,1"
	using:layer = 19
	adding += using

	using = new h_type(src)
	using:name = "mask"
	using:dir = NORTH
	using:icon_state = "equip"
	using:screen_loc = "2,3"
	using:layer = 19
	adding += using

	using = new h_type(src)
	using:name = "back"
	using:dir = NORTHEAST
	using:icon_state = "equip"
	using:screen_loc = "3,3"
	using:layer = 19
	adding += using

	using = new h_type(src)
	using:name = "storage1"
	using:icon_state = "block"
	using:screen_loc = "4,1"
	using:layer = 19
	adding += using

	using = new h_type(src)
	using:name = "storage2"
	using:icon_state = "block"
	using:screen_loc = "5,1"
	using:layer = 19
	adding += using

	using = new h_type(src)
	using:name = "resist"
	using:icon_state = "act_resist"
	using:screen_loc = "13,1"
	using:layer = 19
	adding += using

	using = new h_type(src)
	using:name = "other"
	using:icon_state = "other"
	using:screen_loc = "4,2"
	using:layer = 20
	adding += using

	using = new h_type(src)
	using:name = "intent"
	using:icon_state = "intent"
	using:screen_loc = "14,15"
	using:layer = 20
	adding += using

	using = new h_type(src)
	using:name = "m_intent"
	using:icon_state = "move"
	using:screen_loc = "14,14"
	using:layer = 20
	adding += using

	using = new h_type(src)
	using:name = "gloves"
	using:icon_state = "gloves"
	using:screen_loc = "4,2"
	using:layer = 19
	other += using

	using = new h_type(src)
	using:name = "eyes"
	using:icon_state = "glasses"
	using:screen_loc = "6,2"
	using:layer = 19
	other += using

	using = new h_type(src)
	using:name = "ears"
	using:icon_state = "ears"
	using:screen_loc = "9,2"
	using:layer = 19
	other += using

	using = new h_type(src)
	using:name = "head"
	using:icon_state = "hair"
	using:screen_loc = "7,2"
	using:layer = 19
	other += using

	using = new h_type(src)
	using:name = "shoes"
	using:icon_state = "shoes"
	using:screen_loc = "5,2"
	using:layer = 19
	other += using

	using = new h_type(src)
	using:name = "belt"
	using:icon_state = "belt"
	using:screen_loc = "8,2"
	using:layer = 19
	other += using

	using = new h_type(src)
	using:name = "grab"
	using:icon_state = "grab"
	using:screen_loc = "11,15"
	using:layer = 19
	intents += using

	using = new h_type(src)
	using:name = "hurt"
	using:icon_state = "harm"
	using:screen_loc = "14,15"
	using:layer = 19
	intents += using
	m_ints += using

	using = new h_type(src)
	using:name = "disarm"
	using:icon_state = "disarm"
	using:screen_loc = "13,15"
	using:layer = 19
	intents += using

	using = new h_type(src)
	using:name = "help"
	using:icon_state = "help"
	using:screen_loc = "12,15"
	using:layer = 19
	intents += using
	m_ints += using

	using = new h_type(src)
	using:name = "face"
	using:icon_state = "facing"
	using:screen_loc = "14,14"
	using:layer = 19
	mov_int += using

	using = new h_type(src)
	using:name = "walk"
	using:icon_state = "walking"
	using:screen_loc = "13,14"
	using:layer = 19
	mov_int += using

	using = new h_type(src)
	using:name = "run"
	using:icon_state = "running"
	using:screen_loc = "12,14"
	using:layer = 19
	mov_int += using

	using = new h_type(src)
	using:name = "blocked"
	using:icon_state = "x"
	using:screen_loc = "2,2"
	using:layer = 19
	mon_blo += using

	using = new h_type(src)
	using:name = "blocked"
	using:icon_state = "x"
	using:screen_loc = "1,1"
	using:layer = 19
	mon_blo += using

	using = new h_type(src)
	using:name = "blocked"
	using:icon_state = "x"
	using:screen_loc = "2,1"
	using:layer = 19
	mon_blo += using

	using = new h_type(src)
	using:name = "blocked"
	using:icon_state = "x"
	using:screen_loc = "3,1"
	using:layer = 19
	mon_blo += using

	using = new h_type(src)
	using:name = "blocked"
	using:icon_state = "x"
	using:screen_loc = "4,1"
	using:layer = 19
	mon_blo += using

	using = new h_type(src)
	using:name = "blocked"
	using:icon_state = "x"
	using:screen_loc = "5,1"
	using:layer = 19
	mon_blo += using

	using = new h_type(src)
	using:name = null
	using:icon_state = "dither50"
	using:screen_loc = "1,1 to 5,15"
	using:layer = 17
	vimpaired += using

	using = new h_type(src)
	using:name = null
	using:icon_state = "dither50"
	using:screen_loc = "5,1 to 10,5"
	using:layer = 17
	vimpaired += using

	using = new h_type(src)
	using:name = null
	using:icon_state = "dither50"
	using:screen_loc = "6,11 to 10,15"
	using:layer = 17
	vimpaired += using

	using = new h_type(src)
	using:name = null
	using:icon_state = "dither50"
	using:screen_loc = "11,1 to 15,15"
	using:layer = 17
	vimpaired += using


/atom/movable/Move(NewLoc, direct)
	if(direct & direct - 1)
		if(direct & 1)
			if(direct & 4)
				if(step(src, NORTH))
					step(src, EAST)
				else if(step(src, EAST))
					step(src, NORTH)
			else if(direct & 8)
				if(step(src, NORTH))
					step(src, WEST)
				else if(step(src, WEST))
					step(src, NORTH)
		else if(direct & 2)
			if(direct & 4)
				if(step(src, SOUTH))
					step(src, EAST)
				else if(step(src, EAST))
					step(src, SOUTH)
			else if(direct & 8)
				if(step(src, SOUTH))
					step(src, WEST)
				else if(step(src, WEST))
					step(src, SOUTH)
	else ..()
/atom/verb/examine()
	set src in oview(1)
	if(!usr) return
	usr << desc

/atom/movable/verb/pull()
	set src in oview(1)
	if(!usr) return
	if(!anchored)
		usr.pulling = src

/obj/proc/alter_health()
	return 1
/obj/proc/relaymove()
/obj/screen/grab
	var/master
/obj/screen/screen2
	icon = 'screen.dmi'
/obj/screen
	icon = 'screen1.dmi'; layer = 20
/obj/screen/grab/Click()
	master:s_click(src)
/obj/screen/grab/DblClick()
	master:s_dbclick(src)
/obj/screen/grab/attack_hand()
/obj/screen/grab/attackby()
/obj/screen
	var/id = 0
/obj/screen/Click()
	switch(name)
		if("other")
			usr.other = !usr.other
		if("intent")
			if(!usr.intent)
				switch(usr.a_intent)
					if("help")
						usr.intent = "12,15"
					if("disarm")
						usr.intent = "13,15"
					if("hurt")
						usr.intent = "14,15"
					if("grab")
						usr.intent = "11,15"
			else
				usr.intent = null
		if("m_intent")
			if(!usr.m_int)
				switch(usr.m_intent)
					if("run")
						usr.m_int = "12,14"
					if("walk")
						usr.m_int = "13,14"
					if("face")
						usr.m_int = "14,14"
			else
				usr.m_int = null
		if("walk")
			usr.m_intent = "walk"
			usr.m_int = "13,14"
		if("face")
			usr.m_intent = "face"
			usr.m_int = "14,14"
		if("run")
			usr.m_intent = "run"
			usr.m_int = "12,14"
		if("hurt")
			usr.a_intent = "hurt"
			usr.intent = "14,15"
		if("grab")
			usr.a_intent = "grab"
			usr.intent = "11,15"
		if("disarm")
			if(istype(usr, /mob/human))
				var/M = usr
				M:a_intent = "disarm"
				M:intent = "13,15"
		if("help")
			usr.a_intent = "help"
			usr.intent = "12,15"
		if("Reset Machine")
			usr.machine = null
		if("internal")
			if(!usr.stat && (usr.canmove && !usr.restrained()))
				usr.internal = null
		if("pull")
			usr.pulling = null
		if("sleep")
			usr.sleeping = !usr.sleeping
		if("rest")
			usr.resting = !usr.resting
		if("throw")
			if(!usr.stat && (usr.canmove && !usr.restrained()))
				usr.throw_item_v()
		if("drop")
			usr.drop_item_v()
		if("swap")
			usr.swap_hand()
		if("resist")
			if(!usr.stat && (usr.canmove && (!usr.restrained() && (usr.requests && usr.requests:len))))
				for(var/obj/O in usr.requests)
					del(O)
				for(var/mob/O in view(usr))
					O:show_message("\red<B>[usr] resists!</B>", 1)
/obj/screen/attack_hand(mob/user, using)
	user:db_click(name, using)
/obj/screen/attack_paw(mob/user, using)
	user:db_click(name, using)
/mob/verb/mode()
	set src = usr
	var/W = equipped()
	if(W) W:attack_self(src)


/client/Northeast()
	mob:swap_hand()
/client/Southeast()
	var/W = mob:equipped()
	if(W) W:attack_self(mob)
/client/Northwest()
	mob:drop_item_v()
/client/Southwest()
	mob:throw_item_v()
/client
	var/move_delay = 1
/client/Center()
	if(isobj(mob:loc))
		var/O = mob:loc
		if(mob:canmove)
			return O:relaymove(mob, 16)
/client/Move(n, direct)
	if(moving) return 0
	if(world.time < move_delay) return
	if(!mob) return
	if(mob:stat == 2) return
	if(mob:monkeyizing) return
	if(mob:grabbed_by:len > 0)
		var/grabbing = list()
		if(istype(mob:l_hand, /obj/item/weapon/grab))
			var/G = mob:l_hand
			grabbing += G:affecting
		if(istype(mob:r_hand, /obj/item/weapon/grab))
			var/G = mob:r_hand
			grabbing += G:affecting
		for(var/obj/item/weapon/grab/G in mob:grabbed_by)
			if(G:state == 1)
				if(!grabbing:Find(G:assailant))
					del(G)
			else if(G:state == 2)
				move_delay = world.time + 10
				if(prob(25))
					for(var/mob/O in view(src.mob))
						O:show_message("\red[mob] has broken free of [G:assailant]'s grip!", 1)
					del(G)
				else
					return
			else if(G:state == 2)
				move_delay = world.time + 10
				if(prob(5))
					for(var/mob/O in view(src.mob))
						O:show_message("\red[mob] has broken free of [G:assailant]'s headlock!", 1)
					del(G)
				else
					return
	if(mob:canmove)
		var/j_pack = 0
		if(istype(mob:loc, /turf/space) && !(locate(/obj/move) in mob:loc))
			if(!mob:restrained())
				if(!((locate(/obj/grille) in oview(1, mob)) || (locate(/turf/station) in oview(1, mob))))
					if(istype(mob:back, /obj/item/weapon/tank/jetpack))
						var/J = mob:back
						j_pack = J:allow_thrust(100, mob)
						var/I = new /obj/effects/sparks/ion_trails(mob:loc)
						flick("ion_fade", I)
						I:icon_state = "blank"
						spawn(20) del(I)
						if(!j_pack) return 0
					else return 0
			else return 0
		if(isturf(mob:loc))




			move_delay = world.time
			if(j_pack && j_pack < 1)
				move_delay += 5
			switch(mob:m_intent)
				if("run")
					if(mob:drowsyness > 0)
						move_delay += 6
					move_delay += 1
				if("face")
					mob:dir = direct
					return
				if("walk")
					move_delay += 7
			move_delay += mob:m_delay()
			move_delay += round((100 - mob:health) / 20)
			if(mob:restrained())
				for(var/mob/M in range(mob, 1))
					if(M:pulling == mob && (!M:restrained() && M:stat == 0) || mob:grabbed_by:len)
						src << "\blue Your restrained! You can't move!"
						return 0
			moving = 1
			if(locate(/obj/item/weapon/grab) in mob)
				move_delay = max(move_delay, world.time + 7)
				var/L = mob:ret_grab()
				if(istype(L, /list))
					if(L:len == 2)
						L -= mob
						var/M = L[1]
						if(get_dist(mob, M) <= 1 || M:loc == mob:loc)
							var/T = mob:loc
							. = ..()
							if(isturf(M:loc))
								var/diag = get_dir(mob, M)
								if(diag - 1 & diag)
								else diag = null
								if(get_dist(mob, M) > 1 || diag)
									step(M, get_dir(M:loc, T))
					else
						for(var/mob/M in L)
							M:other_mobs = 1
							if(mob != M) M:animate_movement = 3
						for(var/mob/M in L)
							spawn(0) step(M, direct)
							spawn(1)
								M:other_mobs = null
								M:animate_movement = 1
			else
				. = ..()
			moving = null
			return .
		else if(isobj(mob:loc))
			var/O = mob:loc
			if(mob:canmove)
				return O:relaymove(mob, direct)
	else return


/mob/CheckPass(mob/M)
	if(other_mobs && (ismob(M) && M:other_mobs)) return 1
	else return !M:density || (!density || lying)





























/mob{var/other_mobs}
/client
	var/moving
/mob
	var/sdisabilities = 0
	var/disabilities = 0
	var/pulling
	var/stat = 0
	var/next_move
	var/monkeyizing
	var/other = 0
	var/hand
	var/eye_blind
	var/eye_blurry
	var/ear_deaf
	var/ear_damage
	var/stuttering
	var/rname
	var/blinded
	var/rejuv
	var/r_epil
	var/r_ch_cou
	var/r_Tourette
	var/antitoxs
	var/plasma
	var/virus = 0
	var/sleeping = 0
	var/resting = 0
	var/lying = 0
	var/canmove = 1
	var/eye_stat
	var/oxyloss = 0
	var/toxloss = 0
	var/fireloss = 0
	var/bruteloss = 0
	var/cpr_time = 1
	var/health = 100
	var/drowsyness = 0
	var/paralysis = 0
	var/stunned = 0
	var/weakened = 0
	var/losebreath = 0
	var/muted
	var/intent
	var/a_intent = "disarm"
	var/m_int
	var/m_intent = "walk"
	var/buckled
	var/primary
	var/obj/item/weapon/handcuffs/handcuffed
	var/obj/item/weapon/l_hand
	var/obj/item/weapon/r_hand
	var/obj/item/weapon/back
	var/obj/item/weapon/tank/internal
	var/obj/item/weapon/storage/s_active
	var/obj/item/weapon/clothing/mask/wear_mask
	var/obj/screen/flash
	var/obj/screen/blind
	var/obj/screen/hands
	var/obj/screen/mach
	var/obj/screen/sleep
	var/obj/screen/rest
	var/obj/screen/pullin
	var/obj/screen/internals
	var/obj/screen/oxygen
	var/obj/screen/i_select
	var/obj/screen/m_select
	var/obj/screen/toxin
	var/obj/screen/fire
	var/obj/screen/healths
	var/obj/screen/zone_sel
	var/hud_used
	var/start
	density = 1
/mob
	var/grabbed_by = list()
/mob/verb/help()
	src << browse('help.htm', "window=help")
/mob/verb/changes()
	src << browse("<PRE>[changes]</PRE>", "window=changes")
/mob/verb/succumb()
	set hidden = 1
	if(health < 0 && health > -95)
		oxyloss += health + 99
		health = 100 - oxyloss - toxloss - fireloss - bruteloss
		usr << "\blue You have given up life and succumbed to death."
/mob/layer = 4







/mob/proc/show_message(msg, type, alt, alt_type)
	if(type)
		if(type & 1 && (sdisabilities & 1 || (blinded || paralysis)))
			if(!alt)
				return
			else
				msg = alt
				type = alt_type
		if(type & 2 && (sdisabilities & 4 || ear_deaf))
			if(!alt)
				return
			else
				msg = alt
				type = alt_type
				if(type & 1 && sdisabilities & 1) return
	src << msg
/mob/proc/findname(msg)
	for(var/mob/M in world)
		if(M:rname == "[msg]")
			return 1
	return 0
/mob/burn(fi_amount)
	for(var/atom/movable/A in src)
		A:burn(fi_amount)
/mob/Topic(href, href_list)
	if(href_list["mach_close"])
		var/t1 = "window=[href_list["mach_close"]]"
		machine = null
		src << browse(null, t1)
	..()

/mob
	var/requests = list()
/mob/MouseDrop(mob/M)
	..()
	if(M != usr || (usr == src || get_dist(usr, src) > 1)) return
	show_inv(usr)

/mob/proc/m_delay()
/mob/proc/Life()
/mob/proc/UpdateClothing()
/mob/proc/death()
/mob/proc/restrained()
	if(handcuffed)
		return 1

/mob/human/restrained()
	if(handcuffed)
		return 1
	if(istype(wear_suit, /obj/item/weapon/clothing/suit/straight_jacket))
		return 1
	return 0

/mob/proc/db_click(text, t1)
	var/obj/item/weapon/W = equipped()
	switch(text)
		if("mask")
			if(wear_mask) return
			if(!istype(W, /obj/item/weapon/clothing/mask)) return
			u_equip(W)
			wear_mask = W
		if("back")
			if(back || !istype(W, /obj/item/weapon)) return
			if(!(W:flags & 1)) return
			u_equip(W)
			back = W
/mob/verb/say()
/mob/verb/observe()
	if(stat != 2)
		usr << "\blue You must be dead to use this!"
		return
	client:perspective = EYE_PERSPECTIVE
	client:eye = input("Please, select a player!", "Watch") as mob in world
/mob/verb/listen_ooc()
	if(client)
		client:listen_ooc = !client:listen_ooc
		if(client:listen_ooc)
			src << "\blue You are now listening to messages on the OOC channel. <B>Don't abuse this!</B>"
		else
			src << "\blue You are no longer listening to messages on the OOC channel."
/mob/verb/ooc(msg as text)
	msg = copytext(msg, 1, 128)
	if(ooc_allowed && !muted)
		for(var/mob/M in world)
			if(M:client && M:client:listen_ooc) M << "<B>OOC: [key]</B>: [msg]"
/mob/las_act(flag)
	if(flag)
		if(prob(75)) stunned = 10
		else
			weakened = 10
	else
		if(stat != 2)
			bruteloss += 20
			health = 100 - oxyloss - toxloss - fireloss - bruteloss
			if(prob(25)) stunned = 2
/mob/proc/throw_item()
	var/W = equipped()
	if(W)
		u_equip(W)
		if(client) client:screen -= W
		if(usr.stat) return
		W:loc = loc
		W:dropped(src)
		if(W)
			W:layer = initial(W:layer)
			for(var/mob/O in view(src))
				O:show_message("\red[src] has thrown [W].", 1)
			W:density = 1
			W:throwing = 1
			W:throwspeed = initial(W:throwspeed)
			spawn(0) W:throwing(dir)
/mob/proc/swap_hand()
	hand = !hand
	if(!hand)
		hands:dir = NORTH
	else
		hands:dir = SOUTH
/mob/proc/drop_item_v()
	if(stat == 0)
		drop_item()
/mob/proc/throw_item_v()
	if(stat == 0)
		throw_item()
/mob/proc/drop_item()
	var/W = equipped()
	if(W)
		u_equip(W)
		if(client) client:screen -= W
		if(W)
			W:loc = loc
			W:dropped(src)
			if(W) W:layer = initial(W:layer)
/mob/proc/reset_view(A as mob|obj)
	if(client)
		if(istype(A, /atom/movable))
			client:perspective = EYE_PERSPECTIVE
			client:eye = A
		else
			if(isturf(loc))
				client:eye = client:mob
				client:perspective = MOB_PERSPECTIVE
			else
				client:perspective = EYE_PERSPECTIVE
				client:eye = loc
/mob/proc/who()
	set category = "Admin"
	var/total = 0
	usr << "<B>Current Players:</B>"
	for(var/mob/M in world)
		if(M:client)
			total++
			usr << "\t [M] ([M:client])"
	usr << "<B>Total Players: [total]</B>"
/mob/proc/list_dna()
	set category = "Admin"
	usr << "<B>Registered DNA sequences:</B>"
	for(var/M in reg_dna)
		usr << "\t [M] = [reg_dna["[M]"]]"
/mob/proc/equipped()
	if(hand)
		return l_hand
	else
		return r_hand
/mob/verb/countobj()
	var/total
	for(var/obj/O in world)
		total++
	usr << "There are [total] objects in the world!"
/mob/verb/switch_hud()
	client:screen -= main_hud:contents
	client:screen -= main_hud2:contents
	if(hud_used == main_hud)
		hud_used = main_hud2
		oxygen:icon = 'screen.dmi'
		toxin:icon = 'screen.dmi'
		internals:icon = 'screen.dmi'
		mach:icon = 'screen.dmi'
		fire:icon = 'screen.dmi'
		healths:icon = 'screen.dmi'
		pullin:icon = 'screen.dmi'
		blind:icon = 'screen.dmi'
		hands:icon = 'screen.dmi'
		flash:icon = 'screen.dmi'
		sleep:icon = 'screen.dmi'
		rest:icon = 'screen.dmi'
	else
		hud_used = main_hud
		oxygen:icon = 'screen1.dmi'
		toxin:icon = 'screen1.dmi'
		internals:icon = 'screen1.dmi'
		mach:icon = 'screen1.dmi'
		fire:icon = 'screen1.dmi'
		healths:icon = 'screen1.dmi'
		pullin:icon = 'screen1.dmi'
		blind:icon = 'screen1.dmi'
		hands:icon = 'screen1.dmi'
		flash:icon = 'screen1.dmi'
		sleep:icon = 'screen1.dmi'
		rest:icon = 'screen1.dmi'
	client:screen -= hud_used:adding
	client:screen += hud_used:adding
/mob/proc/show_inv(mob/user)
	user:machine = src
	var/dat = {"<TT>
<B><FONT size=3>[name]</FONT></B><BR>
\t<B>Head(Mask):</B> <A href='?src=\ref[src];item=mask'>[wear_mask ? "[wear_mask]" : "Nothing"]</A><BR>
\t<B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[l_hand ? "[l_hand]" : "Nothing"]</A><BR>
\t<B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[r_hand ? "[r_hand]" : "Nothing"]</A><BR>
\t<B>Back:</B> <A href='?src=\ref[src];item=back'>[back ? "[back]" : "Nothing"]</A><BR>
\t[istype(wear_mask, /obj/item/weapon/clothing/mask) && (istype(back, /obj/item/weapon/tank) && !internal) ? " <A href='?src=\ref[src];item=internal'>Set Internal</A>" : ""]<BR>
\t[internal ? "<A href='?src=\ref[src];item=internal'>Remove Internal</A>" : ""]<BR>
\t[handcuffed ? "<A href='?src=\ref[src];item=handcuff'>Handcuffed</A>" : "<A href='?src=\ref[src];item=handcuff'>Not Handcuffed</A>"]<BR>
\t<A href='?src=\ref[src];item=pockets'>Empty Pockets</A><BR>
<A href='?src=\ref[user];mach_close=mob[name]'>Close</A><BR>
</TT>"}
	user << browse(dat, "window=mob[name]")
/mob/proc/u_equip(obj/W)
	if(W == r_hand)
		r_hand = null
	else if(W == l_hand)
		l_hand = null
	else if(W == handcuffed)
		handcuffed = null
	else if(W == back)
		back = null
	else if(W == wear_mask)
		wear_mask = null
/mob/proc/toggle_ooc()
	set category = "Admin"
	ooc_allowed = !ooc_allowed
	if(ooc_allowed)
		world << "<B>The OOC channel has been globally enabled!</B>"
	else
		world << "<B>The OOC channel has been globally disabled!</B>"
/mob/proc/toggle_abandon()
	set category = "Admin"
	abandon_allowed = !abandon_allowed
	if(abandon_allowed)
		world << "<B>You may now abandon mob.</B>"
	else
		world << "<B>Live or Die Mode Activated</B>"
/mob/proc/toggle_enter()
	set category = "Admin"
	enter_allowed = !enter_allowed
	if(enter_allowed)
		world << "<B>You may enter the game.</B>"
	else
		world << "<B>You may no longer enter the game.</B>"
/mob/proc/toggle_shuttle()
	set category = "Admin"
	shuttle_frozen = !shuttle_frozen
	if(shuttle_frozen)
		world << "<B>The shuttle count is now FROZEN!</B>"
	else
		world << "<B>The shuttle has been thawed.</B>"
/mob/proc/show_ctf()
	set category = "Admin"
	if(ticker)
		usr << "Too late... The game has already started!"
		return
	else
		if(!ctf)
			ctf = new /obj/ctf_assist()
		ctf:show_screen(usr)

/mob/proc/delay_start()
	set category = "Admin"
	if(ticker)
		usr << "Too late... The game has already started!"
		return
	else
		if(alert(usr, "Would you like to delay game start?", "Delay Start", "Yes", "No") == "Yes")
			going = null
			world << "<B>The game start has been delayed by [usr.key] (Administrator to SS13)</B>"
			usr << alert("Don't forgot to revoke the delay by selecting No!")
		else
			world << "<B>The game will now start thanks to [usr.key] (Administrator to SS13)</B>"
			going = 1
/mob/proc/mute(mob/M in world)
	set category = "Admin"
	M:muted = !M:muted
	usr << "[M]'s chat status is now [M:muted ? "muted" : "voiced"]."
/mob/proc/change_name(mob/M in world, t as text)
	set category = "Admin"
	usr << "[M]'s default name is now [t] !"
	M:rname = t
/mob/proc/show_help(mob/M in world)
	set category = "Admin"
	M << browse('help.htm', "window=help")
/mob/proc/changemessage(txt as text)
	set name = "Change Message"
	set category = "Admin"
	world_message = "[key]: [txt]"
	world << "\blue<B>[world_message]</B>"
/mob/proc/changemode()
	set name = "Set Game Mode"
	set category = "Admin"
	if(ticker)
		return
	var/temp = input("Please select a mode", "Game Mode") in list("secret", "traitor", "meteor", "extended", "monkey")
	master_mode = temp
/mob/proc/boot(mob/M in world, txt as text)
	set category = "Admin"
	if(M && (M:client && txt)) del(M:client)
/mob/proc/ban(mob/M in world, txt as text)
	set category = "Admin"
	if(M && (M:client && txt))
		banned += M:ckey
		del(M:client)
/mob/proc/unban()
	set category = "Admin"
	var/t = input(usr, "Unban who?") as null|anything in banned
	banned -= t
/mob/proc/make_gift()
	set category = "Admin"
	new /obj/item/weapon/a_gift(loc)
/mob/proc/make_pill()
	set category = "Admin"
	new /obj/item/weapon/m_pill/superpill(loc)
/mob/proc/make_flag()
	set category = "Admin"
	var/color = input("Please select a color") in list("red", "blue", "green", "yellow", "black", "white", "neutral")

	var/F = new /obj/item/weapon/paper/flag(loc)
	F:icon_state = "flag_[color]"
/mob/proc/restart()
	set category = "Admin"
	world << "\green<B> Restarting world!"
	sleep(50)
	world.Reboot()
/mob/proc/monkey(mob/M in world)
	set category = "Admin"
	set hidden = 1
	for(var/obj/O in M)
		del(O)
	var/O = new /mob/monkey(M:loc)
	M:client:mob = O
	O:loc = M:loc
	del(M)
/mob/proc/toggle_alter()
	set category = "Admin"
	if(verbs:Find(/mob/proc/carboncopy))
		verbs -= /mob/proc/carboncopy
	else
		verbs -= /mob/proc/carboncopy
		verbs += /mob/proc/carboncopy
/mob/proc/carboncopy(O as mob|obj in world)
	var/M = O
	if(istype(M, /mob) && M:key)
		usr << "You can't duplicate PCs' mobs."
		return
	var/new_O = new O:type(usr.loc)
	for(var/V in O:vars)
		if(issaved(O:vars[V])) new_O:vars[V] = O:vars[V]
/mob/proc/secrets(pass as text)
	set category = "Admin"
	switch(pass)
		if("sec_clothes")
			for(var/obj/item/weapon/clothing/under/O in world)
				del(O)
		if("sec_all_clothes")
			for(var/obj/item/weapon/clothing/O in world)
				del(O)
		if("sec_classic1")
			for(var/obj/item/weapon/clothing/suit/firesuit/O in world)
				del(O)
			for(var/obj/grille/O in world)
				del(O)
			for(var/obj/machinery/pod/O in world)
				del(O)
		if("clear_bombs")
			for(var/obj/item/weapon/assembly/r_i_ptank/O in world)
				del(O)
		if("list_bombers")
			usr << "\blue<B>Don't be insane about this lsit</B> Get the facts."
			for(var/l in bombers)
				usr << "[l] 'made' a bomb."
		if("check_antagonist")
			if(ticker)
				if(ticker:killer)
					if(ticker:killer:ckey)
						usr << "<B>The traitor's key is [ticker:killer:ckey].</B>"
					else
						usr << "<B>It seems like the traitor logged out...</B>"
				else
					usr << "<B>There is no traitor.</B>"
			else
				usr << "<B>The game has not started yet.</B>"
/mob/ghost
	icon_state = "ghost"
/mob/ghost/proc/infest()
/mob/ghost/Move()
	if(stunned) return
	. = ..()
/mob/ghost/show_inv()
	return
/mob/ghost/Bump()
	return
/mob/ghost/UpdateClothing()
	for(var/i in overlays)
		overlays -= i
	if(wear_mask)
		if(istype(wear_mask, /obj/item/weapon/clothing/mask))
			var/t1 = wear_mask:s_istate
			if(!t1) t1 = wear_mask:icon_state
			src.overlays += image(icon = 'ghost.dmi', icon_state = "[t1][!lying ? null : "2"]", layer = layer)
		wear_mask:screen_loc = "2,3"
	if(r_hand)
		var/t1 = r_hand:s_istate
		if(!t1) t1 = r_hand:icon_state
		src.overlays += image(icon = 'r_items.dmi', icon_state = t1, layer = layer)
		r_hand:screen_loc = "1,2"
	if(l_hand)
		var/t1 = l_hand:s_istate
		if(!t1) t1 = l_hand:icon_state
		src.overlays += image(icon = 'l_items.dmi', icon_state = t1, layer = layer)
		l_hand:screen_loc = "3,2"
	if(client)
		client:screen -= contents
		client:screen += contents
/mob/ghost/Life()
	if(stat == 2)
		death()
		return
	canmove = 1
	lying = 1
	stat = 0
	if(weakened > 0)
		weakened--
		icon_state = "ghost"
	else
		icon_state = "blank"
	if(stunned > 0)
		stunned--
		canmove = 0
		for(var/obj/item/O in src)
			O:loc = loc
			O:layer = initial(O:layer)
			u_equip(O)
	if(health < 0)
		stat = 2
	return
/mob/ghost/db_click()
	return
/mob/ghost/equipped()
	return null
/mob/ghost/m_delay()
	return -100
/mob/ghost/reset_view()
	if(client)
		client:eye = src
	else return ..()
/mob/ghost/las_act()
	return
/mob/ghost/ex_act()
	return
/mob/ghost/attack_hand(mob/M)
	infest(M)
/mob/ghost/attack_paw(mob/M)
	infest(M)
/mob/ghost/death()
	stunned = 1
/mob/ghost/meteorhit()
	return
/mob/ghost/restrained()
	return 0
/mob/ghost/attackby(nothing, mob/M)
	infest(M)
	return 0
/mob/ghost/say(msg as text)
	if(!msg) return
	msg = stutter(msg)
	if(prob(25)) msg = stars(msg)
	for(var/mob/M in oview())
		M:show_message(msg, 2)
/mob/monkey
	var/t_plasma
	var/t_oxygen
	var/t_sl_gas
	var/t_n2
	var/now_pushing
	icon = 'monkey.dmi'
/mob/monkey/New()
	spawn(50)
		if(!primary)
			var/t1 = rand(1000, 1500)
			dna_ident += t1
			if(dna_ident > 65536)
				dna_ident = rand(1, 1500)
			primary = new /obj/dna(null)
			primary:uni_identity = "[dna_ident]"
			while(length(primary:uni_identity) < 4)
				primary:uni_identity = "0[primary:uni_identity]"
			var/t2 = "[rand(1, 256)]"
			if(length(t2) < 2)
				primary:uni_identity = "[primary:uni_identity]0[t2]"
			else
				primary:uni_identity = "[primary:uni_identity][t2]"
			t2 = "[rand(1, 256)]"
			if(length(t2) < 2)
				primary:uni_identity = "[primary:uni_identity]0[t2]"
			else
				primary:uni_identity = "[primary:uni_identity][t2]"
			t2 = "[rand(1, 256)]"
			if(length(t2) < 2)
				primary:uni_identity = "[primary:uni_identity]0[t2]"
			else
				primary:uni_identity = "[primary:uni_identity][t2]"
			t2 = "[rand(1, 256)]"
			if(length(t2) < 2)
				primary:uni_identity = "[primary:uni_identity]0[t2]"
			else
				primary:uni_identity = "[primary:uni_identity][t2]"
			t2 = gender == "male" ? "[rand(1, 124)]" : "[rand(127, 250)]"
			if(length(t2) < 2)
				primary:uni_identity = "[primary:uni_identity]0[t2]"
			else
				primary:uni_identity = "[primary:uni_identity][t2]"
			primary:spec_identity = "2B6696D2B127E5A4"
			primary:struc_enzyme = "CDEAF5B90AADBC6BA8033DB0A7FD613FA"
			primary:use_enzyme = "C8FFFE7EC09D80AEDEDB9A5A0B4085B61"
			primary:n_chromo = 16
	..()
/mob/monkey/Bump(AM as mob|obj, yes)
	if(!yes || now_pushing) return
	..()
	if(!istype(AM, /atom/movable)) return
	if(!now_pushing)
		now_pushing = 1
		if(!AM:anchored)
			var/t = get_dir(src, AM)
			step(AM, t)
		now_pushing = null
/mob/monkey
	icon_state = "monkey1"
/mob/monkey/Topic(href, href_list)
	if(href_list["mach_close"])
		var/t1 = "window=[href_list["mach_close"]]"
		machine = null
		src << browse(null, t1)
	if(href_list["item"] && (!usr.stat && (!usr.restrained() && get_dist(src, usr) <= 1)))
		var/obj/equip_e/monkey/O = new /obj/equip_e/monkey()
		O:source = usr
		O:target = src
		O:item = usr.equipped()
		O:s_loc = usr.loc
		O:t_loc = loc
		O:place = href_list["item"]
		requests += O
		spawn(0) O:process()
	..()
/mob/monkey/flags = 258
/mob/monkey/meteorhit(obj/O)
	for(var/mob/M in view(src))
		M:show_message("\red[src] has been hit with by [O]", 1)
	if(health > 0)
		var/shielded = 0
		for(var/obj/item/weapon/shield/S in src)
			if(S:active)
				shielded = 1
				break
		bruteloss += 30
		health = 100 - oxyloss - toxloss - fireloss - bruteloss
		if(O:icon_state == "flaming" && !shielded)
			fireloss += 40
			health = 100 - oxyloss - toxloss - fireloss - bruteloss
/mob/monkey/las_act(flag)
	if(flag)
		if(prob(75))
			stunned = 15
		else weakened = 15
	else
		if(stat != 2)
			bruteloss += 20
			health = 100 - oxyloss - toxloss - fireloss - bruteloss
			if(prob(25)) stunned = 1
/mob/monkey/hand_p(mob/M)
	if(M:a_intent == "hurt" && !istype(wear_mask, /obj/item/weapon/clothing/mask/muzzle))
		if(prob(75) && health > 0)
			for(var/mob/O in view(src))
				O:show_message("\red<B>The monkey has bit [src]!</B>", 1)
			var/damage = rand(1, 5)
			bruteloss += damage
			health = 100 - oxyloss - toxloss - fireloss - bruteloss
		else
			for(var/mob/O in view(src))
				O:show_message("\red<B>The monkey has attempted to bite [src]!</B>", 1)
/mob/monkey/attack_paw(mob/M)
	if(M:a_intent == "help")
		sleeping = 0
		resting = 0
		for(var/mob/O in view(src))
			O:show_message("\blue The monkey shakes the monkey trying to wake him up!", 1)
	else if(M:a_intent == "hurt" && !istype(wear_mask, /obj/item/weapon/clothing/mask/muzzle))
		if(prob(75) && health > 0)
			for(var/mob/O in view(src))
				O:show_message("\red<B>The monkey has bit the monkey!</B>", 1)
			var/damage = rand(1, 5)
			bruteloss += damage
			health = 100 - oxyloss - toxloss - fireloss - bruteloss
		else
			for(var/mob/O in view(src))
				O:show_message("\red<B>The monkey has attempted to bite the monkey!</B>", 1)

/mob/monkey/attack_hand(M as mob)
	if(M:a_intent == "help")
		sleeping = 0
		resting = 0
		for(var/mob/O in view(src))
			if(O:client && !O:blinded)
				O:show_message("\blue[M] shakes the monkey trying to wake him up!", 1)
	else if(M:a_intent == "hurt")
		if(prob(75) && health > 0)
			for(var/mob/O in view(src))
				if(O:client && !O:blinded)
					O:show_message("\red<B>[M] has punched the monkey!</B>", 1)
			var/damage = rand(5, 10)
			if(prob(40))
				damage = rand(10, 15)
				if(paralysis < 5)
					paralysis = rand(10, 15)
					spawn(0)
						for(var/mob/O in view(src))
							if(O:client && !O:blinded)
								O:show_message("\red<B>[M] has knocked out the monkey!</B>", 1)
			bruteloss += damage
			health = 100 - oxyloss - toxloss - fireloss - bruteloss
		else
			for(var/mob/O in view(src))
				if(O:client && !O:blinded)
					O:show_message("\red<B>[M] has attempted to punch the monkey!</B>", 1)
	else if(!paralysis)
		if(prob(25))
			paralysis = 2
			for(var/mob/O in view(src))
				if(O:client && !O:blinded)
					O:show_message("\red<B>[M] has pushed down the monkey!</B>", 1)
		else
			drop_item()
			for(var/mob/O in view(src))
				if(O:client && !O:blinded)
					O:show_message("\red<B>[M] has disarmed the monkey!</B>", 1)
/mob/monkey/Stat()
	..()
	statpanel("Status")
	stat(, "Intent: [a_intent]")
	stat(, "Move Mode: [m_intent]")
/mob/monkey/UpdateClothing()
	..()
	for(var/i in overlays)
		overlays -= i
	if(!lying)
		icon_state = "monkey1"
	else
		icon_state = "monkey0"
	if(wear_mask)
		if(istype(wear_mask, /obj/item/weapon/clothing/mask))
			var/t1 = wear_mask:s_istate
			if(!t1) t1 = wear_mask:icon_state
			src.overlays += image(icon = 'monkey.dmi', icon_state = "[t1][!lying ? null : "2"]", layer = layer)
		wear_mask:screen_loc = "2,3"
	if(r_hand)
		var/t1 = r_hand:s_istate
		if(!t1) t1 = r_hand:icon_state
		src.overlays += image(icon = 'r_items.dmi', icon_state = t1, layer = layer)
		r_hand:screen_loc = "1,2"
	if(l_hand)
		var/t1 = l_hand:s_istate
		if(!t1) t1 = l_hand:icon_state
		src.overlays += image(icon = 'l_items.dmi', icon_state = t1, layer = layer)
		l_hand:screen_loc = "3,2"
	if(back)
		if(!lying)
			overlays += image(icon = 'monkey.dmi', icon_state = "back", layer = src.layer)
		else
			overlays += image(icon = 'monkey.dmi', icon_state = "back2", layer = src.layer)
		back:screen_loc = "3,3"
	if(handcuffed)
		pulling = null
		if(!lying)
			overlays += image(icon = 'monkey.dmi', icon_state = "handcuff1", layer = src.layer)
		else
			overlays += image(icon = 'monkey.dmi', icon_state = "handcuff2", layer = src.layer)
	if(client)
		client:screen -= contents
		client:screen += contents
		client:screen -= hud_used:m_ints
		client:screen -= hud_used:mov_int
		if(i_select)
			if(intent)
				client:screen += hud_used:m_ints
				i_select:screen_loc = intent
			else
				i_select:screen_loc = null
		if(m_select)
			if(m_int)
				client:screen += hud_used:mov_int
				m_select:screen_loc = m_int
			else
				m_select:screen_loc = null
	for(var/mob/M in view(1, src))
		if(M:client && M:machine == src)
			spawn(0) show_inv(M)
/mob/monkey/Login()
	if(banned:Find(ckey))
		del(client)
	client:screen -= main_hud:contents
	client:screen -= main_hud2:contents
	if(!hud_used) hud_used = main_hud
	next_move = 1
	if(!rname) rname = key
	oxygen = new /obj/screen(null)
	i_select = new /obj/screen(null)
	m_select = new /obj/screen(null)
	toxin = new /obj/screen(null)
	internals = new /obj/screen(null)
	mach = new /obj/screen(null)
	fire = new /obj/screen(null)
	healths = new /obj/screen(null)
	pullin = new /obj/screen(null)
	blind = new /obj/screen(null)
	flash = new /obj/screen(null)
	hands = new /obj/screen(null)
	sleep = new /obj/screen(null)
	rest = new /obj/screen(null)
	..()
	UpdateClothing()


	oxygen:icon_state = "oxy0"
	i_select:icon_state = "selector"
	m_select:icon_state = "selector"
	toxin:icon_state = "toxin0"
	internals:icon_state = "internal0"
	mach:icon_state = null
	fire:icon_state = "fire0"
	healths:icon_state = "health0"
	pullin:icon_state = "pull0"
	blind:icon_state = "black"
	hands:icon_state = "hand"
	flash:icon_state = "blank"
	sleep:icon_state = "sleep0"
	rest:icon_state = "rest0"
	hands:dir = NORTH

	oxygen:name = "oxygen"
	i_select:name = "intent"
	m_select:name = "move"
	toxin:name = "toxin"
	internals:name = "internal"
	mach:name = "Reset Machine"
	fire:name = "fire"
	healths:name = "health"
	pullin:name = "pull"
	blind:name = " "
	hands:name = "hand"
	flash:name = "flash"
	sleep:name = "sleep"
	rest:name = "rest"

	oxygen:screen_loc = "15,12"
	i_select:screen_loc = "14,15"
	m_select:screen_loc = "14,14"
	toxin:screen_loc = "15,10"
	internals:screen_loc = "15,14"
	mach:screen_loc = "15,15"
	fire:screen_loc = "15,8"
	healths:screen_loc = "15,5"
	sleep:screen_loc = "15,3"
	rest:screen_loc = "15,2"
	pullin:screen_loc = "15,1"
	hands:screen_loc = "1,3"
	blind:screen_loc = "1,1 to 15,15"
	flash:screen_loc = "1,1 to 15,15"
	blind:layer = 0
	flash:layer = 17
	sleep:layer = 20
	rest:layer = 20



	client:screen:len = null
	client:screen -= list(oxygen, i_select, m_select, toxin, internals, fire, hands, healths, pullin, blind, flash, rest, sleep, mach)
	client:screen += list(oxygen, i_select, m_select, toxin, internals, fire, hands, healths, pullin, blind, flash, rest, sleep, mach)

	client:screen -= hud_used:adding
	client:screen += hud_used:adding
	client:screen -= hud_used:mon_blo
	client:screen += hud_used:mon_blo
	if(!primary)
		var/t1 = rand(1000, 1500)
		dna_ident += t1
		if(dna_ident > 65536)
			dna_ident = rand(1, 1500)
		primary = new /obj/dna(null)
		primary:uni_identity = "[dna_ident]"
		while(length(primary:uni_identity) < 4)
			primary:uni_identity = "0[primary:uni_identity]"
		var/t2 = "[rand(1, 256)]"
		if(length(t2) < 2)
			primary:uni_identity = "[primary:uni_identity]0[t2]"
		else
			primary:uni_identity = "[primary:uni_identity][t2]"
		t2 = "[rand(1, 256)]"
		if(length(t2) < 2)
			primary:uni_identity = "[primary:uni_identity]0[t2]"
		else
			primary:uni_identity = "[primary:uni_identity][t2]"
		t2 = "[rand(1, 256)]"
		if(length(t2) < 2)
			primary:uni_identity = "[primary:uni_identity]0[t2]"
		else
			primary:uni_identity = "[primary:uni_identity][t2]"
		t2 = "[rand(1, 256)]"
		if(length(t2) < 2)
			primary:uni_identity = "[primary:uni_identity]0[t2]"
		else
			primary:uni_identity = "[primary:uni_identity][t2]"
		t2 = gender == "male" ? "[rand(1, 124)]" : "[rand(127, 250)]"
		if(length(t2) < 2)
			primary:uni_identity = "[primary:uni_identity]0[t2]"
		else
			primary:uni_identity = "[primary:uni_identity][t2]"
		primary:spec_identity = "2B6696D2B127E5A4"
		primary:struc_enzyme = "CDEAF5B90AADBC6BA8033DB0A7FD613FA"
		primary:use_enzyme = "C8FFFE7EC09D80AEDEDB9A5A0B4085B61"
		primary:n_chromo = 16
	if(!start)
		if(key in list("Thief jack", "Link43130", "Hutchy2k1", "Easty", "Exadv1"))
			start = 1
			loc = locate(36, 67, 10)
		else
			start = 1
			var/A = locate(/area/start)
			var/L = list()
			for(var/T as turf in A)
				L += T
			loc = pick(L)
	src << browse('help.htm', "window=help")
	if((key in list("Exadv1", , "Expert Advisor", "Thief jack", "Jon88", "Link43130", "Hutchy2k1", "Roara", "Blu", "Puzzlemaker")) || (world.address == client:address || !client:address))
		src << "\blue The game ip is byond://[world.address]:[world.port] !"
		verbs += /mob/proc/mute
		verbs += /mob/proc/changemessage
		verbs += /mob/proc/boot
		verbs += /mob/proc/changemode
		verbs += /mob/proc/show_ctf
		verbs += /mob/proc/restart
		verbs += /mob/proc/who
		verbs += /mob/proc/change_name
		verbs += /mob/proc/show_help
		verbs += /mob/proc/toggle_ooc
		verbs += /mob/proc/toggle_abandon
		verbs += /mob/proc/toggle_enter
		verbs += /mob/proc/toggle_shuttle
		verbs += /mob/proc/delay_start
		verbs += /mob/proc/make_gift
		verbs += /mob/proc/make_flag
		verbs += /mob/proc/make_pill
		verbs += /mob/proc/ban
		verbs += /mob/proc/unban
		verbs += /mob/proc/secrets
		verbs += /mob/proc/toggle_alter
		verbs += /mob/proc/carboncopy
		verbs += /mob/proc/list_dna
	src << "\blue<B>[world_message]</B>"
	if(!isturf(loc))
		client:eye = loc
		client:perspective = EYE_PERSPECTIVE
	name = "monkey"
/mob/monkey/Move()
	if(!buckled || buckled:loc != loc)
		buckled = null
	if(buckled) return
	if(restrained()) pulling = null
	var/t7 = 1
	if(restrained())
		for(var/mob/M in range(src, 1))
			if(M:pulling == src && (M:stat == 0 && !M:restrained()))
				t7 = null
	if(t7 && (pulling && get_dist(src, pulling) <= 1))
		var/T = loc
		. = ..()
		if(!isturf(pulling:loc))
			pulling = null
			return
		if(!restrained())
			var/diag = get_dir(src, pulling)
			if(diag - 1 & diag)
			else diag = null
			if(ismob(pulling) && (get_dist(src, pulling) > 1 || diag))
				if(istype(pulling, type))
					var/M = pulling
					var/t = M:pulling
					M:pulling = null
					step(pulling, get_dir(pulling:loc, T))
					M:pulling = t
			else
				step(pulling, get_dir(pulling:loc, T))
	else
		pulling = null
		. = ..()
	if(s_active && !contents:Find(s_active))
		s_active:close(src)
/mob/monkey/death()
	if(healths) healths:icon_state = "health5"
	stat = 2
	canmove = 0
	blind:layer = 0
	lying = 1
	icon_state = "dead"
	var/cancel
	for(var/mob/M in world)
		if(M:client && !M:stat)
			cancel = 1

	if(!cancel)
		world << "<B>Everyone is dead! Resetting in 30 seconds!</B>"
		if(ticker && ticker:timing)
			ticker:shuttle_entered = 1
			ticker:timeleft = 1
		else spawn(300) world.Reboot()
	return
/mob/monkey/Life()
	set background = 1
	var/T = loc
	var/plcheck
	var/oxcheck
	var/ficheck
	if(!(locate(/obj/table) in loc))
		layer = MOB_LAYER
	health = 100 - oxyloss - toxloss - fireloss - bruteloss
	if(stat != 2)
		t_sl_gas = 0
		t_n2 = 0
		if(!m_flag)
			last_move = null
		m_flag = null
		if(mach)
			if(machine)
				mach:icon_state = "mach1"
			else
				mach:icon_state = null
















		if(internal && !contents:Find(internal)) internal = null
		if(!wear_mask || !(wear_mask:flags | 8)) internal = null
		if(istype(T, /turf))
			var/t = 0.00014
			if(health < 20)
				t = 5e-5
			else if(health < 40)
				t = 0.0001
			if(locate(/obj/move) in T)
				T = locate(/obj/move) in T
			var/turf_total = T:oxygen + T:poison + T:sl_gas + T:co2 + T:n2
			var/G = new /obj/substance/gas()
			G:maximum = 10000
			if(internal)
				internal:process(src, G)
				if(wear_mask:flags & 4)
					G:turf_add(T, G:tot_gas() * 0.5)
					G:turf_take(T, t / 2 * turf_total - G:tot_gas())
			else
				G:turf_take(T, t * turf_total)
			aircheck(G)
			plcheck = t_plasma
			oxcheck = t_oxygen
			G:turf_add(T, G:tot_gas())












			ficheck = firecheck(T)
		else
			if(istype(T, /obj))
				var/O = T
				O:alter_health(src)
		if(istype(loc, /turf/space) && !(locate(/obj/move) in loc))
			var/layers = 20
			if(istype(wear_mask, /obj/item/weapon/clothing/mask) && (!(wear_mask:flags & 4) && wear_mask:flags & 8))
				layers -= 5
			if(layers > oxcheck)
				oxcheck = layers

		if(plcheck && health >= 0)
			if(paralysis <= 0 || weakened <= 0)
				toxloss += plcheck
				health = 100 - oxyloss - toxloss - fireloss - bruteloss
			else
				toxloss += plcheck
				health = 100 - oxyloss - toxloss - fireloss - bruteloss

		if(oxcheck && health >= 0)
			if(paralysis <= 0 || weakened <= 0)
				oxyloss += oxcheck
				health = 100 - oxyloss - toxloss - fireloss - bruteloss
			else
				oxyloss += oxcheck
				health = 100 - oxyloss - toxloss - fireloss - bruteloss
		else if(health >= 0)
			if(oxyloss >= 10)
				var/amount = max(0.15, 1)
				oxyloss -= amount
				health = 100 - oxyloss - toxloss - fireloss - bruteloss
			else
				oxyloss = 0

		if(ficheck)
			fireloss += ficheck * 10
			health = 100 - oxyloss - toxloss - fireloss - bruteloss

		if(health <= -100) death()
		else if(sleeping || health < 0)
			if(prob(1))
				if(health <= 20)
					spawn(0) emote("gasp")
				else
					spawn(0) emote("snore")
			if(health < 0)
				if(rejuv <= 0)
					oxyloss++
					health = 100 - oxyloss - toxloss - fireloss - bruteloss
			stat = 1
			if(paralysis < 5) paralysis = 5
		else if(resting)
			if(weakened < 5) weakened = 5
		else if(health < 20)
			if(prob(5))
				if(prob(1))
					if(health <= 20)
						spawn(0) emote("gasp")
				stat = 1
				if(paralysis < 2) paralysis = 2
		if(rejuv > 0)
			rejuv--
		if(r_epil > 0)
			r_epil--
		if(r_ch_cou > 0)
			r_ch_cou--
		if(r_Tourette > 0)
			r_Tourette--
		if(antitoxs > 0)
			antitoxs--
			if(plasma > 0)
				antitoxs -= 4
		if(plasma > 0)
			plasma--
		blinded = null
		if(drowsyness > 0)
			drowsyness--
			if(paralysis > 1)
				drowsyness -= 0.5
			else if(weakened > 1)
				drowsyness -= 0.25
			eye_blurry = max(2, eye_blurry)
			if(prob(5))
				sleeping = 1
				paralysis = 5
			if(health > -10 && drowsyness > 1200)
				if(antitoxs < 1)
					toxloss += plcheck
					health = 100 - oxyloss - toxloss - fireloss - bruteloss
					plcheck = 1
		var/mental_danger = 0
		if(r_epil > 0 && !(disabilities & 2) || r_Tourette > 0 && !(disabilities & 8))
			stuttering = max(2, drowsyness)
			mental_danger = 1
			drowsyness = max(2, drowsyness)
			if(!paralysis)
				if(prob(5))
					src << "\red You have a seizure!"
					paralysis = 10
				else if(prob(5))
					spawn(0)
						emote("twitch")
					stunned = 10
				else if(prob(30))
					spawn(0)
						emote("drool")
		if(health > -10)
			var/threshold = 45
			if(mental_danger)
				threshold = 15
			if(r_ch_cou > 2700)
				if(antitoxs < 1)
					toxloss += 1
					health = 100 - oxyloss - toxloss - fireloss - bruteloss
					plcheck = 1
					if(prob(15))
						spawn(0)
							emote("twitch")
							stunned = 2
			if(r_epil > threshold * 60)
				if(antitoxs < 1)
					toxloss += 1
					health = 100 - oxyloss - toxloss - fireloss - bruteloss
					plcheck = 1
					if(prob(15))
						spawn(0)
							emote("twitch")
							stunned = 2
			if(r_Tourette > threshold * 60)
				if(antitoxs < 1)
					toxloss += 1
					health = 100 - oxyloss - toxloss - fireloss - bruteloss
					plcheck = 1
					if(prob(15))
						spawn(0)
							emote("twitch")
							stunned = 2
			if(antitoxs > 7200)
				toxloss += 1
				health = 100 - oxyloss - toxloss - fireloss - bruteloss
				plcheck = 1
				if(prob(15))
					spawn(0)
						emote("drool")
		if(health > -50)
			if(plasma > 0)
				if(antitoxs < 1)
					toxloss += 1
					health = 100 - oxyloss - toxloss - fireloss - bruteloss
					plcheck = 1
					if(prob(15))
						spawn(0)
							emote("moan")
		if(stat != 2)
			if(paralysis + stunned + weakened > 0)
				if(stunned > 0)
					stunned--
					stat = 0
				if(weakened > 0)
					weakened--
					lying = 1
					stat = 0
				if(paralysis > 0)
					paralysis--
					blinded = 1
					lying = 1
					stat = 1
				canmove = 0
				var/h = hand
				hand = 0
				drop_item()
				hand = 1
				drop_item()
				hand = h
			else
				canmove = 1
				lying = 0
				stat = 0
	else
		lying = 1
		blinded = 1
		stat = 2
		canmove = 0
	if(stuttering > 0)
		stuttering--
	if(eye_blind > 0)
		eye_blind--
		blinded = 1
	if(ear_deaf > 0)
		ear_deaf--
	else if(ear_damage < 25)
		ear_damage -= 0.05
		ear_damage = max(ear_damage, 0)
	if(buckled) lying = 0
	density = !lying
	if(lying)
		weight = 5000000
	else weight = 2500000
	if(sdisabilities & 1)
		blinded = 1
	if(eye_blurry > 0)
		eye_blurry--
	if(client)
		client:screen -= main_hud:g_dither
		if(istype(wear_mask, /obj/item/weapon/clothing/mask/gasmask))
			client:screen += main_hud:g_dither
		if(mach)
			if(machine)
				mach:icon_state = "mach1"
			else
				mach:icon_state = null
		if(sleep)
			sleep:icon_state = "sleep[sleeping]"
		if(rest)
			rest:icon_state = "rest[resting]"
		if(healths)
			if(stat < 2)
				if(health >= 100) healths:icon_state = "health0"
				else if(health >= 75) healths:icon_state = "health1"
				else if(health >= 50) healths:icon_state = "health2"
				else if(health > 20) healths:icon_state = "health3"
				else healths:icon_state = "health4"
			else
				healths:icon_state = "health5"
		if(pullin)
			if(pulling)
				pullin:icon_state = "pull1"
			else
				pullin:icon_state = "pull0"
		if(fire)
			if(ficheck)
				fire:icon_state = "fire1"
			else
				fire:icon_state = "fire0"
		if(toxin)
			if(plcheck)
				toxin:icon_state = "toxin1"
			else
				toxin:icon_state = "toxin0"
		if(oxygen)
			if(oxcheck)
				oxygen:icon_state = "oxy1"
			else
				oxygen:icon_state = "oxy0"
		client:screen -= hud_used:blurry
		client:screen -= hud_used:vimpaired
		if(blind && stat != 2)
			if(blinded)
				blind:layer = 18
			else
				blind:layer = 0
				if(eye_blurry)
					client:screen -= hud_used:blurry
					client:screen += hud_used:blurry
				else
					client:screen -= hud_used:blurry
		if(stat != 2)
			if(machine)
				if(!machine:check_eye(src))
					reset_view(null)
			else
				reset_view(null)
	if(primary) primary:cleanup()
	UpdateClothing()
	health = 100 - oxyloss - toxloss - fireloss - bruteloss
/mob/monkey/verb/removeinternal()
	internal = null
/mob/monkey/verb/abandon_mob()
	if(!abandon_allowed) return
	if(stat != 2 || !ticker)
		usr << "\blue<B>You must be dead to use this! It also must be Extended mode.</B>"
		return
	usr << "\blue<B>Please roleplay correctly!</B>"
	for(var/obj/screen/t in usr.client:screen)
		if(t:loc == null) del(t)
	var/M = new /mob/human()
	M:key = client:key

/mob/monkey/proc/aircheck(obj/G)
	t_oxygen = 0
	t_plasma = 0
	if(G)
		var/a_oxygen = G:oxygen * 0.7
		var/a_plasma = G:plasma
		var/a_sl_gas = G:sl_gas * 0.7

		G:oxygen -= a_oxygen
		G:plasma -= a_plasma
		G:sl_gas -= a_sl_gas

		if(a_oxygen < 67.032)
			t_oxygen = round((67.032 - a_oxygen) / 5)
		if(G:co2 > 5)
			var/t = round((G:co2 - 5) / 5)
			if(G:co2 > 25)
				paralysis = max(paralysis, 3)
				if(G:co2 > 50)
					t = 50
			t_oxygen = max(t_oxygen, t)
		if(a_plasma > 5)
			t_plasma = round((t_plasma - 5) / 10) + 1
		if(a_sl_gas > 10)
			weakened = max(weakened, 3)
			if(G:co2 > 40)
				paralysis = max(paralysis, 3)

		G:co2 += a_oxygen * 0.6

/mob/monkey/proc/firecheck(turf/T)
	if(T:firelevel < 2000000) return 0
	var/total = 0
	if(wear_mask)
		if(T:firelevel > wear_mask:s_fire)
			total += 0.25
	else total += 0.25
	return total
/mob/monkey/say(message as text)
	message = copytext(message, 1, 128)
	if(stat == 2)
		for(var/mob/M in world)
			if(M:stat == 2)
				M << "<B>The monkey</B> [stat > 1 ? "\[<I>dead</I> \]" : ""]: [message]"
		return
	if(copytext(message, 1, 2) == "*" && !stat)
		emote(copytext(message, 2, length(message) + 1))
		return
	if(!message || istype(wear_mask, /obj/item/weapon/clothing/mask/muzzle)) return
	if(!muted)
		if(stat < 2)
			var/L = list()
			var/pre = copytext(message, 1, 4)
			var/italics = 0
			if(pre == "\[r\]")
				message = copytext(message, 4, length(message) + 1)
				if(r_hand)
					r_hand:talk_into(usr, message)
				L += view(1)
				italics = 1
			else if(pre == "\[l\]")
				message = copytext(message, 4, length(message) + 1)
				if(l_hand)
					l_hand:talk_into(usr, message)
				L += view(1)
				italics = 1
			else if(pre == "\[w\]")
				message = copytext(message, 4, length(message) + 1)
				L += view(1)
				italics = 1
			else
				L += view()
				pre = null
			if(italics) message = "<I>[message]</I>"
			for(var/mob/M in L)
				if(istype(M, type))
					M:show_message("<B>The monkey</B>: [message]", 2)
				else
					M:show_message("<B>The monkey</B> chimpers.", 2)
			for(var/obj/O in L)
				spawn(0) if(O) O:hear_talk(usr, message)
		for(var/mob/M in world)
			if(M:stat > 1)
				M << "<B>The monkey</B> [stat > 1 ? "\[<I>dead</I> \]" : ""]: [message]"
	else
		src.show_message("<B>The monkey</B>: [message]", 2)

/mob/monkey/examine()
	set src in oview()
	usr << "\blue*---------*"
	usr << "\blue This is \icon[src] <B>[name]</B>!"
	if(handcuffed) usr << "\blue\t[name] is handcuffed! \icon[handcuffed]"
	if(wear_mask) usr << "\blue\t[name] has a \icon[wear_mask] [wear_mask:name] on \his[src] head!"
	if(l_hand) usr << "\blue\t[name] has a \icon[l_hand] [l_hand:name] in \his[src] left hand!"
	if(r_hand) usr << "\blue[name] has a \icon[r_hand] [r_hand:name] in \his[src] right hand!"
	if(back) usr << "\blue[name] has a \icon[back] [back:name] on \his[src] back!"
	if(bruteloss)
		if(bruteloss < 30) usr << "\red[name] looks slightly bruised!"
		else usr << "\red<B>[name] looks severely bruised!</B>"
	if(fireloss)
		if(fireloss < 30) usr << "\red[name] looks slightly burnt!"
		else usr << "\red<B>[name] looks severely burnt!</B>"
/mob/monkey/proc/emote(act)
	var/param = null
	if(findtext(act, "-"))
		var/t1 = findtext(act, "-")
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)
	var/muzzled = istype(wear_mask, /obj/item/weapon/clothing/mask/muzzle)
	var/message
	var/m_type = 1
	switch(act)
		if("sign")
			if(!restrained())
				message = "<B>The monkey</B> signs[text2num(param) ? " the number [text2num(param)]" : null]."
				m_type = 1
		if("scratch")
			if(!restrained())
				message = "<B>The monkey</B> scratches."
				m_type = 1
		if("whimper")
			if(!muzzled)
				message = "<B>The monkey</B> whimpers."
				m_type = 2
		if("roar")
			if(!muzzled)
				message = "<B>The monkey</B> roars."
				m_type = 2
		if("tail")
			message = "<B>The monkey</B> waves his tail."
			m_type = 1
		if("gasp")
			message = "<B>The monkey</B> gasps."
			m_type = 2
		if("drool")
			message = "<B>The monkey</B> drools."
			m_type = 1
		if("paw")
			if(!restrained())
				message = "<B>The monkey</B> flails his paw."
				m_type = 1
		if("scretch")
			if(!muzzled)
				message = "<B>The monkey</B> scretches."
				m_type = 2
		if("choke")
			message = "<B>The monkey</B> chokes."
			m_type = 2
		if("moan")
			message = "<B>The monkey</B> moans!"
			m_type = 2
		if("nod")
			message = "<B>The monkey</B> nods his head."
			m_type = 1
		if("sit")
			message = "<B>The monkey</B> sits down."
			m_type = 1
		if("sway")
			message = "<B>The monkey</B> sways around dizzily."
			m_type = 1
		if("sulk")
			message = "<B>The monkey</B> sulks down sadly."
			m_type = 1
		if("twitch")
			message = "<B>The monkey</B> twitches violently."
			m_type = 1
		if("dance")
			if(!restrained())
				message = "<B>The monkey</B> dances around happily."
				m_type = 1
		if("roll")
			if(!restrained())
				message = "<B>The monkey</B> rolls."
				m_type = 1
		if("shake")
			message = "<B>The monkey</B> shakes his head."
			m_type = 1
		if("gnarl")
			if(!muzzled)
				message = "<B>The monkey</B> gnarls and shows his teeth.."
				m_type = 2
		if("jump")
			message = "<B>The monkey</B> jumps!"
			m_type = 1
		if("help")
			src << "choke, dance, drool, gasp, gnarl, jump, paw, moan, nod, roar, roll, scratch,\nscretch, shake, sign-#, sit, sulk, sway, tail, twitch, whimper"
		else

			src << "Invalid Emote: [act]"
	if(message && stat == 0)
		for(var/mob/O in view(src))
			O:show_message(message, m_type)
/mob/monkey/ex_act(severity)
	flick("flash", flash)
	switch(severity)
		if(1)
			if(stat != 2)
				bruteloss += 200
				health = 100 - oxyloss - toxloss - fireloss - bruteloss
		if(2)
			if(stat != 2)
				bruteloss += 60
				fireloss += 60
				health = 100 - oxyloss - toxloss - fireloss - bruteloss
		if(3)
			if(stat != 2)
				bruteloss += 30
				health = 100 - oxyloss - toxloss - fireloss - bruteloss
			if(prob(50))
				paralysis += 10

/obj/list_container/mobl
	var/mob/container = list()



/mob/proc/ret_grab(obj/L, flag)
	if(!istype(l_hand, /obj/item/weapon/grab) && !istype(r_hand, /obj/item/weapon/grab))
		if(!L)
			return null
		else
			return L:container
	else
		if(!L)
			L = new /obj/list_container/mobl(null)
			L:container += src
			L:master = src
		if(istype(l_hand, /obj/item/weapon/grab))
			var/G = l_hand
			if(!L:container:Find(G:affecting))
				L:container += G:affecting
				G:affecting:ret_grab(L, 1)
		if(istype(r_hand, /obj/item/weapon/grab))
			var/G = r_hand
			if(!L:container:Find(G:affecting))
				L:container += G:affecting
				G:affecting:ret_grab(L, 1)
		if(!flag)
			if(L:master == src)
				var/temp = list()
				temp += L:container
				del(L)
				return temp
			else
				return L:container

/mob/human/ex_act(severity)
	flick("flash", flash)
	var/shielded = 0
	for(var/obj/item/weapon/shield/S in src)
		if(S:active)
			shielded = 1
			break
	switch(severity)
		if(1)
			if(stat != 2)
				bruteloss += 100
				fireloss += 100
				health = 100 - oxyloss - toxloss - fireloss - bruteloss
		if(2)
			if(stat != 2)
				if(!shielded)
					bruteloss += 60
				fireloss += 60
				health = 100 - oxyloss - toxloss - fireloss - bruteloss
			if(!istype(ears, /obj/item/weapon/clothing/ears/earmuffs))
				ear_damage += 30
				ear_deaf += 120
		if(3)
			if(stat != 2)
				bruteloss += 30
				health = 100 - oxyloss - toxloss - fireloss - bruteloss
			if(prob(50) && !shielded)
				paralysis += 10
			if(!istype(ears, /obj/item/weapon/clothing/ears/earmuffs))
				ear_damage += 15
				ear_deaf += 60



/mob/human
	var/obj/item/weapon/clothing/suit/wear_suit
	var/obj/item/weapon/clothing/under/w_uniform
	var/obj/item/weapon/radio/w_radio
	var/shoes
	var/belt
	var/gloves
	var/glasses
	var/obj/item/weapon/clothing/head/head
	var/ears
	var/obj/item/weapon/card/id/wear_id
	var/r_store
	var/l_store

/mob/human/u_equip(obj/W)
	if(W == wear_suit)
		wear_suit = null
	else if(W == w_uniform)
		W = r_store
		if(W)
			u_equip(W)
			if(client) client:screen -= W
			if(W)
				W:loc = loc
				W:dropped(src)
				W:layer = initial(W:layer)
		W = l_store
		if(W)
			u_equip(W)
			if(client) client:screen -= W
			if(W)
				W:loc = loc
				W:dropped(src)
				W:layer = initial(W:layer)
		W = wear_id
		if(W)
			u_equip(W)
			if(client) client:screen -= W
			if(W)
				W:loc = loc
				W:dropped(src)
				W:layer = initial(W:layer)
		W = belt
		if(W)
			u_equip(W)
			if(client) client:screen -= W
			if(W)
				W:loc = loc
				W:dropped(src)
				W:layer = initial(W:layer)
		w_uniform = null
	else if(W == gloves)
		gloves = null
	else if(W == glasses)
		glasses = null
	else if(W == head)
		head = null
	else if(W == ears)
		ears = null
	else if(W == shoes)
		shoes = null
	else if(W == belt)
		belt = null
	else if(W == wear_mask)
		wear_mask = null
	else if(W == w_radio)
		w_radio = null
	else if(W == wear_id)
		wear_id = null
	else if(W == r_store)
		r_store = null
	else if(W == l_store)
		l_store = null
	else if(W == back)
		back = null
	else if(W == handcuffed)
		handcuffed = null
	else if(W == r_hand)
		r_hand = null
	else if(W == l_hand)
		l_hand = null
/mob/human/db_click(text, t1)
	var/obj/item/weapon/W = equipped()
	if(!istype(W, /obj/item/weapon)) return
	switch(text)
		if("mask")
			if(wear_mask) return
			if(!istype(W, /obj/item/weapon/clothing/mask)) return
			u_equip(W)
			wear_mask = W
		if("back")
			if(back || !istype(W, /obj/item/weapon)) return
			if(!(W:flags & 1)) return
			u_equip(W)
			back = W
		if("headset")
			if(w_radio) return
			if(!istype(W, /obj/item/weapon/radio/headset)) return
			u_equip(W)
			w_radio = W
		if("o_clothing")
			if(wear_suit) return
			if(!istype(W, /obj/item/weapon/clothing/suit)) return
			u_equip(W)
			wear_suit = W
		if("gloves")
			if(gloves) return
			if(!istype(W, /obj/item/weapon/clothing/gloves)) return
			u_equip(W)
			gloves = W
		if("shoes")
			if(shoes) return
			if(!istype(W, /obj/item/weapon/clothing/shoes)) return
			u_equip(W)
			shoes = W
		if("belt")
			if(belt || !istype(W, /obj/item/weapon)) return
			if(!(W:flags & 128)) return
			u_equip(W)
			belt = W
		if("eyes")
			if(glasses) return
			if(!istype(W, /obj/item/weapon/clothing/glasses)) return
			u_equip(W)
			glasses = W
		if("head")
			if(head) return
			if(!istype(W, /obj/item/weapon/clothing/head)) return
			u_equip(W)
			head = W
		if("ears")
			if(ears) return
			if(!istype(W, /obj/item/weapon/clothing/ears)) return
			u_equip(W)
			ears = W
		if("i_clothing")
			if(w_uniform) return
			if(!istype(W, /obj/item/weapon/clothing/under)) return
			u_equip(W)
			w_uniform = W
		if("id")
			if(wear_id || !w_uniform) return
			if(!istype(W, /obj/item/weapon/card/id)) return
			u_equip(W)
			wear_id = W
		if("storage1")
			if(l_store) return
			if(!istype(W, /obj/item/weapon) || (W:w_class >= 3 || !w_uniform)) return
			u_equip(W)
			l_store = W
		if("storage2")
			if(r_store) return
			if(!istype(W, /obj/item/weapon) || (W:w_class >= 3 || !w_uniform)) return
			u_equip(W)
			r_store = W

/mob/human/meteorhit(obj/O)
	for(var/mob/M in view(src))
		if(M:client && !M:blinded)
			M:show_message("\red[src] has been hit with by [O]", 1)
	if(health > 0)
		var/shielded = 0
		for(var/obj/item/weapon/shield/S in src)
			if(S:active)
				shielded = 1
				break
		bruteloss += 30
		if(O:icon_state == "flaming" && !shielded)
			fireloss += 40
		health = 100 - oxyloss - toxloss - fireloss - bruteloss
	if(prob(30))
		var/t = pick(1, 2, 4, 1, 2, 4, 1, 2, 4, 1, 2, 4, 3, 5, 6)
		sdisabilities |= t
		if(t & 1)
			src.show_message("\red You go blind!")
		if(t & 2)
			show_message("\red You go mute!")
		if(t & 4)
			show_message("\red You go deaf!")
/mob/human/Move(a, b, flag)
	if(buckled) return


	if(restrained()) pulling = null
	var/t7 = 1
	if(restrained())
		for(var/mob/M in range(src, 1))
			if(M:pulling == src && (M:stat == 0 && !M:restrained()))
				t7 = null
	if(t7 && (pulling && ((get_dist(src, pulling) <= 1 || pulling:loc == loc) && (client && client:moving))))
		var/T = loc
		. = ..()
		if(!isturf(pulling:loc))
			pulling = null
			return
		if(!restrained())
			var/diag = get_dir(src, pulling)
			if(diag - 1 & diag)
			else diag = null
			if(get_dist(src, pulling) > 1 || diag)
				if(ismob(pulling))
					var/M = pulling
					var/ok = 1
					if(M:grabbed_by:len > 0)
						if(prob(75))
							var/G = pick(M:grabbed_by)
							if(istype(G, /obj/item/weapon/grab))
								for(var/mob/O in view(M))
									O:show_message("\red[G:affecting] has been pulled from [G:assailant]'s grip by [src]", 1)
								del(G)
						else
							ok = 0
						if(M:grabbed_by:len > 0) ok = 0
					if(ok)
						var/t = M:pulling
						M:pulling = null
						step(pulling, get_dir(pulling:loc, T))
						M:pulling = t
				else
					step(pulling, get_dir(pulling:loc, T))
	else
		pulling = null
		. = ..()
	if(s_active && !contents:Find(s_active))
		s_active:close(src)
/mob/human/examine()
	set src in oview()
	usr << "\blue*---------*"
	usr << "\blue This is \icon[src] <B>[name]</B>!"
	if(w_uniform) usr << "\blue\t[name] is wearing \icon[w_uniform] [w_uniform:name]."
	if(handcuffed) usr << "\blue\t[name] is handcuffed! \icon[handcuffed]"
	if(wear_suit) usr << "\blue\t[name] has a \icon[wear_suit] [wear_suit:name] on!"
	if(w_radio) usr << "\blue\t[name] has a \icon[w_radio] [w_radio:name] by \his[src] mouth!"
	if(wear_mask) usr << "\blue\t[name] has a \icon[wear_mask] [wear_mask:name] on \his[src] head!"
	if(l_hand) usr << "\blue\t[name] has a \icon[l_hand] [l_hand:name] in \his[src] left hand!"
	if(r_hand) usr << "\blue[name] has a \icon[r_hand] [r_hand:name] in \his[src] right hand!"
	if(back) usr << "\blue[name] has a \icon[back] [back:name] on \his[src] back!"
	if(wear_id)
		if(wear_id:registered != rname && (get_dist(src, usr) <= 1 && prob(10)))
			usr << "\blue[name] is wearing \icon[wear_id] [wear_id:name] yet doesn't seem to be that person!!!"
		else usr << "\blue[name] is wearing \icon[wear_id] [wear_id:name]!"
	if(bruteloss)
		if(bruteloss < 30) usr << "\red[name] looks slightly bruised!"
		else usr << "\red<B>[name] looks severely bruised!</B>"
	if(fireloss)
		if(fireloss < 30) usr << "\red[name] looks slightly burnt!"
		else usr << "\red<B>[name] looks severely burnt!</B>"
	usr << "\blue*---------*"
/mob/human/Logout()
	if(!start)
		del(src)
	else ..()
/mob/human/Login()
	client:screen -= main_hud:contents
	client:screen -= main_hud2:contents
	if(!hud_used) hud_used = main_hud
	next_move = 1
	if(!rname) rname = key
	oxygen = new /obj/screen(null)
	i_select = new /obj/screen(null)
	m_select = new /obj/screen(null)
	toxin = new /obj/screen(null)
	internals = new /obj/screen(null)
	mach = new /obj/screen(null)
	fire = new /obj/screen(null)
	healths = new /obj/screen(null)
	pullin = new /obj/screen(null)
	blind = new /obj/screen(null)
	flash = new /obj/screen(null)
	hands = new /obj/screen(null)
	sleep = new /obj/screen(null)
	rest = new /obj/screen(null)
	zone_sel = new /obj/screen(null)
	..()
	UpdateClothing()


	oxygen:icon_state = "oxy0"
	i_select:icon_state = "selector"
	m_select:icon_state = "selector"
	toxin:icon_state = "toxin0"
	internals:icon_state = "internal0"
	mach:icon_state = null
	fire:icon_state = "fire0"
	healths:icon_state = "health0"
	pullin:icon_state = "pull0"
	blind:icon_state = "black"
	hands:icon_state = "hand"
	flash:icon_state = "blank"
	sleep:icon_state = "sleep0"
	rest:icon_state = "rest0"
	hands:dir = NORTH

	oxygen:name = "oxygen"
	i_select:name = "intent"
	m_select:name = "moving"
	toxin:name = "toxin"
	internals:name = "internal"
	mach:name = "Reset Machine"
	fire:name = "fire"
	healths:name = "health"
	pullin:name = "pull"
	blind:name = " "
	hands:name = "hand"
	flash:name = "flash"
	sleep:name = "sleep"
	rest:name = "rest"

	oxygen:screen_loc = "15,12"
	i_select:screen_loc = "14,15"
	m_select:screen_loc = "14,14"
	toxin:screen_loc = "15,10"
	internals:screen_loc = "15,14"
	mach:screen_loc = "15,15"
	fire:screen_loc = "15,8"
	healths:screen_loc = "15,5"
	sleep:screen_loc = "15,3"
	rest:screen_loc = "15,2"
	pullin:screen_loc = "15,1"
	hands:screen_loc = "1,3"
	blind:screen_loc = "1,1 to 15,15"
	flash:screen_loc = "1,1 to 15,15"
	blind:layer = 0
	flash:layer = 17
	client:screen:len = null
	client:screen -= list(zone_sel, oxygen, i_select, m_select, toxin, internals, fire, hands, healths, pullin, blind, flash, rest, sleep, mach)
	client:screen += list(zone_sel, oxygen, i_select, m_select, toxin, internals, fire, hands, healths, pullin, blind, flash, rest, sleep, mach)

	client:screen -= hud_used:adding
	client:screen += hud_used:adding
	src << browse('help.htm', "window=help")
	if((key in list("Exadv1", , "Expert Advisor", "Thief jack", "Jon88", "Link43130", "Hutchy2k1", "Roara", "Blu", "Puzzlemaker")) || (world.address == client:address || !client:address))
		src << "\blue The game ip is byond://[world.address]:[world.port] !"
		verbs += /mob/proc/mute
		verbs += /mob/proc/changemessage
		verbs += /mob/proc/boot
		verbs += /mob/proc/changemode
		verbs += /mob/proc/restart
		verbs += /mob/proc/who
		verbs += /mob/proc/change_name
		verbs += /mob/proc/show_help
		verbs += /mob/proc/toggle_ooc
		verbs += /mob/proc/toggle_abandon
		verbs += /mob/proc/toggle_enter
		verbs += /mob/proc/toggle_shuttle
		verbs += /mob/proc/delay_start
		verbs += /mob/proc/make_gift
		verbs += /mob/proc/make_flag
		verbs += /mob/proc/make_pill
		verbs += /mob/proc/show_ctf
		verbs += /mob/proc/ban
		verbs += /mob/proc/unban
		verbs += /mob/proc/secrets
		verbs += /mob/proc/carboncopy
		verbs += /mob/proc/toggle_alter
		verbs += /mob/proc/list_dna
	src << "\blue<B>[world_message]</B>"
	src << browse("<PRE>[changes]</PRE>", "window=changes")
	if(!isturf(loc))
		client:eye = loc
		client:perspective = EYE_PERSPECTIVE
	if(!start)
		ShowChoices()
		var/A = locate(/area/start)
		var/L = list()
		for(var/T as turf in A)
			L += T
		loc = pick(L)
		src << "\blue<B>VITAL: http://elegant-galleria.com/ryan/ has a file called atcache.zip. Download it and extract to your BYOND cache (which is located in BYOND/users/*/cache).</B>"
		src << "\blue<B>Starting has changed. You msut select your preferences then go over the begin object and get ready. If you want to you can go to SS13 by using enter. If you don't and the game hasn't started yet you'll still be automatically teleported.</B>"

/mob/human
	icon_state = "m-none"; var/now_pushing
/mob/human/Bump(AM as mob|obj, yes)
	if(!yes || now_pushing) return
	..()
	if(!istype(AM, /atom/movable)) return
	if(!now_pushing)
		now_pushing = 1
		if(!AM:anchored)
			var/t = get_dir(src, AM)
			step(AM, t)












		now_pushing = null

/mob/human/death()
	healths:icon_state = "health5"
	stat = 2
	canmove = 0
	blind:layer = 0
	lying = 1
	icon_state = "dead"
	var/cancel
	for(var/mob/M in world)
		if(M:client && !M:stat)
			cancel = 1

	if(!cancel)
		world << "<B>Everyone is dead! Resetting in 30 seconds!</B>"
		if(ticker && ticker:timing)
			ticker:shuttle_entered = 1
			ticker:timeleft = 1
		else spawn(300) world.Reboot()
	return
/mob/human
	var/t_plasma = 0; var/t_oxygen = 0
/mob/human/m_delay()
	var/tally = 0
	if(istype(wear_suit, /obj/item/weapon/clothing/suit/straight_jacket))
		tally += 15
	if(istype(shoes, /obj/item/weapon/clothing/shoes))
		if(shoes:chained)
			tally += 15
		else tally += -1
	return tally
/mob/human/burn(fi_amount)
	if(r_hand) r_hand:burn(w_radio)
	if(l_hand) l_hand:burn(w_radio)
	if(back) back:burn(w_radio)
	if(belt) belt:burn(w_radio)

	if(wear_suit && wear_suit:flags & 8) wear_suit:burn(fi_amount)
	else
		if(w_uniform) w_uniform:burn(fi_amount)
		if(wear_id) wear_id:burn(fi_amount)
		if(shoes) shoes:burn(fi_amount)
		if(gloves) gloves:burn(fi_amount)

	if(head) head:burn(fi_amount)
	else
		if(wear_mask) wear_mask:burn(fi_amount)
		else
			if(glasses) glasses:burn(fi_amount)
			if(ears) ears:burn(fi_amount)
			if(w_radio) w_radio:burn(w_radio)



/mob/human/Life()
	set background = 1
	var/T = loc
	var/plcheck
	var/oxcheck
	var/ficheck
	health = 100 - oxyloss - toxloss - fireloss - bruteloss
	if(monkeyizing) return
	if(stat != 2)
		if(!m_flag)
			last_move = null
		m_flag = null
		if(mach)
			if(machine)
				mach:icon_state = "mach1"
			else
				mach:icon_state = null
		if(disabilities & 2)
			if(prob(1) && (paralysis < 10 && r_epil < 1))
				src << "\red You have a seizure!"
				paralysis = max(10, paralysis)
		if(disabilities & 4)
			if(prob(5) && (paralysis <= 1 && r_ch_cou < 1))
				drop_item()
				spawn(0)
					emote("cough")
		if(disabilities & 8)
			if(prob(10) && (paralysis <= 1 && r_Tourette < 1))
				stunned = max(10, stunned)
				spawn(0)
					emote("twitch")
		if(disabilities & 16)
			if(prob(10))
				stuttering = max(10, stuttering)
		if(internal && !contents:Find(internal)) internal = null
		if(!wear_mask || !(wear_mask:flags | 8)) internal = null
		if(losebreath > 0)
			losebreath--
			if(prob(7))
				spawn(0) emote("gasp")
			oxcheck = 7
			plcheck = 0
		else
			if(istype(T, /turf))
				var/t = 0.00014
				if(health < -75)
					t = 5e-5
				else if(health < -50)
					t = 0.0001
				if(locate(/obj/move) in T)
					T = locate(/obj/move) in T
				var/turf_total = T:oxygen + T:poison + T:sl_gas + T:co2 + T:n2
				var/G = new /obj/substance/gas()
				G:maximum = 10000
				if(internal)
					internal:process(src, G)
					internals:icon_state = "internal1"
					if(wear_mask:flags & 4 && (!istype(head, /obj/item/weapon/clothing/head) || !(head:flags & 2)))
						G:turf_add(T, G:tot_gas() * 0.5)
						G:turf_take(T, t / 2 * turf_total - G:tot_gas())
				else
					internals:icon_state = "internal0"
					G:turf_take(T, t * turf_total)
				if(G:tot_gas() > 650) G:turf_add(T, G:tot_gas() - 650)
				aircheck(G)
				plcheck = t_plasma
				oxcheck = t_oxygen
				G:turf_add(T, G:tot_gas())












				ficheck = firecheck(T)
			else
				if(istype(T, /obj))
					var/O = T
					O:alter_health(src)
		if(istype(loc, /turf/space) && !(locate(/obj/move) in loc))
			var/layers = 20
			if(istype(head, /obj/item/weapon/clothing/head) && head:flags & 4 || istype(wear_mask, /obj/item/weapon/clothing/mask) && (!(wear_mask:flags & 4) && wear_mask:flags & 8))
				layers -= 5
			if(istype(w_uniform, /obj/item/weapon/clothing/under))
				layers -= 5
			if(istype(wear_suit, /obj/item/weapon/clothing/suit) && wear_suit:flags & 8)
				layers -= 10
			if(layers > oxcheck)
				oxcheck = layers


		if(plcheck && health >= 0)
			if(paralysis <= 0 || weakened <= 0)
				toxloss += plcheck
			else
				toxloss += plcheck
			health = 100 - oxyloss - toxloss - fireloss - bruteloss

		if(oxcheck && health >= 0)
			if(paralysis <= 0 || weakened <= 0)
				oxyloss += oxcheck
			else
				oxyloss += oxcheck
			health = 100 - oxyloss - toxloss - fireloss - bruteloss
		else if(health >= 0)
			if(oxyloss >= 10)
				var/obj/amount = max(0.15, 1)
				oxyloss -= amount
			else
				oxyloss = 0
			health = 100 - oxyloss - toxloss - fireloss - bruteloss

		if(ficheck)
			fireloss += ficheck * 10
		health = 100 - oxyloss - toxloss - fireloss - bruteloss

		if(health <= -100) death()
		else if(sleeping || health < 0)
			if(prob(1))
				if(health <= 20)
					spawn(0) emote("gasp")
				else
					spawn(0) emote("snore")
			if(health < 0)
				if(rejuv <= 0)
					oxyloss++
			health = 100 - oxyloss - toxloss - fireloss - bruteloss
			stat = 1
			if(paralysis < 5) paralysis = 5
		else if(resting)
			if(weakened < 5) weakened = 5
		else if(health < 20)
			if(prob(5))
				if(prob(1))
					if(health <= 20)
						spawn(0) emote("gasp")
				stat = 1
				if(paralysis < 2) paralysis = 2
		health = 100 - oxyloss - toxloss - fireloss - bruteloss
		if(rejuv > 0)
			rejuv--
		if(r_epil > 0)
			r_epil--
			if(antitoxs > 0)
				r_epil -= 4
		if(r_ch_cou > 0)
			r_ch_cou--
			if(antitoxs > 0)
				r_ch_cou -= 4
		if(r_Tourette > 0)
			r_Tourette--
			if(antitoxs > 0)
				r_Tourette -= 4
		if(antitoxs > 0)
			antitoxs--
			if(plasma > 0)
				antitoxs -= 4
		if(plasma > 0)
			plasma--
		blinded = null
		if(drowsyness > 0)
			drowsyness--
			if(paralysis > 1)
				drowsyness -= 0.5
			else if(weakened > 1)
				drowsyness -= 0.25
			eye_blurry = max(2, eye_blurry)
			if(prob(5))
				sleeping = 1
				paralysis = 5
			if(health > -10 && drowsyness > 1200)
				if(antitoxs < 1)
					toxloss += plcheck
					health = 100 - oxyloss - toxloss - fireloss - bruteloss
					plcheck = 1
		var/mental_danger = 0
		health = 100 - oxyloss - toxloss - fireloss - bruteloss
		if(r_epil > 0 && !(disabilities & 2) || r_Tourette > 0 && !(disabilities & 8))
			stuttering = max(2, drowsyness)
			mental_danger = 1
			drowsyness = max(2, drowsyness)
			if(!paralysis)
				if(prob(5))
					src << "\red You have a seizure!"
					paralysis = 10
				else if(prob(5))
					spawn(0)
						emote("twitch")
					stunned = 10
				else if(prob(30))
					spawn(0)
						emote("drool")
		health = 100 - oxyloss - toxloss - fireloss - bruteloss
		if(health > -10)
			var/threshold = 60
			if(mental_danger)
				threshold = 30
			if(r_ch_cou > 3600)
				if(antitoxs < 1)
					toxloss += 1
					health = 100 - oxyloss - toxloss - fireloss - bruteloss
					plcheck = 1
					if(prob(15))
						spawn(0)
							emote("twitch")
							stunned = 2
			if(r_epil > threshold * 60)
				if(antitoxs < 1)
					toxloss += 1
					health = 100 - oxyloss - toxloss - fireloss - bruteloss
					plcheck = 1
					if(prob(15))
						spawn(0)
							emote("twitch")
							stunned = 2
			if(r_Tourette > threshold * 60)
				if(antitoxs < 1)
					toxloss += 1
					health = 100 - oxyloss - toxloss - fireloss - bruteloss
					plcheck = 1
					if(prob(15))
						spawn(0)
							emote("twitch")
							stunned = 2
			if(antitoxs > 7200)
				toxloss += 1
				health = 100 - oxyloss - toxloss - fireloss - bruteloss
				plcheck = 1
				if(prob(15))
					spawn(0)
						emote("drool")
		health = 100 - oxyloss - toxloss - fireloss - bruteloss
		if(health > -50)
			if(plasma > 0)
				if(antitoxs < 1)
					toxloss += 1
					health = 100 - oxyloss - toxloss - fireloss - bruteloss
					plcheck = 1
					if(prob(15))
						spawn(0)
							emote("moan")
		health = 100 - oxyloss - toxloss - fireloss - bruteloss
		if(stat != 2)
			if(paralysis + stunned + weakened > 0)
				if(stunned > 0)
					stunned--
					stat = 0
				if(weakened > 0)
					weakened--
					lying = 1
					stat = 0
				if(paralysis > 0)
					paralysis--
					blinded = 1
					lying = 1
					stat = 1
				canmove = 0
				var/h = hand
				hand = 0
				drop_item()
				hand = 1
				drop_item()
				hand = h
			else
				canmove = 1
				lying = 0
				stat = 0
	else
		lying = 1
		blinded = 1
		stat = 2
		canmove = 0
	if(stuttering > 0)
		stuttering--
	if(eye_blind > 0)
		eye_blind--
		blinded = 1
	if(ear_deaf > 0)
		ear_deaf--
	else if(ear_damage < 25)
		ear_damage -= 0.05
		if(istype(ears, /obj/item/weapon/clothing/ears/earmuffs))
			ear_damage -= 0.15
		ear_damage = max(ear_damage, 0)
	if(buckled) lying = 0
	density = !lying
	pixel_y = 0
	pixel_x = 0
	var/add_weight = 0
	if(istype(l_hand, /obj/item/weapon/grab))
		add_weight += 1250000
	if(istype(r_hand, /obj/item/weapon/grab))
		add_weight += 1250000
	if(grabbed_by:len > 0)
		var/a_grabs = 0
		for(var/obj/item/weapon/grab/G in grabbed_by)
			G:process()
			if(G)
				if(G:state > 1)
					a_grabs++
					if(G:state > 2 && loc == G:assailant:loc)
						density = 0
						lying = 0
						switch(G:assailant:dir)
							if(1)
								pixel_y = 8
							if(2)
								pixel_y = -8
							if(4)
								pixel_x = 8
							if(8)
								pixel_x = -8
		weight = ((grabbed_by:len - a_grabs) / 2 + 1) * 1250000 + a_grabs * 2500000
	else if(lying)
		weight = add_weight + 2500000
	else weight = add_weight + 1250000
	if(sdisabilities & 1 || istype(glasses, /obj/item/weapon/clothing/glasses/blindfold))
		blinded = 1
	if(sdisabilities & 4 || istype(ears, /obj/item/weapon/clothing/ears/earmuffs))
		ear_deaf = 1
	if(eye_blurry > 0)
		eye_blurry--
	if(client)
		client:screen -= main_hud:g_dither
		if(istype(wear_mask, /obj/item/weapon/clothing/mask/gasmask))
			client:screen += main_hud:g_dither
		if(istype(glasses, /obj/item/weapon/clothing/glasses/meson))
			sight |= SEE_TURFS
		else if(istype(glasses, /obj/item/weapon/clothing/glasses/thermal))
			sight |= SEE_TURFS
			sight |= SEE_MOBS
		else
			sight &= 65519
			sight &= 65531
		if(mach)
			if(machine)
				mach:icon_state = "mach1"
			else
				mach:icon_state = null
		if(sleep)
			sleep:icon_state = "sleep[sleeping]"
		if(rest)
			rest:icon_state = "rest[resting]"
		if(healths)
			if(stat < 2)
				if(health >= 100) healths:icon_state = "health0"
				else if(health >= 75) healths:icon_state = "health1"
				else if(health >= 50) healths:icon_state = "health2"
				else if(health > 20) healths:icon_state = "health3"
				else healths:icon_state = "health4"
			else
				healths:icon_state = "health5"
		if(pullin)
			if(pulling)
				pullin:icon_state = "pull1"
			else
				pullin:icon_state = "pull0"
		if(fire)
			if(ficheck)
				fire:icon_state = "fire1"
			else
				fire:icon_state = "fire0"
		if(toxin)
			if(plcheck)
				toxin:icon_state = "toxin1"
			else
				toxin:icon_state = "toxin0"
		if(oxygen)
			if(oxcheck)
				oxygen:icon_state = "oxy1"
			else
				oxygen:icon_state = "oxy0"
		client:screen -= hud_used:blurry
		client:screen -= hud_used:vimpaired
		if(blind && stat != 2)
			if(blinded)
				blind:layer = 18
			else
				blind:layer = 0
				if(disabilities & 1 && !istype(glasses, /obj/item/weapon/clothing/glasses/regular))
					client:screen -= hud_used:vimpaired
					client:screen += hud_used:vimpaired
				else
					client:screen -= hud_used:vimpaired
				if(eye_blurry)
					client:screen -= hud_used:blurry
					client:screen += hud_used:blurry
				else
					client:screen -= hud_used:blurry
		if(stat != 2)
			if(machine)
				if(!machine:check_eye(src))
					reset_view(null)
			else
				reset_view(null)
	if(primary) primary:cleanup()
	UpdateClothing()
	health = 100 - oxyloss - toxloss - fireloss - bruteloss

/mob/human/proc/firecheck(turf/T)
	if(T:firelevel < 2000000) return 0
	var/total = 0
	if(wear_suit)
		if(wear_suit:flags & 8)
			if(T:firelevel > wear_suit:s_fire)
				total += 0.75
		else
			if(T:firelevel > wear_suit:s_fire)
				total += 0.75
			else
				total += 0.5
	else total += 0.75
	if(head)
		if(T:firelevel > head:s_fire)
			total += 0.25
	else if(wear_mask)
		if(T:firelevel > wear_mask:s_fire)
			total += 0.25
	else total += 0.25
	return total
/mob/human/proc/aircheck(obj/G)
	t_oxygen = 0
	t_plasma = 0
	if(G)
		var/a_oxygen = G:oxygen * 0.7
		var/a_plasma = G:plasma
		var/a_sl_gas = G:sl_gas * 0.7

		G:oxygen -= a_oxygen
		G:plasma -= a_plasma
		G:sl_gas -= a_sl_gas

		if(a_oxygen < 67.032)
			t_oxygen = round((67.032 - a_oxygen) / 5) + 1
		if(G:co2 > 5)
			var/t = round((G:co2 - 5) / 5) + 1
			if(G:co2 > 25)
				paralysis = max(paralysis, 3)
				if(G:co2 > 50)
					t = 50
			t_oxygen = max(t_oxygen, t)
		if(a_plasma > 5)
			t_plasma = round(a_plasma / 10) + 1
			if(wear_mask && wear_mask:a_filter >= 4)
				t_plasma = max(t_plasma - 40, 0)
		if(a_sl_gas > 10)
			weakened = max(weakened, 3)
			if(a_sl_gas > 40)
				paralysis = max(paralysis, 3)

		G:co2 += a_oxygen * 0.6


























/mob/human/Stat()
	..()
	statpanel("Status")
	stat(, "Intent: [a_intent]")
	stat(, "Move Mode: [m_intent]")
	if(client:statpanel == "Status")
		if(ticker)
			var/timel = ticker:timeleft
			stat(, "ETA-[timel / 600 % 60]:[timel / 100 % 6][timel / 10 % 10]")


		if(internal)
			if(!internal:gas) del(internal)
			stat(, "Internal Atmosphere: [internal]")
			stat(, "Internal Oxygen: [internal:gas:oxygen]")
			stat(, "Internal Plasma: [internal:gas:plasma]")



/mob/human/las_act(flag, obj/A)
	var/shielded = 0
	for(var/obj/item/weapon/shield/S in src)
		if(S:active)
			shielded = 1
			S:active = 0
			S:icon_state = "shield0"
	if(shielded)
		if(!flag)
			src << "\blue Ohhh that shield isn't going to help here!"
			paralysis = 120
			fireloss += 60
			health = 100 - oxyloss - toxloss - fireloss - bruteloss
	if(locate(/obj/item/weapon/grab) in src)
		var/safe
		if(istype(l_hand, /obj/item/weapon/grab))
			var/G = l_hand
			if(G:state == 3 && get_dir(src, A) == dir)
				safe = G:affecting
		if(istype(r_hand, /obj/item/weapon/grab))
			var/G = r_hand
			if(G:state == 3 && get_dir(src, A) == dir)
				safe = G:affecting
		if(safe)
			return safe:las_act(flag, A)
	if(flag)
		if(istype(wear_suit, /obj/item/weapon/clothing/suit/armor))
			if(prob(5))
				show_message("\red Your armor absorbs the hit!", 4)
				return
		else if(istype(wear_suit, /obj/item/weapon/clothing/suit/swat_suit))
			if(prob(70))
				show_message("\red Your armor absorbs the hit!", 4)
				return
		if(prob(75))
			stunned = 10
		else weakened = 10
	else
		var/d = 20
		if(istype(wear_suit, /obj/item/weapon/clothing/suit/armor))
			if(prob(40))
				show_message("\red Your armor absorbs the hit!", 4)
				return
			else if(prob(40))
				show_message("\red Your armor only softens the hit!", 4)
				if(prob(20)) d = d / 2
				d = d / 2
		else if(istype(wear_suit, /obj/item/weapon/clothing/suit/swat_suit))
			if(prob(70))
				show_message("\red Your armor absorbs the blow!", 4)
				return
			else
				if(prob(90))
					show_message("\red Your armor only softens the blow!", 4)
					if(prob(60)) d = d / 2
					d = d / 2
		if(stat != 2)
			bruteloss += d
			health = 100 - oxyloss - toxloss - fireloss - bruteloss
			if(prob(25)) stunned = 1


/mob/human/proc/monkeyize()
	if(monkeyizing) return
	for(var/obj/item/weapon/W in src)
		u_equip(W)
		if(client) client:screen -= W
		if(W)
			W:loc = loc
			W:dropped(src)
			W:layer = initial(W:layer)
	UpdateClothing()
	monkeyizing = 1
	icon_state = "blank"
	invisibility = 100
	var/animation = new /atom/movable/overlay(loc)
	animation:icon_state = "blank"
	animation:icon = 'mob.dmi'
	animation:master = src
	flick("h2monkey", animation)
	sleep(48)
	del(animation)
	primary:spec_identity = "2B6696D2B127E5A4"
	var/mob/monkey/O = new /mob/monkey(loc)
	O:start = 1
	O:primary = primary
	primary = null
	if(client)
		client:mob = O
	O:loc = loc
	O << "<B>You are now a monkey.</B>"
	O << "<B>Don't be angry at the source as now you are just like him so deal with it.</B>"
	O << "<B>Follow your objective.</B>"
	del(src)
/mob/human/proc/emote(act as text)
	var/param = null
	if(findtext(act, "-"))
		var/t1 = findtext(act, "-")
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)
	var/muzzled = istype(wear_mask, /obj/item/weapon/clothing/mask/muzzle)
	var/message
	var/m_type = 1
	switch(act)
		if("blink")
			message = "<B>[src]</B> blinks."
			m_type = 1
		if("blink_r")
			message = "<B>[src]</B> blinks rapidly."
			m_type = 1
		if("bow")
			if(!buckled)
				var/M
				if(param)
					for(var/mob/A in view())
						if(param == A:name) M = A
				if(!M) param = null
				message = "<B>[src]</B> bows[param ? " to [param]." : "."]"
			m_type = 1
		if("salute")
			if(!buckled)
				var/M
				if(param)
					for(var/mob/A in view())
						if(param == A:name) M = A
				if(!M) param = null
				message = "<B>[src]</B> salutes[param ? " to [param]." : "."]"
			m_type = 1
		if("choke")
			if(!muzzled)
				message = "<B>[src]</B> chokes!"
				m_type = 2
			else
				message = "<B>[src]</B> makes a strong noise."
				m_type = 2
		if("clap")
			if(!restrained())
				message = "<B>[src]</B> claps."
				m_type = 2
		if("drool")
			message = "<B>[src]</B> drools."
			m_type = 1
		if("eyebrow")
			message = "<B>[src]</B> raises an eyebrow."
			m_type = 1
		if("chuckle")
			if(!muzzled)
				message = "<B>[src]</B> chuckles."
				m_type = 2
			else
				message = "<B>[src]</B> makes a noise."
				m_type = 2
		if("twitch")
			message = "<B>[src]</B> twitches violently."
			m_type = 1
		if("twitch_s")
			message = "<B>[src]</B> twitches."
			m_type = 1
		if("faint")
			message = "<B>[src]</B> faints."
			sleeping = 1
			m_type = 1
		if("cough")
			if(!muzzled)
				message = "<B>[src]</B> coughs!"
				m_type = 2
			else
				message = "<B>[src]</B> makes a strong noise."
				m_type = 2
		if("frown")
			message = "<B>[src]</B> frowns."
			m_type = 1
		if("nod")
			message = "<B>[src]</B> nods."
			m_type = 1
		if("blush")
			message = "<B>[src]</B> blushes."
			m_type = 1
		if("gasp")
			if(!muzzled)
				message = "<B>[src]</B> gasps!"
				m_type = 2
			else
				message = "<B>[src]</B> makes a weak noise."
				m_type = 2
		if("giggle")
			if(!muzzled)
				message = "<B>[src]</B> giggles."
				m_type = 2
			else
				message = "<B>[src]</B> makes a noise."
				m_type = 2
		if("glare")
			var/M
			if(param)
				for(var/mob/A in view())
					if(param == A:name) M = A
			if(!M) param = null
			message = "<B>[src]</B> glares[param ? " at [param]." : "."]"
		if("stare")
			var/M
			if(param)
				for(var/mob/A in view())
					if(param == A:name) M = A
			if(!M) param = null
			message = "<B>[src]</B> stares[param ? " at [param]." : "."]"
		if("look")
			var/M
			if(param)
				for(var/mob/A in view())
					if(param == A:name) M = A
			if(!M) param = null
			message = "<B>[src]</B> looks[param ? " at [param]." : "."]"
			m_type = 1
		if("grin")
			message = "<B>[src]</B> grins."
			m_type = 1
		if("cry")
			if(!muzzled)
				message = "<B>[src]</B> cries."
				m_type = 2
			else
				message = "<B>[src]</B> makes a weak noise. [src] frowns."
				m_type = 2
		if("sigh")
			if(!muzzled)
				message = "<B>[src]</B> sighs."
				m_type = 2
			else
				message = "<B>[src]</B> makes a weak noise."
				m_type = 2
		if("laugh")
			if(!muzzled)
				message = "<B>[src]</B> laughs."
				m_type = 2
			else
				message = "<B>[src]</B> makes a noise."
				m_type = 2
		if("mumble")
			message = "<B>[src]</B> mumbles!"
			m_type = 2
		if("grumble")
			if(!muzzled)
				message = "<B>[src]</B> grumbles!"
				m_type = 2
			else
				message = "<B>[src]</B> makes a noise."
				m_type = 2
		if("groan")
			if(!muzzled)
				message = "<B>[src]</B> groans!"
				m_type = 2
			else
				message = "<B>[src]</B> makes a loud noise."
				m_type = 2
		if("moan")
			message = "<B>[src]</B> moans!"
			m_type = 2
		if("point")
			if(!restrained())
				var/M
				if(param)
					for(var/atom/A in view())
						if(param == A:name) M = A
				if(!M) param = null
				else
					var/P = new /obj/point(M:loc)
					spawn(20) del(P)
				message = "<B>[src]</B> points[M ? " to [M]." : "."]"
			m_type = 1
		if("raise")
			if(!restrained())
				message = "<B>[src]</B> raises a hand."
			m_type = 1
		if("shake")
			message = "<B>[src]</B> shakes [gender == "male" ? "his" : "her"] head."
			m_type = 1
		if("shrug")
			message = "<B>[src]</B> shrugs."
			m_type = 1
		if("signal")
			var/t1 = round(text2num(param))
			if(!isnum(t1)) return
			if(t1 > 5 && (r_hand || l_hand)) return
			else if(t1 <= 5 && (r_hand && l_hand)) return
			else if(t1 > 10 || t1 < 1) return
			if(!restrained())
				message = "<B>[src]</B> raises [param] finger\s."
			m_type = 1
		if("smile")
			message = "<B>[src]</B> smiles."
			m_type = 1
		if("shiver")
			message = "<B>[src]</B> shivers."
			m_type = 1
		if("pale")
			message = "<B>[src]</B> goes pale for a second."
			m_type = 1
		if("tremble")
			message = "<B>[src]</B> trembles in fear!"
			m_type = 1
		if("sneeze")
			if(!muzzled)
				message = "<B>[src]</B> sneezes."
				m_type = 2
			else
				message = "<B>[src]</B> makes a strange noise."
				m_type = 2
		if("sniff")
			message = "<B>[src]</B> sniffs."
			m_type = 2
		if("snore")
			if(!muzzled)
				message = "<B>[src]</B> snores."
				m_type = 2
			else
				message = "<B>[src]</B> makes a noise."
				m_type = 2
		if("whimper")
			if(!muzzled)
				message = "<B>[src]</B> whimpers."
				m_type = 2
			else
				message = "<B>[src]</B> makes a weak noise."
				m_type = 2
		if("wink")
			message = "<B>[src]</B> winks."
			m_type = 1
		if("wink")
			message = "<B>[src]</B> winks."
			m_type = 1
		if("yawn")
			if(!muzzled)
				message = "<B>[src]</B> yawns."
				m_type = 2
		if("hug")
			m_type = 1
			if(!restrained())
				var/M
				if(param)
					for(var/mob/A in view(1))
						if(param == A:name) M = A
				if(M == src) M = null
				if(M)
					message = "<B>[src]</B> hugs [M]."
				else
					message = "<B>[src]</B> hugs [gender == "male" ? "himself" : "herself"]."
		if("handshake")
			m_type = 1
			if(!restrained() && !r_hand)
				var/M
				if(param)
					for(var/mob/A in view(1))
						if(param == A:name) M = A
				if(M == src) M = null
				if(M)
					if(M:canmove && (!M:r_hand && !M:restrained()))
						message = "<B>[src]</B> shakes hands with [M]."
					else message = "<B>[src]</B> holds out [gender == "male" ? "his" : "her"] hand to [M]."
		if("help")
			src << "blink, blink_r, blush, bow-(none)/mob, choke, chuckle, clap, cough,\ncry, drool, eyebrow, frown, gasp, giggle, groan, grumble, handshake, hug-(none)/mob, glare-(none)/mob,\ngrin, laugh, look-(none)/mob, moan, mumble, nod, pale, point-atom, raise, salute, shake, shiver, shrug,\nsigh, signal-#1-10, smile, sneeze, sniff, snore, stare-(none)/mob, tremble, twitch, twitch_s, whimper,\nwink, yawn"
		else




			src << "\blue Unusable emote [act]. Say *help for a list."
	if(message)
		for(var/mob/O in view(src))
			O:show_message(message, m_type)
/mob/human/say(message as text)
	var/alt_name
	if(name != rname && wear_id)
		alt_name = " (as [wear_id:registered])"
	if(stat == 2)
		for(var/mob/M in world)
			if(M:stat == 2)
				M << "<B>[rname]</B>[alt_name] [stat > 1 ? "\[<I>dead</I> \]" : ""]: [message]"
		return
	if(copytext(message, 1, 2) == "*" && !stat)
		emote(copytext(message, 2, length(message) + 1))
		return
	message = copytext(message, 1, 256)
	if(sdisabilities & 2) return
	if(stat >= 1) return
	if(!message || istype(wear_mask, /obj/item/weapon/clothing/mask/muzzle)) return
	if(!muted)
		if(stat < 2)
			var/L = list()
			var/pre = copytext(message, 1, 4)
			var/italics = 0
			if(pre == "\[r\]")
				message = copytext(message, 4, length(message) + 1)
				if(r_hand)
					r_hand:talk_into(usr, message)
				L += view(1)
				italics = 1
			else if(pre == "\[h\]")
				message = copytext(message, 4, length(message) + 1)
				if(w_radio)
					w_radio:talk_into(usr, message)
				L += view(1)
				italics = 1
			else if(pre == "\[l\]")
				message = copytext(message, 4, length(message) + 1)
				if(l_hand)
					l_hand:talk_into(usr, message)
				L += view(1)
				italics = 1
			else if(pre == "\[w\]")
				message = copytext(message, 4, length(message) + 1)
				L += view(1)
				italics = 1
			else if(pre == "\[i\]")
				message = copytext(message, 4, length(message) + 1)
				for(var/obj/item/weapon/radio/intercom/I in view(1))
					I:talk_into(usr, message)
				L += view(1)
				italics = 1
			else
				L += view()
				pre = null
			var/T = loc
			if(locate(/obj/move) in T)
				T = locate(/obj/move) in T
			message = html_encode(message)
			if(stuttering)
				message = stutter(message)
			if(italics) message = "<I>[message]</I>"
			if(oxygen && oxygen:icon_state == "oxy0" || (!(istype(T, /turf) || istype(T, /obj/move)) || T:oxygen > 0))
				for(var/mob/M in L)
					if(istype(M, type))
						M:show_message("<B>[rname]</B>[alt_name]: [message]", 2)
					else
						M:show_message("The human: [stars(message)]", 2)
			for(var/obj/O in L)
				spawn(0) if(O) O:hear_talk(usr, message)
		for(var/mob/M in world)
			if(M:stat > 1)
				M << "<B>[rname]</B>[alt_name] [stat > 1 ? "\[<I>dead</I> \]" : ""]: [message]"
	else
		src.show_message("<B>[rname]</B>[alt_name]: [message]", 2)
/mob/human/verb/abandon_mob()
	if(!abandon_allowed) return
	if(stat != 2 || !ticker)
		usr << "\blue<B>You must be dead to use this!</B>"
		return
	usr << "\blue<B>Please roleplay correctly!</B>"
	for(var/obj/screen/t in usr.client:screen)
		if(t:loc == null) del(t)
	var/M = new /mob/human()
	M:key = client:key




/mob/human/proc/update_face()
	del(face); del(face2)
	var/icon/I = icon(icon = 'mob.dmi', icon_state = "eyes")
	var/icon/I2 = icon(icon = 'mob.dmi', icon_state = "eyes2")
	var/F = icon(icon = 'mob.dmi', icon_state = "[h_style_r]")
	var/F2 = icon(icon = 'mob.dmi', icon_state = "[h_style_r]2")
	F:Blend(rgb(r_hair, g_hair, b_hair), 0)
	F2:Blend(rgb(r_hair, g_hair, b_hair), 0)
	I:Blend(rgb(r_eyes, g_eyes, b_eyes), 0)
	I2:Blend(rgb(r_eyes, g_eyes, b_eyes), 0)
	I:Blend(F, 3)
	I2:Blend(F2, 3)
	del(F); del(F2)
	face = new /image()
	face2 = new /image()
	face:icon = I
	face2:icon = I2
	del(I); del(I2)










/mob/human
	var/last_b_state = 1
	var/face
	var/face2
	var/h_style_r = "hair_a"
/mob/human/UpdateClothing()
	..()
	if(monkeyizing) return
	if(!w_uniform)
		var/W = r_store
		if(W)
			u_equip(W)
			if(client) client:screen -= W
			if(W)
				W:loc = loc
				W:dropped(src)
				W:layer = initial(W:layer)
		W = l_store
		if(W)
			u_equip(W)
			if(client) client:screen -= W
			if(W)
				W:loc = loc
				W:dropped(src)
				W:layer = initial(W:layer)
		W = wear_id
		if(W)
			u_equip(W)
			if(client) client:screen -= W
			if(W)
				W:loc = loc
				W:dropped(src)
				W:layer = initial(W:layer)
		W = belt
		if(W)
			u_equip(W)
			if(client) client:screen -= W
			if(W)
				W:loc = loc
				W:dropped(src)
				W:layer = initial(W:layer)
	for(var/i in overlays)
		overlays -= i
	if(lying)
		if(face2) overlays += face2
	else
		if(face) overlays += face
	var/ic = "m-"
	if(gender == "female")
		ic = "[ic]female"
	else
		ic = "[ic]none"
	if(bruteloss)
		if(bruteloss < 30)
			ic = "[ic]-1"
		else
			ic = "[ic]-2"
	else
		ic = "[ic]-0"
	if(fireloss)
		if(fireloss < 30)
			ic = "[ic]1"
		else
			ic = "[ic]2"
	else
		ic = "[ic]0"
	if(lying)
		ic = "[ic]-d"
	icon_state = ic
	if(w_uniform)
		if(istype(w_uniform, /obj/item/weapon/clothing/under))
			var/t1 = w_uniform:color
			if(!t1) t1 = w_uniform:icon_state
			overlays += image(icon = 'mob.dmi', icon_state = "[t1][!lying ? null : "2"]", layer = MOB_LAYER)
		w_uniform:screen_loc = "2,2"
	if(wear_id)
		overlays += image(icon = 'mob.dmi', icon_state = "id[!lying ? null : "2"]", layer = MOB_LAYER)











	if(client)
		client:screen -= hud_used:other
		client:screen -= hud_used:intents
		client:screen -= hud_used:mov_int
	if(client && other)
		client:screen += hud_used:other
		if(gloves)
			var/t1 = gloves:s_istate
			if(!t1) t1 = gloves:icon_state
			overlays += image(icon = 'mob.dmi', icon_state = "[t1][!lying ? null : "2"]", layer = MOB_LAYER)
			gloves:screen_loc = "4,2"
		if(glasses)
			var/t1 = glasses:s_istate
			if(!t1) t1 = glasses:icon_state
			overlays += image(icon = 'mob.dmi', icon_state = "[t1][!lying ? null : "2"]", layer = MOB_LAYER)
			glasses:screen_loc = "6,2"
		if(ears)
			var/t1 = ears:s_istate
			if(!t1) t1 = ears:icon_state
			overlays += image(icon = 'mob.dmi', icon_state = "[t1][!lying ? null : "2"]", layer = MOB_LAYER)
			ears:screen_loc = "9,2"
		if(shoes)
			var/t1 = shoes:s_istate
			if(!t1) t1 = shoes:icon_state
			overlays += image(icon = 'mob.dmi', icon_state = "[t1][!lying ? null : "2"]", layer = MOB_LAYER)
			shoes:screen_loc = "5,2"
	else
		if(gloves)
			var/t1 = gloves:s_istate
			if(!t1) t1 = gloves:icon_state
			overlays += image(icon = 'mob.dmi', icon_state = "[t1][!lying ? null : "2"]", layer = MOB_LAYER)
			gloves:screen_loc = null
		if(glasses)
			var/t1 = glasses:s_istate
			if(!t1) t1 = glasses:icon_state
			overlays += image(icon = 'mob.dmi', icon_state = "[t1][!lying ? null : "2"]", layer = MOB_LAYER)
			glasses:screen_loc = null
		if(ears)
			var/t1 = ears:s_istate
			if(!t1) t1 = ears:icon_state
			overlays += image(icon = 'mob.dmi', icon_state = "[t1][!lying ? null : "2"]", layer = MOB_LAYER)
			ears:screen_loc = null
		if(shoes)
			var/t1 = shoes:s_istate
			if(!t1) t1 = shoes:icon_state
			overlays += image(icon = 'mob.dmi', icon_state = "[t1][!lying ? null : "2"]", layer = MOB_LAYER)
			shoes:screen_loc = null
	if(w_radio)
		if(!lying)
			overlays += image(icon = 'mob.dmi', icon_state = "headset", layer = MOB_LAYER)
		else
			overlays += image(icon = 'mob.dmi', icon_state = "headset2", layer = MOB_LAYER)
		w_radio:screen_loc = "3,1"
	if(wear_mask)
		if(istype(wear_mask, /obj/item/weapon/clothing/mask))
			var/t1 = wear_mask:s_istate
			if(!t1) t1 = wear_mask:icon_state
			overlays += image(icon = 'mob.dmi', icon_state = "[t1][!lying ? null : "2"]", layer = MOB_LAYER)
		wear_mask:screen_loc = "2,3"
	if(client)
		if(i_select)
			if(intent)
				client:screen += hud_used:intents
				i_select:screen_loc = intent
			else
				i_select:screen_loc = null
		if(m_select)
			if(m_int)
				client:screen += hud_used:mov_int
				m_select:screen_loc = m_int
			else
				m_select:screen_loc = null
	if(wear_suit)
		if(istype(wear_suit, /obj/item/weapon/clothing/suit))
			var/t1 = wear_suit:s_istate
			if(!t1) t1 = wear_suit:icon_state
			overlays += image(icon = 'mob.dmi', icon_state = "[t1][!lying ? null : "2"]", layer = MOB_LAYER)
		wear_suit:screen_loc = "2,1"
		if(istype(wear_suit, /obj/item/weapon/clothing/suit/straight_jacket))
			if(handcuffed)
				handcuffed:loc = loc
				handcuffed:layer = initial(handcuffed:layer)
				handcuffed = null
			if(l_hand || r_hand)
				var/h = hand
				hand = 1
				drop_item()
				hand = 0
				drop_item()
				hand = h
	if(client && other)
		if(head)
			var/t1 = head:s_istate
			if(!t1) t1 = head:icon_state
			overlays += image(icon = 'mob.dmi', icon_state = "[t1][!lying ? null : "2"]", layer = MOB_LAYER)
			head:screen_loc = "7,2"
		if(belt)
			var/t1 = belt:s_istate
			if(!t1) t1 = belt:icon_state
			overlays += image(icon = 'belt.dmi', icon_state = "[t1][!lying ? null : "2"]", layer = MOB_LAYER)
			belt:screen_loc = "8,2"
	else
		if(head)
			var/t1 = head:s_istate
			if(!t1) t1 = head:icon_state
			overlays += image(icon = 'mob.dmi', icon_state = "[t1][!lying ? null : "2"]", layer = MOB_LAYER)
			head:screen_loc = null
		if(belt)
			var/t1 = belt:s_istate
			if(!t1) t1 = belt:icon_state
			overlays += image(icon = 'belt.dmi', icon_state = "[t1][!lying ? null : "2"]", layer = MOB_LAYER)
			belt:screen_loc = null
	if(wear_id)
		if(wear_mask && !wear_mask:see_face || head && !head:see_face)
			name = wear_id:registered ? wear_id:registered : "Unknown"
		else if(wear_id:registered != rname) name = "[rname] (as [wear_id:registered])"
		else name = "[rname]"
		wear_id:screen_loc = "1,1"
	else
		name = "[rname]"

	if(l_store)
		l_store:screen_loc = "4,1"
	if(r_store)
		r_store:screen_loc = "5,1"
	if(r_hand)
		var/t1 = r_hand:s_istate
		if(!t1) t1 = r_hand:icon_state
		overlays += image(icon = 'r_items.dmi', icon_state = t1, layer = MOB_LAYER)
		r_hand:screen_loc = "1,2"
	if(l_hand)
		var/t1 = l_hand:s_istate
		if(!t1) t1 = l_hand:icon_state
		overlays += image(icon = 'l_items.dmi', icon_state = t1, layer = MOB_LAYER)
		l_hand:screen_loc = "3,2"
	if(back)
		if(istype(back, /obj/item/weapon/radio/electropack))
			if(!lying)
				overlays += image(icon = 'mob.dmi', icon_state = "backe", layer = MOB_LAYER)
			else
				overlays += image(icon = 'mob.dmi', icon_state = "backe2", layer = MOB_LAYER)
		else
			if(!lying)
				overlays += image(icon = 'mob.dmi', icon_state = "back", layer = MOB_LAYER)
			else
				overlays += image(icon = 'mob.dmi', icon_state = "back2", layer = MOB_LAYER)
		back:screen_loc = "3,3"
	if(handcuffed)
		pulling = null
		if(!lying)
			overlays += image(icon = 'mob.dmi', icon_state = "handcuff1", layer = MOB_LAYER)
		else
			overlays += image(icon = 'mob.dmi', icon_state = "handcuff2", layer = MOB_LAYER)
	if(client)
		client:screen -= contents
		client:screen += contents
	var/shielded = 0
	for(var/obj/item/weapon/shield/S in src)
		if(S:active)
			shielded = 1
			break
	if(shielded)
		overlays += image(icon = 'mob.dmi', icon_state = "shield", layer = MOB_LAYER)
	for(var/mob/M in view(1, src))
		if(M:client && M:machine == src)
			spawn(0) show_inv(M)
	last_b_state = stat
/mob/human/hand_p(mob/M)
	if(M:a_intent == "hurt")
		if(istype(M:wear_mask, /obj/item/weapon/clothing/mask/muzzle)) return
		if((prob(60) || ticker && ticker:mode == "monkey") && health > 0)
			if(istype(wear_suit, /obj/item/weapon/clothing/suit/sp_suit))
				if(prob(95))
					for(var/mob/O in view(src))
						O:show_message("\red<B>The monkey has attempted to bite [src]!</B>", 1)
					return
			else if(istype(wear_suit, /obj/item/weapon/clothing/suit/bio_suit))
				if(prob(90))
					for(var/mob/O in view(src))
						O:show_message("\red<B>The monkey has attempted to bite [src]!</B>", 1)
					return
			else if(istype(wear_suit, /obj/item/weapon/clothing/suit/armor))
				if(prob(60))
					for(var/mob/O in view(src))
						O:show_message("\red<B>The monkey has attempted to bite [src]!</B>", 1)
					return
			else if(istype(wear_suit, /obj/item/weapon/clothing/suit/swat_suit))
				if(prob(99))
					for(var/mob/O in view(src))
						O:show_message("\red<B>The monkey has attempted to bite [src]!</B>", 1)
					return
			for(var/mob/O in view(src))
				if(O:client && !O:blinded)
					O:show_message("\red<B>The monkey has bit [src]!</B>", 1)
			var/damage = rand(1, 3)
			bruteloss += damage
			health = 100 - oxyloss - toxloss - fireloss - bruteloss
			if(ticker && ticker:mode == "monkey")
				monkeyize()
		else
			for(var/mob/O in view(src))
				if(O:client && !O:blinded)
					O:show_message("\red<B>The monkey has attempted to bite [src]!</B>", 1)
/mob/human/attack_paw(mob/M)
	if(M:a_intent == "help")
		sleeping = 0
		resting = 0
		for(var/mob/O in view(src))
			O:show_message("\blue The monkey shakes [src] trying to wake him up!", 1)
	else if(M:a_intent == "hurt")
		if(istype(M:wear_mask, /obj/item/weapon/clothing/mask/muzzle)) return
		if((prob(60) || ticker && ticker:mode == "monkey") && health > 0)
			if(istype(wear_suit, /obj/item/weapon/clothing/suit/sp_suit))
				if(prob(95))
					for(var/mob/O in view(src))
						O:show_message("\red<B>The monkey has attempted to bite [src]!</B>", 1)
					return
			else if(istype(wear_suit, /obj/item/weapon/clothing/suit/bio_suit))
				if(prob(90))
					for(var/mob/O in view(src))
						O:show_message("\red<B>The monkey has attempted to bite [src]!</B>", 1)
					return
			else if(istype(wear_suit, /obj/item/weapon/clothing/suit/armor))
				if(prob(60))
					for(var/mob/O in view(src))
						O:show_message("\red<B>The monkey has attempted to bite [src]!</B>", 1)
					return
			else if(istype(wear_suit, /obj/item/weapon/clothing/suit/swat_suit))
				if(prob(99))
					for(var/mob/O in view(src))
						O:show_message("\red<B>The monkey has attempted to bite [src]!</B>", 1)
					return
			for(var/mob/O in view(src))
				O:show_message("\red<B>The monkey has bit [src]!</B>", 1)
			var/damage = rand(1, 3)
			bruteloss += damage
			health = 100 - oxyloss - toxloss - fireloss - bruteloss
			if(ticker && ticker:mode == "monkey")
				monkeyize()
		else
			for(var/mob/O in view(src))
				O:show_message("\red<B>The monkey has attempted to bite [src]!</B>", 1)








/mob/human/attack_hand(mob/M)
	if(M:a_intent == "help")
		if(health > 0)
			if(w_uniform)
				w_uniform:add_fingerprint(M)
			sleeping = 0
			resting = 0
			for(var/mob/O in view(src))
				O:show_message("\blue[M] shakes [src] trying to wake [src] up!", 1)
		else if(health >= -75)
			if(M:head && M:head:flags & 4 || (M:wear_mask && !(M:wear_mask:flags & 32) || (head && head:flags & 4 || wear_mask && !(wear_mask:flags & 32))))
				M << "\blue<B>Remove that mask!</B>"
				return
			var/obj/equip_e/human/O = new /obj/equip_e/human()
			O:source = M
			O:target = src
			O:s_loc = M:loc
			O:t_loc = loc
			O:place = "CPR"
			requests += O
			spawn(0) O:process()
	else if(M:a_intent == "grab")
		if(M == src) return
		if(w_uniform)
			w_uniform:add_fingerprint(M)
		var/G = new /obj/item/weapon/grab(M)
		G:assailant = M
		if(M:hand)
			M:l_hand = G
		else M:r_hand = G
		G:layer = 20
		G:affecting = src
		grabbed_by += G
		G:synch()
		for(var/mob/O in view(src))
			O:show_message("\red[M] has grabbed [src] passively!", 1)
	else if(M:a_intent == "hurt")
		if(w_uniform)
			w_uniform:add_fingerprint(M)
		var/randn = rand(1, 100)
		if(randn <= 50 && health > 0)
			for(var/mob/O in view(src))
				O:show_message("\red<B>[M] has punched [src]!</B>", 1)
			var/damage = rand(1, 5)
			if(randn <= 15)
				damage = rand(5, 9)
				if(stunned < 5)
					stunned = rand(10, 15)
					spawn(0)
						for(var/mob/O in view(src))
							O:show_message("\red<B>[M] has stunned [src]!</B>", 1)
			else if(randn <= 25)
				damage = rand(5, 9)
				if(weakened < 5)
					weakened = rand(10, 15)
					spawn(0)
						for(var/mob/O in view(src))
							O:show_message("\red<B>[M] has weakened [src]!</B>", 1)
			bruteloss += damage
			health = 100 - oxyloss - toxloss - fireloss - bruteloss
		else
			for(var/mob/O in view(src))
				O:show_message("\red<B>[M] has attempted to punch [src]!</B>", 1)
	else if(!lying)
		if(w_uniform)
			w_uniform:add_fingerprint(M)
		var/randn = rand(1, 100)
		if(randn <= 25)
			weakened = 2
			for(var/mob/O in view(src))
				O:show_message("\red<B>[M] has pushed down [src]!</B>", 1)
		else if(randn <= 60)
			drop_item()
			for(var/mob/O in view(src))
				O:show_message("\red<B>[M] has disarmed [src]!</B>", 1)
		else
			for(var/mob/O in view(src))
				O:show_message("\red<B>[M] has attempted to disarm [src]!</B>", 1)

/mob/human/Topic(href, href_list)
	if(src == usr && !start)
		if(findtext(href, "occ"))
			if(findtext(href, "cancel"))
				usr << browse(null, "window=\ref[src]occupation")
				return
			if(!findtext(href, "job")) SetChoices(text2num(href_list["occ"]))
			else SetJob(occ = text2num(href_list["occ"]), job = href_list["job"])
		else if(findtext(href, "rname"))
			var/t1 = input("Please select a name:", "Character Generation") as text
			if(!start && t1) rname = t1
		else if(findtext(href, "age"))
			var/t1 = input("Please select type in age: 20-45", "Character Generation") as num
			if(!start && t1) age = max(min(round(text2num(t1)), 45), 20)
		else if(findtext(href, "b_type"))
			var/t1 = input("Please select a blood type:", "Character Generation") as null|anything in list("A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-")
			if(!start && t1) b_type = t1
		else if(findtext(href, "nr_hair"))
			var/t1 = input("Please select red hair component: 1-255", "Character Generation") as text
			if(!start && t1) nr_hair = max(min(round(text2num(t1)), 255), 1)
		else if(findtext(href, "ng_hair"))
			var/t1 = input("Please select green hair component: 1-255", "Character Generation") as text
			if(!start && t1) ng_hair = max(min(round(text2num(t1)), 255), 1)
		else if(findtext(href, "nb_hair"))
			var/t1 = input("Please select blue hair component: 1-255", "Character Generation") as text
			if(!start && t1) nb_hair = max(min(round(text2num(t1)), 255), 1)
		else if(findtext(href, "r_eyes"))
			var/t1 = input("Please select red eyes component: 1-255", "Character Generation") as text
			if(!start && t1) r_eyes = max(min(round(text2num(t1)), 255), 1)
		else if(findtext(href, "g_eyes"))
			var/t1 = input("Please select green eyes component: 1-255", "Character Generation") as text
			if(!start && t1) g_eyes = max(min(round(text2num(t1)), 255), 1)
		else if(findtext(href, "b_eyes"))
			var/t1 = input("Please select blue eyes component: 1-255", "Character Generation") as text
			if(!start && t1) b_eyes = max(min(round(text2num(t1)), 255), 1)
		else if(findtext(href, "h_style"))
			var/t1 = input("Please select hair style", "Character Generation") as null|anything in list("Cut Hair", "Short Hair (M)", "Long Hair (F)", "Bald")
			if(!start && t1)
				h_style = t1
				switch(t1)
					if("Short Hair (M)")
						h_style_r = "hair_a"
					if("Long Hair (F)")
						h_style_r = "hair_b"
					if("Cut Hair")
						h_style_r = "hair_c"
					else
						h_style_r = "bald"
		else if(findtext(href, "gender"))
			if(gender == "male")
				gender = "female"
			else
				gender = "male"
		else if(findtext(href, "n_gl"))
			need_gl = !need_gl
		else if(findtext(href, "b_ep"))
			be_epil = !be_epil
		else if(findtext(href, "b_tur"))
			be_tur = !be_tur
		else if(findtext(href, "b_co"))
			be_cough = !be_cough
		else if(findtext(href, "b_stut"))
			be_stut = !be_stut
		else if(findtext(href, "save"))
			var/F = new /savefile("players/[ckey].sav")
			F["version"] << savefile_ver
			F["rname"] << rname
			F["gender"] << gender
			F["age"] << age
			F["occupation1"] << occupation1
			F["occupation2"] << occupation2
			F["occupation3"] << occupation3
			F["nr_hair"] << nr_hair
			F["ng_hair"] << ng_hair
			F["nb_hair"] << nb_hair
			F["h_style"] << h_style
			F["h_style_r"] << h_style_r
			F["r_eyes"] << r_eyes
			F["g_eyes"] << g_eyes
			F["b_eyes"] << b_eyes
			F["b_type"] << b_type
			F["need_gl"] << need_gl
			F["be_epil"] << be_epil
			F["be_tur"] << be_tur
			F["be_cough"] << be_cough
			F["be_stut"] << be_stut
		else if(findtext(href, "load"))
			if(fexists("players/[ckey].sav"))
				var/F = new /savefile("players/[ckey].sav")
				var/test
				F["version"] >> test
				if(test != savefile_ver)
					fdel("players/[ckey].sav")
					alert("Your savefile was incompatible with this version and was deleted.")
					return
				F["rname"] >> rname
				F["gender"] >> gender
				F["age"] >> age
				F["occupation1"] >> occupation1
				F["occupation2"] >> occupation2
				F["occupation3"] >> occupation3
				F["nr_hair"] >> nr_hair
				F["ng_hair"] >> ng_hair
				F["nb_hair"] >> nb_hair
				F["h_style"] >> h_style
				F["h_style_r"] >> h_style_r
				F["r_eyes"] >> r_eyes
				F["g_eyes"] >> g_eyes
				F["b_eyes"] >> b_eyes
				F["b_type"] >> b_type
				F["need_gl"] >> need_gl
				F["be_epil"] >> be_epil
				F["be_tur"] >> be_tur
				F["be_cough"] >> be_cough
				F["be_stut"] >> be_stut
			else
				alert("You do not have a savefile.")
		ShowChoices()
	if(href_list["mach_close"])
		var/t1 = "window=[href_list["mach_close"]]"
		machine = null
		src << browse(null, t1)
	if(href_list["item"] && (!usr.stat && (usr.canmove && (!usr.restrained() && get_dist(src, usr) <= 1))))
		var/obj/equip_e/human/O = new /obj/equip_e/human()
		O:source = usr
		O:target = src
		O:item = usr.equipped()
		O:s_loc = usr.loc
		O:t_loc = loc
		O:place = href_list["item"]
		requests += O
		spawn(0) O:process()
	..()
/obj/list_container

/mob/human/show_inv(mob/user)
	user:machine = src
	var/dat = {"<PRE>
<B><FONT size=3>[name]</FONT></B>
\t<B>Head(Mask):</B> <A href='?src=\ref[src];item=mask'>[wear_mask ? "[wear_mask]" : "Nothing"]</A>
\t\t<B>Headset:</B> <A href='?src=\ref[src];item=headset'>[w_radio ? "[w_radio]" : "Nothing"]</A>
\t<B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[l_hand ? "[l_hand]" : "Nothing"]</A>
\t<B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[r_hand ? "[r_hand]" : "Nothing"]</A>
\t<B>Gloves:</B> <A href='?src=\ref[src];item=gloves'>[gloves ? "[gloves]" : "Nothing"]</A>
\t<B>Eyes:</B> <A href='?src=\ref[src];item=eyes'>[glasses ? "[glasses]" : "Nothing"]</A>
\t<B>Ears:</B> <A href='?src=\ref[src];item=ears'>[ears ? "[ears]" : "Nothing"]</A>
\t<B>Head:</B> <A href='?src=\ref[src];item=head'>[head ? "[head]" : "Nothing"]</A>
\t<B>Shoes:</B> <A href='?src=\ref[src];item=shoes'>[shoes ? "[shoes]" : "Nothing"]</A>
\t<B>Belt:</B> <A href='?src=\ref[src];item=belt'>[belt ? "[belt]" : "Nothing"]</A>
\t<B>Uniform:</B> <A href='?src=\ref[src];item=uniform'>[w_uniform ? "[w_uniform]" : "Nothing"]</A>
\t<B>(Exo)Suit:</B> <A href='?src=\ref[src];item=suit'>[wear_suit ? "[wear_suit]" : "Nothing"]</A>
\t<B>Back:</B> <A href='?src=\ref[src];item=back'>[back ? "[back]" : "Nothing"]</A> [istype(wear_mask, /obj/item/weapon/clothing/mask) && (istype(back, /obj/item/weapon/tank) && !internal) ? " <A href='?src=\ref[src];item=internal'>Set Internal</A>" : ""]
\t<B>ID:</B> <A href='?src=\ref[src];item=id'>[wear_id ? "[wear_id]" : "Nothing"]</A>
\t[handcuffed ? "<A href='?src=\ref[src];item=handcuff'>Handcuffed</A>" : "<A href='?src=\ref[src];item=handcuff'>Not Handcuffed</A>"]
\t[internal ? "<A href='?src=\ref[src];item=internal'>Remove Internal</A>" : ""]
\t<A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
<A href='?src=\ref[user];mach_close=mob[name]'>Close</A>
</PRE>"}
	user << browse(dat, "window=mob[name];size=300x600")
/obj/equip_e
	var/source
	var/s_loc
	var/t_loc
	var/obj/item
	var/place
/obj/equip_e/proc/process()
/obj/equip_e/proc/done()
/obj/equip_e/New()
	spawn(100) del(src)
	..()
/obj/equip_e/monkey
	var/mob/monkey/target
/obj/equip_e/monkey/process()
	if(item)
		item:add_fingerprint(source)
	if(!item)
		switch(place)
			if("head")
				if(!target:wear_mask) del(src)
			if("l_hand")
				if(!target:l_hand) del(src)
			if("r_hand")
				if(!target:r_hand) del(src)
			if("back")
				if(!target:back) del(src)
			if("handcuff")
				if(!target:handcuffed) del(src)
			if("internal")
				if(!(istype(target:wear_mask, /obj/item/weapon/clothing/mask) && (istype(target:back, /obj/item/weapon/tank) && !target:internal)) && !target:internal) del(src)
	if(item)
		for(var/mob/O in view(src.target))
			if(O:client && !O:blinded)
				O:show_message("\red<B>[source] is trying to put a [item] on [target]</B>", 1)
	else
		var/message
		switch(place)
			if("l_hand")
				message = "\red<B>[source] is trying to take off a [target:l_hand] from [target]'s left hand!</B>"
			if("r_hand")
				message = "\red<B>[source] is trying to take off a [target:r_hand] from [target]'s right hand!</B>"
			if("back")
				message = "\red<B>[source] is trying to take off a [target:back] from [target]'s back!</B>"
			if("handcuff")
				message = "\red<B>[source] is trying to unhandcuff [target]!</B>"
			if("internal")
				if(target:internal) message = "\red<B>[source] is trying to remove [target]'s internals</B>"
				else message = "\red<B>[source] is trying to set on [target]'s internals.</B>"
		for(var/mob/M in view(target))
			M:show_message(message, 1)
	spawn(30) done()
/obj/equip_e/monkey/done()
	if(!source || !target) return
	if(source:loc != s_loc) return
	if(target:loc != t_loc) return
	if(item && source:equipped() != item) return
	if(source:restrained() || source:stat) return
	switch(place)
		if("mask")
			if(target:wear_mask)
				var/W = target:wear_mask
				target:u_equip(W)
				if(target:client) target:client:screen -= W
				if(W)
					W:loc = target:loc
					W:dropped(target)
					W:layer = initial(W:layer)
				W:add_fingerprint(source)
			else if(istype(item, /obj/item/weapon/clothing/mask))
				source:drop_item()
				loc = target
				item:layer = 20
				target:wear_mask = item
				item:loc = target
		if("l_hand")
			if(target:l_hand)
				var/W = target:l_hand
				target:u_equip(W)
				if(target:client) target:client:screen -= W
				if(W)
					W:loc = target:loc
					W:dropped(target)
					W:layer = initial(W:layer)
				W:add_fingerprint(source)
			else if(istype(item, /obj/item/weapon))
				source:drop_item()
				loc = target
				item:layer = 20
				target:l_hand = item
				item:loc = target
		if("r_hand")
			if(target:r_hand)
				var/W = target:r_hand
				target:u_equip(W)
				if(target:client) target:client:screen -= W
				if(W)
					W:loc = target:loc
					W:dropped(target)
					W:layer = initial(W:layer)
				W:add_fingerprint(source)
			else if(istype(item, /obj/item/weapon))
				source:drop_item()
				loc = target
				item:layer = 20
				target:r_hand = item
				item:loc = target
		if("back")
			if(target:back)
				var/W = target:back
				target:u_equip(W)
				if(target:client) target:client:screen -= W
				if(W)
					W:loc = target:loc
					W:dropped(target)
					W:layer = initial(W:layer)
				W:add_fingerprint(source)
			else if(istype(item, /obj/item/weapon) && item:flags & 1)
				source:drop_item()
				loc = target
				item:layer = 20
				target:back = item
				item:loc = target
		if("handcuff")
			if(target:handcuffed)
				var/W = target:handcuffed
				target:u_equip(W)
				if(target:client) target:client:screen -= W
				if(W)
					W:loc = target:loc
					W:dropped(target)
					W:layer = initial(W:layer)
				W:add_fingerprint(source)
			else if(istype(item, /obj/item/weapon/handcuffs))
				source:drop_item()
				target:handcuffed = item
				item:loc = target
		if("internal")
			if(target:internal)
				target:internal:add_fingerprint(source)
				target:internal = null
			else
				if(target:internal) target:internal = null
				if(!istype(target:wear_mask, /obj/item/weapon/clothing/mask)) return
				else if(istype(target:back, /obj/item/weapon/tank))
					target:internal = target:back
					target:internal:add_fingerprint(source)
					for(var/mob/M in view(target, 1))
						if(M:client && !M:blinded)
							M:show_message("[target] is now running on internals.", 1)
	source:UpdateClothing()
	target:UpdateClothing()
	del(src)
/obj/equip_e/human
	var/mob/human/target
/obj/equip_e/human/process()
	if(item)
		item:add_fingerprint(source)
	if(!item)
		switch(place)
			if("mask")
				if(!target:wear_mask) del(src)
			if("headset")
				if(!target:w_radio) del(src)
			if("l_hand")
				if(!target:l_hand) del(src)
			if("r_hand")
				if(!target:r_hand) del(src)
			if("suit")
				if(!target:wear_suit) del(src)
			if("uniform")
				if(!target:w_uniform) del(src)
			if("back")
				if(!target:back) del(src)
			if("syringe")
				return
			if("pill")
				return
			if("handcuff")
				if(!target:handcuffed) del(src)
			if("id")
				if(!target:wear_id || !target:w_uniform) del(src)
			if("internal")
				if(!(istype(target:wear_mask, /obj/item/weapon/clothing/mask) && (istype(target:back, /obj/item/weapon/tank) && !target:internal)) && !target:internal) del(src)
	var/L = list("syringe", "pill")
	if(item && !L:Find(place))
		for(var/mob/O in view(target))
			O:show_message("\red<B>[source] is trying to put a [item] on [target]</B>", 1)
	else if(place == "syringe")
		for(var/mob/O in view(src.target))
			O:show_message("\red<B>[source] is trying to inject [target]!</B>", 1)
	else if(place == "pill")
		for(var/mob/O in view(src.target))
			O:show_message("\red<B>[source] is trying to force [target] to swallow [item]!</B>", 1)
	else
		var/message
		switch(place)
			if("mask")
				message = "\red<B>[source] is trying to take off a [target:wear_mask] from [target]'s head!</B>"
			if("headset")
				message = "\red<B>[source] is trying to take off a [target:w_radio] from [target]'s face!</B>"
			if("l_hand")
				message = "\red<B>[source] is trying to take off a [target:l_hand] from [target]'s left hand!</B>"
			if("r_hand")
				message = "\red<B>[source] is trying to take off a [target:r_hand] from [target]'s right hand!</B>"
			if("gloves")
				message = "\red<B>[source] is trying to take off the [target:gloves] from [target]'s hands!</B>"
			if("eyes")
				message = "\red<B>[source] is trying to take off the [target:glasses] from [target]'s eyes!</B>"
			if("ears")
				message = "\red<B>[source] is trying to take off the [target:ears] from [target]'s ears!</B>"
			if("head")
				message = "\red<B>[source] is trying to take off the [target:head] from [target]'s head!</B>"
			if("shoes")
				message = "\red<B>[source] is trying to take off the [target:shoes] from [target]'s feet!</B>"
			if("belt")
				message = "\red<B>[source] is trying to take off the [target:belt] from [target]'s belt!</B>"
			if("suit")
				message = "\red<B>[source] is trying to take off a [target:wear_suit] from [target]'s body!</B>"
			if("back")
				message = "\red<B>[source] is trying to take off a [target:back] from [target]'s back!</B>"
			if("handcuff")
				message = "\red<B>[source] is trying to unhandcuff [target]!</B>"
			if("uniform")
				message = "\red<B>[source] is trying to take off a [target:w_uniform] from [target]'s body!</B>"
			if("pockets")
				message = "\red<B>[source] is trying to empty [target]'s pockets!!</B>"
			if("CPR")
				if(target:cpr_time >= world.time + 3) del(src)
				message = "\red<B>[source] is trying perform CPR on [target]!</B>"
			if("id")
				message = "\red<B>[source] is trying to take off [target:wear_id] from [target]'s uniform!</B>"
			if("internal")
				if(target:internal) message = "\red<B>[source] is trying to remove [target]'s internals</B>"
				else message = "\red<B>[source] is trying to set on [target]'s internals.</B>"
		for(var/mob/M in view(target))
			M:show_message(message, 1)
	spawn(30) done()
/obj/equip_e/human/done()
	if(!source || !target) return
	if(source:loc != s_loc) return
	if(target:loc != t_loc) return
	if(item && source:equipped() != item) return
	if(source:restrained() || source:stat) return
	switch(place)
		if("mask")
			if(target:wear_mask)
				var/W = target:wear_mask
				target:u_equip(W)
				if(target:client) target:client:screen -= W
				if(W)
					W:loc = target:loc
					W:dropped(target)
					W:layer = initial(W:layer)
				W:add_fingerprint(source)
			else if(istype(item, /obj/item/weapon/clothing/mask))
				source:drop_item()
				loc = target
				item:layer = 20
				target:wear_mask = item
				item:loc = target
		if("headset")
			if(target:w_radio)
				var/W = target:w_radio
				target:u_equip(W)
				if(target:client) target:client:screen -= W
				if(W)
					W:loc = target:loc
					W:dropped(target)
					W:layer = initial(W:layer)
			else if(istype(item, /obj/item/weapon/radio/headset))
				source:drop_item()
				loc = target
				item:layer = 20
				target:w_radio = item
				item:loc = target
		if("gloves")
			if(target:gloves)
				var/W = target:gloves
				target:u_equip(W)
				if(target:client) target:client:screen -= W
				if(W)
					W:loc = target:loc
					W:dropped(target)
					W:layer = initial(W:layer)
				W:add_fingerprint(source)
			else if(istype(item, /obj/item/weapon/clothing/gloves))
				source:drop_item()
				loc = target
				item:layer = 20
				target:gloves = item
				item:loc = target
		if("eyes")
			if(target:glasses)
				var/W = target:glasses
				target:u_equip(W)
				if(target:client) target:client:screen -= W
				if(W)
					W:loc = target:loc
					W:dropped(target)
					W:layer = initial(W:layer)
				W:add_fingerprint(source)
			else if(istype(item, /obj/item/weapon/clothing/glasses))
				source:drop_item()
				loc = target
				item:layer = 20
				target:glasses = item
				item:loc = target
		if("belt")
			if(target:belt)
				var/W = target:belt
				target:u_equip(W)
				if(target:client) target:client:screen -= W
				if(W)
					W:loc = target:loc
					W:dropped(target)
					W:layer = initial(W:layer)
				W:add_fingerprint(source)
			else if(istype(item, /obj) && (item:flags & 128 && target:w_uniform))
				source:drop_item()
				loc = target
				item:layer = 20
				target:belt = item
				item:loc = target
		if("head")
			if(target:head)
				var/W = target:head
				target:u_equip(W)
				if(target:client) target:client:screen -= W
				if(W)
					W:loc = target:loc
					W:dropped(target)
					W:layer = initial(W:layer)
				W:add_fingerprint(source)
			else if(istype(item, /obj/item/weapon/clothing/head))
				source:drop_item()
				loc = target
				item:layer = 20
				target:head = item
				item:loc = target
		if("ears")
			if(target:ears)
				var/W = target:ears
				target:u_equip(W)
				if(target:client) target:client:screen -= W
				if(W)
					W:loc = target:loc
					W:dropped(target)
					W:layer = initial(W:layer)
				W:add_fingerprint(source)
			else if(istype(item, /obj/item/weapon/clothing/ears))
				source:drop_item()
				loc = target
				item:layer = 20
				target:ears = item
				item:loc = target
		if("shoes")
			if(target:shoes)
				var/W = target:shoes
				target:u_equip(W)
				if(target:client) target:client:screen -= W
				if(W)
					W:loc = target:loc
					W:dropped(target)
					W:layer = initial(W:layer)
				W:add_fingerprint(source)
			else if(istype(item, /obj/item/weapon/clothing/shoes))
				source:drop_item()
				loc = target
				item:layer = 20
				target:shoes = item
				item:loc = target
		if("l_hand")
			if(istype(target, /obj/item/weapon/clothing/suit/straight_jacket))
				del(src)
			if(target:l_hand)
				var/W = target:l_hand
				target:u_equip(W)
				if(target:client) target:client:screen -= W
				if(W)
					W:loc = target:loc
					W:dropped(target)
					W:layer = initial(W:layer)
				W:add_fingerprint(source)
			else if(istype(item, /obj/item/weapon))
				source:drop_item()
				loc = target
				item:layer = 20
				target:l_hand = item
				item:loc = target
				item:add_fingerprint(target)
		if("r_hand")
			if(istype(target, /obj/item/weapon/clothing/suit/straight_jacket))
				del(src)
			if(target:r_hand)
				var/W = target:r_hand
				target:u_equip(W)
				if(target:client) target:client:screen -= W
				if(W)
					W:loc = target:loc
					W:dropped(target)
					W:layer = initial(W:layer)
				W:add_fingerprint(source)
			else if(istype(item, /obj/item/weapon))
				source:drop_item()
				loc = target
				item:layer = 20
				target:r_hand = item
				item:loc = target
				item:add_fingerprint(target)
		if("uniform")
			if(target:w_uniform)
				var/W = target:w_uniform
				target:u_equip(W)
				if(target:client) target:client:screen -= W
				if(W)
					W:loc = target:loc
					W:dropped(target)
					W:layer = initial(W:layer)
				W:add_fingerprint(source)
				W = target:l_store
				if(W)
					target:u_equip(W)
					if(target:client) target:client:screen -= W
					if(W)
						W:loc = target:loc
						W:dropped(target)
						W:layer = initial(W:layer)
				W = target:r_store
				if(W)
					target:u_equip(W)
					if(target:client) target:client:screen -= W
					if(W)
						W:loc = target:loc
						W:dropped(target)
						W:layer = initial(W:layer)
				W = target:wear_id
				if(W)
					target:u_equip(W)
					if(target:client) target:client:screen -= W
					if(W)
						W:loc = target:loc
						W:dropped(target)
						W:layer = initial(W:layer)
			else if(istype(item, /obj/item/weapon/clothing/under))
				source:drop_item()
				loc = target
				item:layer = 20
				target:w_uniform = item
				item:loc = target
		if("suit")
			if(target:wear_suit)
				var/W = target:wear_suit
				target:u_equip(W)
				if(target:client) target:client:screen -= W
				if(W)
					W:loc = target:loc
					W:dropped(target)
					W:layer = initial(W:layer)
				W:add_fingerprint(source)
			else if(istype(item, /obj/item/weapon/clothing/suit))
				source:drop_item()
				loc = target
				item:layer = 20
				target:wear_suit = item
				item:loc = target
		if("id")
			if(target:wear_id)
				var/W = target:wear_id
				target:u_equip(W)
				if(target:client) target:client:screen -= W
				if(W)
					W:loc = target:loc
					W:dropped(target)
					W:layer = initial(W:layer)
				W:add_fingerprint(source)
			else if(istype(item, /obj/item/weapon/card/id) && target:w_uniform)
				source:drop_item()
				loc = target
				item:layer = 20
				target:wear_id = item
				item:loc = target
		if("back")
			if(target:back)
				var/W = target:back
				target:u_equip(W)
				if(target:client) target:client:screen -= W
				if(W)
					W:loc = target:loc
					W:dropped(target)
					W:layer = initial(W:layer)
				W:add_fingerprint(source)
			else if(istype(item, /obj/item/weapon) && item:flags & 1)
				source:drop_item()
				loc = target
				item:layer = 20
				target:back = item
				item:loc = target
		if("handcuff")
			if(target:handcuffed)
				var/W = target:handcuffed
				target:u_equip(W)
				if(target:client) target:client:screen -= W
				if(W)
					W:loc = target:loc
					W:dropped(target)
					W:layer = initial(W:layer)
				W:add_fingerprint(source)
			else if(istype(item, /obj/item/weapon/handcuffs))
				source:drop_item()
				target:handcuffed = item
				item:loc = target
		if("CPR")
			if(target:cpr_time >= world.time + 30) del(src)
			if(target:health >= -75 && target:health < 0)
				target:cpr_time = world.time
				if(target:health >= -40)
					var/suff = min(target:oxyloss, 5)
					target:oxyloss -= suff
					target:health = 100 - target:oxyloss - target:toxloss - target:fireloss - target:bruteloss
				target:rejuv += 10
				for(var/mob/O in view(source))
					O:show_message("\red[source] performs CPR on [target]!", 1)
				source << "\red Repeat every 7 seconds AT LEAST."
		if("syringe")
			var/S = item
			item:add_fingerprint(source)
			if(!istype(S, /obj/item/weapon/syringe)) del(src)
			if(S:s_time >= world.time + 30) del(src)
			S:s_time = world.time
			var/obj/a = S:inject(target)
			for(var/mob/O in view(source))
				O:show_message("\red[source] injects [target] with the syringe!", 1)
			source << "\red You inject [a] units into [target]. The syringe contains [S:chem:contains()] units."
		if("pill")
			var/obj/item/weapon/S = item
			if(!istype(S, /obj/item/weapon/m_pill)) del(src)
			if(S:s_time >= world.time + 30) del(src)
			S:s_time = world.time
			var/a = S:name
			S:ingest(target)
			for(var/mob/O in view(source))
				O:show_message("\red[source] forces [target] to swallow [a]!", 1)
		if("pockets")
			if(target:l_store)
				var/W = target:l_store
				target:u_equip(W)
				if(target:client) target:client:screen -= W
				if(W)
					W:loc = target:loc
					W:dropped(target)
					W:layer = initial(W:layer)
				W:add_fingerprint(source)
			if(target:r_store)
				var/W = target:r_store
				target:u_equip(W)
				if(target:client) target:client:screen -= W
				if(W)
					W:loc = target:loc
					W:dropped(target)
					W:layer = initial(W:layer)
				W:add_fingerprint(source)
		if("internal")
			if(target:internal)
				target:internal:add_fingerprint(source)
				target:internal = null
			else
				if(target:internal) target:internal = null
				if(!istype(target:wear_mask, /obj/item/weapon/clothing/mask)) return
				else if(istype(target:back, /obj/item/weapon/tank))
					target:internal = target:back
					for(var/mob/M in view(target, 1))
						M:show_message("[target] is now running on internals.", 1)
					target:internal:add_fingerprint(source)
	source:UpdateClothing()
	target:UpdateClothing()
	del(src)


/client/proc/show_panel()
	if(holder)
		holder:update()
/client/New()
	if(banned:Find(ckey))
		del(src)
		return
	world << "<B>[src] has logged in!</B>"
	..()
	spawn(50)
		if(admins:Find(ckey))
			holder = new /obj/admins(src)
			holder:rank = admins["[ckey]"]
			switch(admins["[ckey]"])
				if("Primary Administrator")
					holder:level = 5
				if("Master Administrator")
					holder:level = 4
				if("Administrator")
					holder:level = 3
				if("Supervisor")
					holder:level = 2
				if("Moderator")
					holder:level = 1
				if("Game Master")
					holder:level = 0
				if("Banned")
					del(src)
				else del(holder)
			if(holder)
				holder:owner = src
				verbs += /client/proc/show_panel
/client/Del()
	if(banned:Find(ckey))
		..()
		return
	world << "<B>[src] has logged out!</B>"
	..()
	del(holder)
/obj/list_container/mobl
	var/master
