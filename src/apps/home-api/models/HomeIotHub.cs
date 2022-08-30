namespace home.api.models;

public class HomeIotHub {
    public int msgCount { get; set; }
    public int temperature { get; set; }
    public int humidity { get; set; }
    public int heatIndex { get; set; }
    public int factor { get; set; }
    public bool acPower { get; set; }
    public int acTemp { get; set; }
    public int acMode { get; set; }
    public int acFan { get; set; }
    public int targetHumidity { get; set; }
    public int targetTemperature { get; set; }
    public int targetHeatIndex { get; set; }
}