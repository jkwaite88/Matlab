a = b + 1;
a b doiwllsknoing a;as;dlfk aoij 
alsjfahf 

a
dfa
sfdasflakjsf;lasjf
as;dkjfas;kjf;alfj
as;djfa;lfjaf
a;lsdfja;lkf 

figure(9)
clf
hold on
axis([-10000 10000 -10000 10000])
delay = -14;
startP = 22800;
for i = startP:(startP+512-1)
    plot([real(squeeze(DataMatrix(maxFftBin,1,i))) real(squeeze(DataMatrix(maxFftBin,1,i+1)))],[imag(squeeze(DataMatrix(maxFftBin,1,i))) imag(squeeze(DataMatrix(maxFftBin,1,i+1)))],'b')
    plot([real(squeeze(DataMatrix(maxFftBin,2,i-delay))) real(squeeze(DataMatrix(maxFftBin,2,i+1-delay)))],[imag(squeeze(DataMatrix(maxFftBin,2,i-delay))) imag(squeeze(DataMatrix(maxFftBin,2,i+1-delay)))],'g')
    stophere=1;
    pause(0.2)
end

a = 0;
for delay = -255:255
    a = a + 1;
    cc(a) = sum(squeeze(DataMatrix(maxFftBin,1,i)) .* conj(squeeze(DataMatrix(maxFftBin,,i-delay))));
end
figure(10)
plot(abs(cc))