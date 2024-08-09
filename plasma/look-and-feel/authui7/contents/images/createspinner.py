#!/usr/bin/python3

from PIL import Image
import glob
import os

os.system("mogrify -format png Bitmap5004.bmp")
img = Image.open('Bitmap5004.png')

w, h = img.size
framesize = min(w, h)
horizontalframes = (w > h)

fin = False
cropcount = 0
while fin == False:
    if (horizontalframes and framesize * (cropcount+1) > w) or (not horizontalframes and framesize * (cropcount+1) > h):
        print("e")
        fin = True
        break
    if horizontalframes:
        img.crop((framesize * cropcount, 0, framesize * (cropcount+1), framesize)).save('spin'+str(cropcount)+'.png')
    else:
        img.crop((0, framesize * cropcount, framesize, framesize * (cropcount+1))).save('spin'+str(cropcount)+'.png')
    cropcount += 1
