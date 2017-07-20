tags = ["maxcapacity", "has"]
has = ["eid", "amount", "available", "purchasedate"]
with open("roomdetail.xml", "a") as f:
	while(True):
		s = input("rnumber>>")
		if(s == "exit"):
			break
		f.write('<roomdetail rnumber="'+s+'">\n')
		for x in tags:
			if(x == "has"):
				while(True):
					if(input("Has?") == "n"):
						break
					f.write("\t<has>\n")
					for y in has:
						s = input(y+">>")
						f.write("\t\t<"+y+">"+s+"</"+y+">\n")
					f.write("\t</has>\n")
			else:		
				s = input(x+">>")
				if(s == "exit"):
					break
				f.write("\t<"+x+">"+s+"</"+x+">\n")
		f.write("</roomdetail>\n")
	
