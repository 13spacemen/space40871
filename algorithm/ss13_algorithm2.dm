





































var/occupations = list("Engineer", "Engineer", "Security Officer", "Security Officer", "Forensic Technician", "Medical Researcher", "Research Technician", "Toxin Researcher", "Atmospheric Technician", "Medical Doctor", "Station Technician", "Head of Personnel", "Head of Research", "Prison Security", "Prison Security", "Prison Doctor", "Prison Warden")

























var/assistant_occupations = list("Technical Assistant", "Medical Assistant", "Research Assistant", "Staff Assistant")













/world/New()
	..()
	spawn(0) SetupOccupationsList()




/proc/SetupOccupationsList()
	var/new_occupations = list()
	for(var/occupation in occupations)
		if(!new_occupations:Find(occupation))
			new_occupations[occupation] = 1
		else
			new_occupations[occupation] += 1
	occupations = new_occupations



/mob/human
	var/tmp/occupation1 = "No Preference"
	var/tmp/occupation2 = "No Preference"
	var/tmp/occupation3 = "No Preference"
/mob/human/verb/char_setup()
	if(start) return





	ShowChoices()

/mob/human/proc/ShowChoices()
	var/destructive = assistant_occupations:Copy()



	var/dat = "<html><body>"
	dat += "<b>Name:</b> <a href=\"byond://?src=\ref[src];rname=1\"><b>[rname]</b></a><br>"
	dat += "<b>Gender:</b> <a href=\"byond://?src=\
\ref[src];gender=1\"><b>[gender == "male" ? "Male" : "Female"]</b></a><br>"
	dat += "<b>Age</b> - <a href='byond://?src=\ref[src];age=1'>[age]</a><hr>"
	dat += "<hr><b>Occupation Choices</b>:<br>"
	if(destructive:Find(occupation1))
		dat += "\t<a href=\"byond://?src=\ref[src];occ=1\"><b>[occupation1]</b></a><br>"
	else if(occupation1 != "No Preference")
		dat += "\tFirst Choice: <a href=\"byond://?src=\
\ref[src];occ=1\"><b>[occupation1]</b></a><br>"
		if(destructive:Find(occupation2))
			dat += "\tSecond Choice: <a href=\"byond://?src=\
\ref[src];occ=2\"><b>[occupation2]</b></a><BR>"
		else if(occupation2 != "No Preference")
			dat += "\tSecond Choice: <a href=\"byond://?src=\
\ref[src];occ=2\"><b>[occupation2]</b></a><BR>"
			if(destructive:Find(occupation3))
				dat += "\tLast Choice: <a href=\"byond://?src=\
\ref[src];occ=3\"><b>[occupation3]</b></a><BR>"
			else if(occupation3 != "No Preference")
				dat += "\tLast Choice: <a href=\"byond://?src=\
\ref[src];occ=3\"><b>[occupation3]</b></a><BR>"
			else
				dat += "\tLast Choice: <a href=\"byond://?src=\
\ref[src];occ=3\">No Preference</a><br>"
		else
			dat += "\tSecond Choice: <a href=\"byond://?src=\
\ref[src];occ=2\">No Preference</a><br>"
	else
		dat += "\t<a href=\"byond://?src=\ref[src];occ=1\">No Preference</a><br>"
	dat += "<hr><b>Body Data</b><br>"
	dat += "<b>Blood Type:</b> <a href='byond://?src=\ref[src];b_type=1'>[b_type]</a><br>"
	dat += "<b>Hair Color:</b> <font color=\"#[num2hex(nr_hair, 2)][num2hex(ng_hair, 2)][num2hex(nb_hair)]\">test</font><br>"
	dat += " <b><font color=\"#[num2hex(nr_hair, 2)]0000\">Red</font></b> - <a href='byond://?src=\ref[src];nr_hair=1'>[nr_hair]</a>"
	dat += " <b><font color=\"#00[num2hex(ng_hair, 2)]00\">Green</font></b> - <a href='byond://?src=\ref[src];ng_hair=1'>[ng_hair]</a>"
	dat += " <b><font color=\"#0000[num2hex(nb_hair, 2)]\">Blue</font></b> - <a href='byond://?src=\ref[src];nb_hair=1'>[nb_hair]</a>"
	dat += "<br> <b>Style</b> - <a href='byond://?src=\ref[src];h_style=1'>[h_style]</a>"
	dat += "<br><b>Eye Color:</b> <font color=\"#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes, 2)]\">test</font><br>"
	dat += " <b><font color=\"#[num2hex(r_eyes, 2)]0000\">Red</font></b> - <a href='byond://?src=\ref[src];r_eyes=1'>[r_eyes]</a>"
	dat += " <b><font color=\"#00[num2hex(g_eyes, 2)]00\">Green</font></b> - <a href='byond://?src=\ref[src];g_eyes=1'>[g_eyes]</a>"
	dat += " <b><font color=\"#0000[num2hex(b_eyes, 2)]\">Blue</font></b> - <a href='byond://?src=\ref[src];b_eyes=1'>[b_eyes]</a>"
	dat += "<hr><b>Disabilities</b><br>"
	dat += "Need Glasses: <a href=\"byond://?src=\
\ref[src];n_gl=1\"><b>[need_gl ? "Yes" : "No"]</b></a><br>"
	dat += "Epileptic: <a href=\"byond://?src=\
\ref[src];b_ep=1\"><b>[be_epil ? "Yes" : "No"]</b></a><br>"
	dat += "Tourette Syndrome: <a href=\"byond://?src=\
\ref[src];b_tur=1\"><b>[be_tur ? "Yes" : "No"]</b></a><br>"
	dat += "Chronic Cough: <a href=\"byond://?src=\
\ref[src];b_co=1\"><b>[be_cough ? "Yes" : "No"]</b></a><br>"
	dat += "Stutter: <a href=\"byond://?src=\
\ref[src];b_stut=1\"><b>[be_stut ? "Yes" : "No"]</b></a><br>"
	dat += "<hr>"
	dat += "<a href='byond://?src=\ref[src];load=1'>Load Setup</a><br>"
	dat += "<a href='byond://?src=\ref[src];save=1'>Save Setup</a><br>"
	dat += "</body></html>"
	src << browse(dat, "window=mob_occupations;size=300x600")

