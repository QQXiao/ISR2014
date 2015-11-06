function [idx_ERS_I,idx_ERS_IB_all,idx_ERS_IB_wc,idx_ERS_D,idx_ERS_DB_all,idx_ERS_DB_wc,idx_mem_D,idx_mem_DB_all,idx_mem_DB_wc,idx_ln_D,idx_ln_DB_all,idx_ln_DB_wc,old_idx]=get_idx(s)
basedir='/seastor/helenhelen/isr';
labeldir=[basedir,'/behav/label'];
%data structure
Mtrial=1; % trial number
MpID=2;  % material id_pic
MwID=3;  % material id_word
Mcat=4; % 1=film,2=polition,3=sports,4=other

Mres1=5; %% phase1 learning 1.least -> 4.most;%% phase2 over training 1.do not know; 2.DNK guess; 3.K guess; 4, know well %%phase3 memory test 1.do not know; 2.DNK guess; 3.K guess; 4, know well
Mres2=6; %% phase1 learning 1=film,2=polition,3=sports,4=other; %% phase2 over training 1=film,2=polition,3=sports,4=other %% phase3 memory test1=film,2=polition,3=sports,4=other
MRT1=7; % reaction time;
MRT2=8; % reaction time;

Monset=9; % designed onset time
MAonset=10; % actually onset time
Moldnew=11;% 1 old. 2,new;
Mrun=12;
Mgroup=13;
MAonset_r1=14; % actually onset time for response 1;charming;
MAonset_r2=15; % actually onset time for response 2;identity;
Mscore=16;%right or wrong for identity
Mposit=18;
Mmem=17; %1=high confident hit; 2=low confident hit; 3=high confident miss; 4=low confident miss; 5=known forgot; 6=miss; 7=high confident fa; 8=low confident fa; 9=right rejection
%% added information
Msub=19;
Mphase=20; %1=learning; 2=retrieval
%%%%%%%%%
ntrial  =  48;    % number of condition in each run
TN=120; % 48learning + 72retrieval;
%perpare data
        load(sprintf('%s/learning_sub%02d.mat',labeldir,s));
        list_subln=subln;
        list_subln(:,Msub)=s;
        list_subln(:,Mphase)=1;
        load(sprintf('%s/test_sub%02d.mat',labeldir,s));
        list_submem=submem;
        list_submem(:,Msub)=s;
        list_submem(:,Mphase)=2;
        new_mem=list_submem(list_submem(:,Moldnew)==1,:);
        oldposit=list_submem(list_submem(:,Moldnew)==1,Mposit);
        old_idx=list_submem(list_submem(:,Moldnew)==1,Mposit);
        for nn=1:48
        p=list_subln(nn,MpID);w=list_subln(nn,MwID);
        list_subln(nn,Mmem)=list_submem(list_submem(:,MpID)==p & list_submem(:,MwID)==w,Mmem);
        end
        all_lable=[list_subln;list_submem];
    all_idx=1:TN*(TN-1)/2; %% all paired correlation idx;
    all_pID1=[]; all_pID2=[]; all_wID1=[]; all_wID2=[]; all_Rcate=[]; all_mem1=[];  all_mem2=[]; all_phase1=[]; all_phase2=[]; all_cate1=[]; check_run=[]; check_group=[]; check_cate=[];
    for k=2:TN
        all_pID1=[all_pID1 all_lable(k-1,MpID)*ones(1,TN-k+1)];
        all_pID2=[all_pID2 all_lable(k:TN,MpID)'];
        all_wID1=[all_wID1 all_lable(k-1,MwID)*ones(1,TN-k+1)];
        all_wID2=[all_wID2 all_lable(k:TN,MwID)'];
        all_mem1=[all_mem1 all_lable(k-1,Mmem)*ones(1,TN-k+1)];
        all_mem2=[all_mem2 all_lable(k:TN,Mmem)'];
        all_phase1=[all_phase1 all_lable(k-1,Mphase)*ones(1,TN-k+1)];
        all_phase2=[all_phase2 all_lable(k:TN,Mphase)'];
        all_cate1=[all_cate1 all_lable(k-1,Mcat)*ones(1,TN-k+1)];

        %reported category(note.this is only true for retrieval items)
        all_Rcate=[all_Rcate all_lable(k-1,Mres2)*ones(1,TN-k+1)];

        %1=same run;0=diff run
        check_run=[check_run (all_lable(k:TN,Mrun)==all_lable(k-1,Mrun))'];

        %1=same group;0=diff group
        check_group=[check_group (all_lable(k:TN,Mgroup)==all_lable(k-1,Mgroup))'];
        %1=same category;0=diff categories
        check_cate=[check_cate (all_lable(k:TN,Mcat)==all_lable(k-1,Mcat))'];
    end
    %% get indexes
    idx_ERS_I=find(all_phase1==1 & all_phase2==2 & all_mem2<=2 & all_pID1==all_pID2 & all_wID1==all_wID2);%identity pair: p+c+
    idx_ERS_IB_all=find(all_phase1==1 & all_phase2==2 & all_mem2<=2 & all_pID1~=all_pID2 & check_run==1 & check_group==1);
    idx_ERS_IB_wc=find(all_phase1==1 & all_phase2==2 & all_mem2<=2 & all_pID1~=all_pID2 & check_run==1 & check_group==1 & check_cate==1);
    idx_ERS_D=find(all_phase1==1 & all_phase2==2 & all_mem2<=2 & all_pID1==all_pID2 & all_wID1~=all_wID2);%%same face different words: p+c-
    idx_ERS_DB_all=find(all_phase1==1 & all_phase2==2 & all_mem2<=2 & all_pID1~=all_pID2 & check_run==1 & check_group==0);
    idx_ERS_DB_wc=find(all_phase1==1 & all_phase2==2 & all_mem2<=2 & all_pID1~=all_pID2 & check_run==1 & check_group==0 & check_cate==1);
    %mem
    idx_mem_D=find(all_phase1==2 & all_phase2==2 & all_mem1<=2 & all_mem2<=2 & all_pID1==all_pID2 & all_wID1~=all_wID2);%%same face different words: p+c-
    idx_mem_DB_all=find(all_phase1==2 & all_phase2==2 & all_mem1<=2 & all_mem2<=2 & all_pID1~=all_pID2 & check_run==1 & check_group==0);
    idx_mem_DB_wc=find(all_phase1==2 & all_phase2==2 & all_mem1<=2 & all_mem2<=2 & all_pID1~=all_pID2 & check_run==1 & check_group==0 & check_cate==1);
    %ln
    idx_ln_D=find(all_phase1==1 & all_phase2==1 & all_pID1==all_pID2 & all_wID1~=all_wID2);%%same face different words: p+c-
    idx_ln_DB_all=find(all_phase1==1 & all_phase2==1 & all_pID1~=all_pID2 & check_run==1 & check_group==0);
    idx_ln_DB_wc=find(all_phase1==1 & all_phase2==1 & all_pID1~=all_pID2 & check_run==1 & check_group==0 & check_cate==1);
end %func
