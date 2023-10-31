# Non Uni office n=10
df = pr.filter_df_by_tags(df_data, must_tags=["General office"], must_not_tags=["University or higher education laboratory", "University or higher education classroom",
                                                                           'Other', 'University or higher education office', 'Low-rise apartment (less than four floors)'], filter_column="Q155")

# Uni office n=18
df = pr.filter_df_by_tags(df_data, must_tags=["University or higher education office"], must_not_tags=['University or higher education laboratory', 'University or higher education classroom', 'Other', 'Low-rise apartment (less than four floors)', 'Mid- to high-rise apartment (more than five floors)'], filter_column="Q155")

# Uni multiple n=13
df = pr.filter_df_by_tags(df_data, one_of_tags=['University or higher education laboratory', 'University or higher education classroom', 'Other'], must_not_tags=['Low-rise apartment (less than four floors)', 'Mid- to high-rise apartment (more than five floors)'], filter_column="Q155")

# School n = 4
df = pr.filter_df_by_tags(df_data, must_tags=["School (Primary/secondary/high school)"], filter_column="Q155")

# Residential n = 10
df = pr.filter_df_by_tags(df_data, one_of_tags=['Mid- to high-rise apartment (more than five floors)', 'Low-rise apartment (less than four floors)', 'Detached/semi-detached house'], must_not_tags=['General office', 'University or higher education office', 'University or higher education classroom', 'University or higher education laboratory'], filter_column="Q155")

# Multiple: All other n = 2 (reverse everything above)

# Interventions n=30
df = pr.filter_df_by_tags(df_data, must_tags=["An intervention or experiment that was designed to improve building performance or occupant satisfaction"], filter_column="QID22")

# HVAC n= 31
df = pr.filter_df_by_tags(df_data, must_tags=["Building HVAC and automation and/or controls information"], filter_column="QID22")

# VAV AHU
df = pr.filter_df_by_tags(df_data, one_of_tags=['VAV AHU system with zone reheat and other perimeter heating', 'VAV AHU system without zone reheat or perimeter heating'], filter_column="Q158")

# Intervention ML n=13
df = pr.filter_df_by_tags(df_data, one_of_tags=["An intervention or experiment that was designed to improve building performance or occupant satisfaction"], filter_column="QID22")
print(f"Number of studies in total: {len(df)}")
df = pr.filter_df_by_tags(df_data, must_tags=["Development of machine learning models to predict human behavior, preference, or satisfaction"], filter_column="QID22")
print(f"Number of studies in total: {len(df)}")



