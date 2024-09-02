USE healthcare

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/

--PREP AND CLEANUP

DROP PROC IF EXISTS [dbo].[FillDateDimension]
DROP PROC IF EXISTS [dbo].[FillTimeDimension]
DROP TABLE IF EXISTS [dbo].[visitinfo]
DROP TABLE IF EXISTS [dbo].[orders]
DROP TABLE IF EXISTS [dbo].[person]
DROP TABLE IF EXISTS [dbo].[visitinfo]
DROP TABLE IF EXISTS #tempvisit
DROP TABLE IF EXISTS #tempvisit2 
DROP TABLE IF EXISTS [dbo].[datedimension]
DROP TABLE IF EXISTS [dbo].[TimeDimension]

GO
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
--TABLE CREATION AREA
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/

--CREATE PERSON TABLE
CREATE TABLE 
person 
(personid int identity (1000000,1) not null primary key, 
firstinitial char(1) ,
lastinitial char(1),
DOB date, 
)
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/

--Populate Person Table
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/

DECLARE @loopincrement INT 
DECLARE @firstinitial CHAR(1)
DECLARE @lastinitial CHAR(1)
SET @loopincrement = 0
SET @firstinitial = ''
SET @lastinitial = ''

DECLARE @start DATETIME = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()-36135), 0) --previous 99 years
DECLARE @end DATETIME = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()-6570), 0)-- starting at 18 so it's only adults
DECLARE @gap INT = DATEDIFF(DD,@start,@end)
DECLARE @dateModified Date = '01/01/01'


WHILE @loopincrement < 5000
BEGIN 
SET @loopincrement = @loopincrement +1
SET @firstinitial = CHAR(cast((90 - 65) * rand() + 65 AS INTEGER)) 
SET @lastinitial = CHAR(cast((90 - 65) * rand() + 65 AS INTEGER)) 
SET @dateModified = DATEADD(DD,@gap*RAND(),@start)
PRINT CONVERT(VARCHAR(5),@loopincrement)+' '+@lastinitial+', '+ @firstinitial +' ' +CONVERT(Varchar(10),@datemodified) 
--PRINT @firstinitial
INSERT INTO dbo.person (lastinitial, firstinitial, DOB)
VALUES (@lastinitial, @firstinitial, @dateModified)
END

/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
--CREATE ORDER TABLE
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/

CREATE TABLE 
orders 
(orderid int identity (1000000,1) not null primary key, 
personid int ,
ordertype varchar(100),
startdate date,
starttime time
)


/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
--Create Visit Info Table
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/

CREATE TABLE 
visitinfo 
(visitid int identity (1,1) not null primary key, 
personid int,
visitstartdatetime datetime, 
visitenddatetime datetime,
LOS decimal(3,2),
admissiondateonly date,
admissiontimeonly time,
dischargedate date,
dischargetime time)

-- ADD IN FOREIGN KEY RELATIONSHIP

ALTER TABLE [dbo].visitinfo     
ADD CONSTRAINT FK_personid FOREIGN KEY (personid)     
    REFERENCES [dbo].[Person] (personid)     
    ON DELETE CASCADE    
    ON UPDATE CASCADE  

/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
--Populate Visit Info Table
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
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
DECLARE @visitstartdate DATE
DECLARE @visitstarttime TIME
DECLARE @visitenddate DATE
DECLARE @visitendtime TIME

WHILE @counter <= @counterend
BEGIN
SELECT @LOS = CAST(ROUND(SUM(DATEDIFF(ss,visitstartdatetime,visitenddatetime)/86400.0),2) as decimal (3,2)) FROM visitinfo where @counter = visitid
SELECT @visitstartdate = CONVERT(DATE,[visitstartdatetime]) FROM visitinfo where @counter = visitid
SELECT @visitstarttime = CONVERT(TIME(0),[visitstartdatetime]) FROM visitinfo  where @counter = visitid
SELECT @visitenddate = CONVERT(DATE,[visitenddatetime]) FROM visitinfo where @counter = visitid
SELECT @visitendtime = CONVERT(TIME(0),[visitenddatetime]) FROM visitinfo  where @counter = visitid
UPDATE 
visitinfo
SET
los = @los,
admissiondateonly = @visitstartdate,
admissiontimeonly = @visitstarttime,
dischargedate = @visitenddate,
dischargetime = @visitendtime 
WHERE visitid = @counter

