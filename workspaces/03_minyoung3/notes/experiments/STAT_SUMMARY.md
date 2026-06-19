# decoupled-CFG per-axis readout — subject-bootstrap 95% CI (s=3, N=30, B=10000)
axis           mean                  95% CI    %>0  CI>0?
age        +0.0112  [+0.0076, +0.0148]    80%  YES
dx         +0.0069  [+0.0043, +0.0097]    70%  YES
cdr        +0.0030  [-0.0000, +0.0060]    63%  no
memory     +0.0023  [-0.0014, +0.0062]    57%  no
amyloid    +0.0025  [-0.0007, +0.0060]    47%  no
executive  +0.0013  [-0.0018, +0.0044]    53%  no
wmh        +0.0020  [-0.0016, +0.0057]    53%  no
mmse       +0.0025  [-0.0008, +0.0056]    60%  no
apoe       +0.0005  [-0.0026, +0.0037]    40%  no

# GROUP test — atrophy(age,dx,cdr) vs T1-blind(memory,amyloid,executive,wmh,mmse,apoe), paired per-subject
  atrophy mean=+0.0070  blind mean=+0.0018  diff=+0.0052  perm-p(1-sided)=0.0000  SIGNIF

# guidance growth (s=1 -> s=3) bootstrap CI — does decoupled CFG amplify atrophy axes?
  age   growth=+0.0074  CI[+0.0044, +0.0105]  amplified
  dx    growth=+0.0041  CI[+0.0020, +0.0062]  amplified
  cdr   growth=+0.0026  CI[+0.0008, +0.0046]  amplified
