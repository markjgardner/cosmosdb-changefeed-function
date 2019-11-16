# High Throughput Event Processing with CosmosDB and Azure Functions

This repo contains a reference example for using the [CosmosDB change feed](https://docs.microsoft.com/en-us/azure/cosmos-db/change-feed) to receive and process a high volume of concurrent events. Each event is written as a document to the CosmosDB instance. An azure function subscribed to the container receives and processes the events. Important characteristics of this model:

* Exactly-once processing of received events
* ChangeFeedFunction scales (via the [change feed processor](https://github.com/Azure/azure-documentdb-changefeedprocessor-dotnet/)) to one instance per physical partition
* InsertItem generates a random partition key for each new event

## How to use this repo

The infrastructure needed to run the example function is provided in ```infrastructure.tf```. To build the test environment ensure you are logged into your azure subscription via ```az login``` and then run ```terraform apply```.

Once the CosmosDB instance is provisioned you should force the instance to provision several physical partitions by manually scaling the RUs for the instance to a high number (e.g. 20,000). Once the change is succesfully applied (this can take several minutes) you can scale back down to a lower number. Physical partitions are never removed from an instance once allocated. Be aware that leaving the instance scaled to a high RU will significantly increase the cost of the instance over time.

Next deploy the function app to the created instance, the ChangeFeedFunction will automatically create the lease partition within the collection and start listening for new events.

The easiest way to generate a high volume of traffic is using a web load testing platform such as [loader.io](https://loader.io). You can use the included [curl script](./test.curl) as a template for your load test.

### Additional Notes

After a few test runs you will have a fairly large number of documents in the database. Because the ```StartFromBeginning``` flag is set on the changefeed trigger you can force the function to reprocess the entire Items collection by deleting the ItemsLeases collection. To get a true measure of the processing time you should manually scale out the function app before doing this, otherwise your results will also include the overhead of the scaling operations which are not in scope for this exercise. To test the impact of scaling events on your real-time process you should create a loadtest that models the desired increase in volume over time.