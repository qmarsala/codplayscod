#SingleInstance force
#Include %A_ScriptDir%\logger.ahk

SetWorkingDir A_ScriptDir

pointStreaks := [
{requiredStreak: 3, name: "✈️ UAV"},
{requiredStreak: 4, name: "🛩️ Counter UAV"},
{requiredStreak: 12, name: "🛰️ Advanced UAV"}
]
state := {
    streak: 0,
    streakIndex: 1,
    isAlive: true
}
logInfo(Format("ready - streak:{1} streakIndex:{2}", state.streak, state.streakIndex))

codIsRunning := false
codHasCrashed := false
loop {
    if (codIsRunning) {
        codIsRunning := WinExist("ahk_exe cod.exe") > 0
        codHasCrashed := WinExist("ahk_exe codCrashHandler.exe") > 0

        if (codIsRunning AND !codHasCrashed){
            Sleep(5000)
            continue
        }

        if (codHasCrashed) {
            state := handleCrash(state)
        } else if (!codIsRunning) {
            state := handleClosing(state)
        }
        state := processState(state)
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
    newState := {streak: currentState.streak, streakIndex: currentState.streakIndex, isAlive: false}
    return newState
}

handleClosing(currentState) {
    logInfo("cod has closed without crashing")
    newState := {streak: currentState.streak, streakIndex: currentState.streakIndex, isAlive: true}
    return newState
}

processState(currentState) {
    if (currentState.isAlive) {
        newStreak := currentState.streak + 1
        newStreakIndex := currentState.streakIndex
        nextStreak := pointStreaks[currentState.streakIndex]
        if (newStreak >= nextStreak.requiredStreak) {
            logInfo("COD aquired a streak")
            callInStreak(pointStreaks[currentState.streakIndex].name)
            newStreakIndex := currentState.streakIndex + 1
            if (newStreakIndex > 3) {
                logInfo("rolling streak index")
                newStreakIndex := 1
            }
        }
    } else {
        logInfo("COD died")
        TrayTip(Format("zamboni 🔫 COD"))
        newStreak := 0
        newStreakIndex := 1
    }

    newState := {streak: newStreak, streakIndex: newStreakIndex, isAlive: true}
    logInfo(Format("streak:{1} streakIndex:{2}", newStreak, newStreakIndex))
    return newState
}

callInStreak(name){
    TrayTip(Format("COD called in a {}", name))
}