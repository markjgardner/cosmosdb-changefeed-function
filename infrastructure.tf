provider "azurerm" {
}

variable "name" {
  default = "cosmostest"
}

variable "region" {
  default = "centralus"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.name}-rg"
  location = var.region
}

resource "azurerm_storage_account" "storage" {
  name                     = "${var.name}sa"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_application_insights" "insights" {
  name                = "${var.name}-ai"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  application_type    = "web"
}

resource "azurerm_app_service_plan" "plan" {
  name                = "${var.name}-asp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    tier = "Premium"
    size = "EP3"
  }
}

resource "azurerm_function_app" "app" {
  name                      = "${var.name}fn"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  app_service_plan_id       = azurerm_app_service_plan.plan.id
  storage_connection_string = azurerm_storage_account.storage.primary_connection_string
  version                   = "~2"

  site_config {
    always_on = "true"
  }

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.insights.instrumentation_key,
    CONNECTIONSTRING               = azurerm_cosmosdb_account.cosmos.connection_strings[0],
    DBNAME                         = azurerm_cosmosdb_sql_database.db.name,
    COLLECTIONNAME                 = azurerm_cosmosdb_sql_container.container.name,
    LEASECOLLECTIONNAME            = "${azurerm_cosmosdb_sql_container.container.name}Leases"
  }
}

resource "azurerm_cosmosdb_account" "cosmos" {
  name                = "${var.name}-cosmos"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.region
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "db" {
  name                = "${var.name}-db"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
}

resource "azurerm_cosmosdb_sql_container" "container" {
  name                = "Items"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  database_name       = azurerm_cosmosdb_sql_database.db.name
  partition_key_path  = "/_partitionKey"
}