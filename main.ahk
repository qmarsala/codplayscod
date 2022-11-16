#SingleInstance force
#Include %A_ScriptDir%\logger.ahk
#Include %A_ScriptDir%\game.ahk

SetWorkingDir A_ScriptDir

state := loadState()
logInfo(Format("ready - streak:{} streakIndex:{}", state.streak, state.streakIndex))

codIsRunning := false
loop {
    monitorResult := monitorCod(codIsRunning)
    codIsRunning := monitorResult.codIsRunning
    codIsClosing := monitorResult.codIsClosing
    if (codIsClosing) {
        didCrash := monitorResult.codHasCrashed
        state := processState(state, didCrash)
        saveState(state)
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

saveState(currentState) {
    stateFile := "state.csv"
    FileDelete(stateFile)
    FileAppend(Format("{},{},{},{}`n", currentState.streak, currentState.streakIndex, currentState.codScore, currentState.crashScore), stateFile)
}

loadState() { 
    stateFile := "state.csv"
    state := { streak: 0, streakIndex: 1, codScore: 0, crashScore: 0 }
    if(!FileExist(stateFile)){
        return state
    }

    stateCsv := FileRead(stateFile)
    loop parse, stateCsv, "," {
        switch A_Index {
            case 1: 
                state.streak := A_LoopField
            case 2: 
                state.streakIndex := A_LoopField
            case 3:
                state.codScore := A_LoopField
            case 4: 
                state.crashScore := A_LoopField
        }
    }
    return state
}