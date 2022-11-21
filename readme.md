# CoD plays CoD

This is a simple script that tracks if cod does or does not crash during a session.    

Once CoD closes or crashes, it will send a status notification to the api running in cloudflare.  
  
The api will "simulate CoD" based on these notifications.    
If CoD did not crash it gets a point towards a streak. CoD can call in a UAV, Counter UAV, or Advanced UAV.

Similarily, if it crashes, its streak is over and CRASH will get a point towards its streak.

## Getting Started

Prereq: [autohotkey v2-beta](https://www.autohotkey.com/download/ahk-v2.exe)

1. Download the client code - the `client` folder containing two ahk scripts
2. Run the `main.ahk` script
3. Keep it running while you play cod