SET @counter = @counter + 1
END


/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
--CREATE DATE DIMENSION
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/

CREATE TABLE	[dbo].[datedimension]
	(	[DateKey] INT primary key, 
		[Date] DATE NOT NULL UNIQUE,
		[FullDateUK] CHAR(10), -- Date in dd-MM-yyyy format
		[FullDateUSA] CHAR(10),-- Date in MM-dd-yyyy format
		[DayOfMonth] VARCHAR(2), -- Field will hold day number of Month
		[DaySuffix] VARCHAR(4), -- Apply suffix as 1st, 2nd ,3rd etc
		[DayName] VARCHAR(9), -- Contains name of the day, Sunday, Monday 
		[DayOfWeekUSA] CHAR(1),-- First Day Sunday=1 and Saturday=7
		[DayOfWeekUK] CHAR(1),-- First Day Monday=1 and Sunday=7
		[DayOfWeekInMonth] VARCHAR(2), --1st Monday or 2nd Monday in Month
		[DayOfWeekInYear] VARCHAR(2),
		[DayOfQuarter] VARCHAR(3),
		[DayOfYear] VARCHAR(3),
		[WeekOfMonth] VARCHAR(1),-- Week Number of Month 
		[WeekOfQuarter] VARCHAR(2), --Week Number of the Quarter
		[WeekOfYear] VARCHAR(2),--Week Number of the Year
		[Month] VARCHAR(2), --Number of the Month 1 to 12
		[MonthName] VARCHAR(9),--January, February etc
		[MonthOfQuarter] VARCHAR(2),-- Month Number belongs to Quarter
		[Quarter] CHAR(1),
		[QuarterName] VARCHAR(9),--First,Second..
		[Year] CHAR(4),-- Year value of Date stored in Row
		[YearName] CHAR(7), --CY 2012,CY 2013
		[MonthYear] CHAR(10), --Jan-2013,Feb-2013
		[MMYYYY] CHAR(6),
		[FirstDayOfMonth] DATE,
		[LastDayOfMonth] DATE,
		[FirstDayOfQuarter] DATE,
		[LastDayOfQuarter] DATE,
		[FirstDayOfYear] DATE,
		[LastDayOfYear] DATE,
		[IsHolidayUSA] BIT,-- Flag 1=National Holiday, 0-No National Holiday
		[IsWeekday] BIT,-- 0=Week End ,1=Week Day
		[HolidayUSA] VARCHAR(50)
		,--Name of Holiday in US
		[IsHolidayNonUS] BIT Null, -- Flag 1=National Holiday, 0-No National Holiday
		[HolidayNonUS] VARCHAR(50) Null --Name of Holiday
	)
GO


/********************************************************************************************/
--This sets up the table boundaries.  
--The @startdate is Jan 1 of the previous year and this is maintained by the -365.  If you only want this year set it to 0
--The @enddate is Jan 1 two years into the future this is the +720  Reducing this will get you into other years as desired

DECLARE @StartDate DATETIME 
SET @StartDate = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()-365), 0) --Starting value of Date Range Jan 1 the year prior to this one
DECLARE @EndDate DATETIME 
SET @EndDate = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()+720), 365) --End Value of Date Range Jan 1 2 years in the future

--Temporary Variables To Hold the Values During Processing of Each Date of Year
DECLARE
	@DayOfWeekInMonth INT,
	@DayOfWeekInYear INT,
	@DayOfQuarter INT,
	@WeekOfMonth INT,
	@CurrentYear INT,
	@CurrentMonth INT,
	@CurrentQuarter INT

