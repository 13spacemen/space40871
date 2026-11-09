/obj/photoshot
/obj/photoshot/two
	var/imgstring
	var/photo


















var/photoid = 0
var/photos[0]




/proc/createphoto(zlevel = 1, tilesizex = 16, tilesizey = 16, denytypes, minx, maxx, miny, maxy, loc)
	var/pid = photoid
	var/ids[0]
	var/id = 1
	var/filename = "photos/[photoid].tmp"
	photoid += 1
	var/html = "<html><body><table border=0 cellspacing=0 cellpadding=0>"
	if(fexists(filename)) fdel(filename)
	var/O
	if(!loc) return
	else O = new /obj/photoshot(loc)
	var/turfs[0]
	for(var/T as turf in view(1000, O)) turfs += T
	for(var/y = maxy, y >= miny, y--)
		html += "</tr><tr>"
		text2file(html, filename)
		html = ""
		sleep(0)
		for(var/x = minx, x <= maxx, x++)

			var/turf/T = locate(x, y, zlevel)
			if(!T) continue
			if(!turfs:Find(T))
				src << browse_rsc('black.dmi', "black.dmi")
				html += "<td><img src=\"black.dmi\" width=[tilesizex] height=[tilesizey]></td>"
				var/xxxx = 0
				for(var/obj/photoshot/two/III in photos) if(III:photo == 'black.dmi') xxxx = 1
				if(!xxxx)
					var/III = new /obj/photoshot/two(photos)
					photos += III
					III:imgstring = "black"
					III:photo = 'black.dmi'
				continue
			var/I = icon(T:icon, T:icon_state)
			var/imgstring = dd_replacetext("[T:type]-[T:icon_state]", "/", "_")


			for(var/atom/movable/A in T)
				if(A == T) continue
				if(!turfs:Find(T)) continue

				var/allowed = 1
				for(var/X in denytypes)
					if(istype(A, X))
						allowed = 0
						break
				if(!allowed) continue
				if(!A:icon) continue
				var/II
				II = image(A:icon, A:icon_state, A:dir)
				world << II
				I:Blend(icon(II:icon, II:icon_state, II:dir), 3)
				imgstring += dd_replacetext("__[A:type]_[A:icon_state]_[A:dir]", "/", "_")
				var/overlay[0]
				for(var/index = 1 to A:overlays:len)
					overlay += A:overlays[index]
					II = A:overlays[index]
					if(!II:icon) continue
					I:Blend(icon(II:icon, II:icon_state, II:dir), 3)
					imgstring += dd_replacetext("__[II:icon]_[II:icon_state]_[A:dir]", "/", "_")
				if(ismob(A))
					ids += "[id]: <b>[A:name]</b>"
					A:CreateID(id, 255, 255, 255)
					for(var/index = 1 to A:overlays:len)
						II = A:overlays[index]
						I:Blend(icon(II:icon, II:icon_state, II:dir), 3)
						imgstring += dd_replacetext("__[II:icon]_[II:icon_state]_[A:dir]", "/", "_")
					id += 1
					A:overlays:Cut()
					for(var/index = 1 to overlay:len) A:overlays += overlay[index]
			src << browse_rsc(I, "[imgstring].dmi")
			var/xxxx = 0
			for(var/obj/photoshot/two/III in photos) if(III:photo == I) xxxx = 1
			if(!xxxx)
				var/III = new /obj/photoshot/two(photos)
				photos += III
				III:imgstring = imgstring
				III:photo = I
			html += "<td><img src=\"[imgstring].dmi\" width=[tilesizex] height=[tilesizey]></td>"
	var/htmll = "<p><b>IDs</b><br>"
	var/xxx = 0
	for(var/QQ in ids)
		xxx = 1
		htmll += "#[QQ]<BR>"
	if(!xxx) htmll += "N/A"
	text2file(htmll, filename)
	text2file("</table></body></html>", filename)
	del(O)
	return pid

/mob/proc/displayphoto(id, windowname = "map", browseopt = "")
	src << browse("<body bgcolor=black text=white><p align=center><font size=5 face='Verdana'>...please wait...<p><center>...loading photo \
[id]...</center></font></body>", "window=\
[windowname],size=[min(world.maxx * 16 + 50, 630)]x[min(world.maxy * 16 + 150, 450)],[browseopt]")
	for(var/obj/photoshot/two/X in photos) src << browse_rsc(X:photo, "[X:imgstring].dmi")
	if(id > photoid) return 0
	var/filename = "photos/[id].tmp"
	if(fexists(filename))
		spawn(20)
			src << browse(file(filename), "window=\
[windowname];size=500x500;[browseopt]")
	else src << "Photo ID does not exist!"

/world/Del()
	..()
	fdel("photos/")

var/DF_WRAP = 0
var/DF_WRAP_NONE = 1
var/DF_WRAP_ELLIPSIS = 2
var/DF_WRAP_ONELINE = 3
var/DF_WRAP_MASK = 3
var/DF_JUSTIFY = 12
var/DF_JUSTIFY_LEFT = 0
var/DF_JUSTIFY_RIGHT = 4
var/DF_JUSTIFY_CENTER = 8
var/DF_BREAK_FIRST = 128
var/DF_INCLUDE_AC = 64
var/DF_SET_WIDTH = 256
var/DF_NO_FORMAT = 4096

/dmifont
	var/name
	var/height
	var/ascent
	var/descent
	var/avgwidth
	var/maxwidth
	var/overhang
	var/inleading
	var/exleading
	var/defchar
	var/start
	var/end
	var/icon
	var/antialias = 1
	var/tmp/ellipsiswidth = 0
	var/tmp/hyphenwidth = 0
	var/tmp/hyphenwidthfull = 0
	var/tmp/maxjustify = 0
	var/metrics
	var/defined
	var/tmp/sizex = 1
	var/tmp/sizey = 1



























