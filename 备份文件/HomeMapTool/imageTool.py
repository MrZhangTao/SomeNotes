#!/usr/bin/python
# -*- coding: utf-8 -*-
import os
from PIL import Image

def splitimage(src, rownum, colnum, dstpath):
    img = Image.open(src)
    w, h = img.size
    if rownum <= h and colnum <= w:
        print('Original image info: %sx%s, %s, %s' % (w, h, img.format, img.mode))
        print('开始处理图片切割, 请稍候...')

        s = os.path.split(src)
        if dstpath == '':
            dstpath = s[0]
        fn = s[1].split('.')
        basename = fn[0]
        ext = fn[-1]

        rowheight = h // rownum
        colwidth = w // colnum
        for r in range(rownum):
            for c in range(colnum):
                box = (c * colwidth, r * rowheight, (c + 1) * colwidth, (r + 1) * rowheight)
                img.crop(box).save(os.path.join(dstpath, basename + '_' + str(c * row + (row - 1 - r)) + '.' + ext), ext)
        print('图片切割完毕，共生成%s张小图片' % (rownum * colnum))
    else:
        print('不合法的行列切割参数！')

src = "/Users/moqikaka/Work/HomeMapTool/homeMap.png"
if os.path.isfile(src):
    dstpath = "/Users/moqikaka/Work/HomeMapTool/homeMap"
    if (dstpath == '') or os.path.exists(dstpath):
        row = 2
        col = 2
        if row > 0 and col > 0:
            splitimage(src, row, col, dstpath)
        else:
            print('无效的行列切割参数！')
    else:
        print('图片输出目录 %s 不存在！' % dstpath)
else:
    print('图片文件 %s 不存在！' % src)
