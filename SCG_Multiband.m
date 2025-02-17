close all; clear; clc;
t0=cputime;

fps = 250;    %视频帧率
time = 20;    % 信号长度
time_spec = time/2;   % 频域变换时的长度
time_angle = time;   % 主导角度更新时间
time_start = 0;   % 开始时间
vedio_name = 'video1-4108585667';
save_name = vedio_name;
channel = 2;
     
      
% 设置开始和结束的事件
iframe = fps*time_start+1;
nframe = fps*time-1; 
% 记录xy方向上的偏移量
Drx = [];
Dry = [];
% 记录xy方向上的偏移量
Dgx = [];
Dgy = [];
% 记录xy方向上的偏移量
Dbx = [];
Dby = [];

%% 读取视频
name = strcat('D:\Dataset\SCG-2camera\',vedio_name);  % "D:\Dataset\SCG-2camera\video1-4108585667.avi"

v = VideoReader(strcat(name,'.avi'));

% 读取第一帧图片
frame = read(v, 1);

zengyi = 1;
frame_r = frame(:,:,1)*zengyi;
frame_g = frame(:,:,2)*zengyi;
frame_b = frame(:,:,3)*zengyi;

%% ROI选择
imshow(frame_r);
roi_r = drawrectangle('Color', [1 0.1 0.1]);
roi_r = floor(roi_r.Position);
imshow(frame_g);
roi_g = drawrectangle('Color', [1 0.1 0.1]);
roi_g = floor(roi_g.Position);
% roi_g=[68, 15,289,263];
% roi_r=[23,20,220,241];
%% 光流法---需要优化


opticFlowr = opticalFlowFarneback("NumPyramidLevels",5);
opticFlowg = opticalFlowFarneback("NumPyramidLevels",5);

for i = 1:channel
    if i ==1
        for idx = iframe : iframe+nframe
            % 打印输出
            disp([num2str('R:'),num2str(idx),'|',num2str(iframe + nframe)]);
            % 选择选定的感兴趣区域
            frame = read(v, idx);
            frame = frame(:,:,1);
            %frame = frame(roi_r(2):roi_r(2)+roi_r(4), roi_r(1):roi_r(1)+roi_r(3),:);
            frame = frame(roi_r(2):roi_r(2)+roi_r(4), roi_r(1):roi_r(1)+roi_r(3),:);
            % 估计两个视频帧的光流量
            flow = estimateFlow(opticFlowr,frame);

            % 计算X Y方向的偏移量
            dx = mean2(double(flow.Vx));
            dy = mean2(double(flow.Vy));

            Drx = [Drx, dx];
            Dry = [Dry, dy];
        end
    elseif i == 2
        for idx = iframe : iframe+nframe
            % 打印输出
            disp([num2str('G:'),num2str(idx),'|',num2str(iframe + nframe)]);
            % 选择选定的感兴趣区域
            frame = read(v, idx);
            frame = frame(:,:,2);
            frame = frame(roi_g(2):roi_g(2)+roi_g(4), roi_g(1):roi_g(1)+roi_g(3),:);

            % 估计两个视频帧的光流量
            flow = estimateFlow(opticFlowg,frame);

            % 计算X Y方向的偏移量
            dx = mean2(double(flow.Vx));
            dy = mean2(double(flow.Vy));

            Dgx = [Dgx, dx];
            Dgy = [Dgy, dy];
        end
    elseif i ==3
         for idx = iframe : iframe+nframe
            % 打印输出
            disp([num2str('B:'),num2str(idx),'|',num2str(iframe + nframe)]);
            % 选择选定的感兴趣区域
            frame = read(v, idx);
            frame = frame(:,:,3);
            frame = frame(roi_b(2):roi_b(2)+roi_b(4), roi_b(1):roi_b(1)+roi_b(3),:);

            % 估计两个视频帧的光流量
            flow = estimateFlow(opticFlowb,frame);

            % 计算X Y方向的偏移量
            dx = mean2(double(flow.Vx));
            dy = mean2(double(flow.Vy));

            Dbx = [Dbx, dx];
            Dby = [Dby, dy];
        end
    end
end
%% 运动合成
[Dxyr, Dxyg] = motion_synthesis(Drx, Dry , Dgx, Dgy, time, fps); 


%% 保存参数并输出
save(strcat(save_name,'.mat'),"Dgy","Dgx","Dry","Drx", 'roi_r',"roi_g","time");

figure
subplot(3,2,1)
plot(Drx)
title("X")
ylabel("R-channel")
subplot(3,2,2)
plot(Dry)
title("Y")
subplot(3,2,3)
plot(Dgx)
ylabel("G-channel")
subplot(3,2,4)
plot(Dgy)
subplot(3,2,5)
plot(Dxyr)

subplot(3,2,6)
plot(Dxyg)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t1=cputime-t0;
disp([num2str('The program running time is:'),num2str(t1)]);