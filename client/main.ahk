#SingleInstance force
#Include %A_ScriptDir%\logger.ahk

SetWorkingDir A_ScriptDir

codIsRunning := false
loop {
    monitorResult := monitorCod(codIsRunning)
    codIsRunning := monitorResult.codIsRunning
    codIsClosing := monitorResult.codIsClosing
    if (codIsClosing) {
        didCrash := monitorResult.codHasCrashed
        sendNotification(didCrash)
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

sendNotification(didCrash) {
    url := "https://codplayscod-bot.qmarsala.workers.dev/"
    whr := ComObject("WinHttp.WinHttpRequest.5.1")
    whr.Open("POST", url, true)
    whr.SetRequestHeader("Content-Type", "application/json")
    reqBody := didCrash ? '{"status": "crashed"}' : '{"status": "closed"}'
    logDebug(reqBody)
    whr.Send(reqBody)
    whr.WaitForResponse()
    if (whr.Status >= 200 && whr.Status < 300) {
        logDebug("sendNotification: success")
    } else {
        logError(Format("sendNotification: failed - {} {}", whr.Status, whr.ResponseText))
    }
}