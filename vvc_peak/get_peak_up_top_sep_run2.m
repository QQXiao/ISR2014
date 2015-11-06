function get_peak_up_top_sep_run2(c)
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
vvcdir=sprintf('%s/peak/VVC/data/vvc_data/sep_run/run2/%s',basedir,condname{c});
resultdir=sprintf('%s/peak/VVC/data/top/coordinate/sep_run_run2',basedir);
mkdir(resultdir);
ERS=[];mem=[];ln=[];
ERS_z=[];mem_z=[];ln_z=[];
kmax=128-radius;jmax=128-radius;imax=75-radius
nt=50; %100; 200; 500; 1000
coords=zeros(21:nt,4);
for s=subs;
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
	    t=0;
	while flag
		max_vvc=max(tvvc(:));
		lmax=find(vvc==max_vvc);
		tlmax=find(tvvc==max_vvc);
		[k,j,i]=ind2sub(ss,lmax);
		%remove max
		tvvc(tlmax)=[];
		if k<=kmax & j<=jmax & i<=imax
 		%define small cubic for memory data
		data_balls=vvc(k-radius:k+radius,j-radius:j+radius,i-radius:i+radius,:);
        a=size(data_balls);
        b=a(1)*a(2)*a(3);
		p=sum(find(data_balls)>=0.01)/b

            if p>=0.9
			t=t+1
            runtime = runtime + 1
			coords(s,t,1:3)=[k,j,i];
			coords(s,t,4)=runtime;
			else
			runtime = runtime + 1
			end %if
	    else
        runtime = runtime + 1
        end %if
		if t==nt | runtime >= 100000
            	flag = 0;
            	break;
        	end
	end %while
end%sub
        file_name=sprintf('%s/%s_%d.mat', resultdir,condname{c},nt);
        eval(sprintf('save %s coords',file_name));
%end %end c
end %function
