# needed libraries
library(tidyverse); library(readr); library(ggpubr); library(ggpattern)

#create data frame from the spreadsheet available on Github
Case_study <- read_csv("C:/Data_Anonymized_Full_Questions.csv")[-c(1),] ### change to file location in your computer


## Figure 3 - Building typologies - Q155
Case_study%>%
    select(Q155)%>% #select the question
    mutate(Q155_original=Q155)%>%
    mutate(Q155=str_replace_all(Q155, "Other", "Uni multiple"))%>%  #group typologies
    mutate(Q155=replace_na(Q155, "Multiple"))%>%
    mutate(Q155=str_replace_all(Q155," \\s*\\([^\\)]+\\)", ""))%>%
    mutate(Q155=str_replace_all(Q155, "General office", "Office"))%>%
    mutate(Q155=str_replace(Q155, "Low-rise apartment", "Residential"))%>%
    mutate(Q155=str_replace(Q155, "Mid- to high-rise apartment", "Residential"))%>%
    mutate(Q155=str_replace(Q155, "Residential,Residential", "Residential"))%>%
    mutate(Q155=str_replace(Q155, "Detached/semi-detached house", "Residential"))%>%
    mutate(Q155=ifelse(Q155=="University or higher education office", "Uni office",
                       ifelse(Q155=="Office,University or higher education office", "Uni office",
                       ifelse(str_detect(Q155,"University or higher education") & str_detect(Q155,"Residential"), "Multiple",
                       ifelse(str_detect(Q155,"University or higher education") & str_detect(Q155,"Office"), "Uni multiple",
                       ifelse(str_detect(Q155,"Assembly"), "Multiple",
                       ifelse(str_detect(Q155,"higher education"), "Uni multiple",
                              Q155)))))))%>%
  count(Q155)%>%
  #graph
  ggplot(aes(y=reorder(Q155,-n), x=n))+geom_bar(stat="identity")+labs(y="",x="")+
  geom_text(aes(label = n), hjust = -0.1)+theme_pubclean(base_family = "sans")


## Figure 4 - Categories of collected information - QID22
Case_study%>%
  select(QID22)%>% #select the question and reorganizing data
  separate(QID22,as.character(c(1:7)),sep=",(?=[A-Z])")%>%
  pivot_longer(1:7,values_to = "category",names_to="whatever")%>%
  filter(category!='NA')%>% #improve categories names for visualization
  mutate(category=ifelse(str_detect(category, "Modes of"), "Occupancy and envr. sensing",
                         ifelse(str_detect(category, "Development of"), "Machine learning",
                                ifelse(str_detect(category, "Data about the occupants "), "Occupant information",
                                       ifelse(str_detect(category, "Data about the building operators"), "Building operators",
                                              ifelse(str_detect(category, "Data about occupant interaction"), "Occupant interation w/ interfaces",
                                                     ifelse(str_detect(category, "Building lighting"), "Lighting automation and/or controls",
                                                            ifelse(str_detect(category, "Building HVAC"), "HVAC automation and/or controls",
                                                                   ifelse(str_detect(category, "An intervention"), "Intervention or pre-post analysis", category)))))))))%>%
  count(category)%>%
  #graph
  ggplot(aes(y=reorder(category,-n), x=n))+geom_bar(stat="identity")+labs(y="",x="")+
  geom_text(aes(label = n), hjust = -0.1)+theme_pubclean(base_family = "sans")

