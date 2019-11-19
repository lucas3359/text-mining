library(quanteda)
library(caret)

data<-read.table("J:/Lucas/TextMining/futurelandscape.csv", header=FALSE, sep=',')
data$V1<-as.character(data$V1)
Encoding(data$V1) <- "UTF-8"
names(data)<-c("text","Theme")

#construct a corpus
corpus <- corpus(data)

#for each document, assign a document id in the corpus
docvars(corpus, "id_numeric") <- 1:ndoc(corpus)
head(docvars, 10)




# tokenize text for doing n-grams
token <-corpus%>%
  tokens(
    remove_numbers = TRUE,
    remove_punct = TRUE,
    remove_symbols = TRUE,
    remove_twitter = TRUE,
    remove_url = TRUE,
    remove_hyphens = TRUE,
    include_docvars = TRUE
  )%>%tokens_select(
  c("[\\d-]", "[[:punct:]]", "^.{1,2}$"),
  selection = "remove",
  valuetype = "regex",
  verbose = TRUE
)%>%tokens_remove(c(stopwords("english"),stop_words$word))

mydfm <- dfm(token,
             tolower = TRUE,
             remove = c(stopwords("english"),stop_words$word))%>%
  dfm_select( min_nchar = 2)%>%
  dfm_trim(max_docfreq = 0.3, docfreq_type = "prop")


df_mydfm<-as.data.frame(t(mydfm))

# 2-grams
token_2grams<-tokens_ngrams(token, n = 2)%>%dfm()%>%dfm_trim( min_termfreq = 2)
x<-as.data.frame(t(token_2grams))

# 3-grmas
token_3grams<-tokens_ngrams(token, n = 3)%>%dfm()%>%dfm_trim( min_termfreq = 2)
x2<-as.data.frame(t(token_3grams))

#enlarge vocabularies with words and some common set-phrase from 2grams & 3grams
dfm<-cbind(mydfm,token_2grams,token_3grams)

dfm_x<-as.data.frame(t(dfm))



#############################################

#testing data using pre-categorized publications

x <- read.csv("J:/Lucas/TextMining/ourLandAndWaterPublications.csv")
x$ï..Title<-as.character(x$ï..Title)
x$Abstract<-as.character(x$Abstract)
Encoding(x$ï..Title) <- "UTF-8"
Encoding(x$Abstract) <- "UTF-8"

x<-x%>%mutate(text = paste(ï..Title,Abstract))%>%dplyr::select(-1,-2)%>%mutate(Train = "test")

corpus_test<-corpus(x)

d1.dfm<-corpus_test%>%tokens(
  remove_numbers = TRUE,
  remove_punct = TRUE,
  remove_symbols = TRUE,
  remove_twitter = TRUE,
  remove_url = TRUE,
  remove_hyphens = TRUE,
  include_docvars = TRUE)%>%
  tokens_select(
  c("[\\d-]", "[[:punct:]]", "^.{1,2}$"),
  selection = "remove",
  valuetype = "regex",
  verbose = TRUE)%>%
  tokens_remove(c(stopwords("english"),stop_words$word))%>%
  tokens_ngrams( n = 1:3)%>%
  dfm()%>%dfm_select( min_nchar = 2)

dfmat_matched <- dfm_match(d1.dfm, features = featnames(dfm))






############################# Naive Bayes Classification

set.seed(100)
nb.classifier <- textmodel_nb(dfm, docvars(corpus, "Theme"))
predicted<-predict(nb.classifier,newdata = dfmat_matched)
actual_class <- docvars(corpus_test, "Theme")
tab_class <- table(actual_class, predicted)
confusionMatrix(tab_class, mode = "everything")





########################## Random Forest Classification
 
train_data <- as.data.frame(dfm)%>%dplyr::select(-1) 
train_data$Theme <- docvars(corpus, "Theme")

test_data <- as.data.frame(dfmat_matched)%>%dplyr::select(-1) 
test_data$Theme <-docvars(corpus_test, "Theme")






set.seed(1001)
data_rf <- train(as.factor(Theme)~.,
                 data=data.frame(train_data),
                 method = "ranger",
                 num.trees = 300,
                 importance = "impurity",
                 trControl = trainControl(method = "cv", classProbs = TRUE))
data_rf.predict <- predict(data_rf,newdata = data.frame(test_data))
confusionMatrix(data_rf.predict , factor(test_data$Theme))
###################


############# Multinomical Naive Bayes using package naivebayes

library(naivebayes)
set.seed(100)
train_data <- as.matrix(dfm)
test_data <- as.matrix(dfmat_matched)


model<-multinomial_naive_bayes(train_data, docvars(corpus, "Theme"))


predict<-predict(model, test_data)

confusionMatrix(predict , docvars(corpus_test, "Theme"))
table(predict(model, test_data),docvars(corpus_test, "Theme"))
