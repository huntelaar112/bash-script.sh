#!/usr/bin/python3

import argparse
import re
import requests
import json
import sys

parser = argparse.ArgumentParser()
parser.add_argument('to')
parser.add_argument('subject')
parser.add_argument('message')

args = parser.parse_args()

url = 'https://chat.runsystem.vn/api/v4/posts'

mention='@mannk-runsystem.net'
#mention='@kienld'
rsub = '^RECOVER(Y|ED)?|^OK|^Resolved'
psub = 'PROBLEM.*|Problem'

nw_rsub = '^RECOVER(Y|ED)?.*(NW bandwidth|TCP SYN_RECV)+|^OK.*(NW bandwidth|TCP SYN_RECV)+|^Resolved.*(NW bandwidth|TCP SYN_RECV)+'
nw_psub = '^PROBLEM.*(NW bandwidth|TCP SYN_RECV)+|^Problem.*(NW bandwidth|TCP SYN_RECV)+|^.*(NW bandwidth|TCP SYN_RECV)+.*PROBLEM'
nw_mention='<@U02S3203E6P> <@U02RYJC5Z8U> <@U03DRKTSFFH>'

stgvn="OCR-STGVN"
prodvn="OCR-PRODVN"
prodjp="OCR-PRODJP"
stgjp="OCR-STGJP"

if re.search(stgvn, args.message, re.I):
    channelID="jud4grcd4tbxtpj5i46iffxs5e"
elif re.search(prodvn, args.message, re.I):
    channelID="iduzqs3zitbjjg9rtytqbem18e"
elif re.search(prodjp, args.message, re.I):
    channelID="wu3dukcnztbmjqkoms5rx4cw4e"
elif re.search(stgjp, args.message, re.I):
    channelID="bwjz9rcqrfrkzqru3gg8eftisa"
else:
    channelID="fsiwicrbwtdr3cwtm9uszqtwqo" # gitlab monitor

if re.search(rsub, args.subject, re.I):
    emoji = ':smile:'
    color = '#0C7BDC'
elif re.search(psub, args.subject, re.I):
    emoji=':frowning:'
    color='#FFC20A'
else:
    emoji=':ghost:'
    color='#CCCCCC'

co_token="nb1h887zo3ft7jwbuxpj4nbwpr"
#co_channel_id="iduzqs3zitbjjg9rtytqbem18e"

headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer '+ co_token}
pload = {'channel_id': channelID, 'message': mention, 'props': {'attachments': [{'pretext': args.subject, 'text': args.message, 'color': color}]}}

try:
    res = requests.post(url, data=json.dumps(pload), headers=headers)
except requests.exceptions.RequestException as e:
    sys.exit(1)
