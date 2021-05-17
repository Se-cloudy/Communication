clear all;
close all;
%-------------------参数设定---------------------%
carrier_count = 200; %每个ofdm符号包含mqam符号个数,1024
ofdm_symbol_count = 100;%ofdm符号个数,1e5
M=64;%mqam的进制数
CP_length = 128;%前缀码
CS_length = 20;%后缀码
%------------------基本步骤----------------------%
bit_signal=bit_Signal_generation(carrier_count,ofdm_symbol_count,M);
%2进制信号生成
bit_moded1 = qammod(bit_signal,M,'InputType','bit');
%星座映射
bit_moded2 = reshape(bit_moded1,carrier_count,ofdm_symbol_count);
%串并转换

%%这里应该可以加导频吧

signal_time=ifft(bit_moded2,2^nextpow2(length(bit_moded2)));
%ifft调制
signal_time_C=add_prefix_suffix_code(signal_time,CP_length,CS_length);
%加前缀后缀码
signal_time_C_W=awgn(signal_time_C,55);
%加性高斯白噪声通道
signal_time_D=signal_time_C_W(1+CP_length:end-CS_length,:);
%去前缀码后缀码
signal_time_E=fft(signal_time_D,2^nextpow2(length(signal_time_D)));
%fft解调
signal_time_F=signal_time_E(1:carrier_count,:);
%解调后下采样
draw(bit_moded1,signal_time_C,signal_time,signal_time_C_W,signal_time_F);
%绘图
error_rate=error_rate1(signal_time_F,bit_signal,M);
%求误码率
%---------------------自己编写的函数 ，包括了绘图函数-------------------------%
function bit_signal=bit_Signal_generation(carrier_count,ofdm_symbol_count,M)
bit_per_symbol=log2(M);
bit_length = carrier_count*ofdm_symbol_count*bit_per_symbol;
bit_signal = round(rand(1,bit_length))'; % 列向量
end
function signal_time_C=add_prefix_suffix_code(signal_time,CP_length,CS_length)
signal_time_C = [signal_time(end-CP_length+1:end,:);signal_time];
signal_time_C = [signal_time_C; signal_time_C(1:CS_length,:)];
end
function draw(bit_moded1,signal_time_C,signal_time,signal_time_C_W,signal_time_F)
figure
subplot(3,2,1)
scatter(real(bit_moded1),imag(bit_moded1),'*r');
title('调制后的星座图');
grid on;
subplot(3,2,2)
scatter(real(reshape(signal_time_F,1,[])),imag(reshape(signal_time_F,1,[])),'.');
title('接收信号的星座图snr=55');
grid on;
subplot(3,2,3)
plot(abs(signal_time_C_W(:,1)),'r');
title('单个OFDM符号加前缀后缀码噪声下的信号');
subplot(3,2,4)
plot(abs(signal_time_C(:,1)),'y');
title('单个OFDM符号加前缀后缀码的信号');
subplot(3,2,5)
plot(abs(signal_time(:,1)),'g');
title('原始单个OFDM符号的信号');
xlabel('Time');
ylabel('Amplitude');
subplot(3,2,6)
NFFT = 2^nextpow2(length(signal_time(:,1)));           
Y1 = fft(mean(signal_time),NFFT)/NFFT;
f = linspace(0,1,NFFT/2+1);
plot(f,2*abs(Y1(1:NFFT/2+1))) ;
hold on;
NFFT2 = 2^nextpow2(length(signal_time_C(:,1)));           
Y2 = fft(mean(signal_time_C),NFFT2)/NFFT2;
f2 = linspace(0,1,NFFT2/2+1);
plot(f2,2*abs(Y2(1:NFFT2/2+1)));
legend('噪声下频谱','无噪声下频谱');
end
function error_rate=error_rate1(signal_time_F,bit_signal,M)
bit_demod_sig = reshape(qamdemod(signal_time_F,M,'OutputType','bit'),[],1);
error_bit = sum(bit_demod_sig~=bit_signal);
error_rate = error_bit/length(bit_signal);
end