## Figure5 - Categories of information by building typology - Q155 vs QID22
Case_study%>%
  select(Q155,QID22)%>% #select the question and reorganizing data
  separate(QID22,as.character(c(1:7)),sep=",(?=[A-Z])")%>%  
  pivot_longer(2:8,values_to = "category",names_to="whatever")%>% 
  filter(category!='NA')%>%
  mutate(cat_n=as.numeric(factor(category)))%>% #group typologies
  mutate(Q155=str_replace_all(Q155, "Other", "Uni multiple"))%>%
  mutate(Q155=replace_na(Q155, "Multiple"))%>%
  mutate(Q155=str_replace_all(Q155," \\s*\\([^\\)]+\\)", ""))%>%
  mutate(Q155=str_replace_all(Q155, "General office", "Office"))%>%
  mutate(Q155=str_replace(Q155, "Low-rise apartment", "Residential"))%>%
  mutate(Q155=str_replace(Q155, "Mid- to high-rise apartment", "Residential"))%>%
  mutate(Q155=str_replace(Q155, "Residential,Residential", "Residential"))%>%
  mutate(Q155=str_replace(Q155, "Detached/semi-detached house", "Residential"))%>%
  mutate(Q155=ifelse(Q155=="University or higher education office", "Uni office",
                     ifelse(Q155=="Office,University or higher education office", "Uni office",
                            ifelse(str_detect(Q155,"University or higher education") & str_detect(Q155,"Residential"), "Multiple",
                                   ifelse(str_detect(Q155,"University or higher education") & str_detect(Q155,"Office"), "Multiple",
                                          ifelse(str_detect(Q155,"Assembly"), "Multiple",
                                                 ifelse(str_detect(Q155,"higher education"), "Uni multiple",
                                                        Q155)))))))%>%
  mutate(typ_n=as.numeric(factor(Q155)))%>% #improve categories names for visualization
  mutate(category=ifelse(str_detect(category, "Modes of"), "Occupancy and envr. sensing", 
                         ifelse(str_detect(category, "Development of"), "Machine learning",
                                ifelse(str_detect(category, "Data about the occupants "), "Occupant information",
                                       ifelse(str_detect(category, "Data about the building operators"), "Building operators",
                                              ifelse(str_detect(category, "Data about occupant interaction"), "Occupant interaction w/ interfaces", 
                                                     ifelse(str_detect(category, "Building lighting"), "Lighting automation and/or controls",
                                                            ifelse(str_detect(category, "Building HVAC"), "HVAC automation and/or controls",
                                                                   ifelse(str_detect(category, "An intervention"), "Intervention or pre-post analysis", category)))))))))%>%
  mutate(cat_n=recode(cat_n,"6"=1,"8"=2,"4"=3,"2"=4,"3"=5,"7"=6,"5"=7,"1"=8))%>% #reorder for visualization
  mutate(typ_n=recode(typ_n,"3"=1,"4"=2,"5"=3,"1"=4,"6"=5,"7"=6,"2"=7))%>%
  #graph
  ggplot(aes(reorder(Q155,typ_n),reorder(category,-cat_n)))+geom_count()+labs(x="", y="", size="Frequency")+
  theme_pubclean(base_family = "sans")+scale_size_continuous(breaks = c(seq(3,13,by=3)))+
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5),legend.key = element_rect(color=NA,fill =NA),
        legend.justification = "left", legend.title = element_text(size=10))

