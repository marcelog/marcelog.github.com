#!/bin/bash

filedump=/tmp/dump.txt

function log() {
    echo ${@} >> ${filedump}
}

function dumpvar() {
    log "channel variable: ${1} = ${2}"
}

function send() {
    log Sending: ${@}
    echo ${@}
    read line
    log "Got: ${line}"
}

function answer() {
    send "ANSWER"
}

function agilog() {
    send "VERBOSE" \"${@}\"
}

function play() {
    send STREAM FILE ${1} "#"
}

function setvariable() {
    send SET VARIABLE ${1} ${2}
}

function hangup() {
    setvariable AGISTATUS SUCCESS
    send "HANGUP 16"
}

callStatus=1
function callEnded() {
    if [ "${callStatus}" -eq "0" ]; then
        return
    fi
    callStatus=0
    agilog "Call ended abruptly"
    hangup
    exit 0
}

trap callEnded SIGHUP

log "------------ call start ------------"
dumpvar "config dir" ${AST_CONFIG_DIR}
dumpvar "configfile" ${AST_CONFIG_FILE}
dumpvar "module dir" ${AST_MODULE_DIR}
dumpvar "spool dir" ${AST_SPOOL_DIR}
dumpvar "monitor dir" ${AST_MONITOR_DIR}
dumpvar "var dir" ${AST_VAR_DIR}
dumpvar "data dir" ${AST_DATA_DIR}
dumpvar "log dir" ${AST_LOG_DIR}
dumpvar "agi dir" ${AST_AGI_DIR}
dumpvar "key dir" ${AST_KEY_DIR}
dumpvar "run dir" ${AST_RUN_DIR}

line='init'
while [ "${#line}" -gt "2" ]; do
	read line
	log ${line}
done
answer
agilog Hello There
play welcome
hangup
log "------------ call done ------------"
exit 0
