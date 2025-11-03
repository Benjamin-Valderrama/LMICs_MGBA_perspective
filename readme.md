# Beyond Solidarity: Global Mental Health Benefits from Expanding Microbiome-Gut-Brain Axis Research to the Global South 

Benjamin Valderrama<sup>1,2</sup>, Livia H. Morais<sup>3</sup>, Aonghus Lavelle<sup>1,2</sup>, Sian M.J. Hemmings<sup>4,5</sup>, Lindsay J. Hall<sup>6,7</sup>, Zul Merali<sup>8</sup>, Gerard Clarke<sup>1,9</sup>, John F. Cryan<sup>1,2</sup> 

1. APC Microbiome Ireland, University College Cork, Cork, Ireland.  

2. Department of Anatomy and Neuroscience, University College Cork, Cork, Ireland.  

3. Department of Microbiology, Immunology and Parasitology, Federal University of Santa Catarina, Florianópolis, Brazil 

4. Department of Psychiatry, Faculty of Medicine and Health Sciences, Stellenbosch University, Cape Town, South Africa 

5. South African Medical Research Council/Stellenbosch University Genomics of Brain Disorders Unit, Department of Psychiatry, Faculty of Medicine and Health Sciences, Stellenbosch University, Cape Town, South Africa 

6. Department of Microbes, Infection, and Microbiomes, School of Infection, Inflammation and Immunology, College of Medicine and Health, University of Birmingham, Birmingham, UK 

7. Food, Microbiome and Health, Quadram Institute Bioscience, Norwich Research Park, Norwich, UK 

8. Brain and Mind Institute, Aga Khan University, Nairobi, Kenya. 

9. Department of Psychiatry and Neurobehavioural Science, University College Cork, Cork, Ireland 

See the original publication at [JOURNAL DOI]


### Abstract

<div style="text-align: justify"> The microbiome-gut-brain axis is shaped by environmental factors. Increasing evidence suggests that the axis sustains brain health; yet most research is conducted in High-Income Countries (HICs). Although calls to expand this research into Low- and Middle-Income Countries (LMICs) are often grounded in solidarity constructs, they overlook a crucial aspect: studying the axis in LMICs offers an innovative route to derive concrete mental health benefits globally. Here, we provide three arguments to justify why expanding the geographic boundaries of microbiome-gut-brain axis research upholds global relevance and warn about the consequence of failing to do so. The overrepresentation of HICs may lead to: First, distorting our understanding of the role of the microbiome-gut-brain axis in mental health. Second, lead us to miss a unique opportunity to disentangle complex environmental forces by studying ‘natural experiments’ occurring in LMIC, and third, limit the development of global mental health interventions derived from lifestyles in LMIC. Therefore, we argue that expanding microbiome-gut-brain axis research in LMICs is not just ethically desirable —it is a duty of scientific rigor with potential to yield global mental health benefits. </div>

### Figure 1

![<div style="text-align: justify"> **Figure 1. Global trends of publication and collaborations in the microbiome-gut-brain axis field.** Countries from all income groups tend to collaborate more with HICs. Details about the search query and the code used can be found in this GitHub repository. (A) Number of total publications in the microbiome-gut-brain axis field by each country. Shades of green represent the Log2 of total publications. Grey depicts countries without information. (B) Proportion of total international collaborations with countries from the same income group. Small grey dots are individual countries. Green dots and bar represent the mean ± SE of each income group. Vertical grey dotted line is the global median. While HICs tend to collaborate among them, LMICs and UMICs mostly collaborate with countries of other income groups. (C) Proportion of international collaborations across income groups and years. Collaborations between pairs of income groups are shown on each panel. Shades of grey represent different income groups. Green represents collaboration between the two income groups shown on each panel. Over the years, collaborations between HICs and UMICs are becoming more prevalent in the literature. However, collaborations between these groups and LMICs remain stagnant and represent a smaller fraction across years. HICs: High Income Countries, LMICs: Low- and Middle-Income Countries, UMICs: Upper-Middle Income Countries. </div>](outputs/figure1.jpg)

### Methods

#### Data collection
<div style="text-align: justify"> The bibliometric data was collected using the Web of science (WoS) database and search tool. The Search was conducted on the 20th of October, 2025 and generated a total of 14,419 records. 14 records were removed as they were duplicated. The following query was used for the search: </div>

> TS=("microbiome-gut-brain" OR "microbiome gut brain" OR "microbiome-gut-brain axis" OR "microbiome gut brain axis" OR "microbiota-gut-brain" OR "microbiota gut brain" OR "microbiota-gut-brain axis" OR "microbiota gut brain axis" OR ("gut microbiota" AND ("behavior" OR "behaviour" OR "cognition" OR psych* OR neuro*)))
AND DOP=(2009/2025)
AND DT=(Article OR Review)

<div style="text-align: justify"> Income group from each country was retrieved from the World Bank, with data retrieved from their website on the 11th of June, 2025. All datasets used in this analysis can be downloaded from this Zenodo repository. </div>

#### Data processing and ploting

<div style="text-align: justify"> The data was imported to R using the `bibliometrix` package. Data processing and plotting was performed using the `tidyverse` suit of softwares. For the depiction of geographic data, the package `sf` was used. To unify panels into a main figure, the software `patchwork` was used.

The code used in the analysis and in the generation of figures is publicly available in the script: 'scripts/make_figures.R'. Custom functions used to facilitate the analysis can be found in 'scripts/functions.R'. </div>