# Goals -------------------------------------------------------------------
# wo bullshit items bs

# ymat N x T (1002 x 100) (participants x items)
# ymat is the items in order of item numbers, NOT in order given to the P.

# ord N x T (order matrix)
# ord[j,i] returns time t at wich item i was prestend to participant j

# time N x T
# Provides the time taken for this item

# treatment.timing N
# Provides the timing of treatment (NA if no treatment)

# cond N
# Provides the treatment condition of individual in 1,2,3,4


# load stuff --------------------------------------------------------------

library(tidyverse)

dat1 <- read.csv("./data-raw/Full_data_survey.csv",stringsAsFactors = F, header = T)

dat1$id <- dat1$ï..V1

rownames(dat1)<-dat1$id

#dat1[1,]%>%as.character()

# items -------------------------------------------------------------------

names.items <- c("anx","ang","fre", "greg", "img","art", "trst", "alt", "ord", "sed")

itemDF <- dat1[ -c(1),
                grepl(paste(c(names.items,"cond"),collapse = "|"), names(dat1)) &
                !grepl("_t_", names(dat1)) &
                !grepl("\\.1", names(dat1))
                ]



# time --------------------------------------------------------------------
timeDF <- dat1[ -c(1),
                grepl(paste(names.items,collapse = "|"), names(dat1)) &
                  grepl("_t_3", names(dat1)) &
                  !grepl("\\.1", names(dat1))]
colnames(timeDF)<- gsub("_t_3","",colnames(timeDF))

# conditions ------------------------------------------------------------


# check if each occurs once
table(itemDF%>%select(starts_with("cond")))

# assign condition
itemDF$cond <- ifelse(itemDF$cond2==1, 2,
                      ifelse(itemDF$cond3==1,3,
                             ifelse(itemDF$cond4==1,4,1)))

# drop old condition variables
itemDF <- itemDF %>% select(-c(cond1,cond2,cond3,cond4))

itemDF <- itemDF%>%
  mutate(across(where(is.character), as.numeric))

cond <- itemDF$cond
names(cond)<-rownames(itemDF)
# reverse items --------------------------------------------------------

reverse.index <- c(
  "anx6","anx7","anx8","anx9","anx10",
  "ang6","ang7","ang8","ang9","ang10",
  "fre6","fre7","fre8","fre9","fre10",
  "greg6","greg7","greg8","greg9","greg10",
  "img7","img8","img9","img10",
  "art6","art7","art8","art9","art10",
  "trst6","trst7","trst8","trst9",
  "alt6","alt7","alt8","alt9","alt10",
  "ord6","ord7","ord8","ord9","ord10",
  "sed6","sed7","sed8","sed9","sed10")


# columns missing?
reverse.index[!reverse.index %in% colnames(itemDF)]
# colnames(itemDF)[!colnames(itemDF)%in% reverse.index]

# values of items
unlist(itemDF%>%select(starts_with(names.items)))%>%table()

#only one answer has 7s
itemDF %>%
  summarise(across(everything(),
                   list(is_seven = function(x) mean(x==7,na.rm=TRUE))))

# join 6 and 7 for question alt6
itemDF[itemDF==7]<-6

# reverse
itemDF[,reverse.index] <- 7 - itemDF[,reverse.index]




# treatment timing --------------------------------------------------------

table(dat1$DO.BR.FL_118=="",dat1$DO.BR.FL_120=="",dat1$DO.BR.FL_430=="")

raw_ord <- paste0(dat1$DO.BR.FL_118,dat1$DO.BR.FL_120,dat1$DO.BR.FL_430)[-c(1)]


### drop irrelevant pages
raw_ord <- gsub("bs1","",raw_ord)
raw_ord <- gsub("bs2","",raw_ord)

raw_ord <- gsub(" ","",raw_ord)
raw_ord <- gsub("\\|\\|","|",raw_ord)

# as matrix
raw_ord <- str_split(string = raw_ord,pattern = fixed("|"),simplify = T)

# find conditions
treatment.timing <-numeric(nrow(raw_ord))
for(j in 1:nrow(raw_ord)){
  here.j <- which(grepl("cond", raw_ord[j,]))
  treatment.timing[j] <- ifelse(is.null(here.j),NA,here.j)
}
names(treatment.timing)<-rownames(dat1[-c(1),])
itemDF$treatment.timing <- treatment.timing


# check if right conditions have treatment timing
table(is.na(itemDF$treatment.timing),itemDF$cond)


# order -------------------------------------------------------------------

