equipmentt = ["Treadmill", "Treadmill", "Treadmill", "Rowing Machine", "Rowing Machine", "Free Weights", "Elliptical", "Badminton Court", "Tennis Court", "Football Pitch", "Football Pitch", "Spinning Bike", "Spinning Bike"]
equipmentd = ["Python 3", "Poly/ML", "Prolog", "Oxford", "Cambridge", "From 5KG to 50KG", "Eclipse", "Full Size Indoor Badminton", "Full Size Outdoor Tennis", "Outdoor Competition Size Grass", "Outdoor Mid Size Grass", "Boardman", "Specialized"]
cname = ["GB Spotters", "Classical Education", "Football Referee"]
with open("Equipment", "w") as E:
    for i in range(14):
        E.write(equipmentd[i]+"\t"+equipmentt[i]+"\n")

#Some manual alterations to accreditation were made
with open("Training", "w") as T:
    for x in cname:
        for i in range(1,5):
            T.write(x+"\t"+str(i)+"\t")
            if i>=3:
                T.write("1")
            else:
                T.write("0")
            T.write("\n")