/*Table Data type to store the day of week count for the month and year*/
DECLARE @DayOfWeek TABLE (DOW INT, MonthCount INT, QuarterCount INT, YearCount INT)

INSERT INTO @DayOfWeek VALUES (1, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (2, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (3, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (4, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (5, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (6, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (7, 0, 0, 0)

--Extract and assign part of Values from Current Date to Variable

DECLARE @CurrentDate AS DATETIME = @StartDate
SET @CurrentMonth = DATEPART(MM, @CurrentDate)
SET @CurrentYear = DATEPART(YY, @CurrentDate)
SET @CurrentQuarter = DATEPART(QQ, @CurrentDate)

/********************************************************************************************/
--Proceed only if Start Date(Current date ) is less than End date you specified above

WHILE @CurrentDate < @EndDate
BEGIN
 
/*Begin day of week logic*/

         /*Check for Change in Month of the Current date if Month changed then 
          Change variable value*/
	IF @CurrentMonth != DATEPART(MM, @CurrentDate) 
	BEGIN
		UPDATE @DayOfWeek
		SET MonthCount = 0
		SET @CurrentMonth = DATEPART(MM, @CurrentDate)
	END

        /* Check for Change in Quarter of the Current date if Quarter changed then change 
         Variable value*/

	IF @CurrentQuarter != DATEPART(QQ, @CurrentDate)
	BEGIN
		UPDATE @DayOfWeek
		SET QuarterCount = 0
		SET @CurrentQuarter = DATEPART(QQ, @CurrentDate)
	END
       
        /* Check for Change in Year of the Current date if Year changed then change 
         Variable value*/
	

	IF @CurrentYear != DATEPART(YY, @CurrentDate)
	BEGIN
		UPDATE @DayOfWeek
		SET YearCount = 0
		SET @CurrentYear = DATEPART(YY, @CurrentDate)
	END
	
        -- Set values in table data type created above from variables 

	UPDATE @DayOfWeek
	SET 
		MonthCount = MonthCount + 1,
		QuarterCount = QuarterCount + 1,
		YearCount = YearCount + 1
	WHERE DOW = DATEPART(DW, @CurrentDate)

	SELECT
		@DayOfWeekInMonth = MonthCount,
		@DayOfQuarter = QuarterCount,
		@DayOfWeekInYear = YearCount
	FROM @DayOfWeek
	WHERE DOW = DATEPART(DW, @CurrentDate)
	
/*End day of week logic*/


/* Populate Your Dimension Table with values*/
	
	INSERT INTO [dbo].[datedimension]
	SELECT
		
		CONVERT (char(8),@CurrentDate,112) as DateKey,
		@CurrentDate AS Date,
		CONVERT (char(10),@CurrentDate,103) as FullDateUK,
		CONVERT (char(10),@CurrentDate,101) as FullDateUSA,
		DATEPART(DD, @CurrentDate) AS DayOfMonth,
		--Apply Suffix values like 1st, 2nd 3rd etc..
		CASE 
			WHEN DATEPART(DD,@CurrentDate) IN (11,12,13) THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'th'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 1 THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'st'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 2 THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'nd'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 3 THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'rd'
			ELSE CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'th' 
			END AS DaySuffix,
		
		DATENAME(DW, @CurrentDate) AS DayName,
		DATEPART(DW, @CurrentDate) AS DayOfWeekUSA,
		-- check for day of week as Per US and change it as per UK format 
		CASE DATEPART(DW, @CurrentDate)
			WHEN 1 THEN 7
			WHEN 2 THEN 1
			WHEN 3 THEN 2
			WHEN 4 THEN 3
			WHEN 5 THEN 4
			WHEN 6 THEN 5
			WHEN 7 THEN 6
			END 
			AS DayOfWeekUK,
		
		@DayOfWeekInMonth AS DayOfWeekInMonth,
		@DayOfWeekInYear AS DayOfWeekInYear,
		@DayOfQuarter AS DayOfQuarter,
		DATEPART(DY, @CurrentDate) AS DayOfYear,
		DATEPART(WW, @CurrentDate) + 1 - DATEPART(WW, CONVERT(VARCHAR, DATEPART(MM, @CurrentDate)) + '/1/' + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate))) AS WeekOfMonth,
		(DATEDIFF(DD, DATEADD(QQ, DATEDIFF(QQ, 0, @CurrentDate), 0), @CurrentDate) / 7) + 1 AS WeekOfQuarter,
		DATEPART(WW, @CurrentDate) AS WeekOfYear,
		DATEPART(MM, @CurrentDate) AS Month,
		DATENAME(MM, @CurrentDate) AS MonthName,
		CASE
			WHEN DATEPART(MM, @CurrentDate) IN (1, 4, 7, 10) THEN 1
			WHEN DATEPART(MM, @CurrentDate) IN (2, 5, 8, 11) THEN 2
			WHEN DATEPART(MM, @CurrentDate) IN (3, 6, 9, 12) THEN 3
			END AS MonthOfQuarter,
		DATEPART(QQ, @CurrentDate) AS Quarter,
		CASE DATEPART(QQ, @CurrentDate)
			WHEN 1 THEN 'First'
			WHEN 2 THEN 'Second'
			WHEN 3 THEN 'Third'
			WHEN 4 THEN 'Fourth'
			END AS QuarterName,
		DATEPART(YEAR, @CurrentDate) AS Year,
		'CY ' + CONVERT(VARCHAR, DATEPART(YEAR, @CurrentDate)) AS YearName,
		LEFT(DATENAME(MM, @CurrentDate), 3) + '-' + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate)) AS MonthYear,
		RIGHT('0' + CONVERT(VARCHAR, DATEPART(MM, @CurrentDate)),2) + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate)) AS MMYYYY,
		CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD, @CurrentDate) - 1), @CurrentDate))) AS FirstDayOfMonth,
		CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD, (DATEADD(MM, 1, @CurrentDate)))), DATEADD(MM, 1, @CurrentDate)))) AS LastDayOfMonth,
		DATEADD(QQ, DATEDIFF(QQ, 0, @CurrentDate), 0) AS FirstDayOfQuarter,
		DATEADD(QQ, DATEDIFF(QQ, -1, @CurrentDate), -1) AS LastDayOfQuarter,
		CONVERT(DATETIME, '01/01/' + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate))) AS FirstDayOfYear,
		CONVERT(DATETIME, '12/31/' + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate))) AS LastDayOfYear,
		NULL AS IsHolidayUSA,
		CASE DATEPART(DW, @CurrentDate)
			WHEN 1 THEN 0
			WHEN 2 THEN 1
			WHEN 3 THEN 1
			WHEN 4 THEN 1
			WHEN 5 THEN 1
			WHEN 6 THEN 1
			WHEN 7 THEN 0
			END AS IsWeekday,
		NULL AS HolidayUSA, Null, Null

	SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END

	/*Add HOLIDAYS USA*/
	/*THANKSGIVING - Fourth THURSDAY in November*/
	UPDATE [dbo].[datedimension]
		SET HolidayUSA = 'Thanksgiving Day'
	WHERE
		[Month] = 11 
		AND [DayOfWeekUSA] = 'Thursday' 
		AND DayOfWeekInMonth = 4

	/*CHRISTMAS*/
	UPDATE [dbo].[datedimension]
		SET HolidayUSA = 'Christmas Day'
		
	WHERE [Month] = 12 AND [DayOfMonth]  = 25

	/*4th of July*/
	UPDATE [dbo].[datedimension]
		SET HolidayUSA = 'Independance Day'
	WHERE [Month] = 7 AND [DayOfMonth] = 4

	/*New Years Day*/
	UPDATE [dbo].[datedimension]
		SET HolidayUSA = 'New Year''s Day'
	WHERE [Month] = 1 AND [DayOfMonth] = 1

	/*Memorial Day - Last Monday in May*/
	UPDATE [dbo].[datedimension]
		SET HolidayUSA = 'Memorial Day'
	FROM [dbo].[datedimension]
	WHERE DateKey IN 
		(
		SELECT
			MAX(DateKey)
		FROM [dbo].[datedimension]
		WHERE
			[MonthName] = 'May'
			AND [DayOfWeekUSA]  = 'Monday'
		GROUP BY
			[Year],
			[Month]
		)

	/*Labor Day - First Monday in September*/
	UPDATE [dbo].[datedimension]
		SET HolidayUSA = 'Labor Day'
	FROM [dbo].[datedimension]
	WHERE DateKey IN 
		(
		SELECT
			MIN(DateKey)
		FROM [dbo].[datedimension]
		WHERE
			[MonthName] = 'September'
			AND [DayOfWeekUSA] = 'Monday'
		GROUP BY
			[Year],
			[Month]
		)

	/*Valentine's Day*/
	UPDATE [dbo].[datedimension]
		SET HolidayUSA = 'Valentine''s Day'
	WHERE
		[Month] = 2 
		AND [DayOfMonth] = 14

	/*Saint Patrick's Day*/
	UPDATE [dbo].[datedimension]
		SET HolidayUSA = 'Saint Patrick''s Day'
	WHERE
		[Month] = 3
		AND [DayOfMonth] = 17

	/*Martin Luthor King Day - Third Monday in January starting in 1983*/
	UPDATE [dbo].[datedimension]
		SET HolidayUSA = 'Martin Luthor King Jr Day'
	WHERE
		[Month] = 1
		AND [DayOfWeekUSA]  = 'Monday'
		AND [Year] >= 1983
		AND DayOfWeekInMonth = 3

	/*President's Day - Third Monday in February*/
	UPDATE [dbo].[datedimension]
		SET HolidayUSA = 'President''s Day'
	WHERE
		[Month] = 2
		AND [DayOfWeekUSA] = 'Monday'
		AND DayOfWeekInMonth = 3

	/*Mother's Day - Second Sunday of May*/
	UPDATE [dbo].[datedimension]
		SET HolidayUSA = 'Mother''s Day'
	WHERE
		[Month] = 5
		AND [DayOfWeekUSA] = 'Sunday'
		AND DayOfWeekInMonth = 2

	/*Father's Day - Third Sunday of June*/
	UPDATE [dbo].[datedimension]
		SET HolidayUSA = 'Father''s Day'
	WHERE
		[Month] = 6
		AND [DayOfWeekUSA] = 'Sunday'
		AND DayOfWeekInMonth = 3

	/*Halloween 10/31*/
	UPDATE [dbo].[datedimension]
		SET HolidayUSA = 'Halloween'
	WHERE
		[Month] = 10
		AND [DayOfMonth] = 31

	/*Election Day - The first Tuesday after the first Monday in November*/
	BEGIN
		DECLARE @Holidays TABLE (ID INT IDENTITY(1,1), DateID int, Week TINYINT, YEAR CHAR(4), DAY CHAR(2))

		INSERT INTO @Holidays(DateID, [Year],[Day])
		SELECT
			DateKey,
			[Year],
			[DayOfMonth] 
		FROM [dbo].[datedimension]
		WHERE
			[Month] = 11
			AND [DayOfWeekUSA] = 'Monday'
		ORDER BY
			YEAR,
			DayOfMonth 

		DECLARE @CNTR INT, @POS INT, @STARTYEAR INT, @ENDYEAR INT, @MINDAY INT

		SELECT
			@CURRENTYEAR = MIN([Year])
			, @STARTYEAR = MIN([Year])
			, @ENDYEAR = MAX([Year])
		FROM @Holidays

		WHILE @CURRENTYEAR <= @ENDYEAR
		BEGIN
			SELECT @CNTR = COUNT([Year])
			FROM @Holidays
			WHERE [Year] = @CURRENTYEAR

			SET @POS = 1

			WHILE @POS <= @CNTR
			BEGIN
				SELECT @MINDAY = MIN(DAY)
				FROM @Holidays
				WHERE
					[Year] = @CURRENTYEAR
					AND [Week] IS NULL

				UPDATE @Holidays
					SET [Week] = @POS
				WHERE
					[Year] = @CURRENTYEAR
					AND [Day] = @MINDAY

				SELECT @POS = @POS + 1
			END

			SELECT @CURRENTYEAR = @CURRENTYEAR + 1
		END

		UPDATE [dbo].[datedimension]
			SET HolidayUSA  = 'Election Day'				
		FROM [dbo].[datedimension] DT
			JOIN @Holidays HL ON (HL.DateID + 1) = DT.DateKey
		WHERE
			[Week] = 1
	END
	
	UPDATE [dbo].[datedimension]
		SET IsHolidayUSA = CASE WHEN HolidayUSA  IS NULL THEN 0 WHEN HolidayUSA  IS NOT NULL THEN 1 END

