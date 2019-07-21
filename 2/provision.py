#!/usr/bin/env python
import json
import requests
from requests.auth import HTTPBasicAuth

zabbix_server = "192.168.77.21"
zabbix_api_admin_name = "Admin"
zabbix_api_admin_password = "zabbix"

hostname = "Hostname"
ipclient = "192.168.77.22"
group = "CloudHosts"
template = "Template OS Linux"


# Define post function
def post(request):
    headers = {'content-type': 'application/json'}
    return requests.post(
        "http://" + zabbix_server + "/zabbix/api_jsonrpc.php",
        data=json.dumps(request),
        headers=headers,
        auth=HTTPBasicAuth(zabbix_api_admin_name, zabbix_api_admin_password)
    )


# Get Auth_token
auth_token = post({
    "jsonrpc": "2.0",
    "method": "user.login",
    "params": {
        "user": zabbix_api_admin_name,
        "password": zabbix_api_admin_password
    },
    "auth": None,
    "id": 0}
).json()["result"]

# Create group "CloudHosts"
post({
    "jsonrpc": "2.0",
    "method": "hostgroup.create",
    "params": {
        "name": group
    },
    "auth": auth_token,
    "id": 1
})

# Get id "CloudHosts"
groupinfo = post({
    "jsonrpc": "2.0",
    "method": "hostgroup.get",
    "params": {
        "output": "extend",
        "filter": {
            "name": [
                group
            ]
        }
    },
    "auth": auth_token,
    "id": 1
}).json()["result"]

result = groupinfo[0]
groupid = result['groupid']

# Get id Custom template -for example "Template OS Linux"

templateinfo = post({
    "jsonrpc": "2.0",
    "method": "template.get",
    "params": {
        "output": "extend",
        "filter": {
            "host": [
                template
            ]
        }
    },
    "auth": auth_token,
    "id": 1
}).json()["result"]

result = templateinfo[0]
templateid = result["templateid"]


# Define host
def create_host(hostname, ip):
    post({
        "jsonrpc": "2.0",
        "method": "host.create",
        "params": {
            "host": hostname,
            "templates": [{
                "templateid": templateid
            }],
            "interfaces": [{
                "type": 1,
                "main": 1,
                "useip": 1,
                "ip": ip,
                "dns": "",
                "port": "10050"
            }],
            "groups": [
                {"groupid": groupid}

            ]
        },
        "auth": auth_token,
        "id": 1
    })


# Create host with necessary parameters
create_host(hostname, ipclient)