SELECT R.rNumber, B.date, B.sTime, B.eTime
FROM Member AS M, Booking AS B, Room AS R
WHERE M.mID=B.mID
AND R.rNumber=B.rNumber
AND M.sName='Vakarian'
AND M.fNames = 'Garrus';