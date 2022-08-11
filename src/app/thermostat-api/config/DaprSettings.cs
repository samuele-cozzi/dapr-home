namespace thermostat.api.config;

public class DaprSettings
{
    public string StateStoreName { get; set; }
    public string StateHome { get; set; }
    public string PubSubName { get; set; }
    public string PubSubHomeEnvironmentTopicName { get; set; }

}