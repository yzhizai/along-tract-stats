function out = trk_reg_dtitk_cfg_run_func(job)

TrkFiles        = job.tag_trk;
aff_filename    = job.tag_aff;
diffeo_filename = job.tag_diffeo;
VFfile          = job.tag_VF;
VGfile          = job.tag_VG;
preName         = job.tag_prefix;

diffeo_vol      = spm_read_vols(spm_vol(diffeo_filename));
VF              = spm_vol(VFfile);
VF              = VF(1);
VG              = spm_vol(VGfile);
VG              = VG(1);

out             = cell(size(TrkFiles));

for aa = 1:numel(trkFiles)
    TrkFile           = TrkFiles{aa};
    [path, name, ext] = spm_fileparts(trkFile);
    trkFileToSave     = fullfile(path, [preName, name, '.', ext]);  
    out{aa}           = trkFileToSave;
    
    [header, tracks] = trk_read(TrkFile);
    [header, tracks] = trk_reg_dtitk(header, tracks, aff_filename, diffeo_vol, VF, VG);
    trk_write(header, tracks, trkFileToSave);
end
