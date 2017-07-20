-- All of these statements assume a properly installed and formatted MySQL database. Such as the appropraite environment variables being set, and disregard the default users created during installation.

-- Note that  usernames ARE case sensitive, but hostnames are not: https://dev.mysql.com/doc/refman/5.6/en/account-names.html
-- Hostnames are also matched as strings, such that 192.168.01.1 <> 192.168.1.1 . This doesn't apply when specifying IP adresses with netmasks.

-- With the exception of IT staff, it is not intended for any users to access the DB directly, but rather through some desktop application.
-- After all, how many staff are likely to know SQL?
-- As such, these accounts represent the credentials such an application would use to connect to the DB depending on the end user. Each 'department' (group of users)
-- has an account on the DB used by the application, with the app handling individual user authentication. Each department also has its own subnet on the LAN.

-- For security reasons, the DB can only be accessed from within the Local Area Network.


-- This all-powerful account can only be accessed from the local host (theoretically requiring physical server access if server so configured) and
-- with only the DB admins knowing the password.
Create USER 'root'@'localhost' IDENTIFIED BY "AHighEntropyHighSecurityEasilyMemorisedPassword";
GRANT ALL PRIVILEGES on *.* TO 'root'@'localhost' WITH GRANT OPTION;

-- Limitations on HR end users, such as not being able to modify their own entries should be
-- imposed at the application level.
create user 'HR'@'192.168.1.0/255.255.255.0' IDENTIFIED BY "ASomewhatLessSecurePassword0";
GRANT INSERT, SELECT, UPDATE, DELETE on ViewStaffMembers TO 'HR'@'192.168.1.0/255.255.255.0';
GRANT INSERT, SELECT (mID, position, sStarted, supMID, paygrade), UPDATE (mID, position, sStarted, supMID, paygrade), DELETE ON Staff TO 'HR'@'192.168.1.0/255.255.255.0';
GRANT SELECT on Paygrade TO 'HR'@'192.168.1.0/255.255.255.0'; -- Paygrade is handled by Finance, but viewable

-- Again it should be considered that a staff member knows their paygrade, and could therefore
-- modify the DB for personal gain. This should be handled at the application level and with sound business practices.
create user 'Finance'@'192.168.2.0/255.255.255.0' IDENTIFIED BY "ASomewhatLessSecurePassword1";
GRANT INSERT, SELECT, UPDATE, DELETE on Paygrade TO 'Finance'@'192.168.2.0/255.255.255.0';
GRANT INSERT, SELECT, UPDATE, DELETE on Membership TO 'Finance'@'192.168.2.0/255.255.255.0';
GRANT SELECT (mID, position, paygrade) on Staff TO 'Finance'@'192.168.2.0/255.255.255.0'; -- Limited viewing to allow data driven business decisions, but pseudoanonymous


create user 'Facilities'@'192.168.3.0/255.255.255' IDENTIFIED BY "ASomewhatLessSecurePassword2";
GRANT INSERT, SELECT, UPDATE, DELETE on Room TO 'Facilities'@'192.168.3.0/255.255.255';
GRANT INSERT, SELECT, UPDATE, DELETE ON Has TO 'Facilities'@'192.168.3.0/255.255.255';
GRANT INSERT, SELECT, UPDATE, DELETE ON Equipment TO 'Facilities'@'192.168.3.0/255.255.255';
GRANT SELECT, UPDATE ON ViewEquipmentTraining TO 'Facilities'@'192.168.3.0/255.255.255';
-- Specific insert and delete permission required as the view is not insertable.
-- Update not specifically required, but will make all transactions possible.
GRANT INSERT, DELETE, UPDATE ON Requires TO 'Facilities'@'192.168.3.0/255.255.255';
GRANT INSERT, DELETE, UPDATE ON Training TO 'Facilities'@'192.168.3.0/255.255.255';
-- Next two required to enable Facilites to check if a staff member is trained on a piece of equipment(and contact them).
-- It is up to Customer Services to register the training of a staff member on a piece of equipment, not Facilities.
GRANT SELECT ON ViewMemberEquipment TO 'Facilities'@'192.168.3.0/255.255.255';
GRANT SELECT (mID, fNames, sName, email, tNumber) FROM ViewStaffMembers TO 'Facilities'@'192.168.3.0/255.255.255'

