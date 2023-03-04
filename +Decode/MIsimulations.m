iterations = 100000;
MI = [];
figure;
for j=2:20
    MI = [];
    for i=1:iterations

       a = rand(j,4);
       a = a./(sum(sum(a)));

       MI(i) =  Decode.computeMI({a});

    end
	ax(j-1) = subplot(4,5,j-1); hist(MI,1000);
end
linkaxes(ax)