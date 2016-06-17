# nodemcu
NodeMCU lua samples

Install WiFi
======

1. Copy ***config.sample.lua*** to ***config.lua***
2. Update ***config.lua*** to your Wifi authentication
2. Update ***init.lua*** to include your module - ***dofile("<your module>")***


LED
======

Turning on and off LED


MQTT BATCH
======

When message length reach certain bytes, it will push the json data to the broker server.

***Install***

Update the ***did*** and ***broker*** variables for device id and broker url.


License
======

This project is under Apache License Version 2.0
