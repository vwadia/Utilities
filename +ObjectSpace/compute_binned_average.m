function nonlin = compute_binned_average(rlin, resp, nbin, least_samples)


%% flexable:
% set an initial bin, combine near bins with too few samples
if nargin<3
    nbin = 8;
end
if nargin<4
    least_samples = 20;
end

mi=min(rlin);
ma=max(rlin);
edge=mi:(ma-mi)/nbin:ma; % min of proj to max of proj in steps of (ma-mi)/nbin

x=zeros(nbin,1);
y=zeros(nbin,1);
e=zeros(nbin,1);
ns=zeros(nbin,1); % number of samples

c = 0; % count

for i=1:nbin
    ind=rlin>edge(i) & rlin<=edge(i+1);
    ns(i)= sum(ind); %num of spikes between edges
end

edge_select = true(nbin+1,1);
for i=1:nbin
    if ns(i) < least_samples
        if i<nbin
            ns(i+1)=ns(i+1)+ns(i);
            edge_select(i+1) = false;
        elseif i==nbin
            ind = find(edge_select(1:end-1),1,'last');  % find last bin edge and combine the last bin to previous one
            edge_select(ind) = false;
        end
    end
end

edge = edge(edge_select); % deselect some dividing edges
nbin = length(edge)-1;
x=zeros(nbin,1);
y=zeros(nbin,1);
e=zeros(nbin,1);
ns=zeros(nbin,1);
for i=1:nbin
    ind=rlin>edge(i) & rlin<=edge(i+1); % images with sta_proj in this range
    x(i)=mean(rlin(ind));
    y(i)=mean(resp(ind));
    e(i)=std(resp(ind))/sqrt(sum(ind));
    ns(i)= sum(ind);
end

nonlin.x=x;
nonlin.y=y;
nonlin.e=e;
nonlin.ns=ns;
nonlin.rlin_std =std(rlin);