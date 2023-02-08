%% Petroleum Reservoir Simulation
% Autores: Francisco Henrique da Silva Costa (francisco.henrique@aluno.unb.br)
%          Matheus Teixeira de Sousa (teixeira.sousa@aluno.unb.br)
%
% Este código gera os gráficos da malha, dos poços, das condições do
% reservatório e de células específicas.

%% Carrega os dados salvos durante a simulação
clear all

int_max = 8*12; % Intervalo de análise
[G, W, init_press, init_sat_w, final_press, final_sat_o, ...
          sat_cell_1, sat_cell_2900, sat_cell_6300, sat_cell_9350, ...
          press_1, sat] = get_solutions_infos(int_max);

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

plot_saturation(G, init_sat_w, 0.5, true);

%% Imagem da pressão inicial com os poços

plot_pression(G, W, init_press, true);

%% Imagem da pressão inicial com os poços
%  depois do cálculo da distribuição de pressão

plot_pression(G, W, press_1, false);

%% Imagem da saturação final de óleo 

plot_saturation(G, final_sat_o, 5*10^-5, false);

%% Imagem da pressão final no reservatório

plot_pression(G, W, final_press, false);

%% Imagem da diferença de pressão com os poços

plot_pression(G, W, press_1-final_press, false);

%% Imagem da saturação de água na célula 1

% Define a cor azul para os gráficos com água
color_w = [31/255, 119/255, 180/255];
plot_time_series_data(50, sat_cell_1(1:51, 1), color_w);

%% Imagem da saturação de óleo na célula 2900

% Define a cor laranja para os gráficos com óleo
color_o = [255/255, 127/255, 14/255];
plot_time_series_data(50, sat_cell_2900(1:51, 1), color_o);

%% Imagem da saturação de água na célula 6300

plot_time_series_data(50, sat_cell_6300(1:51, 1), color_w);

%% Imagem da saturação de óleo na célula 9350

plot_time_series_data(50, sat_cell_9350(1:51, 1), color_o);

%% Imagem das células utilizadas na análise

clf;
% Reduz a visibilidade do malha
plotGrid(G, 'FaceAlpha', 0, 'EdgeAlpha', .1);

% Insere os poços
plotWell(G, W);

% Recebe os indíces das células utilizadas
index_w = [1 6300];
index_o = [2900 9350];
% Insere as células por cores: azul para água e laranja para óleo
plotGrid(G, index_w, 'FaceColor', color_w);
plotGrid(G, index_o, 'FaceColor', color_o);

% Define o tamanho e o nome dos eixos
view(30,50);
xlabel('x');
ylabel('y');
zlabel('z');

%% Gera o gif da saturação de óleo

clf;
% Reduz a visibilidade do malha e insere os poços
plotGrid(G, 'FaceAlpha', 0, 'EdgeAlpha', .1);
plotWell(G, W);

% Define a vista do gráfico
Az = 193; El = 15;
view(Az, El);
hs = [];

% Para cada iteração, salva o gráfico de saturação
for i = 1:int_max
    delete(hs);
    saturation = transpose(sat(i, :, 2));
    hs = plotCellData(G, saturation, saturation > 5*10^-5);
    caxis([0 1]); % Define os limites do heatmap
    drawnow, pause(.1);
    % Remover os comentários para salvar as imagens
%     name = ['gif_sat/img_' num2str(i) '.png'];
%     print(gcf, name, '-dpng', '-r800');
end

%% Funções

% Gera os gráficos temporais
function plot_time_series_data(int_max, data, color)
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
          sat_cell_1, sat_cell_2900, sat_cell_6300, sat_cell_9350, ...
          press_1, sat] = get_solutions_infos(int_max)
    
    load('data_solutions.mat');
    
    % Define o tamanho dos vetores
    sat_cell_1 = zeros(int_max+1, 1);
    sat_cell_2900 = zeros(int_max+1, 1);
    sat_cell_6300 = zeros(int_max+1, 1);
    sat_cell_9350 = zeros(int_max+1, 1);
    sat = zeros(int_max+1, length(init_press), 2);
    
    % Inicializa o primeiro elemento
    sat(1, :, 1) = sat_0(:, 1);
    sat(1, :, 2) = sat_0(:, 2);
    sat_cell_1(1) = s0_cells(1)*100;
    sat_cell_2900(1) = s0_cells(2)*100;
    sat_cell_6300(1) = s0_cells(3)*100;
    sat_cell_9350(1) = s0_cells(4)*100;

    % Para cada iteração, salva os valores de saturação
    for i = 2:int_max
        saturation= solutions{i}.s;
        sat(i, :, 1) = saturation(:, 1);
        sat(i, :, 2) = saturation(:, 2);
        sat_cell_1(i)=saturation(1,1)*100;
        sat_cell_2900(i)=saturation(2900,2)*100;
        sat_cell_6300(i)=saturation(6300,1)*100;
        sat_cell_9350(i)=saturation(9350,2)*100;
    end
end

% Gera os gráficos de saturação
function plot_saturation(G, data, value, control)
    clf;
    % Reduz a visibilidade do malha
    plotGrid(G, 'FaceAlpha', 0, 'EdgeAlpha', .1);

    % Insere as células cuja saturação for maior que um valor
    hc = plotCellData(G, data, data > value);
    drawnow;

    % Cria uma colorbar
    colorbar;
    if control
        caxis([0 1]);
    end

    % Define o tamanho e o nome dos eixos
    view(30,50);
    xlabel('x');
    ylabel('y');
    zlabel('z');
end

% Gera os gráficos de pressão
function plot_pression(G, W, data, control)
    clf;
    % Insere os poços
    plotWell(G, W);

    % Insere a pressão e cria uma colorbar
    plotCellData(G, data);
    colorbar;
    
    % Regula o intervalo da colorbar
    if control
        caxis([0 1*10^5]);
    end

    % Define o tamanho e o nome dos eixos
    view(30,50);
    xlabel('x');
    ylabel('y');
    zlabel('z');
end