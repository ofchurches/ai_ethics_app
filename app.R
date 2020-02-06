# Load packages
library(shinydashboard)
library(dplyr)
library(leaflet)
library(timevis)

# Load data
df <- readRDS(file = "AIethics_in_Adelaide.rds") %>%
    mutate(id = row_number()) %>%
    mutate(content = Label) %>%
    mutate(start = as.Date(Start, "%d/%m/%Y")) %>%
    mutate(end = as.Date(End, "%d/%m/%Y")) %>%
    mutate(time_text = paste(Text, linked_text, "click here."))

tile <- "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png"

# Define UI for application
ui <- dashboardPage(
    
    # Application title
    dashboardHeader(title = "AI Ethics in Adelaide"),
    
    dashboardSidebar(
        
        disable = TRUE
        
    ),
    
    dashboardBody(
        
        tabsetPanel(
        
        tabPanel(
            
            title = "Explore on a map",
            
            h5("Zoom and drag the map to see events and select one to see further details in the map"),
            
            leafletOutput("mymap")
            
        ),
        
        tabPanel(
            
            title = "Explore on a timeline",
            
            h5("Zoom and drag the timeline to see events and select one to see further details here:"),
            
            #textOutput("selected_event")
            
            htmlOutput("html_link"),
            
            timevisOutput("mytime"),
            
        )
        
    )
    
    )
    
)

# Define server logic
server <- function(input, output) {
    
    output$mymap <- renderLeaflet({
        leaflet(df) %>% 
            addTiles(tile) %>%
            addAwesomeMarkers(~Lat, ~Lon, popup = paste(df$Text, 
                                                        paste("<a href=", df$URL,">", df$linked_text,"</a>")
            ), 
            clusterOptions = markerClusterOptions(),
            label = df$Label)
    })
    
    output$mytime <- renderTimevis(timevis(df)) 
    
    #output$selected_event <- renderText(df$Text[as.numeric(input$mytime_selected)])
    
    output$html_link <- renderUI({
        
        a(df$time_text[as.numeric(input$mytime_selected)], href=paste(df$URL[as.numeric(input$mytime_selected)], sep=""), target="_blank") 
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
