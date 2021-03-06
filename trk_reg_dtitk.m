function [header,tracks] = trk_reg_dtitk(header,tracks, aff_filename, diffeo_vol, VF, VG)
%TRK_REG_DTITK - used to registrit the tracks
%you should ensure the max(abs(sn.VF.mat)) = [1, 2, 3];
%
%Syntax: [header,tracks] = TRK_REG_DTITK(header,tracks, aff_filename, diffeo_vol, VF, VG)
%
%  Inputs
%    header, tracks - the result of the trk_read.m, ensure the trk files
%    voxel_order is RAS, so that it can be compatible with the DTITK.
%    aff_filename   - the name of *.aff file generated from the DTI_TK
%    dti_reg_affine
%    diffeo_vol     - spm_vol('*_aff_diffeo.df.nii')
%    VF             - spm_vol(<source of DTI_TK>)
%    VG             - spm_vol(<template of DTI_TK>)
%
%  Outputs
%    header - all information about the voxel, such as dim, voxel_size, vox_to_ras, 
%      image_orientation_patient, obtained from the VF. 
%
%  Example:
%    [header, tracks] = trk_read('trk.trk');
%    aff_filename     = '*.aff';
%    diffeo_vol       = spm_vol('*_aff_diffeo.df.nii');
%    VF               = spm_vol('VFfilename.nii');
%    VG               = spm_vol('VGfilename.nii');
%    [header, tracks] = TRK_REG_DTITK(header,tracks, aff_filename,
%    diffeo_vol, VF, VG);
%
%See also: TRK_READ, SPM_VOL
% Author: Shaofeng Duan (duansf@ihep.ac.cn)
% Institute of High Energy Physics 
% Sep 2015

intrp = [3, 3, 3, 0, 0, 0];

scale_xyz = header.voxel_size ./ ...
    sqrt(sum(diffeo_vol(1).mat(1:3, 1:3).^2));
scale_x = scale_xyz(1);
scale_y = scale_xyz(2);
scale_z = scale_xyz(3);

Cos  = spm_read_vols(diffeo_vol); 
C1   = spm_diffeo('bsplinc',single(Cos(:, :, :, 1)),intrp);
C2   = spm_diffeo('bsplinc',single(Cos(:, :, :, 2)),intrp);
C3   = spm_diffeo('bsplinc',single(Cos(:, :, :, 3)),intrp);

mat_VG = diag([sqrt(sum(VG.mat(1:3,1:3).^2)), 1]);
mat_VF = diag([sqrt(sum(VF.mat(1:3,1:3).^2)), 1]);
Mult = mat_VF\get_affine_dtitk(aff_filename)*mat_VG;
voxel_size = sqrt(sum(VF.mat(1:3,1:3).^2));
for iTrk=1:length(tracks)
    % Translate continuous vertex coordinates into discrete voxel coordinates
    vox = tracks(iTrk).matrix(:,1:3);
    
    % Index into volume to extract scalar values
    nPoints = size(tracks(iTrk).matrix,1);
    
    nSize = ceil(nthroot(nPoints,3));
    [X_trk, Y_trk, Z_trk] = ndgrid(1:nSize);
    X_trk(1:nPoints) = vox(:,1) * scale_x;
    Y_trk(1:nPoints) = vox(:,2) * scale_y;
    Z_trk(1:nPoints) = vox(:,3) * scale_z;
    
    dat1 = spm_diffeo('bsplins',C1,single(cat(4, X_trk, Y_trk, Z_trk)),intrp);  %获取对应位置的非线性参数值
    dat2 = spm_diffeo('bsplins',C2,single(cat(4, X_trk, Y_trk, Z_trk)),intrp);
    dat3 = spm_diffeo('bsplins',C3,single(cat(4, X_trk, Y_trk, Z_trk)),intrp);
    
    dat1(isnan(dat1)) = 0;
    dat2(isnan(dat2)) = 0;
    dat3(isnan(dat3)) = 0;
    
    %利用非线性变形场刷新vox
    vox = vox + [dat1(1:nPoints)', dat2(1:nPoints)', dat3(1:nPoints)'] ./ ...
        repmat([scale_x, scale_y, scale_z], nPoints, 1); %经验证，这个地方应该是+号
    vox = vox ./ repmat(header.voxel_size, tracks(iTrk).nPoints,1);
    
    tracks(iTrk).matrix(:, 1:3) = affine(vox, Mult).* repmat(voxel_size, nPoints, 1);
    
    %配准之后会出现超出体素范围的体素出现，所以要进行一定的修改。而且一般出现在z轴上，所有对z轴进行一定的修改
%     coords = tracks(iTrk).matrix(:, 3);
%     coords(coords <= 0) = 0.1;
%     coords(coords > voxel_size(3)*VF.dim(3)) = voxel_size(3)*VF.dim(3);
%     tracks(iTrk).matrix(:, 3) = coords;
    
    clear('vox');
end

header.dim        = VF.dim(1:3);
header.voxel_size = voxel_size;
%这个地方需要注意一下，在spm中的头文件中的mat的第四列进行了操作，与原始的头文件
%面的sform信息不一致。其转化关系是：
%nii(:, 4) = sum(mat, 2);

mat = VF.mat;
mat(:, 4) = sum(mat, 2);
header.vox_to_ras = mat;
header.image_orientation_patient = getIOP(VF.fname);

%==========================================================================
% function Def = affine(y,M)
%==========================================================================
function y_wld = affine(y_vox,M)
y_wld       = zeros(size(y_vox),'single');
y_wld(:, 1) = y_vox(:, 1)*M(1, 1) + y_vox(:, 2)*M(1, 2) + y_vox(:, 3)*M(1, 3) + M(1, 4);
y_wld(:, 2) = y_vox(:, 1)*M(2, 1) + y_vox(:, 2)*M(2, 2) + y_vox(:, 3)*M(2, 3) + M(2, 4);
y_wld(:, 3) = y_vox(:, 1)*M(3, 1) + y_vox(:, 2)*M(3, 2) + y_vox(:, 3)*M(3, 3) + M(3, 4);

%==========================================================================
%function IOP = getIOP(fname)  
%==========================================================================
function IOP = getIOP(fname)
nii = load_untouch_header_only(fname);

b = nii.hist.quatern_b;
c = nii.hist.quatern_c;
d = nii.hist.quatern_d;

a = sqrt(1 - sum([b, c, d].^2));

R11 = a*a + b*b - c*c -d*d;
R21 = 2*b*c + 2*a*d;
R31 = 2*b*d - 2*a*c;
R12 = 2*b*c - 2*a*d;
R22 = a*a + c*c - b*b - d*d;
R32 = 2*c*d + 2*a*b;
IOP = [-R11, -R21, R31, -R12, -R22, R32];
%==========================================================================
%function Affine = get_affine_dtitk(fileName)  
%==========================================================================
function Affine = get_affine_dtitk(fileName)

fid = fopen(fileName, 'r+');
fgetl(fid);
Affine = eye(4);
for aa = 1:3
    tline = fgetl(fid);
    Affine(aa, 1:3) = sscanf(tline, '%f', [1, 3]);
end
fgetl(fid);
tline = fgetl(fid);
Affine(1:3, 4) = sscanf(tline, '%f', [3, 1]);