raw_ord <- paste0(dat1$DO.BR.FL_118,dat1$DO.BR.FL_120,dat1$DO.BR.FL_430)[-c(1)]

### drop irrelevant pages
raw_ord <- gsub("bs1","",raw_ord)
raw_ord <- gsub("bs2","",raw_ord)
raw_ord <- gsub("cond . instructions","",raw_ord)

raw_ord <- gsub(" ","",raw_ord)
raw_ord <- gsub("\\|\\|","|",raw_ord)


# as matrix
raw_ord_list <- str_split(string = raw_ord,pattern = "\\|")

ymat <- itemDF%>%select(starts_with(names.items))
tord <- matrix(NA,nrow = nrow(ymat),ncol=ncol(ymat))
rownames(tord)<-rownames(ymat)
colnames(tord)<-colnames(ymat)


for(j in 1:nrow(tord)){
  raw_ordj <- raw_ord_list[[j]]
  raw_ordj <- raw_ordj[raw_ordj!=""]
  for(i in 1:ncol(tord)){
    # returns item i at time t for person j
    tord[j,which(str_to_lower(raw_ordj[i])==colnames(ymat))] <- i
  }
}

# check order
table(tord)



# intruction checks -------------------------------------------------------
# "What were those instructions?"
dat1$Q243[1]

instr <- dat1$Q243[-c(1)]
names(instr)<- rownames(ymat)

df.instr <- data.frame(instr=instr,cond=cond)

df.instr$correct <- grepl("effort|quick|random|thought|
                          trick|not read|thinking|any answer",
                          df.instr$instr,
                          ignore.case = TRUE)
table(df.instr%>%select(cond,correct))


df.instr$correct <- grepl("random|read",
                          df.instr$instr,
                          ignore.case = TRUE)
table(df.instr%>%select(cond,correct))



# Exceptions:
# I think they were to continue responding with your gut thought, don't think too much about the questions
# To just rush through and answer without thinking...but I answered quickly but still honestly
# to answer randomly but I couldn't do it
# To complete the rest of the study as quickly as I could that there would me no more trick questions just answer as honestly as possible



# item values (drop missing) -------------------------------------------------------------

#drop incomplete
drop.cases <- !complete.cases(ymat)
message("drop ", paste(rownames(ymat)[drop.cases],collapse = ", "))


tord <- tord[!drop.cases,]
treatment.timing <- treatment.timing[!drop.cases]
cond <- cond[!drop.cases]
timeDF <- timeDF[!drop.cases,]
itemDF <- itemDF[!drop.cases,]
ymat <- ymat[!drop.cases,]
raw_ord <- raw_ord[!drop.cases]
instr <- instr[!drop.cases]

# check remaining values
ymat %>%
  summarise(across(everything(),
                   list(isna =function(x) mean(is.na(x)),
                        bounds = function(x) mean(x>7 | x<1,na.rm=TRUE))))


# summary -----------------------------------------------------------------


dim(tord)
usethis::use_data(tord,overwrite = T)

usethis::use_data(reverse.index,overwrite = TRUE)

dim(ymat)
usethis::use_data(ymat,overwrite = T)

length(cond)
usethis::use_data(cond,overwrite = T)

length(treatment.timing)
usethis::use_data(treatment.timing,overwrite = T)

time <- timeDF
dim(time)
usethis::use_data(time,overwrite = T)

length(raw_ord)
usethis::use_data(raw_ord,overwrite = T)

length(instr)
usethis::use_data(instr)

# tests -------------------------------------------------------------------

### order (raw_ord_list[[j]][tord[j,]] == item list)

# take raw order
raw_ord <- paste0(dat1$DO.BR.FL_118,dat1$DO.BR.FL_120,dat1$DO.BR.FL_430)[dat1$ï..V1 %in% rownames(ymat)]
raw_ord <- gsub("cond . instructions","",raw_ord)
raw_ord <- gsub("bs1","",raw_ord)
raw_ord <- gsub("bs2","",raw_ord)
raw_ord <- gsub(" ","",raw_ord)
raw_ord <- gsub("\\|\\|","|",raw_ord)


# as matrix
raw_ord_list <- str_split(string = raw_ord,pattern = "\\|")

for(j in 1:1002){
  raw_ord_list[[j]] <- raw_ord_list[[j]][raw_ord_list[[j]]!=""]
  if(!identical(str_to_lower(raw_ord_list[[j]][tord[j,]]),colnames(ymat)))
    stop('Order seems off')
}


if(!all(unique(unlist(ymat)) %in% 1:6))
  stop('Wrong item values')


