var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddHealthChecks();
builder.Services.AddControllers().AddDapr();
//builder.Host.UseSerilog();

builder.Services.Configure<DaprSettings>(builder.Configuration.GetSection(nameof(DaprSettings)));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

//app.UseHttpsRedirection();
app.MapHealthChecks("/");
app.UseCloudEvents();
app.MapControllers();
app.MapSubscribeHandler();


app.MapGet("/home", async (IOptions<DaprSettings> daprSettings) =>
{
    var daprClient = new DaprClientBuilder().Build();
    var result = await daprClient.GetStateAsync<HomeState>(
        daprSettings.Value.StateStoreName, daprSettings.Value.StateHome
    );
    return result;
})
.WithName("GetHome");

app.MapPost("/home", async (HomeState home,IOptions<DaprSettings> daprSettings, ILoggerFactory loggerFactory) =>
{
    var logger = loggerFactory.CreateLogger("Start");
    logger.LogInformation(JsonSerializer.Serialize(home));

    var daprClient = new DaprClientBuilder().Build();

    await daprClient.SaveStateAsync<HomeState>(
        daprSettings.Value.StateStoreName, daprSettings.Value.StateHome, home
    );     
})
.WithName("PostHome");

app.MapPost("/iothub",  async (HomeIotHub home, IOptions<DaprSettings> daprSettings, ILoggerFactory loggerFactory, HttpContext context) =>
{
    var logger = loggerFactory.CreateLogger("Start");
    logger.LogInformation(JsonSerializer.Serialize(home));

    HomeState stateHome = new HomeState()
    {
        DeviceId = context.Request.Headers["iothub-connection-device-id"],
        Timestamp = DateTime.Now,
        HeatIndex = (double) home.heatIndex / home.factor,
        Humidity = (double) home.humidity / home.factor,
        Temperature = (double) home.temperature / home.factor,
        TargetHeatIndex = home.targetHeatIndex,
        TargetHumidity = home.targetHumidity,
        TargetTemperature = home.targetTemperature,
        acPower = home.acPower,
        acMode = home.acMode.ToString(),
        acTemp = home.acTemp,
        acFan = home.acFan
    };

    logger.LogInformation(JsonSerializer.Serialize(stateHome));
    
    try {
        var daprClient = new DaprClientBuilder().Build();

        await daprClient.SaveStateAsync<HomeState>(
            daprSettings.Value.StateStoreName, daprSettings.Value.StateHome, stateHome
        );   

        await daprClient.SaveStateAsync<HomeState>(
            daprSettings.Value.StateStoreName, 
            $"history/{DateTime.Now.Year}/{DateTime.Now.Month}/{DateTime.Now.Day}/{DateTime.Now.ToString("HH:mm:ss")}-{daprSettings.Value.StateHome}", 
            stateHome
        ); 
    }
    catch (Exception e){
        logger.LogError(e, e.Message);
    }


    using( HttpClient client = new HttpClient() ){
        var response = await client.PostAsJsonAsync<List<HomeState>>(daprSettings.Value.PowerBIUrl, new List<HomeState>(){ stateHome });
        logger.LogInformation($"{response.StatusCode}");
    }
        
})
.WithName("PostIotHome");

app.Run();