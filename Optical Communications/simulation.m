clc
clear
%% a
N = 27; k = 9; F = 2000;
m_dark = 2;sigma_n = 10;

m = 20:2:200;
for i = 1:length(m)
m1 = 0.8*m(i) + m_dark;  m0 = m_dark;
s1_old = -100; s0_old = 100; th_old = 1;
s1 = -1; s0 = 1; th = 1;
for n = 1:10^5
    if abs(s1 - s1_old)>10^-5 || abs(s0 - s0_old)>10^-5 
        s1_old = s1;
        s0_old = s0;
        [s1,s0] = solve1(th,m1,m0,s1_old,s0_old,sigma_n);
        th_old = th;
        th = solve2(s1,s0,m1,m0,th,sigma_n);
        
    else
        break
    end
end

pe(i) = (psy(s0,m0,th,0,sigma_n)/((2*pi*psy(s0,m0,th,2,sigma_n))^0.5)) + (psy(s1,m1,th,0,sigma_n)/((2*pi*psy(s1,m1,th,2,sigma_n))^0.5));
end

BER_a1 = 0.5*((1-(1-k^2/(2*F)))^(N-1) + (1-k^2/(2*F))^(N-1)*pe);
BER_b1 = 0.5*((1-(1-k^2/(2*F)))^(N-1)^2 + (1-(1-(1-k^2/(2*F))^(N-1))^2)*pe);

figure
subplot(2,1,1)
plot(m,BER_a1)
ylabel('BER of system a')
title('BER vs m')
subplot(2,1,2)
plot(m,BER_b1)
ylabel('BER of system b')
xlabel('m')

%% b
N = 5:2:27;
k = 9; F = 2000;
m_dark = 5;sigma_n = 20;
m = 200;

for i = 1:length(N)
m1 = 0.8*m + m_dark;  m0 = m_dark;
s1_old = -100; s0_old = 100; th_old = 1;
s1 = -1; s0 = 1; th = 1;
for n = 1:10^5
    if abs(s1 - s1_old)>10^-5 || abs(s0 - s0_old)>10^-5 
        s1_old = s1;
        s0_old = s0;
        [s1,s0] = solve1(th,m1,m0,s1_old,s0_old,sigma_n);
        th_old = th;
        th = solve2(s1,s0,m1,m0,th,sigma_n);
        
    else
        break
    end
end

pe = (psy(s0,m0,th,0,sigma_n)/((2*pi*psy(s0,m0,th,2,sigma_n))^0.5)) + (psy(s1,m1,th,0,sigma_n)/((2*pi*psy(s1,m1,th,2,sigma_n))^0.5));

BER_a2(i) = 0.5*((1-(1-k/(2*F)).^(N(i)-1)) + (1-k/(2*F)).^(N(i)-1)*pe);
BER_b2(i) = 0.5*((1-(1-k/(2*F)).^(N(i)-1))^2 + (1-(1-(1-k/(2*F)).^(N(i)-1))^2)*pe);
end




figure
subplot(2,1,1)
plot(N,BER_a2)
ylabel('BER of system a')
title('BER vs N')
subplot(2,1,2)
plot(N,BER_b2)
ylabel('BER of system b')
xlabel('N')