/dmifont/New()
	if(istext(icon)) icon = file(icon)
	sizex = max(1, maxwidth + 31 >> 5)
	sizey = max(1, height + 31 >> 5)
	var/idx = (46 - start) * 3
	if(idx > 0 && idx < metrics:len)
		ellipsiswidth = max(0, (metrics[idx + 1] + metrics[idx + 2]) * 3 + metrics[idx + 3] * 2)
	idx -= 3
	if(idx > 0 && idx < metrics:len)
		hyphenwidth = max(0, metrics[idx + 1] + metrics[idx + 2])
		hyphenwidthfull = max(0, metrics[idx + 1] + metrics[idx + 2] + metrics[idx + 3])
	idx -= 39
	if(idx > 0 && idx < metrics:len)
		maxjustify = max(3, metrics[idx + 1] + metrics[idx + 2] + metrics[idx + 3])
	if(!defined)
		defined = new /list()
		while(defined:len < start - 1 && defined:len < 13) defined += null
		for(var/ch = start, ch <= end, ch++)
			var/tf = ascii2text(ch)
			if(sizex > 1 || sizey > 1)
				if("[tf]0,0" in icon_states(icon))
					defined += tf
					continue
			else if(tf in icon_states(icon))
				defined += tf
				continue
			defined += null
		while(defined:len < 255) defined += null
	else








































		if(defined:len < 255)
			if(end < 255) defined += null
			else
				var/tf = text2ascii(255)
				if(sizex > 1 || sizey > 1)
					defined += ("[tf]0,0" in icon_states(icon)) ? tf : null
				else defined += tf







/dmifont/proc/GetWidth(text, flags = 0, firstline = 0)
	. = 0
	var/longest = 0
	if(!length(text)) return
	var/i = 1
	var/idx
	while(i <= length(text))
		var/ch = text2ascii(text, i++)
		if(ch <= 10)
			if(ch <= 7) . += ch
			if(ch <= 9) continue
			if(. && (idx && !(flags & 64))) . -= max(metrics[idx + 3], 0)
			longest = max(longest, . + firstline)
			. = 0
			firstline = 0
			idx = 0
			continue
		idx = (ch - start) * 3
		if(idx <= 0 || idx >= metrics:len) idx = (defchar - start) * 3
		if(!. && !(flags & 64)) . -= metrics[idx + 1]
		. += metrics[idx + 1] + metrics[idx + 2] + metrics[idx + 3]
	if(. && (idx && !(flags & 64))) . -= max(metrics[idx + 3], 0)
	. = max(. + firstline, longest)
	if(. > 0) . += overhang

/dmifont/proc/GetCharAWidth(ch)
	var/idx = (ch - start) * 3
	if(idx <= 0 || idx >= metrics:len) idx = (defchar - start) * 3
	return metrics[idx + 1]
/dmifont/proc/GetCharBWidth(ch)
	var/idx = (ch - start) * 3
	if(idx <= 0 || idx >= metrics:len) idx = (defchar - start) * 3
	return metrics[idx + 2]
/dmifont/proc/GetCharCWidth(ch)
	var/idx = (ch - start) * 3
	if(idx <= 0 || idx >= metrics:len) idx = (defchar - start) * 3
	return metrics[idx + 3]
/dmifont/proc/GetCharWidth(ch)
	var/idx = (ch - start) * 3
	if(idx <= 0 || idx >= metrics:len) idx = (defchar - start) * 3
	return metrics[idx + 1] + metrics[idx + 2] + metrics[idx + 3]




/dmifont/proc/GetLineUpTo(text, xlimit, index = 1, ellipsis, flags)
	var/w = 0
	var/adjw = 0
	var/idx
	var/breakpoint = flags & 128 ? index : 0
	var/preepoint = index
	var/lastch = 32
	var/i = index
	var/ac = flags & 64
	while(i <= length(text) && adjw <= xlimit)
		var/ch = text2ascii(text, i)
		if(ch == 10) break
		if(lastch != 32)
			if(ch == 32 || ch == 9)
				if((ellipsis ? w + ellipsiswidth : adjw) <= xlimit)
					breakpoint = i
			else if(ch == 8)
				if(w + (ellipsis ? hyphenwidthfull + ellipsiswidth : ac ? hyphenwidthfull : hyphenwidth) <= xlimit)
					breakpoint = i
		i++
		lastch = ch
		idx = (ch - start) * 3
		if(idx <= 0 || idx >= metrics:len) idx = (defchar - start) * 3
		if(!w && !ac) w -= metrics[idx + 1]
		w += metrics[idx + 1] + metrics[idx + 2] + metrics[idx + 3]
		adjw = ac ? w : w - max(metrics[idx + 3], 0)
		if((ellipsis ? w + ellipsiswidth : adjw) <= xlimit) preepoint = i
	if(adjw <= xlimit) return i
	if(breakpoint) return breakpoint
	return max(preepoint, index + 1)



/dmifont/proc/GetNextPosition(lastlines, nexttext, nextfont, lastindent = 0, flags = 0)
	if(!nextfont) nextfont = src
	if(flags & 64)
		return GetWidth(copytext(lastlines, GetLastLineIndex(lastlines)), DF_INCLUDE_AC)
	var/i = 1
	var/j = findtext(lastlines, "\n")
	while(j)
		i = ++j
		j = findtext(lastlines, "\n", j)
	if(i > length(lastlines)) return 0
	. = i > 1 ? 0 : lastindent
	. += GetWidth(copytext(lastlines, i)) + GetCharCWidth(text2ascii(lastlines, length(lastlines)))
	if(length(nexttext))
		. += nextfont:GetCharAWidth(text2ascii(nexttext))


/dmifont/proc/CountLines(text)
	. = 1
	var/i = findtext(text, "\n")
	while(i)
		.++
		i = findtext(text, "\n", i + 1)

/dmifont/proc/CountLinesConstrained(text, width = -1, flags = 0, firstline = 0)
	return CountLines(GetLines(text, width, flags, firstline))

/dmifont/proc/GetWidthConstrained(text, width = -1, flags = 0, firstline = 0, maxlines = -1)
	return GetWidth(GetLines(text, width, flags, firstline, maxlines), flags)

