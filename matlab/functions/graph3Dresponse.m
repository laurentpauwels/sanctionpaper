function graph3Dresponse(lnV_mat3d,elast,approximation,...
                    positive_val, positive_max, negative_val, negative_max)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% graph3Dresponse:
% Inputs:
%       lnVhat_mat3d  Double   simulated response lnVhat (R,N,#elast. comb) 
%       elast         Double   combination of elasticities
%       approximation int      upstream/downstream (HOT/SHOT) approximation  
%       positive_val  int      adjust. param. remove positive outliers 
%       positive_max  int      adjust. param. remove positive outliers 
%       negative_val  int      adjust. param. remove negative outliers 
%       negative_max  int      adjust. param. remove negative outliers 
% Output:
%       Graph of simulated lnV_t vs HOT implied approximation
%       Graph of simulated lnV_t vs SHOT implied approximation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


tab_ctrysect = table(elast(:,1),elast(:,2),lnV_mat3d,...
    'VariableNames',["rho","eps","lnv"]);
tab_ctrysect(tab_ctrysect.rho<0.05,:) = [];
tab_ctrysect(tab_ctrysect.eps<0.05,:) = [];

tab_ctrysect.lnv(tab_ctrysect.lnv>positive_val,:) = positive_max;
tab_ctrysect.lnv(tab_ctrysect.lnv<negative_val,:) = negative_max;

elast_rho = unique(elast(:,1));
elast_eps = unique(elast(:,2));
elast_rho(elast_rho<0.05) = [];
elast_eps(elast_eps<0.05) = [];

format shortG
fprintf('The average response in the simulations is equal #%f',...
    round(mean(tab_ctrysect.lnv,1,'omitnan'),4));

figure1 = figure;
axes1 = axes('Parent',figure1);
hold(axes1,'on');

[X,Y]=meshgrid(elast_rho,elast_eps);
Z = reshape(tab_ctrysect.lnv,size(Y));
C = Z;
surf(X,Y,Z,C)
colorbar
xlabel('${\rho}$','Interpreter','latex','FontSize',18)
ylabel('${\epsilon}$','Interpreter','latex','FontSize',18)
zlabel('$\ln V$','Interpreter','latex','FontSize',18)
hold on
lnv_response = -approximation*ones(size(Y));
mesh(X,Y,lnv_response, 'Edgecolor', 'k','FaceColor','k')

view(axes1,[-37.8381818181818 46.7999998616535]);
grid(axes1,'on');
hold(axes1,'off');

colorbar(axes1);

end