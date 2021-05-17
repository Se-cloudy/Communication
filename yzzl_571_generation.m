%改变signal-generation中的前缀位置
clear;
clc;
clf;
%%一、信号生成

%可调参数
B = 2e4; %带宽改为2M，先仿少一点的
CP = 8; %小于子载波个数，改为106
f_inter = 1700;
%1.1 参数设置与消息序列
B_c = B + CP * f_inter;%前缀拓展了的带宽
Fs = 2 * B_c; %采样频率2B
f_0 = [f_inter:f_inter:B];%数据子载波频域位置
f = [f_inter: f_inter: B_c]; %所有子载波频域位置
N_carrier = length(f_0); %数据子载波个数length(f)
t = 0:1 / Fs:10 - 1 / Fs; % 改为100, 0-9.98s 一共1e5,10*fs=1e5
a_0 = 10 * rand(1, N_carrier); %CP前的消息序列，幅度为10
x=a_0(end-CP+1:end);%1*3
a = [a_0(end-CP+1:end), a_0];%添加了CP载波的消息序列，正确
%a = [a_0, a_0(N_carrier - 2 * CP + 1:end)]; %添加了CP的消息序列,106个CP

%1.2 信号
y_signal_t = 0; %复合的1024个子载波之和，时域载波

for i = 1:length(f)
    y_signal_t = y_signal_t + a(i) * sin(2 * pi * f(i) * t);
end

N = length(y_signal_t); % N
f3 = (N / 2:N - 1) * Fs / N - Fs / 2; %频率范围0-BHz
f4 = f3 / 1000;
y2 = abs(fftshift(fft(y_signal_t)));
y_signal_f = 2 * y2(N / 2:N - 1)/N; %幅值修正得到真实幅值

%%
%y_signal_f按照f4绘图是正确消息数值。
%数据特别小应该是其他频点趋近于零
%%
%1.3 导频
p_f_location = [2.5*f_inter:4*f_inter:B_c];%对含有前缀的所有子载波加导频，位置不应与信号重叠
p_t = 0; %复合的1024+CP个子载波之和，时域载波

for i = 1:length(p_f_location)
    p_t = p_t + sin(2 * pi * p_f_location(i) * t);
end

N_p = length(p_t); % N
%p_f3 = (N_p / 2:N_p - 1) * Fs / N_p - Fs / 2; %频率范围0Hz-B_cHz
p2 = abs(fftshift(fft(p_t)));
p_f = 2 * p2(N_p / 2:N_p - 1) / N_p; %幅值修正得到真实幅值
%p_f4 = p_f3 / 1000;

%%test
p_f_location(1)
p_f(p_f_location(1))
%%
%f4-p_f4=0;

%%信号与导频生成绘图
figure();
subplot(121);
plot(f4, y_signal_f);
title('消息信号');
xlabel('Frequency/kHz');
ylabel('Amplitude');
subplot(122);
plot(f4, p_f);%f4为全部频点范围，需要找到导频位置
%plot(p_f_location,p_f(p_f_location));
title('导频');
xlabel('Frequency/kHz');
ylabel('Amplitude');

figure(); hold on
plot(f4, y_signal_f);
plot(f4, p_f);%p_f4=f4覆盖了，所以可以通用f4
legend('signal', 'pilot');
xlabel('Frequency/kHz');
ylabel('Amplitude');

y_add = y_signal_f + p_f;
%y_add中提取pilot
%f4仅仅是所有频点横轴，赋信号就是信号
%需要找到导频位置，从add中取出
%f4-p_f!=0;
figure()
plot(f4,y_add);
title('test:add');
xlabel('Frequency/kHz');
ylabel('Amplitude');

%%二、瑞利信道（以double-flat为例）
%使用正弦波总和技术生成瑞利信道：
%单径
% Fd = 1;                       % Maximum Doppler shift (Hz)
% numSamples = 1000;              % Number of samples
% rayChan = comm.RayleighChannel('SampleRate',Fs, ...
% 'MaximumDopplerShift',Fd,'FadingTechnique','Sum of sinusoids')
%多径
pathDelays = [0 10] .* (1/Fs);  % Path delays (s)
pathPower = [0 -4];             % Path power (dB)
Fd = 100;                       % Maximum Doppler shift (Hz)
numSamples = 1000;              % Number of samples
rayChan = comm.RayleighChannel('SampleRate',Fs, ...
'PathDelays',pathDelays,'AveragePathGains',pathPower, ...
'MaximumDopplerShift',Fd)
%,'Visualization','Impulse and frequency responses');
%'FadingTechnique','Sum of sinusoids')
y = rayChan(ones(numSamples,1));
t_n = (0:numSamples-1)'/Fs;
plot(t_n,20*log10(abs(y)))
xlabel('Time (s)')
ylabel('Amplitude')

%信号经过信道(未跑通！！！filter输入参数不足？)
%过信道就是传输符号与信道冲激响应的卷积，matlab中就是conv或者用filter函数实现
SNR = 20;
% y_mod=qammod(y_add,4);%QPSK，问题：先QPSK还是先加CP？？？？%%%%%%%%%%%%%%
% y = rayChan(y_add);
y_recv = filter(rayChan,y_add);%改成conv
y_recv_1 = awgn(y_recv,SNR);
Y = fft(y_recv_1,1024);  
Y = fftshift(abs(Y));  
plot([-512:511]*fs/1024,Y.*Y)  
axis([-1000 1000 min(Y.*Y) max(Y.*Y)])  
%从y_add频域复合信号得到y_recv_f
% h = 0.5;
% SNR = 1;
% %y_recv = (h .* y_add);
% %y_recv_channel = awgn(y_recv, SNR);
% y_recv_channel = ifft(y_add);
% figure
% hold on
% plot(f4,y_add);
% plot(f4,y_recv_channel);
% legend('orig', ' through-channel');
% xlabel('Frequency/kHz');
% ylabel('Amplitude');
%y_recv_f = fft(y_recv_channel);
%y_recv_f=y_signal_f;%简化，理想条件相等

%%三、信道估计（频域）
%找到导频位置替代F4
p_rec = y_recv_f(p_f_location);
H_estimation = p_rec; %./ p_f(p_f4);%除以1

%%四、插值扩展
%分段线性插值：插值点处函数值由连接其最邻近的两侧点的线性函数预测。对超出已知点集的插值点用指定插值方法计算函数值
%H_est_interp = interp1(p_f(1:end)', H_estimation, f(1:end)', 'linear', 'extrap');
%H_est_interp为什么是列向量