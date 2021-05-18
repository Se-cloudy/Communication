clear all
s=rng;
% close all
SNR_test = -5:5:15;
T_interA=1;%A��Ƶ������ʱ���ϵļ��
T_interC=1;%C��Ƶ������ʱ���ϵļ��
F_inter=4;%C��Ƶ������Ƶ���ϵļ��
D_shift=1;
Nfft=1024;%���ز�Ϊ1024��
N=1e2;%֡��
data0=randi(2,Nfft*N,1)*2-3;
rng(s);%��֤������������
C=mod(Nfft-1,F_inter);%Dͼ��ʣ��λ��
tau1=1:1:30;
tau2=1:1:30;
tau3=1:T_interA:30*T_interA;
tau4=1:1:30;
tau5=1:T_interC:30*T_interC;
tau6=1:F_inter:30*F_inter;

sample_rate=(1e6);%
L=length(tau1);
[T1,T2]=meshgrid(tau1,tau2);%���ӻ�������
[T3,T4]=meshgrid(tau3,tau4);%���ӻ�������
[T5,T6]=meshgrid(tau5,tau6);%���ӻ�������


Pilot=sqrt(2)/2+sqrt(2)/2*1i;%��Ƶ
FdataA=reshape(data0,Nfft,[]);%ʱƵ����
Ncp=20;%ѭ��ǰ׺

% data_std=ones(N*Nfft,1)*Pilot;%���������׼���������
% data_std=reshape(data_std,Nfft,[]);

% %ͼ��A
% FdataA=data0;
% FdataA(:,1:T_inter:end)=Pilot;
% %ͼ��C
% FdataC=FdataA;
% FdataC(1:F_inter:end,1:T_inter:end)=Pilot;%��Ƶ����Ϊ1+1i
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

%ʱ���ź�
TdataA=ifft(FdataA)*sqrt(1024);%ת��Ϊʱ���ź�
% TdataC=ifft(FdataC);%ת��Ϊʱ���ź�

% TdataS=ifft(data_std);%��׼����

TdataA=[TdataA(Nfft-Ncp+1:end,:);TdataA];%��ifft��ĩβN_cp�������䵽��ǰ��
% TdataC=[TdataC(Nfft-Ncp+1:end,:);TdataC];%��ifft��ĩβN_cp�������䵽��ǰ��
% TdataS=[TdataS(Nfft-Ncp+1:end,:);TdataS];%��ifft��ĩβN_cp�������䵽��ǰ��

%% ����ת��
TdataA=reshape(TdataA,[],1);%���ڴ�����Ҫ
% TdataC=reshape(TdataC,[],1);%���ڴ�����Ҫ

% TdataS=reshape(TdataS,[],1);%���ڴ�����Ҫ



%%�ŵ�ģ��
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
%���ն�
 [TdataA_r,h]=RayleighMultiPath(TdataA);%�����ŵ��Ľ����ź�
%  TdataC_re=RayleighMultiPath(TdataC);%�����ŵ��Ľ����ź�
 for SNR =-5:5:15
     jj=SNR/5 + 2;
 S = RandStream('mt19937ar','Seed',5489);
% TdataA_re =TdataA_r;
TdataA_re=awgn(TdataA_r,SNR,'measured',S);%�����ŵ��Ľ����ź�
% TdataC_re=awgn(TdataC,0,'measured');%�����ŵ��Ľ����ź�
 
% TdataS_re=RayleighMultiPath(TdataS);%�����ŵ��Ľ����ź�
 
 
 %% ����ת��
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
 
 
%% ȥ�����������ѭ��ǰ׺
 TdataA_re=TdataA_re(Ncp+1:end,:);
 h1=h1(Ncp+1:end,:);
 h2=h2(Ncp+1:end,:);
%  h3=h3(Ncp+1:end,:);
%  TdataA_r=TdataA_r(Ncp+1:end,:);
 
%  TdataC_re=TdataC_re(Ncp+1:end,:);
%  TdataS_re=TdataS_re(Ncp+1:end,:);

 
%% FFT,ת��ΪƵ��
 FdataA_re=fft(TdataA_re)/sqrt(1024);
%  FdataA_r=fft(TdataA_r)/sqrt(1024);
 
%  FdataC_re=fft(TdataC_re);
 
%  FdataS_re=fft(TdataS_re);
 
%%׼ȷ�ŵ�
%  HA=FdataA_re./FdataA;
 K2=0:1:Nfft-1;
 K2=repmat(K2,N,1);
 K2=K2';
