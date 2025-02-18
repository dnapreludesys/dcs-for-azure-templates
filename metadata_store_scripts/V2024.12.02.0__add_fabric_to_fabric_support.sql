INSERT INTO [dbo].[adf_type_mapping]
           ([dataset]
           ,[dataset_type]
           ,[adf_type])
     VALUES
           ('FABRIC','bigint','long'),
		   ('FABRIC','date','date'),
		   ('FABRIC','decimal','decimal'),
		   ('FABRIC','float','float'),
		   ('FABRIC','int','integer'),
		   ('FABRIC','varchar','string')
GO