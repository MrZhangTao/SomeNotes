#!/usr/bin/env python3
#-*- coding:utf-8 -*-
from PIL import Image, ImageDraw, ImageFont, ImageColor, ImageFilter
import random, string, re, os, xlwt, xlrd, codecs
from collections import Counter

def add_num(img):
    '''在图上绘制文字(打开png格式图片，保存时存在问题)'''
    draw = ImageDraw.Draw(img)
    myfont = ImageFont.truetype('/Library/Fonts/Arial.ttf', 40)
    fillcolor = ImageColor.colormap.get("red")
    width, height = im.size
    draw.text((width-70, 0), '666', font=myfont, fill=fillcolor)
    img.save("zxrw_8Save.jpg")

def get_activation(order = 0):
    '''生成200个激活码'''
    number = 0
    list_activation = []
    while number < 200:
        pattern_str = string.digits + string.ascii_uppercase
        # patter_str = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        activation_code = "".join(random.sample(pattern_str, 16))
        list_activation.append(activation_code)
        number += 1
    if order == 0:
        print("list_activation:", list_activation)
    else:
        print("the %dth list_activation is: %s" % (order, list_activation[order - 1]))

def getMostCommonWord(articleFileSource, needCommon = False):
    '''输入一个英文的纯文本文件，统计其中的单词出现的个数'''
    pattern = r'''[A-Za-z]+|\$?\d+%?$''' #匹配 纯英文文本 | 数字 金额 百分比
    with open(articleFileSource) as f:
        r = re.findall(pattern, f.read())
        if not needCommon:
            return Counter(r)
        else:
            return Counter(r).most_common()

def getTheMostImportant(**kw):
    '''获取目标目录中所有后缀为txt的英文文件，其中使用频率最高的词'''
    stop_words = ['the', 'in', 'of', 'and', 'to', 'has', 'that', 's', 'is', 'are', 'a', 'with', 'as', 'an']
    if not "path" in kw:
        path = os.path.abspath(".")
    else:
        path = kw["path"]

    #切换目录
    os.chdir(path)
    #遍历该目录下的txt文件
    total_counter = Counter()
    for i in os.listdir(os.getcwd()):
        if os.path.splitext(i)[1] == ".txt":
            total_counter += getMostCommonWord(i)
    #排除stopword的影响
    for i in stop_words:
        total_counter[i] = 0
    print(total_counter.most_common()[0][0])

def countCodeStatus(codefile):
    '''有个程序文件，
    统计一下你写了多少行代码。
    包括空行和注释，但是要分别列出来。'''
    total_line = 0
    comment_line = 0
    blank_line = 0
    with open (codefile) as f:
        lines = f.readlines()
        total_line = len(lines)
        line_index = 0
        while line_index < total_line:
            line = lines[line_index]
            if line == "\n":
                blank_line += 1
                line_index += 1
            elif re.match("\s*'''", line) is not None:
                print(line_index, "'''")
                while re.match(".*'''$", line) is None:
                    comment_line += 1
                    line_index += 1
                    line = lines[line_index]
                comment_line += 1
                print(line_index, "'''$")
                line_index += 1
            else:
                singleSymbolCount = 0 #单引号数量
                doubleSymbolCount = 0 #双引号数量
                hasCommentSymbol = False #是否有注释符号’#‘
                for c in line:
                    if c == "\"":
                        doubleSymbolCount += 1
                    elif c == "\'":
                        singleSymbolCount += 1
                    elif c == "#":
                        hasCommentSymbol = True
                        break
                if hasCommentSymbol and singleSymbolCount % 2 == 0 and doubleSymbolCount % 2 == 0:
                    print(line_index, "#")
                    comment_line += 1
                line_index += 1
        print("在%s中：" % codefile)
        print("代码行数：", total_line)
        print("注释行数：", comment_line, "占%0.2f%%" % (comment_line*100.0/total_line))
        print("空行数：  ", blank_line, "占%0.2f%%" % (blank_line*100.0/total_line))

