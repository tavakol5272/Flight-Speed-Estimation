## Extract Two Movement Speeds

MoveApps

Github repository: *github.com/movestore/Flight-Speed-Estimation*

## Description
Fits a bimodal model to the GPS ground speed distribution and identifies the two peaks (modes) and the minimum between them (antimode) to filter flight locations (ground speed above the antimode). The App outputs a table of track-specific parameters, including the mean and SD of speeds above the antimode (as an estimate of flight speed).

## Documentation
This App uses the locmodes() function from the multimodes package to fit a bimodal to the ground speed distribution of each track/animal. For each track a histogramme with the fitted function is provided. Mode1 (estimated non-flight speed), antimode (minimum between both behaviours) and mode2 (estimated flight speed) are visible by dotted lines in the plot and provided in a .csv table. In the table also average and standard deviation of the three parameters are provided.

If selected, only the locations with ground speed above the antimode are passed on, else the complete data set.

Note that this App works properly only if the two movement modes (no flight and flight) properly separate by ground speed. If there are e.g. intermediate behaviours, clear separations might be difficult and results inaccurate.

This App works best with (instantaneous) GPS ground speed. If your dataset does not include ground speed, you can optionally calculate it as the distance between consecutive GPS fixes divided by the time difference (using move2::mt_speed()), by selecting Yes in the Ground speed calculation setting.

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
`Modes_Histogrammes.pdf`: For each track, a histogram with the fitted distribution overlaid, including mode1, antimode, and mode2.

`groundspeed_modes.csv`: A table of the fitted model parameters per track, with overall means and standard deviations added.

### Settings 

**Output data specification (`retdata`)**: Choose whether to output/pass on the full input dataset (**all**) or only the flight locations (**flight**; locations with ground speed above the antimode).

**Ground speed calculation (`speed_calc`)**: If ground speed is missing, choose whether to calculate it (**yes**) as distance between consecutive GPS fixes divided by the time difference (using `move2::mt_speed()`), or not (**no**).

### Changes in output data

If `retdata = "all"` and the dataset already contains ground speed (ground_speed or ground.speed), the output is the full input dataset (unchanged).

If `retdata = "all"` and the dataset does not contain ground speed and speed_calc = "yes", a new column calculated_ground_speed is added and the full dataset is returned.

If `retdata = "flight"`, the output is filtered to include only locations where ground speed is greater than the estimated antimode for that track.


### Most common errors
**Missing ground speed**: The dataset does not contain ground_speed or ground.speed, and speed_calc is set to No.

### Null or error handling
**Ground speed missing:** If ground_speed/ground.speed is missing and speed_calc = "no", the App logs an informational message and returns the input dataset unchanged
**Data:** If there are no flight data in your input data set, the results might be very unmeaningful and lead to an empty return data set or an error.
