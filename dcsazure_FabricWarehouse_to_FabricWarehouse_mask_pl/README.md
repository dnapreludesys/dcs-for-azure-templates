# dcsazure_FabricWarehouse_to_FabricWarehouse_mask_pl
## Delphix Compliance Services (DCS) for Azure - Fabric Warehouse to Fabric Warehouse Masking Pipeline

This pipeline will perform masking of your Microsoft Fabric Warehouse.

### Prerequisites
1. Configure the hosted metadata database and associated Fabric Warehouse service.
2. Configure the DCS for Azure REST service.
3. Configure the Fabric Warehouse linked service.

### Importing
There are several linked services that will need to be selected in order to perform the masking of your Fabric Warehouse instance.

These linked service types are needed for the following steps:

`Fabric Warehouse` (source) - Linked service associated with Fabric source data. This will be used for the following steps:
* `dcsazure_FabricWarehouse_to_FabricWarehouse_mask_source_ds` (Dataset)
* `dcsazure_FabricWarehouse_to_FabricWarehouse_unfiltered_mask_df/Source` (DataFlow)
* `dcsazure_FabricWarehouse_to_FabricWarehouse_filtered_mask_df/Source` (DataFlow)

`Fabric Warehouse` (sink) - Linked service associated with Fabric sink data. This will be used for the following steps:
* `dcsazure_FabricWarehouse_to_FabricWarehouse_mask_sink_ds` (Dataset)
* `dcsazure_FabricWarehouse_to_FabricWarehouse_unfiltered_mask_df/Sink` (DataFlow)
* `dcsazure_FabricWarehouse_to_FabricWarehouse_filtered_mask_df/Sink` (DataFlow)

`Azure SQL` (metadata) - Linked service associated with your hosted metadata store. This will be used for the following steps:
* `Check For Conditional Masking` (If Condition activity)
* `If Use Copy Dataflow` (If Condition activity)
* `Check If We Should Reapply Mapping` (If Condition activity)
* `Configure Masked Status` (Script activity)
* `dcsazure_FabricWarehouse_to_FabricWarehouse_mask_metadata_ds` (Dataset)
* `dcsazure_FabricWarehouse_to_FabricWarehouse_unfiltered_mask_params_df/Ruleset` (DataFlow)
* `dcsazure_FabricWarehouse_to_FabricWarehouse_filtered_mask_params_df/Ruleset` (DataFlow)

`REST` (DCS for Azure) - Linked service associated with calling DCS for Azure. This will be used for the following steps:
* `dcsazure_FabricWarehouse_to_FabricWarehouse_unfiltered_mask_df` (DataFlow)
* `dcsazure_FabricWarehouse_to_FabricWarehouse_filtered_mask_df` (DataFlow)

### How It Works
* Check If We Should Reapply Mapping
  * If required, mark tables as unmapped in the metadata store.
* Select Tables That Require Masking
  * Identify tables that need masking and retrieve filter conditions for conditional masking.
* For Each Table To Mask:
  * Check if conditional masking is needed:
    * If no filter is required:
      * Generate masking parameters using `dcsazure_FabricWarehouse_to_FabricWarehouse_unfiltered_mask_params_df`.
      * Apply masking using `dcsazure_FabricWarehouse_to_FabricWarehouse_unfiltered_mask_df`.
    * If a filter is required:
      * Generate masking parameters using `dcsazure_FabricWarehouse_to_FabricWarehouse_filtered_mask_params_df`.
      * Apply conditional masking using `dcsazure_FabricWarehouse_to_FabricWarehouse_filtered_mask_df`.
  * Update the mapped status in the metadata store.
* Select Tables Without Required Masking
  * If configured, copy unmasked tables using `dcsazure_FabricWarehouse_to_FabricWarehouse_copy_df` or a copy activity.
* Check and set pipeline status
  * Update metadata to reflect the final masking and mapping state.
  * Set the overall pipeline status to success or failure.

### Variables

If you have configured your database using the metadata store scripts, these variables will not need editing. If you have customized your metadata store, then these variables may need modification.

* `METADATA_SCHEMA` - Schema to be used for storing metadata in Azure SQL (default `dbo`).
* `METADATA_RULESET_TABLE` - Table storing the discovered ruleset (default `discovered_ruleset`).
* `METADATA_SOURCE_TO_SINK_MAPPING_TABLE` - Table that defines where unmasked data lives and where masked data should be stored (default `adf_data_mapping`).
* `METADATA_ADF_TYPE_MAPPING_TABLE` - Table mapping dataset data types to ADF-required data types (default `adf_type_mapping`).
* `DATASET` - Identifier for this dataset in the metadata store (default `FABRIC`).
* `CONDITIONAL_MASKING_RESERVED_CHARACTER` - Character used for referencing key columns in filter conditions (default `%`).
* `TARGET_BATCH_SIZE` - Number of rows per batch (default `2000`).
* `METADATA_EVENT_PROCEDURE_NAME` - Stored procedure for logging masking events (default `insert_adf_masking_event`).

### Parameters

* `P_COPY_UNMASKED_TABLES` - Bool - Enables copying data from source to sink when no masking algorithms are applied (default `false`).
* `P_FAIL_ON_NONCONFORMANT_DATA` - Bool - Fails the pipeline if non-conformant data is encountered (default `true`).
* `P_SOURCE_DATABASE` - String - The Fabric Warehouse containing unmasked data.
* `P_SINK_DATABASE` - String - The Fabric Warehouse where masked data will be stored.
* `P_SOURCE_SCHEMA` - String - The schema within the source database that will be masked.
* `P_SINK_SCHEMA` - String - The schema within the sink database where masked data will be written.

### Known Issues

* Tables with varbinary datatype with fixed sizes like varbinary(64) are not supported.