/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
--END DATE DIMENSION
/*******************************************************************************************************************************************************/



/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
--CREATE TIME DIMENSION
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/

CREATE TABLE [dbo].[TimeDimension](
	[TimeKey] [int] NOT NULL,
	[TimeAltKey] [int] NOT NULL,
	[Time30] time  NOT NULL UNIQUE,
	[Hour30] [tinyint] NOT NULL,
	[MinuteNumber] [tinyint] NOT NULL,
	[SecondNumber] [tinyint] NOT NULL,
	[TimeInSecond] [int] NOT NULL,
	[HourlyBucket] varchar(15)not null,
	[DayTimeBucketGroupKey] int not null,
	[DayTimeBucket] varchar(100) not null
 CONSTRAINT [PK_TimeDimension] PRIMARY KEY CLUSTERED 
 (
 [TimeKey] ASC
 )
 WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
 ) 
 ON [PRIMARY]

 GO

 SET ANSI_PADDING OFF
 GO


/***** Create Stored procedure In Test_DW and Run SP To Fill Time Dimension with Values****/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FillTimeDimension]
as
BEGIN

--Specify Total Number of Hours You need to fill in Time Dimension
DECLARE @Size INTEGER
--iF @Size=32 THEN This will Fill values Upto 32:59 hr in Time Dimension 
Set @Size=23

