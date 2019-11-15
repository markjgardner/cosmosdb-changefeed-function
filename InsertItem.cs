using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace cosmosdb_changefeed_function
{
    public static class InsertItem
    {
        private static readonly Random _random = new Random();

        [FunctionName("InsertItem")]
        [return: CosmosDB( databaseName: "%DBNAME%",
            collectionName: "%COLLECTIONNAME%",
            ConnectionStringSetting = "CONNECTIONSTRING",
            CreateIfNotExists = true)]
        public static async Task<dynamic> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            return JsonConvert.DeserializeObject<doc>(requestBody);
        }

        class doc{
            public int _partitionKey { 
                get{
                    return _random.Next(3000);
                }
            }
            public string data1 { get; set; }
            public string data2 { get; set; }
            public string data3 { get; set; }
            public string data4 { get; set; }

        }
    }
}
