clear all
s=rng;
% close all
SNR_test = -5:5:15;
T_interA=1;%A导频符号在时域上的间隔
T_interC=1;%C导频符号在时域上的间隔
F_inter=4;%C导频符号在频域上的间隔
D_shift=1;
Nfft=1024;%子载波为1024个
N=1e2;%帧数
data0=randi(2,Nfft*N,1)*2-3;
rng(s);%保证随机数种子相等
C=mod(Nfft-1,F_inter);%D图案剩余位置
tau1=1:1:30;
tau2=1:1:30;
tau3=1:T_interA:30*T_interA;
tau4=1:1:30;
tau5=1:T_interC:30*T_interC;
tau6=1:F_inter:30*F_inter;

sample_rate=(1e6);%
L=length(tau1);
[T1,T2]=meshgrid(tau1,tau2);%可视化的网格
[T3,T4]=meshgrid(tau3,tau4);%可视化的网格
[T5,T6]=meshgrid(tau5,tau6);%可视化的网格


Pilot=sqrt(2)/2+sqrt(2)/2*1i;%导频
FdataA=reshape(data0,Nfft,[]);%时频矩阵
Ncp=20;%循环前缀

% data_std=ones(N*Nfft,1)*Pilot;%用来计算标准矩阵的数据
% data_std=reshape(data_std,Nfft,[]);

% %图案A
% FdataA=data0;
% FdataA(:,1:T_inter:end)=Pilot;
% %图案C
% FdataC=FdataA;
% FdataC(1:F_inter:end,1:T_inter:end)=Pilot;%导频设置为1+1i
% FdataA=FdataC;

% figure
% stem3(T1,T2,real(FdataA(1:L,1:L)))
% xlabel('time')
% ylabel('frequency')
% 
% figure
% stem3(T1,T2,real(FdataC(1:L,1:L)))
% xlabel('time')
% ylabel('frequency')

%时域信号
TdataA=ifft(FdataA)*sqrt(1024);%转化为时间信号
% TdataC=ifft(FdataC);%转化为时间信号

% TdataS=ifft(data_std);%标准数据

TdataA=[TdataA(Nfft-Ncp+1:end,:);TdataA];%把ifft的末尾N_cp个数补充到最前面
% TdataC=[TdataC(Nfft-Ncp+1:end,:);TdataC];%把ifft的末尾N_cp个数补充到最前面
% TdataS=[TdataS(Nfft-Ncp+1:end,:);TdataS];%把ifft的末尾N_cp个数补充到最前面

%% 并串转换
TdataA=reshape(TdataA,[],1);%由于传输需要
% TdataC=reshape(TdataC,[],1);%由于传输需要

% TdataS=reshape(TdataS,[],1);%由于传输需要



%%信道模型
RayleighSinglePath = comm.RayleighChannel(...
    'SampleRate',sample_rate, ...                  
    'MaximumDopplerShift',1, ...
    'DopplerSpectrum',doppler('Jakes'));
    %'Visualization','Impulse and frequency responses');

%Rayleigh Multi Path
% RayleighMultiPath = comm.RayleighChannel(...
%     'SampleRate',sample_rate, ...                  
%     'PathDelays', [0 10]*1/sample_rate, ...                
%     'AveragePathGains',[0 -4], ...                 %dB
%     'NormalizePathGains',true, ...
%     'MaximumDopplerShift',100, ...
%     'Seed',22, ...
%     'DopplerSpectrum',doppler('Jakes'));

 RayleighMultiPath =comm.RayleighChannel(...
    'SampleRate',sample_rate, ...
    'PathDelays',[0 10 ]/sample_rate, ...
    'AveragePathGains',[0 -4 ], ...
    'NormalizePathGains',true, ...
    'MaximumDopplerShift',100, ...
     'DopplerSpectrum',doppler('Jakes'), ...
    'RandomStream','mt19937ar with seed', ...
    'Seed',22, ...
    'PathGainsOutputPort',true);