/dmifont/proc/GoodBreaks(text, width = -1, flags = 0, firstline = 0)
	var/i = 1
	var/j
	var/line1 = 1
	do
		if(width < 0 || flags & 1) j = findtext(text, "\n", i)
		else j = GetLineUpTo(text, line1 ? width - firstline : width, i, (flags & 3) == DF_WRAP_ONELINE, flags)
		line1 = 0
		if(j && j <= length(text))
			var/ch = text2ascii(text, j)
			if(ch > 10 && ch != 32) return 0
		i = j ? GetNextIndex(text, (flags & 3) == DF_WRAP_ONELINE ? findtext(text, "\n", j) : j) : 0
	while(i)
	return 1

/dmifont/proc/WillFit(text, width = -1, flags = 0, firstline = 0, maxlines = -1)
	var/nlines = 0
	var/i = 1
	var/j
	var/line1 = 1
	do
		nlines++
		if(width < 0 || flags & 1) j = findtext(text, "\n", i)
		else j = GetLineUpTo(text, line1 ? width - firstline : width, i, (flags & 3) == DF_WRAP_ONELINE, flags)
		line1 = 0
		if(j && j <= length(text))
			var/ch = text2ascii(text, j)
			if(ch > 10 && ch != 32) return 0
		i = j ? GetNextIndex(text, (flags & 3) == DF_WRAP_ONELINE ? findtext(text, "\n", j) : j) : 0
		if(nlines >= maxlines && maxlines >= 0) return !i
	while(i)
	return 1

/dmifont/proc/GetLines(text, width = -1, flags = 0, firstline = 0, maxlines = -1, leftover)
	var/nlines = 0
	var/i = 1
	var/j
	var/line1 = 1
	var/startofline = 1
	do
		nlines++
		if(width < 0 || (flags & 3) == DF_WRAP_NONE) j = findtext(text, "\n", i)
		else j = GetLineUpTo(text, line1 ? width - firstline : width, i, flags & 2 && (flags & 1 || maxlines >= 0 && nlines >= maxlines), flags)
		flags &= 65407
		if(j)
			var/ch = text2ascii(text, j)
			if(ch == 10)
				startofline = j + 1
			else
				if(ch == 8)
					text = copytext(text, 1, j) + "-" + copytext(text, j)
					j++

				if(flags & 2 && (j <= length(text) &&\
(flags & 1 || maxlines >= 0 && nlines >= maxlines)))
					text = copytext(text, 1, j) + "..." + copytext(text, j)
					j += 3
		line1 = 0
		i = j ? GetNextIndex(text, (flags & 3) == DF_WRAP_ONELINE ? findtext(text, "\n", j) : j) : 0

		if(i && (startofline < j && (width >= 0 && (flags & 12) == DF_JUSTIFY)))
			var/widthleft = width - GetWidth(copytext(text, startofline, j), flags)
			var/cc = 0
			var/spc = 0
			var/spw = maxjustify
			var/cw = 0
			for(var/spi = startofline, spi < j - 1, spi++)
				var/ch = text2ascii(text, spi)
				if(ch <= 10) continue
				if(ch == 32) spc++
				cc++
			if(spc * spw >= widthleft) spw = widthleft
			else
				spw *= spc
				cw = widthleft - spw
			var/spacc = 0
			var/cacc = 0
			var/spleft = spw
			var/cleft = cw
			for(var/spi = startofline + 1, spi < j && cleft + spleft, spi++)
				var/ch = text2ascii(text, spi)
				if(ch <= 10) continue
				var/space = 0
				if(ch == 32)
					cacc += cw
					spacc += spw
					if(cacc >= cc)
						var/cs = round(cacc / cc)
						cacc -= cs * cc
						space += cs
						cleft -= cs
					if(spacc >= spc)
						var/sps = round(spacc / spc)
						spacc -= sps * spc
						space += sps
						spleft -= sps
				else if(cleft)
					cacc += cw
					if(cacc >= cc)
						var/cs = round(cacc / cc)
						cacc -= cs * cc
						space += cs
						cleft -= cs
				if(space > 0)
					var/spacer = ""
					while(space > 0)
						spacer += ascii2text(min(space, 7))
						space -= min(space, 7)
					text = copytext(text, 1, spi) + spacer + copytext(text, spi)
					space = length(spacer)
					spi += space
					j += space
					i += space

		if(i && (maxlines < 0 || nlines < maxlines))
			if(j) text = copytext(text, 1, j) + "\n" + copytext(text, i)
			i = j + 1
			startofline = i
		else
			if(leftover)
				leftover:Cut()
				if(i) leftover += copytext(text, i)
			if(j) text = copytext(text, 1, j)
		if(nlines >= maxlines && maxlines >= 0)
			if(leftover && !i) leftover:Cut()
			if(i) text = copytext(text, 1, i)
			break
	while(i)

	return text



/dmifont/proc/GetCutoffIndex(text, width = -1, flags = 0, firstline = 0, maxlines = -1)
	var/nlines = 0
	var/i = 1
	var/j
	var/line1 = 1
	do
		nlines++
		if(width < 0 || (flags & 3) == DF_WRAP_NONE) j = findtext(text, "\n", i)
		else j = GetLineUpTo(text, line1 ? width - firstline : width, i, flags & 2 && (flags & 1 || maxlines >= 0 && nlines >= maxlines), flags)
		flags &= 65407
		line1 = 0
		i = j ? GetNextIndex(text, (flags & 3) == DF_WRAP_ONELINE ? findtext(text, "\n", j) : j) : 0
		if(nlines >= maxlines && maxlines >= 0)
			return i
	while(i)
	return 0

/dmifont/proc/GetLine(text, index = 1)
	return copytext(text, 1, index ? findtext(text, "\n", index) : 0)
/dmifont/proc/GetLastLineIndex(text, index = 1)
	if(!index) return 0
	var/i = findtext(text, "\n", index)
	while(i)
		index = i
		if(++index > length(text)) return 0
		i = findtext(text, "\n", index)
	return index


