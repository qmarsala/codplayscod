#Include %A_ScriptDir%\logger.ahk

pointStreaks := [
{requiredStreak: 3, name: "✈️ UAV"},
{requiredStreak: 4, name: "🛩️ Counter UAV"},
{requiredStreak: 12, name: "🛰️ Advanced UAV"},
{requiredStreak: 30, name: "☢️ Tactical Nuke"}
]

processState(currentState, didCrash) {
    result := didCrash
        ? handleCrash(currentState)
        : handleClose(currentState)

    winner := checkWinCondition(result.newState)
    if (winner != ""){
        result.messages.Push(Format("Game Over, {} won", winner))
        result.newState := {codStreak: 0, codStreakIndex: 1, codScore: 0, crashStreak: 0, crashStreakIndex: 1, crashScore: 0 }
    }
    result.messages.Push(Format("COD: {} - CRASH: {}", result.newState.codScore, result.newState.crashScore))
    return result
}

handleCrash(currentState) {
    newCrashStreak := currentState.crashStreak + 1
    newCrashScore := currentState.crashScore + 1
    newCodScore := currentState.codScore
    isStreak := checkStreakCondition(newCrashStreak, currentState.crashStreakIndex)
    streakResult := isStreak 
        ? callInStreak(generateEnemy(), newCrashStreak, currentState.crashStreakIndex) 
        : { msg: "", streakIndex: currentState.crashStreakIndex }
    killFeed := generateKillFeed(false)


    return {
        messages: [killFeed, streakResult.msg],
        newState: {
            codStreak: 0,
            codStreakIndex: 1,
            codScore: newCodScore,
            crashStreak: newCrashStreak,
            crashStreakIndex: streakResult.streakIndex,
            crashScore: newCrashScore
        }
    }
}

handleClose(currentState){
    newCrashScore := currentState.crashScore
    newCodStreak := currentState.codStreak + 1
    newCodScore := currentState.codScore + 1
    isStreak := checkStreakCondition(newCodStreak, currentState.codStreakIndex)
    streakResult := isStreak 
        ? callInStreak("COD", newCodStreak, currentState.codStreakIndex) 
        : { msg: "", streakIndex: currentState.codStreakIndex }
    killFeed := generateKillFeed(true)

    return {
        messages: [killFeed, streakResult.msg],
        newState: {
            codStreak: newCodStreak,
            codStreakIndex: streakResult.streakIndex,
            codScore: newCodScore,
            crashStreak: 0,
            crashStreakIndex: 1,
            crashScore: newCrashScore
        }
    }
}

checkStreakCondition(currentStreak, currentStreakIndex){
    nextStreak := pointStreaks[currentStreakIndex]
    return currentStreak >= nextStreak.requiredStreak
}

callInStreak(player, currentStreak, currentStreakIndex){
    streakName := pointStreaks[currentStreakIndex].name
    newStreakIndex := currentStreakIndex + 1
    if (newStreakIndex > 4) {
        logDebug("rolling streak index")
        newStreakIndex := 1
    }
    return {msg: Format("{} called in a {}", player, streakName), streakIndex: newStreakIndex}
}

checkWinCondition(currentState){
    scoreLimit := 75
    if(currentState.codScore >= scoreLimit || currentState.crashScore >= scoreLimit){
        return currentState.codScore > currentState.crashScore ? "COD" : "CRASH"
    } else {
        return ""
    }
}

generateKillFeed(forCod) {
    msgTpl := forCod ? "COD 🔫 {}" : "{} 🔫 COD"
    msg := Format(msgTpl, generateEnemy())
    return msg
}

generateEnemy() { 
    enemies := ["zamboni", "badcode", "sofakinggoated", "Jev"]
    return enemies[Random(1,4)]
}