# SPIDER Validation Scripts
This Github repository houses the code used to generate the critical figures for Koolik et al., (2022). This Readme document contains information necessary for understanding and running the scripts.

For more information, see Koolik et al. (2022): https://doi.org/10.5194/amt-2021-26

---

### PCVI Transmission Efficiency Code
The code in the `PCVI_Transmission_Efficiency` folder calculates the transmission efficiency and D<sub>50</sub> for the PCVI. The script assumes that the input data come from the TSI Aerosol Instrument Manager (AIM) software. 

#### Requirements
* MATLAB License
* MATLAB Statistics and Machine Learning Toolbox

#### Acknowledgments
This script utilizes the `sigm_fit` function contributed to the MATLAB Central File Exchange by User R P. For more information about the `sigm_fit` function, see the File Exchange here: https://www.mathworks.com/matlabcentral/fileexchange/42641-sigm_fit.

---

### Droplet Evaporation Code
The code in the `Droplet_Evaporation` folder calculates the evaporation of droplets throughout their residence time in the chamber based on an initial droplet size and chamber supersaturation. Droplet evaporation calcualtions are based on [Seinfeld and Pandis 3e (2016)](https://www.wiley.com/en-us/Atmospheric+Chemistry+and+Physics:+From+Air+Pollution+to+Climate+Change,+3rd+Edition-p-9781118947401) and [Lohmann et al. (2016)](https://www.cambridge.org/core/books/an-introduction-to-clouds/F5A8096E7A3BD5C8FFD9208248DD1839).

The model is split into three files. The main file to call is `DropletEvap.m`. The other two files are supporting functions called by `DropletEvap.m`. The main calculation occurs in `easyrt.m`, which estimates the radius of a droplet as a function of time based on Lohmann et al. (2016), equation 7.29. Equation 7.29 from Lohmann et al. (2016), is reproduced below.



#### Requirements
* MATLAB License
