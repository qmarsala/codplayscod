#SingleInstance force
#Include %A_ScriptDir%\logger.ahk

SetWorkingDir A_ScriptDir
logInfo("ready")

;todo: need persistance
pointStreak := 0
pointStreaks := [{requiredStreak: 3, name: "UAV"}, {requiredStreak: 4, name: "Counter UAV"}, {requiredStreak: 12, name: "Advanced UAV"}]
currentStreakIndex := 1
codIsRunning := false
codHasCrashed := false

;todo: refac
loop {
    if (!codIsRunning AND WinExist("ahk_exe cod.exe")){
        logInfo("cod has started")
        codIsRunning := true
    }

    if (codIsRunning AND WinExist("ahk_exe codCrashHandler.exe")){
        logInfo("cod has crashed")
        codIsRunning := false
        TrayTip(Format("COD was killed by a zamboni"))
        resetStreaks()
    }

    if (codIsRunning AND WinExist("ahk_exe cod.exe") < 1){
        codIsRunning := false
        pointStreak := pointStreak + 1
        if (pointStreak >= pointStreaks[currentStreakIndex].requiredStreak){
            TrayTip(Format("COD called in a {}", pointStreaks[currentStreakIndex].name))
            currentStreakIndex := currentStreakIndex + 1
            if (currentStreakIndex > 3) {
                resetStreaks()
            }
        }
        logInfo(Format("{} current streak: {}", "cod has closed without crashing", pointStreak))
    }

    Sleep(1000)
}

resetStreaks(){
    logInfo("resetting streaks")
    currentStreakIndex := 1
    pointStreak := 0
}