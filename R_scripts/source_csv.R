library(ggplot2)
library(reshape)
library(grid)
library(dplyr)
library(jsonlite)
library(stringr)
library(gridExtra)

############################## FUNCTIONS #####################################

load_data <- function(path, parsed_data){
  
  #read data from the provided csv
  tmp <- read.csv(path)
  
  # Checking whether the name is "spring boot" (taking the name from path) - two words
  
  technology_name <- ""
  if (toupper(paste(strsplit(path, "-")[[1]][3], collapse = " ")) != "SPRING") { 
    technology_name <- paste(strsplit(paste(strsplit(path, "-")[[1]][4], collapse = " "), "\\.")[[1]][1], collapse = " ")
    architecture_name <- paste(strsplit(path, "-")[[1]][3], collapse = " ")
  } 
  else { 
    technology_name <- paste(strsplit(path, "-")[[1]][3:4], collapse = " ")
    architecture_name <- paste(strsplit(paste(strsplit(path, "-")[[1]][5], collapse = " "), "\\.")[[1]][1], collapse = " ")
  }
  
  #inserting data form each of the following columns into data_tmp: time elapsed, latency,
  #technology (microservices or monolith), architecture (flask, spring boot, dotnet), 
  #route (Route1 or Route2), throughput(bytes in time elapsed)
  
  data_tmp <- data.frame(Elapsed = tmp$elapsed, check.names=FALSE)
  data_tmp <- data.frame(data_tmp, Latency = tmp$Latency, check.names=FALSE)
  data_tmp <- data.frame(append(data_tmp, c(Technology=technology_name), after=0))
  data_tmp <- data.frame(append(data_tmp, c(Architecture=architecture_name), after=0))
  data_tmp <- data.frame(data_tmp, Route=str_split_fixed(tmp$label, " ", 3)[,2], check.names = FALSE)
  data_tmp$Throughput <- with(tmp, sentBytes * 1000 / ( elapsed * 1024))
  
  #union with the data parsed already
  parsed_data <- union_all(parsed_data, data_tmp)
  
  return(parsed_data)
  
}

############################### CODE #########################################


# The main directory for the output files (without the "/" character at the end)

# dir <- "D:/studies/mgr2/proj_bad/outputy"
dir <- file.path(getwd(), "output")
dir

#+ List of the sources. This script assumes there is a special naming convention. 

path <- "docker-compose-dotnet-microservices.yml"
path <- append(path, "docker-compose-dotnet-monolith.yml")
path <- append(path, "docker-compose-flask-microservices.yml")
path <- append(path, "docker-compose-flask-monolith.yml")
path <- append(path, "docker-compose-spring-boot-microservices.yml")
path <- append(path, "docker-compose-spring-boot-monolith.yml")


# Defining an object (Data Frame) to store the data

parsed_data <- data.frame(matrix(ncol = 0, nrow = 0))

# Loading the data from csv files

for (file in path) {
  
  path_to_subdirectory <- file.path(dir, file)
  if (file.exists(path_to_subdirectory)){
    parsed_data <- load_data(paste(path_to_subdirectory, "/jmeter_output.csv", sep = ""), parsed_data)
  }
  
}


# Plotting diagrams ##################################3


if (file.exists(file.path(dir, "diagrams"))){
  
  # specifying the working directory
  setwd(file.path(dir, "diagrams"))
} else {
  
  # create a new sub directory inside
  # the main path
  dir.create(file.path(dir, "diagrams"))
  
  # specifying the working directory
  setwd(file.path(dir, "diagrams"))
}

# Throughput ###

png(file=paste("throughput_architecture.png", sep = ""), width = 1200, height= 800)

p1 = ggplot(parsed_data[toupper(parsed_data$Architecture) == "MONOLITH",], aes(x = Technology, y = Throughput)) + 
  geom_boxplot(fill = c("lightgreen")) +
  # facet_wrap(~Route, ncol = 1) +
  xlab("") +
  ylab("Throughput [kB/s]") +
  labs(subtitle = "Monolith") 
#+
#  coord_cartesian(ylim=c(0, 15))

p2 = ggplot(parsed_data[toupper(parsed_data$Architecture) == "MICROSERVICES",], aes(x = Technology, y = Throughput)) + 
  geom_boxplot(fill = c("lightgreen")) +
  # facet_wrap(~Route, ncol = 1) +
  xlab("") +
  ylab("") +
  labs(subtitle = "Microservices") 
#+
#  coord_cartesian(ylim=c(0, 1.7))


grid.arrange(p1, p2, ncol = 2)

dev.off()

png(file=paste("throughput_route.png", sep = ""), width = 1200, height= 800)

p1 = ggplot(parsed_data[toupper(parsed_data$Route) == "ROUTE1",], aes(x = Technology, y = Throughput)) + 
  geom_boxplot(fill = c("lightgreen")) +
  # facet_wrap(~Architecture, ncol = 1) +
  xlab("") +
  ylab("Throughput [kB/s]") +
  labs(subtitle = "Route 1") 
#+
#  coord_cartesian(ylim=c(0, 15))

p2 = ggplot(parsed_data[toupper(parsed_data$Route) == "ROUTE2",], aes(x = Technology, y = Throughput)) + 
  geom_boxplot(fill = c("lightgreen")) +
  # facet_wrap(~Architecture, ncol = 1) +
  xlab("") +
  ylab("") +
  labs(subtitle = "Route 2") 
#+
#  coord_cartesian(ylim=c(0, 3))


grid.arrange(p1, p2, ncol = 2)

dev.off()

# Latency ###

png(file=paste("latency_architecture.png", sep = ""), width = 1200, height= 800)

p1 = ggplot(parsed_data[toupper(parsed_data$Architecture) == "MONOLITH",], aes(x = Technology, y = Latency)) + 
  geom_boxplot(fill = c("lightgreen")) +
  # facet_wrap(~Route, ncol = 1) +
  xlab("") +
  ylab("Time elapsed [ms]") +
  labs(subtitle = "Monolith") 
#+
#  coord_cartesian(ylim=c(0, 15))

p2 = ggplot(parsed_data[toupper(parsed_data$Architecture) == "MICROSERVICES",], aes(x = Technology, y = Latency)) + 
  geom_boxplot(fill = c("lightgreen")) +
  # facet_wrap(~Route, ncol = 1) +
  xlab("") +
  ylab("") +
  labs(subtitle = "Microservices") 
#+
#  coord_cartesian(ylim=c(0, 1.7))


grid.arrange(p1, p2, ncol = 2)

dev.off()

png(file=paste("latency_route.png", sep = ""), width = 1200, height= 800)

p1 = ggplot(parsed_data[toupper(parsed_data$Route) == "ROUTE1",], aes(x = Technology, y = Latency)) + 
  geom_boxplot(fill = c("lightgreen")) +
  # facet_wrap(~Architecture, ncol = 1) +
  xlab("") +
  ylab("Time elapsed [ms]") +
  labs(subtitle = "Route 1") 
#+
#  coord_cartesian(ylim=c(0, 15))

p2 = ggplot(parsed_data[toupper(parsed_data$Route) == "ROUTE2",], aes(x = Technology, y = Latency)) + 
  geom_boxplot(fill = c("lightgreen")) +
  # facet_wrap(~Architecture, ncol = 1) +
  xlab("") +
  ylab("") +
  labs(subtitle = "Route 2") 
#+
#  coord_cartesian(ylim=c(0, 3))


grid.arrange(p1, p2, ncol = 2)

dev.off()