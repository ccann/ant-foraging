;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RED HARVESTER ANT PATROLLING AND FORAGING ;;;;
;;;;;;;;;;;    by Cody Canning   ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; PATROLLING and FORAGING  ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; local patch variables
patches-own [
  chemical             ;; amount of chemical on this patch. Chemical represents food scent
  dufours              ;; amount is dufour's gland secretion on this patch
  food                 ;; amount of food on this patch (0, 1, or 2)
  nest?                ;; true on nest patches, false elsewhere
  nest-scent           ;; number that is higher closer to the nests

]

  
;; global variables  
globals [ 
  coord1 ;; global random variable
  coord2 ;; global random variable
  nest-loc ;; location of the nest
  
  ;; boolean flags for GO procedure
  nest-mound-patrolling? 
  early-patrolling?
  late-patrolling?
  send-foragers?
  ]

;; BREEDS
breed [nest-mound-patrollers nest-mound-patroller] ;; the nest-mound-patrollers
breed [trail-patrollers trail-patroller]           ;; the early trail patrollers
breed [late-patrollers late-patroller]             ;; the late trail patrollers
breed [foragers forager]                           ;; the foragers
breed [neighborhood neighbor]                      ;; a neighboring colony ant
breed [food-claimers food-claimer]                 ;; a patroller that has found food

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup Procedures ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; CALLED ON SETUP BUTTON PRESS
to setup
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks                                                     ;; eliminate anything happening before
  set-default-shape turtles "bug"                               ;; set default shape to bug 
  set nest-loc one-of[[-20 -20] [-40 -40] [-20 -30] [-30 -40]]  ;; list of potential nest locations
  create-nest-mound-patrollers colony-size                      ;; create ants 
  [set size 2                                                   ;; of size 2
    set color red]                                              ;; of color red
  ask nest-mound-patrollers [ setxy (item 0 nest-loc) (item 1 nest-loc) ]   ;; put the turtles at the nest entrance
  set coord1 random 100                                         ;; set coord1 to a random number between 1 and 100
  set coord2 random 100                                         ;; set coord2 to a random number between 1 and 100
  
  ;; Initialize the boolean flags
  set nest-mound-patrolling? true
  set early-patrolling? false
  set late-patrolling? false
  set send-foragers? false
  
  ;; set up the patches
  setup-patches
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; SETUP PATCHES ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-patches  ;; patch procedure
  ask patches 
  [ setup-nest ;; set up the nest patches
    setup-food ;; set up the food patches
    recolor-patch ] ;; recolor all the patches appropriately
end
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; SETUP NEST ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
to setup-nest     ;; patch procedure
  set nest? (distancexy (item 0 nest-loc) (item 1 nest-loc)) < nest-diameter    ;; nest is 25 patches around 
  if (distancexy (item 0 nest-loc) (item 1 nest-loc)) < 2
  [set pcolor brown]
    
  ;; spread a nest-scent over the whole world -- stronger near the nest
  set nest-scent 200 - distancexy (item 0 nest-loc) (item 1 nest-loc)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; SETUP FOOD PATCHES ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-food  ;; patch procedure
  ;; choose 2 semi-random locations to position the food  
  ;; each location will be diameter 9 food patch with 2 food in each patch
  ;; and 1000 chemical in each patch
 
  if ( distancexy (max-pxcor - 17) coord1) < 9
  [ set food 2
    set chemical 1000 ] 
  
  if ( distancexy coord2 (max-pycor - 20) ) < 9
  [ set food 2
    set chemical 1000 ] 
  
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; RECOLOR PATCHES ;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to recolor-patch    ;; patch procedure
  ifelse nest? 
  [set pcolor yellow                                           ;; if the patch is the nest, color it yellow
    if (distancexy (item 0 nest-loc) (item 1 nest-loc)) < 2
  [set pcolor brown]]                                          ;; if the patch is the entrance, color it brown
  [ifelse food > 0
    [set pcolor violet]                                        ;; if the patch is food, color it violet
    [ifelse dufours > 400                 
      [set pcolor green]                                       ;; high concentrations of dufour are colored green
      [set pcolor scale-color magenta dufours 0.1 50]]]        ;; otherwise set the patch to a degree of magenta
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Go procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; INITIATED BY PRESSING THE GO BUTTON

