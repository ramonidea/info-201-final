library(shiny)
library(shinyjs)
library(plotly)

ui <- htmlTemplate(
  "./www/index.html",
  title = tags$h2("INFO 201 Final Project - Data Analysis with TicketMaster API"),
  #Three Button on the side to control the tabsetPanel
  dashboard = actionButton("dashboard_btn", "Dashboard"),
  #All of the data report goes to the main panel
  mainpanel = fluidRow(column(
    12,
    tabsetPanel(
      id = "tabs",
      tabPanel(
        "dashboard",
        #------Dashboard--------
        tags$h3("Dash Board Page"),
        HTML('<div w-type="event-discovery" w-tmapikey="eaiIn2TBGoRwIeogbqahEzo08X8NAz8w" w-googleapikey="AIzaSyCCCPlLZ9dWptKlpgGM3EkrAx7kHG6V92g" w-keyword="" w-theme="simple" w-colorscheme="light" w-width="500" w-height="600" w-size="25" w-border="0" w-borderradius="4" w-postalcode="" w-radius="25" w-period="week" w-layout="vertical" w-attractionid="" w-promoterid="" w-venueid="" w-affiliateid="" w-segmentid="" w-proportion="custom" w-titlelink="off" w-countrycode="US" w-source="" w-city="Seattle" w-latlong=""></div>'),
        HTML('<script src="js/main-widget.js"></script>'),
        textOutput("intro")
        #-----End-------
      ),
      tabPanel("music",
               tabsetPanel(
                 id = "music_sub",
                 tabPanel(
                   "mus_pop",
                   #-----Music Popularity------
                   tags$h2("Data Report - Music Events (Popularity)"),
                   tags$br(),
                   tags$h4("The Music Events in the 5 months across the country"),
                   tags$p("In the map shown below, the color filled in each states indicates the number of the music related events in each state. 
                          It generally shows how music events distributed in the U.S. and the potential demands among those states."),
                   plotlyOutput("stateCountMap"),
                   tags$p("In the map, the color "),
                  tableOutput("topstate"),
                  tableOutput("topcity")
                   
                   
                   #------End-------
                 ),
                 tabPanel(
                   "mus_pri"
                   #------Music Price Range---
                   
                   
                   #------end---------
                   )
               )),
      tabPanel('sport',
               tabsetPanel(
                 id = "sport_sub",
                 tabPanel(
                   "sport_pop"
                   #-----Sport Popularity------
                   
                   #-----End------
                 ),
                 tabPanel(
                   "sport_pri"
                   #-----Sport Price------
                   
                   #-----------End-------------
                 )
               ))
    )
  ))
)
