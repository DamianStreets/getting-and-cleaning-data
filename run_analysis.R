#library(plyr);
#library(data.table);

##Home location
MyWD = getwd()

## Training file location and filename
TrainDir <- "./data/UCI HAR Dataset/train"
TrainFileX <- "X_train.txt"
TrainFileY <- "y_train.txt"
TrainSubject <- "subject_train.txt"

## Test file location and filename
TestDir <- "./data/UCI HAR Dataset/test"
TestFileX <- "X_test.txt"
TestFileY <- "y_test.txt"
TestSubject <- "subject_test.txt"

## Activity Labels file location and filename
ActivityDir <- "./data/UCI HAR Dataset"
ActivityFile <- "activity_labels.txt"

## Features file location and filename
FeaturesDir <- "./data/UCI HAR Dataset"
FeaturesFile <- "features.txt"

setwd(MyWD)
setwd(ActivityDir)
ActivityData <-  read.table(ActivityFile)
FeaturesData <-  read.table(FeaturesFile)

## Build a set that only contains features with a Mean or Std description.
#FeaturesFiltered <- grepl("mean|std", FeaturesData)


## set directory to Train and load the files
setwd(MyWD)
setwd(TrainDir)
TrainDataX <- read.table(TrainFileX)
TrainDataY <- read.table(TrainFileY)
TrainSubject <- read.table(TrainSubject)


## set directory to Home then Test and load the files
setwd(MyWD)
setwd(TestDir)
TestDataX <- read.table(TestFileX)
TestDataY <- read.table(TestFileY)
TestSubject <- read.table(TestSubject)

## reset Working Directory
setwd(MyWD)

## Merge Training and Test files
dataSubject <- rbind(TrainSubject, TestSubject)
dataSet<- rbind(TrainDataX, TestDataX)
dataLabels<- rbind(TrainDataY, TestDataY)

# Assign column names
names(dataSubject)<-c("subject")
names(dataLabels)<- c("activity_names")
names(dataSet)<- FeaturesData$V2

#Merge all files
data <- cbind(dataSubject, dataLabels)
data <- cbind(dataSet, data)

#Extract only columns with mean or std

subColumns <- FeaturesData$V2[grep("mean\\(\\)|std\\(\\)", FeaturesData$V2)]
subColumns <- c(as.character(subColumns), "subject", "activity_names" )
data<-subset(data,select=subColumns)

# the labels for the activities
ActivityData[,2] <- as.character(ActivityData[,2])
data$activity_names <- ActivityData[match(data$activity_names,ActivityData[,1]),2]

# some charachter replacement to clean up the variable labels.
names(data)<-gsub("^t", "time", names(data))
names(data)<-gsub("^f", "frequency", names(data))
names(data)<-gsub("BodyBody", "Body", names(data))


#Aggregate and sort the data
DataOut<-aggregate(. ~subject + activity, data, mean)
DataOut<-DataOut[order(DataOut$subject,DataOut$activity),]

#export to file.
write.table(DataOut, file = "tidydata.txt",row.name=FALSE)


