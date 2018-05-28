#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Population and GDP Per capita evolution per Country (by continent)"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(

    sidebarPanel(
      helpText("Select a continent and a metric",
               "and press submit to view the evolution of the metric",
               "for all the countries in the continent.",
               "You can also change the range of years showing in the plot.",
               "In the tab: 'Table data', the data are displayed in tabular format"
               ),
      selectInput("continent", "Continent:",
                  c("Africa"="Africa",
                    "Asia"="Asia",
                    "Australia (Oceania)"="Australia (Oceania)",
                    "Europe"="Europe",
                    "North America"="North America",
                    "South America"="South America"), selected="Europe" ),
      radioButtons("metric", "Metric:",
                   choices = c("Population", "GDP Per Capita"),
                   selected = "Population"),
      sliderInput("yearRange",
                   "Year range:",
                   min = 1960,
                   max = 2017,
                   sep = "",
                   value = c(1960, 2017)),
    
      submitButton("Submit")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(type="tabs", 
                  tabPanel("Plot", br(), plotlyOutput("linePlot")),
                  tabPanel("Table data", br(), textOutput("continentName"), br(), htmlOutput("continentCountries")) 
                  )
      
       
    )
  )
))
