tags = ["stime", "etime", "room", "uses", "isroombooking"]
uses = ["eid", "amount"]
with open("bookingdetail.xml", "a") as f:
	s = input("date>>");
	f.write('<date iso="'+s+'">\n')
	while(True):
		s = input("bid>>")
		if(s == "exit"):
			break
		f.write('\t<bookingdetail bid="'+s+'">\n')
		for x in tags:
			if(x == "uses"):
				while(True):
					if(input("Uses?") == "n"):
						break
					f.write("\t\t<uses>\n")
					for y in uses:
						s = input(y+">>")
						f.write("\t\t\t<"+y+">"+s+"</"+y+">\n")
					f.write("\t\t</uses>\n")
			else:		
				s = input(x+">>")
				if(s == "exit"):
					break
				f.write("\t\t<"+x+">"+s+"</"+x+">\n")
		f.write("\t</bookingdetail>\n")
	f.write("</date>\n")
