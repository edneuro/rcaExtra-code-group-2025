%% Simulate response

rMax = {1 1};
c50  = {2 2 };
order = { 2 2};


base = {0 0};

    
%input{1} = repmat([ones(10,1); -ones(10,1)],10,1);
%input{2} = repmat([-ones(10,1); ones(10,1)],10,1);

w1 = 3*.33;
w2 = 5*.33;

ph2 = 0;
t = linspace(0,6*pi,200);
t2 = linspace(0,6*pi,200)+2*pi/1;

input{1} = (sin(w1*t));
input{2} = 0*(sin(w2*t+ph2));


% input{1} = input{1}+input{2};
% input{2} = input{1};


input{1} = (input{1}).*(sign(input{1})>0);
input{2} = (input{2}).*(sign(input{2})>0);

sampPerRad = 200/6*pi;
delay = round(sampPerRad*0);

%input{1} = (sin(t)).*sign((sin(t)));
%input{2} = (cos(t2)).*sign((cos(t2)));
%input{2} = (-sin(t2)).*sign((sin(t2)));

%input{1} = (sin(w1*t)).*((sin(w1*t)>0));
%input{2} = (cos(w2*t2)).*((cos(w2*t2)>0));

%  input{1} = real(ftM(4,:))+1
%  input{2} = real(-ftM(4,:))+1;

for i=1:length(input)
pop{i} = rMax{i}*(input{i}.^order{i}./(input{i}.^order{i}+c50{i}.^order{i})) + base{i};
%pop{i} = abs(input{i});
end


pop{1} = pop{1};%-mean(pop{1});
pop{2} = pop{2};%-mean(pop{2});

normalPop{1} = pop{1};%-mean(pop{1});%./(pop{2}+1);
normalPop{2} = pop{2};%-mean(pop{2});%./(pop{1}+1);

popDelay{1} = circshift(pop{1},[0 delay])
popDelay{2} = circshift(pop{2},[0 delay])


rMax = { 1 1};
% c50  = c50;%{ 2 2};
c50  = {.5 .5};
wgt  = { .707  .707};


for i=1:length(input)
pop2{i} = rMax{i}*(popDelay{i}.^2./(popDelay{i}.^2+c50{i}.^2));
end

for i=1:1,
%pop1Combo{i} = popDelay{1}+popDelay{2};
pop1Combo{i} = wgt{1}*pop{1}+wgt{2}*pop{2};

pop2Combo{i} = rMax{i}*(pop1Combo{i}.^2./(pop1Combo{i}.^2+c50{i}.^2));

end

% normalPop2{1} = pop2{1};%-mean(pop2{1});%./(pop2{2}+1);
% normalPop2{2} = pop2{2};%-mean(pop2{2});%./(pop2{1}+1);
% 
 normalPop2{1} = pop2Combo{1};%-mean(pop2{1});%./(pop2{2}+1);
 normalPop2{2} = pop2Combo{1};%-mean(pop2{2});%./(pop2{1}+1);

% 
% normalPop2{1} = popDelay{1};%-mean(pop2{1});%./(pop2{2}+1);
% normalPop2{2} = popDelay{2};%-mean(pop2{2});%./(pop2{1}+1);


popDiff = normalPop{1}-normalPop{2};


popDiff = rMax{i}*(popDiff.^2./(popDiff.^2+c50{i}.^2));

%normalPopDiff{1} = popDiff./(popDiff+1);


resp1 = [normalPop{1}+normalPop{2}];
resp2 = [normalPop2{1}+normalPop2{2}];

% resp1 = resp1./max(resp1);
% resp2 = resp2./max(resp2);
%resp2 = [popDelay{1}+popDelay{2}];

%resp = resp1 - mean(resp);

% resp1 = resp1 - mean(resp1);
% resp2 = resp2 - mean(resp2);
%  
 resp = 1*resp1+1*resp2;

%resp = resp - mean(resp);

resp1 = resp1 - mean(resp1);
resp2 = resp2 - mean(resp2);

figure(17)
clf

nRows = 5;

subplot(nRows,1,1)
plot(input{1},'k','linewidth',4)
hold on
plot(input{2},'--k','linewidth',4)

title('Input','fontsize',20,'fontname','arial')
axis off

subplot(nRows,1,2)
plot(normalPop{1},'--r','linewidth',3)
hold on;
plot(normalPop{2},'-','linewidth',3)
plot(zeros(length(normalPop{1}),1),'-k','linewidth',3);
title('Individual population responses','fontsize',30,'fontname','arial')
axis off

subplot(nRows,1,3)
plot(normalPop2{1},'--r','linewidth',3)
hold on;
plot(normalPop2{2},'-','linewidth',3)
plot(zeros(length(normalPop{1}),1),'-k','linewidth',3);
title('Individual population responses','fontsize',30,'fontname','arial')
axis off

subplot(nRows,1,4)
plot(resp,'b','linewidth',2)
hold on
plot(mean(resp)*ones(length(resp),1),'k','linewidth',3)

title('EEG Measured response','fontsize',20,'fontname','arial')
axis off

subplot(nRows,1,5)
ftM = dftmtx(length(resp));

powSpec = abs(resp*ftM);

sqrt(sum(powSpec(4:3:19).^2))

bar(0:199,powSpec,'b')
%axis([1 30 0 10])
xlim([1 30])

hold on
title('Frequency Components','fontsize',20,'fontname','arial')
set(gca,'XTick',3:3:30)
set(gca,'YTick',[])
set(gca,'fontsize',20,'fontname','arial')





%%


figure(18)
clf

subplot(2,1,1)


powSpec = abs(resp1*ftM);

lims = [1 30 0 max(powSpec)*1.2]

sqrt(sum(powSpec(4:3:19).^2))

bar(0:199,powSpec,'b')
axis(lims)
%xlim([1 30])

hold on
title('Frequency Components','fontsize',20,'fontname','arial')
set(gca,'XTick',3:3:30)
set(gca,'YTick',[])
set(gca,'fontsize',20,'fontname','arial')

subplot(2,1,2)


powSpec = abs(resp2*ftM);

sqrt(sum(powSpec(4:3:19).^2))

bar(0:199,powSpec,'b')
axis(lims)
%xlim([1 30])

hold on
title('Frequency Components','fontsize',20,'fontname','arial')
set(gca,'XTick',3:3:30)
set(gca,'YTick',[])
set(gca,'fontsize',20,'fontname','arial')
