#SingleInstance force
#Include %A_ScriptDir%\logger.ahk
#Include %A_ScriptDir%\game.ahk

SetWorkingDir A_ScriptDir

state := loadState()
logInfo(Format("ready - codStreak:{} codStreakIndex:{} | crashStreak:{} crashStreakIndex:{}", state.codStreak, state.codStreakIndex, state.crashStreak, state.crashStreakIndex))

codIsRunning := false
loop {
    monitorResult := monitorCod(codIsRunning)
    codIsRunning := monitorResult.codIsRunning
    codIsClosing := monitorResult.codIsClosing
    if (codIsClosing) {
        didCrash := monitorResult.codHasCrashed
        result := processState(state, didCrash)
        state := result.newState
        saveState(state)
        sendNotifications(result.messages)
    }
    sleepSeconds := codIsRunning ? 3 : 30
    Sleep(sleepSeconds * 1000)
}

monitorCod(isRunning) {
    if (isRunning) {
        stillRunning := WinExist("ahk_exe cod.exe") > 0
        hasCrashed := WinExist("ahk_exe codCrashHandler.exe") > 0
        if (stillRunning AND !hasCrashed) {
            result := {codIsRunning: true, codHasCrashed: false, codIsClosing: false}
            return result
        }

        if (hasCrashed) {
            logInfo("cod has crashed")
            result := {codIsRunning: false, codHasCrashed: true, codIsClosing: true}
            return result
        } else if (!stillRunning) {
            logInfo("cod has closed without crashing")
            result := {codIsRunning: false, codHasCrashed: false, codIsClosing: true}
            return result
        }
    } else {
        stillRunning := WinExist("ahk_exe cod.exe") > 0
        if (stillRunning) {
            logInfo("cod has started")
        }
        result := {codIsRunning: stillRunning, codHasCrashed: false, codIsClosing: false}
        return result
    }
}

sendNotifications(notifications) {
    for notification in notifications {
        if (notification != "") {
            notifyDiscord(notification)
        }
    }
}

notifyDiscord(notification) {
    webhook_configPath := "webhooks_url.txt"
    if (!FileExist(webhook_configPath)) { 
        return
    }
    url := FileRead(webhook_configPath)
    whr := ComObject("WinHttp.WinHttpRequest.5.1")
    whr.Open("POST", url, true)
    whr.SetRequestHeader("Content-Type", "application/json")
    reqBody := Format('{ "content": "{}" }', notification)
    logDebug(reqBody)
    whr.Send(reqBody)
    whr.WaitForResponse()
    if (whr.Status < 299) {
        logDebug("discord webhook success")
    } else {
        logError(Format("discord webhook failed: {} {}", whr.Status, whr.ResponseText))
    }
}

saveState(currentState) {
    stateFile := "state.csv"
    FileDelete(stateFile)
    FileAppend(Format("{},{},{},{},{},{},`n", currentState.codStreak, currentState.codStreakIndex, currentState.codScore, currentState.crashStreak, currentState.crashStreakIndex, currentState.crashScore), stateFile)
}

loadState() { 
    stateFile := "state.csv"
    state := { codStreak: 0, codStreakIndex: 1, codScore: 0, crashStreak : 0, crashStreakIndex:1, crashScore: 0 }
    if(!FileExist(stateFile)){
        return state
    }

    stateCsv := FileRead(stateFile)
    loop parse, stateCsv, "," {
        switch A_Index {
            case 1: 
                state.codStreak := A_LoopField
            case 2: 
                state.codStreakIndex := A_LoopField
            case 3:
                state.codScore := A_LoopField
            case 4: 
                state.crashStreak := A_LoopField
            case 5: 
                state.crashStreakIndex := A_LoopField
            case 6: 
                state.crashScore := A_LoopField
        }
    }
    return state
}