DECLARE @hour INTEGER
DECLARE @minute INTEGER
DECLARE @second INTEGER
DECLARE @k INTEGER
DECLARE @TimeAltKey INTEGER
DECLARE @TimeInSeconds INTEGER
DECLARE @Time30 varchar(25)
DECLARE @Hour30 varchar(4)
DECLARE @Minute30 varchar(4)
DECLARE @Second30 varchar(4)
DECLARE @HourBucket varchar(15)
DECLARE @HourBucketGroupKey int
DECLARE @DayTimeBucket varchar(100)
DECLARE @DayTimeBucketGroupKey int

SET @hour = 0
SET @minute = 0
SET @second  = 0
SET @k  = 0
SET @TimeAltKey  = 0

WHILE(@hour<= @Size ) 
BEGIN
	
	if (@hour <10 )
		 begin
		 set @Hour30 = '0' + cast( @hour as varchar(10))
		 end
	else
		 begin
		 set @Hour30 = @hour 
		 end
	--Create Hour Bucket Value	 
	set @HourBucket= @Hour30+':00' +'-' +@Hour30+':59' 
	
	
	WHILE(@minute <= 59) 
	BEGIN
		WHILE(@second  <= 59)
		 BEGIN	
	 
		 set @TimeAltKey = @hour *10000 +@minute*100 +@second 
		 set @TimeInSeconds =@hour * 3600 + @minute *60 +@second 
		
		 If @minute  <10 
		   begin
		   set @Minute30  = '0' + cast ( @minute as varchar(10) )
		   end
		 else
		   begin
		   set @Minute30  = @minute 
		   end
		 
		 if @second   <10 
		   begin
		   set @Second30   = '0' + cast ( @second as varchar(10) )
		   end
		 else
		   begin
		   set @Second30  = @second 
		   end
	--Concatenate values for Time30	 
	set @Time30 = @Hour30 +':'+@Minute30 +':'+@Second30 
		 
    --DayTimeBucketGroupKey can be used in Sorting of DayTime Bucket In proper Order
    SELECT @DayTimeBucketGroupKey =
        CASE
			 WHEN (@TimeAltKey >= 00000 AND  @TimeAltKey <= 25959) THEN 0 
			 WHEN (@TimeAltKey >= 30000 AND  @TimeAltKey <= 65959) THEN 1 
             WHEN (@TimeAltKey >= 70000 AND @TimeAltKey <= 85959)  THEN 2
             WHEN (@TimeAltKey >= 90000 AND @TimeAltKey <= 115959) THEN 3
             WHEN (@TimeAltKey >= 120000 AND @TimeAltKey <= 135959)THEN 4
             WHEN (@TimeAltKey >= 140000 AND @TimeAltKey <= 155959)THEN 5
             WHEN (@TimeAltKey >= 50000 AND @TimeAltKey <= 175959) THEN 6 
             WHEN (@TimeAltKey >= 180000 AND @TimeAltKey <= 235959)THEN 7 
             WHEN (@TimeAltKey >= 240000) THEN  8
        END              
     --print @DayTimeBucketGroupKey
	-- DayTimeBucket Time Divided in Spcific Time Zone So Data can Be Grouped as per Bucket for Analyzing as per time of day
    SELECT @DayTimeBucket =
        CASE 
             WHEN (@TimeAltKey >= 00000 AND  @TimeAltKey <= 25959) THEN  'Late Night (00:00 AM To 02:59 AM)' 
             WHEN (@TimeAltKey >= 30000 AND  @TimeAltKey <= 65959) THEN  'Early Morning(03:00 AM To 6:59 AM)' 
             WHEN (@TimeAltKey >= 70000 AND @TimeAltKey <= 85959) THEN   'AM Peak (7:00 AM To 8:59 AM)'
             WHEN (@TimeAltKey >= 90000 AND @TimeAltKey <= 115959) THEN  'Mid Morning (9:00 AM To 11:59 AM)' 
             WHEN (@TimeAltKey >= 120000 AND @TimeAltKey <= 135959) THEN 'Lunch (12:00 PM To 13:59 PM)'
             WHEN (@TimeAltKey >= 140000 AND @TimeAltKey <= 155959)THEN  'Mid Afternoon (14:00 PM To 15:59 PM)'
             WHEN (@TimeAltKey >= 50000 AND @TimeAltKey <= 175959)THEN   'PM Peak (16:00 PM To 17:59 PM)' 
             WHEN (@TimeAltKey >= 180000 AND @TimeAltKey <= 235959)THEN  'Evening (18:00 PM To 23:59 PM)' 
             WHEN (@TimeAltKey >= 240000) THEN                           'Previous Day Late Night (24:00 PM to '+cast( @Size as varchar(10))  +':00 PM )'
         END 
      --    print   @DayTimeBucket    
	  
	    INSERT into  TimeDimension (TimeKey,TimeAltKey,[Time30] ,[Hour30] ,[MinuteNumber],[SecondNumber],[TimeInSecond],[HourlyBucket],DayTimeBucketGroupKey,DayTimeBucket) 
	    VALUES (@k,@TimeAltKey ,@Time30 ,@hour ,@minute,@Second , @TimeInSeconds,@HourBucket,@DayTimeBucketGroupKey,@DayTimeBucket )
	    
	    SET @second  = @second + 1		
	    SET @k = @k  + 1	
	END
		SET @minute = @minute + 1		
		SET @second = 0		
	END
	
	    SET @hour = @hour + 1
	    SET @minute =0
    END

