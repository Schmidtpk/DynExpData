# load stuff --------------------------------------------------------------
library(tidyverse)

dat1 <- read.csv("./data-raw/Full_data_survey.csv",stringsAsFactors = F, header = T)

dat1$id <- dat1$ï..V1

rownames(dat1)<-dat1$id



### add condition
# cbind(colnames(dat1),dat1[1,]%>%as.character())%>%View
# assign condition
dat1$cond <- ifelse(dat1$cond2==1, 2,
                    ifelse(dat1$cond3==1,3,
                           ifelse(dat1$cond4==1,4,1)))


### compute average time
dat1 <- dat1%>%
  group_by(id)%>%
  mutate(time = mean(as.numeric(c_across(contains("_t_3"))),na.rm=TRUE))%>%
  ungroup()

### extract data
demographics <- dat1[-c(1),c("LocationLatitude","LocationLongitude",
                             "fin8","subj1","subj2",
                             "age1","gender1",
                             "bs1","bs2","id",
                             "Q243",
                             "cond3_t_3","cond4_t_3","cond","time")]%>%
  rename(wronganswertype = fin8,
         topicofstudy = subj1,
         confusing=subj2,
         instr = Q243)%>%
  mutate(
    time_cond = ifelse(cond3_t_3=="", as.numeric(cond4_t_3),as.numeric(cond3_t_3)))%>%
  tibble()

demographics

usethis::use_data(demographics,overwrite = TRUE)
