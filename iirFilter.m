function y = iirFilter(num, denom, x, form)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Aaron Roby
% 6/15/2017
% Implementation of Direct Form 1 and Direct Form 2 IIR Filters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set up the buffers to hold past values
inputbuffer = zeros(size(num));
outputbuffer = zeros(1, length(denom)-1);
    
% Set up the output vector
y = zeros(size(x));

% Check the form input
if form == '1' % Direct Form I
    % Loop where the filtering is performed
    for n = 1:length(x)
        inputbuffer(1) = x(n);
        y(n) = sum(inputbuffer.*num) - sum(outputbuffer.*denom(2:length(denom)));
        
        % Shift the buffers around
        for m = length(inputbuffer):-1:2
            inputbuffer(m) = inputbuffer(m-1);
        end
        for m = length(outputbuffer):-1:2
            outputbuffer(m) = outputbuffer(m-1); 
        end
        
        % Save the output to the output buffer. This should make the first
        % element in the output buffer y(n-1) as a result
        outputbuffer(1) = y(n);
    end
elseif form == '2' % Direct Form II
    % TODO: Implement
end


end