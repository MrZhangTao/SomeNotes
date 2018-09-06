#!/usr/bin/env python3
#-*- coding:utf-8 -*-
'copy fashion files'
__author__ = "ZhangTao"

import os
import sys
from shutil import *

#下面五个为参数
_fashionName = "mqkk" #时装名称  	必传 比如:"hero_cuizikuangbao"
_fromDev = "mqkk" #源分支 			 必传 比如 "cn"
_toDev = "mqkk" #目的分支			必传 比如 "en_stable"
_effectName = "mqkk" #技能特效名称       比如 “effect_xxxx"  需要第五个参数而第四个参数不需要时传 "" 即可
_needAdd = False #完成拷贝后是否执行 git add; git commit; git svn dcommit; 比如："true" "True"



_clientUpdateResPyFile = "update*.py" #客户端拷贝animation脚本 使用正则表达式

divDict = { # 分支字典
	"cn":"animation",
	"en_stable":"animation_en",
	"vn_stable":"animation_vn",
	"th_stable":"animation_th",
}

# python3 copyFashions.py "hero_cuizikuangbao" "cn" "th_stable"

#拷贝指定的所有需要的文件到一个临时创建的文件夹下
def copyFilesToTempDir():
	os.chdir("../../../Client")
	print("当前工1作目录是：%s" % os.getcwd())
	gitOrder = "git clean -f ./;git checkout %s;git pull" % _fromDev
	os.system(gitOrder)

	if os.path.exists("../../tempDir"):
		for curDirPath, dirList, fileList in os.walk("../../tempDir"):
			for filename in fileList:
				os.remove(os.path.join(curDirPath, filename))
		os.rmdir("../../tempDir")
	os.mkdir("../../tempDir") #创建临时目录
	#拷贝技能代码
	pugongFile = "src/ComBattle/Config/%s_pugong.lua" % (_fashionName)
	nujiFile = "src/ComBattle/Config/%s_nuji.lua" % (_fashionName)
	print("skilFile:\n%s\n%s\n" %(pugongFile, nujiFile))
	if os.path.exists(pugongFile):
		dest = "../../tempDir/%s_pugong.lua" % (_fashionName)
		copyfile(pugongFile, dest)
	if os.path.exists(nujiFile):
		dest = "../../tempDir/%s_nuji.lua" % (_fashionName)
		copyfile(nujiFile, dest)

	#拷贝音效文件
	os.chdir("../Output/CHT")
	print("当前工2作目录是：%s" % os.getcwd())
	for index in ["", 1, 2, 3]:
		pugongMusic = "Music/%s_pugong%s.mp3" % (_fashionName, index)
		nujiMusic = "Music/%s_nuji%s.mp3" % (_fashionName, index)
		print("musicFile:\n%s\n%s\n" % (pugongMusic, nujiMusic))
		if os.path.exists(pugongMusic):
			dest = "../../../tempDir/%s_pugong%s.mp3" % (_fashionName, index)
			copyfile(pugongMusic, dest)
		if os.path.exists(nujiMusic):
			dest = "../../../tempDir/%s_nuji%s.mp3" % (_fashionName, index)
			copyfile(nujiMusic, dest)

	#拷贝资源文件:角色 + 技能
	os.chdir("../../UI/Output")
	print("当前工3作目录是：%s" % os.getcwd())
	for fileType in [".skel", ".atlas", ".png"]:

		fromAnimationName = divDict[_fromDev]
		toAnimationName = divDict[_toDev]

		fromHeroFile = "%s/%s%s" % (fromAnimationName, _fashionName, fileType)
		toHeroFile = "%s/%s%s" % (toAnimationName, _fashionName, fileType)
		
		fromEffectPugongFile = "%s/%s_pugong%s" % (fromAnimationName, _effectName, fileType)
		toEffectPugongFile = "%s/%s_pugong%s" % (toAnimationName, _effectName, fileType)

		fromEffectNujiFile = "%s/%s_nuji%s" % (fromAnimationName, _effectName, fileType)
		toEffectNujiFile = "%s/%s_nuji%s" % (toAnimationName, _effectName, fileType)
		print("effectFile is:\n%s\n%s\n" % (fromEffectPugongFile, fromEffectNujiFile))
		if os.path.exists(fromHeroFile) and not os.path.exists(toHeroFile):
			copyfile(fromHeroFile, toHeroFile)
		if os.path.exists(fromEffectPugongFile) and not os.path.exists(toEffectPugongFile):
			copyfile(fromEffectPugongFile, toEffectPugongFile)
		if os.path.exists(fromEffectNujiFile) and not os.path.exists(toEffectNujiFile):
			copyfile(fromEffectNujiFile, toEffectNujiFile)

