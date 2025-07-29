import cv2
import os
import time
import numpy as np
import shutil

ASCII_CHARS = "@%#*+=-:. "
RESET = "\x1b[0m"


def resizeframe(image):
    term_size = shutil.get_terminal_size((80, 24))
    term_width = term_size.columns
    term_height = term_size.lines - 1

    img_height, img_width = image.shape[:2]
    aspect_ratio = img_height / img_width

    new_height = term_height
    new_width = int(new_height / (aspect_ratio * 0.55))

    resized_image = cv2.resize(image, (new_width, new_height))
    return resized_image


def pixeltoansi(r, g, b, char):
    return f"\x1b[38;2;{r};{g};{b}m{char}{RESET}"

def frame2ascii(frame):
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    resized_gray = resizeframe(gray)
    resized_color = resizeframe(frame)

    ascii_art = []
    for y in range(resized_gray.shape[0]):
        line = ""
        for x in range(resized_gray.shape[1]):
            lum = resized_gray[y, x]
            char = ASCII_CHARS[lum * len(ASCII_CHARS) // 256]
            b, g, r = resized_color[y, x]
            line += pixeltoansi(r, g, b, char)
        ascii_art.append(line)
    return "\n".join(ascii_art)

def nothingbeatsajet2holiday(video_path):
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print("something beat a jet2 holiday :(")
        return

    try:
        fps = cap.get(cv2.CAP_PROP_FPS) or 25
        delay = 1.0 / fps
        while True:
            ret, frame = cap.read()
            if not ret:
                break

            ascii_frame = frame2ascii(frame)
            os.system('clear')
            print(ascii_frame)
            time.sleep(delay)
    finally:
        cap.release()

video_path = "./nothingbeatsajet2holiday.mp4"
nothingbeatsajet2holiday(video_path)
