
# Text Mining - Supervised Document Classification (on-going project)

## Goal: Trying to match a group of publications from their title & abstracts to one of three pre-defined core themes


## Process:
### 1. Data Preparation: import plain text, generate a corpus and tokenize it. 
### 2. Text Analysis: visualize terms frequency(TF) and term frequency inverse document frequency(TF-IDF), clean out unwanted or irrelevant words like stop words and create own dictionary.
##### *[Text Analysis-exploration and visualization.Rmd](https://github.com/lucas3359/text-mining-CoreThemeMatch/blob/master/Text%20Analysis-exploration%20and%20visualization.Rmd)*
### 3. Model Building: build a supervised document classification model using a training dataset containing only a description of the three themes, evaluate the model with pre-categorized publications
##### *[document-Classification-model.R](https://github.com/lucas3359/text-mining-CoreThemeMatch/blob/master/document-Classification-model.R)*
### 4. Improve the accuracy of the classification model:
##### * Improve the accuracy of the model by taking n-grams into model 
##### *[n-grams.R](https://github.com/lucas3359/text-mining-CoreThemeMatch/blob/master/n-grams.R)*

##### * Take the top matched documents, validate them with customer and use for further model training 

(Note: Pre-categorized models were added to the training data, but were removed as they reduced accuracy.
Once further articles are validated, they can be added back to the model and re-evaluated.)

## Future work to improve accuracy
#### * Word Embeddings as features --- Co-Occurrence Matrix, CBOW(Continuous Bag of words)
#### * Text / NLP based features
#### * Topic Models as features