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
 

