# dcsazure_FabricWarehouse_to_FabricWarehouse_discovery_pl
## Delphix Compliance Services (DCS) for Azure - FabricWarehouse to FabricWarehouse Discovery Pipeline

This pipeline will perform automated sensitive data discovery on your Microsoft Fabric Warehouse.

### Prerequisites
1. Configure the hosted metadata database and associated Fabric Warehouse service.
2. Configure the DCS for Azure REST service.
3. Register an application in Azure for Fabric and obtain the necessary credentials. 
   NOTE: To obtain the necessary credentials, refer to Delphix documentation(https://dcs.delphix.com/docs/latest/delphixcomplianceservices-dcsforazure-2_onboarding#RegisteringaServicePrincipal-Process).
4. Configure the Fabric Warehouse linked service.

### Importing
There are several linked services that will need to be selected in order to perform the profiling and data discovery of your Fabric Warehouse instance.

These linked services types are needed for the following steps:

`Fabric Warehouse` (source) - Linked service associated with unmasked Fabric Warehouse data. This will be used for the following steps:
* `dcsazure_FabricWarehouse_to_FabricWarehouse_discovery_source_ds` (Fabric Warehouse Dataset)
* `dcsazure_FabricWarehouse_to_FabricWarehouse_discovery_df/Source1MillRowDataSampling` (DataFlow)

`Azure SQL` (metadata) - Linked service associated with your hosted metadata store. This will be used for the following steps:
* Update Discovery State (Stored Procedure Activity)
* Update Discovery State Failed (Stored Procedure Activity)
* Check If We Should Rediscover Data (If Condition Activity)
* `dcsazure_FabricWarehouse_to_FabricWarehouse_discovery_metadata_ds` (Azure SQL Database dataset)
* `dcsazure_FabricWarehouse_to_FabricWarehouse_discovery_df/MetadataStoreRead` (DataFlow)
* `dcsazure_FabricWarehouse_to_FabricWarehouse_discovery_df/WriteToMetadataStore` (DataFlow)

`REST` (DCS for Azure) - Linked service associated with calling DCS for Azure. This will be used for the following steps:
* `dcsazure_FabricWarehouse_to_FabricWarehouse_discovery_df` (DataFlow)

### How It Works

* Check If We Should Rediscover Data
  * If required, mark tables as undiscovered. This updates the metadata store to indicate that tables have not had their sensitive data discovered.
* Schema Discovery From Fabric Warehouse
  * Query metadata from Fabric Warehouse `INFORMATION_SCHEMA` to identify tables and columns in the Fabric Warehouse instance.
* Select Discovered Tables
  * After persisting the metadata to the metadata store, collect the list of discovered tables.
* For Each Discovered Table
  * Call the `dcsazure_FabricWarehouse_to_FabricWarehouse_discovery_df` data flow.

### Variables

If you have configured your database using the metadata store scripts, these variables will not need editing. If you have customized your metadata store, then these variables may need editing.

* `METADATA_SCHEMA` - Schema to be used for storing metadata in the self-hosted Azure SQL database (default `dbo`).
* `METADATA_RULESET_TABLE` - Table used for storing the discovered ruleset (default `discovered_ruleset`).
* `DATASET` - Identifier for data belonging to this pipeline in the metadata store (default `FABRIC_WH`).
* `METADATA_EVENT_PROCEDURE_NAME` - Name of the stored procedure capturing pipeline execution details (default `insert_adf_discovery_event`).
* `NUMBER_OF_ROWS_TO_PROFILE` - Number of rows selected for profiling; increasing this value may cause failures (default `1000`).

### Parameters

* `P_SOURCE_DATABASE` - String - The Fabric Warehouse that may contain sensitive data.
* `P_SOURCE_SCHEMA` - String - The schema within the above source database that may contain sensitive data.
* `P_REDISCOVER` - Boolean - Specifies if the data discovery dataflow should re-execute for previously discovered files that have not had their schema modified (default `true`).

### Known Issues

* Fabric warehouse Information schema does not provide row coutnt of tables.