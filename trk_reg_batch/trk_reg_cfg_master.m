function cfg = trk_reg_cfg_master

TrkConv = cfg_repeat;
TrkConv.name = 'trk transform: from exDTI to TrkVis';
TrkConv.tag = 'tag_trk_ex2TrkVis';
TrkConv.values = {trk_exDTI_to_TrkVis_cfg_func};
TrkConv.forcestruct = true;
TrkConv.help = {'This is used to transform the exploreDTI trks to TrackVis compatitive format'};

TrkReg = cfg_repeat;
TrkReg.name = 'track registration : write';
TrkReg.tag = 'tag_trk_reg';
TrkReg.values = {trk_reg_sn_cfg_func, trk_reg_dtitk_cfg_func};
TrkReg.forcestruct = true;
TrkReg.help = {'This app is used to implement the track registration.'};

cfg = cfg_repeat;
cfg.name = 'track operation';
cfg.tag = 'tag_trk_master';
cfg.values = {TrkConv, TrkReg};
cfg.forcestruct = true;
cfg.help = {'This app is used for track operation.'};
