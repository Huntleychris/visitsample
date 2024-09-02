  IF EXISTS (SELECT * FROM sys.databases WHERE name = 'healthcare')
BEGIN
    DROP DATABASE healthcare;
END

Create database healthcare;