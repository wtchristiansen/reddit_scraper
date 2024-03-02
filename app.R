library(shiny)
library(RedditExtractoR)
library(tidyverse)
library(tidytext)
library(lubridate)

# Define UI
ui <- fluidPage(
  titlePanel("Reddit Sentiment and Trust Trend Analysis"),
  sidebarLayout(
    sidebarPanel(
      textInput("keywords", "Enter Keywords", value = "ex. Biden and Ukraine"),
      numericInput("numThreads", "Number of Threads", value = 10, min = 1, max = 20),
      actionButton("goButton", "Scrape, Analyze, Plot!")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Results", plotOutput("trustPlot"))
      )
    )
  )
)

# Server logic
server <- function(input, output) {
  observeEvent(input$goButton, {
    req(input$keywords)
    
    # Fetch thread URLs based on keywords
    thread_urls <- find_thread_urls(input$keywords, sort_by = "top")
    
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
    
    # Perform sentiment analysis focusing on "trust" sentiment
    words_with_sentiment <- comments_df %>%
      unnest_tokens(word, comment) %>%
      inner_join(get_sentiments("nrc") %>% filter(sentiment == "trust")) 
    
    # Count occurrences of "trust" sentiment by date
    trust_sentiment_by_date <- words_with_sentiment %>%
      group_by(date) %>%
      summarise(trust_count = n())
    
    # Plots w/uncertainty
    
    # Calculate standard error for the trust count by date
    # Assuming trust_sentiment_by_date has been calculated as before
    trust_sentiment_by_date <- trust_sentiment_by_date %>%
      mutate(
        se = sd(trust_count) / sqrt(n()), # Standard error calculation
        upper = trust_count + se * 1.96, # Upper bound of 95% CI
        lower = trust_count - se * 1.96  # Lower bound of 95% CI
      )
  
   
    # Visualization: Trust Trend
    output$trustPlot <- renderPlot({
      # Plot with uncertainty (95% confidence interval)
      ggplot(trust_sentiment_by_date, aes(x = date)) +
        geom_ribbon(aes(ymin = lower, ymax = upper), fill = "lightblue", alpha = 0.5) + # Confidence interval
        geom_line(aes(y = trust_count), color = "blue") + # Trust count trend
        geom_point(aes(y = trust_count), color = "darkblue") + # Points for each day's count
        labs(title = "Expression of Trust for Top Reddit Threads Including Keywords",
             x = "Date",
             y = "Count of 'Trust' Sentiment",
             caption = "Gathered using RedditExtractoR. 95% CIs are displayed as intervals surrounding the observed sentiment counts.") +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
    })
  })
}

# Run the app
shinyApp(ui, server)
