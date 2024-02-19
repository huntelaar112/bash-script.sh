import os 
import cv2
import time
import glob
import argparse
import numpy as np
import sys
from PIL import Image
from cryptography.fernet import Fernet

CALL_VIDEO_KEY = b'DGO-WuHAOF50yDjj5OFOB32WHKOUjzhoHR-Bt3Ne4s4='
f_call_video = Fernet(CALL_VIDEO_KEY)

def decrypt_img(encrypted_file_path, decrypt_file_path):
    #return cv2 image
    with open(encrypted_file_path, 'rb') as fi:
        content = fi.read()
    im_bytes = f_call_video.decrypt(content)
    im = np.frombuffer(im_bytes, dtype=np.uint8)
    im = cv2.imdecode(im, cv2.IMREAD_COLOR)
    #return im
    #with open(decrypt_file_path, 'wb') as fi:
    cv2.imwrite(decrypt_file_path, im)
        #fi.write(im)

if __name__ == '__main__':
    # Get the input and output paths from command line arguments
    input_path = sys.argv[1]
    output_path = sys.argv[2]

    # Decrypt the input image and save the output image
    decrypt_img(input_path, output_path)
