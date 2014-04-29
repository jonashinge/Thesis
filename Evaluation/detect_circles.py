import pygame, sys, random

'''pygame.init()
screen=pygame.display.set_mode([640,480])
screen.fill([100,10,255])
for i in range (255):
    r = random.randint(0,255)
    g = random.randint(0,255)
    b = random.randint(0,255)
    x = random.randint(0,640)
    y = random.randint(0,480)
    ballsize = random.randint(15,35)
    border = random.randint(10,50)
    pygame.draw.circle(screen,[r,g,b],[x,y],ballsize,border)
    pygame.display.flip()
while True:
    for event in pygame.event.get():
        if event.type==pygame.QUIT:
            sys.exit()

'''

import pygame
import random
from pygame.locals import *
 
size = [640,480]
bg_color = [0, 0, 0]  # [230,230,230] light gray
last_timespan = pygame.time.get_ticks()
last_pause = pygame.time.get_ticks()
pause = 2000
timespan = 1500
circles_shown = 0
circles_detected = 0
detections_outside = 0
register_circle_active = False


if __name__ == '__main__':
    SW,SH = 640,480
    screen = pygame.display.set_mode((SW,SH))
    pygame.display.set_caption('Circle detection')

    # clear screen
    screen.fill(bg_color)
    pygame.display.flip()
    
    _quit = False
    while not _quit:
        for e in pygame.event.get():
            if e.type is KEYDOWN and e.key == K_w:
                pygame.display.set_mode(size)
            if e.type is KEYDOWN and e.key == K_f:
                pygame.display.set_mode(size, FULLSCREEN)
            if e.type is MOUSEBUTTONDOWN:
                if register_circle_active:
                    circles_detected += 1
                    register_circle_active = False
                else:
                    detections_outside += 1

            if e.type==pygame.QUIT:
                _quit = True

        pygame.time.wait(1)

        now = pygame.time.get_ticks()

        if now - last_timespan >= timespan and circles_shown > 0:
            last_timespan = float("inf")
            # clear screen
            print("Clearing screen...")
            print("Circles shown: " + str(circles_shown) + ", circles detected: " + str(circles_detected))
            print("Success detection rate: ", str((circles_detected/circles_shown)*100) + "%")
            print("(Detections outside: " + str(detections_outside) + ")")
            screen.fill(bg_color)
            pygame.display.flip()

            register_circle_active = False

        if now - last_pause >= pause:
            last_pause = now
            last_timespan = now

            # new circle
            r = random.randint(0,255)
            g = random.randint(0,255)
            b = random.randint(0,255)
            x = random.randint(0,640-35)
            y = random.randint(0,480-35)
            ballsize = random.randint(15,35)
            border = random.randint(10,15)
            pygame.draw.circle(screen,[r,g,b],[x,y],ballsize,border)
            pygame.display.flip()

            pause = random.randint(2000,15000)

            circles_shown += 1

            register_circle_active = True

        

        

            


        




