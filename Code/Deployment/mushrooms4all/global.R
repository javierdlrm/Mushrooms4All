###################################################
##########           Global        ################
###################################################

library(stringr)

values <- reactiveValues()

# Models

model.randomforest <- readRDS("Models/RandomForest.RData")
model.decisiontree <- readRDS("Models/DecisionTree.RData")

# Example mushroom

example_mushroom <- read.csv(file = "Data/example_mushroom.csv")
mushrooms_sankei <- read.csv(file = "Data/Mushrooms.csv")
mushrooms_others <- read.csv(file = "Data/mushrooms_v2 (prob 0.05).csv")
values$mushrooms_columns <- colnames(mushrooms_sankei)

# Code value dictionary -> Features and selection

code_value_dictionary <- read.csv(file = "Data/code_value_dictionary.csv", sep = ",", header = TRUE)
code_value_dictionary$column <- as.factor(gsub("\\.", "_", code_value_dictionary$column))
code_value_dictionary$name <- as.character(code_value_dictionary$name)
code_value_dictionary$code <- as.character(code_value_dictionary$code)

columns <- as.character(unique(code_value_dictionary$column))
columns <- columns[which(columns != "class")]

generate_key <- function(key, column) {
    return(str_c(key, " (", column, ")"))
}
generate_value <- function(column, value) {
    return(str_c(column, "::", value))
}

calculate_features <- function(ignore) {
    features <- list()
    for (column in columns) {
        pairs <- code_value_dictionary[code_value_dictionary$column == column, 2:3]
        options <- c()

        ignore_column <- column %in% gsub("+::.+", "", ignore)
        for (i in 1:nrow(pairs)) {
            key <- as.character(pairs[i, 1])
            value <- as.character(pairs[i, 2])
            key <- generate_key(key, column)
            value <- generate_value(column, value)

            if (ignore_column && !(value %in% ignore)) {
                next
            }

            options[[key]] <- value
        }
        features[[as.character(column)]] <- options
    }
    return(features)
}

random_selection <- function() {
    ignore <- c()
    for (column in columns) {
        codes <- code_value_dictionary[code_value_dictionary$column == column, 3]
        code <- sample(codes, 1)
        feature <- generate_value(column, code)
        ignore <- c(ignore, feature)
    }
    return(ignore)
}

features_selected <- c()
features <- calculate_features(c())

values$features_selected <- features_selected
values$features <- features

# Global session & navigation

values$globalSession <- NULL
values$navigateTo <- function(tabName) {
    showTab(inputId = "tabs", target = tabName, select = TRUE, session = values$globalSession)
}

# Checking

values$mushroom <- NULL
values$prediction <- NULL

chk_mushrooms_columns <- c()
values$chk_mushrooms <- NULL
values$chk_mushrooms_columns <- NULL

# Exploration

mushrooms_columns <- c()
values$mushrooms <- NULL
#values$mushrooms_columns <- NULL

# Utils

dataframe_transpose <- function(data) {
    data <- as.data.frame(t(data))
    rownames(data) <- NULL
    colnames(data) <- as.character(unlist(data[1,]))
    data <- data[-1,]
}

# Connection

source("connection.R", local = TRUE)