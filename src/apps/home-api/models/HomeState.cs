namespace home.api.models;

public class HomeState {
    public string DeviceId { get; set; }
    public DateTime Timestamp { get; set; }
    public double Temperature { get; set; }
    public double Humidity { get; set; }
    public double HeatIndex { get; set; }
}