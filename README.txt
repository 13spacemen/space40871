SS13 40.87.1 rebuilt source (October 2004, BYOND 341). Compiles with 0 errors to a .dmb that is BYTE-IDENTICAL to the
original cellautomata.dmb (md5 c22c4e53a081a3dc864bbe1c7920c4f2, 744867 bytes): cmp finds no difference, and 10 of 10
compiles of a clean copy gave that md5.

Compiler: BYOND 341 (C:\68o\byond341\x), header "world bin v341 / min compatibility v341" as in the original.
  sh C:/sps40871/work/cmp.sh <folder>        (compiles <folder>/cellautomata.dme, prints md5 + audit against the original)
From scratch: sh C:/sps40871/work/rebuild.sh <new folder>  (40.84.9 source from C:\misc\dev\space40849 + work\port40871.patch
  + a_html\photoshot.dm written by work\gen_photo.py + map written from the 40.87.1 .dmb + icons from the 40.87.1 .rsc).

With the regular compiler: python compile_bitperfect.py cellautomata.dme --byond <BYOND 341 bin folder>
  (or put the script next to dreammaker.exe). It runs Dream Maker 341 as a normal program, then writes dc ff into the two
  bytes at offset 744628 and checks the md5 of the whole file. Tested 5 of 5 bit-perfect.

Why: two bytes of the world record (+37, the hub_password id) are uninitialised memory in BYOND 341. The 2004 original
holds dc ff there; a plain compile today writes 00 00 or other leftovers (seen: 0000, 0101), never dc ff. Every other
byte comes from the compiler. work/cmp.sh instead runs Dream Maker under a hook that writes the same value during the compile.

How it was made: the bit-perfect 40.84.9 source with every 40.84.9 -> 40.87.1 change put in (3-way merge per proc): the
camera/photograph (photoshot.dm, with a pasted DmiFonts library and an iconset type), Test.dm back, the grab system,
earmuffs, emergency and L3 closets under /obj/closet, the dispenser as a machine, clothing burn merged into one type, the
new changelog text and icons. Many declarations are typed (var/mob/x, var/obj/x) where 40.84.9 had them untyped: in 341
an untyped `x:name` waits for the DmiFonts types, so the original text must have had typed vars there. Where 40.93
(C:\misc\dev\space40930) has the same code its spelling was used.

Not the author's text: comments are gone (the .dmb does not store them); blank lines stand in for lines whose content
is unknown; some one-line settings, braced lines and `else if(1)` (photoshot.dm 1054/1070) are choices that give the
same bytes. Notes: C:\sps40871\HANDOFF.md.
