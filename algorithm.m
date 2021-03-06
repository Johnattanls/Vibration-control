clear all
close all
clc
 
%% Parâmetros do problema
 
W = 0.15; % Profundidade, [m]
L = 0.20; % Largura, [m]
Hs = [0.15 0.17 0.15]; % Alturas dos andares sem neutralizador [m]
ew = 0.001; % Espessura da parede, [m]
ef = 0.009; % Espessura do piso, [m]
I = W*ew^3/12; % Momento de Inercia, []
m_ads = [0 0.696 0]; % Massa adicional sem neutralizador, [kg]
E = 205.0e9; % Módulo de elasticidade, [Pa]
rho = 7589; % Densidade, [kg/m³]
eta = 0.015; % Coeficiente de amortecimento estrutural, [-]


 
%% Cálculos para a matriz de massa
 
meq_cs = (13/35)*rho*ew*W*Hs; % Vetor massa equivalente de uma coluna por andar 
meq_ps = rho*W*L*ef; % Escalar massa equivalente do piso sem neutralizador
m_eqs = m_ads + 2*meq_cs+ meq_ps; %Vetor massa equivalente sem neutralizador
Ms = diag(m_eqs); % Matriz de massa sem neutralizador


 
%% Cálculos para a matriz de rigidez
 
keq_cs = 2*5*E*I./(Hs.^3);% Rigidez equivalente de duas colunas sem neutralizador
 
As=zeros(3,3); % Matriz de flexibilidade sem neutralizador
 
As(1,1) = 1/keq_cs(1);  
As(1,2) = 1/keq_cs(1); 
As(1,3) = 1/keq_cs(1); 
 
As(2,1) = (1/keq_cs(1));
As(2,2) = 1/keq_cs(1)+1/keq_cs(2);  
As(2,3) = 1/keq_cs(1)+1/keq_cs(2);
 
As(3,1) = (1/keq_cs(1));
As(3,2) = (1/keq_cs(1)+1/keq_cs(2));
As(3,3) = (1/keq_cs(1)+1/keq_cs(2)+1/keq_cs(3));
 
Ks=inv(As); % Matriz de rigidez


 
%% Definição de autovalores e autovetores sem neutralizador
 
[Xs,Ds]=eig(Ks,Ms);
wns = diag(Ds.^(1/2)); % Frequencia natural, [rad/s]
fns = wns/(2*pi); % Frequencia natural, [Hz]
 


%% Frequências naturais experimentais
 
fn_exp1 = 3.88;
fn_exp2 = 11.55;
fn_exp3 = 16.63;
fn_exp = [fn_exp1 fn_exp2 fn_exp3];


 
%% Gráfico das frequencias naturais - sem neutralizador
 
 figure(1)
 aux=ones(3,1);
 stem(fns,aux,'filled','Linewidth',1.5);
 ylim([0 1.5]);
 xlim([0 40]);
 xlabel(['$Frequencia$ [Hz]'],'interpreter','latex');
 set(gca,'ytick',[]);
 text(fns-0.01,aux+0.1,strcat(num2str(fns,3)))
 grid on;
grid minor;
 saveas(gcf, ['.\plots\fig1.png'])
 
 figure(2)
 aux=ones(3,1);
 stem(fns,aux,'filled','Linewidth',1.5);
 hold on
 stem(fn_exp,aux,'filled','-.', 'Color', 'k', 'Linewidth',1.5);
 ylim([0 1.5]);
 xlim([0 40]);
 xlabel(['$Frequencia$ [Hz]'],'interpreter','latex');
legend('Ajuste','Experimental')
 set(gca,'ytick',[]);
%  text(fn-0.01,aux+0.1,strcat(num2str(fn,3)))
%  text(fn2-0.01,aux2+0.1,strcat(num2str(fn2,3)))
 grid on;
 grid minor;
 saveas(gcf, ['.\plots\fig1_comp2.png'])
 
 
%% Gráfico das formas modais sem neutralizador
 
indexess=[0 1 2 3];
auxs=zeros(1,3);
X_mods=[auxs; Xs];
 
figure(3)
subplot(1, 3, 1)
plot(X_mods(:,1), indexess, '.-','MarkerSize',20)  
ylabel(['$Andar$'],'interpreter','latex')
set(gca,'YTick',[0:1:3])
xlabel(['$Amplitude$'],'interpreter','latex')
title(['$Primeiro \hspace{1mm} modo$'],'interpreter','latex')
grid on;
xlim([-0.6 0.6]);
 
