#
# http://varianceexplained.org/r/yelp-sentiment/

library(readr)
library(dplyr)

# we're reading only 200,000 in this example
# you can try it with the full dataset too, it's just a little slower to process!
# infile <- "~/Downloads/yelp_dataset_challenge_academic_dataset/yelp_academic_dataset_review.json"
infile <- "~/Téléchargements/yelp/yelp_academic_dataset_review.json"
#review_lines <- read_lines(infile, n_max = 200000, progress = FALSE)
review_lines <- read_lines(infile)

library(stringr)
library(jsonlite)

# Each line is a JSON object- the fastest way to process is to combine into a
# single JSON string and use fromJSON and flatten
reviews_combined <- str_c("[", str_c(review_lines, collapse = ", "), "]")

reviews <- fromJSON(reviews_combined) %>%
  flatten() %>%
  tbl_df()

reviews

library(tidytext)

review_words <- reviews %>%
  select(review_id, business_id, stars, text) %>%
  unnest_tokens(word, text) %>%
  filter(!word %in% stop_words$word,
         str_detect(word, "^[a-z']+$"))

review_words


AFINN <- sentiments %>%
  filter(lexicon == "AFINN") %>%
  select(word, afinn_score = score)

AFINN

reviews_sentiment <- review_words %>%
  inner_join(AFINN, by = "word") %>%
  group_by(review_id, stars) %>%
  summarize(sentiment = mean(afinn_score))

reviews_sentiment

# plotting

library(ggplot2)
theme_set(theme_bw())

ggplot(reviews_sentiment, aes(stars, sentiment, group = stars)) +
  geom_boxplot() +
  ylab("Average sentiment score")


review_words_counted <- review_words %>%
  count(review_id, business_id, stars, word) %>%
  ungroup()

review_words_counted


word_summaries <- review_words_counted %>%
  group_by(word) %>%
  summarize(businesses = n_distinct(business_id),
            reviews = n(),
            uses = sum(n),
            average_stars = mean(stars)) %>%
  ungroup()

word_summaries


word_summaries_filtered <- word_summaries %>%
  filter(reviews >= 200, businesses >= 10)

word_summaries_filtered

word_summaries_filtered %>%
  arrange(desc(average_stars))

word_summaries_filtered %>%
  arrange(average_stars)

ggplot(word_summaries_filtered, aes(reviews, average_stars)) +
  geom_point() +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1, hjust = 1) +
  scale_x_log10() +
  geom_hline(yintercept = mean(reviews$stars), color = "red", lty = 2) +
  xlab("# of reviews") +
  ylab("Average Stars")
library(plotly)
ggplotly()


ggplot(word_summaries_filtered, aes(reviews, average_stars)) +
  geom_point(alpha = 0.2) +
  scale_x_log10() +
  geom_hline(yintercept = mean(reviews$stars), color = "red", lty = 2) +
  xlab("# of reviews") +
  ylab("Average Stars")
library(plotly)
ggplotly()


words_afinn <- word_summaries_filtered %>%
  inner_join(AFINN)

words_afinn

ggplot(words_afinn, aes(afinn_score, average_stars, group = afinn_score)) +
  geom_boxplot() +
  xlab("AFINN score of word") +
  ylab("Average stars of reviews with this word")



ggplot(words_afinn, aes(reviews, average_stars, colour = afinn_score)) +
  scale_colour_gradient(low = "red", high = "blue") +
  geom_point() +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1, hjust = 1) +
  scale_x_log10() +
  geom_hline(yintercept = mean(reviews$stars), color = "red", lty = 2) +
  xlab("# of reviews") +
  ylab("Average Stars")
