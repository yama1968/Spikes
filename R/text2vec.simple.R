
# https://cran.r-project.org/web/packages/text2vec/vignettes/text-vectorization.html

library(text2vec)
library(data.table)
library(dplyr)

data("movie_review")
setDT(movie_review)
setkey(movie_review, id)

set.seed(2016L)
all_ids = movie_review$id
train_ids = sample(all_ids, 4000)
test_ids = setdiff(all_ids, train_ids)
train = movie_review[J(train_ids)]
test = movie_review[J(test_ids)]

# define preprocessing function and tokenization fucntion
prep_fun = tolower
tok_fun = word_tokenizer

it_train = itoken(train$review,
                  preprocessor = prep_fun,
                  tokenizer = tok_fun,
                  ids = train$id,
                  progressbar = FALSE)
vocab = create_vocabulary(it_train)
#
# train_tokens = train$review %>%
#   prep_fun %>%
#   tok_fun
# it_train = itoken(train_tokens,
#                   ids = train$id,
#                   # turn off progressbar because it won't look nice in rmd
#                   progressbar = FALSE)
#
# vocab = create_vocabulary(it_train)
# vocab

vectorizer = vocab_vectorizer(vocab)
t1 = Sys.time()
dtm_train = create_dtm(it_train, vectorizer)
print(difftime(Sys.time(), t1, units = 'sec'))


library(glmnet)
NFOLDS = 4
t1 = Sys.time()
glmnet_classifier = cv.glmnet(x = dtm_train, y = train[['sentiment']],
                              family = 'binomial',
                              # L1 penalty
                              alpha = 1,
                              # interested in the area under ROC curve
                              type.measure = "auc",
                              # 5-fold cross-validation
                              nfolds = NFOLDS,
                              # high value is less accurate, but has faster training
                              thresh = 1e-3,
                              # again lower number of iterations for faster training
                              maxit = 1e3)
print(difftime(Sys.time(), t1, units = 'sec'))

plot(glmnet_classifier)

print(paste("max AUC =", round(max(glmnet_classifier$cvm), 4)))

# Note that most text2vec functions are pipe friendly!
it_test = test$review %>%
  prep_fun %>%
  tok_fun %>%
  itoken(ids = test$id,
         # turn off progressbar because it won't look nice in rmd
         progressbar = FALSE)

dtm_test = create_dtm(it_test, vectorizer)

preds = predict(glmnet_classifier, dtm_test, type = 'response')[,1]
glmnet:::auc(test$sentiment, preds)


stop_words = c("i", "me", "my", "myself", "we", "our", "ours", "ourselves", "you", "your", "yours")
t1 = Sys.time()
vocab = create_vocabulary(it_train, stopwords = stop_words)
print(difftime(Sys.time(), t1, units = 'sec'))

pruned_vocab = prune_vocabulary(vocab,
                                term_count_min = 10,
                                doc_proportion_max = 0.5,
                                doc_proportion_min = 0.001)
vectorizer = vocab_vectorizer(pruned_vocab)
# create dtm_train with new pruned vocabulary vectorizer
t1 = Sys.time()
dtm_train  = create_dtm(it_train, vectorizer)
print(difftime(Sys.time(), t1, units = 'sec'))

dtm_test   = create_dtm(it_test, vectorizer)
dim(dtm_test)

t1 = Sys.time()
vocab = create_vocabulary(it_train, ngram = c(1L, 2L))
print(difftime(Sys.time(), t1, units = 'sec'))


vocab = vocab %>% prune_vocabulary(term_count_min = 10,
                                   doc_proportion_max = 0.5)

bigram_vectorizer = vocab_vectorizer(vocab)

dtm_train = create_dtm(it_train, bigram_vectorizer)

t1 = Sys.time()
glmnet_classifier = cv.glmnet(x = dtm_train, y = train[['sentiment']],
                              family = 'binomial',
                              alpha = 1,
                              type.measure = "auc",
                              nfolds = NFOLDS,
                              thresh = 1e-3,
                              maxit = 1e3)
print(difftime(Sys.time(), t1, units = 'sec'))

plot(glmnet_classifier)
print(paste("max AUC =", round(max(glmnet_classifier$cvm), 4)))

# apply vectorizer
dtm_test = create_dtm(it_test, bigram_vectorizer)
preds = predict(glmnet_classifier, dtm_test, type = 'response')[,1]
glmnet:::auc(test$sentiment, preds)


