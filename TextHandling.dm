
































































































































/proc/dd_file2list(file_path, separator = "\n")
	var/file
	if(isfile(file_path))
		file = file_path
	else
		file = file(file_path)
	return dd_text2list(file2text(file), separator)







/proc/dd_replacetext(text, search_string, replacement_string)
	var/textList = dd_text2list(text, search_string)
	return dd_list2text(textList, replacement_string)


/proc/dd_replaceText(text, search_string, replacement_string)
	var/textList = dd_text2List(text, search_string)
	return dd_list2text(textList, replacement_string)





/proc/dd_hasprefix(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	return findtext(text, prefix, start, end)

/proc/dd_hasPrefix(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	return findText(text, prefix, start, end)





/proc/dd_hassuffix(text, suffix)
	var/start = length(text) - length(suffix)
	if(start) return findtext(text, suffix, start)

/proc/dd_hasSuffix(text, suffix)
	var/start = length(text) - length(suffix)
	if(start) return findText(text, suffix, start)




/proc/dd_text2list(text, separator)
	var/textlength = length(text)
	var/separatorlength = length(separator)
	var/textList = new /list()
	var/searchPosition = 1
	var/findPosition = 1
	var/buggyText
	while(1)
		findPosition = findtext(text, separator, searchPosition, 0)
		buggyText = copytext(text, searchPosition, findPosition)
		textList += "[buggyText]"

		searchPosition = findPosition + separatorlength
		if(findPosition == 0)
			return textList
		else
			if(searchPosition > textlength)
				textList += ""
				return textList

/proc/dd_text2List(text, separator)
	var/textlength = length(text)
	var/separatorlength = length(separator)
	var/textList = new /list()
	var/searchPosition = 1
	var/findPosition = 1
	var/buggyText
	while(1)
		findPosition = findText(text, separator, searchPosition, 0)
		buggyText = copytext(text, searchPosition, findPosition)
		textList += "[buggyText]"

		searchPosition = findPosition + separatorlength
		if(findPosition == 0)
			return textList
		else
			if(searchPosition > textlength)
				textList += ""
				return textList

/proc/dd_list2text(the_list, separator)
	var/total = the_list:len
	if(total == 0)
		return

	var/newText = "[the_list[1]]"
	var/count
	for(count = 2, count <= total, count++)
		if(separator) newText += separator
		newText += "[the_list[count]]"
	return newText

/proc/dd_centertext(message, length)
	var/new_message = message
	var/size = length(message)
	if(size == length)
		return new_message
	if(size > length)
		return copytext(new_message, 1, length + 1)


	var/delta = length - size
	if(delta == 1)

		return new_message + " "


	if(delta % 2)
		new_message = " " + new_message
		delta--


	delta = delta / 2
	var/spaces = ""
	for(var/count = 1, count <= delta, count++)
		spaces += " "
	return spaces + new_message + spaces


/proc/dd_limittext(message, length)
	var/size = length(message)
	if(size <= length)
		return message
	else
		return copytext(message, 1, length + 1)


















/obj/test/texthandling/verb/dd_list2text_test()
	var/list/mylist = new()
	mylist += "one"

	var/obj/basic = new /obj()
	basic:name = "two"
	mylist += basic

	var/text = dd_list2text(mylist, ",")
	if(text != "one,The two")
		die("dd_list2text() returned incorrect text: [text]")

	mylist -= basic
	del(basic)
	del(mylist)
