
/datum/chemical/pathogen/proc/process(obj/source)
/datum/chemical/pathogen
	var/amount = 0
	var/structure_id
/datum/chemical/pathogen/blood
	var/antibodies
	var/antigens
	var/has_oxygen
	var/has_co
/datum/chemical/pathogen/virus
/datum/chemical/pathogen/antibody
	var/tar_struct
	var/a_style







/obj/substance/proc/leak(turf)
/obj/substance/chemical


	var/maximum = 60
	var/datum/chemical/pathogen/pathogens = list()
	var/pl_coag = 0
	var/l_plas = 0
	var/rejuv = 0
	var/s_tox = 0
	var/epil = 0
	var/ch_cou = 0
	var/water = 0

/obj/substance/chemical/proc/contains()
	return l_plas + pl_coag + rejuv + s_tox + epil + ch_cou + water
/obj/substance/chemical/proc/transfer_mob(mob/M, amount)
	if(!ismob(M)) return
	if(contains() > 0)
		var/t1 = contains()
		if(t1 <= 0) return 0
		if(amount > t1) amount = t1







		var/t_t = l_plas * amount / contains()
		var/t_a = pl_coag * amount / contains()
		var/t_r = rejuv * amount / contains()
		var/t_s = s_tox * amount / contains()
		var/t_e = epil * amount / contains()
		var/t_c = ch_cou * amount / contains()

		l_plas -= t_t
		pl_coag -= t_a
		rejuv -= t_r
		s_tox -= t_s
		epil -= t_e
		ch_cou -= t_c

		if(t_t)
			M:plasma += t_t * 6


		if(t_a)
			spawn(6)
				if(M:health >= 0)
					if(t_a * 4 >= M:toxloss)
						M:toxloss = 0
					else
						M:health += t_a * 4
				M:antitoxs += t_a * 180
				M:health = 100 - M:oxyloss - M:toxloss - M:fireloss - M:bruteloss
		if(t_s)
			M:paralysis += t_s * 12
			M:stat = 1
		if(t_r)
			M:rejuv += t_r * 3
			if(M:paralysis)
				M:paralysis = 3
			if(M:weakened)
				M:weakened = 3
			if(M:stunned)
				M:stunned = 3
		if(t_e)
			M:r_epil += t_e * 60
		if(t_c)
			M:r_ch_cou += t_c * 60
		return amount
	else return 0
/obj/substance/chemical/proc/dropper_mob(mob/M, amount)
	if(!ismob(M)) return
	if(contains() > 0)
		var/t1 = contains()
		if(t1 <= 0) return 0
		if(amount > t1) amount = t1







		var/t_t = l_plas * amount / contains()
		var/t_a = pl_coag * amount / contains()
		var/t_r = rejuv * amount / contains()
		var/t_s = s_tox * amount / contains()
		var/t_e = epil * amount / contains()
		var/t_c = ch_cou * amount / contains()

		l_plas -= t_t
		pl_coag -= t_a
		rejuv -= t_r
		s_tox -= t_s
		epil -= t_e
		ch_cou -= t_c

		if(t_t)
			M:eye_stat += t_t * 5
			M:eye_blurry += t_t * 3
		if(t_a)
			M:eye_stat -= t_a * 2
			M:eye_stat = max(0, M:eye_stat)
		if(t_s)
			M:eye_blind += t_s * 10
			M:eye_blurry += t_s * 15
		if(t_r)
			M:eye_stat -= t_r * 5
			M:eye_blurry += t_r * 5
			M:eye_stat = max(0, M:eye_stat)
		if(t_e)
			M:eye_blind += t_e * 5
			M:eye_stat += t_e * 2
			M:eye_blurry += t_e * 20
		if(t_c)
			M:eye_blind += t_c * 2
			M:eye_stat += t_c * 3
			M:eye_blurry += t_c * 20
		if(M:eye_stat >= 20)
			M << "\red Your eyes start to burn badly!"
			M:disabilities |= 1
			if(prob(M:eye_stat - 20 + 1))
				M << "\red You go blind!"
				M:sdisabilities |= 1
		else
			M:disabilities &= 65534
		return amount
	else return 0
