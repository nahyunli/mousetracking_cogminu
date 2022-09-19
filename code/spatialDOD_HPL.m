function [dod] = spatialDOD_HPL(xs,ws)
% calculate Sample Entropy for a single trajectory x, with window size m of 3, and a
% tolerance r of .2 multiplied by the standard deviation of ¥Äx:
% Recommended tolerance r is the standard deviation of x-shifts (¥Äx) across conditions
% Example: spatialDOD( x , 3 , .2 * std( xshifts( x ) ) )
% xs=newtray_raw(:,xvessleIDX);ws=3;

m = [ws-1, ws];
xs1 = diff(xs,[],2);
r = 0.2*std(xs1,[], 2);

    %for m(1)
    for i = 1:size(xs1,1) 
        for ii = 1:size(xs1,2)-m(1)-1
             wcut1(ii, 1:1+m(1),i) = xs1(i,ii:ii+m(1));             
        end

        for j = 1:size(wcut1,1)-1
            cascade = size(wcut1,1)-j;
            for h = 1:cascade
                if max(abs( wcut1(j,:,i) - wcut1(j+h,:,i))) <= r(i)
                   wcut1tray(j,h,i) =1;
                else 
                   wcut1tray(j,h,i) =0; 
                end
            end
        end
    end

    
    %for m(2)
    for i = 1:size(xs1,1) 
        for ii = 1:size(xs1,2)-m(2)
             wcut2(ii, 1:1+m(2),i) = xs1(i,ii:ii+m(2));             
        end

        for j = 1:size(wcut2,1)-1
            cascade = size(wcut2,1)-j;
            for h = 1:cascade
                if max(abs( wcut2(j,:,i) - wcut2(j+h,:,i))) <= r(i)
                   wcut2tray(j,h,i) =1;
                else 
                   wcut2tray(j,h,i) =0; 
                end
            end
        end
    end
    
for iii = 1:size(xs1,1) 
    mm1(1,iii) = sum(sum(wcut1tray(:,:,iii),1),2);
    mm2(1,iii) = sum(sum(wcut2tray(:,:,iii),1),2);
end
 
dod(:,1) = log(mm1') - log(mm2');
dod(isnan(dod))=0; 
dod(isinf(dod))=0;
%check if we can treat nan and inf like this
%higher the value of dod is, the more complex trajectory is
% dod(:,2) = -log(mm2'./mm1');
end





