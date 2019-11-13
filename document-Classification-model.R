
################# Supervised document classification #################

#get training dataset 
data<-read.table("J:/Lucas/TextMining/futurelandscape.csv", header=FALSE, sep=',')
data$V1<-as.character(data$V1)
Encoding(data$V1) <- "UTF-8"
names(data)<-c("text","Theme")

#construct a corpus
corpus <- corpus(data)

#for each document, assign a document id in the corpus
docvars(corpus, "id_numeric") <- 1:ndoc(corpus)
head(docvars, 10)

#create own stop dictionary
stop<- c("use")

#constructs a document-feature matrix (DFM) from corpus, do some basic preprocesing for each word
#minimun character to 2 & remove words which appear more then 10% of the whole documents
data.dfm <- corpus%>%
  dfm(tolower = TRUE, remove_punct = TRUE,
      remove_numbers = TRUE, remove = c(stopwords("english"),stop))%>%
  dfm_select( min_nchar = 2)%>%
  dfm_trim(max_docfreq = 0.1, docfreq_type = "prop")

###

#get testing datase4t
x <- read.csv("J:/Lucas/TextMining/ourLandAndWaterPublications.csv")
x$ï..Title<-as.character(x$ï..Title)
x$Abstract<-as.character(x$Abstract)
Encoding(x$ï..Title) <- "UTF-8"
Encoding(x$Abstract) <- "UTF-8"

#combine title&abstract
x<-x%>%mutate(text = paste(ï..Title,Abstract))%>%dplyr::select(-1,-2)%>%mutate(Train = "test")

#make it to corpus
corpus_test<-corpus(x)

#convert to dfm
d1.dfm<-corpus_test%>%
  dfm(tolower = TRUE, remove_punct = TRUE,
      remove_numbers = TRUE, remove =stop_words)%>%
  dfm_select( min_nchar = 2)

#only remain words that appears in training
dfmat_matched <- dfm_match(d1.dfm, features = featnames(data.dfm))



### Model - NAIVE BAYES CLASSIFIER - using quanteda package


set.seed(100)
nb.classifier <- textmodel_nb(data.dfm, docvars(data.dfm, "Theme"))

#predict the test data
predicted<-predict(nb.classifier,newdata = dfmat_matched)

#actual themes of the test data
actual_class <- docvars(dfmat_matched, "Theme")

#evaluate the model, compare the results
tab_class <- table(actual_class, predicted)
confusionMatrix(tab_class, mode = "everything")





### Model - Random Forest - using caret package

#transform dfm form into dataframe for both training & testing data
train_data <- as.data.frame(data.dfm)%>%dplyr::select(-1) 
train_data$Theme <- data$Theme

test_data <- as.data.frame(dfmat_matched)%>%dplyr::select(-1) 
test_data$Theme <- x$Theme



set.seed(1001)
data_rf <- train(as.factor(Theme)~.,
                 data=data.frame(train_data),
                 method = "ranger",
                 num.trees = 300,
                 importance = "impurity",
                 trControl = trainControl(method = "cv", classProbs = TRUE))


#evaluate the model
data_rf.predict <- predict(data_rf,newdata = data.frame(test_data))
confusionMatrix(data_rf.predict , factor(test_data$Theme))







##### randomly assign training & testing data and see the results #####

#combine training & testing 
data_merged<-rbind(data,x)

#randomly separate number into 75% & 25% for training and testing 
id_train <- sample(1:321, 240, replace = FALSE)

#convert combined data into corpus
corpus_data_merged <- corpus(data_merged)
summary(corpus_data_merged, 5)

#assign document id for corpus for spliting the training & testing 
docvars(corpus_data_merged, "id_numeric") <- 1:ndoc(corpus_data_merged)

#convert to dfm - training
dfmat_training <- corpus_subset(corpus_data_merged, id_numeric %in% id_train) %>%
  dfm(tolower = TRUE, remove_punct = TRUE,
      remove_numbers = TRUE, remove = stopwords("english"))%>%
  dfm_select( min_nchar = 2)%>%
  dfm_trim(max_docfreq = 0.1, docfreq_type = "prop")

#convet to dfm - testing
dfmat_test <- corpus_subset(corpus_data_merged, !id_numeric %in% id_train) %>%
  dfm(tolower = TRUE, remove_punct = TRUE,
      remove_numbers = TRUE, remove = stopwords("english"))%>%
  dfm_select( min_nchar = 2)

#for testing data, only keep those words appeared in training for the prediction
dfmat_matched <- dfm_match(dfmat_test, features = featnames(dfmat_training))


###Model - Random Forest 

#transform dfm to dataframe so that train function from caret can work
train_data <- as.data.frame(dfmat_training)%>%dplyr::select(-1) 
train_data$Theme <- docvars(dfmat_training, "Theme")

test_data <- as.data.frame(dfmat_matched)%>%dplyr::select(-1) 
test_data$Theme <-docvars(dfmat_test, "Theme")



set.seed(1001)
data_rf <- train(as.factor(Theme)~.,
                 data=data.frame(train_data),
                 method = "ranger",
                 num.trees = 300,
                 importance = "impurity",
                 trControl = trainControl(method = "cv", classProbs = TRUE))

#evaluate model
data_rf.predict <- predict(data_rf,newdata = data.frame(test_data))
confusionMatrix(data_rf.predict , factor(test_data$Theme))




########################################  Optimize the model, and later use the model to classify new unknown theme data