/dmifont/proc/GetNextIndex(text, index)
	if(index < 1 || index > length(text)) return 0
	var/ch = text2ascii(text, index)
	while(index <= length(text) && (ch == 32 || ch <= 10))
		index++
		if(ch == 10) break
		ch = text2ascii(text, index)
	if(index > length(text)) index = 0
	return index


/dmifont/proc/RoundUp32(n)
	return n + 31 & 65504



/dmifont/proc/SyncWidth(firstchar, lastchar)
	firstchar = max(firstchar, start)
	lastchar = min(lastchar, end)
	var/dmifont/newfont = new type()
	var/mw = 0

	for(var/V in src.vars)
		if(vars[V] != initial(vars[V]))
			newfont:vars[V] = vars[V]


	newfont:metrics = metrics:Copy()
	var/idx = (firstchar - start) * 3
	for(var/i = firstchar, i < lastchar, i++)
		mw = max(mw, metrics[++idx] + metrics[++idx] + metrics[++idx])
	idx = (firstchar - start) * 3 + 1
	for(var/i = firstchar, i < lastchar, {i++; idx += 3})
		var/w = mw - (metrics[idx] + metrics[idx + 1] + metrics[idx + 2])

		newfont:metrics[idx] += round(w / 2, 1)
		newfont:metrics[idx + 2] += round(w / 2)
	return newfont


/dmifont/proc/DrawText(text, x, y, width = -1, flags = 0, firstline = 0, maxlines = -1, icons_x = 0, icons_y = 0, drawover, leftover)
	x = round(x)
	y = round(y)
	var/indices = new /list()
	var/nlines = 0
	var/i = 1
	var/j
	var/mw = 0
	var/line1 = 1
	if(flags & 256)
		width = RoundUp32(width < 0 ? GetWidth(text) : width)
		if((flags & 12) == DF_JUSTIFY_CENTER) x += round(width / 2)
		else if((flags & 12) == DF_JUSTIFY_RIGHT) x += width
	if(!(flags & 4096)) text = GetLines(text, width, flags & 65279, firstline, maxlines, leftover)
	do
		nlines++
		j = findtext(text, "\n", i)
		indices += i
		indices += j
		if(j) i = j + 1
		else i = 0
	while(i)
	mw = GetWidth(text, flags)
	if(flags & 12)
		if((flags & 12) == DF_JUSTIFY_CENTER) mw += x - (mw >> 1)
	else
		mw += x
	if(!icons_x) icons_x = mw + 31 >> 5
	if(!icons_y) icons_y = y + nlines * height + 31 >> 5
	var/icout = drawover ? drawover : new /iconset(icons_x, icons_y)
	var/yy = y
	line1 = 1
	for(var/k = 1, k < indices:len, yy += height)
		i = indices[k++]
		j = indices[k++]
		if(!j) j = length(text) + 1
		var/xx = x
		var/ch = text2ascii(text, i)
		var/idx = (ch - start) * 3
		if(idx < 0 || idx >= metrics:len) idx = (defchar - start) * 3
		if(!(flags & 64)) xx -= metrics[idx + 1]
		if(line1) xx += firstline
		if(flags & 12 && (flags & 12) != DF_JUSTIFY)
			var/w = GetWidth(copytext(text, i, j), flags)
			xx -= w
			if(flags & 8) xx += w >> 1

		line1 = 0
		while(i < j)
			ch = text2ascii(text, i++)
			if(ch < 10)
				if(ch <= 7) xx += ch
				continue
			idx = (ch - start) * 3
			if(idx < 0 || idx >= metrics:len) idx = (defchar - start) * 3
			xx += metrics[idx + 1]
			DrawChar(ch, xx, yy, icout, metrics[idx + 2])
			xx += metrics[idx + 2] + metrics[idx + 3]
	return icout

/dmifont/proc/DrawChar(ch, x, y, ic, B = maxwidth)
	if(!src) CRASH("["photoshot.dm"]:[653]:Assertion Failed: ["src"]")


	var/tf = defined[ch]
	if(!tf) tf = defined[defchar]
	if(sizex > 1 || sizey > 1)



		for(var/sy = 0, sy < sizey, sy++)

			for(var/sx = 0, sx < B, sx += 32)

				ic:AddIcon(new /icon(icon, "[tf][sx >> 5],[sy]"), x + sx, y + (sy << 5), , min(32, B - sx), min(32, height - (sy << 5)))
	else



		ic:AddIcon(new /icon(icon, tf), x, y, , B, height)






