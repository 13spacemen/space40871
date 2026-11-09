






















































/proc/dd_run_tests()
	var/test_classes = typesof(/obj/test)

	for(var/class in test_classes)
		var/obj/test/tester = new class()

		for(var/test in tester:verbs)
			call(tester, test)()

			if(!tester:success)
				break

		if(!tester:success)
			world << "Test failed."
			return

	world << "All tests passed."



/obj/test
	var/success = 1
/obj/test/proc/die(message)
	success = 0
	CRASH(message)
