# CoD plays CoD

This is a simple script that tracks if cod does or does not crash during a session.    

Once CoD closes or crashes, it will send a status notification to the api running in cloudflare.  
  
The api will "simulate CoD" based on these notifications.    
If CoD did not crash it gets a point towards a streak. CoD can call in a UAV, Counter UAV, or Advanced UAV.

Similarily, if it crashes, its streak is over and CRASH will get a point towards its streak.