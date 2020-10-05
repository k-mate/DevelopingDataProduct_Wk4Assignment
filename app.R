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
  titlePanel("Appliction for visualising some fiscal indicators of Indian States"),
  
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

      strong("Source:"),
      em(
        "State Finances - A Study of Budgets",
        span("(Various issues)", style = "color:brown")
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

# Define server logic required to draw a trend graph
server <- function(input, output) {
  mydata <- reactive({
    TableData %>%
      filter(StateName == input$state) %>%
      filter(TableName == input$item) %>%
      mutate(FY = paste(FY, estimate, sep = " ")) %>%
      mutate(tokeep = 0,
             tokeep = replace(tokeep, year == input$report & estimate == "(BE)", 1),
             tokeep = replace(tokeep, year == (as.numeric(input$report) - 1) & estimate == "(RE)", 1),
             tokeep = replace(tokeep, year <= (as.numeric(input$report) - 2) & estimate == "", 1)) %>%
      filter(tokeep == 1) %>%
      select(StateName, FY, year, indicator, value, Description)
    })

  output$sfPlot <- renderPlotly({
    ggplot(mydata(), aes(x = year, y = value, color = Description)) + geom_point() + geom_line() +
      theme(axis.text.x = element_text(angle=90, hjust = 1)) +
      xlab("")
  })
  
  output$sfTable <- DT::renderDataTable({
    datatable(mydata() %>% 
                select(StateName, FY, value, Description) %>%
                spread(FY, value))
    
  })
  


}

# Run the application
shinyApp(ui = ui, server = server)
