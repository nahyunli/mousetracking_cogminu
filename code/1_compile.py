# -*- coding: utf-8 -*-
"""
Created on Fri Feb 19 09:00:38 2021

@author: cogmi
"""

import sys
sys.path.append(r'C:\Users\Minu Kim\Documents\GitHub')
import os
from os import sep
import pandas as pd
import numpy as np
import minu_modules as mm
import matplotlib.pyplot as plt
import seaborn as sns
import math
import ast

mm.pd_print_all()


"""========mode =========="""
mode = "compile"  # compile, bin, organize
type = "word"  # 'location', 'arrow', 'word'
root = "C:/Users/Minu Kim/Documents/GitHub/mouse_tracking/nahyun_project/"

dv = "rt"

if mode == "compile":
    if type == "arrow":
        data = mm.csv_compiler(root + "raw_arrow/")
    if type == "word":
        data = mm.csv_compiler(root + "raw_word/")
    if type == "location":
        data = mm.csv_compiler(root + "raw_location/")

    data = data.loc[:, ("subject_nr", "taskType", "tar1L", "tar2R", "tar3U", "tar4D", "correct_button_get_response_pos",
                        "response_time_get_response_bef", "response_time_get_response_pos", "response_time_get_start_click",
                        "n0", "n1", "n2", "n1n0", "n2n0", "correct_resp", "correct",
                        "response_time", "block", "xpos_get_response_bef", "xpos_get_response_pos", "ypos_get_response_pos",
                        "ypos_get_response_bef", "timestamps_get_response_bef", "timestamps_get_response_pos")]

    data = data.rename(index=str, columns={"subject_nr": "id", "correct_resp": "color", "correct": "acc",
                                           "response_time": "rt",  "n1n0": "btwC",
                                           "n2n0": "withC",
                                           "xpos_get_response_bef": "x_coords_b",
                                           "xpos_get_response_pos": "x_coords_p",
                                           "ypos_get_response_bef": "y_coords_b",
                                           "ypos_get_response_pos": "y_coords_p",
                                           "timestamps_get_response_bef": "times_b",
                                           "timestamps_get_response_pos": "times_p"})
    #remove practice data

    data = data[(data['block'] != "prac")]
    print("removing practice trials")
    data=data.reset_index()

    data["rt"] = data.rt + 250
    data_index = data.index.values.tolist()

    for i, j in enumerate(data_index):
        if (data.at[j, "acc"] == 'undefined'):
            data.at[j, "rt"] = -1

    # outlier removal
    indiv_conditions = ["id"]
    mean_groups = mm.sd_detector(data, indiv_conditions, 'rt', thresh=2.5, verbose=False)
    before, after = mm.remove_outlier_sd(mean_groups, data, indiv_conditions, 'rt', 'twotail')
    # print(len(data), 'after removal')
    # print('removing ' + str(len(before)-len(after)) + " trials")

    # use 'before' the dataset only 'marked' for removal. After contains the removed dataframe.
    before = before.reset_index()
    data_index = before.index.values.tolist()
    previous_index = 0
    current_index = 0
    next_index = 0
    remove_list = []
    data = before.copy()

    # remove rows after outlier and incorrect data
    for i, j in enumerate(data_index):
        if (data.at[j, "trim"] == "bad") or (data.at[j, "acc"] in [0, '0', 'undefined']):
            remove_list.append(j+1)
    data = data.drop(remove_list, axis=0)
    a = len(before)
    b = len(data)
    print(a-b, "removed : trial after outlier and incorrect data")

    # remove inaccurate data
    a = len(data)
    data = data[(data['acc'] == '1') | (data['acc'] == 1)]
    b = len(data)
    print(a-b, "removed : inaccurate data")

    # remove first two trials in blocks
    a = len(data)
    data = data[(data['n2'] != 0)]
    b = len(data)
    print(a-b, "removed : first two trials")

    # remove outlier data
    a = len(data)
    data = data[(data['trim'] != 'bad')]
    b = len(data)
    print(a-b, "removed : outliers")


    data["x_coords"] = ""
    data["y_coords"] = ""
    data["times"] = ""
    data["targ_loc"] = ""

    data = data.reset_index(drop=True)
    print("Calibrating trajectory and time data")
    for i in range(0, len(data)):
        #print(i)
        # print(i)
        data.at[i, "times_b"] = ast.literal_eval(data["times_b"][i])
        data.at[i, "times_p"] = ast.literal_eval(data["times_p"][i])
        data.at[i, "x_coords_b"] = ast.literal_eval(data["x_coords_b"][i])
        data.at[i, "y_coords_b"] = ast.literal_eval(data["y_coords_b"][i])
        data.at[i, "x_coords_p"] = ast.literal_eval(data["x_coords_p"][i])
        data.at[i, "y_coords_p"] = ast.literal_eval(data["y_coords_p"][i])

        data.at[i, "times"] = data.at[i, "times_b"] + data.at[i, "times_p"]
        temporary_array = data.at[i, "times"]
        subtract_this = data.at[i, "times"][0]

        data.at[i, "times"] = np.array(temporary_array, dtype=int) - subtract_this
        data.at[i, "times"] = data.at[i, "times"].tolist()
        data.at[i, "x_coords"] = data.at[i,"x_coords_b"] + data.at[i, "x_coords_p"]
        data.at[i, "y_coords"] = data.at[i,"y_coords_b"] + data.at[i, "y_coords_p"]

        if data.at[i, "color"] == 'red':
            data.at[i, "targ_loc"] = 1
        elif data.at[i, "color"] == 'green':
            data.at[i, "targ_loc"] = 2
        elif data.at[i, "color"] == 'blue':
            data.at[i, "targ_loc"] = 3
        elif data.at[i, "color"] == 'yellow':
            data.at[i, "targ_loc"] = 4

    del data["x_coords_b"], data["x_coords_p"], data["y_coords_b"], data["y_coords_p"], data["times_b"], data["times_p"]

    # sorting trials / this is for the binning later
    data.sort_values(by=["rt"])
    data.sort_values(by=["id"])

    if type == "location":
        data.to_excel(root+"/raw_compiled_location.xlsx", index=False)
        print('saving raw_compiled_location at ' + root)
    if type == "arrow":
        data.to_excel(root+"/raw_compiled_arrow.xlsx", index=False)
        print('saving raw_compiled_arrow at ' + root)
    if type == "word":
        data.to_excel(root+"/raw_compiled_word.xlsx", index=False)
        print('saving raw_compiled_word at ' + root)

    print("File Compilation Complete")

