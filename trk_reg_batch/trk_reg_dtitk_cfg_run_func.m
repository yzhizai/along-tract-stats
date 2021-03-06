function out = trk_reg_dtitk_cfg_run_func(job)

TrkFiles        = job.tag_trk;
aff_filename    = job.tag_aff;
diffeo_filename = job.tag_diffeo;
VFfile          = job.tag_VF;
VGfile          = job.tag_VG;
preName         = job.tag_prefix;

[path, tit, ext, ~] = spm_fileparts(diffeo_filename{1});
diffeo_filename = fullfile(path, [tit ext]);
diffeo_vol      = spm_vol(diffeo_filename);
VF              = spm_vol(VFfile{1});
VF              = VF(1);
VG              = spm_vol(VGfile{1});
VG              = VG(1);

out             = cell(size(TrkFiles));

for aa = 1:numel(TrkFiles)
    TrkFile           = TrkFiles{aa};
    [path, name, ext] = spm_fileparts(TrkFile);
    trkFileToSave     = fullfile(path, [preName, '_', name, ext]);  
    out{aa}           = trkFileToSave;
    
    [header, tracks] = trk_read(TrkFile);
    [header, tracks] = trk_reg_dtitk(header, tracks, aff_filename{1}, diffeo_vol, VF, VG);
    trk_write(header, tracks, trkFileToSave);
end
