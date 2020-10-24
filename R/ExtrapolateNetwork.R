#' @param df,a,N 3 inputs
#' @return adjacency matrix of the simulated network, dataframe of the simulated network, number of mismatches in the building process
#' @export
# ==================== function: ExtrapolateNetwork===================
ExtrapolateNetwork <- function(df, # the dataframe of ego networks from survey
                               a, # the number of different values the attribute can take
                               N){  # the number of desired agents in the network for ABM

  # start extrapolating the agents dataframe ================
  # create empty datasets for the agents
  agents <- data.frame(matrix(vector(), N, a+2,   # the two extra columns are for 'attribute' and 'degree'
                              dimnames=list(c(), colnames(df))),
                       stringsAsFactors=F)

  # fit attribute distribution,   so that the distribution of attributes in the agents is similar to in df
  # find out the probability of each attribute from data, df
  attribute_distribution <- table(df$attribute)/length(df$attribute)
  # use these probabilities to generate attributes for agents
  agents$attribute <- sample(names(attribute_distribution), N, replace = T, prob = attribute_distribution)

  # fit the "attribute by degree" distribution,    so that e.g. the prob of number of black friends for a white
  #                                                     person in agents is similar to that in df, etc.
  # find out the degree distribuion for each pair of the attribute
  for (attr in names(attribute_distribution)) {
    for (friendAttr in names(df)[3:length(names(df))]) {
      LinkDist <- df[which(df['attribute']== attr),friendAttr] # identify link distribution
      if (length(LinkDist) >= 3){
        PDF <- approxfun(density(LinkDist)) # extrapolate the prob density function for the degree distribution
        agents[which(agents['attribute']== attr),friendAttr] <- sample(0:max(df[friendAttr]),
                                                                       length(which(agents['attribute']== attr)),
                                                                       replace = T,
                                                                       prob = PDF(0:max(df[friendAttr])))
      }
    }
  }
  agents$degree <- 0
  for (friendAttr in names(df)[3:length(names(df))]){
    agents$degree <- agents$degree + agents[friendAttr]
  }
  # end extrapolating dataframe ======================

  # generate graph based on (extrapolated) dataframe ======
  newdf <- agents[order(-agents$degree),]    # order the dataframe by degree in decending order
  newdf <- newdf[newdf$degree > 0, ]  # get rid of unconnected nodes
  adj_mat <- matrix(0,
                    ncol = length(newdf[,1]),
                    nrow = length(newdf[,1]),
                    dimnames = list(rownames(newdf),rownames(newdf)))
  mismatch <- 0

  for (i in 1:length(newdf[,1])){
    for (friendAttr in names(newdf)[3:length(names(df))]){
      while (newdf[i,friendAttr]>0) {
        from_attr <- newdf[i,'attribute']   # seeker's attribute
        to_attr <- friendAttr      # attribute being sought after
        from_name <- rownames(newdf[i,])   # seeker's name
        possible_matches_row <- which(newdf$attribute == to_attr) # who has the attribute sought after
        possible_matches_row <- possible_matches_row[-i]  # except for the seeker
        possible_matches_df <- newdf[possible_matches_row,]
        possible_matches_df <- possible_matches_df[which(possible_matches_df[,from_attr] > 0),] # who's available
        possible_matches <- rownames(possible_matches_df) # available matches' names
        if (length(possible_matches) > 0){
          match <- sample(possible_matches,1) # first match with mutual needed nodes
          #}else if (length(which(newdf$from_attr > 0))>0) {
          #match <- sample(which(newdf$from_attr > 0),1) # or match with nodes that need but not needed by the seeker
          #mismatch <- mismatch + 1
        }else{
          mismatch <- mismatch + 1    # or give up matching
          match <- -1
        }
        if (as.integer(match) > 0){    # if a match exists
          to_name <- rownames(newdf[match,])
          adj_mat[from_name,to_name] <- 1
          adj_mat[to_name,from_name] <- 1
          newdf[i,to_attr] <- newdf[i,to_attr] - 1
          newdf[match,from_attr] <- newdf[match,from_attr] - 1
        }else{
          newdf[i,to_attr] <- newdf[i,to_attr] - 1
        }
      }
    }
    #print(i)
  }
  # ==========
  return(list(AdjacencyMat = adj_mat,
              AgentsDf = agents,
              MisMatch = mismatch))
}
# ==========================

