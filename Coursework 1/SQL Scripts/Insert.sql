-- This is important for the mID values to be consistent and allow the 
-- manually declared bookings to work.
-- Note that with the batch loading and auto increment NonStaffMember's mID start at 16 (inclusive)
ALTER TABLE Booking AUTO_INCREMENT=1;

-- Following would run as Finance
INSERT INTO Membership VALUES 
	(1, 10.00, 100.00),
	(2, 27.50, 288.00),
	(3, 33.33, 366.00);

INSERT INTO Paygrade VALUES 
	("A3", 45500.00, 3),
	("B3", 30000.00, 3),
	("B2", 30000.00, 2),
	("C2", 20250.00, 2),
	("D2", 18650.00, 2);

-- Following would run as Facilities
INSERT INTO Training VALUES 
	("Rock Climbing", 1, 0), 
	("Rock Climbing", 2, 0), 
	("Rock Climbing", 3, 0), 
	("Rock Climbing", 4, 1), 
	("Rock Climbing", 5, 1);

INSERT INTO Equipment VALUES 
	("100M Vertical", "Climbing Wall"),
	("50M Overhang", "Climbing Wall"),
	("Realistic Rockface", "Climbing Wall");

LOAD DATA LOCAL INFILE "Desktop/DBMS/Coursework1/Equipment" INTO TABLE Equipment;

LOAD DATA LOCAL INFILE "Desktop/DBMS/Coursework1/Training" INTO TABLE Training;	
	
INSERT INTO Requires VALUES 
	("Realistic Rockface", "Rock Climbing", 5),
	("Realistic Rockface", "Classical Education", 1),
	("50M Overhang", "Rock Climbing", 3),
	("100M Vertical", "Rock Climbing", 1),
	("Oxford", "Classical Education", 2),
	("From 5KG to 50KG", "GB Spotters", 3),
	("Outdoor Competition Size Grass", "Football Referee", 4),
	("Outdoor Mid Size Grass", "Football Referee", 2);

INSERT INTO Room VALUES 
	(1, 40),
	(2, 20),
	(3, 20),
	(4, 20),
	(5, 10),
	(6, 60),
	(7, 20),
	(10, NULL),
	(11, NULL);

INSERT INTO Has VALUES 
	(1,"Realistic Rockface", 1),
	(1,"50M Overhang", 2),
	(1,"100M Vertical", 2),
	(2, "Prolog", 7),
	(2, "Python 3", 3),
	(2, "Oxford", 3),
	(3, "Poly/ML", 5),
	(3, "Cambridge", 2),
	(3, "Eclipse", 3),
	(4, "Boardman", 8),
	(4, "Specialized", 8),
	(5, "Oxford", 8),
	(5, "Cambridge", 3),
	(6, "Full Size Indoor Badminton", 5),
	(10, "Full Size Outdoor Tennis", 5),
	(11, "Outdoor Competition Size Grass", 1),
	(11, "Outdoor Mid Size Grass", 2);
	
ALTER TABLE Member AUTO_INCREMENT=1;	

LOAD DATA LOCAL INFILE "Desktop/DBMS/Coursework1/StaffMembers"
INTO TABLE Member (fNames, sName, dob, email, tNumber, mLevel)
SET mID = DEFAULT, mStarted = CURDATE(), mExpire = ADDDATE(CURDATE(), INTERVAL 1 YEAR), autoRenew=1;

-- Where the SET col is not the last columns in the table, the column list must be specified
LOAD DATA LOCAL INFILE "Desktop/DBMS/Coursework1/Staff"
REPLACE
INTO TABLE Staff (mID, position, pword, supMID, paygrade)
SET sStarted = CURDATE();
	
