import sys
sys.path.append(r'C:\Users\Minu Kim\Documents\GitHub')
# import os
# from os import sep
import pandas as pd
# import numpy as np
import minu_modules as mm
import matplotlib.pyplot as plt
# import seaborn as sns
# import math
import ast

mm.pd_print_all()
iv = ["n0", "bin"]
dv = "mean_auc"
 # arrow, location, word

arrow_data = pd.read_excel(r'C:\Users\Minu Kim\Documents\GitHub\mouse_tracking\arrow_indiv.xlsx', header=0)
arrow_data = arrow_data.reset_index(drop=True)
# arrow_data = arrow_data.loc[:, ('id', 'n0', 'bin', 'GroupCount', 'mean_rt', 'mean_it', 'mean_mt', 'mean_auc', 'mean_xflip', 'mean_yflip', 'mean_entrypy_x', 'mean_entropy_y', 'mean_time_max', 'mean_complexnum', 'mean_flip2d', 'mean_entropy2d', 'mean_overshoot2d', 'mean_new_it', 'mean_new_mt')]
arrow_data = arrow_data.loc[:, ('id', 'n0', 'bin', 'GroupCount', 'mean_auc', 'mean_rt', 'mean_it', 'mean_mt', 'mean_new_it', 'mean_new_mt')]

location_data = pd.read_excel(r'C:\Users\Minu Kim\Documents\GitHub\mouse_tracking\location_indiv.xlsx', header=0)
location_data = location_data.reset_index()
# location_data = location_data.loc[:, ('id', 'n0', 'bin', 'GroupCount', 'mean_rt', 'mean_it', 'mean_mt', 'mean_auc', 'mean_xflip', 'mean_yflip', 'mean_entrypy_x', 'mean_entropy_y', 'mean_time_max', 'mean_complexnum', 'mean_flip2d', 'mean_entropy2d', 'mean_overshoot2d', 'mean_new_it', 'mean_new_mt')]
location_data = location_data.loc[:, ('id', 'n0', 'bin', 'GroupCount', 'mean_auc', 'mean_rt', 'mean_it', 'mean_mt', 'mean_new_it', 'mean_new_mt')]

word_data = pd.read_excel(r'C:\Users\Minu Kim\Documents\GitHub\mouse_tracking\word_indiv.xlsx', header=0)
word_data = word_data.reset_index()
# word_data = word_data.loc[:, ('id', 'n0', 'bin', 'GroupCount', 'mean_rt', 'mean_it', 'mean_mt', 'mean_auc', 'mean_xflip', 'mean_yflip', 'mean_entrypy_x', 'mean_entropy_y', 'mean_time_max', 'mean_complexnum', 'mean_flip2d', 'mean_entropy2d', 'mean_overshoot2d', 'mean_new_it', 'mean_new_mt')]
word_data = word_data.loc[:, ('id', 'n0', 'bin', 'GroupCount', 'mean_rt', 'mean_auc', 'mean_it', 'mean_mt', 'mean_new_it', 'mean_new_mt')]

aa = arrow_data.groupby(iv)[dv].mean()
aa = aa.to_frame()
aa = aa.reset_index()
aa['exp'] = 'arrow'
cong_arrow = aa[aa["n0"]==1]
cong_arrow = cong_arrow.reset_index()
inco_arrow = aa[aa["n0"]==2]
inco_arrow = inco_arrow.reset_index()
cs_arrow = pd.DataFrame()
cs_arrow["bin"] = cong_arrow.bin
cs_arrow["exp"] = cong_arrow.exp
cs_arrow["cs_rt"] = round(inco_arrow[dv],0) - round(cong_arrow[dv],0)



bb = word_data.groupby(iv)[dv].mean()
bb = bb.to_frame()
bb = bb.reset_index()
bb['exp'] = 'word'
cong_word = bb[bb["n0"]==1]
cong_word = cong_word.reset_index()
inco_word = bb[bb["n0"]==2]
inco_word = inco_word.reset_index()
cs_word = pd.DataFrame()
cs_word["bin"] = cong_word.bin
cs_word["exp"] = cong_word.exp
cs_word["cs_rt"] = round(inco_word[dv],0) - round(cong_word[dv],0)




cc = location_data.groupby(iv)[dv].mean()
cc = cc.to_frame()
cc = cc.reset_index()
cc['exp'] = 'location'
cong_location = cc[cc["n0"]==1]
cong_location = cong_location.reset_index()
inco_location = cc[cc["n0"]==2]
inco_location = inco_location.reset_index()
cs_location = pd.DataFrame()
cs_location["bin"] = cong_location.bin
cs_location["exp"] = cong_location.exp
cs_location["cs_rt"] = round(inco_location[dv],0) - round(cong_location[dv],0)


frames = [aa,bb,cc]
result = pd.concat(frames)

plt.title(dv)
plt.plot('bin', 'cs_rt', data=cs_arrow, linestyle='-', marker='o', color='red', label="arrow")  # arrow
plt.plot('bin', 'cs_rt', data=cs_word, linestyle='-', marker='o', color='blue', label="word")  # word
plt.plot('bin', 'cs_rt', data=cs_location, linestyle='-', marker='o', color='green', label="location")  # location
plt.ylabel('rt')
plt.xlabel('bin')
plt.xticks([1,2,3,4],['1', '2', '3', '4'])
plt.legend()
plt.savefig(dv+'.png')
plt.show()


