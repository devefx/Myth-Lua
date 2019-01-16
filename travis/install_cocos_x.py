#!/usr/bin/python

import os
import sys
import json
import urllib.request
import urllib
import zipfile
import shutil

def add_path_prefix(path_str):
    if not sys.platform == 'win32':
        return path_str
    
    if path_str.startswith("\\\\?\\"):
        return path_str
    ret = "\\\\?\\" + os.path.abspath(path_str)
    ret = ret.replace("/", "\\")
    return ret

def download_cocos_x(download_url, cocos_x_root):
    # download cocos2d-x
    cocos_x_zip_file = cocos_x_root + '.zip'
    if not os.path.exists(cocos_x_zip_file):
        print("begin download cocos x engine: %s" % download_url)
        urllib.request.urlretrieve(download_url, cocos_x_zip_file)
    
    # unzip cocos2d-x
    print("begin decompression cocos x engine")
    f = zipfile.ZipFile(cocos_x_zip_file, 'r')
    for file in f.namelist():
        f.extract(file, os.path.join(cocos_x_root, ".."))

def append_cocos_x_engine(cocos_x_root, download_url, project_dir, lang):
    dst = os.path.join(project_dir, "frameworks", "cocos2d-x")
    if os.path.exists(dst):
        print("skip copy engin")
        return

    # check cocos engine exist
    cocosx_files_json = os.path.join(
        cocos_x_root, 'templates', 'cocos2dx_files.json')
    if not os.path.exists(cocos_x_root) or not os.path.exists(cocosx_files_json):
        download_cocos_x(download_url, cocos_x_root)

    f = open(cocosx_files_json)
    data = json.load(f)
    f.close()

    fileList = data['common']
    if lang == 'lua':
        fileList = fileList + data['lua']

    if lang == 'js' and 'js' in data.keys():
        fileList = fileList + data['js']

    print("begin copy engine")

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
    
    print("copy engine done")

if __name__ == '__main__':
    cocos_x_download_url = "https://digitalocean.cocos2d-x.org/Cocos2D-X/cocos2d-x-3.17.1.zip"
    cocos_x_root = os.path.join(os.path.dirname(__file__), "..", "cocos2d-x-3.17.1")
    project_dir = os.path.join(os.path.dirname(__file__), "..")
    project_lang = "lua"
    append_cocos_x_engine(cocos_x_root, cocos_x_download_url, project_dir, project_lang)
    