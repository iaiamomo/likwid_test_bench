## Scripts to test Benchmarks
---
To test Benchmarks of NPB:

```bash
sudo ./prepare_ramfs.sh username username #to mount ram to contain inputs file and to check access to msr registers
./npb_script.sh #to test nas parallel benchmarks
./data.sh #to collect all the data
./plot.sh #to create plots of the metrics
./remove_ramfs.sh #to unmount ram
```

The output of these scripts will be a folder *likwid-output* containing all the results.

### config.sh:
  - *config.sh* is imported by *NameOfSuite_script.sh* and in *data.sh*.
  - You need to modify group event to test with **likwid**: *LIKWID_G*.
  - You need to specify the number of physical core: *N_PHISICAL_CORE*.
  - You need to specify total number of runs you want to execute: *RUNS*, *TOT_RUNS*.
  - If you don't want to execute all the benchmarks you need to modify *BENCHS_NameOFSuite*, *BENCHS_NAME_NameOfSuite* and variables in *avg_run.py*.

If you want to execute a differnt group event you need to create a *collect_NameOfGroup.py* file where you collect all the output of LIKWID and you need to modify *avg_run.py* to do the average of the results. Look at *collect_monti.py* and *avg_run.py* in the part related to MONTI group.