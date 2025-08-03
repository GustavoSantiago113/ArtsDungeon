library(htmltools)

header <- function(){
    div(
        tags$header(
            class="w-full text-center mb-12",
            h1(
                class="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-white mb-4 rounded-lg p-4 shadow-lg",
                style="background-color: #297373;",
                "Art's Dungeon"
            ),
            p(
                class="text-lg sm:text-xl text-gray-400 mb-2",
                "Step into the shadows and explore my collection of hand-painted miniature figures. Click on any creature to unveil its secrets!"
            ),
            p(
                class="text-md sm:text-lg text-gray-500",
                "Contact me: ",
                a(href="mailto:gnocerasantiago@gmail.com", class="text-blue-400 hover:text-blue-300 transition-colors duration-200", "gnocerasantiago@gmail.com")
            )
        )
    )
}