/dmifont/proc/GetLinesMultiFont(items, width = -1, flags = 0, firstline = 0, maxheight = -1, leftover)

	var/lastline
	var/curfont = src
	var/nextfont = src
	var/y = 0
	var/cutoff = 0
	var/maxlines = 0
	var/first
	var/prev
	if(leftover) leftover:Cut()
	for(var/item in items)
		if(cutoff)
			if(leftover) leftover += item
			continue
		if(isnull(item))
			nextfont = src
			continue
		if(istype(item, /dmifont))
			nextfont = item
			continue
		if(!istext(item)) item = "[item]"
		if(!lastline)
			curfont = nextfont
			maxlines = maxheight >= 0 ? round((maxheight - y) / curfont:height) : -1
		else
			maxlines = maxheight >= 0 ? round((maxheight - y) / curfont:height) : -1
			firstline = curfont:GetNextPosition(lastline, item, nextfont, firstline, flags)
			curfont = nextfont
			if(firstline) flags |= DF_BREAK_FIRST
		lastline = curfont:GetLines(item, width, flags, firstline, maxlines)
		if(maxheight >= 0) cutoff = curfont:GetCutoffIndex(item, width, flags, firstline, maxlines)


		if(cutoff && (prev && (width >= 0 && (firstline && (GetWidth(lastline, flags, firstline) > width || !curfont:GoodBreaks(item, width, flags, firstline, maxlines))))))
			var/dmifonttextline/oldprev = prev
			prev = prev:prev
			if(prev) prev:next = null
			else first = null
			oldprev:prev = null
			var/oldline = oldprev:line
			var/newwidth = width - GetWidth(GetLine(lastline), flags)
			oldprev:line = oldprev:font:GetLines(oldline, newwidth, flags & 65407, oldprev:x, 1)
			cutoff = oldprev:font:GetCutoffIndex(oldline, newwidth, flags & 65407, oldprev:x, 1)
			if(leftover && cutoff)
				if(oldprev:font != src) leftover += oldprev:font
				leftover += copytext(oldline, oldprev:font:GetNextIndex(oldline, cutoff))
			prev = new /dmifonttextline(oldprev:line, oldprev:font, oldprev:x, oldprev:y, oldprev:flags, prev)
			if(!first) first = prev
			while(prev:next) prev = prev:next
			if(leftover)
				if(!cutoff && curfont != src || oldprev:font != curfont)
					leftover += curfont
				leftover += item
			del(oldprev)
			cutoff = 1
			continue
		prev = new /dmifonttextline(lastline, curfont, firstline, y, flags, prev)
		if(!curfont:GoodBreaks(item, width, flags, firstline, maxlines)) prev:badbreak = 1
		if(!first) first = prev
		while(prev:next) prev = prev:next
		flags &= 65407
		if(cutoff)
			if(leftover)
				if(curfont != src) leftover += curfont
				leftover += copytext(item, cutoff)
			continue
		y += (curfont:CountLines(lastline) - 1) * curfont:height
		if(maxheight >= 0 && y >= maxheight)
			cutoff = 1
			if(curfont != src && leftover) leftover += curfont



	if(leftover)
		while(length(leftover) && istype(leftover[1], /dmifont) &&\
			(length(leftover) == 1 || istype(leftover[2], /dmifont)))
			leftover:Cut(1, 2)
	return first


/dmifont/proc/WillFitMultiFont(items, width = -1, flags = 0, firstline = 0, maxheight = -1)
	var/lastline
	var/curfont = src
	var/nextfont = src
	var/y = 0

	var/maxlines = 0
	for(var/item in items)
		if(isnull(item))
			nextfont = src
			continue
		if(istype(item, /dmifont))
			nextfont = item
			continue
		if(!istext(item)) item = "[item]"
		if(!lastline)
			curfont = nextfont
			maxlines = maxheight >= 0 ? round((maxheight - y) / curfont:height) : -1
		else
			maxlines = maxheight >= 0 ? round((maxheight - y) / curfont:height) : -1
			firstline = curfont:GetNextPosition(lastline, item, nextfont, firstline, flags)
			curfont = nextfont
			if(firstline) flags |= DF_BREAK_FIRST
		if(!curfont:WillFit(item, width, flags, firstline, maxlines)) return 0
		lastline = curfont:GetLines(item, width, flags, firstline, maxlines)
		flags &= 65407
	return 1



/dmifont/proc/DrawTextMultiFont(items, x, y, width = -1, flags = 0, firstline = 0, maxheight = -1, icons_x = 0, icons_y = 0, drawover, leftover)
	var/text
	if(istype(items, /list))
		text = GetLinesMultiFont(items, width, flags, firstline, maxheight, leftover)
	else if(istype(items, /dmifonttextline))
		text = items
	else
		world.log << "DmiFonts error in DrawTextMultiFont(): items is not a list or /dmifonttextline."
		world.log << items
		return
	var/mw = 0
	var/mh = y
	var/T
	if(!drawover || (!icons_x || !icons_y))
		for(T = text, T, T = T:next)
			mw = max(mw, T:font:GetWidth(T:line, flags, T:x))
			mh = max(mh, T:y + T:nlines * T:font:height)
		if((flags & 12) == DF_JUSTIFY_CENTER) mw = mw + x >> 1
		else if((flags & 12) == DF_JUSTIFY_RIGHT) mw = max(mw, x)
		else mw += x
		if(!icons_x) icons_x = (mw + 31 & 65504) >> 5
		if(!icons_y) icons_y = (mh + 31 & 65504) >> 5
	var/icout = drawover ? drawover : new /iconset(icons_x, icons_y)
	for(T = text, T, T = T:next)
		if(flags & 12)
			var/xx = T:x + T:width - T:firstwidth
			if((flags & 12) == DF_JUSTIFY_CENTER)
				xx += T:firstwidth - T:width >> 1
			T:font:DrawText(T:line, x, y + T:y, width, flags, xx, drawover = icout)
		else
			T:font:DrawText(T:line, x, y + T:y, width, flags, T:x, drawover = icout)






	if(text != items) del(text)
	return icout


/dmifont/proc/KeyToBreakable(text)
	. = text
	var/last = 0
	var/chclass = 1
	for(var/i = 1, i <= length(.), i++)
		var/ch = text2ascii(., i)
		if(ch <= 32)
			last = 0
			continue
		if(ch >= 48 && ch < 58) chclass = 3
		else if(ch >= 65 && ch <= 90) chclass = 1
		else if(ch >= 97 && ch <= 122) chclass = 2
		else chclass = 4
		if(last == chclass) continue
		if(last == 4)
			. = copytext(., 1, i) + "\t" + copytext(., i)
			i++
		else if(last == 3 || last && chclass & 1)
			. = copytext(., 1, i) + ascii2text(8) + copytext(., i)
			i++
		last = chclass

/dmifonttextline
	var/font
	var/line
	var/x
	var/y
	var/flags
	var/nlines
	var/width
	var/firstwidth
	var/badbreak
	var/dmifonttextline/prev
	var/dmifonttextline/next



/dmifonttextline/New(ln, f, _x, _y, flags, last)
	line = ln
	font = f
	x = _x
	y = _y
	src.flags = flags
	prev = last
	if(prev) prev:next = src
	nlines = font:CountLines(line)
	width = font:GetWidth(font:GetLine(line), flags)
	firstwidth = x + width

	if(nlines > 1)
		var/idx = font:GetLastLineIndex(line)
		if(idx)
			next = new /dmifonttextline(copytext(line, idx--), font, 0, _y + --nlines * font:height, flags, src)
			line = copytext(line, 1, idx)
	if(x)

		var/by = y + font:ascent
		for(last = prev, last, last = last:prev)
			if(last:nlines > 1) break
			last:firstwidth = firstwidth

			by = max(by, last:y + last:font:ascent)
			if(!last:x) break

		y = by - font:ascent
		for(last = src.prev, last, last = last:prev)
			if(last:nlines > 1) break

			last:y = by - last:font:ascent
			if(!last:x) break