END

Go

Exec [FillTimeDimension]
go

/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
--END TIME DIMENSION

/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
--Populate Orders Table
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/

DECLARE @loopstart int 
SET @loopstart = (SELECT MIN(Personid) from person)
DECLARE @loopend int
SET @loopend = (SELECT MAX(Personid) from person)

WHILE @loopstart<=@loopend
BEGIN
INSERT INTO orders (personid, ordertype, startdate, starttime)
SELECT @loopstart, 'admission', admissiondateonly, admissiontimeonly FROM visitinfo WHERE personid = @loopstart
INSERT INTO orders (personid, ordertype, startdate, starttime)
SELECT @loopstart, 'discharge', dischargedate, dischargetime FROM visitinfo WHERE personid = @loopstart

SET @loopstart = @loopstart+1
END

UPDATE orders
SET starttime = CASE
    WHEN CONVERT(TIME, starttime) BETWEEN '07:00:00' AND '11:00:00' THEN 
        DATEADD(MINUTE, -1 * (120 + FLOOR(RAND(CHECKSUM(NEWID())) * (280 - 120))), starttime)
    ELSE
        DATEADD(MINUTE, -1 * (15 + FLOOR(RAND(CHECKSUM(NEWID())) * (80 - 15))), starttime)
END;


/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
/*************************************          Relationships          *******************************************************************************/
/*******************************************************************************************************************************************************/

