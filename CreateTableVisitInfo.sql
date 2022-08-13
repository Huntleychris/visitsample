USE healthcare

DROP TABLE IF EXISTS [dbo].[visitinfo]

CREATE TABLE 
visitinfo 
(visitid int identity (1000000,1) not null primary key, 
personid int,
visitstartdatetime datetime, 
visitenddatetime datetime)

SELECT * FROM [dbo].[visitinfo]



DECLARE @personloopmin INT
DECLARE @personloopmax INT
DECLARE @StartDate DATETIME 
DECLARE @EndDate DATETIME 

DECLARE @visitbegin DATETIME
DECLARE @visitend DATETIME
Declare @randdatevar INT
SET @randdatevar = Cast(RAND()*(6.2-1.5)+1.5 as int);

SET @visitbegin = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()-365), 0) --Starting value of Date Range Jan 1 the year prior to this one
SET @EndDate = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()+720), 365) --End Value of Date Range Jan 1 2 years in the future

SET @personloopmin = (SELECT MIN(personid) from dbo.person)
SELECT @personloopmax = MAX(personid) from dbo.person

WHILE @personloopmin <= @personloopmax
BEGIN
SET @visitbegin = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()-365), 0) 
SET @randdatevar = Cast(RAND()*(6.2-1.5)+1.5 as int);
SET @visitend = DATEADD(dd,@randdatevar, @visitbegin) 
INSERT INTO dbo.visitinfo (personid, visitstartdatetime, visitenddatetime)
VALUES (@personloopmin, @visitbegin, @visitend)
SET @personloopmin = @personloopmin + 1
End

SELECT * FROM [dbo].[visitinfo]
