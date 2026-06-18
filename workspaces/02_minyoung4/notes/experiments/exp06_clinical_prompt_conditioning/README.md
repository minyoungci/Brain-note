# exp06: Clinical Prompt Conditioning

Status: scaffold only.

## Objective

Test whether controlled clinical prompt conditioning improves over trivial tabular
concatenation without turning scanner/site information into label leakage.

## Prior-Work Gap

Glio-LLaMA-Vision uses age/sex and paired reports. Swin hybrid models use age/location.
Our setting lacks paired radiology reports, so the prompt must be structured and controlled.

## Candidate Inputs

- Age bin.
- Sex.
- Scanner/vendor and field strength for diagnostics or regularization, not naive final-prompt use unless justified.

## Fusion Methods

- Image only.
- Image + tabular concat.
- Image + learned prompt token.
- FiLM/adaptive normalization.
- Cross-attention prompt fusion.

## Required Controls

- Prompt shuffle.
- Age-only.
- Sex-only.
- Scanner removed.
- Scanner diagnostic-only.

## Success Condition

Prompt conditioning must beat image+tabular concat and prompt-shuffle under LOCO.

## Main Risk

Clinical prompts may encode site/age label priors rather than image-conditioned evidence.