%'Visualization','Impulse and frequency responses');
%接收端
 [TdataA_r,h]=RayleighMultiPath(TdataA);%经过信道的接收信号
%  TdataC_re=RayleighMultiPath(TdataC);%经过信道的接收信号
 for SNR =-5:5:15
     jj=SNR/5 + 2;
 S = RandStream('mt19937ar','Seed',5489);
% TdataA_re =TdataA_r;
TdataA_re=awgn(TdataA_r,SNR,'measured',S);%经过信道的接收信号
% TdataC_re=awgn(TdataC,0,'measured');%经过信道的接收信号
 
% TdataS_re=RayleighMultiPath(TdataS);%经过信道的接收信号
 
 
 %% 串并转换
 TdataA_re=reshape(TdataA_re,Nfft+Ncp,[]);
 h1=h(:,1);
 h2=h(:,2);
%  h3=h(:,3);
 h1=reshape(h1,Nfft+Ncp,[]);
 h2=reshape(h2,Nfft+Ncp,[]);
%  h3=reshape(h3,Nfft+Ncp,[]);
 
 
%  TdataA_r=reshape(TdataA_r,Nfft+Ncp,[]);
 
%  TdataC_re=reshape(TdataC_re,Nfft+Ncp,[]);
 
%  TdataS_re=reshape(TdataS_re,Nfft+Ncp,[]);
 
 
%% 去掉保护间隔、循环前缀
 TdataA_re=TdataA_re(Ncp+1:end,:);
 h1=h1(Ncp+1:end,:);
 h2=h2(Ncp+1:end,:);
%  h3=h3(Ncp+1:end,:);
%  TdataA_r=TdataA_r(Ncp+1:end,:);
 
%  TdataC_re=TdataC_re(Ncp+1:end,:);
%  TdataS_re=TdataS_re(Ncp+1:end,:);

 
%% FFT,转化为频域
 FdataA_re=fft(TdataA_re)/sqrt(1024);
%  FdataA_r=fft(TdataA_r)/sqrt(1024);
 
%  FdataC_re=fft(TdataC_re);
 
%  FdataS_re=fft(TdataS_re);
 
%%准确信道
%  HA=FdataA_re./FdataA;
 K2=0:1:Nfft-1;
 K2=repmat(K2,N,1);
 K2=K2';
%  HA=h1+exp((-2*pi*1i)*K2*10/Nfft).*h2+exp((-2*pi*1i)*K2*20/Nfft).*h3;
 HA=h1+exp((-2*pi*1i)*K2*10/Nfft).*h2;
 
%  HC=FdataC_re./FdataC;
 
%% 信道估计
 PilotA_re=FdataA_re(:,1:T_interA:end);
 
 H_estA=PilotA_re./FdataA(:,1:T_interA:end);
 
 PilotC_re=FdataA_re(1:F_inter:end,1:T_interC:end);
 H_estC=PilotC_re./FdataA(1:F_inter:end,1:T_interC:end);
 
 H_estD=H_estC;%初始化
 
 PilotD_re=PilotC_re;
    for j=1:T_interC:N
            if mod((j-1)/T_interC+1,C+1)==0
            PilotD_re(:,((j-1)/T_interC+1))=FdataA_re(1+C:F_inter:Nfft,j);
            H_estD(:,((j-1)/T_interC+1))=FdataA_re(1+C:F_inter:Nfft,j)./FdataA(1+C:F_inter:Nfft,j);
            
            else
            PilotD_re(:,round((j-1)/T_interC+1))=FdataA_re(mod((j-1)/T_interC+1,C+1):F_inter:Nfft,j);
            H_estD(:,((j-1)/T_interC+1))=FdataA_re(mod((j-1)/T_interC+1,C+1):F_inter:Nfft,j)./FdataA(mod((j-1)/T_interC+1,C+1):F_inter:Nfft,j);%信道估计
            end
    end
 
