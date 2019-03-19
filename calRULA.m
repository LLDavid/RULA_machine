function gscore = calRULA( skel_17 )
%% skel_17: N * 3 matrix (N = 32 from human 3.6)
%% initilization
upascore=[0,0];
loascore=[0,0];

%% skel index
% hip 01, rhip 02, rknee 03, rankle 04, lhip 05, lknee 06, lankle 07, spine 08,
% thorax 09, neck/nose 10,
% head 11, lshoulder 12, lelbow 13, lwrist 14, rshoulder 15, relbow 16,
% rwrist 17

%% pair index
hip=[1,1]; lrhip=[5,2]; lrknee=[6,3];lrankle=[7,4];spine=[8,8];
thorax=[9,9]; nose=[10,10]; head=[11,11]; lrshoulder=[12,15];
lrelbow=[13,16];lrwrist=[14,17];
for i=1:2
    %% Initialize: calculate gs score for left and right hand side separately
    %% Step 1: locate upper arm position
    % right side (from me to screen)
    % define upper body coronal plane with L/R shoulder and hip
    [a1,a2,a3,a4] = plfunc_from_3pts(skel_17(1,:),skel_17(15,:),skel_17(12,:));
    
    % define upper body sagital plane with hip, spine, thorax
    [b1,b2,b3,b4] = plfunc_from_3pts(skel_17(9,:),skel_17(1,:),skel_17(8,:));
    
    % project to the plane
    st1_shouler_up_cro_p=proj3dpts_to_2dpl(a1,a2,a3,a4,skel_17(lrshoulder(i),:));% shoulder
    st1_elbow_up_cro_p=proj3dpts_to_2dpl(a1,a2,a3,a4,skel_17(lrelbow(i),:));% elbow
    st1_hip_up_cro_p=proj3dpts_to_2dpl(a1,a2,a3,a4,skel_17(lrhip(i),:));% hip
    
    st1_shoulder_up_sag_p=proj3dpts_to_2dpl(b1,b2,b3,b4,skel_17(lrshoulder(i),:));
    st1_elbow_up_sag_p=proj3dpts_to_2dpl(b1,b2,b3,b4,skel_17(lrelbow(i),:));
    st1_hip_up_sag_p=proj3dpts_to_2dpl(b1,b2,b3,b4,skel_17(lrhip(i),:));
    
    % projected vectors
    st1_p_upa_cro_v1=st1_elbow_up_cro_p-st1_shouler_up_cro_p;
    st1_p_upa_cro_v2=st1_hip_up_cro_p-st1_shouler_up_cro_p;
    
    st1_p_upa_sag_v1=st1_elbow_up_sag_p-st1_shoulder_up_sag_p;
    st1_p_upa_sag_v2=st1_hip_up_sag_p-st1_shoulder_up_sag_p;
    
    % calculate angle
    %s1_upa_angle_cro=cal3dangle(st1_p_upa_cro_v1,st1_p_upa_cro_v2)/pi*180;
    s1_upa_angle_sag=cal3dangle(st1_p_upa_sag_v1,st1_p_upa_sag_v2)/pi*180;
    
    % anterior reference vector
    spine_to_thorax=skel_17(9,:)-skel_17(8,:);
    if dot(spine_to_thorax, [a1,a2,a3])>0
        ant_v=[a1,a2,a3];
    else
        ant_v=-[a1,a2,a3];
    end
    % upper arm sagital direction
    if dot(st1_p_upa_sag_v1, ant_v)>=0 % upper arm direction
        if s1_upa_angle_sag<=20
            upascore(i)= upascore(i)+1;
        elseif s1_upa_angle_sag<45
            upascore(i)= upascore(i)+2;
        elseif s1_upa_angle_sag<90
            upascore(i)= upascore(i)+3;
        else
            upascore(i)= upascore(i)+4;
        end
    else
        if s1_upa_angle_sag<=20
            upascore(i)= upascore(i)+1;
        else
            upascore(i)= upascore(i)+2;
        end
    end
    % step 1a     arm is supported?
    % raised shoulder
    thorax_hip=skel_17(hip(i),:)-skel_17(thorax(i),:);
    thorax_shoulder=skel_17(lrshoulder(i),:)-skel_17(thorax(i),:);
    if cal3dangle(thorax_hip, thorax_shoulder)/pi*180>95
        upascore(i)=upascore(i)+1;
    end
    % abduction (how about inward adduction ?)
    if cal3dangle(st1_p_upa_cro_v1, st1_p_upa_cro_v2)/pi*180>15 % upper arm direction
        upascore(i)= upascore(i)+1;
    end
    % leaning
    hip_thorax=skel_17(thorax(i),:)-skel_17(hip(i),:);
    if cal3dangle(hip_thorax, [0,0,1])/pi*180>5&&upascore(i)>15
        upascore(i)= upascore(i)-1;
    end
    
    %% Step 2: locate lower arm position
    % project 3d point to sagital plane
    st1_elbow_up_sag_p=proj3dpts_to_2dpl(b1,b2,b3,b4,skel_17(lrelbow(i),:));
    st1_wrist_up_sag_p=proj3dpts_to_2dpl(b1,b2,b3,b4,skel_17(lrwrist(i),:));
    % low arm vector
    st1_p_loa_sag_v1=st1_wrist_up_sag_p-st1_elbow_up_sag_p;
    % upper body coronal vector
    hip_thorax=skel_17(thorax(i),:)-skel_17(hip(i),:);
    
    if cal3dangle(st1_p_loa_sag_v1, hip_thorax)/pi*180<60 ......
            || cal3dangle(st1_p_loa_sag_v1, hip_thorax)/pi*180>100
        loascore(i)=loascore(i)+2;
    else
        loascore(i)=loascore(i)+1;
    end
    
    % arm working across midline
    wrist_p=proj3dpts_to_2dpl(a1,a2,a3,a4,skel_17(lrwrist(i),:));
    thorax_p=proj3dpts_to_2dpl(a1,a2,a3,a4,skel_17(thorax(i),:));
    
    thorax_wirst_p=wrist_p-thorax_p;
    thorax_shoulder_p=skel_17(lrshoulder(i),:)-thorax_p(:)';
    
    if cal3dangle(thorax_wirst_p, thorax_shoulder_p)/pi*180>95
        loascore(i)=loascore(i)+1;
    end
    
    
    
    %% step 3: locate wrist position (ignored)
    %% step 4: wrist twist (ignored)
    %% step 5: look posture score in table A
    %% step 6: add muscle use score
    % assume static and repeated occurs
    %% step 7: force/load score
    %% step 8: find row in table C
    
    
    
