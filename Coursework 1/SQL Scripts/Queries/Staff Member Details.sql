SELECT M.mID, fNames, sName, position
FROM ViewStaffMembers AS M
INNER JOIN Staff
ON M.mID=Staff.mID;