## Figure 6 - HVAC system type vs age - Q158 vs Q153
Case_study%>%
  select(Q153,Q158,Q158_13_TEXT)%>% #select the question and re-coding to include "other" category when applicable
  mutate(Q158_13_TEXT=ifelse(str_detect(Q158_13_TEXT,"RTU"),"Rooftop Unit",
                             ifelse(str_detect(Q158_13_TEXT,"stand-alone gas"),"Unitary gas heater and split",
                                    ifelse(str_detect(Q158_13_TEXT,"DOAS, Radiant"), "VRF,DOAS with VRF",
                                           ifelse(str_detect(Q158_13_TEXT,"distric heating"), "Distric heating",
                                                  ifelse(str_detect(Q158_13_TEXT,"controlled ventilation"), NA, 
                                                         ifelse(str_detect(Q158_13_TEXT,"Single Duct"), NA,
                                                                ifelse(str_detect(Q158_13_TEXT,"Additional cooling"), NA,
                                                                       ifelse(str_detect(Q158_13_TEXT,"Water-based"), NA,     
                                                                              Q158_13_TEXT)))))))))%>%
  mutate(Q158=ifelse(!is.na(Q158_13_TEXT),str_replace(Q158,"Other \\(please describe\\)",Q158_13_TEXT),str_replace(Q158,",Other \\(please describe\\)","")))%>%
  mutate(Q158=ifelse(str_detect(Q158,"Other \\(please describe\\)"),NA,Q158))%>%
  select(-Q158_13_TEXT)%>%
  filter(Q158!='NA', Q153!='NA')%>%
  separate_rows(1,sep=",")%>% #reorganizing data
  separate_rows(2,sep=",")%>%
  rename(HVAC_type=Q158,age=Q153)%>% #renaming categories to improve comprehention/visualization
  mutate(HVAC_type=ifelse(str_detect(HVAC_type,"VAV AHU system without"),"AHU VAV without reheat",
                          ifelse(str_detect(HVAC_type,"VAV AHU system with "),"AHU VAV with reheat",  
                                 ifelse(str_detect(HVAC_type,"CAV system"),"AHU CAV",
                                        ifelse(str_detect(HVAC_type,"DOAS with VRF serving"),"DOAS with VRF",
                                               ifelse(str_detect(HVAC_type,"Concrete core tempering/component activation"),"Concrete core tempering",
                                                      ifelse(str_detect(HVAC_type,"DOAS with fan c"),"AHU with DOAS",               
                                                             HVAC_type)))))))%>%
  count(HVAC_type,age)%>%
  left_join(Case_study%>% #count total responses per system to order graph
              select(Q153,Q158,Q158_13_TEXT)%>%
              mutate(Q158_13_TEXT=ifelse(str_detect(Q158_13_TEXT,"RTU"),"Rooftop Unit",
                                         ifelse(str_detect(Q158_13_TEXT,"stand-alone gas"),"Unitary gas heater and split",
                                                ifelse(str_detect(Q158_13_TEXT,"DOAS, Radiant"), "VRF,DOAS with VRF",
                                                       ifelse(str_detect(Q158_13_TEXT,"distric heating"), "Distric heating",
                                                              ifelse(str_detect(Q158_13_TEXT,"controlled ventilation"), NA, 
                                                                     ifelse(str_detect(Q158_13_TEXT,"Single Duct"), NA,
                                                                            ifelse(str_detect(Q158_13_TEXT,"Additional cooling"), NA,
                                                                                   ifelse(str_detect(Q158_13_TEXT,"Water-based"), NA,     
                                                                                          Q158_13_TEXT)))))))))%>%
              mutate(Q158=ifelse(!is.na(Q158_13_TEXT),str_replace(Q158,"Other \\(please describe\\)",Q158_13_TEXT),str_replace(Q158,",Other \\(please describe\\)","")))%>%
              mutate(Q158=ifelse(str_detect(Q158,"Other \\(please describe\\)"),NA,Q158))%>%
              select(-Q158_13_TEXT)%>%
              filter(Q158!='NA', Q153!='NA')%>%
              separate_rows(1,sep=",")%>%
              separate_rows(2,sep=",")%>%
              rename(HVAC_type=Q158,age=Q153)%>%
              mutate(HVAC_type=ifelse(str_detect(HVAC_type,"VAV AHU system without"),"AHU VAV without reheat",
                                      ifelse(str_detect(HVAC_type,"VAV AHU system with "),"AHU VAV with reheat",  
                                             ifelse(str_detect(HVAC_type,"CAV system"),"AHU CAV",
                                                    ifelse(str_detect(HVAC_type,"DOAS with VRF serving"),"DOAS with VRF",
                                                           ifelse(str_detect(HVAC_type,"Concrete core tempering/component activation"),"Concrete core tempering",
                                                                  ifelse(str_detect(HVAC_type,"DOAS with fan c"),"AHU with DOAS",               
                                                                         HVAC_type)))))))%>%
              count(HVAC_type)%>%
              rename(ordem=n))%>%
  #rename age ranges
  mutate(age=ifelse(str_detect(age,"51-100"), ">50",
                    ifelse(str_detect(age,"Less than"), "<10",
                           ifelse(str_detect(age,"11 to 25"), "11-25",
                                  ifelse(str_detect(age,"26 to 50"), "26-50",age)))))%>%
  mutate(cor=ifelse(age=="26-50","black","white"))%>%
  #graph
  ggplot(aes(y=reorder(HVAC_type,ordem), x=n,fill=age))+geom_bar(stat="identity")+
  labs(y="",x="")+theme_pubclean(base_family = "sans")+scale_fill_grey("Building age (years)",
                                                                       breaks = c("<10","11-25","26-50",">50"),
                                                                       limits = c("<10","11-25","26-50",">50"))+
  geom_text(aes(label=n,col=age),position = position_stack(vjust = 0.5))+scale_x_continuous(breaks = seq(0,10,by=2))+
  theme(legend.justification = "left",legend.title = element_text(size=10))+guides(color="none")+scale_color_manual(values = c("white","black","white","black"))

