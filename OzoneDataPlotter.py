# -*- coding: utf-8 -*-
"""
Created on Sun Feb 21 21:41:15 2021

@author: Amanze Ejiogu

Name: OzoneDataPlotter.py
Description:This portion of the program will plot datasets for comparison. It 
does this for 2 plots: Plot 1 compares the potential temperature (K), dry mixing
ratio, and saturated mixing ratio vs altitude (m). Plot 2 compares the measured
O3 concentration with the estimated measurements from the ozone lidar, along with 
its margin of error
"""
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

#Enter the location of the processed data file
data_loc = "C:/Users/BOSS COMPUTER/Documents/Hart Miller Island 2018/Plotting Data/ProcessedData.csv"

#def OzoneDataPlotter(data_loc):
data = pd.read_csv(data_loc)
ozone = data.O3
alt = data.Alt
theta_k = data.Theta_K
mixing_ratio = data.MR
sat_mixing_ratio = data.SMR
ozone_est = data.EstO3
ozone_uncert = data.O3Uncert

#Here, the potential temperature is plotted with the mixing ratio
comp_fig,ax1 = plt.subplots()

#Adding Potential Temperature Values
ax1.plot(theta_k,alt,label= "Potential Temperature",color="blue")
ax1.set_xlabel("Potential Temperature (K)", color="blue")
ax1.set_ylabel("Altitude (m)")
ax1.set_title("Theta K & Mixing Ratio vs Altitude ")

#Adding Mixing Ratio Values
ax2 = ax1.twiny()
ax2.plot(mixing_ratio,alt, label= "Mixing Ratio",color="orange")
ax2.set_xlabel("Mixing Ratio", color="orange")
#ax3 = ax2.twinx(), ax1 =.twiny()
ax2.plot(sat_mixing_ratio,alt, label= "Saturated Mixing Ratio", color ="green")
comp_fig.legend(loc= "lower right",bbox_to_anchor=(0.98, 0.15),
                prop={'size': 8}, ncol = 1)

plt.tight_layout()    
plt.savefig("Mixing Ratio & Potential Temp.jpg", dpi = 600) 

plt.show()

#Now, we plot both the sonde ozone and predictive ozone
comp_fig,ax3 = plt.subplots()
ax3.set_xlabel("Ozone Concentration (ppbv)")
ax3.set_ylabel("Altitude (m)")
ax3.set_title("Sounding O3 and Lidar Est O3 vs Altitude ")

ax3.plot(ozone,alt, label= "Sounding Ozone",color="red")
ax3.plot(ozone_est,alt, label= "Lidar Estimated Ozone",color="orange")

plt.fill_betweenx(alt, ozone_est-ozone_uncert, ozone_est+ozone_uncert, alpha = 0.6, color= "orange")
comp_fig.legend(loc= "lower right",bbox_to_anchor=(0.9, 0.15),
                prop={'size': 8}, ncol = 1)
plt.savefig("Ozone.jpg", dpi = 600) 
plt.show()

    