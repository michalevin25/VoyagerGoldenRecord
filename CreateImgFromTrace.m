function CreateImgFromTrace(signal,locs_min, locs_max, counter_adjust,img_folder,img_number)

%{
T = 1/882100;                % Sampling period       
L = length(signal);      % Length of signal
t = (0:L-1)*T; 
figure; plot(t,signal)
hold on
plot(t(locs_max),signal(locs_max), 'o');
plot(t(locs_min),signal(locs_min), 'o');
title('Trace');
xlabel('Samples');
ylabel('Amplitude');
%}

img_matrix = {};
counter_max = 1;
counter_min = 1;

% From Wiki: "A drawing of an entire picture raster, showing that there are
% 512 vertical lines in a complete picture"


for i = 1:512*2
    if counter_max+counter_adjust < length(locs_min)-2
        trace = signal(locs_min(counter_min):locs_max(counter_max+counter_adjust))';
        %a trace may appear empty if the algorithm didnt detect a peak. In this
        %case skip this trace (see plot 7 in notes)
 
        if ~isempty(trace) 
            img_matrix{end+1,1} = trace;
           %plot(locs_min(counter_min):locs_max(counter_max+counter_adjust),trace, 'g')

            counter_max = counter_max+1;
            counter_min = counter_min+1;
        elseif counter_min > 1
            counter_min = counter_min+1;
            counter_max = counter_max+2;
        else 
            counter_min = 1;
        end
    end
end
    

    %for tesing (check that traces are about the same length)
     %{
     img_matrix{end,2} = locs_min(i);
     img_matrix{end,3} = locs_max(i);
     img_matrix{end,4} = length(trace);
    %}
    

%}

%even out all traces lengths to create a matrix

%length of each row in cell   
lengths_of_traces = cellfun('size',img_matrix,2);
avg_length = round(mean(lengths_of_traces));

%if a trace is shorter than average, it will be padded with its last value
%if a trace is longer than average, it will be shortened. 
% figure; plot(img_matrix{1})
% hold on
% plot(img_matrix{2})
% plot(img_matrix{3})
% plot(img_matrix{4})
% plot(img_matrix{5})

% figure;
% hold on;
% title('before padding');
% for i = 1:length(img_matrix)
%     plot(img_matrix{i});
% end

for i = 1:length(img_matrix)
    diff_length = abs(avg_length-length(img_matrix{i}));
    if length(img_matrix{i}) < avg_length
        padding = img_matrix{i}(1)*ones(1,diff_length);
        img_matrix{i} = [padding,img_matrix{i}];
    else
        img_matrix{i} = img_matrix{i}(1:end-diff_length);
    end
end

% figure;
% hold on;
% title('after padding');
% for i = 1:length(img_matrix)
%     plot(img_matrix{i});
% end


%convert to matrix and adjust gray values: 0 is the lowest value in image,
%1 is the highest value
%img = mat2gray(cell2mat(img_matrix));
%figure;imshow(img)


% only odd
img_odd_cell = img_matrix(1:2:end);

a = {};
for i = 1:length(img_odd_cell)-1
    a{1,end+1} = img_odd_cell{i};
    a{1,end+1} = img_odd_cell{i+1};
end
img_odd = mat2gray(cell2mat(a'));

figure; imshow(img_odd);
%save image
p = pwd;
folder_address = strcat(p,'\', img_folder);
if ~exist(folder_address, 'dir')
       mkdir(folder_address)
end

img_address = strcat(folder_address, '\img_', num2str(img_number), '.jpg');
imwrite(img_odd, img_address);
close all