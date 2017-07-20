-- Where referential actions are not specified, the MySQL default of "ON {UPDATE | DELETE} NO ACTION" is enforced.

Drop Table HasPassed;
drop table Uses;
drop table Has;
drop table Requires;
drop table Booking;
DROP TABLE Staff;
Drop table Training;
Drop TABLE Member;
DROP TABLE Paygrade;
DROP TABLE Membership;
drop table Room;
drop table Equipment;

-- Decimal (5,2) used to allow prices >= 100
-- Used on mPrice as well as aPrice for sake of consistency and versatility
create table Membership (
mLevel int(2) primary key,
mPrice decimal(5,2) not null,
aPrice decimal(5,2) not null
)ENGINE=INNODB;

-- AUTO_INCREMENT used for mID simply for ease, a random integer of fixed length
-- should really be calculated for each new entry.
-- Email is nullable, as not every member will have an email, or want to use it here.
-- The long and identical lengths for fNames and sName is to deal with particularly long names 
-- (eg double-barrelled surnames) and international names where the family names
-- come first. 
-- Changes to the mLevel number is cascaded through to this table, though deletes are rejected
-- This forces members to be manually removed, allowing their memberships to be changed or removed on a per member basis.
create table Member (
mID int(8) primary key AUTO_INCREMENT,
fNames varchar(32) not null,
sName varchar(32) not null,
dob Date not null,
email varchar(256), -- Encompases the absolute maximum length allowable by smtp standard RFC 5321
tNumber varchar(11) not null, -- varchar to maintain leading zeroes, 11 for a british number (others out of scope).
mLevel int(2) not null,
mStarted Date not null,
mExpire Date not null,
autoRenew Bool not null DEFAULT TRUE,
foreign key (mLevel) references Membership (mLevel) ON UPDATE CASCADE
)ENGINE=INNODB;

-- Since the scale of the sports centre is undefined, it is neccessary to accomodate the
-- salary of the CEO of some large national chain of gyms/centres. Thus the large Decimal(8,2) constraint.
-- Updates to the mLevel value are cascaded to maintian integrity, but not on delete. This requires that Finance update
-- the Paygrade details before removing a membership level.
create table Paygrade (
paygrade varchar(2) primary key,
salary Decimal(8,2) not null,
mLevel int(2) not null,
foreign key (mLevel) references Membership (mLevel) ON UPDATE CASCADE
)ENGINE=INNODB;

-- Password length of 256 is to allow for a variety of hashing functions, 
-- as well as a certain amount of future-proofing as new functions are developed.
-- supMID is nullable as at least one member of staff has no boss, eg the CEO.
-- mID cascades as the removal of a member's details automatically means they are no longer a staff member.
-- supMID is set null on delete to allow staff members to be removed without a replacement needing be immediately availible.
-- changing the paygrade code will update the relevant fields in the staff details, removal is forbidden while staff are
-- on that paygrade. This forces HR to change staff to another pay grade (or fire them).
create table Staff (
mID int(8) primary key,
position varchar(24) not null,
pword varchar(256) not null,
sStarted Date not null,
supMID int(8),
paygrade varchar(2) not null,
Foreign Key (mID) references Member (mID) ON DELETE CASCADE ON UPDATE CASCADE,
foreign key (supMID) references Staff (mID) ON DELETE SET NULL ON UPDATE CASCADE,
foreign key (paygrade) references Paygrade (paygrade) ON UPDATE CASCADE
)ENGINE=INNODB;

-- The large lengths in the domain are used to allow a high degree of 
-- flexibility in identifying pieces of equipment.
create table Equipment (
detail varchar(64) primary key,
type varchar(24) not null
)ENGINE=INNODB;

-- Large capacity integer length allows for very large rooms 
-- such as auditoriums, and nullable as not all rooms will have a max capacity, eg outdoor pitches
create table Room (
rNumber int(4) primary key, -- Not auto-increment as the number is meaningful in the world.
capacity int(4)
)ENGINE=INNODB;