subplot(1, 3, 2)
plot(X_mods(:,2), indexess, '.-','MarkerSize',20) 
grid on;
ylabel(['$Andar$'],'interpreter','latex')
set(gca,'YTick',[0:1:3])
xlabel(['$Amplitude$'],'interpreter','latex')
title(['$Segundo \hspace{1mm} modo$'],'interpreter','latex')
grid on;
xlim([-0.6 0.6]);
 
subplot(1, 3, 3)
plot(X_mods(:,3), indexess, '.-','MarkerSize',20)
ylabel(['$Andar$'],'interpreter','latex')
set(gca,'YTick',[0:1:3])
xlabel(['$Amplitude$'],'interpreter','latex')
ylabel(['$Andar$'],'interpreter','latex')
title(['$Terceiro \hspace{1mm} modo$'],'interpreter','latex')
grid on;
xlim([-0.6 0.6]);
saveas(gcf, ['.\plots\fig3.png'])
 


%%% Cálculo da receptancia e da mobilidade
 
 
%% Resposta no segundo andar quando uma força é aplicada no terceiro andar SEM NEUTRALIZADOR
 
ws = 2*pi*(0:0.01:40); %vetor frequências [rad/s]     incremento foi aumentado para melhorar a visualização
Hs_23 = zeros(length(ws),1); %vetor magnitudes da receptância 
Ys_23 = zeros(length(ws),1); %vetor magnitudes da mobilidade
 
for k = 1:length(ws)
    for n = 1:3
      Hs_23(k) = (Hs_23(k) + (Xs(2,n)*Xs(3,n))/(wns(n)^2-ws(k)^2+i*eta*(wns(n))^2));
    end
      Ys_23(k) = i*ws(k)*Hs_23(k);
      As_23(k) = -ws(k)^2*Hs_23(k);
end
 


% % Gráfico das receptâncias
 
  figure(4)
  semilogy(ws/(2*pi),abs(Hs_23), 'Color', [98 122 177]/255,'LineWidth', 1.5);
  hold on;
  ylabel('$|\tilde{H}| \hspace{1mm} [N/m]$ ','interpreter','latex');
  xlabel('$Frequency$, [Hz]','interpreter','latex');
  legend({'${\tilde{H}}_{23}$'},'interpreter','latex');
  grid on;
  grid minor
  saveas(gcf, ['.\plots\fig4.png'])
   


  %% Gráfico das acelerâncias SEM NEUTRALIZADOR
 
figure(5)
semilogy(ws/(2*pi),abs(As_23),'Color', [193 90 99]/255,'LineWidth', 1.5);
hold on;
ylabel('$|\tilde{A}| \hspace{1mm} [N.s^2/m]$ ','interpreter','latex');
xlabel('$Frequency$, [Hz]','interpreter','latex');
legend({'$\tilde{A}_{23}$'},'interpreter','latex');
grid on;
saveas(gcf, ['.\plots\fig5.png'])
 


%% Carregar dados do experimento dos txt %%
 
FRF13 = dlmread(['.\FRF1.txt']);
FRF23 = dlmread(['.\FRF2.txt']);
FRF33 = dlmread(['.\FRF3.txt']);
 

%% Conversão dos dados experimentais para o formato específico %%
 
g = 9.81; % Aceleração da gravidade, [m/s²]
 
FRF13(:,2) = FRF13(:,2)*g;
FRF13(:,3) = FRF13(:,3)*g;
FRF23(:,2) = FRF23(:,2)*g;
FRF23(:,3) = FRF23(:,3)*g;
FRF33(:,2) = FRF33(:,2)*g;
FRF33(:,3) = FRF33(:,3)*g;
 


%% Acelerâncias Experimentais 
 
A_23_exp(:,1) = FRF23(:,1);
A_23_exp(:,2) = FRF23(:,2)+i*FRF23(:,3);
 


%% Mobilidade Experimental
 
Y_23_exp(:,1) = A_23_exp(:,1);
 
Y_23_exp(:,1) = A_23_exp(:,1);
Y_23_exp(:,2) = -i*A_23_exp(:,2)./(Y_23_exp(:,1)*2*pi);
 


%% Gráfico da Acelerancia
 
