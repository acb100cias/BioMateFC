# Modelos de crecimiento de poblaciones

En esta sesión veremos modelos continuos basados en ecuaciones diferenciales. Nos interesa modelar el crecimiento de una población en el tiempo.



## 1. Modelo de Malthus

El modelo de Malthus es el modelo de crecimiento mas sencillo. Llamaremos $X(t)$ a la población al tiempo $t$. Consideramos las siguientes hipótesis

* H1 La población crece de manera proporcional a su tamaño $\dot{X}(t)\propto X(t)$
* H2 La tasa de crecimiento es constante $\alpha$
* H3 La cantidad de recursos es ilimitada

La expresión matemática de este modelo es la siguiente ecuación diferencial

$$\dot{X}(t)=\alpha X(t)$$
con condición inicial

$$X(t_0)=X_0$$



Esta es una ecuación separable o de variables separables. Así que la ecuación diferencial que tenemos podemos escribirla equivalentemente como la ecuación integral:
$$
\int\dfrac{\mathrm{d}X}{X}=\alpha\int\mathrm{d}t
$$
cuya solución es 
$$
ln(X)=\alpha t + \cal{C}
$$
donde $\cal{C}$ es una constante arbitraria de  integración. Aplicando la exponencial en ambos lados de la ecuación obtenemos
$$
X(t)=e^{\alpha t}e^{\cal{C}}
$$
Ahora, utlizando las condiciones imiciales, tenemos:
$$
X_0=e^{\cal{C}}
$$

Así la ecuación que modela el crecimiento de poblaciones con las hipótesis H1-H3 es
$$
X(t)=X_0e^{\alpha t}
$$
