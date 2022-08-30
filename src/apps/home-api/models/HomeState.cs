namespace home.api.models;

public class HomeState {
    public string DeviceId { get; set; }
    public DateTime Timestamp { get; set; }
    public double Temperature { get; set; }
    public double Humidity { get; set; }
    public double HeatIndex { get; set; }

    public bool acPower { get; set; }
    public double acTemp { get; set; }
    public string acMode { get; set; }
    public int acFan { get; set; }
    public int TargetHumidity { get; set; }
    public int TargetTemperature { get; set; }
    public int TargetHeatIndex { get; set; }
}