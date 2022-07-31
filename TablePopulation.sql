Truncate Table [dbo].[person]

DECLARE @loopincrement INT 
DECLARE @firstinitial CHAR(1)
DECLARE @lastinitial CHAR(1)
SET @loopincrement = 0
SET @firstinitial = ''
SET @lastinitial = ''
DECLARE @start DATETIME = '19230101'
DECLARE @end DATETIME = '20170201'
DECLARE @gap INT = DATEDIFF(DD,@start,@end)
DECLARE @dateModified Date = '01/01/01'

WHILE @loopincrement < 5000
BEGIN 
SET @loopincrement = @loopincrement +1
SET @firstinitial = CHAR(cast((90 - 65) * rand() + 65 AS INTEGER)) 
SET @lastinitial = CHAR(cast((90 - 65) * rand() + 65 AS INTEGER)) 
SET @dateModified = DATEADD(DD,@gap*RAND(),@start)
PRINT CONVERT(VARCHAR(5),@loopincrement)+' '+@lastinitial+', '+ @firstinitial +' ' +CONVERT(VArchar(10),@datemodified)
--PRINT @firstinitial
INSERT INTO dbo.person (lastinitial, firstinitial, DOB)
VALUES (@lastinitial, @firstinitial, @dateModified)
END

SELECT TOP 10 * FROM [dbo].[person]