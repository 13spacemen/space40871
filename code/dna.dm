var/reg_dna = list()
/proc/scram(n)
	var/t = ""
	for(var/p = 1, p <= n, p++)
		t = "[t][rand(1, 9)]"
	return t






/obj/machinery/dna_scanner/allow_drop()
	return 0

/obj/machinery/dna_scanner/relaymove()
	go_out()
/obj/machinery/dna_scanner/verb/eject()
	set src in oview(1)
	if(usr.stat != 0) return
	go_out()
	add_fingerprint(usr)


/obj/machinery/dna_scanner
	var/locked = 0
	var/occupant
	icon = 'Cryogenic2.dmi'
	density = 1
	anchored = 1
/obj/machinery/dna_scanner/verb/place_inside()
	set src in oview(1)
	if(usr.stat != 0) return
	if(occupant)
		usr << "\blue<B>The scanner is already occupied!</B>"
		return
	if(ismob(usr.pulling))
		if(get_dist(src, usr) <= 1 && (get_dist(usr, usr.pulling) <= 1 && (isturf(usr.pulling:loc) && isturf(usr.loc))))
			var/M = usr.pulling
			usr.pulling = null
			if(M:contents:len)
				usr << "\blue<B>Subject cannot have abiotic items on.</B>"
				return
			if(M:client)
				M:client:perspective = EYE_PERSPECTIVE
				M:client:eye = src
			M:loc = src
			occupant = M
			icon_state = "scanner_1"
			for(var/obj/O in src)
				O:loc = loc
	add_fingerprint(usr)
/obj/machinery/dna_scanner/verb/move_inside()
	set src in oview(1)
	if(usr.stat != 0) return
	if(occupant)
		usr << "\blue<B>The scanner is already occupied!</B>"
		return
	if(usr.contents:len)
		usr << "\blue<B>Subject cannot have abiotic items on.</B>"
		return
	usr.pulling = null
	usr.client:perspective = EYE_PERSPECTIVE
	usr.client:eye = src
	usr.loc = src
	occupant = usr
	icon_state = "scanner_1"
	for(var/obj/O in src)
		del(O)
	add_fingerprint(usr)
/obj/machinery/dna_scanner/proc/go_out()
	if(!occupant || locked) return
	for(var/obj/O in src)
		O:loc = loc
	if(occupant:client)
		occupant:client:eye = occupant:client:mob
		occupant:client:perspective = MOB_PERSPECTIVE
	occupant:loc = loc
	occupant = null
	icon_state = "scanner_0"

/obj/machinery/dna_scanner/ex_act(severity)
	switch(severity)
		if(1)
			for(var/atom/movable/A in src)
				A:loc = loc
				A:ex_act(severity)
			del(src)
		if(2)
			if(prob(50))
				for(var/atom/movable/A in src)
					A:loc = loc
					A:ex_act(severity)
				del(src)
		if(3)
			if(prob(25))
				for(var/atom/movable/A in src)
					A:loc = loc
					A:ex_act(severity)
				del(src)

/obj/machinery/scan_console
	var/obj/item/weapon/card/data/scan
	icon_state = "scannerconsole"
	name = "DNA Scanner Access Console"
	var/func = ""
	var/data = ""
	var/special = ""
	var/status
	var/prog_p1
	var/prog_p2
	var/prog_p3
	var/prog_p4
	icon = 'Cryogenic2.dmi'
	density = 1
	anchored = 1
	var/temp
	var/obj/machinery/dna_scanner/connected
/obj/machinery/scan_console/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			if(prob(50)) del(src)

/obj/machinery/scan_console/New()
	..()
	spawn(5)
		connected = locate(/obj/machinery/dna_scanner) in get_step(src, WEST)
