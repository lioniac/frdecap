# frdecap
Auto-decapitalization for pret/pokefirered

## Usage:

1. Copy decap.sh to the base of your pokefirered project
2. (Recommended) Backup your files

```
find ./data/ -depth -print |cpio -pvd BKP
find ./src/  -depth -print |cpio -pvd BKP
```

3. Execute:

3.1. Simple:

```
clear;./decap.sh
```

3.2. Logging with time:

```
clear;{ date;./decap.sh;date; }|tee -a output.txt
```
