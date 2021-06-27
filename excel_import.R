# Need to install "writexl" R package
install.packages("writexl")
library(writexl)

# Need to change file type of data frame from Rda to xlsx
write_xlsx(dfExcel, "data/excelData.xlsx")