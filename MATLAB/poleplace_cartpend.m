% Author: Steve Brunton (adapted by Minh Nguyen)
% Date: May 23, 2024
% Description:

clear all
close all
clc

m = 1;
M = 5;
L = 2;
g = -10;
d = 1;

s = 1; % For pendulum up position, s = 1

A = [0 1 0 0;
    0 -d/M s*m*g/M 0;
    0 0 0 1;
    0 -s*d/(M*L) -s*(m+M)*g/(M*L) 0];

B = [0; 1/M; 0; s/(M*L)];

%% Stability Check
lambda = eig(A);

%% Controllability Test
disp(['Controllability matrix rank: ' , num2str(rank(ctrb(A,B)))])

%% Pole placement
% p is a vector of desired eigenvalues
% p = [-.01; -.02; -.03; -.04]; % not enough
p = [-.3; -.4; -.5; -.6];     % just barely
% p = [-1; -1.1; -1.2; -1.3];   % good
% p = [-2; -2.1; -2.2; -2.3];   % aggressive
% p = [-3; -3.1; -3.2; -3.3];   % aggressive
% p = [-3.5; -3.6; -3.7; -3.8]; % breaks
K_pp = place(A,B,p); 


Q = eye(4);
R = 0.0001;

K_lqr = lqr(A,B,Q,R);

% Recheck the eigenvalues
eigenval = eig(A-B*K_pp)';

tspan = 0:0.01:50;

if (s == -1) % Down position
    y0 = [0; 0; 0; 0]; % Initial position
    yref = [4; 0; 0; 0]; % Reference (desired) state
    [t,y] = ode45(@(t,y)cartpend(y,m,M,L,g,d,-K_pp*(y - [4; 0; 0; 0])), tspan, y0);
elseif (s == 1) % Up position
    y0 = [-3; 0; pi + 0.01; 0];
    yref = [1; 0; pi; 0];
    [t,y] = ode45(@(t,y)cartpend(y,m,M,L,g,d,-K_pp*(y - [1; 0; pi; 0])), tspan, y0);
else
end

for k = 1:100:length(t)
    drawcartpend_bw(y(k,:),m,M,L);
end

title_list = ["$x$", "$\dot x$", "$\theta$", "$\dot \theta$"];
figure()
for i = 1:4
%     subplot(4,1,i)
    plot(t,y(:,i),'LineWidth',2); hold on
end
grid minor
xlabel('Time (s)')
legend(title_list,'location','best','Interpreter','latex')
hold off