to go
  show ticks                                ;; display the tick number
  
  if early-patrolling?                      ;; if the early patrollers should be out...
  [ 
    ask nest-mound-patrollers             
    [set breed trail-patrollers             ;; transition the nest-mound-patrollers to early trail patrollers  
      set color orange]                     ;; color them orange to differentiate behaviors
  ]
  
  if late-patrolling?                       ;; if the late patrollers should be out...
  [
    ask trail-patrollers 
    [ set breed late-patrollers             ;; transition the early trail patrollers to late trail patrollers
      set color blue ]                      ;; color them blue to differentiate behavior
  ]
  
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;  Behavioral Schema    ;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; behaviors are selected on the basis of which breed is activated ;;
  
  ask nest-mound-patrollers                ;; nest mound behavior
  [nest-mound-patrol]
  
  ask trail-patrollers                     ;; early trail patrol behavior
  [early-patrol]
  
  ask late-patrollers                      ;; late trail patrol behavior
  [late-patrol]
  
  ask-concurrent foragers                  ;; foraging behavior
  [ forage ]
  
 ;;  ask neighborhood
 ;; [ skirt ]
 
 ask food-claimers                         ;; late trail patrol behavior (for the food claimers
 [late-patrol]                             ;; which are a subset of late trail patrollers)
 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;;;;;;;;;;;;;;;;;;;;;;;; Behavioral Tick Hierarchy ;;;;;;;;;;;;;;;;;;;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; set the proper boolean flags depending on the threshold reached by ticks
  
  if(ticks > early-patrol-threshold)    
  [ set nest-mound-patrolling? false     
    set early-patrolling? true
  ]
  
  if(ticks > late-patrol-threshold)
  [ set early-patrolling? false
    set late-patrolling? true
  ]
  
  ;; in this case either the foraging threshold is hit, or (more frequently!) the remaining patrollers outside
  ;; the nest threshold is hit
  
  if (count turtles = remaining-patrollers) 
  [ 
    create-foragers colony-size                       ;; create the foragers at the nest entrance
    [set size 2                                       
      set color red]
    ask foragers [ setxy (item 0 nest-loc) (item 1 nest-loc) ] 
  ]  
  
  if (ticks > end-foraging-threshold)
  [ ask turtles
    [end-of-foraging]                                 ;; end foraging if threshold breached
  ]
             
             
  diffuse dufours .001                                ;; diffuse the chemical scents along neighboring patches
  diffuse chemical .001
  ask patches 
  [ set dufours dufours * (10000 - evaporation-rate) / 10000    ;; slowly evaporate dufour gland secretion
    if food > 0
    [set chemical 1000]                               ;; if there is food on the patch, set the chemical value high
    recolor-patch]                                    ;; doing this ensures that food constantly emanates scent
  
  tick-advance 1                                      ;; advance 1 tick
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; NEST MOUND PATROL ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to nest-mound-patrol ;; turtle procedure
  ifelse ((distancexy (item 0 nest-loc) (item 1 nest-loc)) > nest-diameter - 5)   ;; if too far from the nest...
  [ rt 180                                                         ;; turn 180 degrees
    fd 1                                                           ;; move forward 1 patch
  ]
  [ wiggle ]                                                       ;; otherwise... wiggle!
