#!/usr/bin/env python
import json
import os
import yaml

terraform_cmd = ['terraform', 'output', '-no-color', '-json']
ansible_var_file_paths = ('group_vars/all.yml', 'vars/main.yml')


def load_terraform_vars():
    print('->> Reading Terraform Outputs')
    with open('tf_outputs.json', 'r') as f:
        raw_output = f.read()
    vars = json.loads(raw_output)
    for key, m in vars.iteritems():
        vars[key] = m['value']
    return vars


def update_ansible_vars(source_vars, var_file):
    with open(var_file, "r+") as f:
        f.seek(0)
        vars = yaml.load(f)

        changed = False

        for k in vars:
            val = source_vars.get(k)
            if val is not None:
                changed = True
                vars[k] = str(val)

        if changed:
            print('-> Updated {}.'.format(var_file))
            f.seek(0)
            yaml_vars = yaml.dump(vars, default_flow_style=False)
            print(yaml_vars)
            f.write(yaml_vars)
            f.truncate()

if __name__ == '__main__':

    terraform_vars = load_terraform_vars()

    print('->> Updating CircleCI vars file (run update-circleci-env.py to push to CircleCI).')

    update_ansible_vars({'AWS_ACCESS_KEY_ID': terraform_vars.get('master_circleci_access_key'),
                         'AWS_SECRET_ACCESS_KEY': terraform_vars.get('master_circleci_access_secret'),
                         'AWS_CODE_DEPLOY_KEY': terraform_vars.get('circleci_access_key'),
                         'AWS_CODE_DEPLOY_SECRET': terraform_vars.get('circleci_access_secret'),
                         'AWS_CODE_DEPLOY_S3_BUCKET': terraform_vars.get('ci_bucket'),
                         'CI_BUCKET': terraform_vars.get('ci_bucket'),
                         'STATIC_MEDIA_BUCKET': terraform_vars.get('static_media_bucket'),
                         'CIRCLE_API_TOKEN': terraform_vars.get('circleci_api_token')},
                        'circleci.env.yml')

    print('->> Updating Ansible vars')
    print

    for root, sub_folders, files in os.walk('playbooks'):
        for file in files:
            abs_path = os.path.join(root, file)
            if abs_path.endswith(ansible_var_file_paths):
                update_ansible_vars(terraform_vars, abs_path)
