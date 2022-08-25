var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddHealthChecks();
builder.Services.AddControllers().AddDapr();
builder.Host.UseSerilog();

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

app.MapPost("/iothub",  async (object home,IOptions<DaprSettings> daprSettings, ILoggerFactory loggerFactory) =>
{
    var logger = loggerFactory.CreateLogger("Start");
    logger.LogInformation(JsonSerializer.Serialize(home));
        
})
.WithName("PostIotHome");

app.Run();