/dmifonttextline/Del()
	if(prev)
		prev:next = null
		del(prev)
	if(next)
		next:prev = null
		del(next)
	..()

/dmifonttextline/proc/AnyBadBreaks()
	var/T
	for(T = src, T, T = T:next)
		if(T:badbreak)
			return 1

/dmifonttextline/proc/TotalWidth()
	. = 0
	var/T
	for(T = src, T, T = T:next)
		. = max(., T:font:GetWidth(T:line, flags, T:x))

/dmifonttextline/proc/TotalHeight()
	var/T = src
	while(T:next) T = T:next
	. = T:y + T:nlines * T:font:height

/iconset
	var/icons
	var/w
	var/h

/iconset/New(x, y, srcicon = 'black.dmi', srcstate)
	if(istype(x, /iconset))
		var/s = x
		w = s:w
		h = s:h
		icons = new /list()
		for(var/ic in s:icons)
			if(ic) icons += new /icon(ic)
			else icons += null
	else
		w = x
		h = y
		icons = new /list()
		for(var/i = w * h, i > 0, i--) icons += new /icon(srcicon, srcstate)

/iconset/proc/GetIcon(ix, iy)
	if(ix < 0 || (ix >= w || (iy < 0 || iy >= h))) return null
	return icons[ix + iy * w + 1]

/iconset/proc/OverlayIcon(c, x, y, iw = 32, ih = 32)
	if(!c) return
	var/ix
	var/iy
	var/ic
	var/idx
	var/oy = y & 31
	for(iy = max(0, y) >> 5, oy > -ih && iy < h, iy++)
		var/fx = max(0, x) >> 5
		idx = iy * w + fx + 1
		var/ox = x - (fx << 5)
		for(ix = fx, ox > -iw && ix < w, ix++)
			ic = icons[idx++]
			var/c2 = c
			if(ox || oy)
				c2 = new /icon(c)
				if(ox) c2:Shift(EAST, ox)
				if(oy) c2:Shift(SOUTH, oy)
			ic:Blend(c2, 3)
			ox -= 32
		oy -= 32

/iconset/proc/AddIcon(c, x, y, operation = 0, iw = 32, ih = 32)
	if(!c) return
	var/ix
	var/iy
	var/ic
	var/idx
	var/oy = y & 31
	for(iy = max(0, y) >> 5, oy > -ih && iy < h, iy++)
		var/fx = max(0, x) >> 5
		idx = iy * w + fx + 1
		var/ox = x - (fx << 5)
		for(ix = fx, ox > -iw && ix < w, ix++)
			ic = icons[idx++]
			var/c2 = c
			if(ox || oy)
				c2 = new /icon(c)
				if(ox) c2:Shift(EAST, ox)
				if(oy) c2:Shift(SOUTH, oy)
			c2:SwapColor(null, "#000000")
			ic:Blend(c2, operation)
			ox -= 32
		oy -= 32

/iconset/proc/MultiplyIcon(c, x, y, iw = 32, ih = 32)
	if(!c) return
	var/ix
	var/iy
	var/ic
	var/idx
	var/oy = y & 31
	for(iy = max(0, y) >> 5, oy > -ih && iy < h, iy++)
		var/fx = max(0, x) >> 5
		idx = iy * w + fx + 1
		var/ox = x - (fx << 5)
		for(ix = fx, ox > -iw && ix < w, ix++)
			ic = icons[idx++]
			var/c2 = c
			if(ox || oy)
				c2 = new /icon(c)
				if(ox) c2:Shift(EAST, ox)
				if(oy) c2:Shift(SOUTH, oy)
			c2:SwapColor(null, "#ffffff")
			ic:Blend(c2, 2)
			ox -= 32
		oy -= 32


/iconset/proc/OverlaySet(iconset/s, x, y)
	for(var/j = 0, j < s:h && y + (j << 5) < (h << 5), j++)
		for(var/i = 0, i < s:w && x + (i << 5) < (w << 5), i++)
			OverlayIcon(s:icons[i + j * s:w + 1], x + (i << 5), y + (j << 5))


/iconset/proc/AddSet(iconset/s, x, y, operation = 0)
	for(var/j = 0, j < s:h && y + (j << 5) < (h << 5), j++)
		for(var/i = 0, i < s:w && x + (i << 5) < (w << 5), i++)
			AddIcon(s:icons[i + j * s:w + 1], x + (i << 5), y + (j << 5), operation)


/iconset/proc/MultiplySet(iconset/s, x, y)
	for(var/j = 0, j < s:h && y + (j << 5) < (h << 5), j++)
		for(var/i = 0, i < s:w && x + (i << 5) < (w << 5), i++)
			MultiplyIcon(s:icons[i + j * s:w + 1], x + (i << 5), y + (j << 5))



