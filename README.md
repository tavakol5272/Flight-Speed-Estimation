## Extract Two Movement Speeds

MoveApps

Github repository: *github.com/movestore/Flight-Speed-Estimation*

## Description
This App fits a bimodal model to the ground-speed distribution of each track. It identifies two peaks, called modes, and the minimum between them, called the antimode. 
The antimode serves as a track-specific threshold for separating lower-speed, non-flight locations from higher-speed, likely flight locations.

The App produces a table containing the estimated mode1, antimode, mode2, and the mean and standard deviation of speeds above the antimode.

## Documentation
This App uses the locmodes() function from the multimode package to fit a bimodal model to the ground-speed distribution of each track.

For each track, the App creates a histogram with the fitted density distribution overlaid. The plot shows:

mode1: the estimated peak of the lower-speed, non-flight behaviour;
antimode: the minimum between the two speed modes, used as the flight threshold;
mode2: the estimated peak of the higher-speed, flight behaviour.

Mode1 and mode2 are shown by dashed lines, while the antimode is shown by a dotted line. The estimated values are also included in a CSV table.

The table additionally reports the mean and standard deviation of all ground-speed values above the antimode. These values provide a summary of
the likely flight speeds for each track. Overall means and standard deviations across tracks are appended to the table.

If retdata = "flight" is selected, the App returns only locations with ground speed above the estimated antimode for their track. Otherwise, it returns the full dataset.

The App works best when the ground-speed distribution clearly contains two distinct movement modes. If flight and non-flight speeds overlap strongly, or if intermediate behaviours are common, the estimated modes and antimode may be unreliable.

The App preferably uses an existing instantaneous GPS ground-speed variable named ground_speed or ground.speed. If neither variable is available, the App can calculate ground speed using move2::mt_speed(). This function calculates step speed
as the distance between consecutive GPS locations divided by the time difference between them. The calculated speed may differ from instantaneous ground speed recorded by the tracking device.

### Application scope
#### Generality of App usability
This App was developed for any taxonomic group. 

#### Required data properties
The App should work with any type of location data as long as it includes ground speed. 
If ground speed is missing and the *Ground speed calculation* setting is set to **No**, the App cannot run.


### Input type
`move2::move2_loc`

### Output type
`move2::move2_loc`

### Artefacts
`Modes_Histogrammes.pdf`: Contains one histogram per track with the fitted density distribution, mode1, antimode, and mode2.
`groundspeed_modes.csv`: Contains the fitted parameters for each track, the mean and standard deviation of speeds above the antimode, and overall means and standard deviations across tracks.

### Settings 

**Output data specification**: Choose whether to output the full input dataset (**All data**) or only flight locations, defined as locations with ground speed above the estimated antimode. (**Only flight locations**).

**Ground speed calculation**: If the dataset does not contain ground speed, choose whether to calculate it as the distance between consecutive locations divided by the time between them using move2::mt_speed() choose **yes**.
### Changes in output data

If `Output data specification = "all"` and the dataset already contains ground speed (ground_speed or ground.speed), the output is the full input dataset (unchanged).

If `Output data specification = "all"` and the dataset does not contain ground speed and `Ground speed calculation = "yes"`, a new column calculated_ground_speed is added and the full dataset is returned.

If `Output data specification = "flight"`, the output is filtered to include only locations where ground speed is greater than the estimated antimode for that track.


### Most common errors
**Missing ground speed**: The dataset does not contain ground_speed or ground.speed, and Ground speed calculation is set to No.

### Null or error handling
- If ground speed is missing and calculation is disabled, the App logs a message and returns the input data unchanged.
- If calculation is enabled, the App computes calculated_ground_speed using move2::mt_speed().