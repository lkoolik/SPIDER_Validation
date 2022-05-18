#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Feb 15 13:05:01 2022

@author: christopherrapp
"""

#%%
import os
import re
import runpy
import numpy as np
import pandas as pd
from datetime import datetime
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit

# USER DEFINED!
# SET ANALYSIS TYPE
calibration_type = ['spider', 'l_pcvi', 'pcvi'][1]
sampling_type = ['aps', 'ops'][0]

# Location of files necessary
import_files = '/Users/christopherrapp/Documents/Purdue/Data_SPIDER/calibrations/import/' + calibration_type + '/' + sampling_type + '/'

# Location to send results
export_results = '/Users/christopherrapp/Documents/Purdue/Data_SPIDER/calibrations/export/' + calibration_type + '/'

# Location to send plots
export_plots = '/Users/christopherrapp/Documents/Purdue/Data_SPIDER/calibrations/plots/' + calibration_type + '/'

try :
    # List directories in import directory
    dated_directories = [d for d in os.listdir(import_files) if not(d.startswith('.'))]
    
    directories = []
    for i in range(0, len(dated_directories), 1):
        directories.append(import_files + dated_directories[i] + '/csv_files/')
        
    del dated_directories, i
    
except FileNotFoundError:
    
    print('No files exist for these settings')
    

#%%

# OPEN MAIN LOOP
# THIS

for a in range(0, len(directories), 1):
    
    directory = directories[a]
    
    files = [d for d in os.listdir(directory) if not(d.startswith('.'))]

    # Initialize dictionary
    F = {
        'File': [],
        'File Path': [],
        'Date': [],
        'Time': [],
        'L-PF': [],
        'L-AF': [],
        'L-SF': [],
        'S-PF': [],
        'S-AF': [],
        'S-SF': [],
        'AIF': [],
        'Temperature': [],
        'L-PCVI Total Inlet Flow': [],
        'S-PCVI Total Inlet Flow': [],
        'EF L-PCVI': [],
        'EF S-PCVI': [],
        'L-PCVI AF:IF Ratio': [],
        'S-PCVI AF:IF Ratio': [],
        'Type': [],
        'Experiment Set #': []
    }
    
    # Loop through the files in selected directory
    # Files should have a set appended to the end
    for i in range(0, len(files), 1):
        
        # Temporary variable
        X = files[i]
    
        # Define paths
        file = directory + X
    
        F['File'].append(X)
        F["File Path"].append(file)
    
        # Date and time
        date = str(re.findall(r'2021\d{4}', file)).replace('_', '').replace("['", '').replace("']", '')
        date = date[0:4] + '-' + date[4:6] + '-' + date[6:8]
        F['Date'].append(date)
    
        time = str(re.findall(r'_\d{4}', file)).replace('_', '').replace("['", '').replace("']", '')
        time = time[0:2] + ':' + time[2:4]
        F['Time'].append(time)
            
        # Pump flows
        L_PF = str(re.findall(r'L-PF\d+[_]?\d*', file))
        L_PF = float(L_PF.replace('_', '.').replace('L-PF', '').replace("['", '').replace("']", ''))
        
        S_PF = str(re.findall(r'S-PF\d+[_]?\d*', file))
        
        if S_PF == '[]':
            S_PF = 0
        else:
            S_PF = float(S_PF.replace('_', '.').replace('S-PF', '').replace("['", '').replace("']", ''))



        F['L-PF'].append(L_PF)
        F['S-PF'].append(S_PF)
    
        # Add flows
        L_AF = str(re.findall(r'L-AF\d+[_]?\d*', file))
        L_AF = float(L_AF.replace('_', '.').replace('L-AF', '').replace("['", '').replace("']", ''))
        F['L-AF'].append(L_AF)
    
        S_AF = str(re.findall(r'S-AF\d+[_]?\d*', file))
        S_AF = float(S_AF.replace('_', '.').replace('S-AF', '').replace("['", '').replace("']", ''))
        F['S-AF'].append(S_AF)
    
        # For the SPIDER system the SF for the L-PCVI should be the inlet flow for the S-PCVI
        # However the SF for L-PCVI may be 0 in filenames
        L_SF = str(re.findall(r'L-SF\d+[_]?\d*', file))
        
        if L_SF == '[]':
            L_SF = 0
        else:
            L_SF = float(L_SF.replace('_', '.').replace('L-SF', '').replace("['", '').replace("']", ''))
    
        S_SF = str(re.findall(r'S-SF\d+[_]?\d*', file))
        S_SF = float(S_SF.replace('_', '.').replace('S-SF', '').replace("['", '').replace("']", ''))
        F['S-SF'].append(S_SF)
    
        # Aerosol intake flow (flow used in particle generation)
        AIF = str(re.findall(r'AIF\d+[_]?\d*', file))
        AIF = float(AIF.replace('_', '.').replace('AIF', '').replace("['", '').replace("']", ''))
        F['AIF'].append(AIF)
        
        # If the chiller was being used, find the temperature it was set to
        temperature = str(re.findall(r'chiller \-\d+', file, re.IGNORECASE))
        
        if temperature != '[]':
            temperature = float(temperature.replace('CHILLER', '').replace('chiller', '').replace("['", '').replace("']", ''))
        
        F['Temperature'].append(temperature)
    
        # Sample type
        # Experiments include an inlet file and outlet file to calculate the transmission efficiency
        experiment_number = int(str(re.findall(r'\d{1,2}(?=\.csv)', file)).replace('_', '').replace('.csv', '').replace("['", '').replace("']", ''))
        F['Experiment Set #'].append(experiment_number)
        
        flow_sums = L_PF + S_PF + L_AF + S_AF + L_SF
        if flow_sums == 0:
            experiment_type = "Inlet"
        else:
            experiment_type = "Outlet"
            
        if L_SF == 0:
            L_SF = S_PF + S_SF - S_AF
            F['L-SF'].append(L_SF)
        
        F['Type'].append(experiment_type)
        
        # This is also the L_PCVI outlet flow
        # The outlet of the S-PCVI is simply the sample flow
        S_PCVI_Inflow = S_PF + S_SF - S_AF
        
        # The inlet flow of the L-PCVI is AIF and L-AF 
        L_PCVI_Inflow = L_PF + L_SF - L_AF
        
        F['L-PCVI Total Inlet Flow'].append(L_PCVI_Inflow)
        F['S-PCVI Total Inlet Flow'].append(S_PCVI_Inflow)
        
        # Calculate the efficiences
        EF_S_PCVI = S_PCVI_Inflow/S_SF
        EF_L_PCVI = L_PCVI_Inflow/S_PCVI_Inflow
        
        # Append to the dictionary
        F['EF L-PCVI'].append(EF_L_PCVI)
        F['EF S-PCVI'].append(EF_S_PCVI)
        
        # Calculate AF:IF Ratios
        F['L-PCVI AF:IF Ratio'].append(round(L_AF/L_PCVI_Inflow, 2))
        F['S-PCVI AF:IF Ratio'].append(round(L_AF/S_PCVI_Inflow, 2))
        
        # Dataframe conversion
        file_info_df = pd.DataFrame.from_dict(F, orient = 'index').transpose()
        
    # Read in OPS data for each file
    experiments = list(set(list(file_info_df['Experiment Set #'])))
    
    str(file_info_df["Type"].str.findall('inlet', flags = re.IGNORECASE))
    
    # Initialize dictionary
    results = {
        'Date': [],
        'Experiment ID': [],
        'L-PF': [],
        'L-AF': [],
        'L-SF': [],
        'S-PF': [],
        'S-AF': [],
        'S-SF': [],
        'AIF': [],
        'Temperature': [],
        'L-PCVI Total Inlet Flow': [],
        'S-PCVI Total Inlet Flow': [],
        'Enrichment Factor L-PCVI': [],
        'Enrichment Factor S-PCVI': [],
        'Dilution Effect': [],
        'L-PCVI AF:IF Ratio': [],
        'S-PCVI AF:IF Ratio': [],
        'Maximum Transimission Efficiency': [],
        'D50': [],
        'D50 SD': []
        }
    
    # Loop through dated directories for all matched inlet and outlet files
    for i in experiments:
        
        # Create a temporary variable of the file information dataframe
        Y = file_info_df.loc[file_info_df["Experiment Set #"] == i, :]
        
        # Experiment ID
        experiment_id = i
    
        # Seperate files based on type
        inlet = Y.loc[Y['Type'] == "Inlet"]
        outlet = Y.loc[Y['Type'] == "Outlet"]
    
        # Use pd.read_csv() to read in the OPS data
        OPS_IN = pd.read_csv(inlet["File Path"].iloc[0], sep = ',', skip_blank_lines = True, skiprows = 26,
                             header = 0, decimal = '.', dtype = "float64")
        
        # Calculate the mean concentrations over the concentration columns
        OPS_IN["Inlet Mean Concentration"] = OPS_IN[OPS_IN.columns[pd.Series(OPS_IN.columns).str.startswith('Data')]].mean(axis = 1)
        OPS_IN["Diameter Midpoint"] = OPS_IN['MPDiam'].round(2)
        
        # Loop through each outlet file to calculate the outlet concentrations
        for j in range(0, len(outlet), 1):
            
            # Retrieve flow values from file information dataframe
            parameters = outlet.loc[:, 'Date':'S-PCVI AF:IF Ratio'].iloc[j]
                            
            # Temperature string
            if parameters[9] != '[]':
                temperature = parameters[9]
            else:
                temperature = ''
            
            # Use pd.read_csv() to read in the OPS data
            OPS_OUT = pd.read_csv(outlet["File Path"].iloc[j], sep = ',', skip_blank_lines = True, skiprows = 26,
                                 header = 0, decimal = '.', dtype = "float64")
            
            # Calculate the mean concentrations over the concentration columns
            OPS_OUT["Outlet Mean Concentration"] = OPS_OUT[OPS_OUT.columns[pd.Series(OPS_OUT.columns).str.startswith('Data')]].mean(axis = 1)
            OPS_OUT["Diameter Midpoint"] = OPS_OUT['MPDiam'].round(2)
            
            # Formatting and adding columns
            data_df = OPS_IN[['Diameter Midpoint', 'Inlet Mean Concentration']].copy(deep = True)
            data_df['Outlet Mean Concentration'] = OPS_OUT["Outlet Mean Concentration"]
            
            # Append flows to data_df
            data_df['L-PF'] = round(parameters['L-PF'], 2)
            data_df['L-AF'] = round(parameters['L-AF'], 2)
            data_df['L-SF'] = round(parameters['L-SF'], 2)
            data_df['S-PF'] = round(parameters['S-SF'], 2)
            data_df['S-AF'] = round(parameters['S-AF'], 2)
            data_df['S-SF'] = round(parameters['S-SF'], 2)
            data_df['AIF'] = parameters['AIF']
            data_df['L-PCVI Total Inlet Flow'] = parameters['L-PCVI Total Inlet Flow']
            data_df['S-PCVI Total Inlet Flow'] = parameters['S-PCVI Total Inlet Flow']
            data_df['EF L-PCVI'] = parameters['EF L-PCVI']
            data_df['EF S-PCVI'] = parameters['EF S-PCVI']
            data_df['L-PCVI AF:IF Ratio'] = parameters['L-PCVI AF:IF Ratio']
            data_df['S-PCVI AF:IF Ratio'] = parameters['S-PCVI AF:IF Ratio']
            
            # Calculate the dilution effect
            data_df['Dilution Effect'] = data_df['AIF']/data_df['L-PCVI Total Inlet Flow']
            
            # Diluted inlet concentration
            data_df['Diluted Inlet Concentration'] = data_df['Inlet Mean Concentration'] * data_df['Dilution Effect']
            
            # Enrichment factor
            data_df['EF'] = data_df['EF L-PCVI']*data_df['EF S-PCVI']
            
            # Transimission Efficiency
            data_df['Transmission Efficiency'] = data_df['Outlet Mean Concentration']/(data_df['Diluted Inlet Concentration'] * data_df['EF']) 
        
            # Mask any inf values with NaN
            # These values will mess with any curve fitting
            data_df = data_df.mask(np.isinf(data_df))
            
            # Extract time variables
            date = parameters['Date']
            time = parameters['Time'].replace(':', '')
            
            if temperature != '':
                
                # Generate a filename
                file_label = date+"_"+time+"_L-PF"+str(data_df['L-PF'][0])+"_L-AF"+str(data_df['L-AF'][0])+"_L-SF"+str(data_df['L-SF'][0])+"_S-PF"+str(data_df['S-PF'][0])+"_S-AF"+str(data_df['S-AF'][0])+"_S-SF"+str(data_df['S-SF'][0])+"_AIF"+str(data_df['AIF'][0])+ "_chiller_temperature_" + str(temperature) + "_export.csv"
            else:
                # Generate a filename
                file_label = date+"_"+time+"_L-PF"+str(data_df['L-PF'][0])+"_L-AF"+str(data_df['L-AF'][0])+"_L-SF"+str(data_df['L-SF'][0])+"_S-PF"+str(data_df['S-PF'][0])+"_S-AF"+str(data_df['S-AF'][0])+"_S-SF"+str(data_df['S-SF'][0])+"_AIF"+str(data_df['AIF'][0])+ "_export.csv"
            
            file_nm = export_results + file_label
            
            data_df.to_csv(file_nm)

            #%% PLOTS
            
            # SIZE DISTRIBUTIONS
            # ---------------------------------------------- #
            
            # Set plotting style
            plt.style.use('ggplot')
    
            # Define figure axes and subplots
            fig, (ax1, ax2) = plt.subplots(2, 1, figsize = (16, 16))
    
            # Create a title string
            plot_title1 = "SPIDER Size Distributions - " + date
            
            plot_title2 = "L-PF: "+str(data_df['L-PF'][0])+", L-AF: "+str(data_df['L-AF'][0])+", L-SF: "+str(data_df['L-SF'][0])+", S-PF: "+str(data_df['S-PF'][0])+", S-AF: "+str(data_df['S-AF'][0])+", S-SF: "+str(data_df['S-SF'][0])+", AIF: "+str(data_df['AIF'][0])
            
            plot_title3 = "AF:IF Ratios - L-PCVI: " + str(round(data_df['L-PCVI AF:IF Ratio'][0], 3)) + ', S-PCVI :' + str(round(data_df['S-PCVI AF:IF Ratio'][0], 3))
            
            fig.suptitle(plot_title1, weight = 'demibold', size = 16, y = 0.93)
    
            # Indices for plot using list comprehension
            idx = np.asarray([i for i in range(len(data_df['Diameter Midpoint']))])
    
            idx = idx + 1
    
            # Define width
            width = 0.8
    
            # Create bars
            bar1 = ax1.bar(x = idx, height = data_df['Inlet Mean Concentration'], width = width, align = "center", alpha = 0.5)
            bar2 = ax1.bar(x = idx, height = data_df['Outlet Mean Concentration'], width = width, align = "center", alpha = 0.5)
    
            # Plot cosmetics
            ax1.set_title(plot_title2, loc = "left")
            ax1.set_title(plot_title3, loc = "right")
            ax1.set_xticks(idx)
            ax1.set_xticklabels(data_df['Diameter Midpoint'], rotation = 90)
            ax1.set_xbound(lower = 0, upper = len(data_df['Diameter Midpoint'])+1)
            ax1.text(-0.075, 0.5, r'Mean Concentration $\mathrm{(cm^{-3})}$', rotation = 90, size = 12, weight = 'normal', verticalalignment='center', horizontalalignment='right', transform = ax1.transAxes)
    
            ax1.legend([bar1, bar2], ['Inlet', 'Outlet'])
            
            # TRANSMISSION EFFICIENCY PLOT
            # Accounts for dilution effect and enhancement factor
            # ------------------------------------------------------------------- #
    
            # Remove NaN's to prevent errors in curve fitting
            data_df = data_df.dropna(thresh = 10)
    
            # Specify variables used in plotting
            xdata = data_df["Diameter Midpoint"]
            xdata_max = round(max(xdata), 1)
            xdata_min = round(min(xdata), 1)
            ydata = data_df["Transmission Efficiency"]
    
            # Create a numpy array of diameter midpoints
            idx = np.asarray([i for i in range(len(data_df['Diameter Midpoint']))])
            
            # Plot transmission data
            ax2.scatter(xdata,ydata)
            ax2.set_xlabel(r'Aerodynamic Diameter $\mathrm{(\mu m)}$', size = 12, labelpad = 20)
            ax2.text(-0.075, 0.5, "Transmission Efficiency", rotation = 90, size = 12, weight = 'normal', verticalalignment='center', horizontalalignment='right', transform = ax2.transAxes)
            ax2.set_xticks(idx)
            ax2.set_xlim(right = (xdata_max + 1))
            
            # CURVE FITTING
            # ------------------------------------------------------------------- #
            
            # Define the sigmoid function
            def sigmoid(x, L ,x0, k, b):
                y = L / (1 + np.exp(-k*(x-x0)))+b
                return (y)
    
            # Define L
            L = max(data_df['Transmission Efficiency']) # The maximum transmission efficiency
    
            # Initial guess for curve_fit model
            # REQUIRED guess to prevent RuntimeErrors from occuring constantly
            p0 = [max(ydata), np.median(xdata), 1, min(ydata)]
    
            try :
                # Fit a sigmoid to the data to idenitfy the cut point
                # Dogbox method is the most accurate however most computationally expensive
                # Absolute sigma is not necessary here
                popt, pcov = curve_fit(sigmoid, xdata, ydata, p0, method = 'dogbox', absolute_sigma = False, maxfev = 1000)
                
                failed = 0
                
                print(calibration_type + ' ' + date + " Experiment ID " + str(experiment_id))
    
            except RuntimeError:
                print(calibration_type + ' ' + date + " Experiment ID " + str(experiment_id) + " Error - curve_fit failed")
                
                failed = 1
    
            # Generate 1000 evenly spaced values between 0 and the maximum midpoint
            # y values are the corresponding model results
            x = np.linspace(xdata_min, xdata_max, 1000)
            
            if temperature != '':
                    
                plot_title4 = "Temperature (C) " + str(temperature)
                
                ax2.set_title(plot_title4, loc = 'right', size = 10)
            
            if failed == 0:
                
                # Calculate sigma values
                sigma = np.sqrt(np.diagonal(pcov))
        
                # Extract the cut-point
                D50 = popt[1]
                D50_rounded = round(D50, 2)
                
                # Extract the standard deviation corresponding to the cut point
                D50_sigma = sigma[1]
                D50_sigma = round(D50_sigma, 2)
                
                y = sigmoid(x, *popt)
                
                if D50 > 0:
                
                    # Plot best fit curve
                    ax2.plot(x, y, color = 'black', linestyle = '--')
        
                    ax2.plot(D50, sigmoid(D50, *popt), 'x', color = 'blue')
                    ax2.errorbar(x = D50, y = sigmoid(D50, *popt), xerr = D50_sigma, color = 'black')
    
                    D50_label = r'Calculated $\mathrm{D_{50} = }$ ' + str(D50_rounded) + r' $\mathrm{\pm}$ ' + str(D50_sigma)
        
                    ax2.legend(["Best Fit Curve", D50_label, "Transmission Efficiencies"])
                
                    ax2.set_title("Curve Fitting Successful", loc = 'left', size = 10)
                    
                else:
                    
                    ax2.set_title("Curve Fitting Unsuccessful (negative values)", loc = 'left', size = 10)
                
                # Generate a figure label for the filename
                figure_label = date+"_"+time+"_L-PF"+str(data_df['L-PF'][0])+" L-AF "+str(data_df['L-AF'][0])+" L-SF "+str(data_df['L-SF'][0])+" S-PF "+str(data_df['S-PF'][0])+" S-AF "+str(data_df['S-AF'][0])+" S-SF "+str(data_df['S-SF'][0])+" AIF "+str(data_df['AIF'][0]) + "_Results" + ".png"
                figure_nm = export_plots + figure_label
                
                # Save the figure
                plt.savefig(figure_nm, format = 'png', dpi = 400)
    
                plt.close()
                
            if failed == 1:
                
                ax2.set_title("Curve Fitting Failed", loc = 'left', size = 10)
    
                # Generate a figure label for the filename
                figure_label = date+"_"+time+"_L-PF"+str(data_df['L-PF'][0])+" L-AF "+str(data_df['L-AF'][0])+" L-SF "+str(data_df['L-SF'][0])+" S-PF "+str(data_df['S-PF'][0])+" S-AF "+str(data_df['S-AF'][0])+" S-SF "+str(data_df['S-SF'][0])+" AIF "+str(data_df['AIF'][0]) + "_CurveFittingFailed" + ".png"
                figure_nm = export_plots + figure_label
                
                # Save the figure
                plt.savefig(figure_nm, format = 'png', dpi = 400)
    
                plt.close()
            
            #%% RESULTS
            
            # Append results to dictionary
            results['Date'].append(date)
            results['Experiment ID'].append(experiment_id)
            results['L-PF'].append(round(data_df['L-PF'][0], 2))
            results['L-AF'].append(round(data_df['L-AF'][0], 2))
            results['L-SF'].append(round(data_df['L-SF'][0], 2))
            results['S-PF'].append(round(data_df['S-PF'][0], 2))
            results['S-AF'].append(round(data_df['S-AF'][0], 2))
            results['S-SF'].append(round(data_df['S-SF'][0], 2))
            results['AIF'].append(data_df['AIF'][0])
            results['Temperature'].append(temperature)
            results['L-PCVI Total Inlet Flow'].append(round(data_df['L-PCVI Total Inlet Flow'][0], 2))
            results['S-PCVI Total Inlet Flow'].append(round(data_df['S-PCVI Total Inlet Flow'][0], 2))
            results['Enrichment Factor L-PCVI'].append(round(data_df['EF L-PCVI'][0], 2))
            results['Enrichment Factor S-PCVI'].append(round(data_df['EF S-PCVI'][0], 2))
            results['Dilution Effect'].append(round(data_df['Dilution Effect'][0], 2))
            results['L-PCVI AF:IF Ratio'].append(round(data_df['L-PCVI AF:IF Ratio'][0], 2))
            results['S-PCVI AF:IF Ratio'].append(round(data_df['S-PCVI AF:IF Ratio'][0], 2))
            results['Maximum Transimission Efficiency'].append(round(L, 2))
    
            if failed == 0:
                if D50 > 0:
                    results['D50'].append(D50_rounded)
                    results['D50 SD'].append(D50_sigma)
                else:
                    results['D50'].append("Failed")
                    results['D50 SD'].append("Failed")
            else:
                results['D50'].append("Failed")
                results['D50 SD'].append("Failed")
                
            # Dataframe conversion
            results_df = pd.DataFrame.from_dict(results, orient = 'index').transpose().sort_values("Date", ascending = False).reset_index().drop(columns = ["index"])
            
            # Find the current time for exporting data
            sys_time = str(datetime.now())[0:10]
            sys_time
            
            # Filename
            file_nm = export_results + "LPCVI_results_summary_" + sys_time + ".csv"
            
            # Export as a csv
            results_df.to_csv(file_nm)

                #%% END































