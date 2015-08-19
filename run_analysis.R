## #################################################################
## Project Assignment : Getting and Cleaning Data
## Due Date : 8/23/2015
##
## This R program will :-
## 1. Merge train and test sets into one
## 2. Extract only the mean and standard deviation for each measurement
## 3. Uses descriptive activity names
## 4. Label the data set with descriptive activity names
## 5. Create an independent tidy data set with the average of each
##    variable for each activity and each subject
## #################################################################


if (!require("data.table")) {
    install.packages("data.table")
}

if (!require("reshape2")) {
    install.packages("reshape2")
}

require("data.table")
require("reshape2")

# Load activity labels into table
tb_actv_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# Load tb_features into table
tb_features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Get the mean and standard deviation
mean_std_dev <- grepl("mean|std", tb_features)

# Load X & Y test data into table and label it
x_test_data <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test_data <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

names(x_test_data) = tb_features

# Get the mean and standard deviation from X_test
x_test_data = x_test_data[,mean_std_dev]

# Load activity labels
y_test_data[,2] = tb_actv_labels[y_test_data[,1]]
names(y_test_data) = c( "Activity_ID", "Activity_Label" )
names(subject_test) = "Subject"

# Column bind subject_test to X & Y test data
test_data <- cbind(as.data.table(subject_test), y_test_data, x_test_data)

# Load training data into tables
x_train_data <- read.table( "./UCI HAR Dataset/train/X_train.txt" )
y_train_data <- read.table( "./UCI HAR Dataset/train/y_train.txt" )

# Load subject training data into table
subject_train_data <- read.table( "./UCI HAR Dataset/train/subject_train.txt" )

names(x_train_data) = tb_features

# Extract only the measurements on the mean and standard deviation for each measurement.
x_train_data = x_train_data[,mean_std_dev]

# Load activity data into table and add lables
y_train_data[,2] = tb_actv_labels[y_train_data[,1]]
names(y_train_data) = c( "Activity_ID", "Activity_Label" )
names(subject_train_data) = "Subject"

# Column bind data
train_data <- cbind( as.data.table( subject_train_data ), y_train_data, x_train_data )

# Merge the test and train data sets
merged_data = rbind( test_data, train_data )
labels   = c( "Subject", "Activity_ID", "Activity_Label" )
data_labels = setdiff( colnames( merged_data ), labels )
melted_data   = melt( merged_data, id = labels, measure.vars = data_labels )

# Finally, find the average of each var for each activity and subject
tb_tidy_data   = dcast( melted_data, Subject + Activity_Label ~ variable, mean )

# Write tidy data to output file using write.table
write.table( tb_tidy_data, file = "./tidy_data.txt" )

