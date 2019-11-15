using System;
using System.Collections.Generic;
using Microsoft.Azure.Documents;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace ChangeFeedSample
{
    public static class ChangeFeedFunction
    {
        [FunctionName("ChangeFeedFunction")]
        public static void Run([CosmosDBTrigger(
            databaseName: "%DBNAME%",
            collectionName: "%COLLECTIONNAME%",
            ConnectionStringSetting = "CONNECTIONSTRING",
            LeaseCollectionName = "%LEASECOLLECTIONNAME%",
            CreateLeaseCollectionIfNotExists = true,
            FeedPollDelay = 250,
            StartFromBeginning = true)]IReadOnlyList<Document> input, ILogger log)
        {
            if (input != null && input.Count > 0)
            {
                log.LogInformation("Documents modified " + input.Count);
            }
        }
    }
}
