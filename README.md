# SondeLidarCompTool
Simple group of programs meant to compare ozonesonde and ozone lidar data from the OWLETS-2 Campaign. 

Note: This is a *very* simple set of scripts, meant to be run individually (working on consolidating them). It is composed of 2 parts.

One is a MATLAB script that decompiles the sonde ICARtT file as well as the lidar .h5 file. You'll need the Glen Wolfe's Glen Wolfe, ICARTTreader function which can be found [here](https://github.com/AirChem/DataHandling/blob/master/ICARTTreader.m). 

The other is a Python script that ingests the processed data to plot comparision charts.
Matplotlib and Pandas are required packages.

**It is also very important that you read the begining of both scripts as this process requires you to enter in the pathnames of several files.**
