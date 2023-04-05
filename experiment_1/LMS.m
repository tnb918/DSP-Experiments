clc;
close all;
clear all;

%%%%%%%%%%%%%%%%%%%%% 误差性能曲面和误差性能曲面等值曲线 %%%%%%%%%%%%%%%%%%%%
[h0,h1]=meshgrid(-2:0.1:4,-4:0.1:2);
v=0:0.1:1.5;%设置等高线的固定值
J=0.55+h0.*h0+h1.*h1+2*cos(pi/8)*h0.*h1-sqrt(2)*h0*cos(pi/10)-sqrt(2)*h1*cos(9*pi/40);
figure;surf(h0,h1,J);xlabel('h0');ylabel('h1');title('误差性能曲面');
figure;contour(h0,h1,J,v);xlabel('h0');ylabel('h1');title('误差性能曲面等值线');

%%%%%%%%%%%%%%%%%%%%% 产生方差0.05，均值为0的白噪声信号 %%%%%%%%%%%%%%%%%%%%%
N=1000;s=sqrt(0.05)*randn(1,N);
figure;plot(s);axis([0 N -1 1]);xlabel('n');ylabel('s(n)');title('方差0.05，均值0的白噪声信号');

%%%%%%%%%%%%%%%%%% 最陡下降法、LMS算法在等值曲线上迭代轨迹 %%%%%%%%%%%%%%%&%%
n=1:N;
q=0.4;%步长
y=s+sin(2*pi*n/16+pi/10);%叠加白噪声的参考信号
x=sqrt(2)*sin(2*pi*n/16);%输入信号

%最陡下降法 H(n+1)=H(n)-0.5*q*Vg(n)
H1=zeros(2,N);%存放最陡下降法的H(n)迭代数据
H1(:,1)=[3;-4];%赋初值
Rxx=[cos(2*pi*0/16),cos(2*pi*1/16);cos(2*pi*1/16),cos(2*pi*0/16)];
Ryx=[cos(2*pi*0/16+pi/10)/sqrt(2);cos(2*pi*1/16+pi/10)/sqrt(2)];
Vg=2*Rxx*H1(:,1)-2*Ryx;
for i=1:N-1
    Vg=2*Rxx*H1(:,i)-2*Ryx;
    H1(:,i+1)=H1(:,i)-0.5*q*Vg;
end
figure;contour(h0,h1,J,v);xlabel('h0');ylabel('h1');title('误差性能曲面等值线');
hold on;plot(H1(1,:),H1(2,:),'g');

%LMS算法 e(n+1)=y(n+1)-H'(n)X(n+1) H(n+1)=H(n)+qe(n+1)X(n+1) 
%X(n+1)=[x(n+1),x(n),...,x(n-N+2)]' N=2
H2=zeros(2,N);%存放LMS法的H(n)迭代数据
H2(:,1)=[3;-4];%赋初值
for i=1:N-1
    e=y(i+1)-H2(:,i)'*x(i+1:-1:i)';
    H2(:,i+1)=H2(:,i)+q*e*x(i+1:-1:i)';
end
hold on;plot(H2(1,:),H2(2,:),'r');
legend('等值线','最陡下降法','LMS算法');

%%%%%%%%%%%%%%%%%%%% LMS算法中e(n)、J(n)、H(n)变化曲线 %%%%%%%%%%%%%%%%%%%%%
en=zeros(1,N-1);%单次实验的e(n)
Jn=zeros(1,N-1);%单次实验的J(n)
Jn_all=zeros(1,N-1,100);%100次实验的J(n)
Jn_average=zeros(1,N-1);%100次实验结果J(n)的平均值
H_all=zeros(2,N-1,100);%100次实验的H(n)
H_average=zeros(2,N-1);%100次实验结果H(n)的平均值
for i=1:100 %100次实验
    s0=sqrt(0.05)*randn(1,N);%随机信号每次实验随机生成
    n=1:N;
    y0=s0+sin(2*pi*n/16+pi/10);%叠加白噪声的参考信号
    x0=sqrt(2)*sin(2*pi*n/16);%输入信号
    H0=[3;-4];%赋初值
    for j=1:N-1
        en(j)=y0(j+1)-H0'*x0(j+1:-1:j)';%保留最后一次实验的e(n)
        H0=H0+q*en(j)*x0(j+1:-1:j)';%实验更新收敛H(n)
        Jn(j)=en(j)^2;%保留最后一次实验的J(n)
        Jn_all(:,j,i)=en(j)^2;%保留100次实验的J(n)
        H_all(:,j,i)=H0;%保留100次实验的H(n)
    end
end
for i=1:N-1%求和算实验均值
    Jn_average(i)=sum(Jn_all(1,i,:))/100;
    H_average(1,i)=sum(H_all(1,i,:))/100;
    H_average(2,i)=sum(H_all(2,i,:))/100;
end
figure;
subplot(3,1,1);plot(en);title('单次实验的e(n)');
subplot(3,1,2);plot(Jn);title('单次实验的J(n)');
subplot(3,1,3);plot(Jn_average);title('100次实验的平均J(n)');

figure;contour(h0,h1,J,v);xlabel('h0');ylabel('h1');title('误差性能曲面等值线');
hold on;plot(H2(1,:),H2(2,:),'g');
hold on;plot(H_average(1,:),H_average(2,:),'r');
legend('等值线','LMS实验的单次轨迹','LMS实验的100次平均轨迹')
