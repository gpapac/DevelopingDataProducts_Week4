#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(reshape)
# library(ggplot2)
library(plotly)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  # countries_population<-read.csv("E:/GPAPAC_Files/Study/Coursera/09.DevelopingDataProducts/Week4Assignment/GPAP_DevDataProducts_Week4_App/API_SP.POP.TOTL_DS2_en_csv_v2_9908626.csv",stringsAsFactors=FALSE, skip = 4, header = T, dec=".")
  countries_population<-read.csv("API_SP.POP.TOTL_DS2_en_csv_v2_9908626.csv",stringsAsFactors=FALSE, skip = 4, header = T, dec=".")
  countries_gdp_per_cap<-read.csv("API_NY.GDP.PCAP.CD_DS2_en_csv_v2_9908784.csv",stringsAsFactors=FALSE, skip = 4, header = T, dec=".")
  countries_by_continent<-read.csv("CountryCodesByContinent.csv", sep=';',stringsAsFactors=FALSE, skip = 2, header = T, dec=".")
  countries_by_continent<-countries_by_continent[, c("Continent", "ISO.3166.3", "Country")]
  names(countries_by_continent)[2] <- "CountryCode"
  
  output$continentName <- reactive(input$continent)
  
  metricName <- reactive(if (input$metric=="Population") {
    "Population"
  } else {
    "GDP Per Capita"
  }) 
  
  countriesData <- reactive({  
    cont<-input$continent
#    countries_by_continent<-read.csv("E:/GPAPAC_Files/Study/Coursera/09.DevelopingDataProducts/Week4Assignment/GPAP_DevDataProducts_Week4_App/CountryCodesByContinent.csv", sep=';',stringsAsFactors=FALSE, skip = 2, header = T, dec=".")
#    countries_by_continent<-countries_by_continent[, c("Continent", "ISO.3166.3", "Country")]
#    names(countries_by_continent)[2] <- "CountryCode"
    countries_by_continent[which(countries_by_continent$Continent==cont), ]
  })
    
  countriesDataAll <- reactive({  
    if (input$metric=="Population") {
      countries_metric_data<-countries_population
    } else {
      countries_metric_data<-countries_gdp_per_cap
    }
    countries_metric_data_new <- merge(countriesData(), countries_metric_data, by.x=c("CountryCode"), by.y=c("Country.Code"))    
    countries_metric_data_new <- countries_metric_data_new[, -which(names(countries_metric_data_new)=="Country")]
    countries_metric_data_new <- countries_metric_data_new[, -which(names(countries_metric_data_new)=="Indicator.Name")]
    countries_metric_data_new <- countries_metric_data_new[, -which(names(countries_metric_data_new)=="Indicator.Code")]
    countries_metric_data_new
    
  })
  
  
  output$continentCountries <- renderTable({
        data.frame(x=countriesDataAll())})

  output$linePlot <- renderPlotly({
    metrName=metricName()
    dataToPlot=countriesDataAll()
    dataToPlot <- melt(dataToPlot, c("CountryCode", "Continent", "Country.Name"))
    dataToPlot$year <- as.numeric(substr(as.character(dataToPlot$variable), 2, 20))
    dataToPlot<-dataToPlot[which(dataToPlot$year>=input$yearRange[1] & dataToPlot$year<=input$yearRange[2]),]

    # ggplot(data=dataToPlot,  aes(x=year, y=value, colour=CountryCode, group=CountryCode)) + geom_line(size=0.5) +     xlab("Year") + ylab("Values")
    
    # p<-plot_ly(dataToPlot, x = ~year, y = ~value, color = ~CountryCode, type = 'scatter', mode = 'lines+markers')
    p<-plot_ly(dataToPlot, x = ~year, y = ~value, color = ~CountryCode, type = 'scatter', mode = 'lines'
                ,hoverinfo = 'text',
                text = ~paste(Country.Name, ' (', CountryCode, ')', ', Year:', year, ', ', metrName, ':', value)  
               
               ) %>% layout(xaxis = list(title="Year"), yaxis = list(title=metrName))
    p
    
  })

  
})
