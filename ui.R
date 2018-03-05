library(shiny)
library(shinyjs)
library(plotly)
source("main.R")

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
                   tags$p("In the map, the darker the color is, the more events happening in that state.
                          The red spots shows the events's city/town and the size of the dot shows the number of the events.
                          The more music events one city/state has, it potentially shows the music events demand in that place."),
                   tags$br(),
                   tags$p("The Tables below showing the top cities and states which going to have music events in the next 5 months.
                          According to the city list, Las Vegas, NYC and Chicago are in the top 3. However, Neither New York nor Nevada states are the top one in the state list.
                          This clearly shows the Californian has strong interest in music and it is not only in LA, but throught the whole California.
                          In total, they have 155 events. On the other side, Wyoming and arkansas do not have any music related events. They may have smaller events which are not selling tickets on the TicketMaster,
                          but their music demands is definitely smaller than others. For a music event planner, they would love to take look at these data to guess the potential demands among states,
                          and arrange different time and number of shows."),
                  tableOutput("topstate"),
                  tableOutput("topcity"),
                  tags$br(),
                  tags$p("Below the Map shows the number of events by different genres of the music.
                         It allows people to arrange their events to the place which have more potential for the genre of the music.
                         You may select the type of genres to view the map."),
                  selectInput("genre.pop",choices = getGenres(),label = "Music Genre", selected = "Pop"),
                  plotOutput("genre.state",width = 600)
                   
                   
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