/obj/substance/chemical/proc/transfer_from(obj/B, t1)
	var/amount = B:maximum - B:contains()
	if(amount <= 0) return
	if(amount > t1) amount = t1







	var/t2 = contains()
	if(t2 <= 0) return 0

	var/t_t = l_plas * amount / t2
	var/t_a = pl_coag * amount / t2
	var/t_r = rejuv * amount / t2
	var/t_s = s_tox * amount / t2
	var/t_e = epil * amount / t2
	var/t_c = ch_cou * amount / t2
	l_plas = l_plas - t_t
	pl_coag = pl_coag - t_a
	rejuv = rejuv - t_r
	s_tox = s_tox - t_s
	epil = epil - t_e
	ch_cou = ch_cou - t_c
	B:l_plas = B:l_plas + t_t
	B:pl_coag = B:pl_coag + t_a
	B:rejuv = B:rejuv + t_r
	B:s_tox = B:s_tox + t_s
	B:epil = B:epil + t_e
	B:ch_cou = B:ch_cou + t_c
	return amount




/obj/substance/gas/leak(turf/T)
	turf_add(T, co2 + oxygen + plasma)

/obj/substance/gas
	var/temperature = 20
	var/co2 = 0
	var/n2 = 0
	var/oxygen = 0
	var/plasma = 0
	var/sl_gas = 0
	var/maximum = -1
/obj/substance/gas/proc/tot_gas()
	return co2 + oxygen + plasma + sl_gas + n2
/obj/substance/gas/proc/transfer_from(obj/target, amount)
	if(!istype(target, /obj/substance/gas) || !amount) return
	var/t1 = target:co2 + target:oxygen + target:plasma + target:sl_gas + target:n2
	if(!t1) return
	if(amount > t1) amount = t1
	var/t2 = co2 + oxygen + plasma + sl_gas + n2
	if(amount < 0)
		amount = t1
	if(maximum > 0 && maximum - t2 < amount)
		amount = maximum - t2









	var/t_oxy = amount * target:oxygen / t1
	var/t_pla = amount * target:plasma / t1
	var/t_co2 = amount * target:co2 / t1
	var/t_sl_gas = amount * target:sl_gas / t1
	var/t_n2 = amount * target:n2 / t1

	var/t3 = t1 + t2
	var/t4 = t2 * temperature
	var/t5 = t1 * target:temperature
	if(t3 > 0) temperature = (t4 + t5) / t3

	co2 += t_co2
	oxygen += t_oxy
	plasma += t_pla
	sl_gas += t_sl_gas
	n2 += t_n2

	target:oxygen -= t_oxy
	target:co2 -= t_co2
	target:plasma -= t_pla
	target:sl_gas -= t_sl_gas
	target:n2 -= t_n2
/obj/substance/gas/proc/clear()
	oxygen = 0
	plasma = 0
	co2 = 0
	sl_gas = 0
	n2 = 0
/obj/substance/gas/proc/has_gas()
	return co2 + oxygen + plasma + sl_gas + n2 > 0

/obj/substance/gas/proc/turf_add(turf/target, amount)
	if(!istype(target, /turf) && !istype(target, /obj/move) || !amount) return
	if(locate(/obj/move) in target)
		target = locate(/obj/move) in target

	var/t2 = co2 + oxygen + plasma + sl_gas + n2
	if(amount < 0)
		amount = plasma + oxygen + co2 + sl_gas + n2

	if(!t2) return

	var/t_oxy = amount * oxygen / t2
	var/t_pla = amount * plasma / t2
	var/t_co2 = amount * co2 / t2
	var/t_sl_gas = amount * sl_gas / t2
	var/t_n2 = amount * n2 / t2

	co2 -= t_co2
	oxygen -= t_oxy
	plasma -= t_pla
	sl_gas -= t_sl_gas
	n2 -= t_n2

	target:oxygen += t_oxy
	target:co2 += t_co2
	target:poison += t_pla
	target:sl_gas += t_sl_gas
	target:n2 += t_n2

	target:heat += amount * (temperature - -254.7)
	target:res_vars()

