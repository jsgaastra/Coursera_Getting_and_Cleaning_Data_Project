library(reshape2)

file <- "getdata_dataset.zip"

# Download the dataset from the link and unpack the zip file

if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(file) 
}

# Load files with activities [labels] and features
activities <- read.table("UCI HAR Dataset/activity_labels.txt")
activities[,2] <- as.character(activities[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# extract the mean and standard deviation from these datasets
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)

# load the training dataset parts
training <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
trainingActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainingSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
training <- cbind(trainingSubjects, trainingActivities, training)

# load the test dataset parts
tests <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testedActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testedSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
tests <- cbind(testedSubjects, testedActivities, tests)

# merge the datasets and re-label
CleanedData <- rbind(training, tests)
colnames(CleanedData) <- c("subject", "activity", featuresWanted.names)

# rewrite activities and subjects as factors
CleanedData$activity <- factor(CleanedData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
CleanedData$subject <- as.factor(CleanedData$subject)

CleanedData.melted <- melt(CleanedData, id = c("subject", "activity"))
CleanedData.mean <- dcast(CleanedData.melted, subject + activity ~ variable, mean)

# export tidied data as a single text file
write.table(CleanedData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)

