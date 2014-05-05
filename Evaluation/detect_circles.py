import pygame
import random
from pygame.locals import *
import time
import datetime
 
bg_color = [0, 0, 0]  # [230,230,230] light gray

fig_min = 20
fig_max = 40

last_timespan = pygame.time.get_ticks()
#last_pause = pygame.time.get_ticks()
#last_text = pygame.time.get_ticks()
#pause = 2000 # will be generated randomly in loop
timespan = 1000
#textspan = 5000

circles_shown = 0
circles_detected = 0
detections_outside = 0
register_circle_active = False

#text_showing = False
texts = [
        "Lorde - Royals",
        "Django Django - Default",
        "alt-J - Breezeblocks",
        "alt-J - Fitzpleasure",
        "alt-J - Tessellate",
        "Django Django - Zumm Zumm",
        "Django Django - Hail Bop",
        "Lorde - Tennis Court",
        "Lorde - Million Dollar Bills"]
text_counter = 0
task_reg = 1
text_y = 50


if __name__ == '__main__':

    pygame.init()

    # bg image
    picture = pygame.image.load("pov_bg_sat.jpg")
    
    
    # font
    myfont = pygame.font.SysFont("Helvetica", 24)

    # Initialize the joysticks
    pygame.joystick.init()

    SW,SH = 1200,675
    screen = pygame.display.set_mode((SW,SH), pygame.RESIZABLE)
    pygame.display.set_caption('Circle detection')

    # clear screen
    #screen.fill(bg_color)
    #pygame.display.flip()

    # shuffle texts
    random.shuffle(texts)

    print("")
    
    _quit = False
    while not _quit:
        for e in pygame.event.get():
            if e.type is KEYDOWN and e.key == K_w:
                pygame.display.set_mode((SW,SH))
            if e.type is KEYDOWN and e.key == K_f:
                pygame.display.set_mode((SW,SH), FULLSCREEN)
            if e.type is KEYDOWN and e.key == K_t:
                if text_counter < len(texts) and text_counter != task_reg:
                    # render text
                    label = myfont.render(texts[text_counter], 1, (255,255,255))
                    screen.blit(label, (30, text_y-35))
                    pygame.display.flip()
                    #text_showing = True
                    #last_text = pygame.time.get_ticks()
                    text_counter += 1
                    print(datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S'))
                    print("Showing task " + str(text_counter))
                    print("")
            if e.type is KEYDOWN and e.key == K_r:
                if text_counter == task_reg:
                    # register track found
                    print(datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S'))
                    print("Registering task " + str(task_reg))
                    print("")
                    task_reg += 1
                    #text_showing = False
                    # remove text
                    screen.fill(bg_color, (0, 0, SW, text_y))
                    pygame.display.flip()
            if e.type is pygame.JOYBUTTONDOWN:
                if register_circle_active:
                    circles_detected += 1
                    register_circle_active = False
                    # remove circle, clear screen
                    screen.blit(picture, (0,text_y))
                    #screen.fill(bg_color, (0, text_y, SW, SH))
                    pygame.display.flip()
                else:
                    detections_outside += 1

            if e.type==pygame.QUIT:
                _quit = True

        pygame.time.wait(1)

        now = pygame.time.get_ticks()

        if now - last_timespan >= timespan:
            last_timespan = float("inf")
            # clear screen
            print(datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S'))
            print("Clearing screen...")
            print("Circles shown: " + str(circles_shown) + ", circles detected: " + str(circles_detected))
            #print("Success detection rate: ", str((circles_detected/circles_shown)*100) + "%")
            print("(Detections outside: " + str(detections_outside) + ")")
            print("")
            screen.blit(picture, (0,text_y))
            #screen.fill(bg_color, (0, text_y, SW, SH))
            pygame.display.flip()

            last_timespan = now

            fig_type = random.randint(0,2)

            # Circle
            r = random.randint(0,255)
            g = random.randint(0,255)
            b = random.randint(0,255)
            x = random.randint(0+fig_max,SW-fig_max)
            y = random.randint(text_y+fig_max,SH-fig_max)
            fig_size = random.randint(fig_min,fig_max)
            #border = 35 # random.randint(10,15)

            if fig_type == 0:
                pygame.draw.circle(screen,[r,g,b],[x,y],fig_size)
                register_circle_active = True
                circles_shown += 1
            elif fig_type == 1:
                pygame.draw.rect(screen,[r,g,b],(x,y,fig_size,fig_size))
                register_circle_active = False
            elif fig_type == 2:
                pygame.draw.polygon(screen, [r,g,b], ((x, y), (x+fig_size/2, y+fig_size), (x-fig_size/2, y+fig_size)))
                register_circle_active = False
            
            pygame.display.flip()

            timespan = random.randint(1000,3000)

            #if text_showing is True:
                #show_text()
                #if now - last_text >= textspan:
                    #last_text = float("inf")
                    #text_showing = False
                    # remove text
                    #screen.fill(bg_color, (0, 0, SW, text_y))



        # Get count of joysticks
        joystick_count = pygame.joystick.get_count()
        
        # For each joystick:
        for i in range(joystick_count):
            joystick = pygame.joystick.Joystick(i)
            joystick.init()

        

            


        




