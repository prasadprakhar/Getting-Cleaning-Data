
library(utils)
library(dplyr)
setwd("C:/Working Directory/Office/Data Science/Coursera/Getting Cleaning Data")

## Downloading and unzipping the dataset ##

if(!file.exists("./data"))
{ dir.create("./data")}

url <-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destfile <- "./data/Dataset.zip"

download.file(url, destfile)
unzip(zipfile = "./data/Dataset.zip", exdir = "./data")

## Reading all the data files into data tables ##
## Refer README.txt for more information ##

xtrain <-  read.table("./data/UCI HAR Dataset/train/X_train.txt")
ytrain <-  read.table("./data/UCI HAR Dataset/train/y_train.txt")
subjectTrain <-  read.table("./data/UCI HAR Dataset/train/subject_train.txt")

xtest <-  read.table("./data/UCI HAR Dataset/test/X_test.txt")
ytest <-  read.table("./data/UCI HAR Dataset/test/y_test.txt")
subjectTest <-  read.table("./data/UCI HAR Dataset/test/subject_test.txt")

features <- read.table("./data/UCI HAR Dataset/features.txt")
activityLabels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
unlink(destfile)

colnames(xtrain) <- features[,2]  
colnames(ytrain) <- "Activity" 
colnames(subjectTrain) <- "Volunteer"

colnames(xtest) <- features[,2]
colnames(ytest) <- "Activity" 
colnames(subjectTest) <- "Volunteer"

##  1. Merges the training and the test sets to create one data set ##
Traindataset <- cbind(ytrain,subjectTrain,xtrain)
Testdataset  <-  cbind(ytest,subjectTest,xtest)
Combinedataset <- rbind(Traindataset,Testdataset)

## Free up memory ## 
rm(ytrain,subjectTrain,xtrain,ytest,subjectTest,xtest)
rm(Traindataset, Testdataset)

## 2. Extracts only the measurements on the mean and standard deviation for each measurement ##
ColNames <- colnames(Combinedataset)
meandataset <- grep("Activity|Volunteer|mean|std", ColNames, value = TRUE)
MeanStd_Dataset <- Combinedataset[,meandataset]

## 3. Uses descriptive activity names to name the activities in the data set##

colnames(activityLabels) <- c("Activity", "ActivityName")
colnames(activityLabels)
Dataset <- merge(MeanStd_Dataset,activityLabels,by = "Activity", all.x = TRUE)

## 4. Appropriately labels the data set with descriptive variable names. 

a <- colnames(Dataset)
a <- gsub("mean","Mean",a)
a <- gsub("std","Standard_Deviation",a)
a <- gsub("[[:punct:]]","",a)
a<-  gsub("Freq","Frequency",a)
a<-  gsub("Mag","Magnitude",a)
colnames(Dataset) <- a

## 5: From the data set in step 4, creates a second, independent tidy data set with the
##    average of each variable for each activity and each subject.

tidyDataSet <- Dataset
tidyDataSet <- tbl_df(tidyDataSet)
tidyDataSet <- arrange(tidyDataSet,Activity,Volunteer)
tidyDataSet <- aggregate(. ~ Volunteer+Activity,tidyDataSet,mean)
write.table(tidyDataSet,file = "Tidy Data Set.txt",row.names = FALSE)

## end of program ##
