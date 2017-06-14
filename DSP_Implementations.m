%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Aaron Roby
% 6/8/2017
% Implementing various types of filters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Finite Impulse Response Filter Tests!                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load coefficients from .mat file
load('fircoefficients.mat');

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

% Get the magnitude of the output and plot it as a bode plot
% TODO
plot(t, outputs(1,:), t, outputs(9,:), t, outputs(10,:), t, outputs(12,:))
xlabel('Time (s)')
ylabel('Amplitude')
title('Output Response of FIR Filter, Fp = 9600, Fs = 12000')
legend('10 Hz', '9.6 kHz', '12 kHz', '20 kHz') 

% Create a low pass butterworth filter
[n, Wn] = buttord(1000/(fs/2), 5e3/(fs/2), 1, 80); 

% B is the numerator in MATLAB, A is the denominator
[b, a] = butter(n, Wn);