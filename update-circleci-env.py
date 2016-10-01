#!/usr/bin/env python

import requests
import argparse
import json
import yaml

address = "https://circleci.com/api/v1.1/project/github/xxx"


def set_env_var_for_project(token, project, name, value):
    api_request = "{}/{}/envvar?circle-token={}".format(address, project, token)
    var = {'name': name, 'value': value}
    print("-> {}\n{}".format(api_request, json.dumps(var)))
    r = requests.post(api_request, data=json.dumps(var), headers={'content-type': 'application/json'})
    r.raise_for_status()


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument('circleci_token', help='CircleCI API token.')
    args = parser.parse_args()

    with open('circleci.env.yml', "r") as f:
        vars = yaml.load(f)

    with open('circleci.projects.yml', "r") as f:
        projects = yaml.load(f).get('projects')

    for project in projects:
        for key in vars:
            set_env_var_for_project(args.circleci_token, project, key, vars.get(key))
