#SingleInstance force
#Include %A_ScriptDir%\logger.ahk

SetWorkingDir A_ScriptDir
logInfo("ready")

pointStreaks := [
    {requiredStreak: 3, name: "✈️ UAV"}, 
    {requiredStreak: 4, name: "🛩️ Counter UAV"}, 
    {requiredStreak: 12, name: "🛰️ Advanced UAV"}
]
state := {
   streak: 0,
   streakIndex: 1 
}
codIsRunning := false
codHasCrashed := false

loop {
    if (codIsRunning) {
        codIsRunning := WinExist("ahk_exe cod.exe") > 0
        codHasCrashed := WinExist("ahk_exe codCrashHandler.exe") > 0      
       
        if (codHasCrashed) {
            state := handleCrash(state)
        } else if (!codIsRunning) {
            state := handleClosing(state)
        } else {
            Sleep(5000)
        }
    } else {
        Sleep(30000)
        codIsRunning := WinExist("ahk_exe cod.exe") > 0
        if (codIsRunning) {
            logInfo("cod has started")
        }
    }
}

handleCrash(currentState) { 
    logInfo("cod has crashed")
    codIsRunning := false
    codHasCrashed := false
 
    TrayTip(Format("zamboni 🔫 COD"))
    
    logInfo("resetting streaks")
    newState := {streak: 0, streakIndex: 1}
    return newState
}

handleClosing(currentState){
    newStreak := currentState.streak + 1
    newStreakIndex := currentState.streakIndex
    nextRequiredStreak := pointStreaks[currentState.streakIndex].requiredStreak
    if (newStreak >= nextRequiredStreak) {
        streakName := pointStreaks[currentState.streakIndex].name
        TrayTip(Format("COD called in a {}", streakName))

        newStreakIndex := currentState.streakIndex + 1
        if (newStreakIndex > 3) {
            logInfo("streaks rolling over")
            newStreakIndex := 1
            newStreak := 0
        }
    }            
    logInfo(Format("{} - current streak: {}", "cod has closed without crashing", newStreak))
    newState := {streak: newStreak, streakIndex: newStreakIndex}
    return newState
}