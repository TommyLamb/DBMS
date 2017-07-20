-- These are convenience statements for modifying query conditions on the fly.
SET @DATE=20170225;
SET @STIME=100000;
SET @ETIME=170000;

-- This query can give the list of concurrent bookings within a date and time frame.
-- Using this query in a self join is neccessary to compute which rooms and equipment are
-- fully booked in that time frame.
-- Unfortunately Views cannot take variables, such as @DATE.
-- Temporary Tables cannot be referenced more than once in a single query (Why!?)
-- Permenant tables are not session independent and are obviously out.
-- And user defined variables can only hold a single column.
-- In other words, it will be neccessary to run this query on what is a potentially very large
-- table with a large return set MULTIPLE TIMES.

--	SELECT Booking.*, amount, detail
--	FROM Booking, Uses
--	WHERE date=@DATE AND Uses.bID = Booking.bID AND sTime<@ETIME AND eTime>@STIME;

-- This query returns the list of all equipment which has been fully booked in any room
-- at any point within the given time frame using a self join on results of the concurrent booking query above.
-- The first sub query selects all concurrent bookings which run over the start time of the outer concurrent 
-- booking (including the outer booking itself) as well as any that run over the entire outer booking (think nested bookings).
-- The second sub query works over the end time of the outer booking, but not including the outer booking or enclosing bookings,
-- as end times are considered exclusive (they don't sount towards total booked) and any enclosing bookings are checked elsewhere. 
-- Even if more bookings begin during the nested, outer booking, the enclosing booking will be included in the check performed 
-- over the start of time of these new bookings.
-- This has the effect of checking the amount of equipment x booked in room y at the start and end of 
-- every currently existing booking within the time frame given.

-- This query is embedded in the query below it.
-- SELECT DISTINCT O.rNumber, O.detail
-- FROM (	SELECT Booking.*, amount, detail
--		FROM Booking, Uses
--		WHERE date=@DATE AND Uses.bID = Booking.bID AND sTime<@ETIME AND eTime>@STIME
--	) AS O
-- WHERE 
--	EXISTS (
--		SELECT I.amount, ViewRoomEquipment.amount, ViewRoomEquipment.capacity
--		FROM (	SELECT Booking.*, amount, detail
--				FROM Booking, Uses
--				WHERE date=@DATE AND Uses.bID = Booking.bID AND sTime<@ETIME AND eTime>@STIME
--			) AS I, ViewRoomEquipment
--		WHERE I.sTime<=O.sTime AND I.eTime>O.sTime AND I.detail = O.detail AND I.rNumber = O.rNumber AND ViewRoomEquipment.rNumber = I.rNumber AND ViewRoomEquipment.detail = I.detail 
--		HAVING (sum(I.amount)>=ViewRoomEquipment.amount OR count(I.amount) >= ViewRoomEquipment.capacity)
--		)
--	OR EXISTS (
--		SELECT I.amount, ViewRoomEquipment.amount, ViewRoomEquipment.capacity
--		FROM (	SELECT Booking.*, amount, detail
--				FROM Booking, Uses
--				WHERE date=@DATE AND Uses.bID = Booking.bID AND sTime<@ETIME AND eTime>@STIME
--			) AS I, ViewRoomEquipment
--		WHERE I.sTime<O.eTime AND I.eTime>O.eTime AND I.sTime>O.sTime AND I.detail = O.detail AND I.rNumber = O.rNumber AND ViewRoomEquipment.rNumber = I.rNumber AND ViewRoomEquipment.detail = I.detail 
--		HAVING (sum(I.amount)>=ViewRoomEquipment.amount OR count(I.bID) >= ViewRoomEquipment.capacity)
--	)
-- ;

-- By 'negating' the previous query this returns the list of all equipment and associated rooms which are available for booking at least 1 of
-- within the globally defined time frame.
SELECT rNumber, detail, type
FROM ViewRoomEquipment AS R
WHERE NOT EXISTS (
	SELECT DISTINCT O.rNumber, O.detail
	FROM (	SELECT Booking.*, amount, detail
			FROM Booking, Uses
			WHERE date=@DATE AND Uses.bID = Booking.bID AND sTime<@ETIME AND eTime>@STIME
		) AS O
	WHERE (
			EXISTS (
				SELECT I.amount, ViewRoomEquipment.amount, ViewRoomEquipment.capacity
				FROM (	SELECT Booking.*, amount, detail
						FROM Booking, Uses
						WHERE date=@DATE AND Uses.bID = Booking.bID AND sTime<@ETIME AND eTime>@STIME
					) AS I, ViewRoomEquipment
				WHERE I.sTime<=O.sTime AND I.eTime>O.sTime AND I.detail = O.detail AND I.rNumber = O.rNumber AND ViewRoomEquipment.rNumber = I.rNumber AND ViewRoomEquipment.detail = I.detail 
				HAVING (sum(I.amount)>=ViewRoomEquipment.amount OR count(I.amount) >= ViewRoomEquipment.capacity)
			)
			OR EXISTS (
				SELECT I.amount, ViewRoomEquipment.amount, ViewRoomEquipment.capacity
				FROM (	SELECT Booking.*, amount, detail
						FROM Booking, Uses
						WHERE date=@DATE AND Uses.bID = Booking.bID AND sTime<@ETIME AND eTime>@STIME
					) AS I, ViewRoomEquipment
				WHERE I.sTime<O.eTime AND I.eTime>O.eTime AND I.sTime>O.sTime AND I.detail = O.detail AND I.rNumber = O.rNumber AND ViewRoomEquipment.rNumber = I.rNumber AND ViewRoomEquipment.detail = I.detail 
				HAVING (sum(I.amount)>=ViewRoomEquipment.amount OR count(I.bID) >= ViewRoomEquipment.capacity)
			)
		)
		AND R.rNumber = O.rNumber AND R.detail = O.detail
);