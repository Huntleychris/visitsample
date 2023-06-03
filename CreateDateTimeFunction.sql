CREATE FUNCTION [GenerateRandomDateTime]
    (
      @StartDate DateTime,
      @EndDate DATETIME 
    )
RETURNS DATETIME
AS BEGIN
  
	--DECLARE VARIABLES
    DECLARE @RandomDateTime DATETIME
    DECLARE @RandomNumber FLOAT
    DECLARE @IntervalInDays INT ;
    
    SET @IntervalInDays = CONVERT(INT, @EndDate - @StartDate)
    SET @RandomNumber = ( SELECT    [RandNumber]
                          FROM      [RandNumberView]
                        )
                        
    SELECT  @RandomDateTime = DATEADD(ss, @RandomNumber * 86400,
                                      DATEADD(dd,
                                              @RandomNumber * @IntervalInDays,
                                              @StartDate))

	
    RETURN @RandomDateTime

  
   END
GO

CREATE VIEW [RandNumberView]
AS  SELECT  RAND() AS [RandNumber]

GO