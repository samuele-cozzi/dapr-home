using System;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace home_consumer
{
    public static class ACThermostatConsumer
    {
        [Function("ACThermostatConsumer")]
        public static void Run([EventHubTrigger("samples-workitems", Connection = "AzureEventHubConnectionString")] string[] input, FunctionContext context)
        {
            var logger = context.GetLogger("ACThermostatConsumer");
            logger.LogInformation($"First Event Hubs triggered message: {input[0]}");
        }
    }
}
