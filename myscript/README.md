## Scripts to test Benchmarks
---
To test Benchmarks of splash3, NPB and stamp:

```bash
sudo ./prepare_ramfs.sh username username #to mount ram to contain inputs file
./splash3_script.sh #to test splash3 benchmarks
./npb_script.sh #to test nas parallel benchmarks
./stamp_script.sh #to test stamp benchmarks
./data.sh #to collect all the data
./remove_ramfs.sh #to unmount ram
```

This will create a folder *likwid-output* containing many all the results.

### config.sh:
*config.sh* is imported by *NameOfSuite_script.sh* and in *data.sh*

You need to modify group event to test with **likwid**: *LIKWID_G*

You need to specify list of thread cores of your system: *THREAD_ID_LIST*, *TOT_THREADS*

You need to specify total number of runs you want to execute: *RUNS*, *TOT_RUNS*

If you don't want to execute all the benchmarks you need to modify *BENCHS_NameOFSuite*, *BENCHS_NAME_NameOfSuite* and *avg.py*