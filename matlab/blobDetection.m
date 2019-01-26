function blobDetection(IM,sigma,k,N,threshold,method)
%% IM: image on top of which you want to display the circles
% assigning values of sigma and k here.
% IM = imread('..\data\i_004.jpg'); 
% sigma = 1.5;
% k = 1.3;
% N = 15;
% threshold = 0.0017;
% method =2;

IM = rgb2gray(IM);
IM = im2double(IM);
sigma1= sigma;
dim = 2*ceil(3*sigma)+1;
scale_space = zeros(size(IM,1),size(IM,2),N);
sca = zeros(size(IM,1),size(IM,2),N);
%% applying filter on images                    
%% method1 keeping image size constant and increasing filter size
if method == 1
    tic
    for i=1:N
        
         Filter = fspecial('log', dim, sigma);
         Filter = Filter.* (sigma*sigma);
         filter_response = imfilter(IM, Filter,'replicate');
         filter_response = filter_response.^2;
         sigma = k * sigma;
         dim = 2*(ceil(3*sigma)) + 1;
         scale_space(:,:,i) = filter_response;
    end
    toc
end
%% method2 keeping filter size constant and downsampling the image
if method == 2
    tic
    FilterConst = fspecial('log', dim, sigma1).*(sigma1*sigma1);
    for i=1:N
         IM1=imresize(IM,(1/(k^(i-1))),'bicubic');
         filter_response = imfilter(IM1, FilterConst,'replicate');
         filter_response = imresize(filter_response, [size(IM,1) size(IM,2)],'bicubic');
         filter_response = filter_response.^2;
         scale_space(:,:,i) = filter_response;
    end
    toc
end
%% method to return maximum for nlfilter (not used).
% f =@maxi
% function z = maxi(x,y)
%     z=y;
%     if x>y
%         z=x;
%     end
% end
%% non maxima supression on 2D layers
for i=1:size(scale_space,3) 
    %sca(:,:,i) = (nlfilter(scale_space(:,:,i), [3 3], maxi));
    sca(:,:,i) = (ordfilt2(scale_space(:,:,i), 9, ones(3,3)));
end
%% non maxima supression between all 2D layrs 
maxima = zeros(size(IM,1),size(IM,2),N);
radius =[];
r1 =[]; c1=[]; 
maximas = zeros(size(IM,1),size(IM,2));
for i=1:size(IM,1)
    for j=1:size(IM,2)
        maximas(i,j) = max(sca(i,j,:),[],3);
    end
end

%% drawing circles on the image
for i=1:size(scale_space,3)
    maxima(:,:,i) = maximas(:,:).*(maximas(:,:)==scale_space(:,:,i));
    % Check the intensities/values that cross the threshold..
    [r,c] = find(maxima(:,:,i)>= threshold);
    r1 = cat(1,r1,r);
    c1 = cat(1,c1,c);
    blobs = length(c);
    %b1 = length(r);
    rad_array = sqrt(2)*sigma1*((k^(i-1)));
    rad_array = repmat(rad_array,blobs,1);
    radius = cat(1,radius,rad_array);
end
show_all_circles(IM,c1,r1,radius,'r',1.50);

end
