## DSTcode: distractor-supported single target tracking in extremely cluttered scenes

### Introduction

DSTcode is a state-of-the-art visual tracker for single target tracking in RGB images under conditions of extreme clutter and camouflage, including frequent occlusions by objects with similar appearance to the target. 

### Citation

If you find the code and dataset useful in your research, please consider citing:

    @inproceedings{Tracking2016Xiao,
        title={Distractor-supported single target tracking in extremely cluttered scenes},
        Author = {Xiao, Jingjing and Qiao, Linbo and Stolkin, Rustam and Leonardis, Ale\v{s}},
        booktitle = {ECCV},
        Year = {2016}
    }

### License

This software is being made available for research purpose only.

### Learning DST tracker

The code is compatiable with [OTB protocol](http://cvlab.hanyang.ac.kr/tracker_benchmark/index.html). If you want to use DST on your own sequences, please edit the file "init_seq.m" and run "run_DST.m".

Download: Paper, Dataset, Results in paper, Results on OTBdataset (OPE on 100 sequences).