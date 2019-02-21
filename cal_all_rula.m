%% %% load all data
% path_list: row*col = # of action * # of subjects
data_dir_src='C:\Users\lli40\Desktop\Materials\3DPose\Human36\D3_Positions\';
sub_id=[1,5,6,7,8,9,11];
path_list=[];
for i = 1:length(sub_id)
    data_dir=data_dir_src;
    data_dir=[data_dir, 'S', num2str(sub_id(i)), '\MyPoseFeatures\D3_Positions\'];
    path_list=[path_list,dir(data_dir)];
end
%% covert to n*3 skel data matrix
count_id=0;
id_seq=[0, 1, 2, 3, 6, 7, 8, 12, 13, 14, 15, 17, 18, 19, 25, 26, 27]+1;
% the first 2 file name is '.' and '..' (skip)
for i = 3:size(path_list, 1)
    for j = 1: size(path_list, 2)
        sfile = path_list(i, j);
        file_path=[sfile.folder, '\',sfile.name];
        tdata=cdfread(file_path);
        tdata=tdata{:}; % convert cell to array
        for k = 1:size(tdata, 1)
            count_id=count_id+1;
            tdata_1=reshape(tdata(k,:),[3,32])'; % reshape 1 * 96 to 32 * 3
            skel_17{count_id}={[tdata_1(id_seq,1), tdata_1(id_seq,2), tdata_1(id_seq,3)]};
            skel_all{count_id}={[tdata_1(:,1), tdata_1(:,2), tdata_1(:,3)]};
        end
    end
end
%% summary of x ,y, z
n_skel=length(skel_17);
%n_skel=100000;
x_list=zeros(n_skel*17,1);
y_list=zeros(n_skel*17,1);
z_list=zeros(n_skel*17,1);
for i=1:n_skel
    skel=skel_17{i}{:};
    for j=1:17
        x_list((i-1)*j+j)=skel(j, 1);
        y_list((i-1)*j+j)=skel(j, 2);
        z_list((i-1)*j+j)=skel(j, 3);
    end
end
scatter3(x_list, y_list, z_list, 4,[x_list, y_list, z_list]/1000,'filled')
%%
gscore=zeros(527599,2);
for i=1:527599
    b=skel_17{i}{:};
    %[a(i,:), nkscore(i), upascore(i,:), loascore(i,:), tpscore(i)] = calRULA(b);
    gscore(i,:) = calRULA(b);
end
%% creating line-relation matrix
lmatrix=zeros(17);
lmatrix(1,[2,5,8])=1;lmatrix(2, [1,3])=1;lmatrix(3,[2,4])=1;
lmatrix(4,3)=1;lmatrix(5,[1,6])=1;lmatrix(6,[5,7])=1;
lmatrix(7,6)=1;lmatrix(8,[1,9])=1;lmatrix(9,[8,10])=1;
lmatrix(10,[9,11])=1;lmatrix(11,10)=1;lmatrix(12,[9,13])=1;
lmatrix(13,[12,14])=1;lmatrix(14,13)=1;lmatrix(15,[9,16])=1;
lmatrix(16, [15,17])=1;lmatrix(17,16)=1;
%% plot single
a=skel_17{100}{:};
b=skel_all{100}{:};
scatter3(b(:,1),b(:,2),b(:,3))
for i = 1:17
    for j = 1:17
        if lmatrix(i,j)>0
            hold on
            line([a(i,1);a(j,1)],[a(i,2);a(j,2)],[a(i,3);a(j,3)]);
        end
    end
end
shg
%%
subplot(2,2,1)
hist(nkscore(:))
subplot(2,2,2)
hist(upascore(:))
subplot(2,2,3)
hist(loascore(:))
subplot(2,2,4)
hist(tpscore(:))
%% project and normalize
skel_17_p=zeros(527599,34);
for i=1:527599
    temp=skel_17{i}{:}(:,[1,3]);
    skel_17_p(i,:)=temp(:)';
    skel_17_p(i,1:17)=skel_17_p(i,1:17)-skel_17_p(i,1);
    skel_17_p(i,18:34)=skel_17_p(i,18:34)-skel_17_p(i,18);
end
%% save
dlmwrite('C:\Users\lli40\Desktop\MyPaper\HFES2019\gscore_all.txt', gscore)
dlmwrite('C:\Users\lli40\Desktop\MyPaper\HFES2019\skel_17_all.txt', skel_17_p)
gscore_merge=max(gscore')';
dlmwrite('C:\Users\lli40\Desktop\MyPaper\HFES2019\gscore_merge.txt', gscore_merge)
%%
hist(gscore_merge)
%%
class_diff=zeros(6,78011);
count=zeros(6,1);
for i=1:105220
    count(gt(i)-1)=count(gt(i)-1)+1;
    class_diff(gt(i)-1, count(gt(i)-1))=pred(i)-gt(i);
end
cf1= class_diff(1,1:count(1));
cf2= class_diff(2,1:count(2));
cf3= class_diff(3,1:count(3));
cf4= class_diff(4,1:count(4));
cf5= class_diff(5,1:count(5));
cf6= class_diff(6,1:count(6));
%% plot
pred=double(pred);
cm=zeros(7);
for i=1:length(pred)  
    cm(gt(i), pred(i))= cm(gt(i), pred(i))+1;    
end
%% boxplot
grp=[2*ones(1,count(1)),3*ones(1,count(2)),4*ones(1,count(3)),...
    5*ones(1,count(4)),6*ones(1,count(5)),7*ones(1,count(6))];
xall=[cf1(:);cf2(:);cf3(:);cf4(:);cf5(:);cf6(:)];
boxplot(xall, grp)
%% hist
subplot(1,3,1)
hist(gscore(:,1))
subplot(1,3,2)
hist(gscore(:,2))
subplot(1,3,3)
hist(gscore_merge)