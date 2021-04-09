# frdecap
Auto-decapitalization for pret/pokefirered. Tested on WSL2 Ubuntu 20.04 LTS
Sample results here: https://github.com/lioniac/pokefirered/compare/master...lioniac:decap

## Usage:

1. Copy decap.sh to the base of your pokefirered project
2. (Recommended) Backup your files

```
find ./data/ -depth -print |cpio -pvd BKP
find ./src/  -depth -print |cpio -pvd BKP
```

3. (Optional) Edit `decap.sh` to change/add reserved words you DON'T want to decapitalize:
```
(...)

##--- Vars
RESERVED="HM HP HQ ID KO LR OK OT PA PC PP RS TM TV AKA DMA DNA GBA LOL NES RPG ZZZ NULL"

(...)
```

4. Execute (Run multiple times until you get no outputs):

Simple:
```
clear;./decap.sh
```

Logging with time:
```
clear;{ date;./decap.sh;date; }|tee -a output.txt
```
