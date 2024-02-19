#!/bin/bash

channelID=${1}
argSubject=${2}
argBody=${3}

jsonfile=$(mktemp)
tmpfile=$(mktemp)
mention="@mannk-runsystem.net"
token="nb1h887zo3ft7jwbuxpj4nbwpr"
url="https://chat.runsystem.vn/api/v4/posts"

[[ ${argBody} =~ "OCR-PRODJP" ]] && {
  channelID="wu3dukcnztbmjqkoms5rx4cw4e"
}

[[ ${argBody} =~ "OCR-PRODVN" || ${argBody} =~ "OCR-STGVN" ]] && {
  #channelID="iduzqs3zitbjjg9rtytqbem18e"
  channelID="fsiwicrbwtdr3cwtm9uszqtwqo"
}

#argSubject="test PROBLEM"
#argBody="just test"

echo ${channelID} >>${tmpfile}
echo ${argSubject} >>${tmpfile}
echo ${argBody} >>${tmpfile}

recoversub="Resolved"
if [[ "$argSubject" =~ ${recoversub} ]] || [[ "$argSubject" =~ 'OK' ]]; then
  echo "resolve" >>${tmpfile}
  color="#0C7BDC"
elif [[ "$argSubject" =~ 'PROBLEM' ]]; then
  echo "problem" >>${tmpfile}
  color="#FFC20A"
else
  color="#CCCCCC"
fi

json=$(
  cat <<__
"{"channel_id":"${channelID}", "message":"${mention}", "props":{"attachments": [{"pretext": "${argSubject}", "text": "${argBody}", "color": "${color}"}]}}"
__
)
cat ${json} >${jsonfile}

function POST_MSG() {
  #return=$(curl -i -X POST -H 'Content-Type: application/json' -d "{\"channel_id\":\"${channelID}\", \"message\":\"${mention}\", \"props\":{\"attachments\": [{\"pretext\": \"$(echo ${argSubject})\", \"text\": \"$(echo ${argBody})\", \"color\": \"$(echo ${color})\"}]}}" -H "Authorization: Bearer ${token} " ${url})
  return=$(curl -i -X POST -H 'Content-Type: application/json' -d "{\"channel_id\":\"${channelID}\", \"message\":\"${mention}\", \"props\":{\"attachments\": [{\"pretext\": \"$(echo ${argSubject})\", \"text\": \"$(echo ${argBody})\", \"color\": \"$(echo ${color})\"}]}}" -H "Authorization: Bearer ${token} " ${url})
  echo $return >>${tmpfile}
}

function POST_MSG1() {
  #return=$(curl -i -X POST -H 'Content-Type: application/json' -d "{\"channel_id\":\"${channelID}\", \"message\":\"${mention}\", \"props\":{\"attachments\": [{\"pretext\": \"$(echo ${argSubject})\", \"text\": \"$(echo ${argBody})\", \"color\": \"$(echo ${color})\"}]}}" -H "Authorization: Bearer ${token} " ${url})
  return=$(curl -i -X POST -H 'Content-Type: application/json' -d @${jsonfile} -H "Authorization: Bearer ${token} " ${url})
  echo $return >>${tmpfile}
}

POST_MSG
POST_MSG1

#Problem started at {EVENT.TIME} on {EVENT.DATE}\Host    : {HOST.NAME} Trigger: {TRIGGER.NAME} Trigger status: {TRIGGER.STATUS} Trigger severity: {TRIGGER.SEVERITY} Item values: {ITEM.NAME} ({ITEM.KEY}): {ITEM.VALUE} Original event ID: {EVENT.ID}
#url -i -X POST -H 'Content-Type: application/json' -d "{\"channel_id\":\"fsiwicrbwtdr3cwtm9uszqtwqo\", \"message\":\"@mannk-runsystem.net\", \"props\":{\"attachments\": [{\"pretext\": \"test-subject\", \"text\": \"test-body ^M asdf\", \"color\": \"#FFC20A\"}]}}" -H "Authorization: Bearer nb1h887zo3ft7jwbuxpj4nbwpr " https://chat.runsystem.vn/api/v4/posts
