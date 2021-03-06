function CM = trk_net_con(trkFileName, volume_sc, sc_name, outputFileName)
%TRK_NET_CON - to generate specified scalar parameter's network.
%
%Syntax: trk_net_con(trkFileName, volume_sc, sc_name, outputFileName)
%
%Inputs:
%  trkFileName: the tmp file generated from trk_refine.m, default
%  trk_tmp.trk
%  volume_sc: scalar volume, such as FA, from spm_read_vols.you should keep
%  in mind the scalar image should have the same voxel_order with the trk.
%  sc_name: such as  'FA'
%  outputFileName: the connection matrix to save in.
%
% Author: Shaofeng Duan (duansf@ihep.ac.cn)
% Institute of High Energy Physics 
% Oct 2015


[header, tracks] = trk_read(trkFileName);

[~, tracks] = trk_add_sc(header, tracks, volume_sc, sc_name);

netCell  = cell(90); %cell to store the edge data
for iTrk = 1:numel(tracks)
    [index_i, index_j] = prop_decode(tracks(iTrk).props);
    sc_data_tmp = double(tracks(iTrk).matrix(:, end));  %if not double, cell will have different datatype.
    netCell{index_i, index_j} = [netCell{index_i, index_j}(:); sc_data_tmp(:)];
end

CM = cellfun(@mean, netCell);
CM = triu(CM, 1);
CM(isnan(CM)) = 0;
CM  = CM + CM';
save(outputFileName, 'CM')




%----------------------------------------------------------
%label the regions which the track linked
%----------------------------------------------------------
function code_prop = prop_encode(label_head, label_end)

code_prop = label_head*100 + label_end;

function [label_head, label_end] = prop_decode(code_prop)

label_head = floor(code_prop/100);
label_end  = rem(code_prop, 100);

