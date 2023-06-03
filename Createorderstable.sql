CREATE TABLE 
orders 
(orderid int identity (1000000,1) not null primary key, 
personid int ,
ordertype varchar(100),
startdate date,
starttime time
)