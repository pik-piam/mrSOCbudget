#' @title toolSoilCarbonCycling
#' @description This function cycles the carbon on an annual basis between the different soil pools
#'
#' @param SoilCarbon soil carbon to be filled
#' @param SoilCarbonSteadyState steadystates
#' @param Decay decay rates
#' @param Landuse landuse
#' @param LanduseChange landuse change
#'
#' @return magpie object with global parameters
#' @author Kristine Karstens
#'
#' @export

toolSoilCarbonCycling <- function(SoilCarbon, SoilCarbonSteadyState, Decay, Landuse, LanduseChange) {

  years <- getYears(SoilCarbon)

  #Clear cells with no Landuse -> no Soil
  noSoilCells               <- where(dimSums(Landuse[,1,], dim=3)==0)$true$regions
  SoilCarbon[noSoilCells,,]            <- 0
  SoilCarbonSteadyState[noSoilCells,,] <- 0

  #Initialize outputs
  SoilCarbonTransfer      <- SoilCarbonInter        <- SoilCarbonNatural    <- SoilCarbon
  SoilCarbonTransfer[,1,] <- SoilCarbonInter[,1,]   <- 0

  for(year_x in years[-1]){

    # Calculate carbon transfer between landuse types
    SoilCarbonTransfer[,year_x,] <- (setYears(mbind(add_dimension(collapseNames(SoilCarbon[,year_x-1 ,"crop"]),  nm="natveg"),
                                                    add_dimension(collapseNames(SoilCarbon[,year_x-1,"natveg"]), nm="crop")), year_x) *
                                       LanduseChange[,year_x,"expansion"]
                                     - setYears(SoilCarbon[,year_x-1,], year_x) * LanduseChange[,year_x,"reduction"])

    # Calculate the carbon density after landuse change
    SoilCarbonInter[,year_x,]    <- (setYears(SoilCarbon[,year_x-1,], year_x) * setYears(Landuse[,year_x-1,], year_x)
                                     + SoilCarbonTransfer[,year_x,] ) / Landuse[,year_x,]
    SoilCarbonInter[,year_x,]    <- toolConditionalReplace(SoilCarbonInter[,year_x,], conditions = c("is.na()","is.infinite()"), replaceby = 0)

    # Update the carbon density after input and decay
    SoilCarbon[,year_x,]         <- SoilCarbonInter[,year_x,] + (SoilCarbonSteadyState[,year_x,] - SoilCarbonInter[,year_x,]) * Decay[,year_x,]

    # Calculate counterfactual potential natural vegetation stocks
    SoilCarbonNatural[,year_x,]  <- setYears(SoilCarbonNatural[,year_x-1,], year_x) + (SoilCarbonSteadyState[,year_x,] - setYears(SoilCarbonNatural[,year_x-1,], year_x)) * Decay[,year_x,]
    SoilCarbonNatural[,,"crop"]  <- 0

    print(year_x)
  }

  out <- mbind(add_dimension(SoilCarbon,            dim=3.1, add="var", nm="actualstate"),
               add_dimension(SoilCarbonTransfer,    dim=3.1, add="var", nm="carbontransfer"),
               add_dimension(SoilCarbonInter,       dim=3.1, add="var", nm="interstate"),
               add_dimension(SoilCarbonNatural,     dim=3.1, add="var", nm="naturalstate"))

  return(out)
}