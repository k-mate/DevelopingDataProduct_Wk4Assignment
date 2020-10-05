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
      ylab("Rs. crore")
  })
  
  output$sfTable <- DT::renderDataTable({
    datatable(mydata() %>% 
                select(StateName, FY, value, Description) %>%
                spread(FY, value))
  })
}