/obj/substance/gas/proc/turf_take(turf/target, amount)
	if(!istype(target, /turf) && !istype(target, /obj/move) || !amount) return
	if(locate(/obj/move) in target)
		target = locate(/obj/move) in target
	var/t1 = target:co2 + target:oxygen + target:poison + target:sl_gas + target:n2
	if(!t1) return
	var/t2 = co2 + oxygen + plasma + sl_gas + n2
	if(amount > 0)
		if(maximum > 0 && maximum - t2 < amount)
			amount = maximum - t2
	else
		amount = plasma + oxygen + co2 + sl_gas + n2
	if(amount > t1) amount = t1




















	var/turf_total = target:poison + target:oxygen + target:co2 + target:sl_gas + target:n2
	var/heat_gain = turf_total ? amount / turf_total * target:heat : 0
	var/temp_gain = turf_total ? target:heat / turf_total + -254.7 : 0

	var/t_oxy = amount * target:oxygen / t1
	var/t_pla = amount * target:poison / t1
	var/t_co2 = amount * target:co2 / t1
	var/t_sl_gas = amount * target:sl_gas / t1
	var/t_n2 = amount * target:n2 / t1

	var/t3 = t1 + t2
	var/t4 = t2 * temperature
	var/t5 = t1 * temp_gain
	if(t3 > 0) temperature = (t4 + t5) / t3
	else temperature = 0

	co2 += t_co2
	oxygen += t_oxy
	plasma += t_pla
	sl_gas += t_sl_gas
	n2 += t_n2

	target:oxygen -= t_oxy
	target:co2 -= t_co2
	target:poison -= t_pla
	target:sl_gas -= t_sl_gas
	target:n2 -= t_n2

	target:heat -= heat_gain
	target:res_vars()
/obj/substance/gas/proc/extract_toxs(turf/target)
	if(!istype(target, /turf) && !istype(target, /obj/move)) return
	if(locate(/obj/move) in target)
		target = locate(/obj/move) in target
	var/co2_diff = target:co2 - 0
	var/oxy_diff = target:oxygen - 756000
	var/no2_diff = target:sl_gas - 0
	var/n2_diff = target:n2 - 2844000
	var/plas_diff = target:poison - 0

	if(co2_diff < 0) co2_diff = 0
	if(oxy_diff < 0) oxy_diff = 0
	if(no2_diff < 0) no2_diff = 0
	if(n2_diff < 0) n2_diff = 0
	if(plas_diff < 0) plas_diff = 0

	var/turf_total = target:poison + target:oxygen + target:co2 + target:sl_gas + target:n2
	var/air_total = co2_diff + oxy_diff + no2_diff + n2_diff + plas_diff
	var/heat_gain = turf_total ? air_total / turf_total * target:heat : null
	var/temp_gain = turf_total ? target:heat / turf_total + -254.7 : 0

	co2 += co2_diff
	oxygen += oxy_diff
	sl_gas += no2_diff
	n2 += n2_diff
	plasma += plas_diff

	target:co2 -= co2_diff
	target:oxygen -= oxy_diff
	target:sl_gas -= no2_diff
	target:n2 -= n2_diff
	target:poison -= plas_diff

	var/t3 = turf_total + air_total
	var/t4 = turf_total * temperature
	var/t5 = air_total * temp_gain
	if(t3 > 0) temperature = (t4 + t5) / t3
	else temperature = 0

	target:heat -= heat_gain
	target:res_vars()

























/obj/substance/gas/proc/merge_into(obj/target)
	if(!istype(target, /obj/substance/gas)) return

	var/amount = co2 + oxygen + plasma + sl_gas + n2 + target:co2 + target:oxygen + target:plasma + target:sl_gas + target:n2
	var/t1 = (co2 + oxygen + plasma + sl_gas) * temperature
	var/t2 = (target:co2 + target:oxygen + target:plasma + target:sl_gas) * target:temperature
	if(amount > 0) temperature = (t1 + t2) / amount

	co2 += target:co2
	oxygen += target:oxygen
	plasma += target:plasma
	sl_gas += target:sl_gas
	n2 += target:n2

	target:oxygen = 0
	target:plasma = 0
	target:co2 = 0
	target:sl_gas = 0
	target:n2 = 0
