library(shiny)
library(DT)
library(tidyverse)
library(stringr)
library(writexl)
library(plotly)


# Load data ----
TableData <- readRDS("data/TableData.rds")

all_items <- sort(unique(TableData$TableName))
all_states <- sort(unique(TableData$StateName))
all_years <- c(2005:2015)


# User interface ----

# Define UI for application that draws appendix tables
ui <- fluidPage(# Application title
  titlePanel("Some fiscal indicators of Indian States"),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      helpText("Visualise trend of Appendix Tables 1 and 3"),
      
      selectInput(
        "state",
        label = "Select the state(s):",
        selected = c("All States"),
        selectize = TRUE,
        multiple = FALSE,
        choices = all_states
      ),
      
      selectInput(
        "report",
        label = "Select report year:",
        selected = 2019,
        choices = all_years
      ),
      
      
      selectInput("item",
                  label = "Select a Table:",
                  choices = all_items),
      br(),
      
      strong("Data Source:"),
      em(
        "State Finances - A Study of Budgets (Various issues)",
        span("Reserve Bank of India", style = "color:brown")
      )
      
    ),
    
    # Show a plot of the generated distribution
    mainPanel(tabsetPanel(
      tabPanel(
        title = "Chart",
        value = "trend",
        h3("Appendix Tables"),
        h4("Trends in Fiscal Indicators"),
        plotlyOutput("sfPlot")
      ),
      tabPanel(
        title = "Table",
        value = "sfTable",
        DT::dataTableOutput("sfTable"))
      
    )
    ))
)

