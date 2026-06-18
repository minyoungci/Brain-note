# DICOM and Histopath Audit

DICOM sample headers were read with `stop_before_pixels=True`; no pixel data was loaded.

## DICOM Series Inventory

| series_concept    |   series |   subjects |   images |
|:------------------|---------:|-----------:|---------:|
| t1                |      680 |        597 |   120034 |
| flair             |      655 |        614 |    38547 |
| t2                |      653 |        613 |    51510 |
| t1ce_or_t1post    |      605 |        566 |   111411 |
| dti_or_diffusion  |      580 |        542 |    65815 |
| perfusion         |      489 |        455 |   437885 |
| other_mr          |        9 |          8 |     1288 |
| secondary_capture |        9 |          8 |     1744 |

## DICOM Sample Header Errors

No DICOM sample header read errors.

## Sample Header Geometry

| series_concept    |   Rows |   Columns | PixelSpacing                      |   SliceThickness |   SpacingBetweenSlices | MagneticFieldStrength   | Manufacturer            |   sample_files |
|:------------------|-------:|----------:|:----------------------------------|-----------------:|-----------------------:|:------------------------|:------------------------|---------------:|
| dti_or_diffusion  |    896 |       896 | 1.71875\1.71875                   |              3   |                      3 | 3                       | SIEMENS                 |              4 |
| dti_or_diffusion  |    896 |       896 | 1.71875\1.71875                   |              3   |                      3 | 3                       | SIEMENS                 |              2 |
| dti_or_diffusion  |    896 |       896 | 1.71875\1.71875                   |              3   |                      3 | 3                       | SIEMENS                 |              1 |
| dti_or_diffusion  |    896 |       896 | 1.71875\1.71875                   |              3   |                      3 | 3                       | SIEMENS                 |              1 |
| flair             |    256 |       192 | 0.9375\0.9375                     |              3   |                      1 | 3                       | SIEMENS                 |              8 |
| other_mr          |    512 |       384 | 0.48828125\0.48828125             |              1   |                      1 | 3                       | SIEMENS                 |              3 |
| other_mr          |    256 |       192 | 0.9765625\0.9765625               |              1   |                      1 | 2.8936200141907         | SIEMENS                 |              1 |
| other_mr          |    256 |       232 | 0.9765625\0.9765625               |              1   |                      1 | 1.5                     | SIEMENS                 |              1 |
| other_mr          |    256 |       256 | 0.9375\0.9375                     |              1.5 |                      1 | 15000                   | GE MEDICAL SYSTEMS      |              1 |
| other_mr          |    320 |       236 | 0.6875\0.6875                     |              4   |                      1 | 3                       | SIEMENS                 |              1 |
| other_mr          |    512 |       512 | 0.4296875\0.4296875               |              4   |                      1 | 3                       | SIEMENS                 |              1 |
| perfusion         |    128 |       128 | 1.71875\1.71875                   |              3   |                      3 | 3                       | SIEMENS                 |              5 |
| perfusion         |    128 |       128 | 1.71875\1.71875                   |              4   |                      4 | 3                       | SIEMENS                 |              3 |
| secondary_capture |    256 |       192 | 0.9765625\0.9765625               |              1   |                      1 |                         | SIEMENS                 |              3 |
| secondary_capture |    512 |       384 | 0.48828125\0.48828125             |              1   |                      1 |                         | SIEMENS                 |              2 |
| secondary_capture |    512 |       384 | 4.882810e-01\4.882810e-01         |              1   |                      1 |                         | SIEMENS                 |              2 |
| secondary_capture |    256 |       192 | .976562023162842\.976562023162842 |              0.9 |                      1 |                         | Siemens HealthCare GmbH |              1 |
| t1                |    256 |       192 | 0.9765625\0.9765625               |              1   |                      1 | 3                       | SIEMENS                 |              8 |
| t1ce_or_t1post    |    256 |       192 | 0.9765625\0.9765625               |              1   |                      1 | 3                       | SIEMENS                 |              7 |
| t1ce_or_t1post    |    512 |       416 | 0.4296875\0.4296875               |              5   |                      1 | 1.5                     | SIEMENS                 |              1 |
| t2                |    256 |       208 | 0.9375\0.9375                     |              3   |                      1 | 3                       | SIEMENS                 |              3 |
| t2                |    256 |       208 | 0.9765625\0.9765625               |              3   |                      1 | 3                       | SIEMENS                 |              1 |
| t2                |    320 |       256 | .896875023841858\.896875023841858 |              0.9 |                      1 | 3                       | SIEMENS                 |              1 |
| t2                |    320 |       256 | 8.968750e-01\8.968750e-01         |              0.9 |                      1 | 3                       | SIEMENS                 |              1 |
| t2                |    512 |       448 | 0.4296875\0.4296875               |              3   |                      1 | 1.5                     | SIEMENS                 |              1 |
| t2                |    512 |       448 | 0.4296875\0.4296875               |              5   |                      1 | 1.5                     | SIEMENS                 |              1 |

## Histopath Inventory

|   slides |   existing_files |   linkable_to_radiology |   missing_radiology_id |   total_size_gib |
|---------:|-----------------:|------------------------:|-----------------------:|-----------------:|
|       71 |               71 |                      38 |                     33 |          148.302 |

## Notes

- UPENN DICOM overlaps with UPENN NIfTI and should not be split or modeled as independent subjects.
- Histopath requires an additional WSI library audit before thumbnail/patch extraction; `openslide` is not currently available in this environment.
- Full DICOM header audit command preview: `python docs/context/build_dicom_histopath_audit.py --mode full`.
