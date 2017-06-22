function y = iirFilterForm2(num, denom, x)
% Implementation of the Direct Form 2 IIR Filter equation.
% Takes numerator coefficients, denominator coefficients, and input signal
% as input arguments, and outputs the output signal

y = zeros(size(x));

% Set up the U values
u = zeros(size(denom));
for n = 1:length(x)
    % The first value in U is X(n) minus the sum of all previous U
    % values multiplied elementwise by the denominator coefficients
    u(1) = x(n) - sum(u(2:length(u)).*denom(2:length(denom)));
    
    % The output is just the sum of the numerator coefficients
    % multiplied by the U values
    y(n)= sum(num.*u(1:length(num)));
    
    % Shift our U values back to keep track of the past N values
    for m = length(u):-1:2
        u(m) = u(m-1);
    end
end

end

