#' Calculate the EI-Index
#'
#' The EI-Index compares the inner-group edge density to the outer-group edge 
#' density. It can be calculated for the whole network and for groups. If you 
#' want to calculate ego's EI use the composition command.
#' @param alteri
#' @param edges_ \code{List} of edgelist-\code{dataframes} or one 
#' \code{dataframes} #' containing all edges_, 
#' @keywords ego-centric network
#' @keywords sna
#' @export
EI <- function(alteri, edges_, var_name, egoID = "egoID", alterID = "alterID") {
  
  # Check if edges_ are dataframe or list, if dataframe split to list by egoID.
  if (!is.data.frame(edges_)) { 
    edges_.list <- edges_
  } else {
    edges_.list <- split(edges_, edges_[[egoID]])
  }
  
  # Check if alteri are dataframe or list, if dataframe split to list by egoID.
  if (!is.data.frame(alteri)) { 
    alteri.list <- alteri
  } else {
    alteri.list <- split(alteri, alteri[[egoID]]) 
  }
  
  # Function: calculating possible dyads between a given number of alteri/ nodes.
  dyad.poss <- function(max.alteri) { (max.alteri ^ 2 - max.alteri) / 2 }
  
  # Function for calculating the possible internal and external edges_.
  possible_edges_ <- function(alteri, var_name) {
    
    # Select only those alteri for which the variable in question was collected.
    alteri <- alteri[!is.na(alteri[[var_name]]), ]
    
    alteri_groups <- split(alteri, alteri[[var_name]])
    tble_var <- sapply(alteri_groups, FUN = NROW)
    poss_internal <- sapply(tble_var, FUN=dyad.poss, simplify = T)
    
    poss_external <- sapply(tble_var, FUN=function(x) {
      poss_ext_edges_ <- (NROW(alteri) - x) * x
    })
    
    list(poss_internal = poss_internal, poss_external = poss_external)
  }
  
  # Classify a single edge as heterogen or homogen.
  rows_to_hm_hts <- function(edge, alteri) {
    if ('Source' %in% names(edge)) {
      source_ <- edge$Source
      target_ <- edge$Target
    } else {
      source_ <- as.numeric(as.character(edge[1,1]))
      target_ <- as.numeric(as.character(edge[1,2]))
    }
    hm_ht <- ifelse(alteri[as.numeric(as.character(alteri[[alterID]])) == source_, ][[var_name]] == alteri[as.numeric(as.character(alteri[[alterID]])) == target_, ][[var_name]], 'HM', 'HT')
    hm_ht
  }
  
  # Calculate group and network EIs.
  lists_to_EIs <- function(edges_, alteri, alterID = 'alterID') {
    #print(alteri$egoID)
    if(NROW(edges_)<1 | !NROW(alteri)>1 ) return(na.df)
    if(length(table(alteri[[var_name]])) < 2) return(na.df)
    # Make sure alteris are sorted and there is a useful alterID
    alteri <- alteri[order(alteri[[alterID]]), ]
    #alteri[[alterID]] <- 1:NROW(alteri)
    
    # Function for calulation EI.
    calc.EI <- function(E, I) {(E-I)/(E+I)}
    # Classify all edges_ as homogen, or heterogen.
    hm_hts <- plyr::adply(edges_, .margins = 1, .fun = rows_to_hm_hts, alteri)
    hm_hts_ <- factor(rev(hm_hts)[[1]], levels = c('HM', 'HT'))
    tble_hm_hts <- table(hm_hts_)
    #if(is.na(tble_hm_hts[1]) | length(tble_hm_hts)<2) return(na.df)
    
    # Calculate regular EI for whole network.
    EIs <- as.numeric(calc.EI(tble_hm_hts['HT'], tble_hm_hts['HM']))
    # Get possible edges_ for all groups (internal and external).
    poss_int_ext <- possible_edges_(alteri, var_name)
    # Count internal and external edges_ for all groups.
    int_ext <- list()
    var_levels <- levels(factor(alteri[[var_name]]))
    for(i in 1:length(var_levels)) {
      
      alteri_ids <- alteri[alterID][ alteri[[var_name]] == var_levels[[i]] , ]
      
      if ('Source' %in% names(hm_hts)) {
        grp_edges_ <- hm_hts[hm_hts$Source %in%  alteri_ids | hm_hts$Target %in%  alteri_ids, ]
      } else {
        grp_edges_ <- hm_hts[hm_hts[1,1] %in%  alteri_ids | hm_hts[1,2] %in%  alteri_ids, ]
      }
      grp_edges_ <- rev(grp_edges_)[[1]]
      grp_edges_ <- factor(grp_edges_, c("HM", "HT"))
      tble_grp_edges_ <- table(grp_edges_)
      int_ext[['HM']][[var_levels[[i]]]] <- tble_grp_edges_['HM']
      int_ext[['HT']][[var_levels[[i]]]] <- tble_grp_edges_['HT']
    } 
    # Dichte für alle Gruppen berechnen. 
    densities <- mapply(function(x,y) x/y, int_ext, poss_int_ext)
    
    # Calculate group EIs, controlled by group-size.
    group_EIs <- calc.EI(densities[, 2], densities[, 1])
    
    # Average of group EIs.
    #avg_net_EIs <-  sum(group_EIs)/length(var_levels)
    # Calculate possible external edges_ for whole network.
    poss_all <- dyad.poss(NROW(alteri))
    poss_ext_all <- poss_all - sum(poss_int_ext$poss_internal)
    
    # Calculate size controlled EI for whole network.
    sc_i <- (sum(densities[, 1]) / length(var_levels))
    sc_e <- (as.numeric(tble_hm_hts['HT']) / poss_ext_all)
    net_EIs_sc <- calc.EI(sc_e, sc_i)
    
    # Return data.frame with all EIs.
    data.frame(t(c(EI = EIs, sc_EI = net_EIs_sc, group_EIs)))
  }
  
  # Create NA data-frame row for networks with missing data or only a single group
  na.df <- data.frame(t(c(EI = NA, sc_EI = NA, rep(NA, nlevels(factor(alteri[[var_name]]))))))
  
  
  # Invoke mapply on edges_ and alteri using list_to_EIs.
  data.frame(t(mapply(lists_to_EIs, edges_.list, alteri.list)))
}



#' Fragmentations of a list of ego-centric networks
#'
#' A longer description will appear here in the future.
#' @param edges_ \code{List} of edgelist-\code{dataframes}
#' @keywords ego-centric network
#' @keywords sna
#' @export
fragmentations <- function(edges_) {
  graphs <- lapply(edges_, FUN = 
                     function(x) igraph::graph.data.frame(x, directed = F))
  frags <- lapply(graphs, FUN = 
           function(x) igraph::clusters(x)$no)
  data.frame(fragmentations = unlist(frags))
}

