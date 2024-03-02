# reddit_scaper

<a href="https://zenodo.org/doi/10.5281/zenodo.10750037"><img src="https://zenodo.org/badge/766047399.svg" alt="DOI"></a>

Reddit Scraper Project

This simple yet powerful Reddit Scraper is designed to fetch comments based on specific keywords over a designated period. Aimed at researchers, data analysts, and enthusiasts interested in textual data analysis, this tool provides an efficient way to gather data from Reddit for various analytical purposes, including sentiment analysis, trend identification, and thematic studies.

Features
Keyword-Based Scraping: Target your data collection by specifying keywords.
Period Selection: Collect data from the last 3 months, adjustable as needed.
Data Aggregation: Compiles scraped comments into a structured dataset for analysis.
Basic Text Analysis: Includes initial functions for sentiment and trend analysis.
Visualization: Utilizes ggplot2 for basic visualization of analysis results.

Requirements
R (version 4.0 or higher recommended)
RStudio (optional, for ease of use)

Installation

Before using the Reddit Scraper, ensure the required R packages are installed. Execute the following command in R:


install.packages(c("RedditExtractoR", "tidyverse", "lubridate", "ggplot2", "tm", "wordcloud", "text2vec"))


Usage
Configuration: Specify your target keywords and time frame within the script.
Execution: Run the script to start scraping Reddit comments related to the keywords.
Analysis and Visualization: Use the included functions or add your custom analysis to explore the dataset.
Example Analysis
The project includes examples of basic text analysis, such as frequency counts of terms and sentiment analysis, to kickstart your exploration.

Visualization
The script provides straightforward examples of using ggplot2 for visualizing key insights from the data, such as sentiment trends over time and word frequency charts.

Future Developments
Enhance the scraper to include more detailed metadata from Reddit comments and posts.
Integrate advanced text analysis techniques for deeper insights.
Improve data storage and management for handling large datasets.
Develop a user-friendly interface for non-technical users.
