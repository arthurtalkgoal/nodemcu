lighton=0
tmr.alarm(0,3000,1,function()
  if lighton==0 then 
      lighton=1 
      gpio.write(1,gpio.HIGH)
  else 
      lighton=0 
      gpio.write(1,gpio.LOW)
  end 
end)