end  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; EARLY TRAIL PATROL ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to early-patrol ;; turtle procedure
  ifelse  ((distancexy (item 0 nest-loc) (item 1 nest-loc)) > nest-diameter + 8)  ;; if too far from the nest...
  [ rt 180                                                         ;; turn 180 degrees
    fd 1                                                           ;; move forward 1 patch
  ]
  [
    if one-of[1 2] = 2                                             ;; 50/50 chance of wiggling
    [wiggle]                                                       ;; other 50% of the time spent inspecting the ground                                                              ;; and other ants with antennae
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; LATE PATROL ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to late-patrol ;; turtle procedure                                                     
  if breed = food-claimers                                    ;; if a food claimer...
  [return-to-nest                                             ;; activate return to the nest schema and move forward 1 patch
    fd 1]
  
  if breed = late-patrollers                                  ;; if a late trail patroller...
  [ifelse (any? food-claimers in-radius 2)                    ;; are there any food claimers nearby?
    [face (one-of food-claimers in-radius 2)                  ;; if there are, then great! food was found
      set breed food-claimers]                                ;; turn this late trail patroller into a food claimer
    [ifelse (distancexy (item 0 nest-loc) (item 1 nest-loc)) > 70 ;; if far from the nest...
      [food-search                                            ;; search for nearby food by chemical scent
        fd 1]                                                 ;; move forward 1
      [wiggle]]]                                              ;; otherwise wiggle around the map
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; end-of-foraging ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to end-of-foraging ;; turtle procedure
  ifelse (distancexy (item 0 nest-loc) (item 1 nest-loc)) < 2  ;; if close to the nest entrance
  [die]                                                        ;; enter the nest
  [toward-nest-scent ]                                         ;; smell for the nest, move toward it
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; FORAGE ;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to forage  ;; turtle procedure
  if food > 0                                                  ;; if on a food patch...
  [ set color orange + 1                                       ;; pick up food 
    set food food - 1                                          ;; and reduce the food source
    if food = 0                                                ;; if that food patch was just depleted
    [set chemical 0]                                           ;; ... then the smell is gone
    rt 180                                                     ;; turn around, move forward, exit command
    fd 1                                                        
    stop ]

  ifelse color = orange + 1                                    ;; if forager has food to deposit at nest...
  [drop-off-at-nest]                                           ;; deposit food at nest
  [ifelse (distancexy (item 0 nest-loc) (item 1 nest-loc)) < nest-diameter - 1
    [ navigate-to-dufours                                      ;; otherwise if close to nest...
      ifelse random 10 = 1                                     ;; wiggle or move forward
      [wiggle]                                                 
      [fd 1]]
    [ifelse (distancexy (item 0 nest-loc) (item 1 nest-loc)) > nest-diameter + 50
    [navigate-to-chemical                                      ;; otherwise if far from nest...
      fd 1]                                                    ;; navigate to food chemical
    [if one-of[1 2 3] >= 2                                       ;; wiggle or move forward
      [fd 1]]]]                                                  ;; otherwise move forward
                                     
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; RETURN TO NEST WITH SCENT ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to return-to-nest  ;; turtle procedure
  ifelse (distancexy (item 0 nest-loc) (item 1 nest-loc)) < 2      ;; if close to nest entrance...
  [die]                                                            ;; go inside nest
  [ ifelse ((distancexy (item 0 nest-loc) (item 1 nest-loc)) >= nest-diameter 
    and
    (distancexy (item 0 nest-loc) (item 1 nest-loc)) <= nest-diameter + 2)
    [set dufours dufours + 100]                                     ;; ... otherwise secrete dufours at the edge of nest &
    [toward-nest-scent]]                                            ;; head toward the nest
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; DROP OFF FOOD AT NEST ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to drop-off-at-nest  ;; turtle procedure
  ifelse (distancexy (item 0 nest-loc) (item 1 nest-loc)) < 2 
  [                                                             ;; if at nest... drop food and head out again
    set color red                                               ;; set color back to red
    rt 180
    fd 1 ]
  [ toward-nest-scent                                           
    fd 1 ]                                                      ;; & head toward the nest in hopes of dropping off food
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; SEARCH FOR FOOD ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to food-search ;; turtle procedure                                                 
  if food > 0
  [ set color orange + 1                                        ;; if on a food patch... set color to orange and
    set breed food-claimers                                     ;; breed to food claimer 
    rt 180                                                      ;; then turn around and move foward, then exit command
    fd 1
    stop]
  
  ifelse one-of[1 2 3] = 1                                      ;; food claimers don't get here.
  [wiggle]                                                      ;; 33% chance of wiggling, 66% chance of moving toward food
  [navigate-to-chemical]
  
  ;; the reason that wiggling is sometimes uses in this manner is to offset the accuracy of the navigate-to-chemical function
  ;; In simulation, there is no noise in that sensor. However in the real world there are sources of interference.
  
end
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; BORROWED FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; The following functions were modified from the ANT library available with netlogo
;; they are, fortunately, fairly simplistic.    
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; NAVIGATE TOWARD CHEMICAL ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; sniff left and right, and go where the strongest smell of food is.
to navigate-to-chemical  ;; turtle procedure
  let scent-ahead chemical-scent-at-angle   0
  let scent-right chemical-scent-at-angle  45
  let scent-left  chemical-scent-at-angle -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)  ;; if scent ahead is weaker than scent to left or right...
  [ ifelse scent-right > scent-left                             ;; if scent to right is stronger than scent to left...
    [ rt 20                                                     ;; turn right and move foward
      fd 1 ]
    [ lt 20                                                     ;; if scent to left is stronger than scent to right...
      fd 1 ] ]                                                  ;; turn left and move foward
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; NAVIGATE TOWARD DUFOURS ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; sniff left and right, and go where the strongest dufour's pheromone is
to navigate-to-dufours  ;; turtle procedure
  let scent-ahead dufours-scent-at-angle   0
  let scent-right dufours-scent-at-angle  45
  let scent-left  dufours-scent-at-angle -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)  ;; if scent ahead is weaker than scent to left or right...
  [ ifelse scent-right > scent-left                             ;; if scent to right is stronger than scent to left...
    [ rt 20                                                     ;; turn right and move foward
      fd 1 ]
    [ lt 20                                                     ;; if scent to left is stronger than scent to right...
      fd 1 ] ]                                                  ;; turn left and move foward
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; NAVIGATE TOWARD NEST ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; same as above but with nest scent instead of chemical scent.

