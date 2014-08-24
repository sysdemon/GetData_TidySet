library(plyr)

furl <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(furl, destfile="temp.zip", method = "internal", mode="wb")

# datasets
training <- read.table( unz("temp.zip", "UCI HAR Dataset/train/X_train.txt") , header=FALSE ) 
test <- read.table( unz("temp.zip", "UCI HAR Dataset/test/X_test.txt") , header=FALSE ) 
merged <- rbind(training, test)

# features
feat <- read.table( unz("temp.zip", "UCI HAR Dataset/features.txt"), header=FALSE ) 
feat <- feat[,2]

merged <- merged[, grepl("(mean|std)\\(\\)", feat) ]
tmp.names <- feat[ grepl("(mean|std)\\(\\)", feat) ]
names(merged) <- gsub( "-", ".", gsub("\\(\\)", "", tmp.names) )

# labels
training.label <- read.table( unz("temp.zip", "UCI HAR Dataset/train/y_train.txt") , header=FALSE ) 
test.label <- read.table( unz("temp.zip", "UCI HAR Dataset/test/y_test.txt") , header=FALSE ) 
labels <- rbind(training.label, test.label)

# subjects
training.subj <- read.table( unz("temp.zip", "UCI HAR Dataset/train/subject_train.txt"), header=FALSE)
test.subj <- read.table( unz("temp.zip", "UCI HAR Dataset/test/subject_test.txt"), header=FALSE)
subj <- rbind(training.subj, test.subj)
names(subj) <- c("Subject")

# activities
act <- read.table( unz("temp.zip", "UCI HAR Dataset/activity_labels.txt"), header=FALSE) 
act.label <- join(labels, act)[2]
names(act.label) <- c("Activity")

merged <- cbind(subj, act.label, merged)

result <- ddply(merged, .(Activity, Subject), numcolwise(mean), .drop=TRUE)

# labels dataset 
avg.names <- sub( "^", "Avg.", names(result)[3:length(names(result))] )
names(result)[3:length(names(result))] <- avg.names

# tidy data set (averages of each activity/subject)
write.table(result, file= "tidydata.txt", row.names = FALSE)

