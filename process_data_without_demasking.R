
library(dplyr)

#load the survey
load("../../data/scored_data.RData")

#convert scored to numeric

scored$score <- as.numeric(scored$score)

#we have applied a system which separates the original arm labels and DEV IDs from the data
#while preserving randomly generated subject IDs and arm labels
#this is not _secure_ because the data is still accessible, but it enables researchers
#to work with tables without inadvertently peaking at the data.
preserve_arm_decoding <- FALSE
source('get_participants.R')

scored <- merge(scored,subid_devid_key,by.x="SID",by.y="dev_id")
scored$SID <- NULL

save(scored,ppt_list_clean,file="../../data/scored_data_coded.RData")