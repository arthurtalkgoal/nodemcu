-- update did and broker ---
did="<your device id>"
broker = "<the broker url e.g. sensor.mysite.com>"

outpin=2                       -- Select output pin - GPIO0 
gpio.mode(outpin,gpio.OUTPUT)

inpin=1                        -- Select input pin - GPIO12  
gpio.mode(inpin,gpio.INT,gpio.PULLUP)  -- attach interrupt to inpin

stat="OFF"
connecting=true
mbroking=true
msgs=""
vals=""

-- init mqtt client with keepalive timer 120sec
m = mqtt.Client(wifi.sta.getmac(), 120)
m:lwt("/lwt", wifi.sta.getmac(), 0, 0)

tmr_broker=0
tmr_motion=1
tmr_nomotion=2
motion_cnt=0
inInt=false
last_read=gpio.LOW

--nomotion_cnt=0

function isready()
  return ((not mbroking) and (not connecting))
end

m:on("connect", function(conn) 
  print("connected+++++++++++++++++++++++")
  mbroking=false
end)

-- on publish message receive event
m:on("message", function(conn, topic, data) 
  print(topic .. ":" ) 
  if data ~= nil then
    print(data)
  end
end)

m:on("offline", function(con) 
  print ("reconnecting...") 
  print(node.heap())
  mbroking=true
         
  tmr.alarm(1, 10000, 0, function()
    m:connect(broker, 1883, 0)
  end)
end)

function pub_stat(s)
  local data = string.format("{\"did\":\"%s\",\"v\":\"%s\",\"c\":%s}",did,s,tmr.now()) 
  --table.insert(msgs, data)
  msgs=data
  print("gonna pub")
  print(node.heap())
  pub_broker()
end


function motion()
    if not inInt then                   -- wait initialize
        return
    end
    last_read = gpio.read(inpin)
    if (last_read == gpio.HIGH) then
    
      stat = 1
      gpio.write(outpin,gpio.HIGH)  -- Led ON - Motion detected
      local s = string.format("%s:%s", stat, tmr.now()/1000)
      print(s)
      if vals~="" then
        vals = vals..","..s
      else
        vals = s
      end
        
      print(string.len(vals) )
      if (string.len(vals) > 300) or (node.heap() < 5000) then
       
        pub_stat(vals)
        vals=""
      end
    else
      stat = 0
      gpio.write(outpin,gpio.LOW)  -- Led ON - Motion detected
    end
    
end

m:connect(broker, 1883, 0)

function pub_broker()
       if(isready())
       then 
        
         msg = msgs
         msgs = ""
         print("msg publishing -------------" .. msg)
         m:publish("hello/office", msg,0,0,   function(conn) 
            print("sent")
         end)
       end

end

gpio.trig(inpin,"both", motion)
tmr.alarm(tmr_motion, 10000,0, function()
  tmr.stop(tmr_motion)
  print("initialized in")
 last_read=gpio.read(inpin)
  inInt=true
end)
