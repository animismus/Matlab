function [pqn_normed, diffs] = PQN(toNorm,ref_idx, varargin)

%{
in:
    toNorm:     matrix with values only, no labels for cols or rows
    ref_idx:    index or indexes for the rows to use as ref
    option 1:   1 to plot the spectrum before and after for the sample with
                higher difference
    option 2:   shade the difference on the plot
                takes some extra time
out:
    pqn_normed: PQN normalized matrix
    diffs:      diff between spectrum and pqn spectrum normalized by num points
    
1. Perform an integral normalization (typically a constant
integral of 100 is used).
2. Choose/calculate the reference spectrum (the best approach
is the calculation of the median spectrum of control samples).
3. Calculate the quotients of all variables of interest of the test
spectrum with those of the reference spectrum.
4. Calculate the median of these quotients.
5. Divide all variables of the test spectrum by this median.
%}

plotflag = 0;
if length(varargin) > 0 && varargin{1} == 1; plotflag = 1;end
shadeflag = 0;
if length(varargin) > 1 && varargin{2} == 1; shadeflag = 1;end



%2. Choose/calculate the reference spectrum (the best approach
% the median of one row will the row
pqn_ref_samp = median(toNorm(ref_idx,:),1);

%3. Calculate the quotients of all variables of interest of the test
%spectrum with those of the reference spectrum.

%bsxfun  - Apply element-by-element binary operation to two arrays with singleton expansion enabled
%Right array divide
pqn_quo_matrix =  bsxfun(@rdivide,toNorm,pqn_ref_samp);

% 4. Calculate the median of these quotients.
pqn_quo_median = median(pqn_quo_matrix,2);

% 5. Divide all variables of the test spectrum by this median.
pqn_normed = bsxfun(@rdivide,toNorm,pqn_quo_median);

% calculate the diference between the original diference and the normalized
% data and divide by number of points
diffs = sum(abs(toNorm - pqn_normed),2) / size(toNorm, 2);

if plotflag
    [maxDiff, maxDiff_idx] = max(diffs);
    figure;

    plot(toNorm(maxDiff_idx, :));
    hold on;
    plot(pqn_normed(maxDiff_idx, :));

    if shadeflag
        
        % color of shade
        shadecolor(1:3) = 225 / 256;
        
        xx = 1:length(toNorm(maxDiff_idx, :));
        fill([xx fliplr(xx)],...
        [toNorm(maxDiff_idx,:) fliplr(pqn_normed(maxDiff_idx,:))],...
        shadecolor,...
        'edgecolor', 'none');
    end





    title(['Largest difference for before and after PQN is for sample ', int2str(maxDiff_idx)]);
    legend('Before', 'After');
%        set(gca, 'xdir', 'reverse'); only if there was a ppm scale
end

end