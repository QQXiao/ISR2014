function caculate_mem_ln()
%%%%%%%%%
basedir='/seastor/helenhelen/isr';
addpath /seastor/helenhelen/scripts/NIFTI
datadir=sprintf('%s/data_singletrial/ref_space/zscore/beta/merged',basedir);

condname={'ERS_IBwc','ERS_DBwc','mem_DBwc','ln_DBwc'}
%%%%%%%%%
xlength =  128;
ylength =  128;
zlength =  75;
radius=3;
step=1;     % compute accuracy map for every STEP voxels in each dimension                                                                                          eps
epsilon=1e-6;
TN=120;
subs=setdiff([1:41],[5 8 11 12 15 16 18 19 24:26 28 29 31:34 40]);
%for c=1:4
resultdir=sprintf('%s/peak/VVC/data/top/ps/mem_ln/r',basedir);
lndir=sprintf('%s/peak/VVC/data/top/ps/ln_DBwc',basedir);
mkdir(resultdir);
nt=50;

for s=subs;
mem_r=zeros(xlength,ylength,zlength,1);
ln_r=zeros(xlength,ylength,zlength,1);
[idx_ERS_I,idx_ERS_IB_all,idx_ERS_IB_wc,idx_ERS_D,idx_ERS_DB_all,idx_ERS_DB_wc,idx_mem_D,idx_mem_DB_all,idx_mem_DB_wc,idx_ln_D,idx_ln_DB_all,idx_ln_DB_wc,old_idx] = get_idx(s);

        %get fMRI data
        data_file=sprintf('%s/sub%02d.nii.gz',datadir,s);
        data_all=load_nii_zip(data_file);
        data=data_all.img;
        %get encoding materail similarity matrix
        ln_file=sprintf('%s/Mrln_%d_sub%02d.mat', lndir,nt,s);
        load(ln_file); ln=ln_tcc;
    %%analysis
    for k=radius+1:step:xlength-radius
        for j=radius+1:step:ylength-radius
            for i=radius+1:step:zlength-radius
                data_ball = data(k-radius:k+radius,j-radius:j+radius,i-radius:i+radius,:); % define small cubic for memory data)
                a=size(data_ball);
                b=a(1)*a(2)*a(3);
                v_data = reshape(data_ball,b,TN);
                if sum(std(v_data(:,:))==0)>epsilon
                    mem_r(k,j,i,:)=10;
                    ln_r(k,j,i,:)=10;
                else
                    xx=v_data';
                    data_ln=xx(1:48,:);
                    tdata_mem=xx(49:end,:);
                    data_mem=tdata_mem(old_idx:end,:);
                    tcc_ln=1-pdist(data_ln(:,:),'correlation');
                    %cc_ln=0.5*(log(1+tcc_ln)-log(1-tcc_ln));
                    tcc_mem=1-pdist(data_mem(:,:),'correlation');
                    %cc_mem=0.5*(log(1+tcc_mem)-log(1-tcc_mem));

                    cc_encoding_ln=1-pdist([ln;tcc_ln],'correlation');
                    cc_encoding_mem=1-pdist([ln;tcc_mem],'correlation');

                    ln_r(k,j,i)=mean(cc_encoding_ln);
                    mem_r(k,j,i)=mean(cc_encoding_mem);
                end
            end %i
        end %j
    end %k
        filename=sprintf('%s/mem_sub%02d_%d.nii', resultdir,s,nt);
        data_all.img=squeeze(mem_r(:,:,:,:));
        data_all.hdr.dime.dim(5)=1; % dimension chagne to 1
        save_untouch_nii(data_all, filename);
        system(sprintf('gzip -f %s',filename));

        filename=sprintf('%s/ln_sub%02d_%d.nii', resultdir,s,nt);
        data_all.img=squeeze(ln_r(:,:,:,:));
        data_all.hdr.dime.dim(5)=1; % dimension chagne to 1
        save_untouch_nii(data_all, filename);
        system(sprintf('gzip -f %s',filename));
end %function
