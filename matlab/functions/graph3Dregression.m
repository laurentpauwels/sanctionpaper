function graph3Dregression(lnVhat_mat3d, lnV_mat3d, elast,io_plotfolder)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% graph3Dregression:
% 1. Regress the simulated responses to a transport cost shock on the
%    approximate simulated responses. The regressions coefficient beta and 
%    the R2 are extracted.
% 2. Construct 3D graph surface for a selection of elasticities rho and 
%    epsilon, and save the graphs in io_plotfolder.
% Inputs:
%       lnVhat_mat3d  Double   approx. response lnVhat (R,N,#elast. comb) 
%       lnV_mat3d     Double   simulated response lnVhat (R,N,#elast. comb) 
%       elast         Double   combination of elasticities
%       io_plotfolder Char     path for saving graphs
% Output:
%       Graph of beta from regressing lnV_t on (alpha*psi)/(1+psi)lnPY_t
%       Graph of R2 from regressing lnV_t on (alpha*psi)/(1+psi)lnPY_t 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nelastcomb = size(elast,1);

%% Regressions

%NxR reshape
lnVhat_nr = reshape(lnVhat_mat3d,[],nelastcomb);
lnV_nr = reshape(lnV_mat3d,[],nelastcomb);

beta = zeros(nelastcomb,1);
R2 = zeros(nelastcomb,1);
for i = 1:nelastcomb
    [b,~,~,~,stats] = regress(lnV_nr(:,i),[lnVhat_nr(:,i),ones(size(lnV_nr,1),1)]);
    beta(i,1) = b(1,1);
    R2(i,1) = stats(1,1);
end

elast_rho = unique(elast(:,1));
elast_eps = unique(elast(:,2));

%% 3D Graphs
%Beta

betapos = beta;
betapos(betapos<0) = 0;
figure_beta = figure;
axes_beta = axes('Parent',figure_beta);
hold(axes_beta,'on');

[Xb,Yb]=meshgrid(elast_rho,elast_eps);
Zb = reshape(betapos,size(Yb));
Cb = Zb;
surf(Xb,Yb,Zb,Cb)
colorbar
xlabel('${\rho}$','Interpreter','latex','FontSize',18)
ylabel('${\epsilon}$','Interpreter','latex','FontSize',18)
zlabel('$\hat{\beta}$','Interpreter','latex','FontSize',18, 'Rotation',10)

view(axes_beta,[-127.456363636364 28.2]);
grid(axes_beta,'on');
hold(axes_beta,'off');
colorbar(axes_beta);

% Save graph
exportgraphics(figure_beta,fullfile(io_plotfolder,'beta.jpg'));


%R2
figure_r2 = figure;
axes_r2 = axes('Parent',figure_r2);
hold(axes_r2,'on');

[Xr,Yr]=meshgrid(elast_rho,elast_eps);
Zr = reshape(R2,size(Yr));
Cr = Zr;
surf(Xr,Yr,Zr,Cr)
colorbar
xlabel('${\rho}$','Interpreter','latex','FontSize',18)
ylabel('${\epsilon}$','Interpreter','latex','FontSize',18)
zlabel('$R^2$','Interpreter','latex','FontSize',18, 'Rotation',0)

view(axes_r2,[-127.456363636364 28.2]);
grid(axes_r2,'on');
hold(axes_r2,'off');
colorbar(axes_r2);

% Save graph
exportgraphics(figure_r2,fullfile(io_plotfolder,'r2.jpg'));
end