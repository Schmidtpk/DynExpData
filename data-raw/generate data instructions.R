library(tidyverse)
df.instr <- instructions_filled <- read_delim("data-raw//instructions_filled.csv",
                                              delim = ";", escape_double = FALSE, trim_ws = TRUE)
colnames(df.instr)[1]<- 'id'

usethis::use_data(df.instr,overwrite = T)
df.instr%>%filter(confidence==1,cond==4)
