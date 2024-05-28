#-------------------------------------------------------------------------------

library(ggpubr)

#-------------------------------------------------------------------------------

# all this should be moved to a repository named CNCFlora at some point

#path to data

path <- "../../Data/CNCFlora/AOH_sim/"


# ggboxplot(AOH_combined,x ="ratio_f",y = "AOH.area_1000",ylab = "AOH (1000 ha)",xlab=" sample ratio")+
#   geom_jitter(aes(color = ratio), width = 0.2, alpha = 0.5) +
#     theme_minimal() +
#     theme(axis.text.x = element_text(angle = 45, hjust = 1))

# list files

df_ls <- list.files(path,full.names = T)[1:2]

# read it

dfs <- lapply(df_ls,read.csv)

# combine into a single data.frame

df <- do.call(rbind,dfs)

# add color to the categories

# Wide distribution (wd): Euterpe edulis; Caryocar cuneatum
# Narrow distribution (nd: Griffinia colatinensis; Discocactus horstii
# Many records (non-endemic to BR)(mr): Apuleia leiocarpa

df <- df %>%
  mutate(
    cat=if_else(
      spp.nm == "Apuleia_leiocarpa",true="mr" ,false = if_else(
        spp.nm %in% c("Euterpe_edulis","Caryocar_cuneatum"),true="wd",false="nd"
        )
      )
    )
    
   
# Determine all possible levels of the `cat` variable
all_cats <- unique(df$cat)

# Define a common color scale for the `cat` variable
color_scale <- scale_color_manual(values = setNames(
  c("red", "blue", "green"), all_cats
))


# plot as a single pannels

df2 <- df %>%
  group_by(ratio_f,spp.nm) %>%
  slice_sample(n = 100) %>%
  ungroup()

# fix factors

  df2 <- df2%>%
    mutate(
      ratio_f=if_else(
        ratio_f==0.61,0.6,if_else(
          ratio_f==0.76,0.75,if_else(
            ratio_f==0.89,0.9,ratio_f
            )
          )
        )
      )



p <- ggboxplot(df2,x ="ratio_f",y = "AOH.area_1000",ylab = "AOH (1000 ha)",xlab=" sample ratio")+
  geom_jitter(aes(color = cat), width = 0.2, alpha = 0.2) +
  #geom_point(color = "blue", width = 0.2, alpha = 0.5)+
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  facet_grid(spp.nm ~ ., scales = "free_y")


# # unique spps id
# 
# spp <- unique(df$spp.nm)
# # list to keep plots
# 
# plot_lst <- list()
# 
# #subset df to each spp.
# for(i in seq_along(spp)){
#   df_s <- filter(df,spp.nm==spp[i])
#   # for some reason there's 1000 sim for Apuleia
#   if(spp[i]=="Apuleia_leiocarpa"){
#     # Perform stratified sampling
#     df_s <- df_s %>%
#       group_by(ratio_f) %>%
#       slice_sample(n = 100) %>%
#       ungroup()
#     
#   } 
#   else{ 
#     df_s <- df_s
#     }
#   
#   df_s <- df_s[sample(1:nrow(df_s), 100),]
#   p <- ggboxplot(df_s,x ="ratio_f",y = "AOH.area_1000",ylab = "AOH (1000 ha)",xlab=" sample ratio")+
#     geom_jitter(aes(color = cat), width = 0.2, alpha = 0.3) +
#     #geom_point(color = "blue", width = 0.2, alpha = 0.5)+
#     theme_minimal() +
#     theme(axis.text.x = element_text(angle = 45, hjust = 1))+
#     ggtitle(spp[i])+
#     color_scale
#   
#   plot_lst[[i]] <- p
# }
# 
# plot_lst[[1]]
# plot_lst[[2]]
# 
# ggarrange(plotlist = plot_lst)

# ggboxplot(df,x ="ratio_f",y = "AOH.area_1000",ylab = "AOH (1000 ha)",xlab=" sample ratio")+
#   geom_jitter(aes(color = ratio), width = 0.2, alpha = 0.5) +
#     theme_minimal() +
#     theme(axis.text.x = element_text(angle = 45, hjust = 1))+
#   facet_grid(spp.nm ~ ., scales = "free_y")
#   

ggsave(plot = p,filename = "my_figures/boxplot_CNCFlora_pilot_spp.png",width = 10,height = 10,units = "cm")