-- The longer cName domain constraint should allow the full title of a training course to be
-- stored in all but truly extreme circumstances.
create table Training (
cName varchar(24) not null,
tLevel int(2) not null,
isAccredited Bool not null DEFAULT FALSE,
primary key(cName, tLevel)
)ENGINE=INNODB;


-- bID like mID in Member is auto incremented for ease, despite posing a slight security risk
-- mID cascades in both circumstances as either the booking needs to reference to that members new mID, 
-- or that member no longer exists, whereby the booking needs not be stored any more.
-- rNumber cannot cascade, as those members' bookings which reference the room should not be silenty changed.
-- The member must be notified first, and their bookings changed as per their wishes; Since there is no way to 
-- specify seperate referential actions for historic, current, or future bookings, even
-- previous bookings need to be manually dealt with (probably through deletion).
create table Booking (
bID int(8) primary key AUTO_INCREMENT, -- a security risk
mID int(8) not null,
rNumber int(4) not null,
date Date not null, 
sTime Time not null,
eTime Time not null,
isRoomBooking Bool not null DEFAULT FALSE,
foreign key (mID) references Member(mID) ON UPDATE CASCADE ON DELETE CASCADE,
foreign key (rNumber) references Room(rNumber)
)ENGINE=INNODB;

-- As with Booking, any changes to mID needs to be reflected here; removing a member means no 
-- longer needing to store their training.
-- A training course should not be removed silenty; members should be notified the sports centre
-- doesn't recognise that course any more.
create table HasPassed (
mID int(8) not null,
cName varchar(32) not null,
tLevel int(2) not null,
primary key (mID, cName, tLevel),
foreign key (mID) references Member (mID) ON UPDATE CASCADE ON DELETE CASCADE,
foreign key (cName, tLevel) references Training (cName, tLevel) ON UPDATE CASCADE
)ENGINE=INNODB;

-- The referential actions follow the same pattern as for HasPassed with similar arguments.
-- Removal of a training course requires first that Facilities decide if referencing equipment
-- require a different training course, or no longer require such a course. Thus is not silently deleted.
create table Requires (
detail varchar(64) not null,
cName varchar(32) not null,
tLevel int(2) not null,
primary key (detail, cName, tLevel),
foreign key (detail) references Equipment(detail) ON UPDATE CASCADE ON DELETE CASCADE,
foreign key (cName, tLevel) references Training (cName, tLevel) ON UPDATE CASCADE
)ENGINE=INNODB;

-- Foreign keys here don't cascade delete or set null to avoid stock keeping errors.
-- This forces that removing equipment from inventory requires removing them from every room 
-- manually (so none can be missed and left undocumented), and removing a room requires equipment
-- be (re)moved, so no equipment can be lost.
-- Updates to room numbers or equipment 'names' do cascade to make updating them easier.
create Table Has (
rNumber int(4) not null,
detail varchar(64) not null,
amount int(4) not null,
primary key (rNumber, detail),
foreign key (rNumber) references Room(rNumber) ON UPDATE CASCADE,
foreign key (detail) references Equipment(detail) ON UPDATE CASCADE
)ENGINE=INNODB;

-- Changes to a booking are reflected in this table to ease the process of deleting bookings;
-- also allowing updates to the booking ID to not lose equipment details.
-- As mentioned before, it is undesirable for changes to bookings to happen silently, that is
-- changes to or removal of equipment already booked must either be manually determined to be 
-- unimportant, or to notify the member. This way a member cannot turn up to a booking to find the
-- equipment no longer exists, at least not caused by the DB. 
create table Uses (
bID int(8) not null,
detail varchar(64) not null,
amount int(4) not null,
primary key(bID, detail),
foreign key (bID) references Booking(bID) ON UPDATE CASCADE ON DELETE CASCADE,
foreign key (detail) references Equipment(detail)
)ENGINE=INNODB;