figure(6)
semilogy(A_23_exp(:,1),abs(A_23_exp(:,2)),'-.','Color', [98 122 177]/255,'LineWidth', 1.5);
ylabel('$|\tilde{A}| \hspace{1mm} [N.s^2/m]$ ','interpreter','latex');
xlabel('$Frequency$, [Hz]','interpreter','latex');
legend({'$\tilde{A}_{23} \hspace{1mm} Exp$'},'interpreter','latex');
xlim([0 40])
ylim([0.0001 50])
grid on;
saveas(gcf, ['.\plots\fig6.png'])
 
figure(7)
semilogy(ws/(2*pi),abs(As_23),'Color', [98 122 177]/255,'LineWidth', 1.5);
hold on;
semilogy(A_23_exp(:,1),abs(A_23_exp(:,2)),'-.','Color', [98 122 177]/255,'LineWidth', 1.5);
ylabel('$|\tilde{A}| \hspace{1mm} [N.s^2/m]$ ','interpreter','latex');
xlabel('$Frequency$, [Hz]','interpreter','latex');
legend({'$\tilde{A}_{23} \hspace{1mm} Model$','$\tilde{A}_{23} \hspace{1mm} Exp$'},'interpreter','latex');
xlim([0 40])
ylim([0.0001 10])
grid on;
saveas(gcf, ['.\plots\fig7.png'])
 


% % % % % % % Neutralizador % % % % % % % % 
 
%% Parâmetros do problema
m_ad = [0 0.696 0 0]; % Massa adicional com netralizador, [kg]
m_neu = [0 0 0 0.2]; % Massa do neutralizador
H = [0.15 0.17 0.15 0]; % Alturas dos andares com neutralizador[m]
 

%% Cálculos para a matriz de massa
z = [1 1 1 0]; %para zerar a massa do piso no neutralizador 
meq_c = (13/35)*rho*ew*W*H; % Vetor massa equivalente de uma coluna por andar 
meq_p = z*rho*W*L*ef; % Escalar massa equivalente do piso
m_eq = m_ad + 2*meq_c+ meq_p + m_neu;% Vetor massa equivalente
M = diag(m_eq); % Matriz de massa
 

%% Cálculos para a matriz de rigidez
 
keq_c = 2*12*E*I./(H.^3);% Rigidez equivalente de duas colunas
keqn=(wns(2)*wns(2))*m_neu(4); % Rigidez equivalente do neutralizador - otimizado na proxima versão
kneut = [0 0 0 keqn]; % Rigidez do neutralizador
 
A=zeros(4,4); % Matriz de flexibilidade com neutralizador
 
A(1,1) = 1/keq_c(1);  
A(1,2) = 1/keq_c(1); 
A(1,3) = 1/keq_c(1); 
A(1,4) = 1/keq_c(1);
 
A(2,1) = (1/keq_c(1));
A(2,2) = 1/keq_c(1)+1/keq_c(2);  
A(2,3) = 1/keq_c(1)+1/keq_c(2);
A(2,4) = 1/keq_c(1)+1/keq_c(2);
 
A(3,1) = (1/keq_c(1));
A(3,2) = (1/keq_c(1)+1/keq_c(2));
A(3,3) = (1/keq_c(1)+1/keq_c(2)+1/keq_c(3));
A(3,4) = (1/keq_c(1)+1/keq_c(2)+1/keq_c(3));
 
A(4,1) = (1/keq_c(1));
A(4,2) = (1/keq_c(1)+1/keq_c(2));
A(4,3) = (1/keq_c(1)+1/keq_c(2)+1/keq_c(3));
A(4,4) = (1/keq_c(1)+1/keq_c(2)+1/keq_c(3)+1/kneut(4));
 
K=inv(A); % Matriz de rigidez
 
 
%% Definição de autovalores e autovetores
 
[X,D]=eig(K,M);
wn = diag(D.^(1/2)); % Frequencia natural, [rad/s]
fn = wn/(2*pi); % Frequencia natural, [Hz]
 

%% Gráfico das formas modais
 
indexes=[0 1 2 3 4];
aux=zeros(1,4);
X_mod=[aux; X];
 
figure(8)
subplot(1, 4, 1)
plot(X_mod(:,1), indexes, '.-','MarkerSize',20)  
ylabel(['$Andar$'],'interpreter','latex')
set(gca,'YTick',[0:1:4])
xlabel(['$Amplitude$'],'interpreter','latex')
title(['$Primeiro \hspace{1mm} modo$'],'interpreter','latex')
grid on;
xlim([-0.6 0.6]);
 
