%�ı�signal-generation�е�ǰ׺λ��
clear;
clc;
clf;
%%һ���ź�����

%�ɵ�����
B = 2e4; %�����Ϊ2M���ȷ���һ���
CP = 8; %С�����ز���������Ϊ106
f_inter = 1700;
%1.1 ������������Ϣ����
B_c = B + CP * f_inter;%ǰ׺��չ�˵Ĵ���
Fs = 2 * B_c; %����Ƶ��2B
f_0 = [f_inter:f_inter:B];%�������ز�Ƶ��λ��
f = [f_inter: f_inter: B_c]; %�������ز�Ƶ��λ��
N_carrier = length(f_0); %�������ز�����length(f)
t = 0:1 / Fs:10 - 1 / Fs; % ��Ϊ100, 0-9.98s һ��1e5,10*fs=1e5
a_0 = 10 * rand(1, N_carrier); %CPǰ����Ϣ���У�����Ϊ10
x=a_0(end-CP+1:end);%1*3
a = [a_0(end-CP+1:end), a_0];%�����CP�ز�����Ϣ���У���ȷ
%a = [a_0, a_0(N_carrier - 2 * CP + 1:end)]; %�����CP����Ϣ����,106��CP

%1.2 �ź�
y_signal_t = 0; %���ϵ�1024�����ز�֮�ͣ�ʱ���ز�

for i = 1:length(f)
    y_signal_t = y_signal_t + a(i) * sin(2 * pi * f(i) * t);
end

N = length(y_signal_t); % N
f3 = (N / 2:N - 1) * Fs / N - Fs / 2; %Ƶ�ʷ�Χ0-BHz
f4 = f3 / 1000;
y2 = abs(fftshift(fft(y_signal_t)));
y_signal_f = 2 * y2(N / 2:N - 1)/N; %��ֵ�����õ���ʵ��ֵ

%%
%y_signal_f����f4��ͼ����ȷ��Ϣ��ֵ��
%�����ر�СӦ��������Ƶ����������
%%
%1.3 ��Ƶ
p_f_location = [2.5*f_inter:4*f_inter:B_c];%�Ժ���ǰ׺���������ز��ӵ�Ƶ��λ�ò�Ӧ���ź��ص�
p_t = 0; %���ϵ�1024+CP�����ز�֮�ͣ�ʱ���ز�

for i = 1:length(p_f_location)
    p_t = p_t + sin(2 * pi * p_f_location(i) * t);
end

N_p = length(p_t); % N
%p_f3 = (N_p / 2:N_p - 1) * Fs / N_p - Fs / 2; %Ƶ�ʷ�Χ0Hz-B_cHz
p2 = abs(fftshift(fft(p_t)));
p_f = 2 * p2(N_p / 2:N_p - 1) / N_p; %��ֵ�����õ���ʵ��ֵ
%p_f4 = p_f3 / 1000;

%%test
p_f_location(1)
p_f(p_f_location(1))
%%
%f4-p_f4=0;

%%�ź��뵼Ƶ���ɻ�ͼ
figure();
subplot(121);
plot(f4, y_signal_f);
title('��Ϣ�ź�');
xlabel('Frequency/kHz');
ylabel('Amplitude');
subplot(122);
plot(f4, p_f);%f4Ϊȫ��Ƶ�㷶Χ����Ҫ�ҵ���Ƶλ��
%plot(p_f_location,p_f(p_f_location));
title('��Ƶ');
xlabel('Frequency/kHz');
ylabel('Amplitude');

figure(); hold on
plot(f4, y_signal_f);
plot(f4, p_f);%p_f4=f4�����ˣ����Կ���ͨ��f4
legend('signal', 'pilot');
xlabel('Frequency/kHz');
ylabel('Amplitude');

y_add = y_signal_f + p_f;
%y_add����ȡpilot
%f4����������Ƶ����ᣬ���źž����ź�
%��Ҫ�ҵ���Ƶλ�ã���add��ȡ��
%f4-p_f!=0;
figure()
plot(f4,y_add);
title('test:add');
xlabel('Frequency/kHz');
ylabel('Amplitude');

%%���������ŵ�����double-flatΪ����
%ʹ�����Ҳ��ܺͼ������������ŵ���
%����
% Fd = 1;                       % Maximum Doppler shift (Hz)
% numSamples = 1000;              % Number of samples
% rayChan = comm.RayleighChannel('SampleRate',Fs, ...
% 'MaximumDopplerShift',Fd,'FadingTechnique','Sum of sinusoids')
%�ྶ
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

%�źž����ŵ�(δ��ͨ������filter����������㣿)
%���ŵ����Ǵ���������ŵ��弤��Ӧ�ľ����matlab�о���conv������filter����ʵ��
SNR = 20;
% y_mod=qammod(y_add,4);%QPSK�����⣺��QPSK�����ȼ�CP��������%%%%%%%%%%%%%%
% y = rayChan(y_add);
y_recv = filter(rayChan,y_add);%�ĳ�conv
y_recv_1 = awgn(y_recv,SNR);
Y = fft(y_recv_1,1024);  
Y = fftshift(abs(Y));  
plot([-512:511]*fs/1024,Y.*Y)  
axis([-1000 1000 min(Y.*Y) max(Y.*Y)])  
%��y_addƵ�򸴺��źŵõ�y_recv_f
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
%y_recv_f=y_signal_f;%�򻯣������������

%%�����ŵ����ƣ�Ƶ��
%�ҵ���Ƶλ�����F4
p_rec = y_recv_f(p_f_location);
H_estimation = p_rec; %./ p_f(p_f4);%����1

%%�ġ���ֵ��չ
%�ֶ����Բ�ֵ����ֵ�㴦����ֵ�����������ڽ������������Ժ���Ԥ�⡣�Գ�����֪�㼯�Ĳ�ֵ����ָ����ֵ�������㺯��ֵ
%H_est_interp = interp1(p_f(1:end)', H_estimation, f(1:end)', 'linear', 'extrap');
%H_est_interpΪʲô��������