USE healthcare

DROP TABLE IF EXISTS [DateTable]



DECLARE @StartDate DATETIME 
SET @StartDate = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()-365), 0) --Starting value of Date Range Jan 1 the year prior to this one
DECLARE @EndDate DATETIME 
SET @EndDate = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()+720), 365) --End Value of Date Range Jan 1 2 years in the futureGO
DECLARE  @StartDateRand DateTime
DECLARE  @EndDateRand DATETIME 
DECLARE @RandomDateTime DATETIME
DECLARE @RandomNumber FLOAT
DECLARE @IntervalInDays INT ;
SET @IntervalInDays = CONVERT(INT, @EndDate - @StartDate)
SET @RandomNumber =  RAND()                   
SELECT  @RandomDateTime = DATEADD(ss, @RandomNumber * 86400, DATEADD(dd, @RandomNumber * @IntervalInDays, @StartDate))

CREATE TABLE [DateTable] 
    (
      [ID] INT IDENTITY,
      [Date] DATETIME
    )
--Let's add some data
INSERT  INTO [DateTable](date)
VALUES(@RandomDateTime)


SELECT * FROM [DateTable]
GO





    