subplot(1, 4, 2)
plot(X_mod(:,2), indexes, '.-','MarkerSize',20) 
grid on;
ylabel(['$Andar$'],'interpreter','latex')
set(gca,'YTick',[0:1:4])
xlabel(['$Amplitude$'],'interpreter','latex')
title(['$Segundo \hspace{1mm} modo$'],'interpreter','latex')
grid on;
xlim([-3 3]);
 
subplot(1, 4, 3)
plot(X_mod(:,3), indexes, '.-','MarkerSize',20)
ylabel(['$Andar$'],'interpreter','latex')
set(gca,'YTick',[0:1:4])
xlabel(['$Amplitude$'],'interpreter','latex')
ylabel(['$Andar$'],'interpreter','latex')
title(['$Terceiro \hspace{1mm} modo$'],'interpreter','latex')
grid on;
xlim([-0.6 0.6]);
 
subplot(1, 4, 4)
plot(X_mod(:,4), indexes, '.-','MarkerSize',20)
ylabel(['$Andar$'],'interpreter','latex')
set(gca,'YTick',[0:1:4])
xlabel(['$Amplitude$'],'interpreter','latex')
ylabel(['$Andar$'],'interpreter','latex')
title(['$Quarto \hspace{1mm} modo$'],'interpreter','latex')
grid on;
xlim([-0.6 0.6]);
saveas(gcf, ['.\plots\fig8.png'])
 


%% Resposta no segundo andar quando uma força é aplicada no terceiro andar
 
w = 2*pi*(0:0.01:40); %vetor frequências [rad/s] mudei o incremento
H_23 = zeros(length(w),1); %vetor magnitudes da receptância 
Y_23 = zeros(length(w),1); %vetor magnitudes da mobilidade
 
for k = 1:length(w)
    for n = 1:4
      H_23(k) = (H_23(k) + (X(2,n)*X(3,n))/(wn(n)^2-w(k)^2+i*eta*(wn(n))^2));
    end
      Y_23(k) = i*w(k)*H_23(k);
      A_23(k) = -w(k)^2*H_23(k);
end
 


% % Gráfico das receptâncias
 
  figure(9)
  semilogy(w/(2*pi),abs(H_23), 'Color', [98 122 177]/255,'LineWidth', 1.5);
  hold on;
  ylabel('$|\tilde{H}| \hspace{1mm} [N/m]$ ','interpreter','latex');
  xlabel('$Frequency$, [Hz]','interpreter','latex');
  legend({'${\tilde{H}}_{23}$'},'interpreter','latex');
  grid on;
  grid minor
  saveas(gcf, ['.\plots\fig9.png'])


 %% Gráfico das mobilidades
 
  figure(10)
  semilogy(w/(2*pi),abs(Y_23),'Color', [98 122 177]/255,'LineWidth', 1.5);
  hold on;
  ylabel('$|\tilde{Y}| \hspace{1mm} [N.s/m]$ ','interpreter','latex');
  xlabel('$Frequency$, [Hz]','interpreter','latex');
  legend({'$\tilde{Y}_{23}$'},'interpreter','latex');
  grid on;
  saveas(gcf, ['.\plots\fig10.png'])
  


  %% Gráficos das acelerâncias COM NEUTRALIZADOR
 
figure(11)
semilogy(w/(2*pi),abs(A_23),'Color', [98 122 177]/255,'LineWidth', 1.5);
hold on;
ylabel('$|\tilde{A}| \hspace{1mm} [N.s^2/m]$ ','interpreter','latex');
xlabel('$Frequency$, [Hz]','interpreter','latex');
legend({'$\tilde{A}_{23}$'},'interpreter','latex');
grid on;
saveas(gcf, ['.\plots\fig11.png'])
 


%% Gráficos das acelerâncias COM e SEM NEUTRALIZADOR
 
figure(12)
semilogy(w/(2*pi),abs(A_23),'Color', [98 122 177]/255,'LineWidth', 1.5);
hold on;
semilogy(ws/(2*pi),abs(As_23),'Color', [193 90 99]/255,'LineWidth', 1.5);
ylabel('$|\tilde{A}| \hspace{1mm} [N.s^2/m]$ ','interpreter','latex');
xlabel('$Frequency$, [Hz]','interpreter','latex');
legend({'$\tilde{A}_{23}$','$\tilde{As}_{23}$'},'interpreter','latex');
grid on;
saveas(gcf, ['.\plots\fig12.png'])