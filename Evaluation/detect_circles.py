import pygame
import random
from pygame.locals import *
import time
import datetime
 
bg_color = [0, 0, 0]  # [230,230,230] light gray

last_timespan = pygame.time.get_ticks()
last_pause = pygame.time.get_ticks()
pause = 2000 # will be generated randomly in loop
timespan = 1000

circles_shown = 0
circles_detected = 0
detections_outside = 0
register_circle_active = False

text_showing = False
texts = [
        "Bodebrixen - I Don't Care",
        "Kanye West, Jay Z, Beyoncé - Lift Off (Album Version Explicit)",
        "Twin Sister - Daniel"]
text_counter = 0
task_reg = 1


if __name__ == '__main__':

    pygame.init()
    # font
    myfont = pygame.font.SysFont("Helvetica", 24)
    # Initialize the joysticks
    pygame.joystick.init()

    SW,SH = 1200,800
    screen = pygame.display.set_mode((SW,SH), pygame.RESIZABLE)
    pygame.display.set_caption('Circle detection')

    # clear screen
    screen.fill(bg_color)
    pygame.display.flip()

    print("")
    
    _quit = False
    while not _quit:
        for e in pygame.event.get():
            if e.type is KEYDOWN and e.key == K_w:
                pygame.display.set_mode((SW,SH))
            if e.type is KEYDOWN and e.key == K_f:
                pygame.display.set_mode((SW,SH), FULLSCREEN)
            if e.type is KEYDOWN and e.key == K_t:
                if text_counter < len(texts):
                    # remove circle, clear screen
                    screen.fill(bg_color)
                    pygame.display.flip()
                    # render text
                    label = myfont.render(texts[text_counter], 1, (255,255,255))
                    screen.blit(label, (50, 50))
                    pygame.display.flip()
                    text_showing = True
            if e.type is KEYDOWN and e.key == K_r:
                if text_counter == task_reg and text_showing is False:
                    # register track found
                    print(datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S'))
                    print("Registering task " + str(task_reg))
                    print("")
                    task_reg += 1
            if e.type is pygame.JOYBUTTONDOWN:
                if text_showing is True:
                    # beginning task
                    print(datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S'))
                    print("Starting task " + str(text_counter+1))
                    print("")
                    # remove circle, clear screen
                    screen.fill(bg_color)
                    pygame.display.flip()
                    text_counter += 1
                    text_showing = False
                    now = pygame.time.get_ticks()
                else:
                    if register_circle_active:
                        circles_detected += 1
                        register_circle_active = False
                        # remove circle, clear screen
                        screen.fill(bg_color)
                        pygame.display.flip()
                    else:
                        detections_outside += 1

            if e.type==pygame.QUIT:
                _quit = True

        pygame.time.wait(1)

        now = pygame.time.get_ticks()

        if text_showing is False:
            if now - last_timespan >= timespan and circles_shown > 0:
                last_timespan = float("inf")
                # clear screen
                print(datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S'))
                print("Clearing screen...")
                print("Circles shown: " + str(circles_shown) + ", circles detected: " + str(circles_detected))
                print("Success detection rate: ", str((circles_detected/circles_shown)*100) + "%")
                print("(Detections outside: " + str(detections_outside) + ")")
                print("")
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
                x = random.randint(0,SW-35)
                y = random.randint(0,SH-35)
                ballsize = random.randint(15,35)
                border = random.randint(10,15)
                pygame.draw.circle(screen,[r,g,b],[x,y],ballsize,border)
                pygame.display.flip()

                pause = random.randint(2000,10000)

                circles_shown += 1

                register_circle_active = True


        # Get count of joysticks
        joystick_count = pygame.joystick.get_count()
        
        # For each joystick:
        for i in range(joystick_count):
            joystick = pygame.joystick.Joystick(i)
            joystick.init()

        

            


        