;; In this implementatio the ants navigate to the nest by scent
;; Red harvester ants use Path Integration and Landmark-based 
;; navigation to return to the nest, as described in the paper
;; and as pseudo-coded in the appendix. 

;; analagous to Seek_Gradient("colony") calling Nest_Enter after receiving
;; a tiny value from Get_Nest_Distance. See Pseudo-Code Appendix.

;; sniff left and right, and go where the strongest smell is
to toward-nest-scent  ;; turtle procedure
  let scent-ahead nest-scent-at-angle   0
  let scent-right nest-scent-at-angle  45
  let scent-left  nest-scent-at-angle -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
  [ ifelse scent-right > scent-left
    [ rt 45
      fd 1 ]
    [ lt 45
      fd 1 ] ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;; WIGGLE ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to wiggle  ;; turtle procedure
  rt random 30                                  ;; turn right between 1 and 40 degrees
  lt random 30                                  ;; turn left between 1 and 40 degrees
  fd 1                                          ;; move foward
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; NEST AND CHEMICAL SCENT RETRIEVERS ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; report the nest or chemical scents at particular angles to the turtle
;; These functions are analagous to reading the sensors of the ant robots
;; and ultimately following the Seek_Gradient function

to-report nest-scent-at-angle [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [nest-scent] of p
end

to-report chemical-scent-at-angle [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [chemical] of p
end
  
to-report dufours-scent-at-angle [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [dufours] of p
end
  
@#$#@#$#@
GRAPHICS-WINDOW
125
38
703
637
120
120
2.36
1
10
1
1
1
0
1
1
1
-120
120
-120
120
1
1
1
ticks
30.0

BUTTON
27
119
91
152
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
26
164
89
197
Go
go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
761
38
933
71
colony-size
colony-size
50
400
120
10
1
NIL
HORIZONTAL

SLIDER
765
149
937
182
early-patrol-threshold
early-patrol-threshold
200
400
300
10
1
NIL
HORIZONTAL

SLIDER
764
205
936
238
late-patrol-threshold
late-patrol-threshold
400
1300
800
10
1
NIL
HORIZONTAL

SLIDER
764
255
936
288
evaporation-rate
evaporation-rate
1
15
7
1
1
NIL
HORIZONTAL

SLIDER
763
305
935
338
remaining-patrollers
remaining-patrollers
1
30
10
1
1
NIL
HORIZONTAL

SLIDER
763
355
922
388
end-foraging-threshold
end-foraging-threshold
2500
3500
2600
100
1
NIL
HORIZONTAL

SLIDER
765
95
938
128
nest-diameter
nest-diameter
25
55
40
1
1
NIL
HORIZONTAL

@#$#@#$#@
Requires NETLOGO

http://ccl.northwestern.edu/netlogo/

## What it is
Agent-based simulation of red harvester ant patrolling and foraging

## How it works

### Patrolling 
The patrolling behavior is broken up into 3 distinct phases

1. "Nest Mound Patrollers" patrol the nest mound, staying very close to the nest entrance. They emerge only for a few minutes and then go back inside. 
2. "Early Trail Patrollers" patrol the immediate vicinity of the nest, stopping frequently to inspect the ground or other ants with their antennae. Usually this last for 5 to 10 minutes.
3. "Late Trail Patrollers" patrol the outer edges of the mound and seek out foraging trails. Their trips are longer, lasting about 20 minutes. These patrollers converge on several paths, which are later used by the foragers.

- Switching between these task phases is simulated with the Tick (time) function. After x amount of time the ants will enter the nest and some will emerge to conduct the next task. In the simulation the ants do not enter the nest, they change color to demonstrate the switch in task. The task switching criterion are further fleshed out in the accompanying paper.

- Recruitment of unsuccessful patrollers by successful patrollers is implemented here. Patrollers returning from a discovered food source to the nest will recruit other patrollers to follow them back to the nest and secrete Dufour's pheromone. This method leads to an increase in the amount of chemical indicating the direction of major food sources.

- If a patroller encounters an ant from a different colony, it will not take a direct route back to the nest. Instead it will wander and come back to the nest from another side, making sure not to secrete chemicals leading to the encounter. Other patrollers secrete chemicals at the nest edge for the foragers to use later (Gordon, 99). This is not yet implemented in this program.

- Patrollers identify ants as members of the same colony by their breed (see global variables). However, since there are currently no ants from other colonies in this model, they never need to use a function like Identify() in the Appendix. 

### Foraging
- Foragers exit the nest as the last few patrollers make their way back. They follow the paths left by the patrollers in order to seek out food, then return to the nest entrance to deliver it. Foragers will only forage food along the paths laid out by the patrollers. Foragers that return to the nest entrance to drop off food will then turn back around and continue to seek food, but this may or may not be a different ant. This simulation does not give any indication of it being a different ant, since the goal is only to have a constant number of ants foraging.

- An ant in the nest will go out to forage depending on the rate of foragers that return to the nest with food. The rate at which successful foragers return correlates with food availability - in the case of red harvester ants seeds are distributed by wind and flooding, as previously stated, and as such will probably be in a similar location when the foragers emerge after the patrollers. Some researchers speculate that there is a threshold, in numbers or rate of returned patrollers, that is required for foraging to begin (Gordon 2002). Once foraging has begun the return of successful foragers has only a very small effect on the likelihood that other foragers will leave the nest (Gordon 2002).

- This simulation demonstrates a bout of foraging that takes place after patrolling. After an arbitrary amount of time (end-foraging-threshold parameter) the foragers return to the nest. The chemical secreted by patrollers from the nest mound to the food source is called Dufour's gland secretion. Red harvester ants typically do NOT leave a path of gland secretion all the way to the food source, they merely secrete chemical on a 20 cm sector of the mound that centrally directs the foraging behavior outward.

- Recruitment behavior in foragers is not implemented in this program. Typically ants that encounter multiple food sources, such as a few seeds gathered together, recruit another forager on their second trip from the nest to forage (Moglich, et al., 1974). This tandem recruitment behavior requires the leader ant to slow down in order to ensure that the follower can keep up on the way to the food source. Once they have reached the food, the leader decouples the follower.

### Implementation
- It turns out that calculating a straight trajectory from the center of the nest through a high concentration of dufour gland secretion at the edge of the nest is very difficult in Netlogo. As a result, the ants navigate toward the dufour gland secretion until they leave the nest, at which point they travel straight, for the most part, until they're far away and can look for food patches in their immediate vicinity with chemical detectors.

## How To Use It

Optimal performance is achieved with an evaporation rate between 5 and 10. The trade off is between the retention of foraging paths as laid out by patrollers and the time spent idling in areas of high chemical diffusion but depleted food source.

The program displays the current Tick number at the bottom in the observer context. 100 Ticks represents one minute.

Do not adjust the threshold values unless you want to speed up phase transition. The end-patrol-threshold is a backup threshold that will only trigger if the late trail patrollers fail to return to the nest after "20 minutes"

Sometimes an ant will get stuck moving vertically or horizontally across the screen. I'm not sure why this happens, and I've spent too long trying to fix it. The evaporation rate of the chemical ensures this isn't too problematic

### Ant Colors
Initially the nest mound patrollers are red. The early trail patrollers are orange. The late trail patrollers are blue. When late trail patrollers find food they become part of the food claimers breed, which is light orange. Foragers are red, or orange if they have food and are returning to the nest.

### Patch Colors 
The YELLOW circle is the nest mound. The BROWN center is the nest entrance. The VIOLET circles are food deposits, i.e. seeds. Patches vary in MAGENTA as the dufour scent diffuses builds up as deposited by patrollers. High concentrations of dufour gland secretion are colored GREEN. Use a world size of 130 by 130. This isn't VERY important, but it's a good size.

### NOTE
Sometimes on the first run of the application the foragers never leave the nest. This bug is annoying and seemingly impossible to fix. If it happens, re-setup and run again.

### Slider Parameters
- colony-size: the number of ants that emerge from the nest
- nest-diameter: the diameter of the nest
- early-patrol-threshold: the tick threshold at which the nest mound patrollers become early trail patrollers
- late-patrol-threshold: the tick threshold at which the early trail patrollers become late trail patrollers.
- end-foraging-threshold: the tick threshold for ending the foraging behavior and sending the foragers back to the nest
- evaporation rate: lower values indicate a slower evaporation rate of the chemical pheromone indicating a path to food
- remaining patrollers: the number of patrollers still present outside the nest that triggers the release of the foraging ants                 
 

@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
