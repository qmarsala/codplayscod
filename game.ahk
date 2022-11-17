#Include %A_ScriptDir%\logger.ahk

pointStreaks := [
{requiredStreak: 3, name: "✈️ UAV"},
{requiredStreak: 4, name: "🛩️ Counter UAV"},
{requiredStreak: 12, name: "🛰️ Advanced UAV"},
{requiredStreak: 30, name: "☢️ Tactical Nuke"}
]

processState(currentState, didCrash) {
    newState := didCrash
    ? handleCrash(currentState)
    : handleClose(currentState)

    newState := checkWinCondition(newState)
    logDebug(Format("codStreak: {}, codIndex: {}, codScore: {}, crashStreak: {}, crashIndex: {}, crashScore: {}", newState.codStreak, newState.codStreakIndex, newState.codScore, newState.crashStreak, newState.crashStreakIndex, newState.crashScore))
    return newState
}

handleCrash(currentState) {
    newCrashStreak := currentState.crashStreak + 1
    newCrashScore := currentState.crashScore + 1
    newCodScore := currentState.codScore
    msg := generateKillFeed(false)
    sendNotification(msg, newCodScore, newCrashScore)
    newCrashStreakIndex := checkStreakCondition("Crash", newCrashStreak, currentState.crashStreakIndex, newCodScore, newCrashScore)

    return {
        codStreak: 0,
        codStreakIndex: 1,
        codScore: newCodScore,
        crashStreak: newCrashStreak,
        crashStreakIndex: newCrashStreakIndex,
        crashScore: newCrashScore
    }
}

handleClose(currentState){
    newCrashScore := currentState.crashScore
    newCodStreak := currentState.codStreak + 1
    newCodScore := currentState.codScore + 1
    msg := generateKillFeed(true)
    sendNotification(msg, newCodScore, newCrashScore)
    newCodStreakIndex := checkStreakCondition("COD", newCodStreak, currentState.codStreakIndex, newCodScore, newCrashScore)

    return {
        codStreak: newCodStreak,
        codStreakIndex: newCodStreakIndex,
        codScore: newCodScore,
        crashStreak: 0,
        crashStreakIndex: 1,
        crashScore: newCrashScore
    }
}

;refactor this stuff
; - don't like that we need the score because we send a notification
checkStreakCondition(player, currentStreak, currentStreakIndex, codScore, crashScore){
    nextStreak := pointStreaks[currentStreakIndex]
    if (currentStreak >= nextStreak.requiredStreak) {
        streakName := pointStreaks[currentStreakIndex].name
        msg := Format("{} called in a {}", player, streakName)
        sendNotification(msg, codScore, crashScore)

        newStreakIndex := currentStreakIndex + 1
        if (newStreakIndex > 4) {
            logDebug("rolling streak index")
            newStreakIndex := 1
        }
        return newStreakIndex
    }else{
        return currentStreakIndex
    }
}
;end todo

checkWinCondition(currentState){
    scoreLimit := 75
    if(currentState.codScore >= scoreLimit || currentState.crashScore >= scoreLimit){
        winner := currentState.codScore > currentState.crashScore ? "COD" : "CRASH"
        msg := Format("Game Over, {} won", winner)
        sendNotification(msg, currentState.codScore, currentState.crashScore)
        return {streak: 0, streakIndex: 1, codScore: 0, crashScore: 0}
    } else {
        return currentState
    }
}

generateKillFeed(forCod) {
    enemies := ["zamboni", "badcode", "sofakinggoated", "Jev"]
    msgTpl := forCod ? "COD 🔫 {}" : "{} 🔫 COD"
    msg := Format(msgTpl, enemies[Random(1,4)])
    return msg
}

;todo: refactor this stuff
sendNotification(msg, codScore, crashScore) {
    notification := Format("{} | cod {} - crash {}", msg, codScore, crashScore)
    TrayTip(notification)
    notifyDiscord(notification)
}
; - don't like this being in the game logic
; - perhaps the game should return the notification and the traytip/discord should be part of main
; - this would keep io out of the game logic
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
;end todo