## Figure 7 - Data collected, and method used to detect occupants - Q21
Case_study%>%
  select(Q21_1,Q21_2,Q21_3,Q21_4,Q21_5,Q21_6)%>% #select the question and rename categories
  rename("Presence building/system level"="Q21_1",
         "Presence zone/room level"= "Q21_2",
         "People count building/system level"= "Q21_3",
         "People count zone/room level"= "Q21_4",
         "Occupant activity building/system level" =  "Q21_5",
         "Occupant activity zone/room level" =  "Q21_6")%>%
  pivot_longer(1:6,values_to = "sensor",names_to="fun")%>% #reorganizing data
  separate_rows(2,sep=",")%>%
  filter(sensor!='NA',sensor!="Not collected")%>%
  #graph
  ggplot(aes(sensor,fun))+geom_count()+labs(x="", y="")+
  theme_pubclean(base_family = "sans")+scale_size_continuous("Frequency",breaks = c(seq(1,15,by=4)))+
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5),
        legend.key = element_rect(color=NA,fill =NA), legend.title = element_text(size=10))

## Figure 8 - Controllable systems and interfaces, and the modes of control - Q105
Case_study%>%
  select(Q105_1,Q105_2,Q105_3,Q105_4,Q105_5)%>% #select the question and rename categories
  rename("Manual control"=Q105_1, "Automated control"=Q105_2, "Individual remote control"=Q105_3,
         "Local control"=Q105_4, "Supervisory control"=Q105_5)%>%
  mutate(num=row_number())%>% #count and reorganizing data
  pivot_longer(1:5,names_to = "control", values_to = "system",values_drop_na = TRUE)%>%
  mutate(num2=as.numeric(factor(num)))%>%
  separate_rows(system,sep=",")%>%
  count(system,control)%>%
  left_join( #count total responses per system option
    Case_study%>%
      select(Q105_1,Q105_2,Q105_3,Q105_4,Q105_5)%>%
      rename("Manual control"=Q105_1, "Automated control"=Q105_2, "Individual remote control"=Q105_3,
             "Local control"=Q105_4, "Supervisory control"=Q105_5)%>%
      pivot_longer(1:5,names_to = "control", values_to = "system",values_drop_na = TRUE)%>%
      separate_rows(system,sep=",")%>%
      count(system)%>%
      rename(total=n))%>%
  mutate(lab=n/total*100)%>%
  filter(system!="Other")%>% #improving writing for visualization
  mutate(system=str_replace(system,"Adjustable",""),
         system=str_replace(system,"internal","Internal"),
         system=str_replace(system,"external","External"),
         system=str_replace(system,"Operable window","Window"))%>%
  mutate(cor=as.numeric(factor(control)))%>% #reordering to improve visualization
  mutate(cor=as.numeric(recode(cor, "1"=1,"2"=4,"5"=2,"3"=3,"4"=5)))%>%
  mutate(ordem=as.numeric(factor(system)),
         ordem=recode(ordem,"1"=3,"2"=1,"5"=7,"3"=6,"4"=5,"6"=4,"8"=2,"7"=8))%>%
  #graph
  ggplot(aes(y=reorder(system,ordem), x=lab,fill=reorder(control,cor)))+geom_bar(stat= "identity")+
  labs(y="",x="")+theme_pubclean(base_family = "sans")+scale_fill_grey("")+
  geom_text(aes(label=n, col=as.factor(cor)),position = position_stack(vjust = 0.5))+
  theme(legend.justification = "right",plot.margin=grid::unit(c(0,0,0,0), "mm"))+#guides(fill = guide_legend(nrow = 2))+
  scale_x_continuous(labels =scales::label_number(suffix = "%"))+
  scale_color_manual(values = c("white","white","black","black","black"))+guides(col="none")

## Figure 9 - Occupant interactions with interfaces - Q103
Case_study%>%
  select(Q103)%>% #select question and reorganing data
  filter(!is.na(.))%>%
  mutate(NUM=row_number())%>%
  separate_rows(Q103,sep=",")%>%
  rename(control=Q103)%>%
  count(control)%>%
  #graph
  ggplot(aes(y=reorder(control,-n), x=n))+geom_bar(stat="identity")+labs(y="",x="")+
  geom_text(aes(label = n), hjust = -0.1)+theme_pubclean(base_family = "sans")