%  图案Ａ内插%分段线性插值：插值点处函数值由连接其最邻近的两侧点的线性函数预测。对超出已知点集的插值点用指定插值方法计算函数值
loc_A1=1:T_interA:N;%A图案的导频位置
loc_A2=1:N;%A图案的全部位置
H_intA=interp1(loc_A1.',H_estA.',loc_A2.','linear','extrap');
H_intA=H_intA.';

%图案C内插
%先在频域内插
loc_CF1=1:F_inter:Nfft;%C图案的导频在频域
loc_CF2=1:Nfft;%A图案的频域全部位置
H_intCF=interp1(loc_CF1,H_estC,loc_CF2,'linear','extrap');
%再在时域内插
loc_CT1=1:T_interC:N;%C图案的导频在频域
loc_CT2=1:N;%A图案的频域全部位置
H_intC=interp1(loc_CT1.',H_intCF.',loc_CT2.','linear','extrap');
H_intC=H_intC.';

%图案D内插
%先在频域内插
for k=1:T_interC:N
    if mod((k-1)/T_interC+1,C+1)==0
            loc_DF1=C+1:F_inter:Nfft;%D图案的导频在频域位置
    else
            loc_DF1= mod((k-1)/T_interC+1,C+1):F_inter:Nfft;%D图案的导频在频域位置
    end
% C=mod(Nfft-1,F_inter);%剩余位置

loc_DF2=1:Nfft;%A图案的频域全部位置
H_intDF(:,(k-1)/T_interC+1)=interp1(loc_DF1,H_estD(:,(k-1)/T_interC+1),loc_DF2,'linear','extrap');
end
%再在时域内插
loc_DT1=1:T_interC:N;%C图案的导频在频域
loc_DT2=1:N;%A图案的频域全部位置
H_intD=interp1(loc_DT1.',H_intDF.',loc_DT2.','linear','extrap');
H_intD=H_intD.';

%计算误差
ERRA=abs((H_intA-HA)./HA);
ERRC=abs((H_intC-HA)./HA);
ERRD=abs((H_intD-HA)./HA);

MSEA(jj)=sum(sum(ERRA.^2))/(N*Nfft);
MSEC(jj)=sum(sum(ERRC.^2))/(N*Nfft);
MSED(jj)=sum(sum(ERRD.^2))/(N*Nfft);
 end
% [MSEA MSEC  MSED]
% display(MSEA)
% display(MSEC)
% display(MSED)

% 
%可视化
% figure
% stem3(T3,T4,real(H_estA(1:L,1:L))+0.01)
% hold on
% stem3(T1,T2,real(H_intA(1:L,1:L)))
% hold on
% stem3(T1,T2,real(HA(1:L,1:L)))
% 
% xlabel('time')
% ylabel('frequency')
% legend('Eastimation','interpolation','real')
%  axis([0 13 0 30 -2.5 2.5])
% 
% 
% figure
% stem3(T5,T6,real(H_estC(1:L,1:L))+0.01)
% hold on
% stem3(T1,T2,real(H_intC(1:L,1:L)))
% % hold on
% % stem3(T1,T2,real(HA(1:L,1:L)))
% 
% xlabel('time')
% ylabel('frequency')
% legend('Eastimation','interpolation')
% axis([0 13 0 30 -2.5 2.5])
% 
% figure
% stem3(T1,T2,real(H_intD(1:L,1:L)))
% hold on
% stem3(T1,T2,real(HA(1:L,1:L)))
% xlabel('time')
% ylabel('frequency')
% legend('interpolation','real')
% axis([0 13 0 30 -2.5 2.5])

figure
plot(SNR_test,10*log10(MSEA))
hold on 
plot(SNR_test,10*log10(MSEC))
hold on
plot(SNR_test,10*log10(MSED))
legend('图案A','图案C','图案D')
xlabel('SNR/dB')
ylabel('MSE 10*log')
% DFT内插还原法
% H_DFTA1=ifft(H_intA);
% H_DFTA2=H_DFTA1(1:20,:);
% H_DFTA3=fft(H_DFTA2,1024);
% ERRA_DFT=abs((H_DFTA3-HA)./HA);
% MSE_DFT=sum(sum(ERRA_DFT.^2))/(N*Nfft)