#!/usr/bin/env python

import os
import json

DIR_PATH = os.path.dirname(os.path.realpath(__file__))
PROJECT_DIR = os.path.abspath(os.path.join(DIR_PATH, ".."))
ROOT_DIR = os.path.join(PROJECT_DIR, "travis_caches")

def export_environment():
    cocos_project_json = os.path.join(PROJECT_DIR, '.cocos-project.json')
    if not os.path.exists(cocos_project_json):
        raise Exception("Not found file: %s" % cocos_project_json)

    f = open(cocos_project_json)
    data = json.load(f)
    f.close()

    engine_version = data['engine_version']
    project_type = data['project_type']
    cocos2dx_root = os.path.join(ROOT_DIR, engine_version)
    cocos_console_root = os.path.join(cocos2dx_root, "tools", "cocos2d-console", "bin")

    if not os.path.exists(ROOT_DIR):
        os.makedirs(ROOT_DIR)

    with open(os.path.join(ROOT_DIR, "environment.sh"), "a") as myfile:
        myfile.write("export COCOS2DX_VERSION=" + engine_version + "\n")
        myfile.write("export COCOS2DX_ROOT=" + cocos2dx_root + "\n")
        myfile.write("export COCOS_CONSOLE_ROOT=" + cocos_console_root + "\n")
        myfile.write("export PROJECT_TYPE=" + project_type + "\n")
        myfile.write("export PATH=" + cocos_console_root + ":$PATH\n")
        
if __name__ == "__main__":
    export_environment()