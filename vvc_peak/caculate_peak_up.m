function caculate_peak_up_top(c)
%%%%%%%%%
basedir='/seastor/helenhelen/isr';
addpath /seastor/helenhelen/scripts/NIFTI
datadir=sprintf('%s/data_singletrial/ref_space/zscore/beta/merged',basedir);

condname={'ERS_IBwc','ERS_DBwc','mem_DBwc','ln_DBwc'}
%%%%%%%%%
radius=3;
TN=120;
subs=setdiff([1:41],[5 8 11 12 15 16 18 19 24:26 28 29 31:34 40]);
%for c=1:4
resultdir=sprintf('%s/peak/VVC/data/top/ps/%s',basedir,condname{c});
mkdir(resultdir);
coorddir=sprintf('%s/peak/VVC/data/top/coordinate',basedir);
ERS=[];mem=[];ln=[];
ERS_z=[];mem_z=[];ln_z=[];
coords=[];tcoords=[];
kmax=128-radius;jmax=128-radius;imax=75-radius
kmin=1+radius;jmin=1+radius;imin=1+radius
nt=50;
for s=subs;
tdata=[];
cc=[];
[idx_ERS_I,idx_ERS_IB_all,idx_ERS_IB_wc,idx_ERS_D,idx_ERS_DB_all,idx_ERS_DB_wc,idx_mem_D,idx_mem_DB_all,idx_mem_DB_wc,idx_ln_D,idx_ln_DB_all,idx_ln_DB_wc,old_idx] = get_idx(s);

        %get fMRI data
        data_file=sprintf('%s/sub%02d.nii.gz',datadir,s);
        data_all=load_nii_zip(data_file);
        data=data_all.img;
        %get coordinate
        coord_file=sprintf('%s/%s_%d.mat', coorddir,condname{c},nt);
        load(coord_file);
 		%get material similarity matrix for encoding phase
		co=squeeze(coords(s,:,[1:3]));
        for t=1:nt;
            tmp=[];
            tmp=squeeze(data(co(t,1),co(t,2),co(t,3),:));
            tdata=[tdata tmp];
        end
		xx=tdata;
       	tcc=1-pdist(xx(:,:),'correlation');
       	cc=0.5*(log(1+tcc)-log(1-tcc));
		ERS_z(s,1)=mean(cc(idx_ERS_I));
        ERS_z(s,2)=mean(cc(idx_ERS_IB_wc));
        ERS_z(s,3)=mean(cc(idx_ERS_IB_all));
        ERS_z(s,4)=mean(cc(idx_ERS_D));
	    ERS_z(s,5)=mean(cc(idx_ERS_DB_wc));
       	ERS_z(s,6)=mean(cc(idx_ERS_DB_all));

        mem_z(s,1)=mean(cc(idx_mem_D));
        mem_z(s,2)=mean(cc(idx_mem_DB_wc));
        mem_z(s,3)=mean(cc(idx_mem_DB_all));

       	ln_z(s,1)=mean(cc(idx_ln_D));
      	ln_z(s,2)=mean(cc(idx_ln_DB_wc));
	    ln_z(s,3)=mean(cc(idx_ln_DB_all));
	
	yy=tdata(1:48,:);
        ln_tcc=1-pdist(yy(:,:),'correlation');
        ln_cc=0.5*(log(1+ln_tcc)-log(1-ln_tcc));
        file_name=sprintf('%s/Mzln_%d_sub%02d', resultdir,nt,s);
        eval(sprintf('save %s ln_cc',file_name));
        file_name=sprintf('%s/Mrln_%d_sub%02d', resultdir,nt,s);
        eval(sprintf('save %s ln_tcc',file_name));

        tzz=tdata(49:end,:);
	zz=tzz(old_idx,:);
        mem_tcc=1-pdist(zz(:,:),'correlation');
        mem_cc=0.5*(log(1+mem_tcc)-log(1-mem_tcc));
        file_name=sprintf('%s/Mzmem_%d_sub%02d', resultdir,nt,s);
        eval(sprintf('save %s mem_cc',file_name));
        file_name=sprintf('%s/Mrmem_%d_sub%02d', resultdir,nt,s);                                                                
        eval(sprintf('save %s mem_tcc',file_name)); 
end%sub
	    ERS=[subs' ERS_z(subs,:)];mem=[subs' mem_z(subs,:)];ln=[subs' ln_z(subs,:)];
	    file_name=sprintf('%s/ERS_%d.txt', resultdir,nt);
	    eval(sprintf('save %s ERS -ascii',file_name));
        file_name=sprintf('%s/mem_%d.txt', resultdir,nt);
        eval(sprintf('save %s mem -ascii',file_name));
        file_name=sprintf('%s/ln_%d.txt', resultdir,nt);
        eval(sprintf('save %s ln -ascii',file_name));
%end %end c
end %function
