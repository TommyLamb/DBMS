-- This simple query is used to give the list of equipment 
-- on which there is no staff member trained, violating the 
-- business constraint. Its simplicity is dependant on its
-- complete use of views. It is also dependant on the return
-- set of ViewEquipmentTraining: that it doesn't include
-- all equipment, just those requiring training.
-- DISTINCT is required to avoid duplicating repetiton of 
-- equipment in ViewEquipmentTraining; those requiring more
-- than one course.
SELECT DISTINCT E.detail, E.type 
FROM ViewEquipmentTraining AS E
WHERE NOT EXISTS (
	SELECT detail
	FROM ViewStaffMembers AS S, ViewMemberEquipment AS T
	WHERE S.mID = T.mID AND E.detail = T.detail
);