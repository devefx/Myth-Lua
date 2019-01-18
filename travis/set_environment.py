#!/usr/bin/env python

import os
import json

DIR_PATH = os.path.dirname(os.path.realpath(__file__))
PROJECT_DIR = os.path.abspath(os.path.join(DIR_PATH, ".."))

def export_environment():
    cocos_project_json = os.path.join(PROJECT_DIR, '.cocos-project.json')
    if not os.path.exists(cocos_project_json):
        raise Exception("Not found file: %s" % cocos_project_json)

    f = open(cocos_project_json)
    data = json.load(f)
    f.close()

    root_dir = os.path.join(PROJECT_DIR, "travis_caches")
    if not os.path.exists(root_dir):
        os.makedirs(root_dir)

    engine_version = data['engine_version']
    project_type = data['project_type']
    cocos2dx_root = os.path.join(root_dir, engine_version)

    with open(os.path.join(root_dir, "environment.sh"), "a") as myfile:
        myfile.write("export COCOS2DX_VERSION=" + engine_version + "\n")
        myfile.write("export COCOS2DX_ROOT=" + cocos2dx_root + "\n")
        myfile.write("export PROJECT_TYPE=" + project_type + "\n")

if __name__ == "__main__":
    export_environment()