/obj/machinery/scan_console/process()
	if(!status) return
	if(!func)
		temp = "No function loaded into memory core!"
		status = null
	var/mob/M
	if(connected && connected:occupant)
		M = connected:occupant
	if(status == "load")
		prog_p1 = null
		prog_p2 = null
		prog_p3 = null
		prog_p4 = null
		switch(func)
			if("dna_trun")
				if(data)
					prog_p1 = copytext(data, 1, 2)
					prog_p2 = text2num(data)
					prog_p3 = special
					status = "dna_trun"
					temp = "Executing trunication function on occupant."
				else
					temp = "No data implanted in core memory."
					status = null
			if("dna_scan")
				if(special)
					if(scan)
						if(istype(M, /mob))
							switch(special)
								if("UI")
									temp = "Scan Complete:<BR>Data downloaded to disk!<BR>Unique Identifier: [M:primary:uni_identity]"
									scan:data = M:primary:uni_identity
								if("SE")
									temp = "Scan Complete:<BR>Data downloaded to disk!<BR>Structural Enzymes: [M:primary:struc_enzyme]"
									scan:data = M:primary:struc_enzyme
								if("UE")
									temp = "Scan Complete:<BR>Data downloaded to disk!<BR>Used Enzynmes: [M:primary:use_enzyme]"
									scan:data = M:primary:use_enzyme
								if("SI")
									temp = "Scan Complete:<BR>Data downloaded to disk!<BR>Species Identifier: [M:primary:spec_identity]"
									scan:data = M:primary:spec_identity
						else temp = "No occupant to scan!"
					else
						temp = "Error: No disk to upload data to."
				else
					temp = "Error: Function program errors."
				status = null
			if("dna_replace")
				if(data && special)
					prog_p1 = special
					prog_p2 = data
					status = "dna_replace"
					temp = "Executing repalcement function on occupant."
				else
					temp = "Error: No DNA data loaded into core or function program errors."
					status = null
			if("dna_add")
				if(data && special)
					prog_p1 = special
					prog_p2 = data
					status = "dna_add"
					temp = "Executing addition function on occupant."
				else
					temp = "Error: No DNA data loaded into core or function program errors."
					status = null
			else
				temp = "Cannot execute program!"
				status = null
	else if(status == "dna_trun")
		if(istype(M, /mob))
			var/t
			switch(prog_p3)
				if("UI") t = M:primary:uni_identity
				if("SE") t = M:primary:struc_enzyme
				if("UE") t = M:primary:use_enzyme
				if("SI") t = M:primary:spec_identity
			if(!prog_p4)
				switch(prog_p1)
					if("a") prog_p4 = length(t)
					if("b") prog_p4 = 1
			else
				if(prog_p1 == "a")
					prog_p4--
				else if(prog_p1 == "b")
					prog_p4--
			switch(prog_p1)
				if("a")
					if(prog_p4 <= 0)
						temp = "Trunication complete"
						status = null
					else
						t = copytext(t, 1, length(t))
						temp = "Trunicating [M:name]'s DNA sequence...<BR>[t]<BR>Status: [prog_p4] units left.<BR><BR><A href='?src=\ref[src];abort=1'>Emergency Abort</A>"
				if("b")
					if(prog_p4 <= 0)
						temp = "Trunication complete"
						status = null
					else
						t = copytext(t, 2, length(t) + 1)
						temp = "Trunicating [M:name]'s DNA sequence...<BR>[t]<BR>Status: [prog_p4] units left.<BR><BR><A href='?src=\ref[src];abort=1'>Emergency Abort</A>"
				if("c")
					if(length(t) <= prog_p2)
						temp = "Limitation complete"
						status = null
					else
						t = copytext(t, 1, length(t))
						temp = "Limiting [M:name]'s DNA sequence...<BR>[t]<BR>Status: [length(t)] units converting to [prog_p2] units.<BR><BR><A href='?src=\ref[src];abort=1'>Emergency Abort</A>"
				else
					if(length(t) <= prog_p2)
						temp = "Limitation complete"
						status = null
					else
						t = copytext(t, 2, length(t) + 1)
						temp = "Limiting [M:name]'s DNA sequence...<BR>[t]<BR>Status: [length(t)] units converting to [prog_p2] units.<BR><BR><A href='?src=\ref[src];abort=1'>Emergency Abort</A>"
			switch(prog_p3)
				if("UI") M:primary:uni_identity = t
				if("SE") M:primary:struc_enzyme = t
				if("UE") M:primary:use_enzyme = t
				if("SI") M:primary:spec_identity = t
		else
			temp = "Process terminated due to lack of occupant in DNA chamber."
			status = null
	else if(status == "dna_replace")
		if(istype(M, /mob))
			var/t
			switch(prog_p1)
				if("UI") t = M:primary:uni_identity
				if("SE") t = M:primary:struc_enzyme
				if("UE") t = M:primary:use_enzyme
				if("SI") t = M:primary:spec_identity
			if(!prog_p4)
				prog_p4 = 1
			else
				prog_p4++
			if(prog_p4 > length(t) || prog_p4 > length(prog_p2))
				temp = "Replacement complete"
				status = null
			else
				t = "[copytext(t, 1, prog_p4)][copytext(prog_p2, prog_p4, prog_p4 + 1)][prog_p4 < length(t) ? copytext(t, prog_p4 + 1, length(t) + 1) : null]"
				temp = "Replacing [M:name]'s DNA sequence...<BR>[t]<BR>Target: [prog_p2]<BR>Status: At position [prog_p4]<BR><BR><A href='?src=\ref[src];abort=1'>Emergency Abort</A>"
			switch(prog_p1)
				if("UI") M:primary:uni_identity = t
				if("SE") M:primary:struc_enzyme = t
				if("UE") M:primary:use_enzyme = t
				if("SI") M:primary:spec_identity = t
		else
			temp = "Process terminated due to lack of occupant in DNA chamber."
			status = null
	else if(status == "dna_add")
		if(istype(M, /mob))
			var/t
			switch(prog_p1)
				if("UI") t = M:primary:uni_identity
				if("SE") t = M:primary:struc_enzyme
				if("UE") t = M:primary:use_enzyme
				if("SI") t = M:primary:spec_identity
			if(!prog_p4)
				prog_p4 = 1
			else
				prog_p4++
			if(prog_p4 > length(prog_p2))
				temp = "Addition complete"
				status = null
			else
				t = "[t][copytext(prog_p2, prog_p4, prog_p4 + 1)]"
				temp = "Adding to [M:name]'s DNA sequence...<BR>[t]<BR>Adding: [prog_p2]<BR>Position: [prog_p4]<BR><BR><A href='?src=\ref[src];abort=1'>Emergency Abort</A>"
			switch(prog_p1)
				if("UI") M:primary:uni_identity = t
				if("SE") M:primary:struc_enzyme = t
				if("UE") M:primary:use_enzyme = t
				if("SI") M:primary:spec_identity = t
		else
			temp = "Process terminated due to lack of occupant in DNA chamber."
			status = null
	else



		status = null
		temp = "Unknown system error."
	for(var/mob/O in view(1, src))
		if(O:client && O:machine == src)
			attack_hand(O)
