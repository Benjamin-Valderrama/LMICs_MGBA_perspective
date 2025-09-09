#' Functions that can be helpful

# 1. custom theme 
theme_bv <- function(){
        
    theme_bw() +
    theme(
          # make aesthetic elements black
          axis.title = element_text(color = "black"),
          axis.text = element_text(color = "black"),

          panel.border = element_rect(color = "black")
          )
}



# 2. check if a publication was an international collaboration.
is_international_collaboration <- function(AU_CO){
    
    #'Description: 
    #'Counts the number of different countries listed in the publication record.
    #'
    #'Output:
    #'TRUE/FALSE if it is an international collaboration (or not)
    
    # handle case where countries are NAs 
    AU_CO <- ifelse(is.na(AU_CO), "", AU_CO)
    
    # get a list of countries
    countries <- str_split_1(AU_CO, pattern = ";")
    # count the number of countries
    n_countries <- n_distinct(countries)
    
    
    if (n_countries > 1){
        collaboration <- TRUE

    } else {
        collaboration <- FALSE
    }

    return(collaboration)
}



# 3. Determine the income groups participating in the international collaboration
determine_incomes_of_collaborating_countries <- function(AU_CO){

    # Handle NAs
    AU_CO <- ifelse(is.na(AU_CO), "", AU_CO)

    # Check the income group of the collaborating countries.
    # Note: HICs , UMICs , LMICs are taken from the environment
    countries <- str_split_1(AU_CO, pattern = ";") |> unique() |> str_trim()
    includes_HICs <- any(countries %in% HICs)
    includes_UMICs <- any(countries %in% UMICs)
    includes_LMICs <- any(countries %in% LMICs)

    # return collab type
    if (includes_HICs & includes_UMICs & includes_LMICs) {
        collab <- "All income groups"

    } else if (includes_HICs & includes_UMICs) {
        collab <- "HICs_UMICs"

    } else if (includes_HICs & includes_LMICs) {
        collab <- "HICs_LMICs"

    } else if (includes_UMICs & includes_LMICs) {
        collab <- "UMICs_LMICs"

    } else if (includes_HICs) {
        collab <- "HICs_only"

    } else if (includes_UMICs) {
        collab <- "UMICs_only"

    } else if (includes_LMICs) {
        collab <- "LMICs_only"

    } else  {
        collab <- NA
    }
    collab
}
