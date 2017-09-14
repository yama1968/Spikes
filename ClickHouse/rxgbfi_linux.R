#' A XGboost Feature Interaction Graphing Function
#'
#' This function allows you to generate a shiny app that outputs the interaction of an xgbmodel.
#' @param model type: XGBModel 
#' @param xgbfi.loc type: filepath File path for the XGBfi folder. Default is C:/xgbfi
#' @param max.interaction.depth type: integer Upper bound for extracted feature interactions depth 
#' @param features type: Character Vector A character vector of the features in the model.
#' @param max.deepening  type: integer Upper bound for interaction start deepening (zero deepening => interactions starting @root only)
#' @param max.trees type: integer Upper bound for trees to be parsed 
#' @param top.k type: integer Upper bound for exportet feature interactions per depth level 
#' @param max.histograms type: integer Amounts of split value histograms
#' 
#' @keywords xgboost, xgbfi
#' @export
#' @examples
#' library(xgboost)
#' library(Ecdat)
#' data(Icecream)
#' train.data <- data.matrix(Icecream[,-1])
#' bst <- xgboost(data = train.data, label = Icecream$cons, max.depth = 3, eta = 1, nthread = 2, nround = 2, objective = "reg:linear")
#' features <- names(Icecream[,-1])
#' xgb.fi(model = bst, features = features)
#' 
#' 
#' 
#'
xgb.fi <- function(model, xgbfi.loc = "/home/yannick/bin/xgbfi", features = NULL, max.interaction.depth = 2, 
                   max.deepening = -1, max.trees = -1, top.k = 100, max.histograms = 10) {
  library(xgboost)
  xgbfi_exe <- paste0(xgbfi.loc, "/", "bin", "/", "XgbFeatureInteractions.exe")
  
  featureVector <- c()
  for (i in 1:length(features)) {
    featureVector[i] <- paste(i - 1, features[i], "q", sep = "\t")
  }
  
  if(!file.exists(file.path(xgbfi.loc, "bin", "XgbFeatureInteractions.exe"))) {
    msg <- paste0("'XGBfi' must be installed to install XGBfiR.")
    
    message(
      msg, "\n",
      "Would you like to install XGBfi? ", "\n",
      "This will source <https://github.com/Far0n/xgbfi/archive/master.zip>.", "\n",
      "It will be installed in the following location. ", "\n", dirname(xgbfi.loc)
    )
    
    if (menu(c("Yes", "No")) != 1) {
      stop("'XGBfiR' not installed.", call. = FALSE)
    } else {
      temp <- tempfile("xgbfi")
      download.file("https://github.com/Far0n/xgbfi/archive/master.zip", temp, mode="wb")
      unzip(temp, exdir = dirname(xgbfi.loc))
      file.rename(from = file.path(dirname(xgbfi.loc), 'xgbfi-master'), to = file.path(dirname(xgbfi.loc), "xgbfi"))
    }
  } 
  
  
  
  write.table(featureVector, paste0(xgbfi.loc, "/", "fmap.txt"), row.names = FALSE, quote = FALSE, col.names = FALSE)
  
  invisible(xgb.dump(model = model, fname = paste0(xgbfi.loc, "/", "xgb.dump"), fmap = paste0(xgbfi.loc, "/", "fmap.txt"), with_stats = TRUE))
  
  command <- paste0('/home/yannick/bin/anaconda3/bin/xgbfir ',
                    ' -m ', paste0(xgbfi.loc, "/", "xgb.dump"),
                    ' -d ', max.interaction.depth,
                    ' -g ', max.deepening,
                    ' -t ', max.trees,
                    ' -k ', top.k,
                    # ' -h ', max.histograms,
                    ' -o ', paste0(xgbfi.loc, "/", "XgbFeatureInteractions.xlsx"))
  
  print(command)
  
  out <- system(command, intern =TRUE)
  
  if (!dir.exists(file.path(xgbfi.loc, "bin", "EPPlus"))) {
    dir.create(file.path(xgbfi.loc, "bin", "EPPlus"))
    file.copy(file.path(xgbfi.loc, "bin", "lib", "EPPlus.dll"), file.path(xgbfi.loc, "bin", "EPPlus"))
  }
  
  if (!dir.exists(file.path(xgbfi.loc, "bin", "NGenerics"))) {
    dir.create(file.path(xgbfi.loc, "bin", "NGenerics"))
    file.copy(file.path(xgbfi.loc, "bin", "lib", "NGenerics.dll"), file.path(xgbfi.loc, "bin", "NGenerics"))
  }
  
  require(shiny, quietly = T)
  library(dplyr, quietly = T)
  library(data.table, quietly = T)
  library(openxlsx, quietly = T)
  library(DT, quietly = T)
  
  shinyApp(ui = fluidPage( navbarPage("XGBoost",
                                      tabPanel("XGBoost Feature Interaction",
                                               fluidPage(
                                                 tabsetPanel(
                                                   tabPanel("Feature Interaction", value = 1, h4("Feature Interaction"),
                                                            p("The feature interactions present in the model."), DT::dataTableOutput("tableVars1")),
                                                   tabPanel("2 Variable Feature Interaction", value = 2, h4("Feature Interaction"),
                                                            p("The 2 variables feature interactions present in the model."), DT::dataTableOutput("tableVars2")),
                                                   tabPanel("3 Variable Feature Interaction", value = 2, h4("Feature Interaction"),
                                                            p("The 3 variables feature interactions present in the model."), DT::dataTableOutput("tableVars3")),
                                                   id = "conditionedPanels"))))),                                              
           server = function(input, output) {
             
             
             
             tableVars1 <- function(){
               featuresimp <- openxlsx::read.xlsx(paste0(xgbfi.loc, "/", "XgbFeatureInteractions.xlsx"))
               featuresimp <- as.data.table(featuresimp)
               featuresimp[, Gain.Percentage := Gain/sum(Gain)]
               cols <- c('wFScore', 'Average.wFScore', 'Average.Gain', 'Expected.Gain', 'Gain.Percentage')
               featuresimp[,(cols) := round(.SD,4), .SDcols=cols]
               setcolorder(featuresimp, c("Interaction", "Gain.Percentage", colnames(featuresimp)[!colnames(featuresimp) %in% c("Interaction", "Gain.Percentage")]))
               
             }
             
             
             tableVars2 <- function(){
               featuresimp <- openxlsx::read.xlsx(paste0(xgbfi.loc, "/", "XgbFeatureInteractions.xlsx"), sheet = 2)
               featuresimp <- as.data.table(featuresimp)
               featuresimp[, c("Var1", "Var2") := tstrsplit(Interaction, "|", fixed=TRUE)]
               featuresimp[, ':='(Interaction  = NULL)]
               featuresimp[, Gain.Percentage := Gain/sum(Gain)]
               cols <- c('wFScore', 'Average.wFScore', 'Average.Gain', 'Expected.Gain', 'Gain.Percentage')
               featuresimp[,(cols) := round(.SD,4), .SDcols=cols]
               setcolorder(featuresimp, c("Var1", "Var2", "Gain.Percentage", colnames(featuresimp)[!colnames(featuresimp) %in% c("Var1", "Var2", "Gain.Percentage")]))
               
             }
             
             
             tableVars3 <- function(){
               featuresimp <- openxlsx::read.xlsx(paste0(xgbfi.loc, "/", "XgbFeatureInteractions.xlsx"), sheet = 3)
               featuresimp <- as.data.table(featuresimp)
               featuresimp[, c("Var1", "Var2", "Var3") := tstrsplit(Interaction, "|", fixed=TRUE)]
               featuresimp[, ':='(Interaction  = NULL)]
               featuresimp[, Gain.Percentage := Gain/sum(Gain)]
               cols <- c('wFScore', 'Average.wFScore', 'Average.Gain', 'Expected.Gain', 'Gain.Percentage')
               featuresimp[,(cols) := round(.SD,4), .SDcols=cols]
               setcolorder(featuresimp, c("Var1", "Var2", "Var3", "Gain.Percentage", colnames(featuresimp)[!colnames(featuresimp) %in% c("Var1", "Var2", "Var3", "Gain.Percentage")]))
             }
             
             
             
             output$tableVars1 <- DT::renderDataTable(
               datatable(tableVars1(),
                         filter = 'top',
                         class = 'hover stripe',
                         options = list(pageLength = 100,
                                        lengthMenu = c(10, 50, 100, 200))
               ) %>% formatStyle('Gain.Percentage',
                                 background = styleColorBar(c(0, max(tableVars1()$Gain.Percentage)), 'lightgreen'),
                                 backgroundSize = '100% 90%',
                                 backgroundRepeat = 'no-repeat',
                                 backgroundPosition = 'center') %>%
                 formatPercentage(columns = c('Gain.Percentage'),
                                  digits = 4)
               
               
               
             )
             
             
             output$tableVars2 <-DT::renderDataTable(
               datatable(tableVars2(),
                         filter = 'top',
                         class = 'hover stripe',
                         options = list(pageLength = 100,
                                        lengthMenu = c(10, 50, 100, 200))
               ) %>% formatStyle('Gain.Percentage',
                                 background = styleColorBar(c(0, max(tableVars2()$Gain.Percentage)), 'lightgreen'),
                                 backgroundSize = '100% 90%',
                                 backgroundRepeat = 'no-repeat',
                                 backgroundPosition = 'center') %>%
                 formatPercentage(columns = c('Gain.Percentage'),
                                  digits = 4)
               
               
               
             )
             
             
             output$tableVars3 <-DT::renderDataTable(
               datatable(tableVars3(),
                         filter = 'top',
                         class = 'hover stripe',
                         options = list(pageLength = 100,
                                        lengthMenu = c(10, 50, 100, 200))
               ) %>% formatStyle('Gain.Percentage',
                                 background = styleColorBar(c(0, max(tableVars3()$Gain.Percentage)), 'lightgreen'),
                                 backgroundSize = '100% 90%',
                                 backgroundRepeat = 'no-repeat',
                                 backgroundPosition = 'center') %>%
                 formatPercentage(columns = c('Gain.Percentage'),
                                  digits = 4)
               
               
               
             )
             
             
           }
  )
}
