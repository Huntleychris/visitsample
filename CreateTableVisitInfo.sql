USE healthcare
-- clean up tables so the code can be repeatedly run
DROP TABLE IF EXISTS [dbo].[visitinfo]
DROP TABLE IF EXISTS #tempvisit
DROP TABLE IF EXISTS #tempvisit2 

--create the table
CREATE TABLE 
visitinfo 
(visitid int identity (1,1) not null primary key, 
personid int,
visitstartdatetime datetime, 
visitenddatetime datetime,
LOS decimal(3,2))

-- declaring the variables for the execution here

DECLARE @personloopmin INT
DECLARE @personloopmax INT
DECLARE @StartDate DATETIME 
DECLARE @EndDate DATETIME 

DECLARE @visitbegin DATETIME
DECLARE @visitend DATETIME
Declare @randdatevar INT
SET @randdatevar = Cast(RAND()*(6.2-1.5)+1.5 as int);
Declare @visitbeginvar INT
SET @visitbeginvar = Cast(RAND()*(6.2-1.5)+1.5 as int);

SET @visitbegin = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()-365), 0) --Starting value of Date Range Jan 1 the year prior to this one
SET @EndDate = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()+720), 365) --End Value of Date Range Jan 1 2 years in the future

SET @personloopmin = (SELECT MIN(personid) from dbo.person)
SELECT @personloopmax = MAX(personid) from dbo.person

WHILE @personloopmin <= @personloopmax
BEGIN
SET @visitbeginvar = Cast(RAND()*(365-6)+6 as int);
SET @visitbegin = DATEADD(dd, DATEDIFF(dd, 0, GETDATE()-@visitbeginvar), 0) 
SET @randdatevar = Cast(RAND()*(6.2-1.5)+1.5 as int);
SET @visitend = DATEADD(dd,@randdatevar, @visitbegin) 
INSERT INTO dbo.visitinfo (personid, visitstartdatetime, visitenddatetime)
VALUES (@personloopmin, @visitbegin, @visitend)
SET @personloopmin = @personloopmin + 1
End

SELECT TOP (80) Percent * 
INTO
#tempvisit 
FROM [dbo].[visitinfo] Order by Rand() 
-- update temp table for visit start and end times
Declare @hourvar INT
Declare @hourendvar INT
DECLARE @incrementor INT
DECLARE @incrementormax INT
SELECT @incrementor = 0 --MIN(visitid) FROM #tempvisit
SELECT @incrementormax = MAX(visitid) FROM #tempvisit


WHILE @incrementor < @incrementormax
BEGIN
UPDATE #tempvisit 
SET visitstartdatetime = DATEADD(MINUTE, @hourvar, CAST(FLOOR(CAST(visitstartdatetime AS FLOAT)) AS DATETIME))
WHERE visitid = @incrementor  
UPDATE #tempvisit 
SET visitenddatetime = DATEADD(MINUTE, @hourendvar, CAST(FLOOR(CAST(visitenddatetime AS FLOAT)) AS DATETIME))
WHERE visitid  = @incrementor
SET @incrementor = @incrementor +1
SET @hourvar = Cast(RAND()*(1440-1)+1 as int);
SET @hourendvar = Cast(RAND()*(900-420)+429 as int)
END 


UPDATE visitinfo
SET visitstartdatetime = #tempvisit.visitstartdatetime
FROM #tempvisit
WHERE #tempvisit.visitid = visitinfo.visitid

UPDATE visitinfo
SET visitenddatetime = #tempvisit.visitenddatetime
FROM #tempvisit
WHERE #tempvisit.visitid = visitinfo.visitid


-- TEMP VISIT 2 for the other 20% of cases 


SELECT  * 
INTO
#tempvisit2 
FROM [dbo].[visitinfo] EXCEPT SELECT TOP(80) PERCENT * FROM visitinfo ORDER BY visitid

-- update temp table for visit start and end times
Declare @hourvar2 INT
Declare @hourendvar2 INT
DECLARE @incrementor2 INT
DECLARE @incrementormax2 INT
SELECT @incrementor2 = 0 --MIN(visitid) FROM #tempvisit
SELECT @incrementormax2 = MAX(visitid) FROM #tempvisit2


WHILE @incrementor2 < @incrementormax2
BEGIN
UPDATE #tempvisit2 
SET visitstartdatetime = DATEADD(MINUTE, @hourvar2, CAST(FLOOR(CAST(visitstartdatetime AS FLOAT)) AS DATETIME))
WHERE visitid = @incrementor2  
UPDATE #tempvisit2 
SET visitenddatetime = DATEADD(MINUTE, @hourendvar2, CAST(FLOOR(CAST(visitenddatetime AS FLOAT)) AS DATETIME))
WHERE visitid  = @incrementor2
SET @incrementor2 = @incrementor2 +1
SET @hourvar2 = Cast(RAND()*(1440-1)+1 as int);
SET @hourendvar2 = Cast(RAND()*(1440-900)+900 as int)
END 


UPDATE visitinfo
SET visitstartdatetime = #tempvisit2.visitstartdatetime
FROM #tempvisit2
WHERE #tempvisit2.visitid = visitinfo.visitid

UPDATE visitinfo
SET visitenddatetime = #tempvisit2.visitenddatetime
FROM #tempvisit2
WHERE #tempvisit2.visitid = visitinfo.visitid


DECLARE @counter INT 
SET @counter  = 0
DECLARE @counterend INT
SELECT @counterend = MAX(visitid) FROM #tempvisit2
DECLARE @los decimal (3,2)

WHILE @counter <= @counterend
BEGIN
SELECT @LOS = CAST(ROUND(SUM(DATEDIFF(ss,visitstartdatetime,visitenddatetime)/86400.0),2) as decimal (3,2)) FROM visitinfo where @counter = visitid
UPDATE 
visitinfo
SET los = @los
WHERE visitid = @counter
SET @counter = @counter + 1
END


SELECT top 1000 *,CAST(ROUND(SUM(DATEDIFF(ss,visitstartdatetime,visitenddatetime)/86400.0),2) as decimal (3,2)) as los2 FROM visitinfo GROUP BY visitid, personid, visitstartdatetime, visitenddatetime, LOS



SELECT * FROM visitinfo 
