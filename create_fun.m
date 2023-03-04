% Commonly used functions

function fun_hand = create_fun(type)

if nargin<1
    type = 'z-score';
end

% Normalization Functions
switch type

    case 'identity'
        fun_hand          = @(x) x;
    case 'z-score' 
        fun_hand          = @(x) (x-repmat(nanmean(x,2),1,size(x,2)))...
                            ./repmat(nanstd(x,[],2),1,size(x,2));
    case 'db'
        fun_hand          = @(x,y) 10*log10((x./repmat(mean(x(:,y),2),...
                            1,size(x,2))));    
     case 'sigmoid'     
        fun_hand          = @ (x) soft_max_fun(x,'sigmoid');
    
     case 'tanh'
        fun_hand          = @ (x) soft_max_fun(x,'tanh');
        
    case 'area'
        fun_hand          = @(x) bsxfun(@rdivide,x,trapz(x));

    case 'peak_norm'
        fun_hand          = @(x) bsxfun(@rdivide,x,max(x));
        
    case 'z-score_2'     
        fun_hand          = @(x) (x-nanmean(x(:)))./nanstd(x(:));
        
     
    

    
        
end

end % End 



% Helper functions
function ret  = soft_max_fun(x,type)

z    = (x-nanmean(x(:)))./nanstd(x(:));

switch type
    case 'sigmoid'
        ret  = 1./(1+exp(-z));
    case 'tanh'
        ret  = (1-exp(-z))./(1+exp(-z));      
end
        
        
end

