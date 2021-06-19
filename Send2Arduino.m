%% Send to Arduino
%% initialize port (run once)
s = instrfindall;
if ~isempty(s)
    fclose(s);
    delete(s);
end
s = serial('COM3','BaudRate',9600,'DataBits',8,'Stopbits',1, 'parity','none');
fopen(s);
%% Load input
Deg=[30,18,24];
%% Transmit 1Data 
T=2; %seconds
for k=1:length(Deg) %U variable name
    fwrite(s,Deg(k));
    pause(T); 
end 