function val = T60(impRsp,fs)
% calculate T60 according to a single impulse response impRsp, with sampling frequency fs

% Author: Ran Weissman
arguments
    impRsp (:,1) {mustBeNumeric}
    fs (1,1) {mustBeNumeric}
end
if isscalar(impRsp)
    val = 0;
    return
end
SchCur = 10*log10(cumsum(abs(impRsp/norm(impRsp)).^2,'reverse'));
fst = find(SchCur<=-05,1,'first') ;
lst = find(SchCur<=-35,1,'first') ;
coe = LinearRegression((fst:lst)'/fs,SchCur(fst:lst)) ;
val = -60/coe(1) ;

    function coe = LinearRegression(tme,eng)
        nmb = length(tme) ;
        Mat = [tme(:) ones(nmb,1)] ;
        coe = pinv(Mat) * eng ;
    end

end