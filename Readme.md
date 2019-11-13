# Text Minind - Supervised Document Classification

## Goal: Trying to match a group of research from their abstracts to one of three defined core themes


## Process:
#### 1. tokenize text: import training data(three themes), tidy text format as being a table with one-token-per-row
#### 2. text analysis: clean out unwanted words, visualize terms to see if it makes sense 
##### ??????1.different visualizations of tf(term-frequency: most common words in all documents) & tf_idf(term frequency inverse document frequency: measuring how important a word is to a document in a collection of documents) 
##### ??????2.clean out some obviously unimportant word & create own stop-word dictionary
##### *[Text Analysis-exploration and visualization.Rmd](https://github.com/lucas3359/text-mining-CoreThemeMatch/blob/master/Text%20Analysis-exploration%20and%20visualization.Rmd)*
#### 3. build a supervised document classification model: turn corpus/tokens into dfm(document-feature matrix) to feed the model, use it to predict test data(with pre-classified themes) 
##### *[document-Classification-model.R](https://github.com/lucas3359/text-mining-CoreThemeMatch/blob/master/document-Classification-model.R)*
#### 4. improve the accuracy of the model by taking n-grams into model later
