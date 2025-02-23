%% TRY TO BUILD THE WHOLE ALGO NOW (WITHOUT THE TOTAL VARIATION FOR NOW) 
% also without reweighting 

%% simple 2D image with 1D convolution kernel 
% assume X and Y are known 

clear all; 
x=phantom(64);
kernel=rand(1,64)>0.9; kernel=kernel./sum(kernel(:)); 
C=opConvolve(64,64,kernel.',[1,1],'cyclic');
y=C*x(:);
X=[]; n=64
for nn=1:n
X=cat(2,X,circshift(x(:),nn-1));
end

%%% solve 
k_init=zeros(size(kernel)); 
opts.pcg_tol = 1e-8;
opts.pcg_its = 100;
opts.lambda=1;

for iter=1:3 %outer iterations 
    k=IRWLS_BlindDeconvolution(k_init.', X, y(:),opts);
    
    %normalize and threshold;
    k(k < 0) = 0;
    sumk = sum(k(:));
    k = k ./ sumk;
    
    k_init=k.';
    
    figure(1); clf;
    hold on;
    plot(k); plot(kernel);
    hold off; drawnow; pause(1)
end


%% Can we do this for the PFOB/PFCE model as well? 
% what would X be in this case ?? 

% neglect the PFCE, say we have a model of 
clear all; 

rr =@(x) reshape(x,[64,64]); 
rr2 =@(x) reshape(x,[64,64*2]); 

n=64; 
x=phantom(n);
kernel=rand(1,64); kernel=kernel./sum(kernel(:)); 
C1=opConvolve(64,64,kernel.',[1,1],'cyclic');
C2=opConvolve(64,64,kernel,[1,1],'cyclic');
C=[C1;C2];
y=C*x(:);

figure(1);clf;
subplot(221);  imshow(abs(rr(x)),[])
subplot(222);  imshow(abs(rr2(y)),[])

% rewrite as X*k = y 
% X will be a n*2*n^2 matrix 

x0=rr(x); % original image 
X1=[]; X2=[]; 
for nn=1:n
xtemp=circshift(x(:),[0 nn-1]);
X1=cat(2,X1,xtemp(:));
end

for nn=1:n
xtemp=circshift(x(:),[nn-1 0]);
X2=cat(2,X2,xtemp(:));
end

X=[X2;X1]; %order?

figure(1); subplot(223); imshow(X);



%%% solve 
k_init=zeros(size(kernel)); 
opts.pcg_tol = 1e-8;
opts.pcg_its = 100;
opts.lambda=10;

for iter=1:10 %outer iterations 
    k=IRWLS_BlindDeconvolution(k_init.', X, y(:),opts);
    
    %normalize and threshold;
    k(k < 0) = 0;
    sumk = sum(k(:));
    k = k ./ sumk;
    
    k_init=k.';
    
    figure(2); clf;
    hold on;
    plot(k); plot(kernel);
    hold off; drawnow; pause(1)
end

%%% use estimated k to deconvolve image
Cest1=opConvolve(64,64,k,[1,1],'cyclic');
Cest2=opConvolve(64,64,k.',[1,1],'cyclic');
Cest=[Cest1;Cest2];
xest=pinv(Cest)*y; 
figure(1); subplot(224); imshow(abs(rr(xest)),[])



%% could we even add PHASE to the PSF????

% ==> YES !!!!

% neglect the PFCE, say we have a model of 
clear all; 

rr =@(x) reshape(x,[64,64]); 
rr2 =@(x) reshape(x,[64,64*2]); 

n=64; 
x=phantom(n);
kernel=rand(1,64)+rand(1,64).*1i;
kernel=kernel./sum(abs(kernel(:))); 
C1=opConvolve(64,64,kernel.',[1,1],'cyclic');
C2=opConvolve(64,64,kernel,[1,1],'cyclic');
C=[C1;C2];
y=C*x(:);

figure(1);clf;
subplot(221);  imshow(abs(rr(x)),[]); title('original image')
subplot(422);  imshow(abs(rr2(y)),[]); title('Two measurement directions - Magnitude ')
subplot(424);  imshow(angle(rr2(y)),[]); title('Two measurement directions - Phase')

% rewrite as X*k = y 
% X will be a n*2*n^2 matrix 

x0=rr(x); % original image 
X1=[]; X2=[]; 
for nn=1:n
xtemp=circshift(x0,[0 nn-1]);
X1=cat(2,X1,xtemp(:));
end

for nn=1:n
xtemp=circshift(x0,[nn-1 0]);
X2=cat(2,X2,xtemp(:));
end

X=[X2;X1]; %order?

figure(10); imshow(X); title('linear convolution operator X')



%%% solve 
k_init=zeros(size(kernel)); 
opts.pcg_tol = 1e-8;
opts.pcg_its = 100;
opts.lambda=10;

for iter=1:10 %outer iterations 
    k=IRWLS_BlindDeconvolution(k_init.', X, y(:),opts);
    
    %normalize and threshold;
    k(k < 0) = 0;
    sumk = sum(k(:));
    k = k ./ sumk;
    
    k_init=k.';
    
    figure(2); clf;
    hold on;
    plot(k); plot(kernel);
    hold off; drawnow; pause(1)
end

%%% use estimated k to deconvolve image
Cest1=opConvolve(64,64,k,[1,1],'cyclic');
Cest2=opConvolve(64,64,k.',[1,1],'cyclic');
Cest=[Cest1;Cest2];
xest=pinv(Cest)*y; 
figure(1); subplot(224); imshow(abs(rr(xest)),[])


