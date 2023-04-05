clc;
clear all;
close all;

N=512;%采样点数
epoch=100;%迭代次数
a1=0.1;a2=-0.8;%默认参数
step=0.05;%LMS算法步长
R=2;%滤波器阶数
h_all=zeros(2,N,epoch);%存放每次实验的a1,a2
en_all=zeros(1,N,epoch);%存放每次实验的误差
Jn_all=zeros(1,N,epoch);%100次实验的J(n)
figure;
for i=1:2
    v=sqrt(0.27)*randn(1,N);%方差为0.27，均值为0的白噪声
    x=zeros(1,N);
    x(1)=v(1);
    x(2)=-a1*x(1)+v(2);
    for j=3:N
        x(j)=-a1*x(j-1)-a2*x(j-2)+v(j);
    end
    plot(x);axis([0 N -3 3]); hold on;
end
legend('第1次生成x(n)过程','第2次生成x(n)过程');

for i=1:epoch
    v=sqrt(0.27)*randn(1,N);
    x=zeros(1,N); 
    h=[0;0];
    x(1)=v(1);
    x(2)=-a1*x(1)+v(2);
    for j=3:N
        x(j)=-a1*x(j-1)-a2*x(j-2)+v(j);
    end
    for j=3:N
        e=x(j)-h'*x(j-1:-1:j-2)';
        h=h+step*e*x(j-1:-1:j-2)';
        h_all(1,j,i)=h(1,1);
        h_all(2,j,i)=h(2,1);
        en_all(:,j,i)=e;
        Jn_all(1,j,i)=e^2;
    end
end

h_average=zeros(2,N);
E=zeros(2,N);
en_average=zeros(1,N);
Jn_average=zeros(1,N);
for i=1:N
     h_average(1,i)=sum( h_all(1,i,:))/epoch;
     E(1,i)=-a1- h_average(1,i);
     h_average(2,i)=sum(h_all(2,i,:))/epoch;
     E(2,i)=-a2-h_average(2,i);
     en_average(1,i)=sum(en_all(1,i,:))/epoch;
     Jn_average(1,i)=sum(Jn_all(1,i,:))/epoch;
end

en_fft=fft(en_average(1,:));
E1_fft=fft(E(1,:));
E2_fft=fft(E(2,:));

figure;
plot(1:N,h_average(1,:),1:N,h_average(2,:));axis([0 N-1 -0.2 1]);
title('迭代100次取平均');legend('a1平均值','a2平均值');
figure;
plot(1:N,abs(en_fft),1:N,abs(E1_fft),1:N,abs(E2_fft));
title('功率谱');axis([0 N-1 0 10]);
legend('预测误差的功率谱','a1误差的功率谱','a2误差的功率谱');
figure;
plot(1:N,Jn_average(1,:));
title('LMS实验平均误差学习曲线-预测误差平方');axis([0 N-1 -0.2 1]);