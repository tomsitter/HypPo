function eqt = fitFID(dpts)

    x = 1:length(dpts);

    s = exp2fit(x, dpts, 1);
    fun = @(s,x) s(1)+s(2)*exp(-x/s(3));

    ff = fun(s, x);
    hold on
    plot(x, ff, ':');
    hold off
    
    eqt = sprintf('%.3f + %.3f * exp(-x/%.3f)', s(1), s(2), s(3));
    
end