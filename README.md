# nodemcu-gpiomqtt

> lua script for the ESP8266 to connect GPIOs to MQTT

I build this to control a 4 channel relay board and receive button presses via MQTT.

## Docs

Input pins are debounced with a 25ms timer, MQTT topics follow the [mqtt-smarthome architecture](https://github.com/mqtt-smarthome/mqtt-smarthome)

Output pins can be set with a timeout, if you e.g. publish {"val": 1, "timeout": 5000} to esp1/set/gpio/3 the gpio 3 will go to high and return to low after 5000ms


![breadboard](images/breadboard.jpg "Breadboard")


## Credits

Used [this article from foobarflies](http://www.foobarflies.io/a-simple-connected-object-with-nodemcu-and-mqtt/) as a starting point.


## License

MIT
