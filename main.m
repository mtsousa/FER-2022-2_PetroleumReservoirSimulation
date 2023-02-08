%% Petroleum Reservoir Simulation
% Autores: Francisco Henrique da Silva Costa (francisco.henrique@aluno.unb.br)
%          Matheus Teixeira de Sousa (teixeira.sousa@aluno.unb.br)
%
% Este código cria e simula um reservatório de petróleo contendo dois
% fluidos (água e óleo) e quatro poços (dois produtores e dois injetores)
% ao longo de oito anos para um determinado conjuto de propriedades
% (rocha, fluidos e poços).

mrstModule add incomp

% Cria a malha para simulação
gravity reset on
nx = 40; % número de células em x
ny = 60; % número de células em y
nz = 7; % número de células em z
celldim = [nx, ny, nz];
physdim = [200, 300, 35]*meter;
G = cartGrid(celldim, physdim);
G = computeGeometry(G);

%% Cria a rocha

gravity off % Desabilita a gravidade
perm = [300*10^-3, 300*10^-3, 10*10^-3]*darcy;
poro = 0.25;
rock = makeRock(G, perm, poro);

%% Cria o fluido na ordem [água, óleo]
% Todos os parâmetros recebem o valor da água e depois do óleo

viscosities = [0.00045, 0.001]*Pascal*second;
densities = [1010, 800]*kilogram/meter^3;
rel_permeability = [1.3, 1.3];
fluid = initSimpleFluid('mu' , viscosities, ...
                        'rho', densities, ...
                        'n'  , rel_permeability);

%% Criação dos poços
% Todos os poços são controlados por BHP com o valor definido no problema,
% os produtores são saturados com óleo e os injetores com água e todos
% possuem raio de 0,5 metros. Quando a direção não é definida, o poço
% é vertical (diração z).

% Produtores
cells = 1:nx*ny:12001; % Define as células na vertical de 1 a 12001
W = addWell([], G, rock, cells, ...
            'Type', 'bhp' , 'Val', 120*barsa, ...
            'Radius', 0.5*meter, 'InnerProduct', 'ip_tpf', ...
            'Comp_i', [0, 1], 'Name', 'Prod1');

cells = 40:nx:840; % Define as células na horizontal de 40 a 840
W = addWell(W, G, rock, cells, 'Dir', 'x', ...
            'Type', 'bhp' , 'Val', 120*barsa, ...
            'Radius', 0.5*meter, 'InnerProduct', 'ip_tpf', ...
            'Comp_i', [0, 1], 'Name', 'Prod2');

% Injetores
cells = 15961:nx:16761; % Define as células na horizontal de 15961 a 16761
W = addWell(W, G, rock, cells, 'Dir', 'x', ...
            'Type', 'bhp' , 'Val', 210*barsa, ...
            'Radius', 0.5*meter, 'InnerProduct', 'ip_tpf', ...
            'Comp_i', [1, 0], 'Name', 'Inje1');

cells = 12000:nx*ny:16800; % Define as células na vertical de 12000  a 16800
W = addWell(W, G, rock, cells, ...
            'Type', 'bhp' , 'Val', 210*barsa, ...
            'Radius', 0.5*meter, 'InnerProduct', 'ip_tpf', ...
            'Comp_i', [1, 0], 'Name', 'Inje2');

% Define as condições inicias do reservatório
p0 = 1*barsa;
% Saturação inicial como 5 camadas de óleo e 2 de água
s0 = [repmat([0, 1], nx*ny*5, 1); repmat([1, 0], nx*ny*2, 1)];
sol = initState(G, [], p0, s0);

% Cria as funções auxiliares para solução da simulação
% e calcula a transmissibilidade
T = computeTrans(G, rock);
psolve = @(state) incompTPFA(state, G, T, fluid, 'wells', W);
tsolve = @(state, dT) implicitTransport(state, G, dT, rock, fluid, 'wells', W);

%% Salva as condições inciais

% Salva os valores de saturação e pressão iniciais
init_sat_w = sol.s(:,1);
init_press = sol.pressure;

% Salva a saturação inicial de células específicas
saturation = sol.s;
sat_0 = saturation;
sat_cell_1 = saturation(1,1);
sat_cell_2900 = saturation(2900,2);
sat_cell_6300 = saturation(6300,1);
sat_cell_9350 = saturation(9350,2);
s0_cells = [sat_cell_1, sat_cell_2900, sat_cell_6300, sat_cell_9350];

%% Simula o reservatório

% Define o passo de tempo (dT) e o intervalo de simulação (int_max)
dT = 30*day;
int_max = 12*8; % Considera todos os meses com 30 dias
solutions = cell(int_max,1);

% Para cada iteração, salva os dados num vetor
sol = psolve(sol);
% Salva a pressão depois do cálculo da distribuição de pressão
press_1 = sol.pressure;
for i = 1:int_max
    sol = tsolve(sol, dT);
    sol = psolve(sol);
    solutions{i} = sol;
end

% Salva as condições finais de saturação e pressão
final_sat_o = sol.s(:, 2);
final_press = sol.pressure;

% Salva um arquivo com os dados para análise
save('data_solutions.mat', 'solutions', 'G', 'W', 'init_press', ...
     'init_sat_w', 'final_press', 'final_sat_o', 's0_cells', ...
     'press_1', 'sat_0');