def randChr():
    '''生成随机字母'''
    return chr(random.randint(65, 90))

def randColor():
    '''生成随机颜色'''
    return (random.randint(64, 255), random.randint(64, 255), random.randint(64, 255))

def randColor2():
    '''生成随机颜色（范围不同）'''
    return (random.randint(32, 127), random.randint(32, 127), random.randint(32, 127))

def makeAuthCode():
    '''生成字母验证码图片'''
    width = 60 * 4
    height = 60
    image = Image.new("RGB", (width, height), (255, 255, 255))
    #创建font对象和draw对象
    font = ImageFont.truetype("Arial.ttf", 36)
    draw = ImageDraw.Draw(image)
    #填充每个像素
    for i in range(width):
        for j in range(height):
            draw.point((i, j), fill=randColor())

    #输入文字
    for i in range(4):
        draw.text((60 * i + 10, 10), randChr(), font = font, fill = randColor2())
    #模糊图片
    image = image.filter(ImageFilter.BLUR)
    image.save("authCode.jpg", "jpeg")

def filterWords():
    '''敏感词文本文件 filtered_words.js
    当用户输入敏感词语时，则打印出 Freedom，否则打印出 Human Rights。'''
    wordList = None
    os.chdir(os.path.abspath("."))
    with open("filtered_words.js", "r") as f:
        wordList = f.readlines()
    while True:
        val = input("请输入词语：")
        if val == "OVER":
            break
        if val in wordList or (val + "\n") in wordList:
            print("Freedom")
        else:
            print("Human Rights")

def replaceFilterWord():
    '''当用户输入敏感词语，则用 星号 * 替换，例如当用户输入「北京是个好城市」，则变成「**是个好城市」'''
    wordList = None
    maxLen = 0
    os.chdir(os.path.abspath("."))
    with open("filtered_words.js", "r") as f:
        wordList = f.readlines()
        for i, line in enumerate(wordList):
            wordList[i] = line.strip("\n")
            if maxLen < len(wordList[i]):
                maxLen = len(wordList[i])
    #星号处理
    starStr = ""
    for i in range(maxLen):
        starStr += "*"

    while True:
        val = input("请输入语句：")
        if val == "OVER":
            break
        for line in wordList:
            if line in val:
                chrLen = len(line)
                #下面这句如果输入的词语
                val = val.replace(line, "".join(random.sample(starStr, chrLen)))
                break

        print(val)

def txt_to_Excel(inputTxt, sheetName, start_row, start_col, outputExcel):
    '''将txt文本内容写入到xls文件中'''
    fr = codecs.open(inputTxt, "r")
    wb = xlwt.Workbook(encoding = "utf-8")
    ws = wb.add_sheet(sheetName)
    line_number = 0
    row_excel = start_row
    try:
        for line in fr:
            line_number += 1
            row_excel += 1
            line = line.strip()
            col_excel = start_col

            tmpLines = line.split(":")
            ws.write(row_excel, col_excel, (tmpLines[0]).strip("\""))
            col_excel += 1
            len_line = len(tmpLines[1])
            line = tmpLines[1][1:len_line - 2].split(",")
            len_line = len(line)
            for j in range(len_line):
                ws.write(row_excel, col_excel, line[j].strip("\""))
                col_excel += 1
        wb.save(outputExcel)
    except:
        print("Error")

if __name__ == '__main__':
    # im = Image.open("zxrw_8.jpg")
    # add_num(im)
    # get_activation(4)
    # getMostCommonWord("VictorySpeech.txt", True)
    # getTheMostImportant()
    # countCodeStatus("Yixiaohan.py")
    # makeAuthCode()
    # filterWords()
    # replaceFilterWord()
    txt_to_Excel("excelText.js", "Sheet2", 7, 3, "textExcel.xls")