/mob/human/proc/SetChoices(occ = 1)

	var/HTML = "<body>"
	HTML += "<tt><center>"
	switch(occ)
		if(1) HTML += "<b>Which occupation would you like most?</b><br><br>"
		if(2) HTML += "<b>Which occupation would you like if you couldn't have your first?</b><br><br>"
		if(3)
			HTML += "<b>Which occupation would you like if you couldn't have the others?</b><br><br>"

	for(var/job in occupations + assistant_occupations)
		HTML += "<a href=\"byond://?src=\ref[src];occ=[occ];job=[job]\">[job]</a><br>"
	HTML += "<a href=\"byond://?src=\ref[src];occ=[occ];job=Captain\">Captain</a><br>"

	HTML += "<br>"
	HTML += "<a href=\"byond://?src=\
\ref[src];occ=[occ];job=No Preference\">\[No Preference\]</a><br>"
	HTML += "<a href=\"byond://?src=\ref[src];occ=[occ];cancel\">\[Cancel\]</a>"
	HTML += "</center></tt>"
	usr << browse(HTML, "window=mob_occupation;size=300x500")


/mob/human/proc/SetJob(occ = 1, job = "Captain")














	if(!occupations:Find(job) && (!assistant_occupations:Find(job) && job != "Captain")) return

	switch(occ)
		if(1)
			if(job == occupation1)
				usr << browse(null, "window=mob_occupation")
				return
			else if(job == "No Preference")
				occupation1 = "No Preference"
			else if(job == occupation2)
				job = occupation1
				occupation1 = occupation2
				occupation2 = job
			else if(job == occupation3)
				job = occupation1
				occupation1 = occupation3
				occupation3 = job
			else
				occupation1 = job
		if(2)
			if(job == occupation2)
				src << browse(null, "window=mob_occupation")
				return
			else if(job == "No Preference")
				if(occupation3 != "No Preference")
					occupation2 = occupation3
					occupation3 = "No Preference"
				else
					occupation2 = "No Preference"
			else if(job == occupation1)
				if(occupation2 == "No Preference")
					src << browse(null, "window=mob_occupation")
					return
				job = occupation2
				occupation2 = occupation1
				occupation1 = job
			else if(job == occupation3)
				job = occupation2
				occupation2 = occupation3
				occupation3 = job
			else
				occupation2 = job
		if(3)
			if(job == occupation3)
				usr << browse(null, "window=mob_occupation")
				return
			else if(job == "No Preference")
				occupation3 = "No Preference"
			else if(job == occupation1)
				if(occupation3 == "No Preference")
					src << browse(null, "window=mob_occupation")
					return
				job = occupation3
				occupation3 = occupation1
				occupation1 = job
			else if(job == occupation2)
				if(occupation3 == "No Preference")
					src << browse(null, "window=mob_occupation")
					return
				job = occupation3
				occupation3 = occupation2
				occupation2 = job
			else
				occupation3 = job
	ShowChoices()
	src << browse(null, "window=mob_occupation")