/iconset/proc/Dilate()
	var/lastright
	var/ic
	var/ic2
	var/ic3
	var/lastbottom
	var/idx = 1
	for(var/y = 0, y < h, y++)
		if(!lastbottom && h > 1) lastbottom = new /list(w)
		for(var/x = 0, x < w, {x++; idx++})
			ic = new /icon(icons[idx])
			ic2 = new /icon(icons[idx])
			ic2:Shift(EAST, 1)
			if(x > 0)
				if(lastright) ic2:Blend(lastright, 3)
			else if(1) ic2:SwapColor(null, "#000000")
			if(ic2) ic:Blend(ic2, 0)
			ic2 = new /icon(icons[idx])
			ic2:Shift(WEST, 1)
			if(x < w - 1)
				lastright = new /icon(icons[idx])
				lastright:Shift(WEST, 31)
				ic3 = new /icon(icons[idx + 1])
				ic3:Shift(EAST, 31)
				if(ic3) ic2:Blend(ic3, 3)
			else ic2:SwapColor(null, "#000000")
			if(ic2) ic:Blend(ic2, 0)
			ic2 = new /icon(icons[idx])
			ic2:Shift(SOUTH, 1)
			if(y > 0)
				if(lastbottom[x + 1]) ic2:Blend(lastbottom[x + 1], 3)
			else if(1) ic2:SwapColor(null, "#000000")
			if(ic2) ic:Blend(ic2, 0)
			ic2 = new /icon(icons[idx])
			ic2:Shift(NORTH, 1)
			if(y < h - 1)
				ic3 = new /icon(icons[idx])
				ic3:Shift(NORTH, 31)
				lastbottom[x + 1] = ic3
				ic3 = new /icon(icons[idx + w])
				ic3:Shift(SOUTH, 31)
				if(ic3) ic2:Blend(ic3, 3)
			else ic2:SwapColor(null, "#000000")
			if(ic2) ic:Blend(ic2, 0)
			icons[idx] = ic



/iconset/proc/Blend(I, operation = 0)
	for(var/n = 1 to icons:len)
		var/ic = icons[n]
		if(ic) ic:Blend(I, operation)



/iconset/proc/Invert()
	var/ic
	var/ic2
	for(var/n = 1 to icons:len)
		ic = icons[n]
		if(ic)
			ic2 = new /icon(ic)
			ic2:Blend("#ffffff", 3)
			ic2:Blend(ic, 1)
			icons[n] = ic2


/iconset/proc/Transparent(r = 0, g = r, b = r)
	for(var/n = 1 to icons:len)
		var/ic = icons[n]
		if(ic) ic:SwapColor(rgb(r, g, b), null)


/iconset/proc/Opaque(r = 0, g = r, b = r)
	for(var/n = 1 to icons:len)
		var/ic = icons[n]
		if(ic) ic:SwapColor(null, rgb(r, g, b))