if mode == "bin":
    if type == "location":
        filename = root+"raw_compiled_location.xlsx"
    if type == "word":
        filename = root+"raw_compiled_word.xlsx"
    if type == "arrow":
        filename = root + "raw_compiled_arrow.xlsx"

    data = pd.read_excel(filename, header=0)
    bad_subjects = []
    cut_labels=[1, 2, 3, 4]

    data.sort_values(by=["id"])
    subs = data.id.unique()
    subs=subs.tolist()

    for i in range(0, len(subs)):

        id_num = i+1
        print("processing #",id_num)

        bin_grouping = []
        if id_num in bad_subjects:
            pass
        else:
            temp_df_1 = data[(data["id"] == id_num) & (data["taskType"] == 1) & (data["n0"] == 1)].copy()

            temp_df_1["bin"] = pd.qcut(temp_df_1.rt, 4, labels = cut_labels)

            temp_df_2 = data[(data["id"] == id_num) & (data["taskType"] == 2) & (data["n0"] == 1)].copy()
            temp_df_2["bin"] = pd.qcut(temp_df_2.rt, 4, labels = cut_labels)

            temp_df_3 = data[(data["id"] == id_num) & (data["taskType"] == 1) & (data["n0"] == 2)].copy()
            temp_df_3["bin"] = pd.qcut(temp_df_3.rt, 4, labels = cut_labels)

            temp_df_4 = data[(data["id"] == id_num) & (data["taskType"] == 2) & (data["n0"] == 2)].copy()
            temp_df_4["bin"] = pd.qcut(temp_df_4.rt, 4, labels = cut_labels)

            temp_combined = pd.concat([temp_df_1, temp_df_2, temp_df_3, temp_df_4], axis=0)

            if i == 0:
                new_data = temp_combined
            elif i > 0:
                new_data = pd.concat([new_data, temp_combined])


    new_data["flip"] = ""
    for i in range(0, len(new_data)):
        if new_data.at[i, "color"] == 'red' and new_data.at[i,"n0"] == 1: #left, congruent
            new_data.at[i, "flip"] = 1
        elif new_data.at[i, "color"] == 'red' and new_data.at[i, "n0"] == 2: # left, incongruent
            new_data.at[i, "flip"] = 2
        elif new_data.at[i, "color"] == 'blue' and new_data.at[i,"n0"] == 1: #up, congruent
            new_data.at[i, "flip"] = 3
        elif new_data.at[i, "color"] == 'blue' and new_data.at[i, "n0"] == 2: # up, incongruent
            new_data.at[i, "flip"] = 4
        elif new_data.at[i, "color"] == 'green' and new_data.at[i,"n0"] == 1: #right, congruent
            new_data.at[i, "flip"] = 5
        elif new_data.at[i, "color"] == 'green' and new_data.at[i, "n0"] == 2: # right, incongruent
            new_data.at[i, "flip"] = 6
        elif new_data.at[i, "color"] == 'yellow' and new_data.at[i,"n0"] == 1: #down, congruent
            new_data.at[i, "flip"] = 7
        elif new_data.at[i, "color"] == 'yellow' and new_data.at[i, "n0"] == 2: # down, incongruent
            new_data.at[i, "flip"] = 8


    rtsss = new_data.groupby(["id", "taskType", "n0", "bin"])["rt"].mean()
    rtssss = (new_data.groupby(["id", "taskType", "n0", "bin"]).mean()).groupby(["taskType", "n0", "bin"])["rt"].mean()
    rtsssss = (new_data.groupby(["id", "taskType", "n0", "bin"]).mean()).groupby(["taskType", "n0", "bin"])["rt"].sem()
    rtsss = rtsss.to_frame()
    rtsss = rtsss.reset_index()

    rtsss_cong = rtsss[rtsss["n0"] == 1]
    rtsss_cong = rtsss_cong.reset_index()

    rtsss_incong = rtsss[rtsss["n0"] == 2]
    rtsss_incong = rtsss_incong.reset_index()

    ddd = rtsss_incong["rt"].copy() - rtsss_cong["rt"].copy()

    rtsss_cong["incong"] = rtsss_incong["rt"]
    # rtsss_incongs = pd.concat([rtsss_incong, rtsss_cong["rt"], ddd])
    rtsss_cong['difference'] = ddd

    diff_sem = rtsss_cong.groupby(["taskType", "n0", "bin"])["rt"].sem()

    # print(rtsssss)

    if type == "location":
        new_data.to_excel(root + "/bin_added_location.xlsx", index=False)
        print('saving bin_added_location at ' + root)
    if type == "arrow":
        new_data.to_excel(root + "/bin_added_arrow.xlsx", index=False)
        print('saving bin_added_arrow at ' + root)
    if type == "word":
        new_data.to_excel(root + "/bin_added_word.xlsx", index=False)
        print('saving bin_added_word at ' + root)

    print("File Compilation Complete")