ALTER TABLE [dbo].orders   
ADD CONSTRAINT FK_ordertime FOREIGN KEY (starttime)     
    REFERENCES [dbo].[timedimension] (time30)     
    ON DELETE CASCADE    
    ON UPDATE CASCADE  

ALTER TABLE [dbo].[visitinfo]   
ADD CONSTRAINT FK_admissiontime FOREIGN KEY (admissiontimeonly)     
    REFERENCES [dbo].[timedimension] (time30)     
    ON DELETE CASCADE    
    ON UPDATE CASCADE  

ALTER TABLE [dbo].[visitinfo]   
ADD CONSTRAINT FK_admissiondate FOREIGN KEY (admissiondateonly)     
    REFERENCES [dbo].[datedimension] (date)     
 

ALTER TABLE [dbo].[visitinfo]   
ADD CONSTRAINT FK_dischargedate FOREIGN KEY (dischargedate)     
    REFERENCES [dbo].[datedimension] (date)     
    ON DELETE CASCADE    
    ON UPDATE CASCADE  


	
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/


/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
/*************************************          VALIDATION AREA          *******************************************************************************/
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
/*******************************************************************************************************************************************************/
--GET ALL THE TABLE DATA for audit

SELECT COUNT(*) as VisitCount FROM [dbo].[visitinfo]
SELECT COUNT(*) as orderscount FROM [dbo].[orders]
SELECT top 10 * FROM orders where ordertype = 'admission'
SELECT top 10 * FROM orders where ordertype = 'discharge'

SELECT COUNT(*) as datecount FROM [dbo].[datedimension]
SELECT * FROM [dbo].[datedimension] WHERE DateKey=(SELECT min(DateKey) FROM [dbo].[datedimension]);
SELECT * FROM [dbo].[datedimension] WHERE DateKey=(SELECT max(DateKey) FROM [dbo].[datedimension]);

SELECT COUNT(*) as timecount FROM [dbo].[TimeDimension]
SELECT * FROM [dbo].[TimeDimension] WHERE TimeKey=(SELECT min(TimeKey) FROM [dbo].[TimeDimension]);
SELECT * FROM [dbo].[TimeDimension] WHERE TimeKey=(SELECT max(TimeKey) FROM [dbo].[TimeDimension]);
SELECT TOP 10 * FROM [dbo].[person]
SELECT COUNT(*) as numberofpeople FROM [dbo].[person]


SELECT top 1000 *,CAST(ROUND(SUM(DATEDIFF(ss,visitstartdatetime,visitenddatetime)/86400.0),2) as decimal (3,2)) as los2 FROM visitinfo GROUP BY visitid, personid, visitstartdatetime, visitenddatetime, LOS, admissiondateonly, admissiontimeonly, dischargedate, dischargetime
SELECT * FROM visitinfo 