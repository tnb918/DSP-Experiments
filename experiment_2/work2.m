clc;
clear all;
close all;

N=2048;%采样点数
R=250;%滤波器阶数
step=0.00001;%迭代步长
delay=30;%延迟D
h=zeros(R,N);
n=1:N;
x1n=sin(0.05*pi*n+2*pi*rand(1));
en=randn(1,N);
x2n=zeros(1,N);
x2n(1)=en(1);
x2n(2)=en(2)+2*en(1);
for i=3:N
    x2n(i)=en(i)+2*en(i-1)+en(i-2);
end

x=x1n+x2n;
x_delay=zeros(1,N);
for i=delay+1:N
    x_delay(i)=x(i-delay);
end

y=zeros(1,N);
e=zeros(1,N);
for i=1:R-1
    y(i)=h(1:i)*x_delay(i:-1:1)';
    e(i)=x(i)-y(i);
    h(1:i)=h(1:i)+step*e(i)*x_delay(i:-1:1);
end

for i=R:N
    y(i)=h(:,i-1)'*x_delay(i:-1:i-R+1)';
    e(i)=x(i)-y(i);
    h(:,i)=h(:,i-1)+step*e(i)*x_delay(i:-1:i-R+1)';
end

figure;
m=0:1:10;
rx1=0.5*cos(0.05*pi*m);
rx2=1*(m==-2)+4*(m==-1)+6*(m==0)+1*(m==2)+4*(m==1);
stem(rx1);hold on;stem(rx2);
title('自相关函数');legend('Rx1','Rx2');
figure;
subplot(4,1,1);plot(x1n);xlabel('n');ylabel('x1(n)的值');axis([0 N -1 1]);
subplot(4,1,2);plot(x2n);xlabel('n');ylabel('x2(n)的值');axis([0 N -10 10]);
subplot(4,1,3);plot(x);xlabel('n');ylabel('x(n)的值');axis([0 N -10 10]);
subplot(4,1,4);plot(x_delay);xlabel('n');ylabel('x(n)_delay的值');axis([0 N -10 10]);
figure;
subplot(2,1,1);plot(y);title('输出信号y(n)');axis([1 N -1 1]);
subplot(2,1,2);plot(x1n);title('窄带信号x1(n)');axis([1 N -1 1]);
figure;
subplot(2,1,1);plot(e);title('误差信号error(n)');axis([1 N -10 10]);
subplot(2,1,2);plot(x2n);title('宽带信号x2(n)');axis([1 N -10 10]);
