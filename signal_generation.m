close all;
clear all;
%%一、信号生成

%可调参数
B = 2e4; %带宽改为2M，先仿少一点的
CP = 3; %小于子载波个数，改为106

%1.1 参数设置与消息序列
Fs = 2 * B; %采样频率2B
f = [0:1900:B]; %子载波频域间隔1900
N_carrier = length(f); %子载波个数length(f)
t = 0:1 / Fs:100 - 1 / Fs; % 0-9.98s 一共1e5,10*fs=1e5
a_0 = 10 * rand(1, N_carrier - CP); %CP前的消息序列，幅度为10
a = [a_0, a_0(N_carrier - 2 * CP + 1:end)]; %添加了CP的消息序列,106个CP

%1.2 信号
y_signal_t = 0; %复合的1024个子载波之和，时域载波

for i = 1:length(f)
    y_signal_t = y_signal_t + a(i) * sin(2 * pi * f(i) * t);
end

N = length(y_signal_t); % N
f3 = (N / 2:N - 1) * Fs / N - Fs / 2; %频率范围0-BHz
f4 = f3 / 1000;
y2 = abs(fftshift(fft(y_signal_t)));
y_signal_f = 2 * y2(N / 2:N - 1) / N; %幅值修正得到真实幅值

%1.3 导频
p_f = [0:64:B];
p_t = 0; %复合的1024个子载波之和，时域载波

for i = 1:length(p_f)
    p_t = p_t + sin(2 * pi * p_f(i) * t);
end

N_p = length(p_t); % N
p_f3 = (N_p / 2:N_p - 1) * Fs / N_p - Fs / 2; %频率范围0Hz-BHz
p2 = abs(fftshift(fft(p_t)));
p_f = 2 * p2(N_p / 2:N_p - 1) / N_p; %幅值修正得到真实幅值
p_f4 = p_f3 / 1000;

%%信号与导频生成绘图
figure();
subplot(121);
plot(f4, y_signal_f);
title('消息信号');
xlabel('Frequency/kHz');
ylabel('Amplitude');
subplot(122);
plot(p_f4, p_f);
title('导频');
xlabel('Frequency/kHz');
ylabel('Amplitude');

figure(); hold on
plot(f4, y_signal_f);
plot(p_f4, p_f);
legend('signal', 'pilot');
xlabel('Frequency/kHz');
ylabel('Amplitude');