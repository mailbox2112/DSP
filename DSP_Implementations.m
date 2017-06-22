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
form1outputs = zeros(length(frequencies), length(t));

% Get the coefficients from the SOS and gains
[b, a] = sos2tf(SOS, G);

% Get the filtered outputs for each frequency using IIR Form 1
for i = 1:length(frequencies)
    form1outputs(i, :) = iirFilterForm1(b, a, inputs(i,:));
end

% Create the matrix to hold our IIR Form 2 outputs
form2outputs = zeros(length(frequencies), length(t));

% Filter the inputs using the Form 2 variant
for i = 1:length(frequencies)
    form2outputs(i, :) = iirFilterForm2(b, a, inputs(i, :));
end

% Handles for timing the two forms of the IIR filter, plus FIR filter
func1 = @() iirFilterForm1(b, a, inputs(10, :));
func2 = @() iirFilterForm2(b, a, inputs(10, :));
func3 = @() firFilter(Num, inputs(10, :));

% Perform the filtering 1000 times and average the execution time
sum = 0;
for i = 1:100
    sum = sum + timeit(func1);
end
form1time = sum / 100


sum = 0;
for i = 1:100
    sum = sum + timeit(func2);
end
form2time = sum / 100

sum = 0;
for i = 1:100
    sum = sum + timeit(func3);
end
firtime = sum / 100

% Result from a perfectly clear workspace: 

figure
subplot(3,1,1)
% Plot the outputs of a passband signal, Fp signal, Fs signal, stopband
% Created using the FIR version of the filter
plot(t, outputs(1,:), t, outputs(9,:), t, outputs(10,:), t, outputs(12,:))
xlabel('Time (s)')
ylabel('Amplitude')
title('Output Response of FIR Filter, Fp = 9600, Fs = 12000')
legend('10 Hz', '9.6 kHz', '12 kHz', '20 kHz') 
subplot(3,1,2)
% Plot the outputs of a passband signal, Fp signal, Fs signal, stopband
% Created using the IIR Form 1 version of the filter
plot(t, form1outputs(1,:), t, form1outputs(9,:), t, form1outputs(10,:), t, form1outputs(12,:))
title('Output Response of Direct Form 1 IIR Filter, Fp = 9600, Fs = 12000')
xlabel('Time (s)')
ylabel('Amplitude')
legend('10 Hz', '9.6 kHz', '12 kHz', '20 kHz')
subplot(3,1,3)
% Plot the outputs of a passband signal, Fp signal, Fs signal, stopband
% Created using the IIR Form 2 version of the filter
plot(t, form2outputs(1,:), t, form2outputs(9,:), t, form2outputs(10,:), t, form2outputs(12,:))
title('Output Response of Direct Form 2 IIR Filter, Fp = 9600, Fs = 12000')
xlabel('Time (s)')
ylabel('Amplitude')
legend('10 Hz', '9.6 kHz', '12 kHz', '20 kHz')