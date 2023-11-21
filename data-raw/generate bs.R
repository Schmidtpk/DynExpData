
# load stuff --------------------------------------------------------------

library(tidyverse)

dat1 <- read.csv("./data-raw/Full_data_survey.csv",stringsAsFactors = F, header = T)

dat1$id <- dat1$ï..V1

rownames(dat1)<-dat1$id


names.items <- c("anx","ang","fre", "greg", "img","art", "trst", "alt", "ord", "sed")

# bs timing --------------------------------------------------------

raw_ord <- paste0(dat1$DO.BR.FL_118,dat1$DO.BR.FL_120,dat1$DO.BR.FL_430)[-c(1)]

### drop irrelevant page
raw_ord <- gsub("cond . instructions","",raw_ord)
raw_ord <- gsub("\\|\\|","|",raw_ord)

### delete item description
for(item.cur in names.items){
  raw_ord <- gsub(paste0(item.cur,"([0-9]+)"),"",raw_ord,ignore.case = T)
}

# as matrix
raw_ord <- str_split(string = raw_ord,pattern = fixed("|"),simplify = T)

# find bs by counting number of "|" before
bs1 <- bs2 <-numeric(nrow(raw_ord))
for(j in 1:nrow(raw_ord)){
  bs1[j] <- which(grepl("bs1", raw_ord[j,]))
  bs2[j] <- which(grepl("bs2", raw_ord[j,]))
}
bs <- data.frame(bs1r = bs1,bs2r =bs2)%>%
  mutate(bs1t = bs1r - 1*(bs2r<bs1r), # drop bs item before from count
         bs2t = bs2r - 1*(bs1r<bs2r))%>%
  select(bs1t,bs2t)%>%
  mutate(id = rownames(dat1[-c(1),])) # add id to data



# bs value ----------------------------------------------------------------

bsdf <- dat1[ -c(1),c("bs1","bs2")]%>%rownames_to_column("id")

bs <- left_join(bs,bsdf)
bs

usethis::use_data(bs,overwrite = T)

### long format

bs.long <-
  bs%>%pivot_longer(c("bs1","bs2"),names_to = "number",values_to="response")%>%pivot_longer(c("bs1t","bs2t"),values_to = "timing")%>%
  filter(extract_numeric(number)==extract_numeric(name))

bs.long

usethis::use_data(bs.long, overwrite = T)




