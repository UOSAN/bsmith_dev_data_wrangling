
library(dplyr)

#load the survey

load("~/Dropbox (University of Oregon)/UO-SAN Lab/Berkman Lab/Devaluation/analysis_files/data/scored_data.RData")

#convert scored to numeric

scored$score <- as.numeric(scored$score)

#we have applied a system which separates the original arm labels and DEV IDs from the data
#while preserving randomly generated subject IDs and arm labels
#this is not _secure_ because the data is still accessible, but it enables researchers
#to work with tables without inadvertently peaking at the data.
preserve_arm_decoding <- TRUE
source('get_participants.R')

scored <- merge(scored,subid_devid_key,by.x="SID",by.y="dev_id")
scored$SID <- NULL

save(scored,group_decoding_key,ppt_list_clean,file="~/Dropbox (University of Oregon)/UO-SAN Lab/Berkman Lab/Devaluation/analysis_files/data/scored_data_coded.RData")