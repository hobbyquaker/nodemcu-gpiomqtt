# nodemcu-gpiomqtt

> lua script for the ESP8266 to connect GPIOs to MQTT

I build this to control a 4 channel relay board and receive button presses via MQTT.

## Documentation

Input pins are debounced with a 25ms timer, MQTT topics follow the [mqtt-smarthome architecture](https://github.com/mqtt-smarthome/mqtt-smarthome). Changes on the input pins will be published to e.g. `esp1/status/gpio/2` with payload `1` for high and payload `0` for low.

You can just publish `0`, `1`, `true` or `false` to e.g. `esp1/set/gpio/3` to switch an output pin. It's also possible to publish a JSON, then the pin is set to the value of the attribute `val`  
Output pins can also be set with a timeout, if you publish `{"val": 1, "timeout": 5000}` to `esp1/set/gpio/3` the gpio 3 will go to high and return to low after 5000ms


![breadboard](images/breadboard.jpg "Breadboard")


## Credits

Used [this article from foobarflies](http://www.foobarflies.io/a-simple-connected-object-with-nodemcu-and-mqtt/) as a starting point.


## License

MIT