/proc/DivideOccupations()
	var/occupations1 = list()
	var/occupations2 = list()
	var/occupations3 = list()


	var/final_occupations = list()

	var/unassigned_mobs = list()

	var/occupation_choices = occupations:Copy()
	occupation_choices = shuffle(occupation_choices)


	for(var/occupation in occupations + assistant_occupations)
		occupations1[occupation] = list()
		occupations2[occupation] = list()
		occupations3[occupation] = list()
		final_occupations[occupation] = list()
	occupations1["Captain"] = list()
	occupations2["Captain"] = list()
	occupations3["Captain"] = list()
	final_occupations["Captain"] = list()

	for(var/mob/human/M in world)
		if(!M:client || !M:start)
		else






			unassigned_mobs += M


			if(M:occupation1 != "No Preference")
				occupations1[M:occupation1] += M
				if(M:occupation2 != "No Preference")
					occupations2[M:occupation2] += M
					if(M:occupation3 != "No Preference")
						occupations3[M:occupation3] += M


	for(var/occupation in occupations)
		occupations1[occupation] = shuffle(occupations1[occupation])
		occupations2[occupation] = shuffle(occupations2[occupation])
		occupations3[occupation] = shuffle(occupations3[occupation])
	occupations1["Captain"] = shuffle(occupations1["Captain"])
	occupations2["Captain"] = shuffle(occupations2["Captain"])
	occupations3["Captain"] = shuffle(occupations3["Captain"])






	var/captain_choice = occupations1["Captain"]
	if(captain_choice:len)
		final_occupations["Captain"] = captain_choice[1]
		occupation_choices -= "Captain"

		unassigned_mobs -= final_occupations["Captain"]
	if(!final_occupations["Captain"])
		captain_choice = occupations2["Captain"]
		if(captain_choice:len)
			final_occupations["Captain"] = captain_choice[1]
			occupation_choices -= "Captain"
			unassigned_mobs -= final_occupations["Captain"]
	if(!final_occupations["Captain"])
		captain_choice = occupations3["Captain"]
		if(captain_choice:len)
			final_occupations["Captain"] = captain_choice[1]
			occupation_choices -= "Captain"
			unassigned_mobs -= final_occupations["Captain"]
	if(!final_occupations["Captain"])









		var/contenders = list()
		for(var/mob/human/M in world) if(M:client) contenders += M
		var/M = pick(contenders)
		final_occupations["Captain"] = M
		occupation_choices -= "Captain"
		unassigned_mobs -= final_occupations["Captain"]
		occupations1["[M:occupation1]"] -= M
		occupations2["[M:occupation2]"] -= M
		occupations3["[M:occupation3]"] -= M




	for(var/mob/human/M in unassigned_mobs)
		if(assistant_occupations:Find(M:occupation1))
			M:Assign_Rank(M:occupation1)
			unassigned_mobs -= M


	for(var/occupation in occupation_choices)
		var/L = occupations1[occupation]
		if(L:len)


			var/eligible = occupations[occupation]
			var/multiple = eligible > 1

			while(eligible--)
				var/M

				for(var/i = 1, i <= L:len && !M, i++)


					if(unassigned_mobs:Find(L[i])) M = L[i]
				if(M)

					if(multiple)
						final_occupations[occupation] += M
					else
						final_occupations[occupation] = M
					unassigned_mobs -= M

					if(eligible < 1) occupation_choices -= occupation





		if(!occupation_choices:len || !unassigned_mobs:len) break


	for(var/mob/human/M in unassigned_mobs)
		if(assistant_occupations:Find(M:occupation2))
			M:Assign_Rank(M:occupation2)
			unassigned_mobs -= M


	for(var/occupation in occupation_choices)
		var/L = occupations2[occupation]
		if(L:len)


			var/eligible = occupations[occupation]
			var/multiple = eligible > 1
			if(multiple)

				var/X = final_occupations[occupation]
				eligible -= X:len

			while(eligible--)
				var/M
				for(var/i = 1, i <= L:len && !M, i++)
					if(unassigned_mobs:Find(L[i])) M = L[i]
				if(M)
					if(multiple)
						final_occupations[occupation] += M
					else
						final_occupations[occupation] = M
					unassigned_mobs -= M
					if(eligible < 1) occupation_choices -= occupation


		if(!occupation_choices:len || !unassigned_mobs:len) break


	for(var/mob/human/M in unassigned_mobs)
		if(assistant_occupations:Find(M:occupation3))
			M:Assign_Rank(M:occupation3)
			unassigned_mobs -= M


	for(var/occupation in occupation_choices)
		var/L = occupations3[occupation]
		if(L:len)

			var/eligible = occupations[occupation]
			var/multiple = eligible > 1
			if(multiple)
				var/X = final_occupations[occupation]
				eligible -= X:len

			while(eligible--)
				var/M
				for(var/i = 1, i <= L:len && !M, i++)
					if(unassigned_mobs:Find(L[i])) M = L[i]
				if(M)
					if(multiple)
						final_occupations[occupation] += M
					else
						final_occupations[occupation] = M
					unassigned_mobs -= M
					if(eligible < 1) occupation_choices -= occupation




	if(unassigned_mobs:len)


		unassigned_mobs = shuffle(unassigned_mobs)
	for(var/mob/human/M in unassigned_mobs)
		if(occupation_choices:len)
			var/occupation = pick(occupation_choices)
			final_occupations[occupation] = M
			occupation_choices -= occupation
			unassigned_mobs -= M
		else break


	for(var/occupation in final_occupations)
		var/M = final_occupations[occupation]
		if(ismob(M))

			M:Assign_Rank(occupation)
		else

			if(istype(M, /list))
				for(var/mob/human/E in final_occupations[occupation])

					E:Assign_Rank(occupation)



	for(var/mob/human/M in unassigned_mobs)

		M:Assign_Rank(pick("Research Assistant", "Technical Assistant", "Medical Assistant", "Staff Assistant"))









