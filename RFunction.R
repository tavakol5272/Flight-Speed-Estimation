library(sf)
library(move2)
library(multimode)
library(units)

rFunction <- function(data, retdata=c("all", "flight"), speed_calc= c("yes", "no"))
{
  data <- sf::st_transform(data, 4326)
  
  if ("ground_speed" %in% names(data)) {
    gs_col <- "ground_speed"
  } else if ("ground.speed" %in% names(data)) {
    gs_col <- "ground.speed"
  } else {
    if (speed_calc == "yes"){
      data <- data[!sf::st_is_empty(data), ]
      data <- data[order(mt_track_id(data), mt_time(data)), ]
      data$calculated_ground_speed <- units::set_units(mt_speed(data), m / s)
      gs_col <- "calculated_ground_speed"
    } else {
      logger.info("Your data do not contain the attribute ground speed. Without this data, flight behaviour cannot be properly extracted and flight speed not estimated in this App. The input data set is returned.")
      return(data)
    }
  }
 
  data.split <- split(data, mt_track_id(data))
  ids <- names(data.split)
  
  pdf(appArtifactPath("Modes_Histogrammes.pdf"),width=12,height=8)
  
  flightmodes <- lapply(seq_along(data.split), function(i) {
    datai <- data.split[[i]]
    id <- ids[[i]]
    
    speed_99qu <- quantile(units::drop_units(datai[[gs_col]]), na.rm=TRUE, probs=0.999)
    
    gspeed <- units::drop_units(datai[[gs_col]])
    gspeed <- gspeed[gspeed < speed_99qu]
    gspeed <- gspeed[!is.na(gspeed)]
    
    
    modes <- locmodes(gspeed,mod0=2)
    plot(modes, xlab = "(ground) speed")
    title(main = paste0("Track: ", id))
    brks <- max(10, floor(length(gspeed)/100))
    hist(gspeed, breaks=brks, freq=FALSE, col=rgb(0,0,1,0.1), add=TRUE, main = "")
    
    antimode <- modes$locations[2]
    
    above <- gspeed[gspeed > antimode]
    mean_above <- if (length(above) > 0) mean(above) else NA_real_
    sd_above   <- if (length(above) > 1) sd(above)   else NA_real_
    modes$locations <- c(modes$locations[1:3], mean_above, sd_above)
    
    return(modes$locations)
    
  })
  
  dev.off()
  
  modes_table <- as.data.frame(do.call("rbind", flightmodes))
  names(modes_table) <- c("mode1","antimode","mode2","mean.above.antimode","sd.above.antimode")
  
  modes_table <- data.frame(trackID = ids, modes_table)
  
  mode1_avg <- c(mean(modes_table$mode1,na.rm=TRUE),sd(modes_table$mode1,na.rm=TRUE))
  antimode_avg <- c(mean(modes_table$antimode,na.rm=TRUE),sd(modes_table$antimode,na.rm=TRUE))
  mode2_avg <- c(mean(modes_table$mode2,na.rm=TRUE),sd(modes_table$mode2,na.rm=TRUE))
  meanabove_avg <- c(mean(modes_table$mean.above.antimode,na.rm=TRUE),sd(modes_table$mean.above.antimode,na.rm=TRUE))
  sdabove_avg <- c(mean(modes_table$sd.above.antimode,na.rm=TRUE),sd(modes_table$sd.above.antimode,na.rm=TRUE))
  
  
  modes_table <- rbind(modes_table,data.frame("trackID"=c("mean","sd"),"mode1"=mode1_avg,"antimode"=antimode_avg,"mode2"=mode2_avg,"mean.above.antimode"=meanabove_avg,"sd.above.antimode"=sdabove_avg))
  
  write.csv(modes_table, file = appArtifactPath("groundspeed_modes.csv"), row.names = FALSE)
  
  # return all data or only flight locations?
  if (retdata=="flight")
  {
    flight_data <- lapply(seq_along(data.split), function(i) {
      datai <- data.split[[i]]
      id <- ids[[i]]
      antimode <- modes_table$antimode[modes_table$trackID == id]
      #datai[datai[[gs_col]] >antimode & !is.na(datai[[gs_col]]), ]
      gs_num <- units::drop_units(datai[[gs_col]])
      keep <- !is.na(gs_num) & (gs_num > antimode)
      datai[keep, , drop = FALSE]
    })
    
    flight_data.nozero <- flight_data[vapply(flight_data, nrow, integer(1)) > 0]
    
    # bind back together
    if (length(flight_data.nozero) == 0) {
      result <- data[0, ]
    } else {
      result <- do.call(rbind, flight_data.nozero)
    }
    
    logger.info(paste("You selected retdata='flight'. New dataset contains",nrow(result), "flight locations out of", nrow(data), "total locations." ))
    
  } else {
    result <- data
  }
  
  return(result)
}

