%  function [yls,flag] = loess(y,t,tls,tau)
%
%  y = values
%  t = time variable (same length as y)
%  tls = new time variable
%  tau = window size
%
%  Jim Lerczak
%  11 June 2012
%  Dylan Anderson
%  24 May 2013

function [yls,flag] = loess(y,t,tls,tau)

yls = NaN*tls ;
flag = 0*tls ;

%  normalize t and tls by tau
t = t/tau ;
tls = tls/tau ;

%  only apply loess smoother to times (tls) within the time range of the
%  data (t)
nn = find((tls>=min(t)).*(tls<=max(t))) ;

for ii = 1:length(nn)
    idx = nn(ii) ;
    qn = (t-tls(idx)) ;
    mm = find(abs(qn)<=1) ;
    qn = qn(mm) ;
    ytmp = y(mm) ;
    ttmp = t(mm)-tls(idx) ;
    mm = find(~isnan(ttmp.*ytmp)) ;
    %  need at least three data points to do the regression
    if length(mm)>=3
        ytmp = ytmp(mm) ;
        ttmp = ttmp(mm) ;
        qn = qn(mm) ;
        wn = ((1 - abs(qn).^3).^3).^2 ;
        W = diag(wn,0) ;
        X = [ones(size(ttmp)) ttmp ttmp.^2] ;
        M1 = X'*W*X ;
        M2 = X'*W*ytmp ;
        B = M1\M2 ;
        
        yls(idx) = B(1) ;
        
        %  if the solution is out of the range of the data used in the
        %  regression, then flag that datapoint
        if (B(1)<min(ytmp))||(B(1)>max(ytmp))
            flag(idx) = 1 ;
        end
        
    end
end
       
return