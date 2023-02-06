%% Petroleum Reservoir Simulation
% Autores: Francisco Henrique da Silva Costa (francisco.henrique@aluno.unb.br)
%          Matheus Teixeira de Sousa (teixeira.sousa@aluno.unb.br)
%
% Este código gera os gráficos da malha, dos poços, das condições do
% reservatório e de células específicas.

clear all

%% Carrega os dados salvos durante a simulação

int_max = 8*12; % Intervalo de análise
[G, W, init_press, init_sat_w, final_press, final_sat_o, ...
          sat_cell_1, sat_cell_2900, sat_cell_6300, sat_cell_9350] ...
          = get_solutions_infos(int_max);

%% Imagem da malha

clf;
% Recebe os indíces das células pares
equal_index = mod(1:G.cells.num, 2) == 0;

% Insere as células por cores: amarelo para pares e azul para impares
plotGrid(G,  equal_index, 'FaceColor', 'yellow');
plotGrid(G, ~equal_index, 'FaceColor', 'blue');

% Define o tamanho e o nome dos eixos
view(30,50);
xlabel('x');
ylabel('y');
zlabel('z');

%% Imagem da malha com poço

clf;
% Reduz a visibilidade do malha
plotGrid(G, 'FaceAlpha', 0, 'EdgeAlpha', .1)

% Insere os poços
plotWell(G, W);

% Define o tamanho e o nome dos eixos
view(30,50);
xlabel('x');
ylabel('y');
zlabel('z');

%% Imagem da saturação inicial de água sem os poços

clf;
% Reduz a visibilidade do malha
plotGrid(G, 'FaceAlpha', 0, 'EdgeAlpha', .1);

% Insere as células cuja saturação for maior que 0,5
hc = plotCellData(G, init_sat_w, init_sat_w > 0.5);
drawnow;

% Cria uma colorbar e define os limites
colorbar;
caxis([0 1]);

% Define o tamanho e o nome dos eixos
view(30,50);
xlabel('x');
ylabel('y');
zlabel('z');

%% Imagem da pressão inicial com os poços

clf;
% Insere os poços
plotWell(G, W);

% Insere a pressão e cria uma colorbar
plotCellData(G, init_press);
colorbar;

% Define o tamanho e o nome dos eixos
view(30,50);
xlabel('x');
ylabel('y');
zlabel('z');

%% Imagem da saturação final de óleo 

clf;
% Reduz a visibilidade do malha
plotGrid(G, 'FaceAlpha', 0, 'EdgeAlpha', .1);

% Insere as células cuja saturação for maior que 5*10^-5
hc = plotCellData(G, final_sat_o, final_sat_o > 5*10^-5);
drawnow;

% Cria uma colorbar
colorbar;

% Define o tamanho e o nome dos eixos
view(30,50);
xlabel('x');
ylabel('y');
zlabel('z');

%% Imagem da pressão final no reservatório

clf;
% Insere os poços
plotWell(G, W);

% Insere a pressão e cria uma colorbar
plotCellData(G, final_press);
colorbar;

% Define o tamanho e o nome dos eixos
view(30,50);
xlabel('x');
ylabel('y');
zlabel('z');

%% Imagem da diferença de pressão com os poços

clf;
% Insere os poços
plotWell(G, W);

% Insere a diferença de pressão e cria uma colorbar
plotCellData(G, init_press-final_press);
colorbar;

% Define o tamanho e o nome dos eixos
view(30,50);
xlabel('x');
ylabel('y');
zlabel('z');

%% Imagem da saturação de água na célula 1

% Define a cor azul para os gráficos com água
color_w = [31/255, 119/255, 180/255];
plot_time_series_chart(50, sat_cell_1(1:51, 1), color_w);

%% Imagem da saturação de óleo na célula 2900

% Define a cor laranja para os gráficos com óleo
color_o = [255/255, 127/255, 14/255];
plot_time_series_chart(50, sat_cell_2900(1:51, 1), color_o);

%% Imagem da saturação de água na célula 6300

plot_time_series_chart(50, sat_cell_6300(1:51, 1), color_w);

%% Imagem da saturação de óleo na célula 9350

plot_time_series_chart(50, sat_cell_9350(1:51, 1), color_o);

%% Funções

% Gera os gráficos temporais
function plot_time_series_chart(int_max, data, color)
    clf;
    % Insere os dados em marcadores do tipo 'o' preenchidos
    plot(0:int_max, data, 'o', 'MarkerFaceColor', color , 'Color', color);
    
    % Ativa o grid
    grid on;
    
    % Define o nome dos eixos
    xlabel('Tempo em meses');
    ylabel('Saturação (%)');
end

% Lê os dados do arquivo salvo e retornas as variáveis
function [G, W, init_press, init_sat_w, final_press, final_sat_o, ...
          sat_cell_1, sat_cell_2900, sat_cell_6300, sat_cell_9350] ...
          = get_solutions_infos(int_max)
    
    load('data_solutions.mat');
    
    % Define o tamanho dos vetores
    sat_cell_1 = zeros(int_max+1, 1);
    sat_cell_2900 = zeros(int_max+1, 1);
    sat_cell_6300 = zeros(int_max+1, 1);
    sat_cell_9350 = zeros(int_max+1, 1);
    
    % Inicializa o primeiro elemento
    sat_cell_1(1) = s0_cells(1)*100;
    sat_cell_2900(1) = s0_cells(2)*100;
    sat_cell_6300(1) = s0_cells(3)*100;
    sat_cell_9350(1) = s0_cells(4)*100;

    % Para cada iteração, salva os valores de saturação
    for i = 2:int_max
        saturation= solutions{i}.s;
        sat_cell_1(i)=saturation(1,1)*100;
        sat_cell_2900(i)=saturation(2900,2)*100;
        sat_cell_6300(i)=saturation(6300,1)*100;
        sat_cell_9350(i)=saturation(9350,2)*100;
    end
end