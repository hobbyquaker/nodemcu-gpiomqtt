local module = {}  
m = nil

config.GPIO = {} 
-- Relays
config.GPIO[0] = "OUTPUT"
config.GPIO[1] = "OUTPUT"
config.GPIO[2] = "OUTPUT"
config.GPIO[3] = "OUTPUT"

-- GPIO4 is used as MQTT connection indicator (onboard LED)

-- Buttons
config.GPIO[5] = "INPUT"
config.GPIO[6] = "INPUT"
config.GPIO[7] = "INPUT"


function str_split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {} ; i = 1
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end


local function mqtt_start()  
    m = mqtt.Client(config.ID, 120)
    m:lwt(config.ENDPOINT .. "connected", "0", 0, true)

    for k,v in pairs(config.GPIO) do
        local nr = tonumber(k)
        if (v == "INPUT") then
         
            gpio.trig(nr, "both", function()
                tmr.alarm(nr-1, 25, tmr.ALARM_SINGLE, function () 
                    level = gpio.read(nr)
                    print("MQTT > " .. config.ENDPOINT .. "status/gpio/" .. nr .. " " .. level)
                    m:publish(config.ENDPOINT .. "status/gpio/" .. nr, level, 0, 1)
                end)
            end)

        end    
    end

    -- register message callback beforehand
    m:on("message", function(conn, topic, data) 
      if data ~= nil then
        print("MQTT < " .. topic .. " " .. data)
        
        numGpio = tonumber(str_split(topic, "/")[4])
       
        if (config.GPIO[numGpio] ~= "OUTPUT") then
            print("GPIO" .. numGpio .. " not configured as output!")
            return
        end
        
        timeout = nil

        if string.match(data, "{") then
            local success, t = pcall(cjson.decode, data);
            if (not success) then
                print("invalid json " .. t)
                value = data
            else
                -- t contains a valid json object
                value = t["val"]
                timeout = t["timeout"]
            end
        else
            value = data
        end
        if (value == true or value == 1 or value == "1" or value == "true") then
            gpio.write(numGpio, gpio.HIGH)
            print("MQTT > " .. config.ENDPOINT .. "status/gpio/" .. numGpio .. " 1")
            m:publish(config.ENDPOINT .. "status/gpio/" .. numGpio, 1, 0, 1)
    
            n = gpio.LOW
        elseif (value ~= nil) then
            gpio.write(numGpio, gpio.LOW) 
            print("MQTT > " .. config.ENDPOINT .. "status/gpio/" .. numGpio .. " 0")
            m:publish(config.ENDPOINT .. "status/gpio/" .. numGpio, 0, 0, 1)
            n = gpio.HIGH
        else
            n = nil
        end
        if (timeout ~= nil and n ~= nil) then
            tmr.alarm(numGpio, timeout, tmr.ALARM_SINGLE, function ()
                gpio.write(numGpio, n)
                print("MQTT > " .. config.ENDPOINT .. "status/gpio/" .. numGpio .. " " .. n)
                m:publish(config.ENDPOINT .. "status/gpio/" .. numGpio, n, 0, 1)
            end)
        end
        
      end
    end)
    
    m:on("connect", function()
        print("MQTT connected")
        gpio.write(4, gpio.LOW)     
        m:subscribe(config.ENDPOINT .. "set/gpio/+", 0, function(conn)
            print("MQTT subscribed "  .. config.ENDPOINT .. "set/gpio/+")
        end)
        m:publish(config.ENDPOINT .. "connected", "2", 0, 1)
      
    end)

    m:on("offline", function() 
        print("MQTT offline")
        gpio.write(4, gpio.HIGH)     
    end)

    -- Connect to broker
    m:connect(config.HOST, config.PORT, 0, 1) 
end


local function wifi_wait_ip()  
  if wifi.sta.getip()== nil then
    print("IP unavailable, Waiting...")
  else
    tmr.stop(1)
    print("\n====================================")
    print("ESP8266 mode is: " .. wifi.getmode())
    print("MAC address is: " .. wifi.ap.getmac())
    print("IP is "..wifi.sta.getip())
    print("====================================")
    mqtt_start()
  end
end


local function wifi_start(list_aps)  
    if list_aps then
        for key,value in pairs(list_aps) do
            if config.SSID and config.SSID[key] then
                wifi.setmode(wifi.STATION);
                wifi.sta.config(key,config.SSID[key])
                wifi.sta.connect()
                print("Connecting to " .. key .. " ...")
                --config.SSID = nil  -- can save memory
                tmr.alarm(1, 2500, 1, wifi_wait_ip)
            end
        end
    else
        print("Error getting AP list")
    end
end


print("Configuring GPIOs ...")
for k,v in pairs(config.GPIO) do
    nr = tonumber(k)
    if (v == "INPUT") then
        gpio.mode(nr, gpio.INT, gpio.PULLUP)
    elseif (v == "OUTPUT") then
        gpio.mode(nr, gpio.OUTPUT)
        gpio.write(nr, gpio.LOW) 
    end    
end

gpio.mode(4, gpio.OUTPUT)
gpio.write(4, gpio.HIGH)     

print("Configuring Wifi ...")
wifi.setmode(wifi.STATION);
wifi.sta.getap(wifi_start)

return module  
