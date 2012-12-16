function polarization = GetPolarization_t(hypData, target, thermal_snr)

    switch (target)
        case 'thermal'  
            %calculate the number of moles of  Xe in the thermal phantom and SNR:
            fprintf('Input the data from the thermal phantom experiment: \n')
            [mol_tp] = idealmoles(1);
            snr = hypData.getSNR();
        case 'hyper'
            %calculate the number of moles of HP Xe and SNR:
            fprintf('Input the data from the polarization test experiment: \n')
            mol_nuc=idealmoles(0);
            [snr_nuc, nuc, ~] = bringSNR();
                
            %calculate the thermal polarization constant:
            pol_tp=ThermalP(gamma,3,298);
        otherwise
    end

    %calculate the Xe polarization:
    polarization = (snr_nuc/snr_tp) * (mol_tp/mol_nuc) * pol_tp * 100;
    
    fprintf('The percent polarization of %s is %f%%\n', nuc, polarization);

end


%% Calculate moles of gas using ideal gas law
function [ntp]=idealmoles(phantom)
    R=0.08206;
    T = 298;%input('Temperature in K: ');
    
    if phantom
        P = 3;%input('Partial pressure of the nucleus in atm: ');
        V = 0.121;%input('Volume in L: ');
        b = 0.90;  %input('Isotopic abundance: ');
    else
        P = 1;
        V = 0.002;
        b = 0.26;
    end
    
    ntp = (b*P*V)/(R*T);
end

%% Calculate the polarization of the thermal phantom
function [Pth]=ThermalP(gamma,Bo,T)

    %gamma = 74.02e6;
    I = 0.5;
    hbar = 1.054571e-34;
    u = gamma*I*hbar;                       %(A/m^2)
    %Bo = 3;                                 %T
    kB = 1.380648e-23 ; %T %J/K
    %T= 300;
    Pth = (u*Bo)/(kB*T);

end

function gamma = getGamma(hypData)

    nucleus = char(hypData.parms.nucleus);
    
    gamma = -1;
    switch(nucleus)
        case '129Xe'
            gamma = 35.3e6 * (2 * pi) / 3;
        case '3He'
            gamma = 97.3e6 * (2 * pi) / 3;
        case '1H'
            gamma = 127.8e6 * (2 * pi) / 3;
        case '13C'
            gamma = 31.1e6 * (2 * pi) / 3;
        case '31P'
            gamma = 120.2e6 * (2 * pi) / 3;
    end

end