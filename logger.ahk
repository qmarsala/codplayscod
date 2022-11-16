logDebug(message) {
    _writeLog("debug", message)
}

logInfo(message) {
    _writeLog("info", message)
}

logError(message) {
    _writeLog("error", message)
}

_writeLog(level, message) {
    logFilePath := "log.txt"
    _keepFileSmallerThanMb(logFilePath, 1)
    line := _formatLogWithTime(level, message)
    _appendLine(line, logFilePath)
}

_formatLogWithTime(level, message) {
    timeStamp := _getTimeStamp()
    return Format("[{}] {} - {}", level, timeStamp, message)
}

_getTimeStamp() {
    return FormatTime(A_Now, "MM/dd HH:mm:ss")
}

_appendLine(line, filePath)  {
    FileAppend(Format("{1}`n", line), filePath)
}

_keepFileSmallerThanMb(filePath, maxSizeMb := 1) {
    if (!FileExist(filePath)) {
        return
    }
    
    logFileSize := FileGetSize(filePath, "M")
    if (logFileSize >= maxSizeMb) {
        FileDelete(filePath)
    }
}