#移动指定的所有文件到目的分支下的相应位置
def moveLuaAndMp3Files():
	os.chdir("../../Client")
	print("当前工4作目录是：%s" % os.getcwd())
	gitOrder = "git checkout %s;git pull" % _toDev
	os.system(gitOrder) # 切换到目的分支
	os.system("ls ../../tempDir")
	if not os.path.exists("../../tempDir"):
		raise Error("tempDir不存在......")
	
	pugongFile = "../../tempDir/%s_pugong.lua" % _fashionName
	nujiFile = "../../tempDir/%s_nuji.lua" % _fashionName
	if os.path.exists(pugongFile):
		dest = "src/ComBattle/Config/%s_pugong.lua" % _fashionName
		if not os.path.exists(dest):
			move(pugongFile, "src/ComBattle/Config/")
	if os.path.exists(nujiFile):
		dest = "src/ComBattle/Config/%s_nuji.lua" % _fashionName
		if not os.path.exists(dest):
			move(nujiFile, "src/ComBattle/Config/")

	os.chdir("../Output/CHT")
	print("当前工5作目录是：%s" % os.getcwd())
	for index in ["", 1, 2, 3]:
		pugongMusic = "../../../tempDir/%s_pugong%s.mp3" % (_fashionName, index)
		nujiMusic = "../../../tempDir/%s_nuji%s.mp3" % (_fashionName, index)
		if os.path.exists(pugongMusic):
			dest = "Music/%s_pugong%s.mp3" % (_fashionName, index)
			if not os.path.exists(dest):
				move(pugongMusic, "Music/")
		if os.path.exists(nujiMusic):
			dest = "Music/%s_nuji%s.mp3" % (_fashionName, index)
			if not os.path.exists(dest):
				move(nujiMusic, "Music/")

def dealOtherThings():
	os.chdir("..")
	print("当前工6作目录是：%s" % os.getcwd())
	#删除临时文件夹
	os.rmdir("../../tempDir")
	print("临时目录已被删除...")

	#执行脚本拷贝资源到客户端下
	os.system("python %s" % _clientUpdateResPyFile)

	if not _needAdd:
		print("脚本执行结束...")
		return

	os.chdir("../UI")
	print("当前工7作目录是：%s" % os.getcwd()) #提交拷贝的资源到CACommon
	# os.system("git add ./*;")
	os.system("git add ./*;git commit -m 'commit autoly by copyFashions.py';git svn rebase;git svn dcommit;")
	print("脚本执行结束...")

if __name__ == "__main__":
	print("##################################################")
	_fashionName = sys.argv[1]
	_fromDev = sys.argv[2]
	_toDev = sys.argv[3]
	_effectName = "effect" + _fashionName[4:]

	if len(sys.argv) > 4 and sys.argv[4] != "":
		_effectName = sys.argv[4]

	if len(sys.argv) > 5:
		if sys.argv[5] == "true" or sys.argv[5] == "True":
			_needAdd = True

	copyFilesToTempDir()
	moveLuaAndMp3Files()
	dealOtherThings()