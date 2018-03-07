library(shiny)
library(plotly)

ui <- htmlTemplate(
  "./www/index.html",
  title = tags$h2("INFO 201 Final Project - Data Analysis with TicketMaster API"),
  #Three Button on the side to control the tabsetPanel
  dashboard = actionButton("dashboard_btn", "Project Description"),
  #All of the data report goes to the main panel
  mainpanel = fluidRow(column(
    8,
    tabsetPanel(
      id = "tabs",
      tabPanel(
        "dashboard",
        #------Project Description--------
        tags$h3("Project Description"),
        tags$h4("TicketMaster API Data Report"),
        HTML('<div w-type="event-discovery" w-tmapikey="eaiIn2TBGoRwIeogbqahEzo08X8NAz8w" w-googleapikey="YOUR_GOOGLE_API_KEY" w-keyword="" w-theme="simple" w-colorscheme="dark" w-width="100%" w-height="550" w-size="25" w-border="0" w-borderradius="0" w-postalcode="" w-radius="25" w-period="month" w-layout="fullwidth" w-attractionid="" w-promoterid="" w-venueid="" w-affiliateid="" w-segmentid="" w-proportion="custom" w-titlelink="off" w-sorting="groupByName" w-source="" w-countrycode="US" w-postalcodeapi="" w-city="Seattle" w-latlong=""></div>'),
        tags$h3("Group Members:"),
        tags$b(tags$p("Jeeyoung Kim, Kosuke Terada, Ramon Qu, Andrew Thai")),
        tags$h3("Data Set Description:"),
        tags$p("For out project, we are using Ticketmaster's api. The data set includes all the events that
                are currently listed on Ticketmaster. We are able to access information such as the location of
               events, the type of event, search by genre, location, keyword, and view available offers for
               events. The api and description of the avaliable data is located at:
               https://developer.ticketmaster.com/products-and-docs/apis/getting-started/ . The data for this set
               comes from data collected by Ticketmaster, Universe, FrontGate and Ticketmaster Resale.
               The data set would include all information that is available directly on the Ticketmaster
               website. From there, we can refine our search results by setting where the source is from the
               companies listed above. We can define query parameters to find specific listing information for a
               certain event of an artist, sports team, location, etc. It is not too hard to understand the data set.
               You would need to know how to request from the api but for specific events, you would only
               need to know culturally prevalent topics and themes as it is all events that are listed on
               Ticketmaster."),
        tags$br(),
        HTML('<script src="js/main-widget.js"></script>')

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
                   tags$h4("The Music Events across the country"),
                   tags$p("In the map shown below, the color filled in each states indicates the number of the music related events in each state.
                          It generally shows how music events distributed in the U.S. and the potential demands among those states."),
                   plotlyOutput("stateCountMap"),
                   tags$p("In the map, the darker the color is, the more events happening in that state.
                          The red spots shows the events's city/town and the size of the dot shows the number of the events.
                          The more music events one city/state has, it potentially shows the music events demand in that place."),
                   tags$br(),
                   tags$p("The Tables below showing the top cities and states which going to have music events in the next 5 months.
                          (Data retrieved on 3/2/2018)According to the city list, Las Vegas, NYC and Chicago are in the top 3. However, Neither New York nor Nevada states are the top one in the state list.
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
                   "mus_pri",
                   #------Music Price Range---
                   tags$h3("Music Event Price Range Page"),
                   tags$h4("Data Report:"),
                   tags$body(paste0("This is a data report for music events in three cities: Seattle, Los Angeles, and New York.
                                    The most cheap music event is ",most.cheap$name, " in ", most.cheap$City,
                                    "and the most expensive music event is ", most.expensive$name, " in ", most.expensive$City)),
                   tableOutput('music_min_price'),
                   tableOutput('music_max_price'),
                   plotlyOutput('seattle'),
                   plotlyOutput('la'),
                   plotlyOutput('newyork')

                   #------end---------
                   )
               )),
      tabPanel('sport',
               tabsetPanel(
                 id = "sport_sub",
                 tabPanel(
                   "sport_pop",
                   #-----Sport Popularity------
                   tags$h3("Sport Popularity Page"),
                   tags$h4("Data Report"),
                   tags$p(sports.pop.report),
                   tags$h4("Sports Popularity Map"),
                   plotlyOutput('sports_pop_map'),
                   tags$h4("Number of Sports Events per State"),
                   plotlyOutput('sports_pop_bar'),
                   tags$h4("Distribution of Events of Top 5 States"),
                   plotlyOutput('sports_pop_pie')
                   #-----End------
                 ),
                 tabPanel(
                   "sport_pri",
                   #-----Sport Price------
                   tags$h3("Sport Price Range Page")
                   #-----------End-------------
                 )
               ))
    )
  ))
)
