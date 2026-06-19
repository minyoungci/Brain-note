# Decoupled vs Standard CFG — effectiveness & leakage (s=3, N=30, paired)
model/mode      dx ΔCSF (effect)  amyloid ΔCSF (leak)  leak/effect
medcond_std    -0.0003            +0.0017              +5.35
medcond_dec    +0.0032            -0.0017              -0.53
p04_std        +0.0041            +0.0015              +0.37
p04_dec        +0.0069            +0.0025              +0.37

# Leakage reduction by DECOUPLED vs STANDARD (paired amyloid ΔCSF; >0 = decoupled leaks less)
  medcond : standard_leak=+0.0017  decoupled_leak=-0.0017  reduction=+0.0034  CI[+0.0010,+0.0059]  SIGNIF
  p04     : standard_leak=+0.0015  decoupled_leak=+0.0025  reduction=-0.0010  CI[-0.0041,+0.0022]  ns

# Effectiveness preserved? dx ΔCSF standard vs decoupled (should be comparable)
  medcond : standard_dx=-0.0003  decoupled_dx=+0.0032  Δ=+0.0035 CI[+0.0000,+0.0072]
  p04     : standard_dx=+0.0041  decoupled_dx=+0.0069  Δ=+0.0028 CI[+0.0010,+0.0046]
