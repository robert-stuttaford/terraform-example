#!/usr/bin/env python3

import sys
import requests
from os import environ
from subprocess import check_output
import json
import configparser


address = "https://circleci.com/api/v1/project/Cognician"


def get_commits(project, build_num, token):
    api_request = "{}/{}/{}?circle-token={}".format(address, project, build_num, token)
    print("Get commits: {}".format(api_request))
    return(requests.get(api_request, headers={'Accept': 'application/json'}).json()['all_commit_details'])


def get_files_changed_in_commit(commit):
    cmd_base = ['git', 'diff-tree', '--no-commit-id', '--name-only', '-r']
    cmd = cmd_base + [commit]
    out = check_output(cmd)
    files = out.decode('ascii').split('\n')
    return(files)


def get_files_changed(project, build_num, token):
    commit_hashes = [x['commit'] for x in get_commits(project, build_num, token)]
    print("Commits hashes: {}".format(commit_hashes))
    files_changed = [get_files_changed_in_commit(x) for x in commit_hashes]
    return [item for sublist in files_changed for item in sublist if item]


def get_depended_files():
    config = configparser.ConfigParser()
    config.read('dependent-builds.cfg')
    return {project: json.loads(config.get(project, 'files')) for project in config.sections()}


def start_deps_build(project, branch, token):
    api_request = "{}/{}/tree/{}?circle-token={}".format(address, project, branch, token)
    print("Start build: {}".format(api_request))
    r = requests.post(api_request)
    if (int(r.status_code) == 201):
        print("Running project: {} branch: {}".format(project, branch))

    if (int(r.status_code) == 400):
        api_request_develop = "{}/{}/tree/{}?circle-token={}".format(address, project, 'develop', token)
        print("Start build: {}".format(api_request_develop))
        requests.post(api_request_develop)
        print("Running project: {} branch: develop".format(project))


if __name__ == "__main__":

    token = environ['CIRCLE_API_TOKEN']

    files_changed = get_files_changed(environ['CIRCLE_PROJECT_REPONAME'], environ['CIRCLE_BUILD_NUM'], token)
    print("Files changed: {}".format(files_changed))

    depended = get_depended_files()
    print("Depended files per project: {}".format(depended))

    for key in depended.keys():
        mtch = depended[key][0] == '*' or [(x, y.rstrip())
                                           for x
                                           in files_changed
                                           for y
                                           in depended[key]
                                           if x != '\n'
                                           if y != '\n'
                                           if x.startswith(y.rstrip())]
        if(mtch):
            print("Starting deps build: {} for matched files {}".format(key, mtch))
            start_deps_build(key, environ['CIRCLE_BRANCH'], token)

sys.exit(0)
