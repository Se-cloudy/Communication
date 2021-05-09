close all;
clear all;
%测试频率位置，没有添加了CP的消息序列

B=2e4;%带宽2M
p_inter=64;%导频间隔4，16，64

Fs=2*B;%采样频率2B
f=[0:1900:B];
t = 0:1/Fs:100-1/Fs; % 0-9.98s 一共1e5,10*fs=1e5
y_carrier_t=0;%复合的1024个子载波之和，时域载波
for i=1:length(f)
    y_carrier_t=y_carrier_t+sin(2*pi*f(i)*t);
end
N=length(y_carrier_t);% N
figure();hold on
f3=(N/2:N-1)*Fs/N-Fs/2 ;%频率范围0Hz-25Hz
y2=abs(fftshift(fft(y_carrier_t)));
y_signal_f=2*y2(N/2:N-1)/N;%幅值修正得到真实幅值
f4=f3/1000;
plot(f4,y_signal_f);
title('信号');
xlabel('Frequency/kHz'); 
ylabel('Amplitude');

p_f=[0:64:B];
p_t=0;%复合的1024个子载波之和，时域载波
for i=1:length(p_f)
    p_t=p_t+sin(2*pi*p_f(i)*t);
end
N_p=length(p_t);% N
p_f3=(N_p/2:N_p-1)*Fs/N_p-Fs/2 ;%频率范围0Hz-25Hz
p2=abs(fftshift(fft(p_t)));
p_f=2*p2(N_p/2:N_p-1)/N_p;%幅值修正得到真实幅值
p_f4=p_f3/1000;
plot(p_f4,p_f);
title('导频');
xlabel('Frequency/kHz'); 
ylabel('Amplitude');