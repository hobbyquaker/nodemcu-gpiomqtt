config = {}

-- WIFI
config.SSID = {}  
config.SSID["wifi-ssid"] = "wifi-passphrase"

-- MQTT
config.HOST = "172.16.23.100"  
config.PORT = 1883  
config.ID = node.chipid()
config.ENDPOINT = "esp1/"  

require("gpiomqtt")  
