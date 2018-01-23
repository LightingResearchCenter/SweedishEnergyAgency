 function [time,red,green,blue,illuminance,CLA,activity,deviceSN] = importDaysimeter12(log_info_filename,data_log_filename)

% Applies calibration to a pair of Daysimeter12 data files.
% The files are called log_info.txt and data_log.txt on the Daysimeter12,
% but they should be renamed after copying them to the computer. The first
% first file requested in the pop-up file dialog box is the log_info file
% and the second file requested is the data_log file.
% This function saves a text file of the calibrated data in same directory
% as the data_log file with file name having the characters "Processed"
% appended to gthe file name.
%{
[FileNameLogInfo,PathNameLogInfo] = uigetfile('*.*','"log_info" file');
[FileNameDataLog,PathNameDataLog] = uigetfile('*.*','"data_log" file');
log_info_filename = [PathNameLogInfo '\' FileNameLogInfo];
data_log_filename = [PathNameDataLog '\' FileNameDataLog];
%}
% RGB calibration constants
% ID#	R	G	B
RGBcalFactors = [...
    1	0.4575	0.6422	3.0108
    2	1.2432	1.5681	3.1364
    3	1.2545	1.6829	3.0000
    4	0.4575	0.6422	3.0108
    5	1.3878	1.6190	3.0909
    6	1.4468	2.0299	3.3171
    7	1.1825	1.7529	3.1042
    8	1.3097	1.7011	3.2174
    9	1.2946	1.6292	3.1522
    10	1.2636	1.6548	3.0217
    11	1.2373	1.6404	3.1064
    12	1.3426	1.7683	3.2222
    13	1.2288	1.7059	2.8431
    14	1.0000	2.0000	3.0000
    15	1.2636	1.6951	2.9574
    16	1.1885	1.5761	2.6852
    17	1.3495	1.6747	3.3902
    18	1.0000	2.0000	3.0000
    19	1.2586	1.6782	2.9796
    20	1.3148	1.7317	3.1556
    21	1.2909	1.7108	3.0870
    22	1.2544	1.6250	3.0426
    23	1.2241	1.5778	2.9583
    24	1.2909	1.6136	3.2273
    25	1.0840	1.4343	2.5357
    26	1.2609	1.6292	2.9592
    27	1.1488	1.5275	2.5741
    28	1.3091	1.6941	3.1304
    29	1.2991	1.6747	3.4750
    30	1.2636	1.6548	3.2326
    31	1.2752	1.7375	2.8958
    32	1.6951	2.4386	4.0882
    33	1.3018	1.7742	3.0556
    34	1.3436	1.8250	3.2206
    35	1.7778	2.3226	4.1143
    36	1.2609	1.6292	2.9592
    37	1.2909	2.4000	3.0870
    38	1.7778	1.6912	4.3636
    39	1.0000	2.0000	3.0000
    40	1.7654	2.3833	4.3333
    41	1.7857	2.4457	4.5000
    42	1.0000	2.0000	3.0000
    43	1.2280	1.6250	2.9225
    44	1.3271	1.7750	3.1556
    45	1.7108	2.3279	4.3030
    46	1.3271	1.7975	3.0870
    47	1.3271	1.7750	3.2272
    48	1.3302	1.7407	3.1333
    49	1.3981	1.8228	3.2727
    50	1.2632	1.7143	3.2727
    51	1.3431	1.7792	3.3415
    52	1.7895	2.3051	4.6897
    53	1.3776	1.7763	3.3750
    54	1.2991	1.6548	3.1591
    55	1.2296	1.6118  2.9643
    56	1.6275	2.1013	3.9524
    57	1.2661	1.7037	3.0667
    58	1.6988	2.3898	4.2727
    59	1.2936	1.6988	3.1333
    60	1.2769	1.6939	2.9643
    61	1.1920	1.5974	2.8621
    62	1.2870	1.6747	3.2326
    63	1.2897	1.7250	2.9362
    64  1.2672  1.6600  3.0182
    65  1.2287  1.6114  2.9643
    66  1.1942  1.6600  2.7655
    67  1.6436  2.1275  3.9524
    68  1.2862  1.6600  3.0182
    69  1.2388  1.6895  2.7667
    70  1.6940  2.3056  4.1500
    71  1.2264  1.6436  3.0182
    72  1.2720  1.6704  2.9223
    73  1.1835  1.6405  2.8333
    74  1.2070  1.6121  2.8769
    75  1.5203  2.1345  3.9026
    76  1.2359  1.5847  2.9219
    77  1.2437  1.6023  3.0540
    78  1.1910  1.5714  2.8769
    79  1.2033  1.6368  2.7914
    80  1.2550  1.6121  2.9683
    81  1.2140  1.5191  2.9219
    82  1.1941  1.5457  2.9686
    83  1.2764  1.7253  2.9864
    84  1.7171  2.3974  4.1833
    85  1.2256  1.6804  2.9107
    86  1.6633  2.2049  4.1795
    87  1.3252  1.7717  3.1424
    88  1.2636  1.7158  2.9107
    89  1.3209  1.7527  3.1346
    90  1.1985  1.6139  2.7627
    91  1.6470  2.2639  3.9756
    92  1.7173  2.3249  4.1805
    93  1.3377  1.7711  3.2040
    94  1.2673  1.7093  3.1285
    95  1.0     1.0     1.0
    96  1.6705  2.1618  3.8684
    97  1.6708  2.3333  4.0833
    98  1.2684  1.7500  3.0000
    99  1.2809  1.6880  3.0776
    100  1.6705  2.1940  4.3235
    101 NaN NaN NaN
    102	NaN NaN NaN
    103	NaN NaN NaN
    104	NaN NaN NaN
    105	NaN NaN NaN
    106	NaN NaN NaN
    107	NaN NaN NaN
    108	NaN NaN NaN
    109	NaN NaN NaN
    110 NaN NaN NaN
    111	1.3279	1.8596	3.0488
    112	1.4337	2.0641	3.3926
    113	1.3965	1.9761	3.0637
    114	1.3326	1.7636	2.8234
    115	1.3153	1.7762	3.2456
    116	1.7953	2.3853	4.4396
    117	1.5444	1.8919	3.6053
    118	1.3381	1.835	3.3622
    119	1.2791	1.8063	3.0258
    120	1.8452	2.4238	4.0028
    121	1.1646	1.4239	2.5854
    122	1.4703	2.0096	3.2165
    123	1.5515	1.831	3.7812
    124	1.7296	2.4057	4.3139
    125	1.5716	1.8565	3.4763
    126	1.2971	1.5889	2.9953
    127	1.1905	1.4311	2.756
    128	1.1486	1.4505	2.525
    129	1.3454	1.7587	3.1977
    130	1.2433	1.6634	2.9262];

fid = fopen(log_info_filename,'r','b');
I = fread(fid,'uchar');
fclose(fid);
q = find(I==10,4,'first');
IDstr = char(I(q(1)+1:q(1)+4))';
IDnum = str2double(IDstr);
deviceSN = IDnum;
startDateTimeStr = char(I(q(2)+1:q(2)+14))'; % start date
startTime = datenum(startDateTimeStr,'mm-dd-yy HH:MM');

logInterval = str2double(char(I(q(3)+1:q(3)+5))');

fid = fopen(data_log_filename,'r','b');
D = fread(fid,'uint16');
fclose(fid);

R = zeros(1,floor(length(D)/4));
G = zeros(1,floor(length(D)/4));
B = zeros(1,floor(length(D)/4));
A = zeros(1,floor(length(D)/4));
UV = zeros(1,floor(length(D)/4));
for i1 = 1:floor(length(D)/4)
    R(i1) = D((i1-1)*4+1);
    G(i1) = D((i1-1)*4+2);
    B(i1) = D((i1-1)*4+3);
    A(i1) = D((i1-1)*4+4);
end
% Remove resets (value = 65278) and unwritten (value = 65535)
resets = find(R==65278);
if (isempty(resets))
    disp('Number of resets = 0');
else
    disp(['Number of resets = ' num2str(length(resets))]);
end
q = find(R~=65278 & R~=65535 & UV~=65535); % remove reset markers
R = R(q);
G = G(q);
B = B(q);
A = A(q);

time = (1:length(R))/(1/logInterval*60*60*24)+startTime;

% Calibrate activity index in units of rms g-force
% raw activity is a mean squared value, 1 count = .0039 g's, and 
% the 4 comes from four right shifts in the source code
activity = (sqrt(A))*.0039*4;

%calibrate to illuminant A
red = R*RGBcalFactors(IDnum,2);
green = G*RGBcalFactors(IDnum,3);
blue = B*RGBcalFactors(IDnum,4);

%************************************************************************
% Calculate illuminance (lux), circadian light (CLA) and circadian stimulus
% (CS)

% RGB weighting constants for each response
Sm = [-0.005701	-0.014015	0.241859]; % Scone/macula
Vm = [0.381876	0.642883	0.067544]; % Vlamda/macula (L+M cones)
M = [0.000254	0.167237	0.261462]; % Melanopsin
Vp = [0.004458	0.360213	0.189536]; % Vprime (rods)
V = [0.382859	0.604808	0.017628]; % Vlamda
% Model coefficients: a2, a3, k, A
C = [0.617848	3.221534	0.265128	2.309656];

illuminance = V(1)*red + V(2)*green + V(3)*blue;
illuminance(illuminance<0) = 0;

CLA = zeros(size(illuminance));
for i1 = 1:length(red)
    RGB = [red(i1) green(i1) blue(i1)];
    Scone(i1) = sum(Sm.*RGB);
    Vmaclamda(i1) = sum(Vm.*RGB);
    Melanopsin(i1) = sum(M.*RGB);
    Vprime(i1) = sum(Vp.*RGB);
    
    if(Scone(i1) > C(3)*Vmaclamda(i1))
        CLA(i1) = Melanopsin(i1) + C(1)*(Scone(i1) - C(3)*Vmaclamda(i1)) - C(2)*683*(1 - 2.71^(-(Vprime(i1)/(683*6.5))));
    else
        CLA(i1) = Melanopsin(i1);
    end
    
    CLA(i1) = C(4)*CLA(i1);
end
CLA(CLA < 0) = 0;




 end