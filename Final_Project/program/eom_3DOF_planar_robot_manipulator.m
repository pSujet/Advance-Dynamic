function X_dot = eom_3DOF_planar_robot_manipulator(t, X, params)

% State -------------------------------------------------------------------

theta1      = X(1);
theta1_dot  = X(2);
theta2      = X(3);
theta2_dot  = X(4);
theta3      = X(5);
theta3_dot  = X(6);

% Parameters --------------------------------------------------------------
params;
l1          = params.l1;            % Length of link 1 [m]
l2          = params.l2;            % Length of link 2 [m]
l3          = params.l3;            % Length of link 3 [m]
lcm1        = params.lcm1;          % CM position of link 1 [m]
lcm2        = params.lcm2;          % CM position of link 2 [m]
lcm3        = params.lcm3;          % CM position of link 2 [m]
m1          = params.m1;            % Mass of link 1 [kg]
m2          = params.m2;            % Mass of link 2 [kg]
m3          = params.m3;            % Mass of link 3 [kg]
I_lcm1      = params.I_lcm1;        % Moment of inertia of link 1 [kg.m^2]
I_lcm2      = params.I_lcm2;        % Moment of inertia of link 2 [kg.m^2]
I_lcm3      = params.I_lcm3;        % Moment of inertia of link 2 [kg.m^2]
kr1         = params.kr1;           % Gear ratio of motor at joint 1 [-]
kr2         = params.kr2;           % Gear ratio of motor at joint 2 [-]
kr3         = params.kr3;           % Gear ratio of motor at joint 2 [-]
m_motor1    = params.m_motor1;      % Mass of rotor at joint 1 [kg]
m_motor2    = params.m_motor2;      % Mass of rotor at joint 2 [kg]
m_motor3    = params.m_motor3;      % Mass of rotor at joint 2 [kg]
I_motor1    = params.I_motor1;      % Moment of inertia of rotor at joing 1 [kg.m^2]
I_motor2    = params.I_motor2;      % Moment of inertia of rotor at joing 2 [kg.m^2]
I_motor3    = params.I_motor3;      % Moment of inertia of rotor at joing 2 [kg.m^2]
g           = params.g;             % Gravity [m/s^2]

%% Dynamics

% B(theta)*theta_ddot + C(theta,theta_dot)*theta_dot + Fv*theta_dot + Fs*sign(theta_dot) + g(theta) = tau - J'(theta)*he

b11 = I_lcm1 + m1*lcm1^2 + kr1^2*I_motor1 + I_lcm2 + m2*(l1^2 + lcm2^2 + 2*l1*lcm2*cos(theta2)) + I_motor2 + m_motor2*l1^2;
b12 = I_lcm2 + m2*(lcm2^2 + l1*lcm2*cos(theta2)) + kr2^2*I_motor2;
b13 = 0;
b21 = b12;
b22 = I_lcm2 + m2*lcm2^2 + kr2^2*I_motor2;
b23 = 0;
b31 = 0;
b32 = 0;
b33 = 0;

h = -m2*l1*lcm2*sin(theta2);

B_theta = [b11 b12 b13; 
           b21 b22 b23;
           b31 b32 b33];

C_theta_theta_dot = [ h*theta2_dot  h*(theta1_dot + theta2_dot) 0;
                     -h*theta1_dot  0 0;
                     0 0 0];
                 
G_theta = [(m1*lcm1 + m_motor2*l1 + m2*l1)*g*cos(theta1) + m2*lcm2*g*cos(theta1 + theta2);
            m2*lcm2*g*cos(theta1 + theta2);
            0];

%% Control Law        
u = zeros(3,1);

Theta_DOT = [theta1_dot; theta2_dot; theta3_dot];
Theta_DDOT = pinv(B_theta)*[ u - C_theta_theta_dot*Theta_DOT - G_theta ];

%% 

X_dot(1,1) = theta1_dot;
X_dot(2,1) = Theta_DDOT(1);
X_dot(3,1) = theta2_dot;
X_dot(4,1) = Theta_DDOT(2);
X_dot(5,1) = theta3_dot;
X_dot(6,1) = Theta_DDOT(3);

end