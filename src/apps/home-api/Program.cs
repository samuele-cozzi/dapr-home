var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddHealthChecks();
builder.Services.AddControllers().AddDapr();
//builder.Host.UseSerilog();

builder.Services.Configure<DaprSettings>(builder.Configuration.GetSection(nameof(DaprSettings)));

builder.Services.AddScoped<IConfigurationService, ConfigurationService>();
builder.Services.AddScoped<IAnalysisService, AnalysisService>();
builder.Services.AddScoped<IHomeService, HomeServices>();

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


app.MapGet("/home", async (IOptions<DaprSettings> daprSettings, IHomeService service) =>
{
    return service.Get();
})
.WithName("GetHome");

app.MapPost("/configuration", async (HomeConfiguration conf, IConfigurationService service) =>
{
    service.Save(conf);
})
.WithName("PostConfiguration");

app.MapPost("/thermostat", async (Thermostat thermostat, IHomeService service) =>
{
    service.SaveThermostat(thermostat);
})
.WithName("PostThermostat");

app.MapPost("/airConditioner", async (AirConditioner airConditioner, IHomeService service) =>
{
    service.SaveAirConditioner(airConditioner);
})
.WithName("PostAirConditioner");

app.MapPost("/iothub",  async (HomeIotHub iot, HttpContext context, IHomeService service, IAnalysisService aservice) =>
{
    service.SaveThermostat(new Thermostat(){
        deviceId = context.Request.Headers["iothub-connection-device-id"],
        temperature = (double) iot.temperature / iot.factor,
        humidity = (double) iot.humidity / iot.factor,
        heatIndex = (double) iot.heatIndex / iot.factor
    });
    
    var home = await service.Get();

    service.SaveArchive(home);
    aservice.Save(home);        
})
.WithName("PostIotHome");

app.Run();