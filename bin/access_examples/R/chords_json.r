install.packages('curl')
install.packages('jsonlite')
library('jsonlite')

url <- 'http://chords.dyndns.org/instruments/26.json?last'
data <- fromJSON(txt=url)
data

