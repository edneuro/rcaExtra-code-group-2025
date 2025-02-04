%% Simulate response
rMaxVals = 1*linspace(0,1,100);
f1 = zeros(length(rMaxVals));
f2 = zeros(length(rMaxVals));
f3 =zeros(length(rMaxVals));
f4 =zeros(length(rMaxVals));
ftM = dftmtx(200);

for in1 = 1:length(rMaxVals),
    for in2 = 1:length(rMaxVals),
        
        inVal1 = rMaxVals(in1);
        inVal2 = rMaxVals(in2);

rMax = {inVal1 inVal2};
c50  = {5 5};
order = { 2 2};

base = {0 0};

    
%input{1} = repmat([ones(10,1); -ones(10,1)],10,1);
%input{2} = repmat([-ones(10,1); ones(10,1)],10,1);

t = linspace(0,6*pi,200);
t2 = linspace(0,6*pi,200);

input{1} = (sin(t)+1);
input{2} = (-sin(t2)+1);

%  input{1} = inVal1*(real(ftM(4,:))+1);
%  input{2} = inVal2*(real(-ftM(4,:))+1);
  input{1} = (real(ftM(4,:))+1);
  input{2} = ( -1*real(ftM(4,:)) + .0*imag(-ftM(4,:)))+1;

%   input{1} = input{1}.*(sign(input{1}-1)+1);
%   input{2} = input{2}.*(sign(input{2}-1)+1);
%   
  
for i=1:length(input)
pop{i} = rMax{i}*(input{i}.^order{i}./(input{i}.^order{i}+c50{i}.^order{i})) + base{i};
%pop{i} = abs(input{i});
%pop{i} = rMax{i}*(input{i}-1).*(sign(input{i}-1)+1);
end

    
normalPop{1} = pop{1};%./(pop{2}+1);
normalPop{2} = pop{2};%./(pop{1}+1);
normalPop{1} = pop{1}./(pop{2}+1);
normalPop{2} = pop{2}./(pop{1}+1);

rMax = { 1 1};
c50  = { 1 1};

for i=1:length(input)
pop2{i} = rMax{i}*(normalPop{i}.^2./(normalPop{i}.^2+c50{i}.^2));
end

normalPop2{1} = pop2{1};%./(pop2{2}+1);
normalPop2{2} = pop2{2};%./(pop2{1}+1);


popDiff = normalPop{1}-normalPop{2};


popDiff = rMax{i}*(popDiff.^2./(popDiff.^2+c50{i}.^2));

%normalPopDiff{1} = popDiff./(popDiff+1);


resp = [normalPop{1}+normalPop{2}];
%resp = input{1} + input{2};

%resp = resp - mean(resp);

powSpec = abs(resp*ftM);

f1(in1,in2) = powSpec(3+1);
f2(in1,in2) = powSpec(6+1);
f3(in1,in2) = powSpec(9+1);
f4(in1,in2) = powSpec(12+1);

    end
    if mod(in1,10)==0,in1,end
%end

figure(17)
clf
subplot(4,1,1)
plot(sign(input{1}-1),'k','linewidth',4)
title('Input','fontsize',30,'fontname','arial')
axis off

subplot(4,1,2)
plot(normalPop{1},'--r','linewidth',3)
hold on;
plot(normalPop{2},'-','linewidth',3)
plot(zeros(length(normalPop{1}),1),'-k','linewidth',3);
title('Individual population responses','fontsize',30,'fontname','arial')
axis off

subplot(4,1,3)
plot(resp,'b','linewidth',2)
hold on
plot(mean(resp)*ones(length(resp),1),'k','linewidth',3)

title('EEG Measured response','fontsize',30,'fontname','arial')
axis off

subplot(4,1,4)


%sqrt(sum(powSpec(4:3:19).^2))

bar(0:199,powSpec,'b')
axis([1 30 0 10])
%xlim([1 30])

hold on
title('Frequency Components','fontsize',30,'fontname','arial')
set(gca,'XTick',3:3:30)
set(gca,'YTick',[])
set(gca,'fontsize',30,'fontname','arial')



end
figure(18)
clf
subplot(2,2,1)
imagesc(rMaxVals,rMaxVals,f1)
title('f1')
subplot(2,2,2)
imagesc(rMaxVals,rMaxVals,f2)
title('f2')
subplot(2,2,3)
imagesc(rMaxVals,rMaxVals,f3)
title('f3')
subplot(2,2,4)
imagesc(rMaxVals,rMaxVals,f4)
title('f4')


