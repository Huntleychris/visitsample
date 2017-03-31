-- increments for internal loop
DECLARE @loopincrementer INT
SET @loopincrementer	= 0
-- randomizes the number of loops
DECLARE @randomizer INT
SET @randomizer = ABS(Checksum(NewID()) % 19)+1
-- sets how many days the person is admitted it's 1-10 days for this sample
DECLARE @enddatespacer INT
SET @enddatespacer	= ABS(Checksum(NewID()) % 10)+1
--sets the hour of admission
DECLARE @hourvariableadm INT
SET @hourvariableadm = ABS(Checksum(NewID()) % 24)
--sets the hour of discharge
DECLARE @hourvariabledsc INT
SET @hourvariabledsc = ABS(Checksum(NewID()) % 24)

-- variable for populating the admission values
DECLARE @startdatetime DATETIME 
--  variable for populating the discharge value
DECLARE @enddatetime DATETIME

--Sets the beginning of the path
SET @startdatetime = (SELECT min([date]) FROM dimdate)


--TEST SECTION
--SELECT @loopincrementer
--SELECT @randomizer
--SELECT @enddatespacer	
--SELECT @hourvariableadm	
--SELECT @hourvariabledsc
--SELECT @startdatetime	
--SELECT @enddatetime	

-- Populating the admissions to give the buffer so we don't get future date discharges
-- this can be updated to have a larger focus and show how real time activities work

WHILE @startdatetime <= getdate() -10
BEGIN 
	WHILE @randomizer >=@loopincrementer	
	BEGIN
		SET @enddatespacer	= ABS(Checksum(NewID()) % 10)+1
		SET @startdatetime = DATEADD(hh,@hourvariableadm, @startdatetime)
		SET @enddatetime = DATEADD(hh,@hourvariabledsc, @startdatetime) + @enddatespacer
		INSERT INTO visitinfo (visitstartdatetime, visitenddatetime)
		VALUES (@startdatetime, @enddatetime)
		SET @loopincrementer = @loopincrementer + 1
	END
	SET @loopincrementer = 0
	SET @randomizer = ABS(Checksum(NewID()) % 40)+1
	SET @startdatetime = DATEADD(hh,@hourvariableadm, @startdatetime)+1

END

SELECT COUNT(*) AS admcount, CAST(visitstartdatetime as date)  FROM dbo.visitinfo v	GROUP BY CAST(visitstartdatetime as date) 
TRUNCATE TABLE dbo.visitinfo	

