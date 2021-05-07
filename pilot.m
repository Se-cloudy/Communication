matlab

%%一、发端信号y
%发送1024个子载波，2MHz
data_amplitude=randi([0 1],1,1e5);%1e5个OFDM符号
d_carrier=2e6/1024;%19531.25Hz
f=1:d_carrier:2e6
y_mux=0;
for i=1:1024
    data[i]=sin(2*pi*f[i]*t);
    y_mux=y_mux+data[i];
end

%%验证一
figure();
subplot(131);
hold on 
plot(data[1])
plot(data[2])
plot(data[3])
sublegend('sub1','sub2','sub3');

subplot(132)
plot(y_mux);
subtitle('合成信号');

subplot(133)
y0=abs(fft(y_mux));
plot(f,y0);
subtitle('spectrum');

%%二、制作导频p
%对频带进行内插，间隔为4，16，64
p_inter=4;
%p=([1:p_inter:2e6],1);
p_f_location=1:p_inter:2e6;
pilot=sin(2*pi*p_f_location*t);
pilot_mux=0;
for i=1:size(pilot)
    pilot_mux=pilot_mux+pilot(i);
end

%%验证二
figure();hold on 
plot(pilot(1)))
plot(pilot(2))
plot(pilot(3))
legend('pilot1','pilot2','pilot3');
figure();
plot(pilot_mux);
title('合成导频');
figure();
p0=abs(fft(pilot_mux));
plot(p_f_location,p0);
title('pilot spectrum');

%%三、插入导频到信号
y_add = y_mux+pilot_mux;

%%验证三
plot(abs(fft(y_add)));

%%四、送入信道（以double-flat为例，需要替换为瑞利）
h = 0.5;
SNR = 1;
y_recv = (h.*y_add);
y_recv_channel = awgn(y_recv,SNR)
figure 
hold on 
plot(y_add);
plot(y_recv_channel);
legend('orig',' through-channel');

%%五、信道估计（频域）
Y_recv = fft(y_recv_channel);
pilot_rec=Y_recv(p_f_location);
H_estimation=pilot_rec./pilot;

%%插值扩展
x = [1:250:501]
xi = [1:501];
H_est_interp =interp1(x,H_est,xi, 'spline');
