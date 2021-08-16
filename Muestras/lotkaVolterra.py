import matplotlib.pyplot as plt
import seaborn as sbn
import pandas as pd
import numpy as np

class Conejo:
    def __init__(self,gender=np.random.choice(['M','F']), age = 0, x = np.random.uniform(-10,10),y = np.random.uniform(-10,10)):
        self.x, self.y = x,y
        self.gender = gender
        self.age = age

    def __add__(self,Cp):
        if isinstance(Cp, Conejo):
            return Conejo(x=self.x,y=self.y)

    def move(self, limit_x = 10, limit_y = 10) -> None:
        m = 0.5
        self.x = (self.x + np.random.uniform(-m,m))%limit_x
        self.y = (self.y + np.random.uniform(-m,m))%limit_y

    def isNeighbor(self, Cb):
        radio = 0.02
        return True if (self.x - Cb.x)**2 + (self.y - Cb.y)**2 < radio**2 else False

    def getOld(self) -> None:
        self.age += 1/365
    
    def die(self, dr=0.35) -> None:
        return True if self.age > 2 and np.random.uniform()<dr else False
        

Conejos = [Conejo(x=np.random.uniform(-10,10),y=np.random.uniform(-10,10),gender=np.random.choice(['M','F'])) for i in range(500)]
Population_size = [len(Conejos)]
fig, ax = plt.subplots(1,1,figsize=(10,8),dpi=120)
ax.set_xlim(-1,11)
ax.set_ylim(-1,11)
X, Y = [c.x for c in Conejos],[c.y for c in Conejos]
ax.scatter(X,Y,marker='*',color='red')
for i in range(800):
    ax.cla()
    ax.set_xlim(-1,11)
    ax.set_ylim(-1,11)
    Dying = []
    for c in Conejos:
        c.move()
        c.getOld()
        if c.die():
            Dying.append(c)

    for d in Dying:
        Conejos.remove(d)
    
    Population_size.append(len(Conejos))
        
    X, Y = [c.x for c in Conejos],[c.y for c in Conejos]
    ax.scatter(X,Y,marker='*',color='red')
    plt.pause(0.1)
    
X, Y = [c.x for c in Conejos],[c.y for c in Conejos]
ax.scatter(X,Y,marker='*',color='red')
fig_1, ax_1 = plt.subplots(1,1,figsize=(10,8),dpi=120)
ax_1.plot(list(range(0,len(Population_size))),Population_size)
plt.show()