library(shiny)
library(ellmer)
library(kuzco)
library(gt)
library(gargle)
library(magick)
library(bslib)

# Cargar funciones auxiliares
source("my_view_llm_results.R")

# Claves API desde variables de entorno
GEMINI_API_KEY <- Sys.getenv("GEMINI_API_KEY")
GOOGLE_API_KEY <- Sys.getenv("GOOGLE_API_KEY")

ui <- fluidPage(
  # Encabezado con título y subtítulo centrados
  tags$div(
    style = "text-align: center; margin-bottom: 10px;",
    tags$h1("BioObserva"),
    tags$h4("Detección e identificación de especies en imágenes")
  ),
  
  # Logo centrado debajo del título
  tags$div(
    style = "text-align: center; margin-bottom: 10px;",
    tags$img(src = "logo_maritza.png", style = "width: 150px; height: auto;")
  ),
  
  # Texto de crédito debajo del logo, también centrado y con estilo pequeño
  tags$div(
    style = "text-align: center; font-style: italic; font-size: 0.9em; margin-bottom: 30px;",
    "Ilustración por Gemini 2.0 Flash y Maritza Ramírez"
  ),
  
  sidebarLayout(
    sidebarPanel(
      fileInput(
        inputId = "imagen",
        label = "Escoge una imagen",
        buttonLabel = "Seleccionar...",
        placeholder = "Ningún archivo seleccionado",
        width = "400px"
      ),
      textInput(
        inputId = "prompt",
        label = "Tu solicitud (Ejemplo: qué especie se ve en la imagen)",
        placeholder = "Escribe aquí lo que quieras saber de la imagen",
        width = "100%"
      ),
      actionButton("goButton", "Envía tu solicitud")
    ),
    
    mainPanel(
      div(
        style = "max-width: 800px; margin: 0 auto; text-align: center;",
        
        # Imagen adaptable al ancho disponible
        imageOutput("my_image", height = "auto", width = "100%"),
        
        # Texto decorado
        div(
          style = "margin-top: 20px; white-space: pre-wrap; word-wrap: break-word; 
               border: 1px solid #ccc; padding: 10px; border-radius: 6px; 
               background: #f8f8f8; text-align: left;",
          textOutput("text1")
        ),
        
        # Tabla centrada
        div(
          style = "margin-top: 20px;",
          gt_output("results_table")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  # Mostrar la imagen cargada
  observeEvent(input$imagen, {
    req(input$imagen)
    output$my_image <- renderImage({
      list(
        src = input$imagen$datapath,
        contentType = input$imagen$type,
        width = "50%",
        height = "auto"
      )
    }, deleteFile = FALSE)
  })
  
  # Reactive para guardar resultados del modelo
  results <- reactiveVal()
  
  # Llamar al modelo cuando se presiona el botón
  observeEvent(input$goButton, {
    req(input$imagen, input$prompt)
    
    res <- kuzco::llm_image_classification(
      provider = "google_gemini",
      llm_model = "gemini-2.5-flash",
      backend = "ellmer",
      additional_prompt = input$prompt,
      image = input$imagen$datapath,
      language = "Spanish",
      api_key = GOOGLE_API_KEY
    )
    
    results(res)
    
    output$text1 <- renderText({
      paste("Modelo respondió con", length(res), "resultados.")
    })
  })
  
  # Mostrar resultados con gt
  output$results_table <- gt::render_gt({
    req(results())
    my_view_llm_results(results())
  })
}

# Ejecutar la app
shinyApp(ui = ui, server = server)