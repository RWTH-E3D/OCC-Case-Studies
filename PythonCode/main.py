import pandas as pd

import Plot_Results as pr
from Survey_questions import full_questions

from Shortened_Answers_Titles import short_replies as short_replies
from Shortened_Answers_Titles import short_titles as short_titles

# Import data as a pandas DataFrame
df_data = pd.read_csv("Data_Anonymized_Full_Questions.csv")
# The first row contains full questions to the questions. In this code, we're only going to use their question number,
# therefore, we remove the first line from the DataFrame
df_data = df_data.loc[1:]

# Print out number of studies in your data
print(f"Number of studies in total: {len(df_data)}")

# Reformat questions with multiple answers to python Lists, to make them easier to use in the rest of our code
df_data = pr.reformat_dataframe(df_data, columns=full_questions)

"""
The following code is an example which you can modify according to your research questions.
The example filters for all buildings that were categorized as "Uni-Office" and then plots which categories of analysis
(QID22) were resent among those buildings.
"""

# Filter the dataframe according to specific rules. Refer to the description of the filter_df_by_tags method for an
# explanation of how to set up your own filters.
# Refer to "Filters.py" for some example filters that were used for the publication
# Example: Filter for all case studies that were categorized as "Uni-Office"
df_data = pr.filter_df_by_tags(df_data, must_tags=["University or higher education office"],
                          must_not_tags=['University or higher education laboratory',
                                         'University or higher education classroom', 'Other',
                                         'Low-rise apartment (less than four floors)',
                                         'Mid- to high-rise apartment (more than five floors)'],
                          filter_column="Q155")

print(f"Number of studies after filtering: {len(df_data)}")

question = "QID22"  # Change this to the question number you want to plot (refer to Survey_questions.py or the csv file
                    # for the full questions texts)

# Get either the shortened or the full question text for our diagram
if question in short_titles:
    title = short_titles[question]
else:
    title = full_questions[question]

# Some answers are too long to be properly displayed in our plots. Use and edit the short_replies dictionary found in
# "shortened_Answers_Titles.py" to shorten these answers
if question in short_replies:
    short_answers = short_replies
    print("Shortened answers to:")
    for key, value in short_replies[question].items():
        print(f"{key} : {value}")
else:
    short_answers = []

pr.plot_barchart(df_data, question, title, short_answers=short_replies, export=False, horizontal=True)