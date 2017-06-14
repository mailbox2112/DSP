function y = firFilter(numerator, x)

% Create a buffer to hold the old values of the input
buffer = zeros(size(numerator));
y = zeros(size(x));

% Do the filtering
for n = 1:length(x)
    % Store the new sample at the first point in the buffer
    buffer(1) = x(n);
    % The output at that time interval is equal to the sum of the current and
    % past inputs multiplied by the coefficients
    y(n) = sum(buffer.*numerator);
    % Shift everything in the buffer. Need to go from last to first, 
    % otherwise it just moves the newest sample out of the buffer and
    % passes the input through
    for m = length(numerator):-1:2
       buffer(m) = buffer(m - 1);
    end
end

end