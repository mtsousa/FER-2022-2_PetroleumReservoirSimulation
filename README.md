# FER-2022-2_PetroleumReservoirSimulation

Simulação de reservatório de petróleo utilizando MRST no contexto da disciplina Fundamentos de Engenharia de Reservatório da Universidade de Brasília.

## Objetivo

O trabalho tem por objetivo criar e simular um reservatório contendo dois fluidos (água e óleo) e quatro poços (dois produtores e dois injetores) ao longo de oito anos para um determinado conjuto de propriedades (rocha, fluidos e poços).

## Características do reservatório

### Malha
- Tamanho da malha: 40x60x7;
- Dimensão: 200x300x35 metros;
- As duas camadas mais profundas saturadas com água;
- As cinco camadas superiores saturadas com óleo;
- Pressão inicial de 1 bar;

### Rocha
- Permeabilidade: x = y = 300 mD, z = 10 mD;
- Porosidade = 0,25;

### Fluidos
- Viscosidade dinâmica da água: 0,00045 Pa.s;
- Massa específica da água: 1010 kg/m^3;
- Viscosidade dinâmica da óleo: 0.001 Pa.s;
- Massa específica da óleo: 800 kg/m^3;
- Permeabilidade relativa para os dois fluidos: 1,3;

### Poços
- Produtor 1: vertical (células 1 a 12001), controlado por BHP (120 bar);
- Produtor 2: horizontal (células 40 a 840), controlado por BHP (120 bar);
- Injetor 1: horizontal (células 15961 a 16761), controlado por BHP (210 bar);
- Injetor 2: vertical (células 12000 a 16800), controlado por BHP (210 bar);

## Resultados

|  Saturação de óleo ao longo do tempo  |
|:-------------------------------------:|
|           ![](imgs/sat.gif)           |
