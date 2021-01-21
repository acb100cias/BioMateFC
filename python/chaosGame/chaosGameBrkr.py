# importing necessary packages
import random
import numpy as np
import time
import matplotlib.pyplot as plt
import os
import sys

# set default figure size
plt.rcParams['figure.figsize'] = (10.0, 8.0)

def chaosGameBrkr(start=None,n=None,breaks=None):

    plt.scatter([0,2,4], [0,4,0])
    bounds = ([0,0],[2,4],[4,0])
    plt.xlim([-0.5,4.5])
    plt.ylim([-0.5,4.5])

    if start==None:
        # default starting point
        start=np.array([2,2])
    if n==None:
        # default number of iterations
        n=500
    if breaks==None:
        sys.exit("breaks must be specified")

    for i in xrange(1,n+1):
        plt.scatter(start[0],start[1],lw='0',s=19)
        plt.draw()

        rnc=random.choice(bounds)
        rnc=np.array(rnc)
        start=start+(0.5*(rnc-start))

        if i % breaks == 0:
            # save the final figure
            plt.savefig(os.getcwd()+"/images/"+str(i)+"chaos_game"+str(n)+".png")

    return None
