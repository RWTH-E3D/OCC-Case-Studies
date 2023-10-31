import pandas as pd
from matplotlib import pyplot as plt
import numpy as np
import re
from matplotlib import rcParams
rcParams.update({'figure.autolayout': True})

import seaborn as sns
sns.set_theme(style='darkgrid', rc={'figure.dpi': 147},
              font_scale=0.7)
#plt.rcParams["figure.autolayout"] = True


def filter_df_by_tags(df, filter_column, must_tags=[], must_not_tags=[], one_of_tags=[], max_answers=None,
                      reverse=False):
    """
    This function allows you to filter the data according to your research questions.
    :param df: pandas.Dataframe - Dataframe containing your data
    :param filter_column: string - Name of the column to filter by
    :param must_tags: List<string> - Answers must contain all of these to count
    :param must_not_tags: List<string> - Answers must not contain any of these to count
    :param one_of_tags: - List<string> - Answers must contain at least one of these to count
    :param max_answers: Integer - Maximum amount of answers given to this question. Use this to filter for answered that solely gave a certain response.
    :param reverse: boolean - Reverse the given filter
    :return: pandas.Dataframe
    """
    def check_filter_tags(row_tags):
        if not isinstance(row_tags, list):
            try:
                row_tags = row_tags.split(";")  # Untagged rows are NaN
            except:
                return False  # Sort out untagged rows
        for tag in must_tags:
            if tag not in row_tags:
                return False
        for tag in must_not_tags:
            if tag in row_tags:
                return False
        if len(one_of_tags) > 0:
            for tag in row_tags:
                if tag in one_of_tags:
                    return True
            return False
        if max_answers:
            if len(row_tags) > max_answers:
                return False
        return True

    if not reverse:
        filtered_df = df[df[filter_column].apply(check_filter_tags)]
    else:
        filtered_df = df[df[filter_column].apply(lambda x: not check_filter_tags(x))]

    return filtered_df


def reformat_list_replies(df, column):
    """
    Reformat replies that checked multiple answers for a certain column into a List.
    :param df: pandas.Dataframe
    :param column: string
    :return: pandas.Dataframe
    """
    def reformat(reply):
        if pd.isna(reply):
            return reply
        # Convert commas that are within a reply to semicolons and split by commas
        reply = re.sub('(?<=\d),(?=\d)', '---', reply)
        reply = reply.replace(", ", ";")
        reply = reply.split(",")
        # Convert back to commas within our new list for better readablity later on
        reply = [x.replace(";", ", ") for x in reply]
        reply = [x.replace("---", ",") for x in reply]
        return reply
    df[column] = df[column].apply(reformat)
    return df


def reformat_dataframe(df, columns):
    """
    Reformat multiple columns using reformat_list_replies
    :param df: pandas.Dataframe
    :param columns:
    :return:
    """
    for column in columns:
        if column in df:
            df = reformat_list_replies(df, column)
    return df


def get_shortened_reply_list(reply_list, short_answers):
    """
    Convert replies in to a shortened version.
    :param reply_list:
    :param short_answers:
    :return:
    """
    shortened_list = []
    for reply in reply_list:
        if reply in short_answers:
            shortened_list.append(short_answers[reply])
        else:
            shortened_list.append(reply)
    return shortened_list


def enter_replies_to_dict(dict, reply_list, consider_nan):
    """
    Enter replies to counting dictionary that counts how often each reply appears.
    :param dict:
    :param reply_list:
    :param consider_nan:
    :return:
    """
    # Make sure this works both with lists and single Strings
    if not isinstance(reply_list, list):
        reply_list = [reply_list]
    for reply in reply_list:
        if pd.isna(reply) and not consider_nan:
            continue
        elif reply not in dict:
            dict[reply] = 1
        else:
            dict[reply] += 1


def plot_barchart(df, question, title, short_answers, export=False, horizontal=True):
    """
    Plot a barchart for a question.
    :param df: pandas.Dataframe - Your data
    :param question: String - Question you want to plot
    :param title: String - Title of your plot, usually the full or shortened question text
    :param short_answers: Dict<string;Dict<string;string>: A dictionary containing the shortened answers to some questions (makes it easier to display)
    :param export: boolean - Specify whether your plot should be displayed or exported as a png (Format can be changed). Uses the title as filename
    :param horizontal: boolean - Specify whether your barchart should have horizontal or vertical bars.
    :return: None
    """
    fig, ax = plt.subplots(1, 1)
    y_pos = {}

    print(f"Question {question}: {title}: {len(df[question].dropna())} Replies")

    count_dict = {}

    df[question].apply(lambda x: enter_replies_to_dict(count_dict, x, consider_nan=False))

    print(count_dict)

    if question in short_answers:
        tick_labels = get_shortened_reply_list(sorted(list(count_dict.keys()), key=(lambda x: count_dict[x]),
                                 reverse=True), short_answers[question])
    else:
        tick_labels = sorted(list(count_dict.keys()), key=(lambda x: count_dict[x]),
                                      reverse=True)

    y_pos[question] = np.arange(0, len(count_dict))
    if horizontal:
        ax.barh(y_pos[question], sorted(count_dict.values(), reverse=True),
                 tick_label=tick_labels)
    else:
        ax.bar(y_pos[question], sorted(count_dict.values(), reverse=True),
                tick_label=tick_labels)
    ax.set_title(title)

    if not export:
        plt.show()
    if export:
        plt.savefig(f"Plots/{question}.png", format="png")