using System;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace home_consumer
{
    public static class ACThermostatConsumer
    {
        [Function("ACThermostatConsumer")]
        public static void Run([EventHubTrigger("samples-workitems", Connection = "AzureEventHubConnectionString")] string[] input, 
            [DaprInvoke(AppId = "capp-home-api", MethodName = "home", HttpVerb = "post")] IAsyncCollector<InvokeMethodParameters> output,
            FunctionContext context)
        {
            var logger = context.GetLogger("ACThermostatConsumer");
            logger.LogInformation($"First Event Hubs triggered message: {input[0]}");

            var outputContent = new InvokeMethodParameters
            {
                Body = input[0]
            };

            await output.AddAsync(outputContent);
        }
    }
}
