DROP TABLE IF EXISTS [DateTable]



DECLARE @StartDate DATETIME 
SET @StartDate = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()-365), 0) --Starting value of Date Range Jan 1 the year prior to this one
DECLARE @EndDate DATETIME 
SET @EndDate = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()+720), 365) --End Value of Date Range Jan 1 2 years in the futureGO


CREATE TABLE [DateTable] 
    (
      [ID] INT IDENTITY,
      [Date] DATETIME
    )
--Let's add some data
INSERT  INTO [DateTable]
SELECT DBO.[GenerateRandomDateTime]
(@startdate,@EndDate)


SELECT * FROM [DateTable]
GO