end
nkscore=0;
tpscore=0;
%% step 9: locate neck position
% project to sagital plane
head_p=proj3dpts_to_2dpl(b1,b2,b3,b4,skel_17(head(i),:));
thorax_p=proj3dpts_to_2dpl(b1,b2,b3,b4,skel_17(thorax(i),:));
% projected vector
thorax_head_p=head_p-thorax_p;
thorax_hip_p=skel_17(hip(i),:)-thorax_p(:)';

% use thorax-hip as reference
if cal3dangle(ant_v, thorax_head_p)/pi*180<90
    if cal3dangle(thorax_head_p, thorax_hip_p)/pi*180<160
        nkscore=nkscore+3;
    elseif cal3dangle(thorax_head_p, thorax_hip_p)/pi*180>160......
            && cal3dangle(thorax_head_p, thorax_hip_p)/pi*180<=170
        nkscore=nkscore+2;
    elseif cal3dangle(thorax_head_p, thorax_hip_p)/pi*180>170......
            && cal3dangle(thorax_head_p, thorax_hip_p)/pi*180<=180
        nkscore=nkscore+1;
    end
else
    nkscore=nkscore+4;
end

% use ant_v as reference
% if cal3dangle(ant_v, thorax_head_p)/pi*180<70
%     nkscore=nkscore+3;
% elseif cal3dangle(ant_v, thorax_head_p)/pi*180>=70&&...
%         cal3dangle(ant_v, thorax_head_p)/pi*180<80
%     nkscore=nkscore+2;
% elseif cal3dangle(thorax_head_p, thorax_hip_p)/pi*180>=80......
%             && cal3dangle(thorax_head_p, thorax_hip_p)/pi*180<90
%      nkscore=nkscore+1;
% else
%     nkscore=nkscore+4;
% end
% step 9a: twisted neck

thorax_cro_p=proj3dpts_to_2dpl(a1,a2,a3,a4,skel_17(thorax(i),:));
nose_cro_p=proj3dpts_to_2dpl(a1,a2,a3,a4,skel_17(nose(i),:));

thorax_nose_p= nose_cro_p-thorax_cro_p;
hip_thorax_p=thorax_cro_p(:)'-skel_17(hip(i),:);

if cal3dangle(hip_thorax_p, thorax_nose_p)/pi*180>=15
    nkscore=nkscore+1;
end
% step 9a: bend side-bent

thorax_cro_p=proj3dpts_to_2dpl(a1,a2,a3,a4,skel_17(thorax(1),:));
head_cro_p=proj3dpts_to_2dpl(a1,a2,a3,a4,skel_17(head(1),:));

thorax_head_cro_v= head_cro_p-thorax_cro_p;
hip_thorax_p=thorax_cro_p(:)'-skel_17(hip(i),:);

if cal3dangle(hip_thorax_p, thorax_head_cro_v)/pi*180>=15
    nkscore=nkscore+1;
