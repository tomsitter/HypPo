function taxis = timeAxis(data)

%t_dwell = 1 / data.parms.sample_frequency;

t_dwell = data.parms.dim1_step;
x = data.parms.samples;

taxis = t_dwell:t_dwell:x*t_dwell;
