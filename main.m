%% Petroleum Reservoir Simulation
% Autores: Francisco Henrique
%          Matheus Teixeira de Sousa (teixeira.sousa@aluno.unb.br)
%
% Este c�digo cria e simula um reservat�rio de petr�leo contendo dois
% fluidos (�gua e �leo) e quatro po�os (dois produtores e dois injetores)
% ao longo de oito anos para um determinado conjuto de propriedades
% (rocha, fluidos e po�os).

mrstModule add incomp

% Cria a malha para simula��o
gravity reset on
nx = 40; % n�mero de c�lulas em x
ny = 60; % n�mero de c�lulas em y
nz = 7; % n�mero de c�lulas em z
celldim = [nx, ny, nz];
physdim = [200, 300, 35]*meter;
G = cartGrid(celldim, physdim);
G = computeGeometry(G);

% Apresenta a malha criada
clf;
plotGrid(G)
view(30,50)

%% Cria a rocha

gravity off % Disable gravity
perm = [300*10^-3, 300*10^-3, 10*10^-3]*darcy;
poro = 0.25;
rock = makeRock(G, perm, poro);

%% Cria o fluido na ordem [�gua, �leo]

viscosities = [0.00045, 0.001]*Pascal*second;
densities = [1010, 800]*kilogram/meter^3;
rel_permeability = [1.3, 1.3];
fluid = initSimpleFluid('mu' , viscosities, ...
                        'rho', densities, ...
                        'n'  , rel_permeability);

%% Cria��o dos po�os

% Produtores
cells = 1:nx*ny:12001; % Define as c�lulas na vertical de 1 a 12001
W = addWell([], G, rock, cells, ...
            'Type', 'bhp' , 'Val', 120*barsa(), ...
            'Radius', 0.5*meter, 'InnerProduct', 'ip_tpf', ...
            'Comp_i', [0, 1], 'Name', 'Prod1');

cells = 40:nx:840; % Define as c�lulas na horizontal de 40 a 840
W = addWell(W, G, rock, cells, 'Dir', 'x', ...
            'Type', 'bhp' , 'Val', 120*barsa(), ...
            'Radius', 0.5*meter, 'InnerProduct', 'ip_tpf', ...
            'Comp_i', [0, 1], 'Name', 'Prod2');

% Injetores
cells = 15961:nx:16761; % Define as c�lulas na horizontal de 15961 a 16761
W = addWell(W, G, rock, cells, 'Dir', 'x', ...
            'Type', 'bhp' , 'Val', 210*barsa(), ...
            'Radius', 0.5*meter, 'InnerProduct', 'ip_tpf', ...
            'Comp_i', [1, 0], 'Name', 'Inje1');

cells = 12000:nx*ny:16800; % Define as c�lulas na vertical de 12000  a 16800
W = addWell(W, G, rock, cells, ...
            'Type', 'bhp' , 'Val', 210*barsa(), ...
            'Radius', 0.5*meter, 'InnerProduct', 'ip_tpf', ...
            'Comp_i', [1, 0], 'Name', 'Inje2');

% Define as condi��es inicias do reservat�rio
p0 = 1*barsa;
s0 = [repmat([0, 1], nx*ny*5, 1); repmat([1, 0], nx*ny*2, 1)]; % 5 camadas de �leo e 2 de �gua
sol = initState(G, [], p0, s0);

% Compute transmissibility and define function handles for solvers to avoid
% having to retype parameters that stay constant throught the simulation
T = computeTrans(G, rock);
psolve = @(state) incompTPFA(state, G, T, fluid, 'wells', W);
tsolve = @(state, dT) implicitTransport(state, G, dT, rock, fluid, 'wells', W);

% Limpa o gr�fico e mostra os po�os
clf
plotGrid(G, 'FaceAlpha', 0, 'EdgeAlpha', .1)
plotWell(G, W);
view(30,50);
%% Mostra o gr�fico de press�o no reservat�rio

sol = psolve(sol);
clf;
plotCellData(G, sol.pressure)
colorbar, view(30,50)

%% Simula o reservat�rio

% Set up static parts of the plot
clf
plotGrid(G, 'FaceAlpha', 0, 'EdgeAlpha', .1)
plotWell(G, W);
view(30,50); pause(1)
hs = [];  % handle for saturation plot, empty initially

% Perform simulation
dT = 30*day;
solutions = cell(20,1);
for i = 1:20 % Simula por um tempo gen�rico
    sol = tsolve(sol, dT);
    sol = psolve(sol);
    solutions{i} = sol;
    delete(hs)
    hs = plotCellData(G, sol.s(:,2), sol.s(:,2)>0.05);
    drawnow, pause(.5)
end