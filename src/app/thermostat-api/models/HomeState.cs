namespace thermostat.api.models;

public class HomeState {
    public int temperature { get; set; }
    public int humidity { get; set; }
    public int heatIndex { get; set; }
}