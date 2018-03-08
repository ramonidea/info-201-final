library(shiny)
library(plotly)
source("main.R")
source("music_pop.R")
source("mkmain.R")
source("sportspopmain.R")
source("main.R")

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
        HTML("<p>For our project, we are using Ticketmaster's api. The data set includes all the events that
                are currently listed on Ticketmaster. We are able to access information such as the location of
               events, the type of event, search by genre, location, keyword, and view available offers for
               events. The api and description of the avaliable data is located at:
               <a href = 'https://developer.ticketmaster.com/products-and-docs/apis/getting-started/'> TicketMaster API Link </a> . The data for this set
               comes from data collected by Ticketmaster, Universe, FrontGate and Ticketmaster Resale.
               The data set would include all information that is available directly on the Ticketmaster
               website. For our project, we chose to focus on sports and music for our subjects. From there,
              we categorized them under popularity and price trends. Our goal was to understand the trends of popularity of 
                cities and the corresponding prices for various events. This could be used by event coordinators planning 
                future events and price them accordingly. Understanding the supply and demand can allow for maximum profit 
                while keeping it attractive for fans. Sports fans can also see where there are the most amount of sports events 
                so if they are interested in going to a city to see their favorite team, they can plan accordingly and find the 
              price range and budget.</p>"),
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
                  plotOutput("genre.state",width = 600),
                  tags$p("This map is inteded for event planners to view which state(s) may have higher potential interests in certain genres.")


                   #------End-------
                 ),
                 tabPanel(
                   "mus_pri",
                   #------Music Price Range---
                   tags$h3("Music Event Price Range Page"),
                   tags$br(),
                   tags$h4("Data Report:"),
                   tags$body(paste0("This is a data report for music events in three cities: Seattle, Los Angeles, and New York.
                                    The data shows minimum and maxmimum prices of music events among those three cities and compare prices.
                                    The most cheap music event is ",most.cheap$name, " in ", most.cheap$City,
                                    "and the most expensive music event is ", most.expensive$name, " in ", most.expensive$City)),
                   tags$br(),
                   tableOutput('music_min_price'),
                   tags$br(),
                   tableOutput('music_max_price'),
                   tags$br(),
                   tags$h4("Music events in Seattle"),
                   plotlyOutput('seattle'),
                   tags$body("This graph illustrates the music event prices in Seattle with minimum and maximum prices.
                            Each dot represents each music events. Event's name and genre are included in the data.
                             As illustrated in the graph, Seattle has second most expensive music events among three cities."),
                   tags$br(),
                   plotlyOutput('la'),
                   tags$body("This graph illustrates the price ranges of music event prices in Los Angeles.
                            Each dot represents each music events. Event's name and genre are included in the data."),
                   tags$br(),
                   plotlyOutput('newyork'),
                   tags$body("This graph illustrates the price ranges of music event prices in New York.
                             Each dot represents each music events. Event's name and genre are included in the data.
                             As illustrate by the graph, New York has the most expensive events of all three cities.")
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
                   tags$h1("Sport Price Range Page"),
                   tags$br(),
                   tags$p("The two tables below focuses on the top 5 populated states in the US which includes
                    California, Texas, Florida, New York, and Pennsylvania. The first table represents the
                    the top 5 cheapest tickets among those states whereas, the second one focuses on the most
                    expensive. For any individual in these areas who loves to watch sports and, is not willing to spend a lot on
                    a ticket, this would be a useful dataset. On the otherhand, the second table represents
                    the top 5 expensive tickets. Any sports fanatics around these areas who is willing to
                    splurge for front row seat tickets would find this dataset helpful."),
                   tableOutput('cheapesttickets'),
                   tableOutput('expensivetickets'),
                   tags$br(),
                   tags$p("The bar graph below represents the price ranges for each of the top 5 populated states.
                          The states are color coded. Also, it is interactive as it shows the minimum, mean, and maximum
                          price for tickets when you hover over each of the bars."),
                   plotlyOutput('bargraph'),
                   tags$br("The input filter allows the user to choose what sport they want to see on the US map.
                   More specifically the map shows what state has events associated to the sport selected. The
                   darker the color the state is, the more expensive the ticket is."),
                   selectInput("sport", choices = getDropDownValues(), label = "Sport Type", selected = "Basketball"),
                   plotlyOutput('basketballmap')



                   #-----------End-------------
                 )
               ))
    )
  ))
)
