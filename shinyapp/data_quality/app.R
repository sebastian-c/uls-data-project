#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(FAOSTAT)
library(data.table)
library(ggplot2)

if (!file.exists("Inputs_LandUse_E_All_Data_(Normalized).zip")){
    raw_data <- get_faostat_bulk("RL", ".")
} else {
    raw_data <- read_faostat_bulk("Inputs_LandUse_E_All_Data_(Normalized).zip")
}
    
setDT(raw_data)

flag_map <- c("A" = "Official figure",
              "E" = "Estimated value",
              "I" = "Imputed value",
              "P" = "Provisional value",
              "T" = "Unofficial figure")

raw_data[, flag := flag_map[flag]]


# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("FAOSTAT Land Use data quality"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            selectInput("area", 
                        "Choose a country",
                        choices = raw_data[,unique(area)])
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("tilePlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$tilePlot <- renderPlot({
        ggplot(raw_data[area == input$area], aes(x = year, y = item, fill = flag)) +
            geom_tile() +
            labs(x = "Year", y = "Property")
        
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
