tags = ["class", "make", "model", "description"]
with open("equipmentdetail.xml", "a") as f:
	s = input("eid")
	f.write('<equipmentdetail eid="'+s+'">\n')
	for x in tags:
		s = input(x+">>")
		if(s == "exit"):
			break
		f.write("\t<"+x+">"+s+"</"+x+">\n")
	f.write("</equipmentdetail>\n")
	
