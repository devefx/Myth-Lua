#!/usr/bin/python

import os
import sys
import json
import urllib.request
import urllib
import zipfile
import shutil
import logging

def add_path_prefix(path_str):
    if not sys.platform == 'win32':
        return path_str
    
    if path_str.startswith("\\\\?\\"):
        return path_str
    ret = "\\\\?\\" + os.path.abspath(path_str)
    ret = ret.replace("/", "\\")
    return ret

def copy_cocos_x_engin(cocos_x_root, project_dir, lang):
    dst = os.path.join(project_dir, "frameworks", "cocos2d-x")
    if os.path.exists(dst):
        print("Skip copy engin")
        return

    # check cocos engine exist
    cocosx_files_json = os.path.join(
        cocos_x_root, 'templates', 'cocos2dx_files.json')
    if not os.path.exists(cocosx_files_json):
        raise Exception("Not found file: %s" % cocosx_files_json)

    f = open(cocosx_files_json)
    data = json.load(f)
    f.close()

    fileList = data['common']
    if lang == 'lua':
        fileList = fileList + data['lua']

    if lang == 'js' and 'js' in data.keys():
        fileList = fileList + data['js']

    print("Begin copy cocos engine")

    # begin copy engine
    for index in range(len(fileList)):
        srcfile = os.path.join(cocos_x_root, fileList[index])
        dstfile = os.path.join(dst, fileList[index])

        srcfile = add_path_prefix(srcfile)
        dstfile = add_path_prefix(dstfile)

        if not os.path.exists(os.path.dirname(dstfile)):
            os.makedirs(add_path_prefix(os.path.dirname(dstfile)))

        # copy file or folder
        if os.path.exists(srcfile):
            if os.path.isdir(srcfile):
                if os.path.exists(dstfile):
                    shutil.rmtree(dstfile)
                shutil.copytree(srcfile, dstfile)
            else:
                if os.path.exists(dstfile):
                    os.remove(dstfile)
                shutil.copy2(srcfile, dstfile)
    
    print("Copy cocos engine done")

if __name__ == "__main__":
    copy_cocos_x_engin(sys.argv[1], sys.argv[2], sys.argv[3])
