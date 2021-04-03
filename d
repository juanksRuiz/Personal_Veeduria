[1mdiff --git a/Analisis_modelos_secop1 (1).ipynb b/Analisis_modelos_secop1 (1).ipynb[m
[1mdeleted file mode 100644[m
[1mindex b525758..0000000[m
[1m--- a/Analisis_modelos_secop1 (1).ipynb[m	
[1m+++ /dev/null[m
[36m@@ -1,4304 +0,0 @@[m
[31m-{[m
[31m- "cells": [[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": 161,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "import os\n",[m
[31m-    "import numpy as np\n",[m
[31m-    "import pandas as pd\n",[m
[31m-    "\n",[m
[31m-    "import matplotlib.pyplot as plt\n",[m
[31m-    "\n",[m
[31m-    "from sklearn.utils import resample\n",[m
[31m-    "from sklearn import preprocessing\n",[m
[31m-    "from sklearn.model_selection import train_test_split, cross_val_score, GridSearchCV\n",[m
[31m-    "from sklearn.feature_selection import RFE, SelectFromModel\n",[m
[31m-    "from sklearn.metrics import *\n",[m
[31m-    "from sklearn.linear_model import LogisticRegression\n",[m
[31m-    "from sklearn.ensemble import RandomForestClassifier, ExtraTreesClassifier\n",[m
[31m-    "\n",[m
[31m-    "import scipy.stats as stats\n",[m
[31m-    "from scipy import stats\n",[m
[31m-    "from scipy.stats import kruskal\n",[m
[31m-    "from scipy import stats\n",[m
[31m-    "\n",[m
[31m-    "import pycorrcat.pycorrcat as corrcat  #Calcula la V de cramer para variables categóricas.\n",[m
[31m-    "\n",[m
[31m-    "import statsmodels.api as sm\n",[m
[31m-    "\n",[m
[31m-    "import seaborn as sns\n",[m
[31m-    "# os.chdir('C:/Users/santiago/Documents/Proyecto AI Veeduría')\n",[m
[31m-    "os.chdir('C:/Users/juanc/OneDrive/Escritorio/LOCAL_Personal_Veeduria')\n"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "## Descripción breve de los datos"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "df = pd.read_csv(\"SECOP_I_MASTER.csv\")"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "df.head()"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Dimensiones del dataset secop I inicial: \",df.shape)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "df['Valor Promedio de la Sancion'].fillna(0,inplace = True) "[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "df.info()"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Orden Entidad"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "orden = pd.DataFrame(df[\"Orden Entidad\"].value_counts())/len(df)\n",[m
[31m-    "print(\"Porcentaje de entidades por Orden:\")\n",[m
[31m-    "print(orden)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "fig = plt.figure(figsize=(10,5));\n",[m
[31m-    "pos = [2*i for i in range(1,6)]\n",[m
[31m-    "plt.barh(pos,np.flip(orden[\"Orden Entidad\"])/len(df),\n",[m
[31m-    "         tick_label=np.flip(orden.index));\n",[m
[31m-    "plt.xticks(rotation=45);\n",[m
[31m-    "plt.title(\"Porcentaje de distribucion de entidades por Orden\")"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Tipo de Proceso"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos por Tipo de proceso:\")\n",[m
[31m-    "df[\"Tipo de Proceso\"].value_counts()/len(df)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Estado del proceso"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos por Estado de proceso:\")\n",[m
[31m-    "df[\"Estado del Proceso\"].value_counts()/len(df)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Causal de Otras Formas de Contratacion Directa"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos Causal de Otras Formas de Contratacion Directa:\")\n",[m
[31m-    "df[\"Causal de Otras Formas de Contratacion Directa\"].value_counts()/len(df)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Régimen de Contratación"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos Régimen de Contratación:\")\n",[m
[31m-    "df[\"Regimen de Contratacion\"].value_counts()/len(df)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Objeto a Contratar"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos Objeto a Contratar:\")\n",[m
[31m-    "df[\"Objeto a Contratar\"].value_counts()/len(df)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Nombre grupo"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos Nombre Grupo:\")\n",[m
[31m-    "df[\"Nombre Grupo\"].value_counts()/len(df)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Nombre Familia"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos Nombre Familia:\")\n",[m
[31m-    "df[\"Nombre Familia\"].value_counts(normalize = True).head(50)#/len(df)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Nombre Clase"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos Nombre Clase:\")\n",[m
[31m-    "df[\"Nombre Clase\"].value_counts(normalize = True).head(10)#/len(df)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Tipo de Contrato"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {[m
[31m-    "scrolled": true[m
[31m-   },[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos por Tipo de contrato:\")\n",[m
[31m-    "df[\"Tipo de Contrato\"].value_counts()/len(df)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### EsPostConflicto"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos por EsPostConflicto:\")\n",[m
[31m-    "df[\"EsPostConflicto\"].value_counts()/len(df)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Definición del Origen de los Recursos"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos por Def Origen Recur:\")\n",[m
[31m-    "df[\"Def Origen Recur\"].value_counts()/len(df)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Número Origenes de los recursos"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos por Num Origenes Recur:\")\n",[m
[31m-    "df[\"Num Origenes Recur\"].value_counts()/len(df)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Tipo de Identificación del Contratista"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos por Tipo Identifi del Contratista:\")\n",[m
[31m-    "df[\"Tipo Identifi del Contratista\"].value_counts()/len(df)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Departamento y Minicipio del Contratista"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos por  Dpto y Muni Contratista:\")\n",[m
[31m-    "df[\"Dpto y Muni Contratista\"].value_counts(normalize = True).head(20)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Mes Firma del Contrato"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos por Mes Firma Contrato:\")\n",[m
[31m-    "df[\"Mes Firma Contrato\"].value_counts(normalize = True)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Día Mes Firma del Contrato"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos por Día Mes Firma Contrato:\")\n",[m
[31m-    "df[\"Dia del Mes Firma Contrato\"].value_counts(normalize = True)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Día de la Semana Firma del Contrato"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos por Día de la Firma Contrato:\")\n",[m
[31m-    "df[\"Dia de la Semana Firma Contrato\"].value_counts(normalize = True)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Plazo en dias de Ejec del Contrato"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos por Plazo en dias de Ejec del Contrato:\")\n",[m
[31m-    "df[\"Plazo en dias de Ejec del Contrato\"].value_counts(normalize = True).head(30)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Marc Adiciones"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos por Plazo en dias de Marc Adiciones:\")\n",[m
[31m-    "df[\"Marc Adiciones\"].value_counts(normalize = True).head(30)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Adicion en Valor"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos por Plazo en Adicion en Valor:\")\n",[m
[31m-    "df[\"Adicion en Valor\"].value_counts(normalize = True)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Adicion en Tiempo"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos por Plazo en Adicion en Tiempo:\")\n",[m
[31m-    "df[\"Adicion en Tiempo\"].value_counts(normalize = True)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Tiempo Adiciones (Dias)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos por Plazo en Tiempo Adiciones (Dias):\")\n",[m
[31m-    "df[\"Tiempo Adiciones (Dias)\"].value_counts(normalize = True).head(20)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Nombre Sub Unidad Ejecutora"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos por Nombre Sub Unidad Ejecutora:\")\n",[m
[31m-    "df[\"Nombre Sub Unidad Ejecutora\"].value_counts(normalize = True).head(20)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Moneda"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos por Moneda:\")\n",[m
[31m-    "df[\"Moneda\"].value_counts(normalize = True)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Marcación Sanción"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "print(\"Porcentaje de datos por Marc Sancion:\")\n",[m
[31m-    "df[\"Marc Sancion\"].value_counts(normalize = True)"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Cuantía Proceso"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "df['Cuantia Proceso'].describe().to_frame()"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "len(df[df['Cuantia Proceso'] == 0.0])"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "q952 = df['Cuantia Proceso'].quantile(0.95)\n",[m
[31m-    "valor_procesos = df.loc[df['Cuantia Proceso'] < q952, 'Cuantia Proceso']\n",[m
[31m-    "\n",[m
[31m-    "bx = sns.boxplot(y=valor_procesos);\n",[m
[31m-    "bx.get_yaxis().get_major_formatter().set_scientific(False)\n",[m
[31m-    "plt.show()\n"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "fig, ax = plt.subplots(figsize=(14,5))\n",[m
[31m-    "ax.hist(valor_procesos, bins=50, rwidth=0.8)\n",[m
[31m-    "ax.get_xaxis().get_major_formatter().set_scientific(False)\n",[m
[31m-    "plt.xticks(rotation=45)\n",[m
[31m-    "plt.ylabel('Frecuencia')\n",[m
[31m-    "plt.xlabel('Valor Proceso')\n",[m
[31m-    "plt.title('Distribución de la Cuantía de los Procesos(excluyendo valores superiores al percentil 95)')"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "markdown",[m
[31m-   "metadata": {},[m
[31m-   "source": [[m
[31m-    "### Cuantía Contrato"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "df['Cuantia Contrato'].describe().to_frame()"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "len(df[df['Cuantia Contrato'] == 0.0])"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "q952 = df['Cuantia Contrato'].quantile(0.95)\n",[m
[31m-    "valor_contratos = df.loc[df['Cuantia Contrato'] < q952, 'Cuantia Contrato']\n",[m
[31m-    "\n",[m
[31m-    "bx = sns.boxplot(y=valor_contratos);\n",[m
[31m-    "bx.get_yaxis().get_major_formatter().set_scientific(False)\n",[m
[31m-    "plt.show()\n"[m
[31m-   ][m
[31m-  },[m
[31m-  {[m
[31m-   "cell_type": "code",[m
[31m-   "execution_count": null,[m
[31m-   "metadata": {},[m
[31m-   "outputs": [],[m
[31m-   "source": [[m
[31m-    "fig, ax = plt.subplots(figsize=(14,5))\n",[m
[31m-    "ax.hist(valor_contratos, bins=50, rwidth=0.8)\n",[m
[31m-    "ax.get_xaxis().get_major_formatter().set_scientific(False)