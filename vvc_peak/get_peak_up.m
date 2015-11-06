function get_peak_up(c)
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
vvcdir=sprintf('%s/peak/VVC/data/vvc_data/%s',basedir,condname{c});
resultdir=sprintf('%s/peak/VVC/data/peak/%s',basedir,condname{c});
mkdir(resultdir);
ERS=[];mem=[];ln=[];
ERS_z=[];mem_z=[];ln_z=[];
coords=[];tcoords=[];
kmax=128-radius;jmax=128-radius;imax=75-radius
for s=subs;
[idx_ERS_I,idx_ERS_IB_all,idx_ERS_IB_wc,idx_ERS_D,idx_ERS_DB_all,idx_ERS_DB_wc,idx_mem_D,idx_mem_DB_all,idx_mem_DB_wc,idx_ln_D,idx_ln_DB_all,idx_ln_DB_wc] = get_idx(s);

        %get fMRI data
        data_file=sprintf('%s/sub%02d.nii.gz',datadir,s);
        data_all=load_nii_zip(data_file);
        data=data_all.img;

	vvcfile=sprintf('%s/sub%02d.nii.gz',vvcdir,s);
	vvc_all=load_nii_zip(vvcfile);
	vvc=vvc_all.img;
	ss=size(vvc);
	flag=1;
	runtime=0;
	tvvc=vvc;
	while flag
		max_vvc=max(tvvc(:));
		lmax=find(vvc==max_vvc);
		tlmax=find(tvvc==max_vvc);
		[k,j,i]=ind2sub(ss,lmax);
		tcoords(s,:)=[k,j,i];
		%remove max
		tvvc(tlmax)=[];

		if k<=kmax & j<=jmax & i<=imax
 			%define small cubic for memory data
			data_balls=vvc(k-radius:k+radius,j-radius:j+radius,i-radius:i+radius,:);
        		a=size(data_balls);
	        	b=a(1)*a(2)*a(3);
			p=sum(find(data_balls)>=0.01)/b

        	        if p>=0.9
			        data_ball=data(k-radius:k+radius,j-radius:j+radius,i-radius:i+radius,:);
			    v_data = reshape(data_ball,b,TN);
			    xx=v_data';
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
			        
			 flag=0;
                         runtime = runtime + 1
			 else
			 runtime = runtime + 1
			 end %if
               	    else
                    runtime = runtime + 1
                    end %if
		    if runtime >= 100000
            	flag = 0;
            	break;
        	end
	end %while
end%sub
	ERS=[subs' ERS_z(subs,:)];mem=[subs' mem_z(subs,:)];ln=[subs' ln_z(subs,:)];coords=[subs' tcoords(subs',:)];
	file_name=sprintf('%s/ERS.txt', resultdir);
	eval(sprintf('save %s ERS -ascii',file_name));
        file_name=sprintf('%s/mem.txt', resultdir);
        eval(sprintf('save %s mem -ascii',file_name));
        file_name=sprintf('%s/ln.txt', resultdir);
        eval(sprintf('save %s ln -ascii',file_name));
        file_name=sprintf('%s/coordinate.txt', resultdir);
        eval(sprintf('save %s coords -ascii',file_name));
%end %end c
end %function