/obj/machinery/scan_console/attack_paw(mob/user)
	return attack_hand(user)
/obj/machinery/scan_console/attack_hand(mob/user)
	var/dat
	if(temp)
		dat = "[temp]<BR><BR><A href='?src=\ref[src];clear=1'>Clear Message</A>"
	else if(connected)
		var/mob/occupant = connected:occupant
		dat = "<font color='blue'><B>Occupant Statistics:</B></FONT><BR>"
		if(occupant)
			var/t1
			switch(occupant:stat)
				if(0) t1 = "Conscious"
				if(1) t1 = "Unconscious"
				else t1 = "*dead*"
			dat += "[occupant:health > 50 ? "<font color='blue'>" : "<font color='red'>"]\tHealth %: [occupant:health] ([t1])</FONT><BR><BR>"
		else dat += "The scanner is empty.<BR>"
		if(!connected:locked) dat += "<A href='?src=\ref[src];locked=1'>Lock (Unlocked)</A><BR>"
		else dat += "<A href='?src=\ref[src];locked=1'>Unlock (Locked)</A><BR>"
		dat += {"Disk: <A href='?src=\ref[src];scan=1'>[scan ? "[scan:name]" : "----------"]</A><BR>
[scan ? "<A href='?src=\ref[src];u_dat=1'>Upload Data</A>" : "No disk to upload"]<BR>
[data || (func || special) ? "<A href='?src=\ref[src];c_dat=1'>Clear Data</A><BR><A href='?src=\ref[src];e_dat=1'>Execute Data</A><BR>Function Type: [func][special ? "-[special]" : null]<BR>Data: [data]" : "No data uploaded"]<BR>"}
		dat += "<BR><BR><A href='?src=\ref[user];mach_close=scanner'>Close</A>"
	user << browse(dat, "window=scanner;size=400x500")
/obj/machinery/scan_console/Topic(href, href_list)
	if(!istype(usr, /mob/human) && (!ticker || ticker && ticker:mode != "monkey"))
		usr << "\red You don't have the dexterity to do this!"
		return
	if(usr.stat || usr.restrained()) return
	if(usr.contents:Find(src) || get_dist(src, usr) <= 1 && istype(loc, /turf))
		usr.machine = src
		if(href_list["locked"])
			if(connected && connected:occupant)
				connected:locked = !connected:locked
		if(href_list["scan"])
			if(scan)
				scan:loc = loc
				scan = null
			else
				var/I = usr.equipped()
				if(istype(I, /obj/item/weapon/card/data))
					usr.drop_item()
					I:loc = src
					scan = I
		if(href_list["u_dat"])
			if(scan && !status)
				if(scan:function && scan:function != "storage")
					func = scan:function
					special = scan:special
				if(scan:data) data = scan:data
			else
				temp = "No disk found or core data access lock out!"
		if(href_list["c_dat"])
			if(!status)
				func = null
				data = null
				special = null
			else
				temp = "No disk found or core data access lock out!"
		if(href_list["clear"])
			temp = null
		if(href_list["abort"])
			status = null
		if(href_list["e_dat"])
			if(!status)
				status = "load"
				temp = "Loading..."
		add_fingerprint(usr)
		for(var/mob/M in view(1, src))
			if(M:client && M:machine == src) attack_hand(M)
/obj/machinery/computer/dna
	var/obj/item/weapon/card/data/scan
	var/obj/item/weapon/card/data/modify
	name = "DNA operations computer"
	icon_state = "dna_computer"
	var/obj/item/weapon/card/data/modify2
	icon = 'Cryogenic2.dmi'
	density = 1
	anchored = 1
	var/mode
	var/temp
/obj/machinery/computer/dna/attack_paw(mob/user)
	return attack_hand(user)
/obj/machinery/computer/dna/attack_hand(mob/user)
	user:machine = src
	if(istype(user, /mob/human))
		var/dat = {"<I>Please Insert the cards into the slots</I><BR>
\t\t\t\tFunction Disk: <A href='?src=\ref[src];scan=1'>[scan ? "[scan:name]" : "----------"]</A><BR>
\t\t\t\tTarget Disk: <A href='?src=\ref[src];modify=1'>[modify ? "[modify:name]" : "----------"]</A><BR>
\t\t\t\tAux. Data Disk: <A href='?src=\ref[src];modify2=1'>[modify2 ? "[modify2:name]" : "----------"]</A><BR>
\t\t\t\t\t(Not always used!)<BR>
\t\t\t\t[scan ? "<A href='?src=\ref[src];execute=1'>Execute Function</A>" : "No function disk inserted!"]"}
		if(temp)
			dat = "[temp]<BR><BR><A href='?src=\ref[src];clear=1'>Clear Message</A>"
		user << browse(dat, "window=dna_comp")
	else
		var/dat = {"<I>[stars("Please Insert the cards into the slots")]</I><BR>
\t\t\t\t[stars("Function Disk:")] <A href='?src=\ref[src];scan=1'>[scan ? "[scan:name]" : "----------"]</A><BR>
\t\t\t\t[stars("Target Disk:")] <A href='?src=\ref[src];modify=1'>[modify ? "[modify:name]" : "----------"]</A><BR>
\t\t\t\t[stars("Aux. Data Disk:")] <A href='?src=\ref[src];modify2=1'>[modify2 ? "[modify2:name]" : "----------"]</A><BR>
\t\t\t\t\t(Not always used!)<BR>
\t\t\t\t[scan ? "<A href='?src=\ref[src];execute=1'>[stars("Execute Function")]</A>" : stars("No function disk inserted!")]"}
		if(temp)
			dat = "[stars(temp)]<BR><BR><A href='?src=\ref[src];clear=1'>[stars("Clear Message</A>")]"
		user << browse(dat, "window=dna_comp")
/obj/machinery/computer/dna/Topic(href, href_list)
	if(!istype(usr, /mob/human) && (!ticker || ticker && ticker:mode != "monkey"))
		usr << "\red You don't have the dexterity to do this!"
		return
	if(usr.stat || usr.restrained()) return
	if(usr.contents:Find(src) || get_dist(src, usr) <= 1 && istype(loc, /turf))
		usr.machine = src
		if(href_list["modify"])
			if(modify)
				modify:loc = loc
				modify = null
				mode = null
			else
				var/I = usr.equipped()
				if(istype(I, /obj/item/weapon/card/data))
					usr.drop_item()
					I:loc = src
					modify = I
				mode = null
		if(href_list["modify2"])
			if(modify2)
				modify2:loc = loc
				modify2 = null
				mode = null
			else
				var/I = usr.equipped()
				if(istype(I, /obj/item/weapon/card/data))
					usr.drop_item()
					I:loc = src
					modify2 = I
				mode = null
		if(href_list["scan"])
			if(scan)
				scan:loc = loc
				scan = null
				mode = null
			else
				var/I = usr.equipped()
				if(istype(I, /obj/item/weapon/card/data))
					usr.drop_item()
					I:loc = src
					scan = I
				mode = null
		if(href_list["clear"])
			temp = null
		if(href_list["execute"])
			if(scan && scan:function)
				switch(scan:function)
					if("data_mutate")
						if(modify)
							if(!findtext(scan:data, "-"))
								if(modify:data && (scan:data && length(modify:data) >= length(scan:data)))
									modify:data = "[scan:data][length(modify:data) > length(scan:data) ? copytext(modify:data, length(scan:data) + 1, length(modify:data) + 1) : null]"
								else
									temp = "Disk Failure: Cannot examine data! (Null or wrong format)"
							else
								var/d = findtext(scan:data, "-")
								var/t = copytext(scan:data, d + 1, length(scan:data) + 1)
								d = text2num(copytext(1, d))
								if(d && (t && (modify:data && (scan:data && length(modify:data) >= length(t) + d - 1))))
									modify:data = "[copytext(modify:data, 1, d)][t][length(modify:data) > length(t) + d ? copytext(modify:data, length(t) + d, length(modify:data) + 1) : null]"
								else
									temp = "Disk Failure: Cannot examine data! (Null or wrong format)"
						else

							temp = "Disk Failure: Cannot read target disk!"
					if("dna_seq")
						temp = "<TT>DNA Systems Help:\nHuman DNA sequences: (Compressed in *.dna format version 10.76)\n\tSpecies Identification Marker: (28 chromosomes)\n\t\t5BDFE293BA5500F9FFFD500AAFFE\n\tStructural Enzymes:\n\t\tCDE375C9A6C25A7DBDA50EC05AC6CEB63\n\t\tNote: The first id set is used for DNA clean up operations.\n\tUsed Enzymes:\n\t\t493DB249EB6D13236100A37000800AB71\n\tSpecies/Genus Classification: <I>Homo Sapien</I>\n\nMonkey DNA sequences: (Compressed in *.dna format version 10.76)\n\tSpecies Identification Marker: (16 chromosomes)\n\t\t2B6696D2B127E5A4\n\tStructural Enzymes:\n\t\tCDEAF5B90AADBC6BA8033DB0A7FD613FA\n\t\tNote: The first id set is used for DNA clean up operations.\n\tUsed Enzymes:\n\t\tC8FFFE7EC09D80AEDEDB9A5A0B4085B61\n\tSpecies/Genus Classification: Generic Monkey\n</TT>>"
					if("dna_help")




















						temp = "<TT>DNA Systems Help:\nThe DNA systems consists 3 systems.\nI. DNA Scanner/Implanter - This system is slightly advanced to use. It accepts\n\t1 disk. Before you wish to run a function/program you must implant the\n\tdisk data into the temporary memory. Note that once this is done the disk can\n\tbe removed to place a data disk in.\nII. DNA computer - This is a simple yet fast computer that basically operates on data.\nIII. Restructurer - This device reorganizes the anatomical structure of the subject\n\taccording to the DNA sequences. Please note that it is illegal to perform a\n\ttransfer from one species to or from the <I>Homo sapiens</I> species but\n\thuman to human is acceptable under UNSD guidlines.\n\tNote: This machine is programmed to operate on specific preprogrammed species with\n\tspecialized anatomical blueprints hard coded into its databanks. It cannot operate\n\ton other species. (Current: Human, Monkey)\n\nData Disks:\n\tThese run on 2 (or 3) types: DNA scanner program disks and data modification\nfunctions (and disk modification functions)\n\nDisk-Copy\n\tThis erases the target disk and completely copies the data from the aux. disk.\nDisk-Erase\n\tThis erases everything on the target disk.\nData-Clear\n\tThis erases (clears) only the data.\n\nData-Trunicate\n\tThis removes data from the target disk (parameters gathered from data slot on target\n\tdisk). This fuction has 4 modes (a,b,c,default) defined by this way. (mode id)(#)\n\ta - This cuts # data from the end. (ex a1 on ABCD = ABC)\n\tb - This cuts # data from the beginning. (ex b1 on ABCD = BCD)\n\tc - This limits the data from the end. (ex c1 on ABCD = A)\n\tdefault - This limits the data from the end. (ex 1 on ABCD = D)\nData-Add\n\tThis adds thedata on the aux. disk to the data on the target disk.\nData-Sramble\n\tThis scrambles the data on the target disk. The length is equal to\n\tthe length of the original data.\nData-Input\n\tThis lets you input data into the data slot of any data disk.\n\tNote: This doesn't work only on storage.\nData-Mutate\n\tThis basically inserts text. You follow this format:\n\tpos-text (or just text for automatic pos 1)\n\tie 2-IVE on FOUR yields FIVE\n</TT>"
					if("data_add")













































						if(modify)
							if(modify2)
								if(modify:data && modify2:data)
									modify:data += modify2
									temp = "Done!<BR>New Data:<BR>[modify:data]"
								else
									temp = "Cannot read data! (may be null)"
							else
								temp = "Disk Failure: Cannot read aux. data disk!"
						else

							temp = "Disk Failure: Cannot read target disk!"
					if("data_scramble")
						if(modify)
							if(length("[modify:data]") >= 1)
								modify:data = scram(length("[modify:data]"))
								temp = "Data scrambled: [modify:data]"
							else
								temp = "No data to scramble"
						else
							temp = "Disk Failure: Cannot read target disk!"
					if("data_input")
						if(modify)
							var/dat = input(usr, ">", "[name]") as text
							var/obj/item/weapon/card/data/s = scan
							var/obj/item/weapon/card/data/m = modify
							if(usr.stat || (usr.restrained() || (modify != m || scan != s))) return
							if(get_dist(src, usr) <= 1 && istype(loc, /turf))
								modify:data = dat
						else
							temp = "Disk Failure: Cannot read target disk!"
					if("disk_copy")
						if(modify)
							if(modify2)
								modify:function = modify2:function
								modify:data = modify2:data
								modify:special = modify2:special
								temp = "All disk data/programs copied."
							else
								temp = "Disk Failure: Cannot read aux. data disk!"
						else

							temp = "Disk Failure: Cannot read target disk!"
					if("disk_dis")
						if(modify)
							temp = "Function: [modify:function][modify:special ? "-[modify:special]" : null]<BR>Data: [modify:data]"
						else
							temp = "Disk Failure: Cannot read target disk!"
					if("disk_erase")
						if(modify)
							modify:data = null
							modify:function = "storage"
							modify:special = null
							temp = "All Disk contents deleted."
						else
							temp = "Disk Failure: Cannot read target disk!"
					if("data_clear")
						if(modify)
							modify:data = null
							temp = "Disk data cleared."
						else
							temp = "Disk Failure: Cannot read target disk!"
					if("data_trun")
						if(modify)
							if(modify:data && scan:data)
								var/l1 = length(modify:data)
								var/l2 = max(round(text2num(scan:data)), 1)
								switch(copytext(scan:data, 1, 2))
									if("a")
										if(l1 > l2)
											modify:data = copytext(modify:data, 1, l1 - l2 + 1)
										else
											modify:data = ""
										temp = "Done!<BR>New Data:<BR>[modify:data]"
									if("b")
										if(l1 > l2)
											modify:data = copytext(modify:data, l2, l1 + 1)
										else
											modify:data = ""
										temp = "Done!<BR>New Data:<BR>[modify:data]"
									if("c")
										if(l1 >= l2)
											modify:data = copytext(modify:data, l1 - l2, l1 + 1)
										temp = "Done!<BR>New Data:<BR>[modify:data]"
									else
										if(l1 >= l2)
											modify:data = copytext(modify:data, 1, l2 + 1)
										temp = "Done!<BR>New Data:<BR>[modify:data]"
							else
								temp = "Cannot read data! (may be null and note that function data slot is used instead of aux disk!!)"
						else

							temp = "Disk Failure: Cannot read target disk!"
			else
				temp = "System Failure: Cannot read disk function!"
		add_fingerprint(usr)
		for(var/mob/M in view(1, src))
			if(M:client && M:machine == src) attack_hand(M)


/obj/machinery/computer/dna/ex_act(severity)
	switch(severity)
		if(1)
			del(src)
		if(2)
			if(prob(50)) del(src)


/obj/machinery/restruct
	name = "DNA Physical Restructurization Accelerator"
	icon_state = "restruct_0"
/obj/machinery/restruct/allow_drop()
	return 0

/obj/machinery/restruct/verb/eject()
	set src in oview(1)
	if(usr.stat != 0) return
	go_out()
	add_fingerprint(usr)
/obj/machinery/restruct/relaymove()
	go_out()






/obj/machinery/restruct/verb/operate()
	set src in oview(1)
	add_fingerprint(usr)
	if(occupant && occupant:primary)
		switch(occupant:primary:spec_identity)
			if("5BDFE293BA5500F9FFFD500AAFFE")
				if(!istype(occupant, /mob/human))
					for(var/obj/O in src.occupant)
						del(O)
					var/mob/human/O = new /mob/human(src)
					var/M = occupant
					O:start = 1
					O:primary = M:primary
					M:primary = null
					var/t1 = hex2num(copytext(O:primary:uni_identity, 25, 28))
					if(t1 < 125)
						O:gender = "male"
					else
						O:gender = "female"
					M << "Genetic Transversal Complete!"
					if(M:client)
						M << "Transferring..."
						M:client:mob = O

					O << "Neural Sequencing Complete!"
					O:loc = src
					O << "Genetic Transversal Complete!"
					del(M)
					occupant = O
					occupant << "Done!"
			if("2B6696D2B127E5A4")
				if(!istype(occupant, /mob/monkey))
					for(var/obj/O in src.occupant)
						del(O)
					var/mob/monkey/O = new /mob/monkey(src)
					var/M = occupant
					O:start = 1
					O:primary = M:primary
					M:primary = null
					M << "Genetic Transversal Complete!"
					if(M:client)
						M << "Transferring..."
						M:client:mob = O

					O << "Neural Sequencing Complete!"
					O:loc = src
					O << "Genetic Transversal Complete!"
					del(M)
					occupant = O
					occupant << "Done!"
		if(istype(occupant, /mob/human))
			var/H = occupant
			if(reg_dna["[H:primary:uni_identity]"])
				H:rname = reg_dna["[H:primary:uni_identity]"]
			else
				if(findname("Unknown"))
					var/counter = 1
					while(findname("Unknown #[counter]"))
						counter++
					H:rname = "Unknown #[counter]"
				else
					H:rname = "Unknown"
				reg_dna["[H:primary:uni_identity]"] = H:rname
			H << "\red<B>Your name is now [H:rname].</B>"
			var/speak = length(H:primary:struc_enzyme) >= 25 ? hex2num(copytext(H:primary:struc_enzyme, 22, 25)) : 9999
			var/ears = length(H:primary:struc_enzyme) >= 10 ? hex2num(copytext(H:primary:struc_enzyme, 7, 10)) : 9999
			var/vision = length(H:primary:struc_enzyme) >= 16 ? hex2num(copytext(H:primary:struc_enzyme, 13, 16)) : 1
			var/mental1 = length(H:primary:struc_enzyme) >= 31 ? hex2num(copytext(H:primary:struc_enzyme, 28, 31)) : 1
			var/mental2 = length(H:primary:struc_enzyme) >= 28 ? hex2num(copytext(H:primary:struc_enzyme, 25, 28)) : 1
			var/speak2 = length(H:primary:struc_enzyme) >= 22 ? hex2num(copytext(H:primary:struc_enzyme, 19, 22)) : 1
			H:sdisabilities = 0
			H:disabilities = 0
			if(speak < 3776)
				H:disabilities = H:disabilities | 4
			else if(speak > 3776)
				H:sdisabilities = H:sdisabilities | 2

			if(speak2 < 2640)
				H:disabilities = H:disabilities | 16

			if(ears > 3226)
				H:sdisabilities = H:sdisabilities | 4

			if(vision < 1447)
				H:sdisabilities = H:sdisabilities | 1
			else if(vision > 1447)
				H:disabilities = H:disabilities | 1

			if(mental1 < 1742)
				H:disabilities = H:disabilities | 2

			if(mental2 < 1452)
				H:disabilities = H:disabilities | 8
			var/t1
			if(length(H:primary:uni_identity) >= 20)
				t1 = copytext(H:primary:uni_identity, 19, 21)
				if(hex2num(t1) > 127)
					H:gender = "female"
				else
					H:gender = "male"
			else
				H:gender = "neuter"
			if(length(H:primary:uni_identity) >= 18)
				t1 = copytext(H:primary:uni_identity, 17, 19)
				H:ns_tone = hex2num(t1)
			else
				H:ns_tone = 5
			if(length(H:primary:uni_identity) >= 16)
				t1 = copytext(H:primary:uni_identity, 15, 17)
				H:b_eyes = hex2num(t1)
			else
				H:b_eyes = 255
			if(length(H:primary:uni_identity) >= 14)
				t1 = copytext(H:primary:uni_identity, 13, 15)
				H:g_eyes = hex2num(t1)
			else
				H:g_eyes = 255
			if(length(H:primary:uni_identity) >= 12)
				t1 = copytext(H:primary:uni_identity, 11, 13)
				H:r_eyes = hex2num(t1)
			else
				H:r_eyes = 255
			if(length(H:primary:uni_identity) >= 10)
				t1 = copytext(H:primary:uni_identity, 9, 11)
				H:nb_hair = hex2num(t1)
			else
				H:nb_hair = 255
			if(length(H:primary:uni_identity) >= 8)
				t1 = copytext(H:primary:uni_identity, 7, 9)
				H:ng_hair = hex2num(t1)
			else
				H:ng_hair = 255
			if(length(H:primary:uni_identity) >= 6)
				t1 = copytext(H:primary:uni_identity, 5, 7)
				H:nr_hair = hex2num(t1)
			else
				H:nr_hair = 255
			H:r_hair = H:nr_hair
			H:g_hair = H:ng_hair
			H:b_hair = H:nb_hair
			H:s_tone = H:ns_tone
			H:update_face()

















/obj/machinery/restruct
	var/locked = 0
	var/occupant
	icon = 'Cryogenic2.dmi'
	density = 1
	anchored = 1







/obj/machinery/restruct/verb/place_inside()
	set src in oview(1)
	if(usr.stat != 0) return
	if(occupant)
		usr << "\blue<B>The machine is already occupied!</B>"
		return
	if(ismob(usr.pulling))
		if(get_dist(src, usr) <= 1 && (get_dist(usr, usr.pulling) <= 1 && (isturf(usr.pulling:loc) && isturf(usr.loc))))
			var/M = usr.pulling
			if(M:contents:len)
				usr << "\blue<B>Subject cannot have abiotic items on.</B>"
				return
			usr.pulling = null
			if(M:client)
				M:client:perspective = EYE_PERSPECTIVE
				M:client:eye = src
			M:loc = src
			occupant = M
			icon_state = "restruct_1"
			for(var/obj/O in src)
				O:loc = loc
			add_fingerprint(usr)
/obj/machinery/restruct/verb/move_inside()
	set src in oview(1)
	if(usr.stat != 0) return
	if(occupant)
		usr << "\blue<B>The scanner is already occupied!</B>"
		return
	if(usr.contents:len)
		usr << "\blue<B>Subject cannot have abiotic items on.</B>"
		return
	usr.pulling = null
	usr.client:perspective = EYE_PERSPECTIVE
	usr.client:eye = src
	usr.loc = src
	occupant = usr
	icon_state = "restruct_1"
	for(var/obj/O in src)
		del(O)
	add_fingerprint(usr)
/obj/machinery/restruct/proc/go_out()
	if(!occupant || locked) return
	for(var/obj/O in src)
		O:loc = loc
	if(occupant:client)
		occupant:client:eye = occupant:client:mob
		occupant:client:perspective = MOB_PERSPECTIVE
	occupant:loc = loc
	occupant = null
	icon_state = "restruct_0"

/obj/machinery/restruct/ex_act(severity)
	switch(severity)
		if(1)
			for(var/atom/movable/A in src)
				A:loc = loc
				A:ex_act(severity)
			del(src)
		if(2)
			if(prob(50))
				for(var/atom/movable/A in src)
					A:loc = loc
					A:ex_act(severity)
				del(src)
		if(3)
			if(prob(25))
				for(var/atom/movable/A in src)
					A:loc = loc
					A:ex_act(severity)
				del(src)
