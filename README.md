# sparklyr-tutorial
## How to install Spark through R
Install ‘sparklyr’ by ruining ```install.packages("sparklyr")```  
Install a local version of Spark by running the following commands  
```library(sparklyr)```  
```spark_install(version = "2.4")```  
To install the latest version of ‘sparklyr’ run ```devtools::install_github("rstudio/sparklyr") ```  

## sparklyr_practice.R
This file walks through basic data manipulation and machine learning methods on the built-in mtcars using ‘sparklyr’. Besides installing Spark and sparklyr, there are no prerequisites to run this script. 
