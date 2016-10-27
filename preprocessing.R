###################
# BU Biostats Faculty Collaboration Network
# Data Preprocessing Script

# Note PubMed duplicates the header line 
# Need to remove those rows

# install.packages(data.table)
library(data.table)

setwd('~/Desktop/seminars/network/biostat_collaboration_network/data')
# Get filenames for .csv files downloaded from pubmed
filenames <- list.files()
# Removes the xlsx file I made with list of faculty
filenames <- grep('.csv', rawlist, value = T)

DT.all <- data.table(title=integer(), year=integer(), author=character())

# Errorchecking (make sure 2 columns per dataset)
#DT.list = list()
#for (i in 1:length(filenames)) {
#  DT.list[[i]] = fread(filenames[i], header=F, sep=',')
#}
#sapply(DT.list, ncol)

# loop through faculty pub files
for (i in filenames) {
# Test things with Ching-Ti
DT <- fread(i, header=F, sep=',')
#DF <- read.csv(i, header=F, stringsAsFactors = F)
#DT <- as.data.table(DF)

# Remove missing data
DT <- DT[complete.cases(DT)]
# Check for missingness
# sapply(DT, function(x) table(is.na(x)))

# Make sure both title and year are integers
DT <- DT[, lapply(.SD, as.integer)]
# Name title and year columns
setnames(DT, c('title','year'))
# Add author column
DT$author <- rep(gsub('.csv','',i), nrow(DT))
# Should be integer (title), integer (year), chr (author)
# sapply(DT, class)

DT.all <- rbind(DT.all, DT)
}
DT.all
table(DT.all$author)

# Includes ALL duplicated, doesn't exclude first or last one
dupall <- function(x) {
  return(duplicated(x) | duplicated(x,fromLast=T))
}

nrow(DT.all)-length(unique(DT.all$title))
sum(dupall(DT.all$title))

# Restrict dataset to only articles with multiple biostat authors
DT.shared <- DT.all[duplicated(DT.all$title)|duplicated(DT.all$title, fromLast=T)]
sum(dupall(DT.shared$title))
sum(dupall(DT.all$title))
    
# Examples
DT.all[title==12456912]
which(DT.all$title==12456912)
DT.shared[title==12456912]

# Needed to make wide data-set
# Will represent an edge eventually
DT.shared$value <- rep(1, nrow(DT.shared))

# Cast from long to wide form
# Each row is a paper
# 1st column is paper name
# 2nd column is paper year
# Rest of the columns indicate authorship (1 = yes, NA=no)
DT.edge <- dcast(DT.shared, title + year ~ author, value.var='value')
# Replace NAs with 0's
DT.edge[is.na(DT.edge)] <- 0
table(rowSums(DT.edge[,-c("title","year"),with=F]))
sum(rowSums(DT.edge[,-c("title","year"),with=F]))

write.csv(DT.edge, file='edge_dat.csv', quote=F, row.names=F)