-- Customer Services can access staff members' details for the purpose of making bookings, but cannot change
-- or delete them - that's HR's job.
-- Customer Services handles booking and training for all Staff and Non Staff members. Also accounts of 
-- non staff members.
create user 'CustomerServices'@'192.168.4.0/255.255.255.0' IDENTIFIED BY "ASomewhatLessSecurePassword3";
GRANT INSERT, SELECT, UPDATE, DELETE ON Booking TO 'CustomerServices'@'192.168.4.0/255.255.255.0';
GRANT SELECT ON ViewStaffMembers TO 'CustomerServices'@'192.168.4.0/255.255.255.0'; -- Required to be able to associate contact details to a booking and perform any enterprise constriaint checks
GRANT INSERT, SELECT, UPDATE, DELETE ON ViewNonStaffMembers TO 'CustomerServices'@'192.168.4.0/255.255.255.0'; -- Manage accounts of non staff members. As a Single Table view, DELETE is supported.
GRANT INSERT, SELECT, UPDATE ON ViewMemberTraining TO 'CustomerServices'@'192.168.4.0/255.255.255.0'; -- Changes here have a knock-on effect on next table (ViewMemberEquipment). As a multitable view, delete not supported.
GRANT DELETE, INSERT, SELECT, UPDATE ON HasPassed TO 'CustomerServices'@'192.168.4.0/255.255.255.0';
GRANT SELECT ON ViewMemberEquipment TO 'CustomerServices'@'192.168.4.0/255.255.255.0'; -- Can see equipment members are trained on, but can't modify (as it references Equipment table)
GRANT SELECT ON ViewFreeEquipment TO 'CustomerServices'@'192.168.4.0/255.255.255.0' -- Allows viewing equipment not requiring training
GRANT SELECT ON ViewRoomEquipment TO 'CustomerServices'@'192.168.4.0/255.255.255.0'; -- Can see rooms and associated equipment to check availability.
GRANT SELECT, UPDATE, INSERT, DELETE ON Uses TO 'CustomerServices'@'192.168.4.0/255.255.255.0';
GRANT SELECT ON Membership TO 'CustomerServices'@'192.168.4.0/255.255.255.0'; --Required to set up and manage customer accounts.

-- Allowing IT to log in from any machine on the LAN, subnet independent.
-- Note That IT do not have the ability to drop table or Super privileges.
-- Quite permissive, but allows IT to deal with a wide range of errors without too much jumping through hoops.
-- Even IT are not allowed to view staff paygrades though, or update/delete from those tables. This prevents abuse of the system, as such actions must go through HR (or root);
CREATE USER 'IT'@'192.168.0.0\255.225.0.0' identified BY "APasswordOfModeratebutnotextremeSecurity";
GRANT CREATE, LOCK TABLES, EVENT, ALTER, DELETE, INDEX, INSERT, SELECT, UPDATE, CREATE TEMPORARY TABLES, TRIGGER, CREATE VIEW, SHOW VIEW, ALTER ROUTINE, CREATE ROUTINE, EXECUTE, FILE, CREATE TABLESPACE, CREATE USER, PROCESS, PROXY, RELOAD, REPLICATION CLIENT, SHOW DATABASES ON *.* TO 'IT'@'192.168.0.0\255.225.0.0';
REVOKE ALL PRIVILEGES ON Staff FROM 'IT'@'192.168.0.0\255.225.0.0';
REVOKE ALL PRIVILEGES ON Paygrade FROM 'IT'@'192.168.0.0\255.225.0.0'; 

-- HR is in charge of inserting Staff details, including password.
-- IT maintain DISU on ViewStaffMembers as it is only minimally exploitable
GRANT CREATE, LOCK TABLES, EVENT, ALTER, INDEX, SELECT (mID, position, pword, sStarted, supMID), UPDATE (mID, position, pword, sStarted, supMID), TRIGGER ON Staff TO 'IT'@'192.168.0.0\255.225.0.0';
GRANT CREATE, LOCK TABLES, EVENT, ALTER, INDEX, INSERT, SELECT, TRIGGER ON Paygrade TO 'IT'@'192.168.0.0\255.225.0.0';

FLUSH HOSTS, PRIVILEGES; -- Make sure new users and privileges take effect immediately.

