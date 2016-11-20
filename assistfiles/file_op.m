
%%
lista = dir('*nii');

for aa = 1:numel(lista)
    C = textscan(lista(aa).name, '%s', 'delimiter', '_');
    dirname = [C{1}{1}, C{1}{3}];
    mkdir(dirname);
    if exist(dirname, 'dir')
        movefile(lista(aa).name, fullfile('.', dirname, 'dti_fa.nii'));
    end
end
%%
dirname_src = spm_select(1, 'dir');
trk1 = fullfile(dirname_src, 'CST_L.trk');
trk2 = fullfile(dirname_src, 'CST_R.trk');

listb = dir('*');
listb(~[listb.isdir]) = [];
for bb = 3:numel(listb)
    copyfile(trk1, [listb(bb).name, '\'], 'f');
    copyfile(trk2, [listb(bb).name, '\'], 'f');
end
%%
listb = dir('*');
listb(~[listb.isdir]) = [];

filecell1 = {'*fa.nii', '*ad.nii', '*rd.nii', '*tr.nii'};

filecell2 = {'.\dti_fa.nii', '.\dti_ad.nii', '.\dti_rd.nii', '.\dti_tr.nii'};

for bb = 3:numel(listb)
    cd(listb(bb).name)
    cellfun(@movefile, filecell1, filecell2)
    cd ..
%----------------------------------------
%     listc = dir('*trk*');
%     for cc = 1:numel(listc)
%         trkName = listc(cc).name;
%         [pat, tit, ext] = fileparts(trkName);
%         namecell = textscan(tit, '%s', 'Delimiter', {'_', '.'});
%         trkName_new = [namecell{1}{3}, '_', namecell{1}{4}, ext];
%         movefile(trkName, trkName_new);     
%     end
%-------------------------------------------------------
%     cd ..
%     [pat, tit, ext] = fileparts(listb(bb).name);
%     movefile(tit, ['reg', tit]);
end
%% sort the files
lista = dir('*nii');
dirname = [];
for aa = 1:numel(lista)
    C = textscan(lista(aa).name, '%s', 'delimiter', '_');
    temp = [C{1}{1}, C{1}{3}];
    if ~isequal(temp, dirname)
        dirname = temp;
        mkdir(dirname);    
    end
    movefile(lista(aa).name, fullfile('.', dirname));   
end

%%
listb = dir('*sub*');
listb(~[listb.isdir]) = [];

for bb = 1:numel(listb)
    cd(listb(bb).name)
    copyfile('dti_FA.nii', ['..\' listb(bb).name, '_FA.nii']);
    copyfile('dti_MD.nii', ['..\' listb(bb).name, '_MD.nii']);
    cd ..
end