## Figure 10 - Type of data and methods used to collect information on behavior and motivations - Q238_
Case_study%>%
  select(Q238_2,Q238_3,Q238_4,Q238_5,Q238_7,Q238_8)%>% #select categories with answers and rename options
  rename("Interview"=Q238_2,"Survey"=Q238_3,"Smart Phone"=Q238_4,"Smart Watch"=Q238_5,"Observation"=Q238_7,"Other"=Q238_8)%>%
  pivot_longer(1:6,names_to = "method", values_to = "variable",values_drop_na = TRUE)%>% #reorganize data
  separate_rows(variable,sep=",")%>%
  count(variable, method)%>%
  left_join(
    Case_study%>% #count total per variable
      select(Q238_2,Q238_3,Q238_4,Q238_5,Q238_7,Q238_8)%>%
      rename("Interview"=Q238_2,"Survey"=Q238_3,"Smart Phone"=Q238_4,"Smart Watch"=Q238_5,"Observation"=Q238_7,"Other"=Q238_8)%>%
      pivot_longer(1:6,names_to = "method", values_to = "variable",values_drop_na = TRUE)%>%
      separate_rows(variable,sep=",")%>%
      count(variable)%>%
      rename(total=n))%>%
  mutate(lab=n/total*100)%>%
  filter(variable!="Others")%>%
  #graph
  ggplot(aes(y=variable, x=lab,fill=method))+geom_bar(stat= "identity")+
  labs(y="",x="")+theme_pubclean(base_family = "sans")+scale_fill_grey("")+
  geom_text(aes(label=n, col=method),position = position_stack(vjust = 0.5))+
  theme(legend.justification = "center",plot.margin=grid::unit(c(0,0,0,0), "mm"))+
  scale_x_continuous(labels =scales::label_number(suffix = "%"))+
  scale_color_manual(values = c("white","white","white","black","black","black"))+guides(col="none")

## Figure 11 - Controlled system/components in intervention studies - Q111 & Q77
Case_study%>%
  select(Q111_1.1,Q77_1)%>% #select questions
  mutate(Q77=str_replace_all(Q77_1, "Cooling,Ventilation", "Cooling and Ventilation"))%>% #grouping cooling and ventilation as one category
  mutate(Q77=ifelse(str_detect(Q77, "Cooling") & !str_detect(Q77, "Ventilation"),"Cooling and Ventilation",Q77))%>%
  mutate(Q77=ifelse(str_detect(Q77, "Ventilation") & !str_detect(Q77, "Cooling"),"Cooling and Ventilation",Q77))%>%
  replace(is.na(.), "none")%>%
  mutate(total=ifelse(Q111_1.1!= "none", Q111_1.1, Q77))%>% #merging responses
  select(total)%>%
  filter(total!="none")%>%
  separate_rows(total, sep = ",")%>%
  count(total)%>%
  #graph
  ggplot(aes(y=reorder(total,-n), x=n))+geom_bar(stat="identity")+labs(y="",x="")+
  geom_text(aes(label = n), hjust = -0.1)+theme_pubclean(base_family = "sans")

# Figure 12 - Occupant-center strategy and method in intervention - Q62
Case_study%>%
  select(Q62_1,Q62_2,Q62_3,Q62_4)%>% #select questions and rename options
  rename("Sensor data for responsive/adaptive control"=Q62_1,
         "Occupant modelling for responsive/adaptive control"=Q62_2,
         "Occupant modelling for anticipatory/predictive control"=Q62_3,
         "Occupant feedback incorporated to controls"=Q62_4)%>%
  pivot_longer(1:4, names_to = "what", values_to = "method")%>% #reorganize data
  filter(method!='NA')%>%
  separate_rows(method,sep=",")%>%
  filter(method!="Other")%>%
  #rename methods for better visualization
  mutate(method=ifelse(str_detect(method, "interaction"),"Activity/Interaction with systems",
                       ifelse(str_detect(method, "operator"),"Manual adjust by operator",
                              ifelse(str_detect(method, "Machine"),"Machine/Deep Learning",
                                     ifelse(str_detect(method, "Presence"),"Occupant presence",
                                            ifelse(str_detect(method, "Count") ,"Occupant count",
                                                   method))))))%>%
  #graph
  ggplot(aes(method,what))+geom_count()+labs(x="", y="", size="Frequency")+
  theme_pubclean(base_family = "sans")+scale_size_continuous(breaks = c(seq(1,10,by=4)))+
  theme(axis.text.x = element_text(angle=90, hjust=1, vjust=0.5),legend.key = element_rect(color=NA,fill =NA),
        legend.justification = "center", legend.title = element_text(size=10))