-- Insert Members with email addresses
LOAD DATA LOCAL INFILE "Desktop/DBMS/Coursework1/Members"
INTO TABLE Member (fNames, sName, dob, email, tNumber, mLevel, autoRenew)
SET mID=DEFAULT, mStarted = CURDATE(), mExpire = ADDDATE(CURDATE(), INTERVAL 1 MONTH);
-- And without
LOAD DATA LOCAL INFILE "Desktop/DBMS/Coursework1/MemberNoEmail"
INTO TABLE Member (fNames, sName, dob, email, tNumber, mLevel, autoRenew)
SET mID = DEFAULT, mStarted = CURDATE(), mExpire = ADDDATE(CURDATE(), INTERVAL 1 YEAR);

-- Load a random set of mID values and training they have passed.
LOAD DATA LOCAL INFILE "Desktop/DBMS/Coursework1/HasPassed"
INTO TABLE HasPassed;
	
-- Insert normal member
-- Run as Customer Services
-- With the bulk loading and auto incrementing, Garrus should have mID 782
INSERT INTO ViewNonStaffMembers VALUES (DEFAULT, "Garrus", "Vakarian", 20071120, "archangel@omegaextra.net", "07700900856", 2, CURDATE(), ADDDATE(CURDATE(), INTERVAL 1 MONTH), 1);

-- Register a member's training
-- Run as Customer Services
-- Notably 782 is the only member
-- qualified for the Realistic Rockface
INSERT INTO HasPassed VALUES 
	(782, "Rock Climbing", 5),
	(782, "Classical Education", 2),
	(5, "Rock Climbing", 4);

-- Insert a new staff member
-- Replace used to allow insertion of a known member with a known mID
INSERT INTO Member VALUES (DEFAULT, "Sir Topham", "Hatt", 19450913, "WAwdrey@sodoronline.com", "01314960086", 3, CURDATE(), ADDDATE(CURDATE(), INTERVAL 1 YEAR), 1);
INSERT INTO Staff VALUES (LAST_INSERT_ID(), "The Fat Controller", "$2a$07$xlC62olpdNdIZdCoIJ615.HIp2zky9wLgeD.PNgKImJPcPlVCvn2K", CURDATE(), NULL, "A3");

-- Insert a booking
-- Run as Customer Services
-- Note that 2100 is interpretated by MySQL as MMSS not HHMM. 21:00 is HH:MM though.
INSERT INTO Booking VALUES (DEFAULT, 782, 1, 20170225, 120000, 140000, 0);
INSERT INTO Uses VALUES (LAST_INSERT_ID(), "50M Overhang", 1);


INSERT INTO Booking VALUES
	(2, 2, 1, 20170225, 110000, 120000, 0),
	(3, 23, 1, 20170225, 130000, 133000, 0), -- Inner overlap with booking (DEFAULT, 782...), above. Fully booked at this point
	(4, 23, 1, 20170225, 123000, 140000, 0), -- End time overlap with (2, 2...) above
	(5, 5, 1, 20170225, 130000, 150000, 0),
	(6, 203, 1, 20170226, 140000, 150000, 0), -- Overlap in time but not date.
	(7, 122, 5, 20170225, 090000, 120000, 0), -- Multiple item booking, not all items in room. More items in room than bookings allowed (by Room.capacity)
	(8, 782, 4, 20170225, '15:00', '17:00', 1), -- Room booking; includes all equipment in room.
	(9, 554, 7, 20170225, 120000, 160000, 1); -- Booking a room without equipment.

INSERT INTO Uses VALUES 
	(2, "100M Vertical", 1), 
	(3, "50M Overhang", 1),
	(4, "100M Vertical", 1),
	(5, "Realistic Rockface", 1),
	(6, "Realistic Rockface", 1),
	(7, "Oxford", 5), 
	(7, "Cambridge", 3),
	(8, "Boardman", 8),
	(8, "Specialized", 8);
	
-- A dirty fix to avoid having to regenerate an entire set of new data
UPDATE Member SET mStarted=20160517, mExpire=20170517 WHERE RAND() <0.3;
UPDATE Member SET mStarted=20170113, mExpire=20170213 WHERE RAND() <0.3;
UPDATE Member SET mStarted=20170223, mExpire=20180223 WHERE RAND() <0.3;


