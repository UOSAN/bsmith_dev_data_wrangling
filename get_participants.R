


cwd<-getwd()

setwd("../../data/")

source("DEV2-PostpreOutcomesChang_R_2021-01-23_0025.r")

setwd(cwd)


#let's use good old data.table, I miss it
library(data.table)
library(dplyr)

dev2_pp_dt_all_sessions<- data.table(data)

table(dev2_pp_dt_all_sessions$redcap_event_name)

#Let's get some participant information....


ppt_id <- c("dev_id","date_0"#,"address"
            ,"birthsex","dob","race___1","race___2","race___3","race___4","race___5","race___6","race___7","race___8")
#only store info relevant to participant ID
participant_list_raw <- dev2_pp_dt_all_sessions[,ppt_id,with=FALSE]
#now remove missing data columns
blank_by_row <- rowSums(is.na(participant_list_raw))+rowSums(participant_list_raw=="",na.rm = TRUE)
#remove rows with the least amount of information
ppt_list_clean.1 <- participant_list_raw[blank_by_row<max(blank_by_row)]
ppt_list_clean <- ppt_list_clean.1[stringr::str_detect(ppt_list_clean.1$dev_id,"DEV\\d\\d\\d") & ppt_list_clean.1$dob!="",]

#strip out irrelevant rows


blank_by_row <- rowSums(is.na(dev2_pp_dt_all_sessions))+rowSums(dev2_pp_dt_all_sessions=="",na.rm = TRUE)

#remove rows with no content other than a DEV ID.
dev2_pp_dt_all_sessions.1 <- dev2_pp_dt_all_sessions[blank_by_row<max(blank_by_row)]

#Then combine to get rows representing subjects rather than events. Columns are already unique, we just need to make it so.

vars_per_subj_by_columns <- dev2_pp_dt_all_sessions.1 %>% group_by(dev_id) %>% summarise_each(
  funs=list(function(x){sum(!is.na(x))}))

max_var_count <- apply(vars_per_subj_by_columns,2,max)
max_var_count[max_var_count>1]
cols_with_one_entry_per_subject <- names(max_var_count)[max_var_count==1]


#only store info relevant to participant ID
ppt_anon_list_raw <- dev2_pp_dt_all_sessions.1[,ppt_id,with=FALSE]
#now remove missing data columns
blank_by_row <- rowSums(is.na(ppt_anon_list_raw))+rowSums(ppt_anon_list_raw=="",na.rm = TRUE)
#remove rows with the least amount of information
ppt_list_clean.1 <- ppt_anon_list_raw[blank_by_row<max(blank_by_row)]
ppt_list_clean <- ppt_list_clean.1[stringr::str_detect(ppt_list_clean.1$dev_id,"DEV\\d\\d\\d") & ppt_list_clean.1$dob!="",]



#now do arm randomization
set.seed(Sys.time())
arm_names <- sample(c("Georgio","Pike","Kirk"))
arm_numbers_with_na <- unique(dev2_pp_dt_all_sessions$arm_0)
#assumes these arm numbers are 1, 2, 3
arm_numbers<-sort(arm_numbers_with_na[!is.na(arm_numbers_with_na)])
stopifnot(all(arm_numbers==c(1,2,3)))

dev2_pp_dt_all_sessions$arm_session_randlabel<-as.character(NA)
for (arm_number in arm_numbers){
  dev2_pp_dt_all_sessions[dev2_pp_dt_all_sessions$arm_0==arm_number,arm_session_randlabel:=arm_names[arm_number]]
}

group_decoding_key <- unique(dev2_pp_dt_all_sessions %>% select(arm_0.factor,arm_session_randlabel))
keep_group_decoding <- FALSE
if(exists("preserve_arm_decoding")==TRUE){
  if (preserve_arm_decoding==TRUE){
    keep_group_decoding <- TRUE
  }
}
if(!keep_group_decoding){
  rm(group_decoding_key) #purpose of this is to hide unless there's a good reason to show.
}

arm_data <- dev2_pp_dt_all_sessions[!is.na(arm_session_randlabel),.(dev_id,arm_session_randlabel)]

#and then merge this back in with the participant list.



ppt_list_clean <- ppt_list_clean %>% merge(arm_data)

rm(arm_data)

subid <- paste0("RS",formatC(sample(1:1000,nrow(ppt_list_clean)),width=4,flag = "0"))

ppt_list_clean$subid <- subid
subid_devid_key <- ppt_list_clean %>% select(dev_id,subid)
ppt_list_clean$dev_id <- NULL