%  HA=h1+exp((-2*pi*1i)*K2*10/Nfft).*h2+exp((-2*pi*1i)*K2*20/Nfft).*h3;
 HA=h1+exp((-2*pi*1i)*K2*10/Nfft).*h2;
 
%  HC=FdataC_re./FdataC;
 
%% �ŵ�����
 PilotA_re=FdataA_re(:,1:T_interA:end);
 
 H_estA=PilotA_re./FdataA(:,1:T_interA:end);
 
 PilotC_re=FdataA_re(1:F_inter:end,1:T_interC:end);
 H_estC=PilotC_re./FdataA(1:F_inter:end,1:T_interC:end);
 
 H_estD=H_estC;%��ʼ��
 
 PilotD_re=PilotC_re;
    for j=1:T_interC:N
            if mod((j-1)/T_interC+1,C+1)==0
            PilotD_re(:,((j-1)/T_interC+1))=FdataA_re(1+C:F_inter:Nfft,j);
            H_estD(:,((j-1)/T_interC+1))=FdataA_re(1+C:F_inter:Nfft,j)./FdataA(1+C:F_inter:Nfft,j);
            
            else
            PilotD_re(:,round((j-1)/T_interC+1))=FdataA_re(mod((j-1)/T_interC+1,C+1):F_inter:Nfft,j);
            H_estD(:,((j-1)/T_interC+1))=FdataA_re(mod((j-1)/T_interC+1,C+1):F_inter:Nfft,j)./FdataA(mod((j-1)/T_interC+1,C+1):F_inter:Nfft,j);%�ŵ�����
            end
    end
 
%  ͼ�����ڲ�%�ֶ����Բ�ֵ����ֵ�㴦����ֵ�����������ڽ������������Ժ���Ԥ�⡣�Գ�����֪�㼯�Ĳ�ֵ����ָ����ֵ�������㺯��ֵ
loc_A1=1:T_interA:N;%Aͼ���ĵ�Ƶλ��
loc_A2=1:N;%Aͼ����ȫ��λ��
H_intA=interp1(loc_A1.',H_estA.',loc_A2.','linear','extrap');
H_intA=H_intA.';

%ͼ��C�ڲ�
%����Ƶ���ڲ�
loc_CF1=1:F_inter:Nfft;%Cͼ���ĵ�Ƶ��Ƶ��
loc_CF2=1:Nfft;%Aͼ����Ƶ��ȫ��λ��
H_intCF=interp1(loc_CF1,H_estC,loc_CF2,'linear','extrap');
%����ʱ���ڲ�
loc_CT1=1:T_interC:N;%Cͼ���ĵ�Ƶ��Ƶ��
loc_CT2=1:N;%Aͼ����Ƶ��ȫ��λ��
H_intC=interp1(loc_CT1.',H_intCF.',loc_CT2.','linear','extrap');
H_intC=H_intC.';

%ͼ��D�ڲ�
%����Ƶ���ڲ�
for k=1:T_interC:N
    if mod((k-1)/T_interC+1,C+1)==0
            loc_DF1=C+1:F_inter:Nfft;%Dͼ���ĵ�Ƶ��Ƶ��λ��
    else
            loc_DF1= mod((k-1)/T_interC+1,C+1):F_inter:Nfft;%Dͼ���ĵ�Ƶ��Ƶ��λ��
    end
% C=mod(Nfft-1,F_inter);%ʣ��λ��

loc_DF2=1:Nfft;%Aͼ����Ƶ��ȫ��λ��
H_intDF(:,(k-1)/T_interC+1)=interp1(loc_DF1,H_estD(:,(k-1)/T_interC+1),loc_DF2,'linear','extrap');
end
%����ʱ���ڲ�
loc_DT1=1:T_interC:N;%Cͼ���ĵ�Ƶ��Ƶ��
loc_DT2=1:N;%Aͼ����Ƶ��ȫ��λ��
H_intD=interp1(loc_DT1.',H_intDF.',loc_DT2.','linear','extrap');
H_intD=H_intD.';

%�������
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
%���ӻ�
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
legend('ͼ��A','ͼ��C','ͼ��D')
xlabel('SNR/dB')
ylabel('MSE 10*log')
% DFT�ڲ廹ԭ��
% H_DFTA1=ifft(H_intA);
% H_DFTA2=H_DFTA1(1:20,:);
% H_DFTA3=fft(H_DFTA2,1024);
% ERRA_DFT=abs((H_DFTA3-HA)./HA);
% MSE_DFT=sum(sum(ERRA_DFT.^2))/(N*Nfft)