end
%% step 10: trunk position
hip_thorax=skel_17(thorax(1),:)-skel_17(hip(1),:);
if cal3dangle(hip_thorax, [0,0,1])/pi*180>=5......
        && cal3dangle(hip_thorax, [0,1,0])/pi*180<20
    tpscore=tpscore+2;
elseif cal3dangle(hip_thorax, [0,0,1])/pi*180>=20......
        && cal3dangle(hip_thorax, [0,0,1])/pi*180<60
    tpscore=tpscore+3;
elseif cal3dangle(hip_thorax, [0,0,1])/pi*180>=60
    tpscore=tpscore+4;
else
    tpscore=tpscore+1;
end

% step 10a: trunk twisted
hip_rhip=skel_17(lrhip(2),:)-skel_17(hip(i),:);
hip_lhip=skel_17(lrhip(1),:)-skel_17(hip(i),:);

if cal3dangle(hip_rhip, ant_v)/pi*180<85......
        || cal3dangle(hip_lhip, ant_v)/pi*180<85
    tpscore=tpscore+1;
end

% step 10a: truck side-bending
lhip_p=proj3dpts_to_2dpl(a1,a2,a3,a4,skel_17(lrhip(1),:));
rhip_p=proj3dpts_to_2dpl(a1,a2,a3,a4,skel_17(lrhip(2),:));
thorax_p=proj3dpts_to_2dpl(a1,a2,a3,a4,skel_17(thorax(i),:));

hip_thorax_p=thorax_p(:)'-skel_17(hip(i),:);
hip_lhip_p=lhip_p(:)'-skel_17(hip(i),:);
hip_rhip_p=rhip_p(:)'-skel_17(hip(i),:);
if cal3dangle(hip_thorax_p, hip_lhip_p)/pi*180<85......
        || cal3dangle(hip_rhip_p, hip_thorax_p)/pi*180<85
    tpscore=tpscore+1;
end

%% Check Table
gscore=[0,0];
%% Table A
tableA_in=[1 2 2 2 2 3 3 3; 2 2 2 2 3 3 3 3; 2 3 3 3 3 3 4 4;
    2 3 3 3 3 4 4 4; 3 3 3 3 3 4 4 4; 3 3 4 4 4 4 5 5;
    3 3 4 4 4 4 5 5; 3 4 4 4 4 4 5 5; 4 4 4 4 4 5 5 5;
    4 4 4 4 4 5 5 5; 4 4 4 5 5 5 6 6; 4 4 4 5 5 5 6 6;
    5 5 5 5 5 6 6 7; 5 6 6 6 6 7 7 7; 6 6 6 7 7 7 7 8;
    7 7 7 7 7 8 8 8; 8 8 8 8 8 9 9 9; 9 9 9 9 9 9 9 9];
%% Table B
tableB_in=[1 3 2 3 3 4 5 5 6 6 7 7; 2 3 2 3 4 5 5 5 6 7 7 7;
    3 3 3 4 4 5 5 6 6 7 7 7;5 5 5 6 6 7 7 7 7 7 8 8;
    7 7 7 7 7 8 8 8 8 8 8 8;8 8 8 8 8 8 8 9 9 9 9 9];
%% Table C
tableC_in=[1 2 3 3 4 5 5;2 2 3 4 4 5 5;3 3 3 4 4 5 6;
    3 3 3 4 5 6 6;4 4 4 5 6 7 7;4 4 5 6 6 7 7;
    5 5 6 6 7 7 7; 5 5 6 7 7 7 7];
for i =1:2
    % Table A
    row_no_A=(upascore(i)-1)*3+loascore(i);
    % assume in the middle column (no below wrist in human 3.6)
    col_no_B=4;
    TAscore(i)=tableA_in(row_no_A, col_no_B);
    % step6: assume static and repeated occurs
    %TAscore(i)=TAscore(i)+1;
    % step 7: assume load 4.4-22lbs
    %TAscore(i)=TAscore(i)+1;
    
    % Table B
    row_no_B=nkscore;
    % assume leg and feet are supported
    if abs(skel_17(lrankle(1),3)-skel_17(lrankle(2),3))>50
        ls=2;
    else
        ls=1;
    end
    col_no_B=(tpscore-1)*2+ls;
    TBscore=tableB_in(row_no_B, col_no_B);
    % assume static
    %TBscore=TBscore+1;
    % assume load 4.4-20 lbs.
    % TBscore=TBscore+1;
    
    row_no_C=TAscore(i);
    col_no_C=TBscore;
    if row_no_C>8
        row_no_C=8;
    end
    if col_no_C>7
        col_no_C=7;
    end
    %% Grand score
    gscore(i)=tableC_in(row_no_C, col_no_C);
end

end

