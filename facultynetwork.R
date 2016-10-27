###################
# BU Biostats Faculty Collaboration Network
# Analysis Script

#######
# Installs packages if needed, then loads them
ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

packages <- c("data.table","statnet", "ndtv",
              "scatterplot3d","htmlwidgets","tsna")
ipak(packages)

setwd('~/Desktop/seminars/network/biostat_collaboration_network/data/')
list.files()
######
# Create Adjacency Matrix for each time point

# Read in edge dataset we made
# Articles on rows
# 1st column: pubmed article # (can toss out)
# 2nd column: year (we will be using this)
# Other columns: Faculty (0/1 variable)
DT <- fread('edge_dat.csv', header=T)

# Remove article title
DT <- DT[,title:=NULL]

DTlist <- list()
Adjlist <- list()
unweighted <- list()

# Split datatable into multiple years (2002-2016)
for (i in 1:length(unique(DT$year))) {
  # Subset data.table by year
  DTlist[[i]] = DT[year==unique(DT$year)[i]]
  # remove year column
  DTlist[[i]][,year:=NULL]

  # Create Adjacency matrix 
  #  i.e. we want entries in this matrix to be
  #  dot products of two faculty's authorship
  Adjlist[[i]] = as.matrix(t(DTlist[[i]])) %*% 
                 as.matrix(DTlist[[i]])
  
  # Create unweighted adjacency matrix
  unweighted[[i]] = Adjlist[[i]]
  # Set edge weights > 1 to 1
  unweighted[[i]][unweighted[[i]]>1] = 1
}

# Check the structure of the data at min/max year
#DTlist[[1]]
#DTlist[[15]]

#Adjlist[[1]]
#Adjlist[[15]]

# unweighted[[15]]

#######
# Create list of static networks
#    One network per time point (year)
netlist <- lapply(unweighted, function(x) 
            as.network(x, directed = F))

#######
# Create dynamic network from list of static nets
minyear = min(DT$year) # starts in 2002
maxyear = max(DT$year) # ends in 2016
tnet <- networkDynamic(network.list=netlist,
            onsets=(minyear-1):(maxyear-1),
            termini=minyear:maxyear,
            create.TEAs=T) # add vertex names

#### 
# Create animation
# render.animation(tnet)
# ani.replay()

compute.animation(tnet)
timePrism(tnet,at=c(2002,2009,2015),
          displaylabels=TRUE,planes = TRUE,
          label.cex=0.5, angle=35,
          displayisolates=F)

render.d3movie(tnet,output.mode = 'htmlWidget',
                displaylabels=T)

filmstrip(tnet,displaylabels=FALSE)
timeline(tnet,displaylabels=T)


