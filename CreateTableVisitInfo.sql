DROP TABLE IF EXISTS [dbo].[visitinfo]

CREATE TABLE 
visitinfo 
(visitid int identity (1000000,1) not null primary key, 
personid int,
visitstartdatetime datetime, 
visitenddatetime datetime)

SELECT * FROM [dbo].[visitinfo]