# Install and load necessary packages
if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
devtools::install_github('ivan-rivera/RedditExtractor') # Install the RedditExtractoR package

if (!requireNamespace("tidyverse", quietly = TRUE)) install.packages("tidyverse")
if (!requireNamespace("tidytext", quietly = TRUE)) install.packages("tidytext")
if (!requireNamespace("lubridate", quietly = TRUE)) install.packages("lubridate")
# Install the textdata package
if (!requireNamespace("textdata", quietly = TRUE)) {
  install.packages("textdata")
}

# Load packages
library(textdata)
library(RedditExtractoR)
library(tidyverse)
library(tidytext)
library(lubridate)

# Define keywords for extracting Reddit comments
keywords <- "tigray" # Adjust keywords as needed

# Fetch thread URLs based on keywords
thread_urls <- find_thread_urls(keywords = keywords, sort_by = "top")

# Fetch thread content (adjust the slice for more or fewer threads)
threads_contents <- get_thread_content(thread_urls$url[1:10]) # Example uses the top 10 threads

# Combine comments into a single dataframe
comments_df <- bind_rows(threads_contents$comments) %>%
  mutate(index = row_number()) # Add a unique index to each comment

# Ensure date is in correct format (if not already)
comments_df$date <- as.Date(comments_df$date)

# Sentiment Analysis
words <- comments_df %>%
  unnest_tokens(word, comment) %>%
  anti_join(stop_words) %>%
  inner_join(get_sentiments("bing")) %>%
  count(index, sentiment, sort = TRUE)

comment_sentiments <- words %>%
  group_by(index) %>%
  summarise(positivity = sum(sentiment == "positive") - sum(sentiment == "negative"))

# Trend Analysis
comments_trend <- comments_df %>%
  left_join(comment_sentiments, by = "index") %>%
  group_by(date) %>%
  summarise(average_sentiment = mean(positivity, na.rm = TRUE))

# Visualization with ggplot2
ggplot(comments_trend, aes(x = date, y = average_sentiment)) +
  geom_line() +
  geom_smooth(se = FALSE, color = "blue") +
  labs(title = "Trend of Sentiment for Keywords over Time",
       x = "Date",
       y = "Average Sentiment Score",
       caption = "Data sourced from Reddit comments") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# graph trust over time

# Assuming you've already fetched and prepared `comments_df` as per previous instructions

# Perform sentiment analysis focusing on "trust" sentiment
words_with_sentiment <- comments_df %>%
  unnest_tokens(word, comment) %>%
  inner_join(get_sentiments("nrc") %>% filter(sentiment == "trust")) 
# Filter for "trust" sentiment

# Count occurrences of "trust" sentiment by date
trust_sentiment_by_date <- words_with_sentiment %>%
  group_by(date) %>%
  summarise(trust_count = n())

# Visualization of Trust Sentiment Over Time
ggplot(trust_sentiment_by_date, aes(x = date, y = trust_count)) +
  geom_line(color = "forestgreen") +
  geom_point(color = "darkgreen") +
  labs(title = "Trend of 'Trust' Sentiment Over Time",
       x = "Date",
       y = "Count of 'Trust' Sentiment") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Note: This plot shows the count of occurrences of the "trust" sentiment in the comments over time.

# Plots w/uncertainty

# Assuming you have a dataframe 'comments_trend' with 'date' and 'average_sentiment'
# Calculate the start date as x months before today
start_date <- Sys.Date() %m-% months(1)

# Calculate the end date as today
end_date <- Sys.Date()

# Generate a sequence of dates from start_date to end_date
dates <- seq(from = start_date, to = end_date, by = "day")

# Calculate standard error for the trust count by date
# Assuming trust_sentiment_by_date has been calculated as before
trust_sentiment_by_date <- trust_sentiment_by_date %>%
  mutate(
    se = sd(trust_count) / sqrt(n()), # Standard error calculation
    upper = trust_count + se * 1.96, # Upper bound of 95% CI
    lower = trust_count - se * 1.96  # Lower bound of 95% CI
  )

# Plot with uncertainty (95% confidence interval)
ggplot(trust_sentiment_by_date, aes(x = date)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "lightblue", alpha = 0.5) + # Confidence interval
  geom_line(aes(y = trust_count), color = "blue") + # Trust count trend
  geom_point(aes(y = trust_count), color = "darkblue") + # Points for each day's count
  labs(title = "Trend of 'Trust' Sentiment Over Time with Uncertainty",
       x = "Date",
       y = "Count of 'Trust' Sentiment") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

