
clc
clear all
close all


f = fred
startdate = '01/01/1994';
enddate = '01/01/2022';

%%
CN = fetch(f,'NGDPRSAXDCCAQ',startdate,enddate)      %Real Gross Domestic Product for Canada(NGDPRSAXDCCAQ)
JP = fetch(f,'JPNRGDPEXP',startdate,enddate)      %Real Gross Domestic Product for Japan(JPNRGDPEXP)
cn = log(CN.Data(:,2));
jp = log(JP.Data(:,2));
q = CN.Data(:,1);
T = size(cn,1);

% Hodrick-Prescott filter
lam = 1600;
A = zeros(T,T);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

cnGDP = A\cn;
jpPCE = A\jp;

% detrended GDP
cntilde = cn-cnGDP;
jptilde = jp-jpPCE;

% plot detrended GDP
dates = 1994:1/4:2022.1/4; zerovec = zeros(size(cn));
figure
title('Detrended log(real GDP) 1994Q1-2022Q1'); hold on
plot(q, cntilde,'r', q, jptilde,'b')
datetick('x', 'yyyy-qq')
legend({'JAPAN','CANADA'},'Location','southwest')

% compute sd(y), sd(c), rho(y), rho(c), corr(y,c) (from detrended series)
ysd_cn = std(cntilde)*100;
ysd_jp = std(jptilde)*100;
corryc = corrcoef(cntilde(1:T),jptilde(1:T)); corryc = corryc(1,2);

disp(['Percent standard deviation of detrended log real GDP for Japan: ', num2str(ysd_cn),'.']); disp(' ')
disp(['Percent standard deviation of detrended log real GDP for Canada: ', num2str(ysd_jp),'.']); disp(' ')
disp(['Contemporaneous correlation between detrended log real GDP　for Japan　and detrended log real GDP for Canada : ', num2str(corryc),'.']);