/dmifont/Arial7pt
	name = "Arial 7pt"
	height = 12
	ascent = 9
	descent = 3
	avgwidth = 4
	maxwidth = 24
	overhang = 0
	inleading = 3
	exleading = 0
	defchar = 31
	start = 31
	end = 255
	metrics = list(1, 5, 1, 0,\
		0, 3, 1,\
		1, 1, 0,\
		3, 0, 0,\
		4, 1, 0,\
		5, 0, 1,\
		6, 1, 0,\
		6, 0, 0,\
		1, 1, 0,\
		3, 0, 0,\
		3, 0, 0,\
		3, 1, 0,\
		5, 0, 1,\
		1, 1, 0,\
		2, 1, 1,\
		1, 1, 0,\
		3, 0, 0,\
		4, 1, 1,\
		2, 2, 0,\
		4, 1, 0,\
		4, 1, 0,\
		5, 0, 0,\
		4, 1, 0,\
		4, 1, 0,\
		4, 1, 0,\
		4, 1, 0,\
		4, 1, 1,\
		1, 1, 1,\
		1, 1, 1,\
		3, 1, 0,\
		4, 1, 1,\
		3, 1, 0,\
		5, 0, 1,\
		8, 0, 0,\
		7, -1, 1,\
		4, 1, 1,\
		5, 1, 1,\
		5, 1, 1,\
		5, 0, 1,\
		4, 1, 1,\
		5, 1, 1,\
		5, 1, 1,\
		1, 1, 0,\
		4, 1, 1,\
		5, 0, 1,\
		4, 0, 0,\
		7, 0, 1,\
		5, 1, 1,\
		5, 1, 1,\
		4, 1, 1,\
		5, 1, 1,\
		6, 0, 1,\
		4, 1, 0,\
		5, 0, 1,\
		5, 1, 0,\
		7, -1, 0,\
		9, 0, 0,\
		5, 0, 1,\
		5, 1, 0,\
		6, 0, 1,\
		2, 0, 0,\
		3, 0, 0,\
		2, 1, 0,\
		3, 0, 0,\
		5, 0, 0,\
		2, 1, 0,\
		4, 1, 0,\
		4, 1, 0,\
		4, 1, 0,\
		4, 1, 0,\
		4, 1, 0,\
		3, 1, 0,\
		4, 1, 0,\
		4, 1, 0,\
		1, 1, -1,\
		2, 1, 0,\
		4, 1, 0,\
		1, 1, 0,\
		7, 1, 0,\
		4, 1, 0,\
		4, 1, 0,\
		4, 1, 0,\
		4, 1, 0,\
		3, 0, 0,\
		4, 1, -1,\
		3, 1, 0,\
		4, 1, 0,\
		5, 1, 0,\
		5, 1, 0,\
		4, 1, 0,\
		5, 1, 0,\
		3, 1, 0,\
		3, 0, 1,\
		1, 1, 0,\
		3, 0, 0,\
		4, 1, 1,\
		5, 1, -1,\
		6, 0, 1,\
		5, 1, 0,\
		1, 1, 0,\
		5, 0, 0,\
		3, 0, 1,\
		7, 1, 0,\
		5, 0, 0,\
		5, 0, 0,\
		5, -2, 0,\
		10, 0, 0,\
		5, 1, 0,\
		3, 0, 1,\
		8, 0, 1,\
		5, 1, 1,\
		5, 1, 1,\
		5, 1, 1,\
		5, 1, 0,\
		1, 1, 0,\
		1, 1, 0,\
		3, 0, 0,\
		3, 0, 1,\
		2, 0, 0,\
		5, 0, 0,\
		9, 0, 0,\
		4, 0, 1,\
		8, 0, -1,\
		5, 1, 0,\
		3, 0, 0,\
		8, 0, 1,\
		5, 1, 1,\
		5, 1, 1,\
		5, 0, 0,\
		0, 3, 1,\
		1, 1, 0,\
		4, 1, 0,\
		5, 0, 1,\
		4, 0, 0,\
		5, 0, 1,\
		1, 1, 0,\
		4, 1, 0,\
		3, 0, 0,\
		7, 0, 0,\
		3, 0, 0,\
		5, 0, 0,\
		4, 1, 0,\
		2, 1, 0,\
		7, 0, 0,\
		5, 0, 1,\
		3, 0, 0,\
		5, 0, 0,\
		3, 0, 0,\
		3, 0, 1,\
		2, 0, 0,\
		4, 1, 0,\
		5, 0, 1,\
		1, 1, 0,\
		2, 1, 1,\
		2, 0, 0,\
		3, 0, 0,\
		5, 0, 1,\
		6, 1, 1,\
		7, 0, 0,\
		7, 1, 1,\
		4, 1, 0,\
		7, -1, 0,\
		7, -1, 0,\
		7, -1, 0,\
		7, -1, 0,\
		7, -1, 0,\
		7, -1, -1,\
		10, 0, 1,\
		5, 0, 1,\
		5, 0, 1,\
		5, 0, 1,\
		5, 0, 1,\
		5, 0, 1,\
		2, 0, 0,\
		2, 1, -2,\
		5, 0, 0,\
		3, 0, 0,\
		6, 0, 1,\
		5, 0, 1,\
		5, 1, 1,\
		5, 1, 1,\
		5, 1, 1,\
		5, 1, 1,\
		5, 1, 0,\
		5, 0, 1,\
		5, 1, 1,\
		5, 0, 1,\
		5, 0, 1,\
		5, 0, 1,\
		5, 0, 1,\
		5, 0, 1,\
		5, 0, 1,\
		4, 1, 0,\
		4, 1, 0,\
		4, 1, 0,\
		5, 0, 0,\
		4, 1, 0,\
		4, 1, 0,\
		4, 1, 0,\
		7, 1, 0,\
		4, 1, 0,\
		4, 1, 0,\
		4, 1, 0,\
		5, 0, 0,\
		4, 1, 0,\
		2, 1, -1,\
		2, 2, -1,\
		5, -1, -1,\
		3, 1, 0,\
		4, 1, 0,\
		4, 1, 0,\
		4, 1, 0,\
		4, 1, 0,\
		5, 0, 0,\
		4, 1, 0,\
		4, 1, 0,\
		5, 0, 0,\
		4, 1, 0,\
		4, 1, 0,\
		4, 1, -1,\
		5, 1, 0,\
		4, 1, 0,\
		5, 0, 0,\
		4, 1, 0,\
		5, 0, 225)



	defined = list(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, "", " ", "!", "\"", "#", "$", "%", "&", "'", "(", ")", "*", "+", ",", "-", ".", "/", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", ";", "<", "=", ">", "?", "@", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "\[", "\\", "]", "^", "_", "`", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "{", "|", "}", "~", null, "€", null, "‚", "ƒ", "„", "…", "†", "‡", "ˆ", "‰", "Š", "‹", "Œ", null, null, null, null, "‘", "’", "“", "”", "•", "–", "—", "˜", "™", "š", "›", "œ", null, null, "Ÿ", " ", "¡", "¢", "£", "¤", "¥", "¦", "§", "¨", "©", "ª", "«", "¬", "­", "®", "¯", "°", "±", "²", "³", "´", "µ", "¶", "·", "¸", "¹", "º", "»", "¼", "½", "¾", "¿", "À", "Á", "Â", "Ã", "Ä", "Å", "Æ", "Ç", "È", "É", "Ê", "Ë", "Ì", "Í", "Î", "Ï", "Ð", "Ñ", "Ò", "Ó", "Ô", "Õ", "Ö", "×", "Ø", "Ù", "Ú", "Û", "Ü", "Ý", "Þ", "ß", "à", "á", "â", "ã", "ä", "å", "æ", "ç", "è", "é", "ê", "ë", "ì", "í", "î", "ï", "ð", "ñ", "ò", "ó", "ô", "õ", "ö", "÷", "ø", "ù", "ú", "û", "ü", "ý", "þ", "ÿ")
	icon = 'Arial7pt.dmi'



























var/dmifont/namefont = new /dmifont/Arial7pt


/mob/proc/CreateName(r = 255, g = r, b = r)
	overlays = list()
	var/lines = round(32 / namefont.height)
	var/list/txt = namefont.GetLines(key, width = 96,\
		maxlines = lines, flags = DF_WRAP_ELLIPSIS)
	var/size = namefont.RoundUp32(namefont.GetWidth(txt))
	var/iconset/s = namefont.DrawText(txt, size / 2, 0,\
		width = size, maxlines = lines,\
		flags = 2 | 8,\
		icons_x = size / 32, icons_y = 1)
	s.Transparent()
	if(r < 255 || g < 255 || b < 255)
		s.Blend(rgb(r, g, b), 2)
	var/obj/O = new
	O.pixel_y = -32
	for(var/xx = 0, xx < s.w, xx++)
		var/ic = s.GetIcon(xx, 0)
		if(ic)
			O.icon = ic
			O.pixel_x = (xx + (1 - s.w) / 2) * 32
			overlays += O
	del(O)
/mob/proc/CreateID(id, r, g, b)
	overlays = null
	overlays = list()
	var/lines = round(32 / namefont.height)
	var/list/txt = namefont.GetLines("[id]", width = 96, maxlines = lines,\
		flags = DF_WRAP_ELLIPSIS)
	var/size = namefont.RoundUp32(namefont.GetWidth(txt))
	var/iconset/s = namefont.DrawText(txt, size / 2, 0,\
		width = size, maxlines = lines,\
		flags = 2 | 8,\
		icons_x = size / 32, icons_y = 1)
	s.Transparent()
	if(r < 255 || g < 255 || b < 255)
		s.Blend(rgb(r, g, b), 2)
	var/obj/O = new
	O.pixel_y = -32
	for(var/xx = 0, xx < s.w, xx++)
		var/ic = s.GetIcon(xx, 0)
		if(ic)
			O.icon = ic
			O.pixel_x = (xx + (1 - s.w) / 2) * 32
			O.pixel_x += 10
			overlays += O
	del(O)