/proc/shuffle(shufflelist)
	if(!shufflelist) return
	var/old_list = shufflelist:Copy()
	var/new_list = list()

	while(old_list:len)
		var/item = old_list[rand(1, old_list:len)]
		new_list += item
		old_list -= item

	return new_list

/mob/human/proc/Assign_Rank(rank)
	if(rank == "Captain") world << "<b>[src] is the captain!</b>"
	if(!w_radio)
		var/H = new /obj/item/weapon/radio/headset(src)
		w_radio = H
		H:layer = 20
	if(!back)
		var/H = new /obj/item/weapon/storage/backpack(src)
		back = H
		H:layer = 20
	if(!glasses)
		if(disabilities & 1)
			var/G = new /obj/item/weapon/clothing/glasses/regular(src)
			glasses = G
			G:layer = 20
	if(!l_store && w_uniform)
		var/S = new /obj/item/weapon/radio/signaler(src)
		l_store = S
		S:layer = 20
	if(!r_store && w_uniform)
		var/S = new /obj/item/weapon/pen(src)
		r_store = S
		S:layer = 20
	if(client && (!wear_id && w_uniform))
		var/obj/item/weapon/card/id/C = new /obj/item/weapon/card/id(src)
		wear_id = C
		C:assignment = rank
		C:layer = 20
		C:registered = rname
		switch(C:assignment)
			if("Research Assistant")
				C:access_level = 1
				C:lab_access = 1
				C:engine_access = 0
				C:air_access = 0
			if("Technical Assistant")
				C:access_level = 1
				C:lab_access = 0
				C:engine_access = 1
				C:air_access = 0
			if("Staff Assistant")
				C:access_level = 2
				C:lab_access = 0
				C:engine_access = 0
				C:air_access = 0
			if("Medical Assistant")
				if(!l_hand)
					var/W = new /obj/item/weapon/storage/firstaid/regular(src)
					l_hand = W
					W:layer = 20
					UpdateClothing()
				C:access_level = 1
				C:lab_access = 1
				C:engine_access = 0
				C:air_access = 0
			if("Engineer")
				if(!l_hand)
					var/W = new /obj/item/weapon/storage/toolbox(src)
					l_hand = W
					W:layer = 20
					UpdateClothing()
				C:access_level = 2
				C:lab_access = 1
				C:engine_access = 3
				C:air_access = 0
			if("Research Technician")
				C:access_level = 2
				C:lab_access = 3
				C:engine_access = 0
				C:air_access = 0
			if("Forensic Technician")
				C:access_level = 3
				C:lab_access = 2
				C:engine_access = 0
				C:air_access = 0
			if("Medical Doctor")
				if(!l_hand)
					var/W = new /obj/item/weapon/storage/firstaid/regular(src)
					l_hand = W
					W:layer = 20
					UpdateClothing()
				C:access_level = 2
				C:lab_access = 0
				C:engine_access = 0
				C:air_access = 0
			if("Prison Doctor")
				if(!l_hand)
					var/W = new /obj/item/weapon/storage/firstaid/regular(src)
					l_hand = W
					W:layer = 20
					UpdateClothing()
				C:access_level = 2
				C:lab_access = 0
				C:engine_access = 0
				C:air_access = 0
			if("Captain")
				C:access_level = 5
				C:air_access = 5
				C:engine_access = 5
				C:lab_access = 5
			if("Security Officer")
				if(!l_hand)
					var/W = new /obj/item/weapon/handcuffs(src)
					l_hand = W
					W:layer = 20
					UpdateClothing()
				C:access_level = 3
				C:lab_access = 0
				C:engine_access = 0
				C:air_access = 0
			if("Prison Security")
				if(!l_hand)
					var/W = new /obj/item/weapon/handcuffs(src)
					l_hand = W
					W:layer = 20
					UpdateClothing()
				C:access_level = 3
				C:lab_access = 0
				C:engine_access = 0
				C:air_access = 0
			if("Medical Researcher")
				C:access_level = 2
				C:lab_access = 5
				C:engine_access = 0
				C:air_access = 0
			if("Toxin Researcher")
				C:access_level = 2
				C:lab_access = 5
				C:engine_access = 0
				C:air_access = 0
			if("Head of Research")
				C:access_level = 4
				C:air_access = 2
				C:engine_access = 2
				C:lab_access = 5
			if("Head of Personnel")
				C:access_level = 4
				C:air_access = 2
				C:engine_access = 2
				C:lab_access = 4
			if("Prison Warden")
				C:access_level = 4
				C:air_access = 2
				C:engine_access = 2
				C:lab_access = 4
			if("Station Technician")
				if(!l_hand)
					var/W = new /obj/item/weapon/storage/toolbox(src)
					l_hand = W
					W:layer = 20
					UpdateClothing()
				C:access_level = 2
				C:lab_access = 0
				C:engine_access = 2
				C:air_access = 3
			if("Atmospheric Technician")
				C:access_level = 3
				C:lab_access = 0
				C:engine_access = 0
				C:air_access = 4
		C:name = "[C:registered]'s ID Card ([C:access_level]>[C:lab_access]-[C:engine_access]-[C:air_access])"
		src << "<B>You are the [C:assignment].</B>"
		var/S = locate("start*[C:assignment]")
		if(istype(S, /obj/start) && (istype(S:loc, /turf) && !ctf))
			src << "\blue<B>You have been teleported to your new starting location!</B>"
			loc = S:loc
