#\N ==NULL
with open("StaffMembers", "w") as f:
    with open("Staff", "w") as s:
        fnames = ["Thomas", "Edward", "Henry", "Gordon", "James", "Percy", "Toby", "Diesel", "Lady"] #Trains from Thomas & Friends
        sname = ["Tweed", "Dee", "Clyde", "Spey", "Forth", "Teviot", "Balckadder", "Tay", "Leith"] #Scottish Rivers
        dob = ["20160713", "20100511", "20070627", "19970502", "19901128", "19790504", "19760405", "19740304", "19700619"] #Dates of new PMs
        email = ["thomas@may.com", "Edward@cameron.com", "Henry@brown.scot", "gordon@blair.co.uk", "\\N", "\\N", "\\N", "Diesel@wilson.org", "Lady@Heath.com"] #fname@PMlastname
        tNumber = ["07700900163", "07700900151", "07700900037", "07700900764", "07700900798", "07700900672", "07700900691", "07700900901", "07700900736"]
        position = ["Manager", "Manager", "DBA", "Instructor", "Facilites", "CustomerServices", "Finance", "HR", "IT" ]
        pword = ["$2a$07$bstAcDLIsAZHSratyQUm7O.C47tZVtDFdJUTDtmExOZrKa/EJ2XJW", "$2a$07$DDJaLGINWuETtQRoE2aQV.I8zOr4cFb6aJhzu/aicWeyE7hREdGeC", "$2a$07$pKi2EmX5CpzdNqIuGSmfvuEVbBLEVm3pNhnWUFvxGyd4xu3lyhv3S", "$2a$07$j3UP5kU9voCS2FvBJKbzH.xabTsOfwYmTDQPujWiPijkOFt5E/YbS", "$2a$07$2vebY1ABt1jh0Xr7iSPJgeV0STwhIkfjee.UD1CrH/EI20e16/FZu", "$2a$07$GMZwnggcFrerrE9eBlENUOuLm/ClxYj6QNWwayUc66ISNQ2igB7bm", "$2a$07$MbPDbkz2DaXoNyMh4yg9U.tiV9aeTqHHJalJ12gNdiEuED9EUQZ1q", "$2a$07$irUO1Wyv0BmRJjv1tP0QSudGtgXH0cfl8wJXZZXJ0pKHa8lDJj4V.", "$2a$07$njnnKzxh6PqaX8zlD6r1IewlTyM3y95RTDbXOPxfauzC5JK96u0nK"]
        supMID = ["\\N", "\\N", "1", "2", "1", "2", "1", "1", "3"]
        paygrade = ["A3", "A3", "B3", "C2", "D2", "D2", "B3", "C2", "C2"]
        mLevel = ["3","3","3","2","2","2","3","2","2"]
        #mStarted dealt with in SQL
        #mExpire dealt with in SQL
        #autoRenew as above
        #sStarted as above
		#mID as above
        for i in range(9):
            f.write(fnames[i]+"\t"+sname[i]+"\t"+dob[i]+"\t"+email[i]+"\t"+tNumber[i]+"\t"+mLevel[i]+"\n")
            s.write(position[i]+"\t"+pword[i]+"\t"+supMID[i]+"\t"+paygrade[i]+"\n")