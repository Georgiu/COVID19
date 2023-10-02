# needed libraries
library(ggplot2)
library(zoo)
library(dtw)
library(factoextra)
library(MASS)
library(fossil)
library(purrr)
library(cluster)

# set working directory and read the data
path <- "enter/your/path"
setwd(path)
data <- read.csv('owid-covid-data.csv')[,c('location','date','new_cases')]

# function that returns data about specified country
country <- function(country_name){
  # delete rows with NAs
  data<-na.omit(subset(data, location==country_name)[,c('date','new_cases')])
  data$date = c(1:length(data$date))
  # delete rows with negative amounts
  return (data[data$new_cases >= 0, ])
}

# list of spectated countries
countries <-c ('France','United Kingdom','Italy','Ukraine','Poland','Romania','Czechia',
               'Portugal','Hungary','Austria','Switzerland','Bulgaria','Serbia','Denmark',
               'Slovakia','Norway','Ireland','Croatia','Bosnia and Herzegovina','Albania',
               'Lithuania','Moldova','North Macedonia','Latvia','Estonia')
# time series plot for each country also with data smoothing line
for (i in 1:length(countries)){
  get <- country(countries[i])
  p <- ggplot(get,aes(x=as.Date(date), y=new_cases))
  print(p+scale_x_date(date_labels = "%b")
        +geom_line()+geom_line(aes(y=rollmean(new_cases,20,na.pad=TRUE)),col='red',lwd=1.5)
        +labs(title = countries[i], x = "Month", y = "New Cases", color = "Legend Title\n")
        +theme(plot.title = element_text(size=20,color="darkgreen", hjust = 0.5)))
}

df <- data.frame(matrix(ncol = length(countries), nrow = 366))
x <- countries
colnames(df) <- x

for (i in 1:length(countries)){
  
  # read each separate country
  smooth_data <- country(countries[i])
  
  # apply minimax scaling
  smooth_data$new_cases = (smooth_data$new_cases-min(smooth_data$new_cases))/(max(smooth_data$new_cases)-min(smooth_data$new_cases))
  
  # smoothing parameter calculation
  d <- sd(smooth_data$date)
  h <- ((4*d^5)/(3*length(smooth_data$new_cases)))^(1/5)
  
  # smoothing function calculation
  fit <- with(smooth_data, ksmooth(date, new_cases, kernel = "normal", bandwidth = h))
  smooth = fit$y
  
  # data plot with smoothing
  new_P <- ggplot(smooth_data,aes(x=date, y=new_cases,group=1))
  print(new_P  +
          geom_point(size = 3, alpha = .5, color = "grey") + 
          geom_line(aes(x=date, y=smooth), color="red",lwd=1))
  
  while (length(smooth)<366){
    smooth<-c(smooth,NA)
  }
  df[countries[i]]=smooth
}

# calculation of DTW-distances for each pair of countries
dist_lst <- c()
dist_matrix = matrix(0, length(countries), length(countries))
for (i in 1:length(countries)){
  for (j in 1:length(countries)){
    if (i!=j){
      # calculation of DTW-distances between pair of countries 
      dist<-dtw(na.omit(df[countries[i]]),na.omit(df[countries[j]]),keep=TRUE)
      
      # save data about DTW-distances between pair of countries
      dist_lst<-c(dist_lst,c(countries[i],countries[j],dist$normalizedDistance))
      dist_matrix[i,j] = dist$normalizedDistance
    }
  }
}

# example of DTW plot between Ukraine and Poland
al1 <- dtw(na.omit(df$Poland),na.omit(df$Ukraine),keep=TRUE)  
dtwPlotTwoWay(al1)

# Multidimensional scaling + knn
fit <- cmdscale(dist_matrix,eig=TRUE, k=2)
res <- kmeans(fit$points, 4, nstart=25)
x <- fit$points[,1]
y <- fit$points[,2]
plot(x, y, xlab="Coordinate 1", ylab="Coordinate 2",
     main="Metric MDS", type="n")
text(x, y, labels = countries, cex=.7)
df = as.data.frame(dist_matrix)
colnames(df) = countries
rownames(df) = countries
fviz_cluster(res, data=df)

# find out optimal clusters amount and optimal linkage method for hierarchical clustering
ac <- function(x) {
  agnes(dist_matrix, method = x)$ac
}
m <- c( "average", "single", "complete", "ward")
names(m) <- c( "average", "single", "complete", "ward")
map_dbl(m, ac)
fviz_nbclust(dist_matrix, hcut, method = "gap_stat")

# hierarchical clustering
library(dendextend)
clusters <- hclust(as.dist(dist_matrix), method="ward.D")
clusters$labels = countries
dend <- as.dendrogram(clusters)
dend <- color_labels(dend, k = 5)
plot(dend, main = "Hierarchy clustering with k=5")
abline(h=0.015, col="red", lty=2)

# comparing of two clasterizations
rand.index(cutree(clusters, k = 5, h = NULL),res$cluster)
table(cutree(clusters, k = 5, h = NULL),res$cluster)






