#SingleInstance force
#Include %A_ScriptDir%\logger.ahk
#Include %A_ScriptDir%\game.ahk

SetWorkingDir A_ScriptDir

state := {
    streak: 0,
    streakIndex: 1
}
logInfo(Format("ready - streak:{1} streakIndex:{2}", state.streak, state.streakIndex))

codIsRunning := false
loop {
    monitorResult := monitorCod(codIsRunning)
    codIsRunning := monitorResult.codIsRunning
    codIsClosing := monitorResult.codIsClosing
    if (codIsClosing) {
        didCrash := monitorResult.codHasCrashed
        state := processState(state, didCrash)
    }
    sleepSeconds := codIsRunning ? 3 : 30
    Sleep(sleepSeconds * 1000)
}

monitorCod(isRunning) {
    if (isRunning) {
        newIsRunning := WinExist("ahk_exe cod.exe") > 0
        hasCrashed := WinExist("ahk_exe codCrashHandler.exe") > 0
        if (newIsRunning AND !hasCrashed) {
            result := {codIsRunning: true, codHasCrashed: false, codIsClosing: false}
            return result
        }

        if (hasCrashed) {
            logInfo("cod has crashed")
            result := {codIsRunning: false, codHasCrashed: true, codIsClosing: true}
            return result
        } else if (!newIsRunning) {
            logInfo("cod has closed without crashing")
            result := {codIsRunning: false, codHasCrashed: false, codIsClosing: true}
            return result
        }
    } else {
        newIsRunning := WinExist("ahk_exe cod.exe") > 0
        if (newIsRunning) {
            logInfo("cod has started")
        }
        result := {codIsRunning: newIsRunning, codHasCrashed: false, codIsClosing: false}
        return result
    }
}