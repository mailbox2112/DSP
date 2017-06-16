%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Aaron Roby
% 6/8/2017
% Implementing various types of filters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Finite Impulse Response Filter Tests!                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load coefficients from .mat file
% Coefficients are for same filter specs, but one is FIR, other IIR
load('fircoefficients.mat');
load('iircoefficients.mat');

% Create some 100ms of sinusoids to pass into the filters, sampled at
% 20 kHz
fs = 48e3;
t = 0:1/fs:.1;

% Create some frequencies to pass through the filter
frequencies = [10, 100, 250, 500, 1e3, 2e3, 3e3, 5e3, 9.6e3 12e3 15e3 20e3];

% Matrix to hold each sinusoid
inputs = zeros(length(frequencies), length(t));
outputs = zeros(length(frequencies), length(t));

% Create sinusoids at each frequency
for i = 1:length(frequencies)
    inputs(i,:) = sin(2*pi*frequencies(i)*t);
end

% Create a bode plot of the filter response using the function
for j = 1:length(frequencies)
   outputs(j, :) = firFilter(Num, inputs(j, :)); 
end

% Create the output matrix
iiroutputs = zeros(length(frequencies), length(t));

% Get the coefficients from the SOS and gains
[b, a] = sos2tf(SOS, G);

% Create an impulse for debugging
%impulse = [1 zeros(1, length(t)-1)];

% Get the filtered outputs for each frequency
for i = 1:length(frequencies)
    iiroutputs(i, :) = iirFilter(b, a, inputs(i,:), '1');
end

figure
subplot(2,1,1)
% Plot the outputs of a passband signal, Fp signal, Fs signal, stopband
plot(t, outputs(1,:), t, outputs(9,:), t, outputs(10,:), t, outputs(12,:))
xlabel('Time (s)')
ylabel('Amplitude')
title('Output Response of FIR Filter, Fp = 9600, Fs = 12000')
legend('10 Hz', '9.6 kHz', '12 kHz', '20 kHz') 
subplot(2,1,2)
plot(t, iiroutputs(1,:), t, iiroutputs(9,:), t, iiroutputs(10,:), t, iiroutputs(12,:))
title('Output Response of Direct Form 1 IIR Filter, Fp = 9600, Fs = 12000')
xlabel('Time (s)')
ylabel('Amplitude')
legend('10 Hz', '9.6 kHz', '12 kHz', '20 kHz')