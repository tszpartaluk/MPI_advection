function zapiszpdf(fig,x,y,nazwa)

set(fig,'PaperUnits','centimeters');
set(fig,'Units','centimeters');
set(fig,'PaperSize',[x y]);
set(fig,'OuterPosition',[0 0 x y]);
saveas(fig,nazwa,'pdf')

end