clear all;
close all;
%%OFDM中的导频
%采用了简单的均衡和线性内插
%信道是平坦假设，后续需要用瑞利替代

%%5.8:信号简化，信道简化

%%一、发端信号y
%发送1024个子载波，2MHz
fs = 1000;
T = 1/fs;             % Sampling period  
L = 1000;
t = (0:L-1)*T;

f=[10 20 30 40];
data_1=sin(2*pi*f(1)*t);
data_2=sin(2*pi*f(2)*t);
data_3=sin(2*pi*f(3)*t);
data_4=sin(2*pi*f(4)*t);
y_mux=data_1+data_2+data_3+data_4;

%%二、制作导频p
%对频带进行内插，间隔为4，16，64
p_f_location=[15 25 35];
y_pilot_1=sin(2*pi*p_f_location(1)*t);
y_pilot_2=sin(2*pi*p_f_location(2)*t);
y_pilot_3=sin(2*pi*p_f_location(3)*t);
pilot_mux=y_pilot_1+y_pilot_2+y_pilot_3;

%y_pilot=[abs(fft(y_pilot_1)),abs(fft(y_pilot_2)),abs(fft(y_pilot_3))];
y_pilot=[fft(y_pilot_1),fft(y_pilot_2),fft(y_pilot_3)];
y_spec=[abs(fft(y_pilot_1)),abs(fft(y_pilot_2)),abs(fft(y_pilot_3))];

%%验证二
figure();hold on 
plot(y_pilot_1)
plot(y_pilot_2)
plot(y_pilot_3)
legend('pilot1','pilot2','pilot3');
figure();
plot(pilot_mux);
title('合成导频');
figure();
p_spec=abs(fft(pilot_mux));
stem(p_f_location,p_spec(p_f_location));
title('pilot spectrum');
%%三、插入导频到信号
y_add = y_mux+pilot_mux;

%%验证三
%plot(abs(fft(y_add)));
figure();hold on
plot(y_mux);
plot(pilot_mux);
title('signal add pilot');

figure();hold on
% plot(abs(fft(y_mux)),'-b');
% plot(abs(fft(pilot_mux)),'r');
stem(f,y_spec(f),'-b');
stem(p_f_location,p_spec(p_f_location),'r');
title('signal add pilot_spectrum');

%%四、送入信道（以double-flat为例，需要替换为瑞利）
h = 0.5;
SNR = 1;
y_recv = (h.*y_add);
y_recv_channel = awgn(y_recv,SNR);
figure 
hold on 
plot(y_add);
plot(y_recv_channel);
legend('orig',' through-channel');

%%五、信道估计（频域）
Y_recv = fft(y_recv_channel);
pilot_rec=Y_recv(p_f_location);
H_estimation=pilot_rec./y_pilot(p_f_location);

%%六、插值扩展
%分段线性插值：插值点处函数值由连接其最邻近的两侧点的线性函数预测。对超出已知点集的插值点用指定插值方法计算函数值
H_est_interp =interp1(p_f_location(1:end)',H_estimation,f(1:end)','linear','extrap');
%H_est_interp为什么是列向量

%%七、均衡补偿
%题目没有要求，但是一般都会做
%采用单抽头均衡，直接除去信道系数
%Y_data=Y_recv;
% Y_equ=Y_data./H_est_interp;
%先不做均衡
%%验证七：
figure;
hold on
plot(f,Y_recv(f),'r');
plot(f,y_mux(f),'b')
legend('after','before')
title('after inter');
% 
% %%八、误码率计算
% [error_num,err]=biterr(Y_recv,y_mux);
% 
% %%九、结果与绘图
% figure();
% plot(SNR,err);
% title('biterror after piloting');
