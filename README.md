# Dataset kv1000: 1000 protein domains statistically related to RCSB-PDB of 28-Jan-2019

The directory organizes as follows:
```
kv1000/
    Figs/
        'FigA - Time x Threads.png'
        'FigA2 - Time x Threads.png'
        'FigB - Speedup x Threads.png'
        'FigB2 - Speedup x Threads.png'
        'FigC - Efficiency x Threads.png'
        'FigC2 - Efficiency x Threads.png' 
    analysis/
        data/
            processed_time_data.txt
            runtime_kv1000-brasil_parKVFinder_1-24threads.txt
        scripts/
            calculate_speedup_n_efficiency.py
            graphics_kv1000_runtime.R
            runtime_parKVFinder_analysis.py
    kv1000/
        data/
            kv1000_information.txt
        pdbs/
            *.pdb
    runtime/
        1cores/
            *_KVFinder_3run_1cores.csv 
        2cores/
            *_KVFinder_3run_1cores.csv
        4cores/
            *_KVFinder_3run_4cores.csv
        8cores/
            *_KVFinder_3run_8cores.csv
        12cores/
            *_KVFinder_3run_12cores.csv
        16cores/
            *_KVFinder_3run_16cores.csv
        20cores/
            *_KVFinder_3run_20cores.csv
        24cores/
            *_KVFinder_3run_24cores.csv
    .gitignore
    LICENSE
    README.md
```


### analysis directory

This directory contains processed time **data** and **scripts** used to
process raw time data.

**scripts**: 

- runtime_kv1000_analysis.py: get time data from kv1000 dataset. Script
  loops in each directory in runtime/ and read each runtime file
  (<pdb>_<chain>_<n>cores.csv). Return PDB ID, chain, number of atoms,
  number of threads, average runtime and stdev runtime.

```bash
$ python3 runtime_kv1000_analysis.py

OUTPUT DIRECTORY: 
OUTPUT: runtime_kv1000-brasil_parKVFinder_1-24threads.txt

FORMAT:
threads	PDB_ID	chain	atoms	mm_Da	runtime	stdev
12	3KMH	A	1736	28096.5	3.955392599105	0.06330793821533129
```

- calculate_speedup_n_efficiency.py: get time data from runtime_kv1000-brasil_parKVFinder_1-24threads.txt and calculate speedup and efficiency.

```bash
$ python3 calculate_speedup_n_efficiency.py

OUTPUT DIRECTORY: /home/jvsguerra/KVpaper/kv1000-brasil/analysis/data
OUTPUT: processed_time_data.txt
FORMAT:
threads	PDB_ID	chain	atoms	mm_Da	runtime	stdev	speedup	efficiency
12	3KMH	A	1736	28096.5	3.955392599105	0.06330793821533129	6.350739497410172	0.5292282914508476
```

- graphics_kv1000_runtime.R: Integrate runtime_kv1000_analysis.py and calculate_speedup_n_efficiency.py in its pipeline. After, calculate average time, speedup and efficiency for 17 molecular weight intervals. Finally, plots three graphics in ggplot2: Time vs Threads, Speedup vs Threads and Efficiency vs Threads.

```bash
$ Rscript graphics_kv1000_runtime.R

OUTPUT DIRECTORY: /home/jvsguerra/KVpaper/kv1000-brasil/analysis/Figs
OUTPUT: FigA.png, FigB.png, FigC.png
FORMAT: .png
```

### kv1000 directory

This directory contain pdb structures in **pdbs** directory and
statistics (molecular weight (Da) and enzyme classification) in **data**
directory.

### Figs directory

This directory contains charts of time, speedup and efficiency per
number of threads.

### runtime directory

This directory contains raw time data (times of runs in triplicate) of
each pdb structure with different number of OpenMP threads in
parKVFinder.



