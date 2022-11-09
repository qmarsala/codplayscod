#SingleInstance force
#Include %A_ScriptDir%\logger.ahk

SetWorkingDir A_ScriptDir

pointStreaks := [
{requiredStreak: 3, name: "✈️ UAV"},
{requiredStreak: 4, name: "🛩️ Counter UAV"},
{requiredStreak: 12, name: "🛰️ Advanced UAV"},
{requiredStreak: 30, name: "☢️ Tactical Nuke"}
]
state := {
    streak: 0,
    streakIndex: 1,
    isAlive: true
}
logInfo(Format("ready - streak:{1} streakIndex:{2}", state.streak, state.streakIndex))

codIsRunning := false
loop {
    monitorResult = monitorCod(codIsRunning, state)
    codIsRunning := monitorResult.codIsRunning
    if (codIsRunning) {
        sleepSeconds := 3
    } else {
        sleepSeconds := 30
        state := processState(monitorResult.state)
    }
    Sleep(sleepSeconds * 1000)
}

monitorCod(isRunning, currentState) {
    if (isRunning) {
        isRunning := WinExist("ahk_exe cod.exe") > 0
        hasCrashed := WinExist("ahk_exe codCrashHandler.exe") > 0
        if (isRunning AND !hasCrashed) {
            return {codIsRunning: isRunning, state: currentState}
        }

        if (hasCrashed) {
            newState := handleCrash(currentState)
        } else if (!isRunning) {
            newState := handleClosing(currentState)
        }
    } else {
        isRunning := WinExist("ahk_exe cod.exe") > 0
        if (isRunning) {
            logInfo("cod has started")
        }
    }

    return {codIsRunning: isRunning, state: newState}
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
            callInStreak(pointStreaks[currentState.streakIndex].name)
            newStreakIndex := currentState.streakIndex + 1
            if (newStreakIndex > 4) {
                logInfo("rolling streak index")
                newStreakIndex := 1
            }
        }
    } else {
        generateKillFeed(currentState.streak)
        newStreak := 0
        newStreakIndex := 1
    }

    newState := {streak: newStreak, streakIndex: newStreakIndex, isAlive: true}
    logInfo(Format("streak:{1} streakIndex:{2}", newStreak, newStreakIndex))
    return newState
}

callInStreak(name){
    msg := Format("COD called in a {}", name)
    logInfo(msg)
    TrayTip(msg)
}

generateKillFeed(currentStreak) {
    enemies := ["zamboni", "badcode", "sofakinggoated", "Jev"]
    nextStreak := pointStreaks[currentState.streakIndex].requiredStreak
    baseMsg := Format("{} 🔫 COD", enemies[Random(1,4)])
    msg := currentStreak + 1 >= nextStreak ? Format("(buzzkill) {}", baseMsg) : baseMsg
    logInfo(msg)
    TrayTip(msg)
}