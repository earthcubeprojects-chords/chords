install.packages('curl')
install.packages('jsonlite')

url <- 'http://chords.dyndns.org/instruments/26.json?last'
data <- fromJSON(txt=url)
data

