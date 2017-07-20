DROP VIEW ViewStaffMembers;
DROP VIEW ViewNonStaffMembers;
DROP VIEW ViewMemberTraining;
DROP VIEW ViewEquipmentTraining;
DROP VIEW ViewFreeEquipment;
DROP VIEW ViewMemberEquipment;
DROP VIEW ViewRoomEquipment;

-- Multi-table Views are only updatable if one of the underlying tables is referenced, not 2 or more.
-- The same holds true for inserting.
-- Note that delete is not supported on multi-table views.

-- The default mode for CHECK OPTION is CASCADE.

-- The views for Staff and NonStaff members are used to enforce security,
-- allowing seperate department privileges for each sub set of members.

-- Updatable and insertable
-- Also deletable; Used in permissions.
Create VIEW ViewStaffMembers AS
	Select Member.*
	FROM Member
	WHERE Member.mID IN (
		Select mID 
		FROM Staff
	)
WITH CHECK OPTION;
	
-- Updatable and Insertable and Deletable
-- Used in permissions.
Create VIEW ViewNonStaffMembers AS
	Select Member.*
	FROM Member
	WHERE mID NOT IN (
		Select mID 
		from Staff
	)
WITH CHECK OPTION;
	
-- Updatable, and Insertable. Not deletable
-- Used in permissions.
create VIEW ViewMemberTraining AS
	Select mID, Training.*
	FROM HasPassed, Training
	WHERE Training.cName = HasPassed.cName AND Training.tLevel = HasPassed.tLevel
WITH CHECK OPTION;

-- Type required otherwise dependent ViewMemberEquipment won't work (premature projection)
-- Updatable, Not insertable, not deletable
-- Used in permissions
create VIEW ViewEquipmentTraining AS
        Select Equipment.detail, type, Training.*
        FROM Requires, Training, Equipment
        WHERE Training.cName = Requires.cName AND Training.tLevel = Requires.tLevel AND Requires.detail = Equipment.detail
WITH CHECK OPTION;

-- A view to show all equipment NOT requiring any training.
-- Updatable, Insertable, Deletable
-- Used in permissions
CREATE VIEW ViewFreeEquipment AS 
	SELECT * 
	FROM Equipment
	WHERE detail NOT IN (
		SELECT detail
		FROM Requires
	)
WITH CHECK OPTION;

-- Not updatable, Not insertable, not deletable
-- Used in permissions
-- This view will fail when Members have multiple entries in HasPassed
-- for the same course but with one a level below that required for abstracts
-- piece of equipment.
create VIEW ViewMemberEquipment AS
	Select DISTINCT mID, detail, type
	FROM ViewEquipmentTraining AS E, ViewMemberTraining AS M
	WHERE E.cName = M.cName AND M.tLevel>=E.tLevel
		AND NOT EXISTS (
			SELECT *
			FROM ViewEquipmentTraining AS I, ViewMemberTraining AS N
			WHERE E.detail = I.detail
				AND ((I.cName NOT IN (Select cName from ViewMemberTraining where ViewMemberTraining.mId = M.mID))
					OR (I.cName = N.cName AND I.tLevel>N.tLevel AND N.mID = M.mID)
				)
		);


-- This view abstracts over the join condition on the underlying tables.
-- Updatable, Not insertable, not deletable.
-- Used for permissions.
create VIEW ViewRoomEquipment AS
	Select Room.*, amount, Equipment.*
	FROM Room, Has, Equipment
	WHERE Room.rNumber=Has.rNumber AND Has.detail=Equipment.detail
WITH CHECK OPTION;
